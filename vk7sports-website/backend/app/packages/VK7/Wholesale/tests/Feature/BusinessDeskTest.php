<?php

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Http;
use VK7\Wholesale\Couriers\DemoCourier;
use VK7\Wholesale\Models\OrderTerm;
use VK7\Wholesale\Models\Payment;
use VK7\Wholesale\Payments\PaymentGateway;
use VK7\Wholesale\Payments\RazorpayGateway;
use VK7\Wholesale\Services\OrderFinance;
use Webkul\Customer\Models\Customer;
use Webkul\Sales\Models\Order;
use Webkul\User\Models\Admin;
use Webkul\User\Models\Role;

beforeEach(function () {
    Artisan::call('vk7:apply-policy');

    Artisan::call('vk7:demo-data');

    config(['vk7.payments.gateway' => 'demo', 'vk7.courier.provider' => 'demo']);
});

/**
 * Place a 24-piece order for a new retailer, returning both.
 */
function placedOrder(string $name = 'alpha'): array
{
    $retailer = retailer($name);

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    return [$retailer, checkout($retailer)->assertCreated()->json('data.id')];
}

/**
 * Sign in a staff member with a role limited to the given desk areas, or the full admin.
 */
function staffToken(?array $areas = null): string
{
    $staff = $areas === null ? Admin::first() : Admin::create([
        'name' => 'TEST Staff',
        'email' => 'staff-'.uniqid().'@example.test',
        'password' => bcrypt('Test-Password-1'),
        'status' => 1,
        'role_id' => Role::create([
            'name' => 'TEST role '.uniqid(),
            'permission_type' => 'custom',
            'permissions' => array_map(fn ($area) => 'vk7_desk.'.$area, $areas),
        ])->id,
    ]);

    return $staff->createToken('test', ['staff'], now()->addHour())->plainTextToken;
}

/**
 * Send a request as staff.
 */
function asStaff(string $token, string $method, string $uri, array $data = [])
{
    app('auth')->forgetGuards();

    return test()->withToken($token)->json($method, $uri, $data);
}

/**
 * Pay the advance through the simulated gateway.
 */
function payAdvance(array $retailer, int $orderId): void
{
    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertCreated();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm", ['simulated_result' => 'success'])->assertOk();
}

// ====================================================================
// Advance And Balance
// ====================================================================

it('asks for a ten percent advance and holds the rest until after delivery', function () {
    [$retailer, $orderId] = placedOrder();

    $finance = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->assertOk()->json('data.finance');

    expect($finance['stage'])->toBe('Awaiting advance')
        ->and($finance['payable'])->toBe('advance')
        ->and($finance['advance_due'])->toEqual(round($finance['total'] * 0.1, 2))
        ->and($finance['outstanding'])->toEqual($finance['total']);

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'balance'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'NOT_PAYABLE');
});

