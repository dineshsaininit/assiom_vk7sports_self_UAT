<?php

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Console\Commands\ApplyPolicy;
use Webkul\B2BSuite\Models\CustomerQuote;
use Webkul\B2BSuite\Repositories\CustomerQuoteRepository;
use Webkul\Customer\Models\Customer;
use Webkul\Product\Models\Product;
use Webkul\User\Models\Admin;

beforeEach(function () {
    Artisan::call('vk7:apply-policy');

    Artisan::call('vk7:demo-data');

    core()->getConfigData('vk7.moq.settings.enabled');
});

/**
 * Register and approve a fictional company, returning its email and token.
 */
function retailer(string $name = 'alpha'): array
{
    $email = 'test-'.$name.'-'.uniqid().'@example.test';

    test()->postJson('/api/v1/auth/register', [
        'business_name' => 'TEST-'.$name.' Traders',
        'first_name' => 'Test',
        'last_name' => $name,
        'email' => $email,
        'phone' => '98'.random_int(10000000, 99999999),
        'password' => 'Test-Password-1',
        'password_confirmation' => 'Test-Password-1',
    ])->assertCreated()->assertJsonPath('data.approval', 'pending');

    Customer::where('email', $email)->update(['status' => 1, 'is_verified' => 1]);

    $token = test()->postJson('/api/v1/auth/login', [
        'email' => $email,
        'password' => 'Test-Password-1',
    ])->assertOk()->json('token');

    return ['email' => $email, 'token' => $token];
}

/**
 * Build grid lines for a fictional style.
 */
function lines(string $sku, array $quantities): array
{
    $product = Product::where('sku', $sku)->firstOrFail();

    return collect($quantities)->values()->map(fn ($qty, $index) => [
        'product_id' => $product->id,
        'variant_id' => $product->variants[$index]->id,
        'qty' => $qty,
    ])->all();
}

/**
 * Send a request as a retailer.
 */
function asRetailer(array $retailer, string $method, string $uri, array $data = [])
{
    app('auth')->forgetGuards();

    return test()->withToken($retailer['token'])->json($method, $uri, $data);
}

/**
 * Record an admin offer on a quote at the given discount.
 */
function adminOffer(int $quoteId, float $percent = 10): void
{
    $quote = CustomerQuote::findOrFail($quoteId);

    $message = $quote->messages()->create([
        'message' => 'Fictional offer',
        'user_type' => 'admin',
        'user_id' => 1,
        'created_at' => now(),
    ]);

    app(CustomerQuoteRepository::class)->createOrUpdateMessageQuotation([
        'status' => CustomerQuote::STATUS_NEGOTIATION,
        'message_id' => $message->id,
        'message' => 'Fictional offer',
        'items' => $quote->items->mapWithKeys(fn ($item) => [$item->id => [
            'discount_type' => 'percent',
            'discount_value' => $percent,
            'negotiated_qty' => $item->qty,
        ]])->all(),
    ], $quoteId);
}

/**
 * Walk the checkout steps for the retailer's cart.
 */
function checkout(array $retailer)
{
    $address = [
        'first_name' => 'Test',
        'last_name' => 'Retailer',
        'email' => $retailer['email'],
        'address' => ['1 Fictional Street'],
        'city' => 'Mumbai',
        'country' => 'IN',
        'state' => 'MH',
        'postcode' => '400001',
        'phone' => '9876543210',
        'use_for_shipping' => true,
    ];

    asRetailer($retailer, 'POST', '/api/v1/checkout/address', ['billing' => $address])->assertOk();

    asRetailer($retailer, 'POST', '/api/v1/checkout/shipping', ['shipping_method' => 'flatrate_flatrate'])->assertOk();

    asRetailer($retailer, 'POST', '/api/v1/checkout/payment', ['method' => 'moneytransfer'])->assertOk();

    return asRetailer($retailer, 'POST', '/api/v1/checkout/order');
}

// ====================================================================
// Accounts And Price Visibility
// ====================================================================

it('makes every policy setting take effect', function () {
    foreach (ApplyPolicy::SETTINGS as $code => [$value]) {
        expect((string) core()->getConfigData($code))->toBe($value, $code);
    }
});

