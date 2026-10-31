<?php

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Webkul\User\Models\Admin;
use Webkul\User\Models\Role;

beforeEach(function () {
    Artisan::call('vk7:apply-policy');

    Artisan::call('vk7:demo-data');

    config(['vk7.payments.gateway' => 'demo', 'vk7.courier.provider' => 'demo']);
});

/**
 * Create a style through the admin, returning its id.
 */
function adminStyle(string $token, string $code = 'REAL-01'): int
{
    $category = asStaff($token, 'POST', '/api/v1/admin/categories', ['name' => 'Real Category'])->assertCreated()->json('data.id');

    return asStaff($token, 'POST', '/api/v1/admin/products', [
        'name' => 'Real Tee',
        'style' => $code,
        'category_id' => $category,
        'price' => 285,
        'status' => 'active',
        'stock' => 50,
        'colours' => [['name' => 'Sky Blue', 'hex' => '#BBD9F1'], ['name' => 'Mint Green', 'hex' => '#BFE5BE']],
        'sizes' => ['S', 'M'],
    ])->assertCreated()->json('data.id');
}

// ====================================================================
// Products And Stock
// ====================================================================

it('creates a style with a variant for each colour and size', function () {
    $token = staffToken();

    $id = adminStyle($token);

    $style = asStaff($token, 'GET', "/api/v1/admin/products/{$id}")->assertOk()->json('data');

    expect($style['price'])->toEqual(285)
        ->and($style['available'])->toBe(200)
        ->and($style['sizes'])->toHaveCount(2)
        ->and(collect($style['colours'])->pluck('name')->all())->toBe(['Sky Blue', 'Mint Green']);

    asStaff($token, 'POST', '/api/v1/admin/products', [
        'name' => 'Copy',
        'style' => 'REAL-01',
        'category_id' => $style['category_id'],
        'price' => 1,
        'status' => 'active',
        'colours' => [['name' => 'Sky Blue']],
        'sizes' => ['S'],
    ])->assertStatus(422)->assertJsonPath('code', 'DUPLICATE_STYLE');
});

it('updates a style, keeps its stock and adds new sizes', function () {
    $token = staffToken();

    $id = adminStyle($token);

    $style = asStaff($token, 'GET', "/api/v1/admin/products/{$id}")->json('data');

    $updated = asStaff($token, 'PUT', "/api/v1/admin/products/{$id}", [
        'name' => 'Real Tee Plus',
        'category_id' => $style['category_id'],
        'price' => 290,
        'status' => 'active',
        'colours' => [['name' => 'Sky Blue'], ['name' => 'Mint Green']],
        'sizes' => ['S', 'M', 'L'],
    ])->assertOk()->json('data');

    expect($updated['name'])->toBe('Real Tee Plus')
        ->and($updated['price'])->toEqual(290)
        ->and($updated['sizes'])->toHaveCount(3)
        ->and($updated['available'])->toBe(200);
});

it('stores photos per colour, rejects other files and removes them', function () {
    Storage::fake('public');

    $token = staffToken();

    $id = adminStyle($token);

    app('auth')->forgetGuards();

    test()->withToken($token)->post("/api/v1/admin/products/{$id}/photos", [
        'colour' => 'Sky Blue',
        'photos' => [UploadedFile::fake()->create('script.php', 10, 'text/plain')],
    ], ['Accept' => 'application/json'])->assertStatus(422);

    $style = test()->withToken($token)->post("/api/v1/admin/products/{$id}/photos", [
        'colour' => 'Sky Blue',
        'photos' => [UploadedFile::fake()->image('tee.jpg')],
    ], ['Accept' => 'application/json'])->assertCreated()->json('data');

    $photo = $style['colours'][0]['images'][0];

    expect($style['colours'][1]['images'])->toBeEmpty();

    Storage::disk('public')->assertExists(DB::table('product_images')->where('id', $photo['id'])->value('path'));

    $after = asStaff($token, 'DELETE', "/api/v1/admin/products/{$id}/photos/{$photo['id']}")->assertOk()->json('data');

    expect($after['colours'][0]['images'])->toBeEmpty();
});

