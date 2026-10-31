<?php

namespace VK7\Wholesale\Couriers;

use VK7\Wholesale\Exceptions\BusinessRuleException;

class DelhiveryCourier implements CourierProvider
{
    /**
     * The code stored against shipments booked through this provider.
     */
    public function code(): string
    {
        return 'delhivery';
    }

    /**
     * Book a pickup with Delhivery once an account and API token exist.
     */
    public function book(array $shipment): array
    {
        throw $this->notConnected();
    }

    /**
     * Fetch scans from Delhivery once an account and API token exist.
     */
    public function track(string $waybill, array $context = []): array
    {
        throw $this->notConnected();
    }

    /**
     * The error shown until this adapter is written against a real account.
     */
    protected function notConnected(): BusinessRuleException
    {
        return new BusinessRuleException(trans('Delhivery is not connected yet.'), 'COURIER_UNAVAILABLE');
    }
}
