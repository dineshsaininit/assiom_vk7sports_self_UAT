<?php

namespace VK7\Wholesale\Services;

use Illuminate\Database\QueryException;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\OrderTerm;
use VK7\Wholesale\Models\Payment;
use VK7\Wholesale\Models\RetailerPolicy;
use VK7\Wholesale\Models\ScoreEvent;
use Webkul\Customer\Models\CustomerProxy;
use Webkul\Sales\Models\OrderProxy;

/**
 * The retailer debit score and the payment rules that follow from it: the advance asked for,
 * whether cash on delivery is offered, and what a cancellation costs.
 */
class RetailerStanding
{
    /**
     * Where every retailer starts.
     */
    public const BASE_SCORE = 60;

    /**
     * The smallest advance ever asked for, set by the chartered accountant.
     */
    public const MIN_ADVANCE_PERCENT = 20;

    /**
     * Points for each kind of event. Manual adjustments carry their own points.
     */
    public const POINTS = [
        'order_completed' => 5,
        'cancelled_before_payment' => -3,
        'cancelled_after_advance' => -8,
        'cancelled_while_packing' => -12,
        'advance_expired' => -5,
        'payment_rejected' => -10,
        'payment_late' => -10,
        'cod_refused' => -20,
    ];

    /**
     * What each event is called on screen.
     */
    public const LABELS = [
        'order_completed' => 'Order paid in full',
        'cancelled_before_payment' => 'Order cancelled before payment',
        'cancelled_after_advance' => 'Order cancelled after the advance',
        'cancelled_while_packing' => 'Order cancelled while being packed',
        'advance_expired' => 'Advance not paid in time',
        'payment_rejected' => 'Payment reference rejected',
        'payment_late' => 'Balance paid late',
        'cod_refused' => 'Cash on delivery refused',
        'manual' => 'Adjusted by VK7',
    ];

    /**
     * Policy settings, as the form key, the stored code and the default.
     */
    public const SETTINGS = [
        'codMinScore' => ['vk7.risk.cod_min_score', 70],
        'codMinOrders' => ['vk7.risk.cod_min_orders', 2],
        'codMaxOrder' => ['vk7.risk.cod_max_order', 100000],
        'newMidValue' => ['vk7.risk.new_mid_value', 25000],
        'newMidPct' => ['vk7.risk.new_mid_percent', 50],
        'newPrepaidAbove' => ['vk7.risk.new_prepaid_above', 100000],
        'cancelConfirmedPct' => ['vk7.risk.cancel_confirmed_percent', 5],
        'cancelPackingPct' => ['vk7.risk.cancel_packing_percent', 10],
        'lateDays' => ['vk7.risk.late_days', 7],
    ];

    /**
     * Cached company ids, keyed by buyer.
     */
    protected array $companies = [];

    /**
     * Read one policy setting.
     */
    public function setting(string $key): float
    {
        [$code, $default] = self::SETTINGS[$key];

        $value = core()->getConfigData($code);

        return is_numeric($value) ? (float) $value : (float) $default;
    }

    /**
     * The base advance percent from the settings, never below the minimum.
     */
    public function baseAdvance(): float
    {
        return max(self::MIN_ADVANCE_PERCENT, (float) (core()->getConfigData('vk7.payments.terms.advance_percent') ?: self::MIN_ADVANCE_PERCENT));
    }

    /**
     * The company account a buyer belongs to; a company's own id for its owner.
     */
    public function companyId(int $customerId): int
    {
        if (isset($this->companies[$customerId])) {
            return $this->companies[$customerId];
        }

        $customer = CustomerProxy::query()->find($customerId);

        $id = $customer && $customer->type !== 'company'
            ? ($customer->companies()->first()?->id ?? $customerId)
            : $customerId;

        return $this->companies[$customerId] = $id;
    }

    /**
     * Every buyer login under a company.
     */
    public function buyerIds(int $companyId): array
    {
        $company = CustomerProxy::query()->find($companyId);

        return $company && $company->type === 'company'
            ? array_values(array_unique(array_merge([$companyId], $company->members()->pluck('customers.id')->all())))
            : [$companyId];
    }