it('confirms the order only after a successful payment', function () {
    [$retailer, $orderId] = placedOrder();

    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertCreated();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm", ['simulated_result' => 'failed'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'PAYMENT_FAILED');

    expect(asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance.stage'))->toBe('Awaiting advance');

    payAdvance($retailer, $orderId);

    $finance = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance');

    expect($finance['stage'])->toBe('Confirmed')
        ->and($finance['paid'])->toEqual($finance['advance_due'])
        ->and($finance['payable'])->toBeNull();
});

it('reuses an open payment instead of opening a second one', function () {
    [$retailer, $orderId] = placedOrder();

    $first = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->json('data.payment_id');

    $second = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->json('data.payment_id');

    expect($second)->toBe($first);
});

it('does not let one retailer pay or see the payment of another', function () {
    [, $orderId] = placedOrder('alpha');

    $stranger = retailer('bravo');

    asRetailer($stranger, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertNotFound();

    asRetailer($stranger, 'POST', "/api/v1/orders/{$orderId}/payments/reference", [
        'kind' => 'advance',
        'method' => 'UPI',
        'reference' => 'UTR1234567',
    ])->assertNotFound();
});

it('sends a bank reference to finance and refuses it twice', function () {
    [$retailer, $orderId] = placedOrder('alpha');

    $body = ['kind' => 'advance', 'method' => 'UPI', 'reference' => 'UTR1234567'];

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/reference", $body)->assertCreated();

    expect(asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance.stage'))->toBe('Awaiting advance');

    [$other, $otherOrder] = placedOrder('bravo');

    asRetailer($other, 'POST', "/api/v1/orders/{$otherOrder}/payments/reference", $body)
        ->assertStatus(422)
        ->assertJsonPath('code', 'DUPLICATE_REFERENCE');

    $payment = Payment::where('order_id', $orderId)->firstOrFail();

    asStaff(staffToken(), 'POST', "/api/v1/admin/payments/{$payment->id}/review", ['accepted' => true])->assertOk();

    app('auth')->forgetGuards();

    expect(asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance.stage'))->toBe('Confirmed');
});

it('expires an unpaid order, releases it and leaves a paid one alone', function () {
    [, $orderId] = placedOrder('alpha');

    [$paying, $paidOrder] = placedOrder('bravo');

    payAdvance($paying, $paidOrder);

    OrderTerm::query()->update(['hold_until' => now()->subHour()]);

    app(OrderFinance::class)->expireOverdue();

    expect(OrderTerm::where('order_id', $orderId)->value('stage'))->toBe('Expired')
        ->and(Order::find($orderId)->status)->toBe('canceled')
        ->and(OrderTerm::where('order_id', $paidOrder)->value('stage'))->toBe('Confirmed');
});

// ====================================================================
// Razorpay
// ====================================================================

it('accepts only a correctly signed Razorpay result for the same order', function () {
    config(['vk7.payments.gateway' => 'razorpay', 'vk7.payments.razorpay.key_id' => 'rzp_test_x', 'vk7.payments.razorpay.key_secret' => 'test-secret']);

    Http::fake(['api.razorpay.com/*' => Http::response(['id' => 'order_TEST123'])]);

    [$retailer, $orderId] = placedOrder();

    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertCreated();

    $uri = "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm";

    expect($start->json('data.options.key'))->toBe('rzp_test_x')
        ->and($start->json('data.options'))->not->toHaveKey('key_secret');

    Http::assertSent(fn ($request) => $request['amount'] === (int) round(Payment::first()->amount * 100));

    asRetailer($retailer, 'POST', $uri, ['razorpay_order_id' => 'order_TEST123', 'razorpay_payment_id' => 'pay_1', 'razorpay_signature' => 'forged'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'PAYMENT_NOT_VERIFIED');

    asRetailer($retailer, 'POST', $uri, [
        'razorpay_order_id' => 'order_OTHER',
        'razorpay_payment_id' => 'pay_1',
        'razorpay_signature' => hash_hmac('sha256', 'order_OTHER|pay_1', 'test-secret'),
    ])->assertStatus(422);

    expect(OrderTerm::first()->stage)->toBe('Awaiting advance');

    asRetailer($retailer, 'POST', $uri, [
        'razorpay_order_id' => 'order_TEST123',
        'razorpay_payment_id' => 'pay_1',
        'razorpay_signature' => hash_hmac('sha256', 'order_TEST123|pay_1', 'test-secret'),
    ])->assertOk()->assertJsonPath('data.stage', 'Confirmed');
});

it('refuses live Razorpay keys until real payments are authorised', function () {
    config(['vk7.payments.gateway' => 'razorpay', 'vk7.payments.razorpay.key_id' => 'rzp_live_x', 'vk7.payments.razorpay.key_secret' => 'secret']);

    Http::fake();

    [$retailer, $orderId] = placedOrder();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'GATEWAY_UNAVAILABLE');

    Http::assertNothingSent();
});

it('applies a signed webhook once and rejects a forged one', function () {
    config([
        'vk7.payments.gateway' => 'razorpay',
        'vk7.payments.razorpay.key_id' => 'rzp_test_x',
        'vk7.payments.razorpay.key_secret' => 'test-secret',
        'vk7.payments.razorpay.webhook_secret' => 'hook-secret',
    ]);

    Http::fake(['api.razorpay.com/*' => Http::response(['id' => 'order_HOOK'])]);

    [$retailer, $orderId] = placedOrder();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertCreated();

    $payment = Payment::firstOrFail();

    $send = fn (array $payload, string $signature) => test()->call(
        'POST',
        '/api/v1/webhooks/razorpay',
        [],
        [],
        [],
        ['HTTP_X-Razorpay-Signature' => $signature, 'CONTENT_TYPE' => 'application/json'],
        json_encode($payload),
    );

    $body = fn (int $paise) => ['event' => 'payment.captured', 'payload' => ['payment' => ['entity' => ['id' => 'pay_h', 'order_id' => 'order_HOOK', 'amount' => $paise]]]];

    $good = $body(RazorpayGateway::paise($payment->amount));

    $send($good, 'forged')->assertStatus(400);

    expect($payment->fresh()->status)->toBe('created');

    $wrongAmount = $body(100);

    $send($wrongAmount, hash_hmac('sha256', json_encode($wrongAmount), 'hook-secret'))->assertOk();

    expect($payment->fresh()->status)->toBe('created');

    $signature = hash_hmac('sha256', json_encode($good), 'hook-secret');

    $send($good, $signature)->assertOk();

    $send($good, $signature)->assertOk();

    expect($payment->fresh()->status)->toBe('verified')
        ->and(Payment::where('status', 'verified')->count())->toBe(1)
        ->and(OrderTerm::first()->stage)->toBe('Confirmed');
});

it('uses the configured gateway implementation', function () {
    config(['vk7.payments.gateway' => 'razorpay']);

    expect(app(PaymentGateway::class))->toBeInstanceOf(RazorpayGateway::class);
});

// ====================================================================
// Courier
// ====================================================================

it('dispatches, tracks and collects the balance after delivery', function () {
    [$retailer, $orderId] = placedOrder();

    $staff = staffToken();

    asStaff($staff, 'POST', "/api/v1/admin/orders/{$orderId}/dispatch")->assertStatus(422)->assertJsonPath('code', 'INVALID_STAGE');

    payAdvance($retailer, $orderId);

    asStaff($staff, 'POST', "/api/v1/admin/orders/{$orderId}/stage", ['stage' => 'Packing'])->assertOk();

    $order = asStaff($staff, 'POST', "/api/v1/admin/orders/{$orderId}/dispatch")->assertOk()->json('data');

    expect($order['stage'])->toBe('Dispatched')
        ->and($order['tracking']['events'])->toHaveCount(1)
        ->and($order['tracking']['simulated'])->toBeTrue()
        ->and(Order::find($orderId)->shipments)->toHaveCount(1);

    foreach (range(1, 12) as $scan) {
        $order = asStaff($staff, 'POST', "/api/v1/admin/shipments/{$order['tracking']['id']}/refresh")->assertOk()->json('data');
    }

    expect($order['stage'])->toBe('Delivered')
        ->and($order['tracking']['status'])->toBe('Delivered')
        ->and($order['payable'])->toBe('balance');

    $retailerView = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->assertOk()->json('data');

    expect(count($retailerView['tracking']['events']))->toBeGreaterThanOrEqual(5)
        ->and(end($retailerView['tracking']['events'])['status'])->toBe('Delivered');

    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'balance'])->assertCreated();

    expect((float) $start->json('data.amount'))->toEqual($retailerView['finance']['outstanding']);

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm", ['simulated_result' => 'success'])
        ->assertOk()
        ->assertJsonPath('data.stage', 'Paid in full');

    expect(Order::find($orderId)->status)->toBe('completed');
});

it('tracks publicly without showing any money', function () {
    [$retailer, $orderId] = placedOrder();

    $order = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data');

    app('auth')->forgetGuards();

    $data = test()->flushHeaders()->postJson('/api/v1/orders/track', ['number' => $order['order_number'], 'phone' => '9876543210'])
        ->assertOk()
        ->assertJsonPath('data.stage', 'Awaiting advance')
        ->json('data');

    expect($data)->not->toHaveKey('finance')->not->toHaveKey('grand_total');
});

// ====================================================================
// Business Desk
// ====================================================================

it('reports monthly sales, pending payments and clients', function () {
    [$retailer, $orderId] = placedOrder('alpha');

    placedOrder('bravo');

    payAdvance($retailer, $orderId);

    $staff = staffToken();

    $report = asStaff($staff, 'GET', '/api/v1/admin/reports')->assertOk()->json('data');

    $paid = Payment::where('status', 'verified')->sum('amount');

    expect($report['orders'])->toBe(2)
        ->and($report['monthly'])->toHaveCount(1)
        ->and((float) $report['monthly'][0]['collected'])->toEqual((float) $paid)
        ->and($report['pending'])->toHaveCount(2)
        ->and($report['outstanding'])->toEqual(round($report['sales'] - $paid, 2));

    $clients = asStaff($staff, 'GET', '/api/v1/admin/clients')->assertOk()->json('data');

    expect(collect($clients)->pluck('company')->all())->toContain('TEST-alpha Traders', 'TEST-bravo Traders');

    expect(asStaff($staff, 'GET', '/api/v1/admin/dashboard')->assertOk()->json('data.ordersToday'))->toBe(2);
});

it('keeps the desk closed to retailers, visitors and the wrong role', function () {
    $retailer = retailer();

    test()->getJson('/api/v1/admin/reports')->assertUnauthorized();

    asRetailer($retailer, 'GET', '/api/v1/admin/reports')->assertUnauthorized();

    app('auth')->forgetGuards();

    $warehouse = staffToken(['dashboard', 'orders', 'dispatch']);

    asStaff($warehouse, 'GET', '/api/v1/admin/orders')->assertOk();

    asStaff($warehouse, 'GET', '/api/v1/admin/payments')->assertForbidden()->assertJsonPath('code', 'FORBIDDEN');

    asStaff($warehouse, 'GET', '/api/v1/admin/reports')->assertForbidden();
});

it('signs staff in and refuses a wrong password', function () {
    $staff = Admin::first();

    $staff->update(['password' => bcrypt('Test-Password-1')]);

    test()->postJson('/api/v1/admin/login', ['email' => $staff->email, 'password' => 'wrong'])->assertUnauthorized();

    $token = test()->postJson('/api/v1/admin/login', ['email' => $staff->email, 'password' => 'Test-Password-1'])->assertOk()->json('token');

    asStaff($token, 'GET', '/api/v1/admin/me')->assertOk()->assertJsonPath('data.email', $staff->email);

    asStaff($token, 'POST', '/api/v1/admin/logout')->assertOk();

    expect($staff->tokens()->count())->toBe(0);
});

it('suspends a client and ends their session', function () {
    $retailer = retailer();

    $id = Customer::where('email', $retailer['email'])->value('id');

    $staff = staffToken();

    asStaff($staff, 'POST', "/api/v1/admin/clients/{$id}/decision", ['decision' => 'suspended'])->assertStatus(422);

    asStaff($staff, 'POST', "/api/v1/admin/clients/{$id}/decision", ['decision' => 'suspended', 'reason' => 'Fictional test'])
        ->assertOk()
        ->assertJsonPath('data.status', 'suspended');

    asRetailer($retailer, 'GET', '/api/v1/orders')->assertUnauthorized();
});

// ====================================================================
// Demo Courier
// ====================================================================

it('routes a demo shipment through hubs on the way and scans each one', function () {
    $courier = new DemoCourier;

    $booking = $courier->book([
        'origin' => ['city' => 'Mumbai', 'state' => 'MH'],
        'destination' => ['city' => 'Lucknow', 'state' => 'Uttar Pradesh'],
    ]);

    $stops = array_column($booking['route'], 'label');

    $scans = $courier->track($booking['waybill'], ['route' => $booking['route'], 'scans' => 50]);

    expect($stops[0])->toBe('Mumbai')
        ->and(end($stops))->toBe('Lucknow')
        ->and(count($stops))->toBeGreaterThan(2)
        ->and($stops)->toBe(array_unique($stops))
        ->and(array_column($scans, 'location'))->toContain($stops[1])
        ->and(end($scans)['status'])->toBe('Delivered');
});

it('goes straight to the destination on a short demo shipment', function () {
    $booking = (new DemoCourier)->book([
        'origin' => ['city' => 'Mumbai', 'state' => 'MH'],
        'destination' => ['city' => 'Pune', 'state' => 'Maharashtra'],
    ]);

    expect(array_column($booking['route'], 'label'))->toBe(['Mumbai', 'Pune']);
});

// ====================================================================
// Security Regressions
// ====================================================================

it('does not let a retailer confirm a bank reference as an online payment', function () {
    [$retailer, $orderId] = placedOrder();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/reference", [
        'kind' => 'advance',
        'method' => 'UPI',
        'reference' => 'UPI12345678',
    ])->assertCreated();

    $payment = Payment::where('order_id', $orderId)->first();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$payment->id}/confirm", ['simulated_result' => 'success'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'PAYMENT_NOT_OPEN');

    expect($payment->fresh()->status)->toBe('submitted');
});

