<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class HidePricesFromGuests
{
    /**
     * Storefront routes that return prices to whoever calls them.
     */
    public const PRICED_ROUTES = [
        'shop.api.products.*',
        'shop.api.categories.max_price',
        'shop.api.compare.*',
        'shop.search.index',
        'shop.product_or_category.index',
    ];

    /**
     * Keep guests away from the priced storefront routes while prices are hidden from them.
     */
    public function handle(Request $request, Closure $next)
    {
        if (
            ! core()->getConfigData('vk7.pricing.visibility.hide_from_guests')
            || auth()->guard('customer')->check()
            || ! $request->routeIs(...self::PRICED_ROUTES)
        ) {
            return $next($request);
        }

        if ($request->expectsJson()) {
            return response()->json([
                'message' => trans('Sign in with an approved retailer account.'),
                'code' => 'UNAUTHENTICATED',
            ], 401);
        }

        return redirect()->route('shop.customer.session.index');
    }
}
