<?php

namespace VK7\Wholesale\Couriers;

interface CourierProvider
{
    /**
     * The code stored against shipments booked through this provider.
     */
    public function code(): string;

    /**
     * Book a pickup. $shipment has order_number, weight_kg, pieces, origin and destination
     * (city, state, pin, name, phone). Return courier, waybill, tracking_url, expected_on,
     * route (a list of lat, lng, label) and events.
     */
    public function book(array $shipment): array;

    /**
     * Return every scan known for a waybill, oldest first. Each has status, location, lat, lng,
     * description and occurred_at. Use Delivered as the final status so the order moves on.
     */
    public function track(string $waybill, array $context = []): array;
}
