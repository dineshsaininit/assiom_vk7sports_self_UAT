<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class AuthenticateStaff
{
    /**
     * Admit a staff token, requiring the named area of the business desk when one is given.
     */
    public function handle(Request $request, Closure $next, ?string $area = null)
    {
        $staff = $this->resolveStaff($request);

        if (! $staff) {
            return response()->json(['message' => trans('Sign in as staff.'), 'code' => 'UNAUTHENTICATED'], 401);
        }

        if (
            $area
            && ! in_array($area, self::areasFor($staff))
        ) {
            return response()->json(['message' => trans('Your role does not include this.'), 'code' => 'FORBIDDEN'], 403);
        }

        $request->attributes->set('staff', $staff);

        return $next($request);
    }

    /**
     * The desk areas a staff member may use, from their Bagisto role.
     */
    public static function areasFor($staff): array
    {
        $areas = ['dashboard', 'retailers', 'orders', 'payments', 'dispatch', 'reports', 'audit'];

        if ($staff->role?->permission_type === 'all') {
            return $areas;
        }

        return array_values(array_filter($areas, fn ($area) => $staff->hasPermission('vk7_desk.'.$area)));
    }

    /**
     * Find the staff member behind the bearer token.
     */
    protected function resolveStaff(Request $request)
    {
        $token = $request->bearerToken()
            ? PersonalAccessToken::findToken($request->bearerToken())
            : null;

        if (
            ! $token
            || $token->expires_at?->isPast()
            || ! $token->can('staff')
            || ! $token->tokenable?->status
        ) {
            return null;
        }

        return $token->tokenable;
    }
}