    /**
     * Record an event once per order. A repeat of the same event for the same order is ignored.
     */
    public function record(int $companyId, string $type, ?int $orderId, string $actor, ?string $note = null, ?int $points = null): void
    {
        $points ??= self::POINTS[$type] ?? 0;

        try {
            $orderId
                ? ScoreEvent::firstOrCreate(['customer_id' => $companyId, 'type' => $type, 'order_id' => $orderId], ['points' => $points, 'note' => $note, 'actor' => $actor])
                : ScoreEvent::create(['customer_id' => $companyId, 'type' => $type, 'points' => $points, 'note' => $note, 'actor' => $actor]);
        } catch (QueryException) {
            // Two requests recorded the same event at once; the unique key kept one.
        }
    }

    /**
     * Record an event against the company behind an order.
     */
    public function recordForOrder($order, string $type, string $actor, ?string $note = null): void
    {
        $this->record($this->companyId((int) $order->customer_id), $type, (int) $order->id, $actor, $note);
    }

    /**
     * The score from 0 to 100.
     */
    public function score(int $companyId): int
    {
        return (int) max(0, min(100, self::BASE_SCORE + (int) ScoreEvent::where('customer_id', $companyId)->sum('points')));
    }

    /**
     * The band a score falls in.
     */
    public function tier(int $score): string
    {
        return match (true) {
            $score >= 80 => 'Excellent',
            $score >= 60 => 'Good',
            $score >= 40 => 'Watch',
            default => 'High risk',
        };
    }

    /**
     * Orders this company has paid in full.
     */
    public function completedOrders(int $companyId): int
    {
        return OrderTerm::whereIn('order_id', OrderProxy::query()->whereIn('customer_id', $this->buyerIds($companyId))->select('id'))
            ->where('stage', 'Paid in full')
            ->count();
    }

    /**
     * The staff override for cash on delivery: auto, allow or block.
     */
    public function codOverride(int $companyId): string
    {
        return RetailerPolicy::where('customer_id', $companyId)->value('cod_override') ?? 'auto';
    }

    /**
     * Whether cash on delivery may be offered, with the reason shown to the retailer.
     */
    public function cod(int $companyId, ?float $total = null): array
    {
        $override = $this->codOverride($companyId);

        $limit = $this->setting('codMaxOrder');

        if ($override === 'block') {
            return ['eligible' => false, 'reason' => 'Cash on delivery is not available on this account. Please contact sales.', 'limit' => $limit];
        }

        if ($override === 'allow') {
            return ['eligible' => true, 'reason' => 'Cash on delivery is available on this account.', 'limit' => null];
        }

        $score = $this->score($companyId);
        $done = $this->completedOrders($companyId);
        $minOrders = (int) $this->setting('codMinOrders');
        $minScore = (int) $this->setting('codMinScore');

        $reason = match (true) {
            $done < $minOrders => 'Cash on delivery opens after '.$minOrders.' orders paid in full. You have '.$done.'.',
            $score < $minScore => 'Cash on delivery needs a payment score of '.$minScore.' or more. Yours is '.$score.'.',
            $total !== null && $total > $limit => 'Cash on delivery is available on orders up to ₹'.number_format($limit).'.',
            default => null,
        };

        return ['eligible' => $reason === null, 'reason' => $reason ?? 'Cash on delivery is available for the balance.', 'limit' => $limit];
    }

    /**
     * The advance and checks for a new order of this value.
     */
    public function policy(int $companyId, float $total): array
    {
        $score = $this->score($companyId);
        $tier = $this->tier($score);
        $isNew = $this->completedOrders($companyId) === 0;
        $percent = $this->baseAdvance();
        $notes = [];

        if ($isNew) {
            if ($total > $this->setting('newPrepaidAbove')) {
                $percent = 100;
                $notes[] = 'First order above ₹'.number_format($this->setting('newPrepaidAbove')).': full payment before dispatch, and call the retailer to confirm.';
            } elseif ($total > $this->setting('newMidValue')) {
                $percent = max($percent, $this->setting('newMidPct'));
                $notes[] = 'First order above ₹'.number_format($this->setting('newMidValue')).': higher advance.';
            } else {
                $notes[] = 'First order.';
            }
        }

        if ($tier === 'Watch') {
            $percent = max($percent, 30);
            $notes[] = 'Payment score '.$score.' (Watch): higher advance.';
        }

        if ($tier === 'High risk') {
            $percent = max($percent, $score < 20 ? 100 : 50);
            $notes[] = 'Payment score '.$score.' (High risk): '.($score < 20 ? 'full payment before dispatch.' : 'half paid in advance.');
        }

        return [
            'advance_percent' => min(100, $percent),
            'first_order' => $isNew,
            'note' => implode(' ', $notes) ?: null,
            'cod' => $this->cod($companyId, $total),
        ];
    }

