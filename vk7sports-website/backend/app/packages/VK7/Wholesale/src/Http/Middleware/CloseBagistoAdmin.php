<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CloseBagistoAdmin
{
    /**
     * Send anyone reaching the old admin panel to the single VK7 admin.
     */
    public function handle(Request $request, Closure $next)
    {
        $path = trim(config('app.admin_url'), '/');

        if (
            config('vk7.admin.close_bagisto_panel')
            && ($request->is($path) || $request->is($path.'/*'))
        ) {
            return redirect()->away(config('vk7.admin.url'));
        }

        return $next($request);
    }
}
