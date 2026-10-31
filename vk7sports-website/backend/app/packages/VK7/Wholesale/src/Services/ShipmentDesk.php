<?php

namespace VK7\Wholesale\Services;

use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Couriers\CourierProvider;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\Shipment;
use VK7\Wholesale\Models\ShipmentEvent;
use Webkul\Sales\Repositories\ShipmentRepository;

class ShipmentDesk
{
    /**
     * Create a new service instance.
     */
    public function __construct(
        protected CourierProvider $courier,
        protected OrderFinance $finance,
        protected ShipmentRepository $shipmentRepository,
        protected ActivityRecorder $activity,
    ) {}

    /**
     * Book the courier for a packed order and deduct its stock through a Bagisto shipment.
     */
    public function dispatch($order, string $actor): Shipment
    {
        if ($this->finance->terms($order)->stage !== 'Packing') {
            throw new BusinessRuleException(trans('Only packed orders can be dispatched.'), 'INVALID_STAGE');
        }

        $address = $order->shipping_address ?? $order->billing_address;

        $booking = $this->courier->book([
            'order_number' => $order->increment_id,
            'pieces' => (int) $order->total_qty_ordered,
            'weight_kg' => (float) $order->total_weight,
            'origin' => config('vk7.courier.origin'),
            'destination' => [
                'name' => $order->customer_full_name,
                'phone' => $address->phone,
                'city' => $address->city,
                'state' => $address->state,
                'pin' => $address->postcode,
            ],
        ]);

        return DB::transaction(function () use ($order, $booking, $actor) {
            $this->createBagistoShipment($order, $booking);

            $shipment = Shipment::create([
                'order_id' => $order->id,
                'provider' => $this->courier->code(),
                'courier' => $booking['courier'],
                'waybill' => $booking['waybill'],
                'status' => end($booking['events'])['status'],
                'tracking_url' => $booking['tracking_url'],
                'expected_on' => $booking['expected_on'],
                'route' => $booking['route'],
            ]);

            $this->storeEvents($shipment, $booking['events']);

            $this->finance->markDispatched($order);

            $this->activity->record($actor, 'Dispatched order', $order->increment_id, $booking['waybill']);

            return $shipment;
        });
    }

    /**
     * Fetch the latest scans from the courier, moving the order on when delivered.
     */
    public function refresh(Shipment $shipment): Shipment
    {
        if ($shipment->delivered_at) {
            return $shipment;
        }

        $this->storeEvents($shipment, $this->courier->track($shipment->waybill, [
            'route' => $shipment->route,
            'scans' => $shipment->events()->count(),
        ]));

        $latest = $shipment->events()->get()->last();

        $delivered = $latest->status === 'Delivered';

        $shipment->update(['status' => $latest->status, 'delivered_at' => $delivered ? $latest->occurred_at : null]);

        if ($delivered) {
            $this->finance->markDelivered($shipment->order);
        }

        return $shipment->fresh();
    }

    /**
     * Shape an order's shipment for the tracking screens.
     */
    public function tracking($order): ?array
    {
        $shipment = Shipment::where('order_id', $order->id)->latest('id')->first();

        if (! $shipment) {
            return null;
        }

        return [
            'id' => $shipment->id,
            'courier' => $shipment->courier,
            'waybill' => $shipment->waybill,
            'status' => $shipment->status,
            'simulated' => $shipment->provider === 'demo',
            'tracking_url' => $shipment->tracking_url,
            'expected_on' => $shipment->expected_on?->toDateString(),
            'delivered_at' => $shipment->delivered_at,
            'route' => $shipment->route,
            'events' => $shipment->events->map(fn ($event) => [
                'status' => $event->status,
                'location' => $event->location,
                'lat' => $event->lat,
                'lng' => $event->lng,
                'description' => $event->description,
                'occurred_at' => $event->occurred_at,
            ])->values(),
        ];
    }

    /**
     * Save scans not yet stored.
     */
    protected function storeEvents(Shipment $shipment, array $events): void
    {
        foreach ($events as $event) {
            ShipmentEvent::firstOrCreate(
                ['shipment_id' => $shipment->id, 'status' => $event['status'], 'location' => $event['location']],
                ['lat' => $event['lat'], 'lng' => $event['lng'], 'description' => $event['description'], 'occurred_at' => $event['occurred_at']],
            );
        }
    }

    /**
     * Create the Bagisto shipment that takes the goods out of stock.
     */
    protected function createBagistoShipment($order, array $booking): void
    {
        $source = $order->channel->inventory_sources->first()->id;

        $items = $order->items
            ->whereNull('parent_id')
            ->mapWithKeys(fn ($item) => [$item->id => [$source => (int) $item->qty_to_ship]])
            ->all();

        $this->shipmentRepository->create([
            'order_id' => $order->id,
            'shipment' => [
                'carrier_title' => $booking['courier'],
                'track_number' => $booking['waybill'],
                'source' => $source,
                'items' => $items,
            ],
        ]);
    }
}
