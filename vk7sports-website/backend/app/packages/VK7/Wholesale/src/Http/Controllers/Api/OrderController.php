<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Webkul\Sales\Repositories\OrderRepository;

class OrderController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(protected OrderRepository $orderRepository) {}

    /**
     * List this retailer's orders.
     */
    public function index(Request $request): JsonResponse
    {
        $orders = $this->orderRepository->scopeQuery(
            fn ($query) => $query->whereIn('customer_id', $this->buyerIds())->orderByDesc('id')
        )->paginate(min((int) $request->query('limit', 15), 100));

        return response()->json([
            'data' => collect($orders->items())->map(fn ($order) => $this->summary($order))->values(),
            'meta' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    /**
     * Return one order with its lines and tracking.
     */
    public function show(int $id): JsonResponse
    {
        $order = $this->orderRepository->find($id);

        if (
            ! $order
            || ! in_array($order->customer_id, $this->buyerIds())
        ) {
            return $this->fail(trans('Order not found.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => array_merge($this->summary($order), [
            'sub_total' => (float) $order->base_sub_total,
            'tax_total' => (float) $order->base_tax_amount,
            'shipping_total' => (float) $order->base_shipping_amount,
            'shipping_title' => $order->shipping_title,
            'payment_method' => $order->payment?->method,
            'items' => $order->items->whereNull('parent_id')->map(fn ($item) => [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'variant_id' => $item->child?->product_id,
                'name' => $item->name,
                'sku' => $item->child?->sku ?? $item->sku,
                'options' => $item->additional['attributes'] ?? [],
                'qty_ordered' => (int) $item->qty_ordered,
                'qty_shipped' => (int) $item->qty_shipped,
                'price' => (float) $item->base_price,
                'total' => (float) $item->base_total,
            ])->values(),
            'shipments' => $this->shipments($order),
            'comments' => $order->comments->map(fn ($comment) => [
                'comment' => $comment->comment,
                'created_at' => $comment->created_at,
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
     * Cancel an order that has not started moving.
     */
    public function cancel(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['reason' => ['required', 'string', 'max:500']]);

        $order = $this->orderRepository->find($id);

        if (
            ! $order
            || ! in_array($order->customer_id, $this->buyerIds())
        ) {
            return $this->fail(trans('Order not found.'), 'NOT_FOUND', 404);
        }

        if (
            $order->status !== 'pending'
            || ! $this->orderRepository->cancel($order)
        ) {
            return $this->fail(trans('This order can no longer be cancelled online. Please contact sales.'), 'CANNOT_CANCEL');
        }

        $order->comments()->create(['comment' => 'Cancelled by retailer: '.$data['reason'], 'customer_notified' => 0]);

        return $this->show($id);
    }

    /**
     * Show basic progress to anyone holding both the order number and the mobile on it.
     */
    public function track(Request $request): JsonResponse
    {
        $data = $request->validate([
            'number' => ['required', 'string', 'max:50'],
            'phone' => ['required', 'string', 'max:20'],
        ]);

        $order = $this->orderRepository->findOneByField('increment_id', trim($data['number']));

        $phone = substr(preg_replace('/\D/', '', $data['phone']), -10);

        if (
            ! $order
            || ! $order->addresses->contains(fn ($address) => substr(preg_replace('/\D/', '', (string) $address->phone), -10) === $phone)
        ) {
            return $this->fail(trans('No order matches that number and mobile.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => [
            'order_number' => $order->increment_id,
            'status' => $order->status,
            'status_label' => $order->status_label,
            'total_qty' => (int) $order->total_qty_ordered,
            'created_at' => $order->created_at,
            'shipments' => $this->shipments($order),
        ]]);
    }

    /**
     * Customers whose orders this retailer may see: its own, and its members' for a company owner.
     */
    protected function buyerIds(): array
    {
        $customer = $this->customer();

        $ids = [$customer->id];

        return $customer->type === 'company'
            ? array_values(array_unique(array_merge($ids, $customer->members()->pluck('customers.id')->all())))
            : $ids;
    }

    /**
     * Shape an order's shipments.
     */
    protected function shipments($order)
    {
        return $order->shipments->map(fn ($shipment) => [
            'id' => $shipment->id,
            'carrier' => $shipment->carrier_title,
            'track_number' => $shipment->track_number,
            'total_qty' => (int) $shipment->total_qty,
            'created_at' => $shipment->created_at,
        ])->values();
    }

    /**
     * Shape an order for listing screens.
     */
    protected function summary($order): array
    {
        return [
            'id' => $order->id,
            'order_number' => $order->increment_id,
            'status' => $order->status,
            'status_label' => $order->status_label,
            'total_qty' => (int) $order->total_qty_ordered,
            'grand_total' => (float) $order->base_grand_total,
            'currency' => $order->order_currency_code,
            'created_at' => $order->created_at,
        ];
    }
}