    /**
     * Refuse an order before it is saved when cash on delivery is asked for but not allowed.
     */
    public function assertOrder(array $data): void
    {
        if (($data['payment']['method'] ?? null) !== 'cashondelivery') {
            return;
        }

        $cod = $this->cod($this->companyId((int) $data['customer_id']), (float) ($data['base_grand_total'] ?? 0));

        if (! $cod['eligible']) {
            throw new BusinessRuleException($cod['reason'], 'COD_NOT_AVAILABLE');
        }
    }

    /**
     * What cancelling now would cost, from the stage and the retailer's score.
     */
    public function cancellation(OrderTerm $term, $order): array
    {
        $paid = round((float) Payment::where('order_id', $order->id)->where('status', 'verified')->sum('amount'), 2);

        $score = $this->score($this->companyId((int) $order->customer_id));

        [$allowed, $base, $event] = match ($term->stage) {
            'Awaiting advance' => [true, 0.0, 'cancelled_before_payment'],
            'Confirmed' => [true, $this->setting('cancelConfirmedPct'), 'cancelled_after_advance'],
            'Packing' => [true, $this->setting('cancelPackingPct'), 'cancelled_while_packing'],
            default => [false, 0.0, null],
        };

        $multiplier = match ($this->tier($score)) {
            'Excellent' => 0.5,
            'Good' => 1.0,
            'Watch' => 1.5,
            default => 2.0,
        };

        $percent = round($base * $multiplier, 2);

        $deduction = min($paid, round($term->total * $percent / 100, 2));

        return [
            'allowed' => $allowed,
            'stage' => $term->stage,
            'deduction_percent' => $percent,
            'deduction' => $deduction,
            'paid' => $paid,
            'refund' => round($paid - $deduction, 2),
            'score' => $score,
            'score_change' => $event ? self::POINTS[$event] : 0,
            'event' => $event,
        ];
    }

    /**
     * Everything staff and the retailer see about the account's standing.
     */
    public function standing(int $companyId, bool $forStaff = false): array
    {
        $score = $this->score($companyId);

        $events = ScoreEvent::where('customer_id', $companyId)->latest('id')->limit(30)->get();

        $orders = OrderProxy::query()->whereIn('id', $events->pluck('order_id')->filter())->pluck('increment_id', 'id');

        return [
            'score' => $score,
            'tier' => $this->tier($score),
            'completed_orders' => $this->completedOrders($companyId),
            'cod' => $this->cod($companyId),
            'cod_override' => $this->codOverride($companyId),
            'advance_percent' => $this->policy($companyId, 0)['advance_percent'],
            'events' => $events->map(fn ($event) => array_filter([
                'type' => $event->type,
                'label' => self::LABELS[$event->type] ?? $event->type,
                'points' => $event->points,
                'order_number' => $event->order_id ? ($orders[$event->order_id] ?? null) : null,
                'note' => $forStaff ? $event->note : null,
                'actor' => $forStaff ? $event->actor : null,
                'created_at' => $event->created_at,
            ], fn ($value) => $value !== null))->values(),
        ];
    }

    /**
     * Staff change cash on delivery access or the score by hand, always with a reason.
     */
    public function adjust(int $companyId, string $actor, string $note, ?string $codOverride = null, int $points = 0): void
    {
        if ($codOverride !== null) {
            RetailerPolicy::updateOrCreate(['customer_id' => $companyId], ['cod_override' => $codOverride, 'note' => $note, 'updated_by' => $actor]);
        }

        if ($points !== 0) {
            $this->record($companyId, 'manual', null, $actor, $note, $points);
        }
    }

    /**
     * Mark cash-on-delivery balances still unpaid after the grace period as late, once per order.
     */
    public function markLatePayments(): int
    {
        $days = (int) $this->setting('lateDays');

        $count = 0;

        $terms = OrderTerm::where('stage', 'Delivered')->where('payment_mode', 'cod')->where('updated_at', '<', now()->subDays($days))->get();

        foreach ($terms as $term) {
            $paid = (float) Payment::where('order_id', $term->order_id)->where('status', 'verified')->sum('amount');

            $order = OrderProxy::query()->find($term->order_id);

            if (
                $order
                && round($paid, 2) < $term->total
                && ! ScoreEvent::where('type', 'payment_late')->where('order_id', $term->order_id)->exists()
            ) {
                $this->recordForOrder($order, 'payment_late', 'System', 'Balance unpaid '.$days.' days after delivery');

                $count++;
            }
        }

        return $count;
    }
}