it('corrects stock with a reason and never below what orders hold', function () {
    placedOrder();

    $token = staffToken();

    $rows = collect(asStaff($token, 'GET', '/api/v1/admin/inventory')->assertOk()->json('data'))->flatMap(fn ($style) => $style['rows']);

    $row = $rows->firstWhere('held', '>', 0);

    expect($row)->not->toBeNull();

    asStaff($token, 'POST', '/api/v1/admin/inventory/adjust', ['variant_id' => $row['variant_id'], 'change' => 5])->assertStatus(422);

    asStaff($token, 'POST', '/api/v1/admin/inventory/adjust', ['variant_id' => $row['variant_id'], 'change' => 5, 'reason' => 'New stock received'])->assertOk();

    asStaff($token, 'POST', '/api/v1/admin/inventory/adjust', ['variant_id' => $row['variant_id'], 'change' => -1000, 'reason' => 'Other'])
        ->assertStatus(422)
        ->assertJsonPath('code', 'STOCK_HELD');

    $log = asStaff($token, 'GET', '/api/v1/admin/stock-log')->assertOk()->json('data');

    expect($log)->toHaveCount(1)->and($log[0]['on_hand'])->toBe($row['on_hand'] + 5);
});

// ====================================================================
// Quotes And Enquiries
// ====================================================================

it('shows a target price to staff and carries their offer to the order', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [12, 12])])->assertSuccessful();

    $quoteId = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Order list', 'description' => 'Target price 600'])->assertCreated()->json('data.id');

    $token = staffToken();

    $quote = asStaff($token, 'GET', "/api/v1/admin/quotes/{$quoteId}")->assertOk()->json('data');

    expect($quote['description'])->toBe('Target price 600');

    $prices = collect($quote['items'])->mapWithKeys(fn ($item) => [$item['id'] => 630])->all();

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quoteId}/offer", ['prices' => $prices, 'message' => 'Best rate'])->assertOk();

    $seen = asRetailer($retailer, 'GET', "/api/v1/quotes/{$quoteId}")->assertOk()->json('data');

    expect($seen['can_accept'])->toBeTrue()
        ->and((float) $seen['items'][0]['negotiated_price'])->toEqual(630.0);

    asRetailer($retailer, 'POST', "/api/v1/quotes/{$quoteId}/accept")->assertOk();

    $order = checkout($retailer)->assertCreated()->json('data.id');

    $lines = asRetailer($retailer, 'GET', "/api/v1/orders/{$order}")->json('data.items');

    expect(collect($lines)->pluck('price')->unique()->values()->all())->toEqual([630.0]);
});

it('rejects a quote with a reason', function () {
    $retailer = retailer();

    asRetailer($retailer, 'POST', '/api/v1/cart/items', ['lines' => lines('TEST-STYLE-02', [24])])->assertSuccessful();

    $quoteId = asRetailer($retailer, 'POST', '/api/v1/quotes', ['name' => 'Order list'])->json('data.id');

    $token = staffToken();

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quoteId}/reject", [])->assertStatus(422);

    asStaff($token, 'POST', "/api/v1/admin/quotes/{$quoteId}/reject", ['reason' => 'Below cost'])
        ->assertOk()
        ->assertJsonPath('data.status', 'rejected');
});

it('follows up enquiries and hides trade applications from the queue', function () {
    retailer();

    app('auth')->forgetGuards();

    test()->flushHeaders()->postJson('/api/v1/enquiries', ['name' => 'Buyer', 'email' => 'b@example.test', 'message' => 'Need shirts', 'type' => 'bulk'])->assertCreated();

    $token = staffToken();

    $list = asStaff($token, 'GET', '/api/v1/admin/enquiries')->assertOk()->json('data');

    expect($list)->toHaveCount(1);

    $saved = asStaff($token, 'PUT', "/api/v1/admin/enquiries/{$list[0]['id']}", ['status' => 'contacted', 'note' => 'Called', 'follow_up_on' => '2030-01-01'])->assertOk()->json('data');

    expect($saved['status'])->toBe('contacted')
        ->and($saved['notes'][0]['text'])->toBe('Called')
        ->and($saved['follow_up_on'])->toBe('2030-01-01');
});

