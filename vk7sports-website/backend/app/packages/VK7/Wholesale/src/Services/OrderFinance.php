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
    public const CLOSED_STAGES = ['Cancelled', 'Expired', 'Returned'];

    /**
     * Stages that can no longer be paused or cancelled.
     */
    public const FINAL_STAGES = ['Delivered', 'Paid in full', 'Cancelled', 'Expired', 'Returned'];

    /**
     * Payment modes: the balance before dispatch, or collected on delivery.
     */
    public const MODES = ['prepaid', 'cod'];

    /**
     * Create a new service instance.
     */
    public function __construct(
        protected OrderRepository $orderRepository,
        protected PaymentGateway $gateway,
        protected ActivityRecorder $activity,
        protected RetailerStanding $standing,
    ) {}

    /**
     * Return an order's terms. Orders placed through checkout get them from openTerms; this is the fallback.
     */
    public function terms($order): OrderTerm
    {
        $existing = OrderTerm::where('order_id', $order->id)->first();

        if ($existing) {
            return $existing;
        }

        return $this->createTerms($order, $this->standing->baseAdvance(), false, null);
    }

    /**
     * Fix an order's advance and payment mode from the retailer's standing when it is placed.
     */
    public function openTerms($order): OrderTerm
    {
        if ($existing = OrderTerm::where('order_id', $order->id)->first()) {
            return $existing;
        }

        $policy = $this->standing->policy($this->standing->companyId((int) $order->customer_id), (float) $order->base_grand_total);

        return $this->createTerms($order, $policy['advance_percent'], $policy['first_order'], $policy['note']);
    }

    /**
     * Create the terms row once.
     */
    protected function createTerms($order, float $percent, bool $firstOrder, ?string $note): OrderTerm
    {
        $hours = (int) (core()->getConfigData('vk7.payments.terms.hold_hours') ?: 48);

        $total = (float) $order->base_grand_total;

        return OrderTerm::firstOrCreate(['order_id' => $order->id], [
            'stage' => in_array($order->status, ['canceled', 'closed']) ? 'Cancelled' : 'Awaiting advance',
            'payment_mode' => $order->payment?->method === 'cashondelivery' ? 'cod' : 'prepaid',
            'first_order' => $firstOrder,
            'risk_note' => $note,
            'advance_percent' => $percent,
            'advance_due' => round($total * $percent / 100, 2),
            'total' => $total,
            'hold_until' => $order->created_at->copy()->addHours($hours),
        ]);
    }

    /**
     * What cancelling this order now would cost.
     */
    public function cancellationQuote($order): array
    {
        return $this->standing->cancellation($this->terms($order), $order);
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
            'payment_mode' => $term->payment_mode,
            'balance_before_dispatch' => $term->payment_mode !== 'cod',
            'first_order' => (bool) $term->first_order,
            'risk_note' => $term->risk_note,
            'cancelled_by' => $term->cancelled_by,
            'cancel_deduction' => $term->cancel_deduction,
            'refund_due' => $term->refund_due,
            'refund_status' => $term->refund_status,
            'refund_reference' => $term->refund_reference,
            'advance_percent' => $term->advance_percent,
            'advance_due' => $term->advance_due,
            'balance_due' => round($term->total - $term->advance_due, 2),
            'total' => $term->total,
            'paid' => $paid,
            'outstanding' => $closed ? 0.0 : round($term->total - $paid, 2),
            'hold_until' => $term->stage === 'Awaiting advance' ? $term->hold_until : null,
            'payable' => $this->payableKind($term, $payments, $paid),
            'min_payment' => $term->advance_due,
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
    public function startOnline($order, string $kind, ?float $requested = null): array
    {
        $amount = $this->amountDue($order, $kind, $requested);

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

        if ($payment->status !== 'created') {
            throw new BusinessRuleException(trans('This payment cannot be confirmed online.'), 'PAYMENT_NOT_OPEN');
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
    public function submitReference($order, string $kind, string $method, string $reference, ?float $requested = null): void
    {
        $amount = $this->amountDue($order, $kind, $requested);

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

        $this->standing->recordForOrder($payment->order, 'payment_rejected', $actor, $reason);

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
     * Cancel an order and release its stock. When the retailer is at fault, the cancellation
     * policy keeps part of what was paid and lowers their score; the rest is owed back.
     */
    public function cancel($order, string $reason, string $actor, string $fault = 'retailer'): array
    {
        $term = $this->terms($order);

        $quote = $this->standing->cancellation($term, $order);

        if (
            ! $quote['allowed']
            || in_array($term->stage, self::FINAL_STAGES)
            || $term->stage === 'Dispatched'
        ) {
            throw new BusinessRuleException(trans('This order can no longer be cancelled.'), 'CANNOT_CANCEL');
        }

        if (Payment::where('order_id', $order->id)->where('status', 'submitted')->exists()) {
            throw new BusinessRuleException(trans('A payment on this order is waiting to be checked. Please try again after it is reviewed.'), 'PAYMENT_PENDING');
        }

        $deduction = $fault === 'retailer' ? $quote['deduction'] : 0.0;

        $refund = round($quote['paid'] - $deduction, 2);

        if (! $this->orderRepository->cancel($order)) {
            throw new BusinessRuleException(trans('This order can no longer be cancelled.'), 'CANNOT_CANCEL');
        }

        $this->terms($order)->update([
            'stage' => 'Cancelled',
            'hold_until' => null,
            'cancelled_by' => $fault,
            'cancel_deduction' => $deduction,
            'refund_due' => $refund,
            'refund_status' => $refund > 0 ? 'pending' : null,
        ]);

        if (
            $fault === 'retailer'
            && $quote['event']
        ) {
            $this->standing->recordForOrder($order, $quote['event'], $actor, $reason);
        }

        $this->activity->record($actor, 'Cancelled order', $order->increment_id, $reason.' (deduction ₹'.number_format($deduction, 2).', refund ₹'.number_format($refund, 2).')');

        return ['deduction' => $deduction, 'refund' => $refund];
    }

    /**
     * The retailer refused a cash-on-delivery parcel: the order is returned and the policy deduction applies.
     */
    public function markCodRefused($order, string $note, string $actor): void
    {
        $term = $this->terms($order);

        if (
            $term->payment_mode !== 'cod'
            || ! in_array($term->stage, ['Dispatched', 'Delivered'])
        ) {
            throw new BusinessRuleException(trans('Only a dispatched cash-on-delivery order can be marked as refused.'), 'INVALID_STAGE');
        }

        $paid = round((float) Payment::where('order_id', $order->id)->where('status', 'verified')->sum('amount'), 2);

        $percent = $this->standing->setting('cancelPackingPct');

        $deduction = min($paid, round($term->total * $percent / 100, 2));

        $refund = round($paid - $deduction, 2);

        $term->update([
            'stage' => 'Returned',
            'cancelled_by' => 'retailer',
            'cancel_deduction' => $deduction,
            'refund_due' => $refund,
            'refund_status' => $refund > 0 ? 'pending' : null,
        ]);

        $this->standing->recordForOrder($order, 'cod_refused', $actor, $note);

        $this->activity->record($actor, 'Cash on delivery refused, order returned', $order->increment_id, $note);
    }

    /**
     * Finance records the refund owed after a cancellation.
     */
    public function markRefunded($order, string $reference, string $actor): void
    {
        $term = $this->terms($order);

        if ($term->refund_status !== 'pending') {
            throw new BusinessRuleException(trans('No refund is waiting on this order.'), 'NO_REFUND');
        }

        $term->update(['refund_status' => 'refunded', 'refund_reference' => $reference]);

        $this->activity->record($actor, 'Refund paid', $order->increment_id, '₹'.number_format((float) $term->refund_due, 2).' ref '.$reference);
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

                $this->standing->recordForOrder($order, 'advance_expired', 'System');

                $this->activity->record('System', 'Order expired: no advance received', $order->increment_id);
            }
        }

        $this->standing->markLatePayments();

        return $overdue->count();
    }

    /**
     * Work out what to collect now. The first payment may be anything from the minimum advance
     * up to the full amount; the balance is always what is left.
     */
    protected function amountDue($order, string $kind, ?float $requested = null): float
    {
        $summary = $this->summary($order);

        if ($summary['payable'] !== $kind) {
            throw new BusinessRuleException(trans('This payment is not due now.'), 'NOT_PAYABLE');
        }

        if ($kind === 'balance') {
            return $summary['outstanding'];
        }

        $amount = round($requested ?? (float) $summary['advance_due'], 2);

        if (
            $amount < (float) $summary['advance_due']
            || $amount > (float) $summary['outstanding']
        ) {
            throw new BusinessRuleException(trans('Enter an amount from the minimum advance up to the full amount.'), 'INVALID_AMOUNT');
        }

        return $amount;
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

        if ($paid >= $term->total) {
            return null;
        }

        // Prepaid orders clear the balance before dispatch; cash-on-delivery orders after delivery.
        $balanceStages = $term->payment_mode === 'cod' ? ['Delivered'] : ['Confirmed', 'Packing', 'Delivered'];

        return in_array($term->stage, $balanceStages) ? 'balance' : null;
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

            $this->standing->recordForOrder($order, 'order_completed', 'System');
        }
    }
}