it('blocks sign-in until the company is approved', function () {
    $email = 'test-pending-'.uniqid().'@example.test';

    $this->postJson('/api/v1/auth/register', [
        'business_name' => 'TEST-Pending Traders',
        'first_name' => 'Test',
        'last_name' => 'Pending',
        'email' => $email,
        'phone' => '98'.random_int(10000000, 99999999),
        'password' => 'Test-Password-1',
        'password_confirmation' => 'Test-Password-1',
    ])->assertCreated();

    $this->postJson('/api/v1/auth/login', ['email' => $email, 'password' => 'Test-Password-1'])
        ->assertForbidden()
        ->assertJsonPath('code', 'ACCOUNT_PENDING');
});

it('hides prices and stock counts from guests', function () {
    $product = Product::where('sku', 'TEST-STYLE-01')->first();

    $this->getJson('/api/v1/products')->assertOk()->assertJsonPath('data.0.prices', null);

    $this->getJson('/api/v1/products/'.$product->id)
        ->assertOk()
        ->assertJsonPath('data.prices', null)
        ->assertJsonPath('data.grid.variants.0.prices', null)
        ->assertJsonPath('data.grid.variants.0.stock', null);

    $this->getJson('/api/products')->assertUnauthorized();
});

it('shows prices and the grid to an approved retailer', function () {
    $product = Product::where('sku', 'TEST-STYLE-01')->first();

    $response = asRetailer(retailer(), 'GET', '/api/v1/products/'.$product->id)->assertOk();

    expect($response->json('data.prices'))->not->toBeNull();
    expect($response->json('data.grid.variants'))->toHaveCount(8);
    expect($response->json('data.grid.variants.0.stock'))->toBe(50);
    expect($response->json('data.grid.attributes.0.code'))->toBeIn(['color', 'size']);
});

it('searches the catalogue', function () {
    $this->getJson('/api/v1/products?q=Track')
        ->assertOk()
        ->assertJsonPath('data.0.sku', 'TEST-STYLE-02');
});

it('does not count browsing against the sign-in limit', function () {
    foreach (range(1, 25) as $request) {
        $this->getJson('/api/v1/meta')->assertOk();
    }

    $this->postJson('/api/v1/auth/login', ['email' => 'nobody@example.test', 'password' => 'wrong'])
        ->assertUnauthorized()
        ->assertJsonPath('code', 'INVALID_CREDENTIALS');
});

it('rejects a request with no token', function () {
    $this->getJson('/api/v1/cart')->assertUnauthorized()->assertJsonPath('code', 'UNAUTHENTICATED');
});

it('stops accepting a token after logout', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/auth/logout')->assertOk();

    asRetailer($retailer, 'GET', '/api/v1/auth/me')->assertUnauthorized();
});

// ====================================================================
// Minimum Order Quantity
// ====================================================================

it('combines sizes and colours of a style and reports what is missing', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/moq/check', ['lines' => lines('TEST-STYLE-01', [6, 6, 6, 6])])
        ->assertOk()
        ->assertJsonPath('data.moq.met', true);

    asRetailer($retailer, 'POST', '/api/v1/moq/check', ['lines' => array_merge(
        lines('TEST-STYLE-01', [10, 10]),
        lines('TEST-STYLE-02', [15, 15]),
    )])
        ->assertOk()
        ->assertJsonPath('data.moq.met', false)
        ->assertJsonPath('data.moq.shortfalls.0.needed', 4);
});

it('reports a stock shortage per variant', function () {
    asRetailer(retailer(), 'POST', '/api/v1/moq/check', ['lines' => lines('TEST-STYLE-01', [51])])
        ->assertOk()
        ->assertJsonPath('data.stock_ok', false)
        ->assertJsonPath('data.shortages.0.available', 50);
});

it('refuses a quote and a checkout below the minimum', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [5])])->assertCreated();

    asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Too small'])
        ->assertUnprocessable()
        ->assertJsonPath('code', 'MOQ_NOT_MET');

    asRetailer($retailer, 'POST', '/api/v1/checkout/order')
        ->assertUnprocessable()
        ->assertJsonPath('code', 'MOQ_NOT_MET');
});

// ====================================================================
// Quotes, Orders And Isolation
// ====================================================================

