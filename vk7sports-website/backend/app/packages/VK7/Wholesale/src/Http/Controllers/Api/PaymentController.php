<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Services\OrderFinance;
use Webkul\Sales\Repositories\OrderRepository;

class PaymentController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected OrderRepository $orderRepository,
        protected OrderFinance $finance,
    ) {}

    /**
     * Open an online payment for what is due on this order.
     */
    public function start(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['kind' => ['required', Rule::in(['advance', 'balance'])]]);

        return $this->guarded(fn () => response()->json([
            'data' => $this->finance->startOnline($this->ownOrder($id), $data['kind']),
        ], 201));
    }

    /**
     * Accept the payment screen's result once the gateway proves it.
     */
    public function confirm(Request $request, int $id, int $paymentId): JsonResponse
    {
        return $this->guarded(function () use ($request, $id, $paymentId) {
            $order = $this->ownOrder($id);

            $this->finance->confirmOnline($order, $paymentId, $request->only([
                'razorpay_payment_id',
                'razorpay_order_id',
                'razorpay_signature',
                'simulated_result',
            ]));

            return response()->json(['data' => $this->finance->summary($order->fresh())]);
        });
    }

    /**
     * Record a UPI or bank reference for finance to verify.
     */
    public function reference(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'kind' => ['required', Rule::in(['advance', 'balance'])],
            'method' => ['required', Rule::in(['UPI', 'Bank transfer'])],
            'reference' => ['required', 'string', 'regex:/^[A-Za-z0-9-]{6,30}$/'],
        ]);

        return $this->guarded(function () use ($id, $data) {
            $order = $this->ownOrder($id);

            $this->finance->submitReference($order, $data['kind'], $data['method'], $data['reference']);

            return response()->json(['data' => $this->finance->summary($order)], 201);
        });
    }

    /**
     * Apply a signed notification from the payment gateway.
     */
    public function webhook(Request $request): JsonResponse
    {
        return $this->guarded(function () use ($request) {
            $this->finance->handleWebhook($request->getContent(), $request->header('X-Razorpay-Signature'));

            return response()->json(['status' => 'ok']);
        });
    }

    /**
     * Find an order this retailer may pay for.
     */
    protected function ownOrder(int $id)
    {
        $order = $this->orderRepository->find($id);

        if (
            ! $order
            || ! in_array($order->customer_id, $this->buyerIds())
        ) {
            throw new BusinessRuleException(trans('Order not found.'), 'NOT_FOUND', 404);
        }

        return $order;
    }

    /**
     * Customers whose orders this retailer may see.
     */
    protected function buyerIds(): array
    {
        $customer = $this->customer();

        return $customer->type === 'company'
            ? array_values(array_unique(array_merge([$customer->id], $customer->members()->pluck('customers.id')->all())))
            : [$customer->id];
    }

    /**
     * Turn a broken business rule into the shared error response.
     */
    protected function guarded(callable $action): JsonResponse
    {
        try {
            return $action();
        } catch (BusinessRuleException $e) {
            return $this->fail($e->getMessage(), $e->errorCode, $e->status);
        }
    }
}
