<?php

namespace VK7\Wholesale\Http\Controllers\Api\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Http\Controllers\Api\Controller;
use VK7\Wholesale\Models\Payment;
use VK7\Wholesale\Models\Shipment;
use VK7\Wholesale\Services\ActivityRecorder;
use VK7\Wholesale\Services\BusinessReport;
use VK7\Wholesale\Services\OrderFinance;
use VK7\Wholesale\Services\ShipmentDesk;
use Webkul\Customer\Repositories\CustomerRepository;
use Webkul\Sales\Repositories\OrderRepository;

class DeskController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected BusinessReport $report,
        protected OrderFinance $finance,
        protected ShipmentDesk $shipments,
        protected OrderRepository $orderRepository,
        protected CustomerRepository $customerRepository,
        protected ActivityRecorder $activity,
    ) {}

    /**
     * Return the owner's dashboard.
     */
    public function dashboard(): JsonResponse
    {
        return response()->json(['data' => $this->report->dashboard()]);
    }

    /**
     * Return sales, collections and pending money.
     */
    public function reports(): JsonResponse
    {
        return response()->json(['data' => $this->report->reports()]);
    }

    /**
     * List every client.
     */
    public function clients(): JsonResponse
    {
        return response()->json(['data' => $this->report->clients()]);
    }

    /**
     * Return one client with orders and statement.
     */
    public function client(int $id): JsonResponse
    {
        return response()->json(['data' => $this->report->clientDetail($this->clientOr404($id))]);
    }

    /**
     * Approve, reject, suspend or reactivate a client.
     */
    public function decideClient(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'decision' => ['required', Rule::in(['approved', 'rejected', 'suspended'])],
            'reason' => ['required_unless:decision,approved', 'nullable', 'string', 'max:500'],
        ]);

        $client = $this->clientOr404($id);

        $client->update($data['decision'] === 'approved'
            ? ['status' => 1, 'is_verified' => 1, 'is_suspended' => 0]
            : ['is_suspended' => 1]);

        if ($data['decision'] !== 'approved') {
            $client->tokens()->delete();
        }

        $this->activity->record($this->staffName($request), 'Client '.$data['decision'], $client->email, $data['reason'] ?? null);

        return $this->client($id);
    }

    /**
     * List every order.
     */
    public function orders(): JsonResponse
    {
        return response()->json(['data' => $this->report->orderRows()->values()]);
    }

    /**
     * Return one order with money and tracking.
     */
    public function order(int $id): JsonResponse
    {
        $order = $this->orderOr404($id);

        return response()->json(['data' => array_merge($this->finance->summary($order), [
            'id' => $order->id,
            'number' => $order->increment_id,
            'company' => $this->report->companyName($order),
            'customer_id' => $order->customer_id,
            'created_at' => $order->created_at,
            'pieces' => (int) $order->total_qty_ordered,
            'shipping_total' => (float) $order->base_shipping_amount,
            'tracking' => $this->shipments->tracking($order),
            'items' => $order->items->whereNull('parent_id')->map(fn ($item) => [
                'name' => $item->name,
                'sku' => $item->child?->sku ?? $item->sku,
                'options' => $item->additional['attributes'] ?? [],
                'qty_ordered' => (int) $item->qty_ordered,
                'price' => (float) $item->base_price,
            ])->values(),
            'address' => ($address = $order->shipping_address ?? $order->billing_address) ? [
                'label' => $address->company_name,
                'line1' => $address->address,
                'city' => $address->city,
                'state' => $address->state,
                'pin' => $address->postcode,
                'phone' => $address->phone,
            ] : null,
        ])]);
    }

    /**
     * Move an order to the next stage staff control.
     */
    public function moveOrder(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['stage' => ['required', 'string']]);

        return $this->guarded($id, fn ($order) => $this->finance->advance($order, $data['stage'], $this->staffName($request)));
    }

    /**
     * Pause an order.
     */
    public function holdOrder(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['reason' => ['required', 'string', 'max:500']]);

        return $this->guarded($id, fn ($order) => $this->finance->hold($order, $data['reason'], $this->staffName($request)));
    }

    /**
     * Resume a paused order.
     */
    public function resumeOrder(Request $request, int $id): JsonResponse
    {
        return $this->guarded($id, fn ($order) => $this->finance->resume($order, $this->staffName($request)));
    }

    /**
     * Cancel an order.
     */
    public function cancelOrder(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['reason' => ['required', 'string', 'max:500']]);

        return $this->guarded($id, fn ($order) => $this->finance->cancel($order, $data['reason'], $this->staffName($request)));
    }

    /**
     * Book the courier for a packed order.
     */
    public function dispatchOrder(Request $request, int $id): JsonResponse
    {
        return $this->guarded($id, fn ($order) => $this->shipments->dispatch($order, $this->staffName($request)));
    }

    /**
     * Fetch the latest courier scans.
     */
    public function refreshShipment(int $id): JsonResponse
    {
        $shipment = Shipment::find($id);

        if (! $shipment) {
            return $this->fail(trans('Shipment not found.'), 'NOT_FOUND', 404);
        }

        return $this->guarded($shipment->order_id, fn () => $this->shipments->refresh($shipment));
    }

    /**
     * Record money collected against an order.
     */
    public function recordCollection(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0'],
            'method' => ['required', Rule::in(['Cash on delivery', 'UPI', 'Bank transfer'])],
            'reference' => ['required', 'string', 'max:100'],
        ]);

        return $this->guarded($id, fn ($order) => $this->finance->recordCollection($order, (float) $data['amount'], $data['method'], $data['reference'], $this->staffName($request)));
    }

    /**
     * List every payment made or submitted.
     */
    public function payments(): JsonResponse
    {
        $payments = Payment::with('order')->where('status', '!=', 'created')->latest('id')->get();

        return response()->json(['data' => $payments->map(fn ($payment) => array_merge($this->finance->payment($payment), [
            'order_id' => $payment->order_id,
            'order_number' => $payment->order->increment_id,
            'company' => $this->report->companyName($payment->order),
        ]))]);
    }

    /**
     * Accept or reject a submitted reference.
     */
    public function reviewPayment(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'accepted' => ['required', 'boolean'],
            'reason' => ['required_if:accepted,false', 'nullable', 'string', 'max:255'],
        ]);

        $payment = Payment::find($id);

        if (! $payment) {
            return $this->fail(trans('Payment not found.'), 'NOT_FOUND', 404);
        }

        return $this->guarded($payment->order_id, fn () => $this->finance->review($payment, $data['accepted'], $this->staffName($request), $data['reason'] ?? null));
    }

    /**
     * List orders in the warehouse's hands.
     */
    public function dispatchQueue(): JsonResponse
    {
        return response()->json(['data' => $this->report->orderRows()
            ->whereIn('stage', ['Confirmed', 'Packing', 'Dispatched'])
            ->values()
            ->map(fn ($row) => array_merge($row, ['tracking' => $this->shipments->tracking($this->orderRepository->find($row['id']))]))]);
    }

    /**
     * Return the activity log.
     */
    public function activity(): JsonResponse
    {
        return response()->json(['data' => $this->activity->latest()]);
    }

    /**
     * Run an action on an order and return the order, reporting broken rules cleanly.
     */
    protected function guarded(int $id, callable $action): JsonResponse
    {
        try {
            $action($this->orderRepository->find($id));
        } catch (BusinessRuleException $e) {
            return $this->fail($e->getMessage(), $e->errorCode, $e->status);
        }

        return $this->order($id);
    }

    /**
     * The name recorded against staff actions.
     */
    protected function staffName(Request $request): string
    {
        return $request->attributes->get('staff')->name;
    }

    /**
     * Find an order or stop with a 404.
     */
    protected function orderOr404(int $id)
    {
        $order = $this->orderRepository->find($id);

        abort_unless((bool) $order, 404, trans('Order not found.'));

        return $order;
    }

    /**
     * Find a client or stop with a 404.
     */
    protected function clientOr404(int $id)
    {
        $client = $this->customerRepository->find($id);

        abort_unless($client && $client->type === 'company', 404, trans('Client not found.'));

        return $client;
    }
}
