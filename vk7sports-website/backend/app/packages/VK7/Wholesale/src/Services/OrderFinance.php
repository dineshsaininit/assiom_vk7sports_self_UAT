<?php

namespace VK7\Wholesale\Services;

use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\OrderTerm;
use VK7\Wholesale\Models\Payment;
use VK7\Wholesale\Payments\PaymentGateway;
use Webkul\Sales\Models\Order;
use Webkul\Sales\Repositories\OrderRepository;

class OrderFinance
{
    /**
     * Stages after which nothing is owed.
     */
    public const CLOSED_STAGES = ['Cancelled', 'Expired'];

    /**
     * Stages that can no longer be paused or cancelled.
     */
    public const FINAL_STAGES = ['Delivered', 'Paid in full', 'Cancelled', 'Expired'];

    /**
     * Create a new service instance.
     */
    public function __construct(
        protected OrderRepository $orderRepository,
        protected PaymentGateway $gateway,
        protected ActivityRecorder $activity,
    ) {}

    /**
     * Return an order's terms, fixing the advance from the settings when first seen.
     */
    public function terms($order): OrderTerm
    {
        $percent = (float) (core()->getConfigData('vk7.payments.terms.advance_percent') ?: 10);

        $hours = (int) (core()->getConfigData('vk7.payments.terms.hold_hours') ?: 48);

        $total = (float) $order->base_grand_total;

        return OrderTerm::firstOrCreate(['order_id' => $order->id], [
            'stage' => in_array($order->status, ['canceled', 'closed']) ? 'Cancelled' : 'Awaiting advance',
            'advance_percent' => $percent,
            'advance_due' => round($total * $percent / 100, 2),
            'total' => $total,
            'hold_until' => $order->created_at->copy()->addHours($hours),
        ]);
    }

    /**
     * Shape an order's money and stage for the screens.
     */
    public function summary($order): array
    {
        $term = $this->terms($order);

        $payments = Payment::where('order_id', $order->id)->orderBy('id')->get();

        $paid = round($payments->where('status', 'verified')->sum('amount'), 2);

        $closed = in_array($term->stage, self::CLOSED_STAGES);

        return [
            'stage' => $term->stage,
            'advance_percent' => $term->advance_percent,
            'advance_due' => $term->advance_due,
            'balance_due' => round($term->total - $term->advance_due, 2),
            'total' => $term->total,
            'paid' => $paid,
            'outstanding' => $closed ? 0.0 : round($term->total - $paid, 2),
            'hold_until' => $term->stage === 'Awaiting advance' ? $term->hold_until : null,
            'payable' => $this->payableKind($term, $payments, $paid),
            'gateway' => $this->gateway->code(),
            'payments' => $payments->where('status', '!=', 'created')->map(fn ($payment) => $this->payment($payment))->values(),
        ];
    }

    /**
     * Shape a payment.
     */
    public function payment(Payment $payment): array
    {
        return [
            'id' => $payment->id,
            'kind' => $payment->kind,
            'amount' => $payment->amount,
            'method' => $payment->method,
            'status' => $payment->status,
            'reference' => $payment->reference ?? $payment->gateway_payment_id,
            'reviewed_by' => $payment->reviewed_by,
            'reject_reason' => $payment->reject_reason,
            'created_at' => $payment->created_at,
        ];
    }

    /**
     * Open an online payment for the amount the server works out.
     */
    public function startOnline($order, string $kind): array
    {
        $amount = $this->amountDue($order, $kind);

        $payment = Payment::where('order_id', $order->id)
            ->where('kind', $kind)
            ->where('status', 'created')
            ->where('gateway', $this->gateway->code())
            ->where('amount', $amount)
            ->first();

        if (! $payment) {
            $payment = Payment::create([
                'order_id' => $order->id,
                'kind' => $kind,
                'amount' => $amount,
                'method' => 'online',
                'status' => 'created',
                'gateway' => $this->gateway->code(),
            ]);

            $payment->update(['gateway_order_id' => $this->gateway->createOrder($payment, $order->increment_id.'-'.$payment->id)]);
        }

        return [
            'payment_id' => $payment->id,
            'gateway' => $this->gateway->code(),
            'amount' => $payment->amount,
            'options' => $this->gateway->clientOptions($payment, [
                'description' => ucfirst($kind).' for order '.$order->increment_id,
                'prefill' => ['name' => $order->customer_full_name, 'email' => $order->customer_email],
            ]),
        ];
    }

