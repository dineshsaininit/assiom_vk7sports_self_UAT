<?php

namespace VK7\Wholesale\Http\Controllers\Api\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use VK7\Wholesale\Http\Controllers\Api\Controller;
use VK7\Wholesale\Http\Middleware\AuthenticateStaff;
use Webkul\User\Repositories\AdminRepository;

class StaffAuthController extends Controller
{
    /**
     * Failed sign-ins allowed per email and address before waiting.
     */
    public const MAX_LOGIN_ATTEMPTS = 6;

    /**
     * Hours a staff token stays valid.
     */
    public const TOKEN_HOURS = 12;

    /**
     * Create a new controller instance.
     */
    public function __construct(protected AdminRepository $adminRepository) {}

    /**
     * Exchange staff credentials for a short-lived token.
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $key = 'vk7-staff-login|'.strtolower($data['email']).'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, self::MAX_LOGIN_ATTEMPTS)) {
            return $this->fail(trans('Too many attempts. Try again in a minute.'), 'TOO_MANY_ATTEMPTS', 429);
        }

        $staff = $this->adminRepository->findOneByField('email', $data['email']);

        if (
            ! $staff
            || ! $staff->status
            || ! Hash::check($data['password'], $staff->password)
        ) {
            RateLimiter::hit($key);

            return $this->fail(trans('The email or password is incorrect.'), 'INVALID_CREDENTIALS', 401);
        }

        if ($staff->two_factor_enabled) {
            return $this->fail(trans('This account uses two-factor sign-in. Use the admin panel.'), 'TWO_FACTOR_REQUIRED', 403);
        }

        RateLimiter::clear($key);

        return response()->json([
            'token' => $staff->createToken('business-desk', ['staff'], now()->addHours(self::TOKEN_HOURS))->plainTextToken,
            'data' => $this->profile($staff),
        ]);
    }

    /**
     * Return the signed-in staff member.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->profile($request->attributes->get('staff'))]);
    }

    /**
     * Revoke the token used on this request.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->attributes->get('staff')->tokens()
            ->where('token', hash('sha256', explode('|', (string) $request->bearerToken(), 2)[1] ?? ''))
            ->delete();

        return response()->json(['message' => trans('Signed out.')]);
    }

    /**
     * Shape a staff member.
     */
    protected function profile($staff): array
    {
        return [
            'id' => $staff->id,
            'name' => $staff->name,
            'email' => $staff->email,
            'role' => $staff->role?->name,
            'areas' => AuthenticateStaff::areasFor($staff),
        ];
    }
}