// ====================================================================
// Staff, Settings And Invoices
// ====================================================================

it('manages staff and stops a deactivated login', function () {
    $token = staffToken();

    $role = Role::create(['name' => 'TEST Sales', 'permission_type' => 'custom', 'permissions' => ['vk7_desk.orders']]);

    $staff = asStaff($token, 'POST', '/api/v1/admin/staff', [
        'name' => 'New Person',
        'email' => 'new@example.test',
        'password' => 'Test-Password-1',
        'role_id' => $role->id,
    ])->assertOk()->json('data.staff');

    $person = collect($staff)->firstWhere('email', 'new@example.test');

    $login = test()->flushHeaders()->postJson('/api/v1/admin/login', ['email' => 'new@example.test', 'password' => 'Test-Password-1'])->assertOk();

    expect($login->json('data.areas'))->toBe(['orders']);

    asStaff($token, 'POST', "/api/v1/admin/staff/{$person['id']}/toggle")->assertOk();

    asStaff($login->json('token'), 'GET', '/api/v1/admin/me')->assertUnauthorized();
});

it('saves company details and shows bank details only to retailers', function () {
    $retailer = retailer();

    $token = staffToken();

    $settings = asStaff($token, 'GET', '/api/v1/admin/settings')->assertOk()->json('data');

    asStaff($token, 'PUT', '/api/v1/admin/settings', array_merge($settings, [
        'moqEnabled' => true,
        'taxInvoiceApproved' => false,
        'lowStock' => 20,
        'legalName' => 'Real Company Pvt Ltd',
        'gstin' => '27ABCDE1234F1Z5',
        'upiId' => 'real@upi',
        'advancePct' => 15,
    ]))->assertOk()->assertJsonPath('data.legalName', 'Real Company Pvt Ltd');

    app('auth')->forgetGuards();

    $public = test()->flushHeaders()->getJson('/api/v1/meta')->assertOk()->json('data');

    expect($public['company']['legalName'])->toBe('Real Company Pvt Ltd')
        ->and($public['bank'])->toBeNull()
        ->and($public['payments']['advance_percent'])->toEqual(15);

    expect(asRetailer($retailer, 'GET', '/api/v1/meta')->json('data.bank.upiId'))->toBe('real@upi');
});

it('issues one numbered invoice after payment and keeps it private', function () {
    [$retailer, $orderId] = placedOrder('alpha');

    $before = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}/invoice")->assertOk()->json('data');

    expect($before['proforma'])->toBeTrue();

    payAdvance($retailer, $orderId);

    $first = asRetailer($retailer, 'GET', "/api/v1/orders/{$orderId}/invoice")->assertOk()->json('data');

    $again = asStaff(staffToken(), 'GET', "/api/v1/admin/orders/{$orderId}/invoice")->assertOk()->json('data');

    expect($first['proforma'])->toBeFalse()
        ->and($first['number'])->toStartWith('INV-')
        ->and($again['number'])->toBe($first['number'])
        ->and($first['tax_invoice'])->toBeFalse();

    asRetailer(retailer('bravo'), 'GET', "/api/v1/orders/{$orderId}/invoice")->assertNotFound();
});

it('sends the old admin panel to the single admin', function () {
    config(['vk7.admin.close_bagisto_panel' => true, 'vk7.admin.url' => 'https://example.test/admin-login.html']);

    test()->flushHeaders()->get('/admin/login')->assertRedirect('https://example.test/admin-login.html');

    test()->get('/admin/catalog/products')->assertRedirect('https://example.test/admin-login.html');
});

it('prepares a fresh store with roles and a one-time owner password', function () {
    Artisan::call('vk7:setup', ['--owner-email' => 'owner@example.test', '--owner-name' => 'Owner']);

    expect(Role::where('name', 'Finance')->exists())->toBeTrue()
        ->and(Admin::where('email', 'owner@example.test')->exists())->toBeTrue()
        ->and(Hash::check('admin123', Admin::where('email', 'owner@example.test')->value('password')))->toBeFalse();
});
