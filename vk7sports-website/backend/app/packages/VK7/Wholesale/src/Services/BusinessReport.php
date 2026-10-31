<?php

namespace VK7\Wholesale\Services;

use Illuminate\Support\Collection;
use VK7\Wholesale\Models\Enquiry;
use VK7\Wholesale\Models\Payment;
use Webkul\B2BSuite\Models\CustomerQuote;
use Webkul\Customer\Models\CustomerProxy;
use Webkul\Sales\Models\OrderItemProxy;
use Webkul\Sales\Models\OrderProxy;

class BusinessReport
{
    /**
     * Shop names already looked up for this report.
     */
    protected array $companies = [];

    /**
     * Create a new service instance.
     */
    public function __construct(
        protected OrderFinance $finance,
        protected CatalogueDesk $catalogue,
        protected StoreSettings $settings,
    ) {}

    /**
     * The numbers on the owner's dashboard.
     */
    public function dashboard(): array
    {
        $rows = $this->orderRows();

        $live = $rows->whereNotIn('stage', OrderFinance::CLOSED_STAGES);

        return [
            'ordersToday' => $rows->filter(fn ($row) => $row['created_at']->isToday())->count(),
            'openOrders' => $live->whereNotIn('stage', ['Delivered', 'Paid in full'])->count(),
            'awaitingVerification' => Payment::where('status', 'submitted')->count(),
            'awaitingAdvance' => $rows->where('stage', 'Awaiting advance')->count(),
            'moneyToCollect' => round($live->sum('outstanding'), 2),
            'pendingRetailers' => $this->companyQuery()->where('status', 0)->where('is_suspended', 0)->count(),
            'readyToDispatch' => $rows->whereIn('stage', ['Confirmed', 'Packing'])->count(),
            'openQuotes' => CustomerQuote::query()->where('status', CustomerQuote::STATUS_OPEN)->count(),
            'newEnquiries' => Enquiry::query()->where('status', 'new')->where('type', '!=', 'retailer_application')->count(),
            'lowStock' => $this->catalogue->lowStock($this->settings->lowStock()),
            'recent' => $rows->sortByDesc('id')->take(6)->values(),
        ];
    }

    /**
     * Sales, collections and money still owed, by month, style and client.
     */
    public function reports(): array
    {
        $live = $this->orderRows()->whereNotIn('stage', OrderFinance::CLOSED_STAGES);

        $collected = Payment::where('status', 'verified')->get()
            ->groupBy(fn ($payment) => $payment->paid_at->format('Y-m'))
            ->map(fn ($payments) => round($payments->sum('amount'), 2));

        return [
            'sales' => round($live->sum('total'), 2),
            'collected' => round($live->sum('paid'), 2),
            'outstanding' => round($live->sum('outstanding'), 2),
            'orders' => $live->count(),
            'monthly' => $live->groupBy(fn ($row) => $row['created_at']->format('Y-m'))
                ->map(fn ($rows, $month) => [
                    'month' => $month,
                    'orders' => $rows->count(),
                    'pieces' => $rows->sum('pieces'),
                    'sales' => round($rows->sum('total'), 2),
                    'collected' => $collected[$month] ?? 0,
                    'pending' => round($rows->sum('outstanding'), 2),
                ])->sortKeys()->values(),
            'pending' => $live->where('outstanding', '>', 0)->sortBy('created_at')->values()->map(fn ($row) => array_merge($row, [
                'age_days' => (int) $row['created_at']->diffInDays(now()),
            ])),
            'products' => $this->piecesByStyle($live->pluck('id')),
            'retailers' => $live->groupBy('customer_id')->map(fn ($rows) => [
                'customer_id' => $rows->first()['customer_id'],
                'company' => $rows->first()['company'],
                'orders' => $rows->count(),
                'billed' => round($rows->sum('total'), 2),
                'paid' => round($rows->sum('paid'), 2),
                'outstanding' => round($rows->sum('outstanding'), 2),
            ])->sortByDesc('outstanding')->values(),
        ];
    }