it('runs the whole journey from cart to tracked order at the negotiated price', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [6, 6, 6, 6])])
        ->assertCreated()
        ->assertJsonPath('data.items_qty', 24)
        ->assertJsonCount(4, 'data.items');

    $quote = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Fictional request'])
        ->assertCreated()
        ->assertJsonPath('data.status', 'open')
        ->assertJsonCount(4, 'data.items')
        ->json('data');

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/accept")
        ->assertUnprocessable()
        ->assertJsonPath('code', 'NO_OFFER');

    adminOffer($quote['id'], 10);

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/accept")
        ->assertOk()
        ->assertJsonPath('data.status', 'accepted');

    $cart = asRetailer($retailer, 'GET', '/api/v1/cart')->assertOk()->json('data');

    expect($cart['items'])->toHaveCount(4);
    expect(collect($cart['items'])->every('locked_by_quote'))->toBeTrue();
    expect((float) $cart['items'][0]['price'])->toBe(450.0);

    $order = checkout($retailer)->assertCreated()->json('data');

    expect((float) DB::table('orders')->where('id', $order['id'])->value('base_sub_total'))->toBe(10800.0);

    expect(DB::table('product_ordered_inventories')->sum('qty'))->toBeGreaterThanOrEqual(24);

    expect(CustomerQuote::find($quote['id'])->status)->toBe('ordered');

    asRetailer($retailer, 'GET', '/api/v1/orders')->assertOk()->assertJsonPath('data.0.id', $order['id']);

    asRetailer($retailer, 'GET', "/api/v1/orders/{$order['id']}")
        ->assertOk()
        ->assertJsonPath('data.order_number', $order['order_number'])
        ->assertJsonCount(4, 'data.items');
});

it('locks the quantity of an accepted quote line', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-03', [12, 12])])->assertCreated();

    $quoteId = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Lock'])->assertCreated()->json('data.id');

    adminOffer($quoteId);

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quoteId}/accept")->assertOk();

    $itemId = asRetailer($retailer, 'GET', '/api/v1/cart')->json('data.items.0.id');

    asRetailer($retailer, 'PUT', "/api/v1/cart/items/{$itemId}", ['qty' => 500])
        ->assertUnprocessable()
        ->assertJsonPath('code', 'QUOTE_LOCKED');

    DB::table('cart_items')->where('id', $itemId)->update(['quantity' => 30]);

    asRetailer($retailer, 'POST', '/api/v1/checkout/order')
        ->assertUnprocessable()
        ->assertJsonPath('code', 'QUOTE_LOCKED');
});

it('keeps one retailer out of another retailer\'s quotes and orders', function () {
    $alpha = retailer('alpha');
    $bravo = retailer('bravo');

    asRetailer($alpha, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-04', [24])])->assertCreated();

    $quoteId = asRetailer($alpha, 'POST', '/api/v1/quotes', ['name' => 'Private'])->assertCreated()->json('data.id');

    asRetailer($bravo, 'GET', "/api/v1/quotes/{$quoteId}")->assertNotFound();
    asRetailer($bravo, 'POST', "/api/v1/quotes/{$quoteId}/accept")->assertNotFound();
    asRetailer($bravo, 'POST', "/api/v1/quotes/{$quoteId}/reject", ['message' => 'x'])->assertNotFound();
    asRetailer($bravo, 'GET', '/api/v1/quotes')->assertOk()->assertJsonCount(0, 'data');

    asRetailer($alpha, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-04', [24])])->assertCreated();

    $orderId = checkout($alpha)->assertCreated()->json('data.id');

    asRetailer($bravo, 'GET', "/api/v1/orders/{$orderId}")->assertNotFound();
    asRetailer($bravo, 'GET', '/api/v1/orders')->assertOk()->assertJsonCount(0, 'data');
});

// ====================================================================
// Document Numbers
// ====================================================================

it('never repeats a quote number after the newest quote is deleted', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [24])])->assertCreated();

    $first = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'One'])->json('data');

    CustomerQuote::destroy($first['id']);

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [24])])->assertCreated();

    $second = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Two'])->json('data');

    expect($second['quotation_number'])->not->toBe($first['quotation_number']);
});

it('does not reuse order numbers when the counter is behind a restored database', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [24])])->assertCreated();

    $first = checkout($retailer)->assertCreated()->json('data');

    DB::table('vk7_sequences')->where('name', 'order')->update(['value' => 0]);

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [24])])->assertCreated();

    $second = checkout($retailer)->assertCreated()->json('data');

    expect($second['order_number'])->not->toBe($first['order_number']);
});

