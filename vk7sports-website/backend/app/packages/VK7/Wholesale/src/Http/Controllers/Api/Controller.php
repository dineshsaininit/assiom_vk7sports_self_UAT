<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller as BaseController;

abstract class Controller extends BaseController
{
    /**
     * Build the error response every endpoint shares.
     */
    protected function fail(string $message, string $code, int $status = 422, array $extra = []): JsonResponse
    {
        return response()->json(array_merge(['message' => $message, 'code' => $code], $extra), $status);
    }

    /**
     * The retailer signed in on this request.
     */
    protected function customer()
    {
        return auth()->guard('customer')->user();
    }

    /**
     * Whether the current caller may see prices.
     */
    protected function canSeePrices(): bool
    {
        return (bool) $this->customer()
            || ! core()->getConfigData('vk7.pricing.visibility.hide_from_guests');
    }
}