    /**
     * Every client with their order and money totals.
     */
    public function clients(): Collection
    {
        $rows = $this->orderRows()->whereNotIn('stage', OrderFinance::CLOSED_STAGES)->groupBy('customer_id');

        return $this->companyQuery()->orderBy('id', 'desc')->get()->map(function ($client) use ($rows) {
            $orders = $rows->get($client->id, collect());

            return array_merge($this->client($client), [
                'orders' => $orders->count(),
                'billed' => round($orders->sum('total'), 2),
                'paid' => round($orders->sum('paid'), 2),
                'outstanding' => round($orders->sum('outstanding'), 2),
            ]);
        });
    }

    /**
     * One client with their orders and running account.
     */
    public function clientDetail($client): array
    {
        $orders = $this->orderRows()->where('customer_id', $client->id)->sortByDesc('id')->values();

        return array_merge($this->client($client), [
            'orders' => $orders,
            'statement' => $this->statement($client->id),
            'addresses' => $client->addresses->map(fn ($address) => [
                'line1' => is_array($address->address) ? implode(', ', $address->address) : $address->address,
                'city' => $address->city,
                'state' => $address->state,
                'pin' => $address->postcode,
                'gstin' => $address->vat_id,
            ])->values(),
        ]);
    }

    /**
     * A client's orders and verified payments as a running account.
     */
    public function statement(int $customerId): array
    {
        $rows = collect();

        foreach ($this->orderRows()->where('customer_id', $customerId)->whereNotIn('stage', OrderFinance::CLOSED_STAGES) as $order) {
            $rows->push(['at' => $order['created_at'], 'text' => 'Order '.$order['number'], 'order_id' => $order['id'], 'debit' => $order['total'], 'credit' => 0]);

            foreach (Payment::where('order_id', $order['id'])->where('status', 'verified')->get() as $payment) {
                $rows->push(['at' => $payment->paid_at, 'text' => ucfirst($payment->kind).' received', 'order_id' => $order['id'], 'debit' => 0, 'credit' => $payment->amount]);
            }
        }

        $balance = 0.0;

        $rows = $rows->sortBy('at')->values()->map(function ($row) use (&$balance) {
            $balance = round($balance + $row['debit'] - $row['credit'], 2);

            return array_merge($row, ['balance' => $balance]);
        });

        return [
            'rows' => $rows,
            'billed' => round($rows->sum('debit'), 2),
            'paid' => round($rows->sum('credit'), 2),
            'balance' => $balance,
        ];
    }

    /**
     * Every order as a flat row of stage and money.
     */
    public function orderRows(): Collection
    {
        $this->finance->expireOverdue();

        return OrderProxy::query()->orderBy('id', 'desc')->get()->map(function ($order) {
            $money = $this->finance->summary($order);

            return [
                'id' => $order->id,
                'number' => $order->increment_id,
                'customer_id' => $order->customer_id,
                'company' => $this->companyName($order),
                'pieces' => (int) $order->total_qty_ordered,
                'created_at' => $order->created_at,
                'stage' => $money['stage'],
                'total' => $money['total'],
                'paid' => $money['paid'],
                'outstanding' => $money['outstanding'],
            ];
        });
    }

    /**
     * The shop name behind an order, falling back to the buyer's name.
     */
    public function companyName($order): string
    {
        return $this->companies[$order->customer_id] ??= CustomerProxy::query()->find($order->customer_id)?->businessName() ?: $order->customer_full_name;
    }

    /**
     * Companies registered as retailers.
     */
    protected function companyQuery()
    {
        return CustomerProxy::query()->where('type', 'company');
    }

    /**
     * Shape a client for listing screens.
     */
    protected function client($client): array
    {
        return [
            'id' => $client->id,
            'company' => $client->businessName() ?: $client->name,
            'contact' => $client->name,
            'email' => $client->email,
            'phone' => $client->phone,
            'status' => $client->is_suspended ? 'suspended' : ($client->status ? 'approved' : 'pending'),
            'applied_at' => $client->created_at,
        ];
    }

    /**
     * Pieces sold per style.
     */
    protected function piecesByStyle(Collection $orderIds): Collection
    {
        return OrderItemProxy::query()
            ->whereIn('order_id', $orderIds)
            ->whereNull('parent_id')
            ->get()
            ->groupBy('name')
            ->map(fn ($items, $name) => ['name' => $name, 'pieces' => (int) $items->sum('qty_ordered')])
            ->sortByDesc('pieces')
            ->values();
    }
}