    /**
     * Accept the browser's result after the gateway proves it is genuine.
     */
    public function confirmOnline($order, int $paymentId, array $result): void
    {
        $payment = Payment::where('order_id', $order->id)->where('id', $paymentId)->first();

        if (! $payment) {
            throw new BusinessRuleException(trans('Payment not found.'), 'NOT_FOUND', 404);
        }

        if ($payment->status === 'verified') {
            return;
        }

        $this->settle($payment, $this->gateway->verify($payment, $result), 'Payment gateway');
    }

    /**
     * Apply a signed gateway notification. Safe to receive more than once.
     */
    public function handleWebhook(string $body, ?string $signature): void
    {
        $event = $this->gateway->parseWebhook($body, $signature);

        if (
            ! $event
            || ! $event['order_id']
        ) {
            return;
        }

        $payment = Payment::where('gateway', $this->gateway->code())->where('gateway_order_id', $event['order_id'])->first();

        if (
            ! $payment
            || $payment->status === 'verified'
            || (int) round($payment->amount * 100) !== $event['paise']
        ) {
            return;
        }

        $this->settle($payment, $event['payment_id'], 'Payment gateway');
    }

    /**
     * Record a UPI or bank reference for finance to check against the statement.
     */
    public function submitReference($order, string $kind, string $method, string $reference): void
    {
        $amount = $this->amountDue($order, $kind);

        if (Payment::where('reference', $reference)->whereIn('status', ['submitted', 'verified'])->exists()) {
            throw new BusinessRuleException(trans('This reference has already been used.'), 'DUPLICATE_REFERENCE');
        }

        Payment::create([
            'order_id' => $order->id,
            'kind' => $kind,
            'amount' => $amount,
            'method' => $method,
            'status' => 'submitted',
            'reference' => $reference,
        ]);
    }

    /**
     * Accept or reject a submitted reference.
     */
    public function review(Payment $payment, bool $accepted, string $actor, ?string $reason = null): void
    {
        if ($payment->status !== 'submitted') {
            throw new BusinessRuleException(trans('This payment is not waiting for review.'), 'NOT_REVIEWABLE');
        }

        if ($accepted) {
            $this->settle($payment, null, $actor);

            return;
        }

        $payment->update(['status' => 'rejected', 'reviewed_by' => $actor, 'reject_reason' => $reason]);

        $this->activity->record($actor, 'Rejected payment', $payment->order->increment_id, $payment->reference);
    }

    /**
     * Record money collected on delivery by staff.
     */
    public function recordCollection($order, float $amount, string $method, string $reference, string $actor): void
    {
        $outstanding = $this->summary($order)['outstanding'];

        if (
            $amount <= 0
            || $amount > $outstanding
        ) {
            throw new BusinessRuleException(trans('The amount must not exceed the balance due.'), 'INVALID_AMOUNT');
        }

        $this->settle(Payment::create([
            'order_id' => $order->id,
            'kind' => 'balance',
            'amount' => $amount,
            'method' => $method,
            'status' => 'submitted',
            'reference' => $reference,
        ]), null, $actor);
    }

    /**
     * Move an order to a stage staff may set directly.
     */
    public function advance($order, string $stage, string $actor): void
    {
        $term = $this->terms($order);

        if (
            $term->stage !== 'Confirmed'
            || $stage !== 'Packing'
        ) {
            throw new BusinessRuleException(trans('That change is not allowed from this stage.'), 'INVALID_STAGE');
        }

        $term->update(['stage' => $stage]);

        $this->activity->record($actor, 'Moved order to '.$stage, $order->increment_id);
    }

    /**
     * Pause an order with a reason.
     */
    public function hold($order, string $reason, string $actor): void
    {
        $term = $this->terms($order);

        if (
            $term->stage === 'On hold'
            || in_array($term->stage, self::FINAL_STAGES)
        ) {
            throw new BusinessRuleException(trans('This order cannot be put on hold.'), 'INVALID_STAGE');
        }

        $term->update(['stage' => 'On hold', 'previous_stage' => $term->stage]);

        $this->activity->record($actor, 'Put order on hold', $order->increment_id, $reason);
    }

    /**
     * Resume a paused order where it left off.
     */
    public function resume($order, string $actor): void
    {
        $term = $this->terms($order);

        if ($term->stage !== 'On hold') {
            throw new BusinessRuleException(trans('This order is not on hold.'), 'INVALID_STAGE');
        }

        $term->update(['stage' => $term->previous_stage, 'previous_stage' => null]);

        $this->activity->record($actor, 'Resumed order', $order->increment_id);
    }

