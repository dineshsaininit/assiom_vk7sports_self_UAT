<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CloseBagistoShop
{
    /**
     * The only paths still served: the VK7 API, public files, password links and the health check.
     */
    public const OPEN_PATHS = [
        'api/v1/*',
        'storage/*',
        'cache/*',
        'themes/*',
        'up',
        'customer/reset-password',
        'customer/reset-password/*',
        'customer/verify-account/*',
    ];

    /**
     * Keep the old storefront, installer and tools closed, since they skip VK7's approval and payment rules.
     */
    public function handle(Request $request, Closure $next)
    {
        if (
            ! config('vk7.site.close_bagisto_shop')
            || $request->is(...self::OPEN_PATHS)
            || $this->isAdminPanel($request)
        ) {
            return $next($request);
        }

        return $request->isMethod('GET') || $request->isMethod('HEAD')
            ? redirect()->away(config('vk7.site.url'))
            : response()->json(['message' => trans('Not found.'), 'code' => 'NOT_FOUND'], 404);
    }

    /**
     * Leave the admin path to CloseBagistoAdmin, which sends it to the single VK7 admin.
     */
    protected function isAdminPanel(Request $request): bool
    {
        $path = trim(config('app.admin_url'), '/');

        return $request->is($path) || $request->is($path.'/*');
    }
}
