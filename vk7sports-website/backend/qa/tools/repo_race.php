<?php
// Sandbox test: race N processes straight into OrderRepository::create(), bypassing every cart pre-check.
// build: RACE_MODE=build RACE_VARIANT=147 RACE_QTY=3 [RACE_LINES=147:12,149:12]  -> storage/race-order.json
// fire:  RACE_MODE=fire RACE_AT=<unix ts>                                         -> PLACED <id> | REJECTED <class>: <msg>
use Webkul\Checkout\Facades\Cart;
use Webkul\Customer\Models\Customer;
use Webkul\Product\Repositories\ProductRepository;
use Webkul\Sales\Repositories\OrderRepository;
use Webkul\Sales\Transformers\OrderResource;

$file = storage_path('race-order.json');

if (getenv('RACE_MODE') === 'build') {
    $super = [145 => [1, 6], 146 => [41, 6], 147 => [1, 7], 148 => [1, 8], 149 => [1, 9], 150 => [41, 7], 151 => [41, 8], 152 => [41, 9]];
    $lines = getenv('RACE_LINES') ?: getenv('RACE_VARIANT').':'.getenv('RACE_QTY');

    $customer = Customer::where('email', getenv('RACE_BUYER') ?: 'qa.zeta@example.test')->firstOrFail();
    auth()->guard('customer')->setUser($customer);
    Cart::initCart($customer);
    foreach (Cart::getCart()?->items ?? [] as $item) {
        Cart::removeItem($item->id);
    }

    foreach (explode(',', $lines) as $line) {
        [$variant, $qty] = array_map('intval', explode(':', $line));
        Cart::addProduct(app(ProductRepository::class)->find(144), [
            'product_id' => 144, 'quantity' => $qty, 'selected_configurable_option' => $variant,
            'super_attribute' => [23 => $super[$variant][0], 24 => $super[$variant][1], 34 => 25],
        ]);
    }

    Cart::saveAddresses(['billing' => [
        'first_name' => 'Buyer', 'last_name' => 'Race', 'email' => getenv('RACE_BUYER') ?: 'qa.zeta@example.test', 'address' => ['1 Test Street'],
        'country' => 'IN', 'state' => 'DL', 'city' => 'Testpur', 'postcode' => '110001', 'phone' => '9000000001',
        'use_for_shipping' => true,
    ]]);
    Cart::collectTotals();
    Cart::saveShippingMethod('free_free');
    Cart::savePaymentMethod(['method' => 'moneytransfer']);
    Cart::collectTotals();

    file_put_contents($file, json_encode((new OrderResource(Cart::getCart()))->jsonSerialize()));
    echo 'BUILT '.$lines.PHP_EOL;

    return;
}

$data = json_decode(file_get_contents($file), true);

while (microtime(true) < (float) getenv('RACE_AT')) {
    usleep(500);
}

try {
    $order = app(OrderRepository::class)->create($data);
    printf("%.4f PLACED order #%d\n", microtime(true), $order->id);
} catch (Throwable $e) {
    printf("%.4f REJECTED %s: %s\n", microtime(true), class_basename($e), $e->getMessage());
}