// ====================================================================
// Enquiries
// ====================================================================

it('stores a public enquiry and validates it', function () {
    $this->postJson('/api/v1/enquiries', ['name' => 'x'])->assertUnprocessable();

    $id = $this->postJson('/api/v1/enquiries', [
        'type' => 'custom',
        'name' => 'Test Club',
        'email' => 'test-club@example.test',
        'quantity' => 100,
        'message' => 'Fictional custom order enquiry.',
    ])->assertCreated()->json('data.id');

    expect(DB::table('vk7_enquiries')->where('id', $id)->value('status'))->toBe('new');
});

it('lets only signed-in staff open the enquiry queue', function () {
    $this->get('/admin/vk7/enquiries')->assertRedirect();

    $this->actingAs(Admin::first(), 'admin')
        ->get('/admin/vk7/enquiries')
        ->assertOk()
        ->assertSee('Enquiries');
});

// ====================================================================
// Account, Addresses And Tracking
// ====================================================================

it('saves the shop address and application details at registration', function () {
    $email = 'test-apply-'.uniqid().'@example.test';

    $this->postJson('/api/v1/auth/register', [
        'business_name' => 'TEST-Apply Traders',
        'first_name' => 'Test',
        'last_name' => 'Apply',
        'email' => $email,
        'phone' => '98'.random_int(10000000, 99999999),
        'password' => 'Test-Password-1',
        'password_confirmation' => 'Test-Password-1',
        'shop_type' => 'Sports shop',
        'proof' => 'Shop licence',
        'label' => 'Main shop',
        'line1' => '1 Fictional Street',
        'city' => 'Mumbai',
        'state' => 'Maharashtra',
        'pin' => '400001',
    ])->assertCreated();

    $customer = Customer::where('email', $email)->first();

    expect(DB::table('addresses')->where('customer_id', $customer->id)->value('state'))->toBe('MH');

    expect(DB::table('vk7_enquiries')->where('email', $email)->value('message'))->toContain('Shop licence');
});

it('manages addresses and keeps them private to the retailer', function () {
    $alpha = retailer('alpha');
    $bravo = retailer('bravo');

    $body = ['label' => 'Main shop', 'line1' => '1 Fictional Street', 'city' => 'Mumbai', 'state' => 'Maharashtra', 'pin' => '400001', 'phone' => '9876543210'];

    $first = asRetailer($alpha, 'POST', '/api/v1/account/addresses', $body)
        ->assertCreated()
        ->assertJsonPath('data.addresses.0.state', 'MH')
        ->assertJsonPath('data.addresses.0.is_default', true)
        ->json('data.addresses.0.id');

    asRetailer($alpha, 'POST', '/api/v1/account/addresses', ['state' => 'Atlantis'] + $body)
        ->assertUnprocessable()
        ->assertJsonValidationErrors('state');

    asRetailer($alpha, 'DELETE', "/api/v1/account/addresses/{$first}")
        ->assertUnprocessable()
        ->assertJsonPath('code', 'LAST_ADDRESS');

    asRetailer($bravo, 'PUT', "/api/v1/account/addresses/{$first}", $body)->assertNotFound();
    asRetailer($bravo, 'DELETE', "/api/v1/account/addresses/{$first}")->assertNotFound();
});

it('changes the password only with the current one', function () {
    $retailer = retailer();

    asRetailer($retailer, 'PUT', '/api/v1/account/password', [
        'current_password' => 'wrong',
        'password' => 'New-Password-1',
        'password_confirmation' => 'New-Password-1',
    ])->assertUnprocessable()->assertJsonValidationErrors('current_password');

    asRetailer($retailer, 'PUT', '/api/v1/account/password', [
        'current_password' => 'Test-Password-1',
        'password' => 'New-Password-1',
        'password_confirmation' => 'New-Password-1',
    ])->assertOk();

    app('auth')->forgetGuards();

    $this->flushHeaders();

    $this->postJson('/api/v1/auth/login', ['email' => $retailer['email'], 'password' => 'New-Password-1'])->assertOk();
});

