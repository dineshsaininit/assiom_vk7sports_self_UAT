<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller as BaseController;
use Throwable;

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
     * Pass on a business message, but log a technical failure and show the fallback instead.
     */
    protected function publicMessage(Throwable $e, string $fallback): string
    {
        if (
            $e instanceof QueryException
            || $e instanceof \PDOException
            || $e instanceof \Error
        ) {
            report($e);

            return $fallback;
        }

        return $e->getMessage();
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
