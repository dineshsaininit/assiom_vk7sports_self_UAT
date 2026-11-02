<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Webkul\Checkout\Facades\Cart;
use Webkul\Payment\Facades\Payment;
use Webkul\Sales\Repositories\OrderRepository;
use Webkul\Sales\Transformers\OrderResource;
use Webkul\Shipping\Facades\Shipping;
use Webkul\Shop\Http\Controllers\API\OnepageController;
use Webkul\Shop\Http\Requests\CartAddressRequest;

class CheckoutController extends Controller
{
    /**
     * Offline methods only; no live payment collection is authorised.
     */
    public const OFFLINE_PAYMENT_METHODS = ['cashondelivery', 'moneytransfer'];

    /**
     * Seconds a cart stays locked while its order is placed.
     */
    public const ORDER_LOCK_SECONDS = 60;

    /**
     * Create a new controller instance.
     */
    public function __construct(protected OrderRepository $orderRepository) {}

    /**
     * Save addresses and return the shipping methods available for them.
     */
    public function address(CartAddressRequest $request): JsonResponse
    {
        if ($blocked = $this->blocked()) {
            return $blocked;
        }

        Cart::saveAddresses($request->all());

        Cart::collectTotals();

        $rates = Shipping::collectRates();

        return response()->json(['data' => [
            'shipping_methods' => $rates['shippingMethods'] ?? [],
        ]]);
    }

    /**
     * Save the shipping method and return the offline payment methods.
     */
    public function shipping(Request $request): JsonResponse
    {
        $data = $request->validate(['shipping_method' => ['required', 'string']]);

        if ($blocked = $this->blocked()) {
            return $blocked;
        }

        if (! Cart::saveShippingMethod($data['shipping_method'])) {
            return $this->fail(trans('That shipping method is not available.'), 'INVALID_SHIPPING');
        }

        Cart::collectTotals();

        return response()->json(['data' => [
            'payment_methods' => collect(Payment::getSupportedPaymentMethods()['payment_methods'] ?? [])
                ->whereIn('method', self::OFFLINE_PAYMENT_METHODS)
                ->values(),
        ]]);
    }

    /**
     * Save an offline payment method.
     */
    public function payment(Request $request): JsonResponse
    {
        $data = $request->validate(['method' => ['required', 'string']]);

        if ($blocked = $this->blocked()) {
            return $blocked;
        }

        $available = collect(Payment::getSupportedPaymentMethods()['payment_methods'] ?? [])
            ->whereIn('method', self::OFFLINE_PAYMENT_METHODS)
            ->contains('method', $data['method']);

        if (! $available) {
            return $this->fail(trans('That payment method is not available.'), 'INVALID_PAYMENT');
        }

        Cart::savePaymentMethod(['method' => $data['method']]);

        Cart::collectTotals();

        return response()->json(['data' => ['method' => $data['method']]]);
    }

    /**
     * Place the order once, re-checking the rules against the saved cart.
     */
    public function order(Request $request, OnepageController $onepageController): JsonResponse
    {
        $data = $request->validate([
            'po_ref' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ]);

        if ($blocked = $this->blocked()) {
            return $blocked;
        }

        $lock = Cache::lock('vk7-order-cart-'.Cart::getCart()->id, self::ORDER_LOCK_SECONDS);

        if (! $lock->get()) {
            return $this->fail(trans('This order is already being placed.'), 'ORDER_IN_PROGRESS', 409);
        }

        try {
            Cart::collectTotals();

            $onepageController->validateOrder();

            if (! in_array(Cart::getCart()->payment->method, self::OFFLINE_PAYMENT_METHODS)) {
                return $this->fail(trans('That payment method is not available.'), 'INVALID_PAYMENT');
            }

            $order = $this->orderRepository->create((new OrderResource(Cart::getCart()))->jsonSerialize());

            Cart::deActivateCart();

            foreach (array_filter(['Retailer reference: '.($data['po_ref'] ?? ''), 'Delivery notes: '.($data['notes'] ?? '')], fn ($comment) => ! str_ends_with($comment, ': ')) as $comment) {
                $order->comments()->create(['comment' => $comment, 'customer_notified' => 0]);
            }
        } catch (\Exception $e) {
            return $this->fail($this->publicMessage($e, trans('Your order could not be placed. Please try again.')), 'ORDER_REJECTED');
        } finally {
            $lock->release();
        }

        return response()->json(['data' => [
            'id' => $order->id,
            'order_number' => $order->increment_id,
            'status' => $order->status,
        ]], 201);
    }

    /**
     * Stop checkout when the cart is missing or breaks a rule.
     */
    protected function blocked(): ?JsonResponse
    {
        if (! Cart::getCart()) {
            return $this->fail(trans('The cart is empty.'), 'CART_EMPTY');
        }

        if (Cart::hasError()) {
            $error = Cart::getErrors();

            return $this->fail($error['message'] ?? trans('The cart cannot be checked out.'), $error['error_code'] ?? 'CART_INVALID');
        }

        return null;
    }
}