it('answers a password reset the same for unknown emails', function () {
    $this->postJson('/api/v1/auth/forgot', ['email' => 'nobody@example.test'])
        ->assertOk()
        ->assertJsonPath('data.sent', true);
});

it('replaces a style atomically and refuses a locked one', function () {
    $retailer = retailer();

    $product = Product::where('sku', 'TEST-STYLE-01')->first();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [10, 10])])->assertCreated();

    asRetailer($retailer, 'PUT', "/api/v1/cart/styles/{$product->id}", ['lines' => [['variant_id' => $product->variants[2]->id, 'qty' => 24]]])
        ->assertOk()
        ->assertJsonPath('data.items_qty', 24)
        ->assertJsonCount(1, 'data.items');

    asRetailer($retailer, 'PUT', "/api/v1/cart/styles/{$product->id}", ['lines' => [['variant_id' => $product->variants[2]->id, 'qty' => 9999]]])
        ->assertUnprocessable()
        ->assertJsonPath('code', 'CART_REJECTED');

    asRetailer($retailer, 'GET', '/api/v1/cart')->assertJsonPath('data.items_qty', 24);
});

it('tracks an order only with its number and mobile, and lets the owner cancel it', function () {
    $alpha = retailer('alpha');
    $bravo = retailer('bravo');

    asRetailer($alpha, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-04', [24])])->assertCreated();

    $order = checkout($alpha)->assertCreated()->json('data');

    expect($order['order_number'])->toStartWith('VK7-');

    app('auth')->forgetGuards();

    $this->flushHeaders();

    $this->postJson('/api/v1/orders/track', ['number' => $order['order_number'], 'phone' => '9000000000'])->assertNotFound();

    $this->postJson('/api/v1/orders/track', ['number' => $order['order_number'], 'phone' => '9876543210'])
        ->assertOk()
        ->assertJsonMissingPath('data.grand_total');

    asRetailer($bravo, 'POST', "/api/v1/orders/{$order['id']}/cancel", ['reason' => 'x'])->assertNotFound();

    asRetailer($alpha, 'POST', "/api/v1/orders/{$order['id']}/cancel", ['reason' => 'Fictional reason'])
        ->assertOk()
        ->assertJsonPath('data.status', 'canceled');
});
// ====================================================================
// Staff Screens
// ====================================================================

it('lets a pending retailer sign in after staff approve it in the admin panel', function () {
    $email = 'test-staff-'.uniqid().'@example.test';

    $this->postJson('/api/v1/auth/register', [
        'business_name' => 'TEST-Staff Traders',
        'first_name' => 'Test',
        'last_name' => 'Staff',
        'email' => $email,
        'phone' => '98'.random_int(10000000, 99999999),
        'password' => 'Test-Password-1',
        'password_confirmation' => 'Test-Password-1',
    ])->assertCreated();

    $company = Customer::where('email', $email)->first();

    Customer::where('id', $company->id)->update(['is_verified' => 1]);

    $this->actingAs(Admin::first(), 'admin')
        ->postJson(route('admin.b2b.companies.update_status', $company->id), ['status' => 1])
        ->assertOk();

    app('auth')->forgetGuards();

    $this->postJson('/api/v1/auth/login', ['email' => $email, 'password' => 'Test-Password-1'])->assertOk();
});

it('lets a retailer accept an offer sent from the admin panel', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-01', [12, 12])])->assertCreated();

    $quote = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Staff offer'])->assertCreated()->json('data');

    app('auth')->forgetGuards();

    $this->flushHeaders();

    $this->actingAs(Admin::first(), 'admin')
        ->post(route('admin.b2b.quotes.submit_quote', $quote['id']), [
            'message' => 'Fictional offer',
            'status' => 'negotiation',
            'items' => collect($quote['items'])->mapWithKeys(fn ($item) => [$item['id'] => [
                'discount_type' => 'percent',
                'discount_value' => 10,
                'negotiated_qty' => $item['qty'],
            ]])->all(),
        ])
        ->assertRedirect();

    asRetailer($retailer, 'GET', "/api/v1/quotes/{$quote['id']}")->assertJsonPath('data.can_accept', true);

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quote['id']}/accept")->assertOk();

    expect((float) asRetailer($retailer, 'GET', '/api/v1/cart')->json('data.items.0.price'))->toBe(450.0);
});