it('refuses simulated payments outside a developer computer unless a demo is allowed', function () {
    [$retailer, $orderId] = placedOrder();

    app()->detectEnvironment(fn () => 'staging');

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'GATEWAY_UNAVAILABLE');

    config(['vk7.payments.allow_demo' => true]);

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance'])->assertCreated();
});

it('does not open order tracking with a blank mobile number', function () {
    [, $orderId] = placedOrder();

    $order = Order::find($orderId);

    $order->addresses()->update(['phone' => '']);

    test()->postJson('/api/v1/orders/track', ['number' => $order->increment_id, 'phone' => 'none'])
        ->assertNotFound();
});

it('closes the old storefront and installer but keeps the API and password links', function () {
    config(['vk7.site.close_bagisto_shop' => true, 'vk7.site.url' => 'https://site.example']);

    test()->get('/')->assertRedirect('https://site.example');

    test()->get('/customer/register')->assertRedirect('https://site.example');

    test()->get('/api/categories')->assertRedirect('https://site.example');

    test()->postJson('/api/checkout/onepage/orders')->assertNotFound();

    test()->postJson('/customer/register', ['email' => 'late@example.test'])->assertNotFound();

    test()->postJson('/install/api/create-admin-user')->assertNotFound();

    test()->get('/%69nstall')->assertRedirect('https://site.example');

    test()->getJson('/api/v1/meta')->assertOk();

    expect(test()->get('/customer/reset-password/any-token')->status())->toBe(200);
});