    /**
     * Cancel an order and release its stock.
     */
    public function cancel($order, string $reason, string $actor): void
    {
        $term = $this->terms($order);

        if (
            in_array($term->stage, self::FINAL_STAGES)
            || $term->stage === 'Dispatched'
            || ! $this->orderRepository->cancel($order)
        ) {
            throw new BusinessRuleException(trans('This order can no longer be cancelled.'), 'CANNOT_CANCEL');
        }

        $this->activity->record($actor, 'Cancelled order', $order->increment_id, $reason);
    }

    /**
     * Mark an order cancelled when Bagisto cancels it, from any screen.
     */
    public function markCancelled($order): void
    {
        $this->terms($order)->update(['stage' => 'Cancelled', 'hold_until' => null]);
    }

    /**
     * Mark a shipment's order dispatched.
     */
    public function markDispatched($order): void
    {
        $this->terms($order)->update(['stage' => 'Dispatched']);
    }

    /**
     * Mark an order delivered, closing it when nothing is left to pay.
     */
    public function markDelivered($order): void
    {
        $this->terms($order)->update(['stage' => 'Delivered']);

        $this->closeIfPaid($order);
    }

    /**
     * Expire orders whose advance never arrived, releasing their stock.
     */
    public function expireOverdue(): int
    {
        $overdue = OrderTerm::where('stage', 'Awaiting advance')
            ->where('hold_until', '<', now())
            ->whereNotIn('order_id', Payment::whereIn('status', ['submitted', 'verified'])->select('order_id'))
            ->get();

        foreach ($overdue as $term) {
            $order = $this->orderRepository->find($term->order_id);

            if (
                $order
                && $this->orderRepository->cancel($order)
            ) {
                $term->update(['stage' => 'Expired', 'hold_until' => null]);

                $this->activity->record('System', 'Order expired: no advance received', $order->increment_id);
            }
        }

        return $overdue->count();
    }

    /**
     * Work out what is due now, refusing payment at the wrong moment.
     */
    protected function amountDue($order, string $kind): float
    {
        $summary = $this->summary($order);

        if ($summary['payable'] !== $kind) {
            throw new BusinessRuleException(trans('This payment is not due now.'), 'NOT_PAYABLE');
        }

        return $kind === 'advance' ? $summary['advance_due'] : $summary['outstanding'];
    }

    /**
     * Decide which payment, if any, the retailer can make now.
     */
    protected function payableKind(OrderTerm $term, $payments, float $paid): ?string
    {
        if ($payments->contains('status', 'submitted')) {
            return null;
        }

        if (
            $term->stage === 'Awaiting advance'
            && $paid < $term->advance_due
        ) {
            return 'advance';
        }

        return $term->stage === 'Delivered' && $paid < $term->total ? 'balance' : null;
    }

    /**
     * Mark a payment verified once and apply it, safely against a repeat of the same result.
     */
    protected function settle(Payment $payment, ?string $gatewayPaymentId, string $actor): void
    {
        DB::transaction(function () use ($payment, $gatewayPaymentId, $actor) {
            $locked = Payment::whereKey($payment->id)->lockForUpdate()->first();

            if ($locked->status === 'verified') {
                return;
            }

            $locked->update([
                'status' => 'verified',
                'gateway_payment_id' => $gatewayPaymentId,
                'reviewed_by' => $actor,
                'paid_at' => now(),
            ]);

            $order = $locked->order;

            $term = $this->terms($order);

            if (
                $locked->kind === 'advance'
                && $term->stage === 'Awaiting advance'
            ) {
                $term->update(['stage' => 'Confirmed', 'hold_until' => null]);

                $this->orderRepository->updateOrderStatus($order, Order::STATUS_PROCESSING);
            }

            $this->activity->record($actor, 'Verified '.$locked->kind.' payment', $order->increment_id, $locked->reference ?? $gatewayPaymentId);

            $this->closeIfPaid($order);
        });
    }

    /**
     * Close a delivered order once it is fully paid.
     */
    protected function closeIfPaid($order): void
    {
        $term = $this->terms($order);

        $paid = Payment::where('order_id', $order->id)->where('status', 'verified')->sum('amount');

        if (
            $term->stage === 'Delivered'
            && round($paid, 2) >= $term->total
        ) {
            $term->update(['stage' => 'Paid in full']);

            $this->orderRepository->updateOrderStatus($order, Order::STATUS_COMPLETED);
        }
    }
}
