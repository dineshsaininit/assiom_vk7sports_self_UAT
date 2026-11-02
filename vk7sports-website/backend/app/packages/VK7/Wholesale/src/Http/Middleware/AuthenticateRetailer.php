<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;
use Webkul\Checkout\Facades\Cart;
use Webkul\Customer\Contracts\Customer;

class AuthenticateRetailer
{
    /**
     * Sign the request in as the token's retailer; only an active, verified account is accepted.
     */
    public function handle(Request $request, Closure $next, ?string $mode = null)
    {
        $customer = $this->resolveCustomer($request);

        if ($customer) {
            auth()->shouldUse('customer');

            auth()->guard('customer')->setUser($customer);

            Cart::initCart($customer);
        }

        if (
            ! $customer
            && $mode !== 'optional'
        ) {
            return response()->json([
                'message' => trans('Sign in with an approved retailer account.'),
                'code' => 'UNAUTHENTICATED',
            ], 401);
        }

        return $next($request);
    }

    /**
     * Find the retailer behind the bearer token, ignoring expired tokens and blocked accounts.
     */
    protected function resolveCustomer(Request $request)
    {
        $token = $request->bearerToken()
            ? PersonalAccessToken::findToken($request->bearerToken())
            : null;

        if (
            ! $token
            || $token->expires_at?->isPast()
            || ! $token->can('retailer')
        ) {
            return null;
        }

        $customer = $token->tokenable;

        if (
            ! $customer instanceof Customer
            || ! $customer->status
            || ! $customer->is_verified
            || $customer->is_suspended
        ) {
            return null;
        }

        $token->forceFill(['last_used_at' => now()])->save();

        return $customer->withAccessToken($token);
    }
}