it('refuses a retailer account on staff routes and a staff account on retailer routes', function () {
    retailer();

    $token = Customer::latest('id')->first()->createToken('all-areas', ['*'], now()->addHour())->plainTextToken;

    asStaff($token, 'GET', '/api/v1/admin/me')->assertUnauthorized();

    $staffToken = Admin::first()->createToken('all-areas', ['*'], now()->addHour())->plainTextToken;

    app('auth')->forgetGuards();

    test()->withToken($staffToken)->getJson('/api/v1/auth/me')->assertUnauthorized();
});

it('rejects a registration password shorter than eight characters', function () {
    test()->postJson('/api/v1/auth/register', [
        'first_name' => 'Short',
        'last_name' => 'Password',
        'business_name' => 'TEST Short Password Shop',
        'email' => 'short-password@example.test',
        'phone' => '9000000123',
        'password' => 'abc123',
        'password_confirmation' => 'abc123',
    ])->assertStatus(422)->assertJsonValidationErrors('password');
});

it('locks staff sign-in after repeated failures and keeps it locked', function () {
    $staff = Admin::first();

    foreach (range(1, 5) as $attempt) {
        test()->postJson('/api/v1/admin/login', ['email' => $staff->email, 'password' => 'wrong-password'])->assertUnauthorized();
    }

    test()->postJson('/api/v1/admin/login', ['email' => $staff->email, 'password' => 'wrong-password'])
        ->assertStatus(429)
        ->assertJsonPath('code', 'TOO_MANY_ATTEMPTS');

    test()->travel(14)->minutes();

    test()->postJson('/api/v1/admin/login', ['email' => $staff->email, 'password' => 'wrong-password'])->assertStatus(429);
});

it('does not let a retailer accept their own lower counter-offer', function () {
    $token = staffToken();

    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    $quote = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'TEST quote'])->assertCreated()->json('data');

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quote['id']}/offer", [
        'amount' => $quote['list_total'] - 240,
    ])->assertOk();

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/counter", [
        'amount' => 24,
    ])->assertOk();

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/accept")
        ->assertStatus(422)
        ->assertJsonPath('code', 'NO_OFFER');
});

it('shows piece counts on the quote list', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'TEST quote'])->assertCreated();

    asRetailer($retailer, 'GET', '/api/v1/quotes')->assertOk()->assertJsonPath('data.0.pieces', 24);
});

// ====================================================================
// Quote Amounts And Flexible Payment
// ====================================================================

it('lets staff accept the retailer amount and carries it to the order total', function () {
    $token = staffToken();

    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    $quote = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'TEST quote'])->assertCreated()->json('data');

    $amount = round($quote['list_total'] * 0.9, 2);

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/counter", ['amount' => $amount])->assertOk();

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quote['id']}/accept", ['amount' => $amount + 100])
        ->assertStatus(422)
        ->assertJsonPath('code', 'AMOUNT_CHANGED');

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quote['id']}/accept", ['amount' => $amount])
        ->assertOk()
        ->assertJsonPath('data.status', 'accepted');

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/accept")->assertOk();

    $orderId = checkout($retailer)->assertCreated()->json('data.id');

    expect((float) Order::find($orderId)->base_sub_total)->toEqualWithDelta($amount, 0.05);
});

it('does not let staff accept their own amount or anyone send more than the list value', function () {
    $token = staffToken();

    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    $quote = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'TEST quote'])->assertCreated()->json('data');

    $amount = $quote['list_total'] - 100;

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/counter", ['amount' => $quote['list_total'] + 1])
        ->assertStatus(422)
        ->assertJsonPath('code', 'INVALID_AMOUNT');

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quote['id']}/offer", ['amount' => $amount])->assertOk();

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quote['id']}/accept", ['amount' => $amount])
        ->assertStatus(422)
        ->assertJsonPath('code', 'AMOUNT_CHANGED');
});

it('accepts any first payment from the minimum advance up to the full amount', function () {
    [$retailer, $orderId] = placedOrder();

    $finance = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance');

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance', 'amount' => $finance['min_payment'] - 1])
        ->assertStatus(422)
        ->assertJsonPath('code', 'INVALID_AMOUNT');

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance', 'amount' => $finance['total'] + 1])
        ->assertStatus(422)
        ->assertJsonPath('code', 'INVALID_AMOUNT');

    $half = round($finance['total'] / 2, 2);

    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance', 'amount' => $half])->assertCreated();

    expect((float) $start->json('data.amount'))->toEqual($half);

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm", ['simulated_result' => 'success'])->assertOk();

    expect(OrderTerm::where('order_id', $orderId)->value('stage'))->toBe('Confirmed');

    $after = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance');

    expect((float) $after['outstanding'])->toEqualWithDelta($finance['total'] - $half, 0.01);
});

it('closes an order paid in full up front as soon as it is delivered', function () {
    [$retailer, $orderId] = placedOrder();

    $staff = staffToken();

    $total = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance.total');

    $start = asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments", ['kind' => 'advance', 'amount' => $total])->assertCreated();

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/{$start->json('data.payment_id')}/confirm", ['simulated_result' => 'success'])->assertOk();

    asStaff($staff, 'POST', "/api/v1/admin/orders/{$orderId}/stage", ['stage' => 'Packing'])->assertOk();

    $order = asStaff($staff, 'POST', "/api/v1/admin/orders/{$orderId}/dispatch")->assertOk()->json('data');

    foreach (range(1, 12) as $scan) {
        $order = asStaff($staff, 'POST', "/api/v1/admin/shipments/{$order['tracking']['id']}/refresh")->assertOk()->json('data');
    }

    expect($order['stage'])->toBe('Paid in full')
        ->and((float) $order['outstanding'])->toEqual(0.0);
});

it('stores a bank reference for the amount the retailer chose', function () {
    [$retailer, $orderId] = placedOrder();

    $finance = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}")->json('data.finance');

    asRetailer($retailer, 'POST', "/api/v1/orders/{$orderId}/payments/reference", [
        'kind' => 'advance',
        'method' => 'UPI',
        'reference' => 'UPI99887766',
        'amount' => $finance['total'],
    ])->assertCreated();

    expect((float) Payment::where('order_id', $orderId)->value('amount'))->toEqual((float) $finance['total']);
});
