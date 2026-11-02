<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use VK7\Wholesale\Repositories\EnquiryRepository;
use Webkul\B2BSuite\Http\Controllers\Shop\Customer\RegistrationController;
use Webkul\B2BSuite\Http\Requests\CompanyRequest;
use Webkul\Checkout\Repositories\CartRepository;
use Webkul\Customer\Repositories\CustomerRepository;

class AuthController extends Controller
{
    /**
     * Failed sign-ins allowed per email and address before waiting.
     */
    public const MAX_LOGIN_ATTEMPTS = 6;

    /**
     * Seconds a sign-in stays blocked after too many failures.
     */
    public const LOGIN_LOCK_SECONDS = 300;

    /**
     * Shortest password a retailer may choose.
     */
    public const MIN_PASSWORD_LENGTH = 8;

    /**
     * Days a retailer token stays valid.
     */
    public const TOKEN_DAYS = 30;

    /**
     * Create a new controller instance.
     */
    public function __construct(protected CustomerRepository $customerRepository) {}

    /**
     * Register a shop through the B2B company sign-up, which applies the approval setting.
     */
    public function register(
        CompanyRequest $request,
        RegistrationController $registrationController,
        AccountController $accountController,
        EnquiryRepository $enquiryRepository,
    ): JsonResponse {
        $address = $request->filled('line1') ? $accountController->validateAddress($request) : null;

        $profile = $request->validate([
            'password' => ['required', 'string', 'min:'.self::MIN_PASSWORD_LENGTH],
            'shop_type' => ['nullable', 'string', 'max:100'],
            'gstin' => ['nullable', 'string', 'max:20'],
            'proof' => ['nullable', 'string', 'max:255'],
        ]);

        $customer = DB::transaction(function () use ($request, $registrationController, $accountController, $enquiryRepository, $address, $profile) {
            $registrationController->save($request);

            $customer = $this->customerRepository->findOneByField('email', $request->input('email'));

            if ($address) {
                $accountController->createAddress($customer, $address, true, $profile['gstin'] ?? null);
            }

            $enquiryRepository->create([
                'type' => 'retailer_application',
                'name' => $customer->name,
                'business_name' => $request->input('business_name'),
                'email' => $customer->email,
                'phone' => $customer->phone,
                'city' => $address['city'] ?? null,
                'message' => 'Trade application. Shop type: '.($profile['shop_type'] ?? 'not given')
                    .'. GSTIN: '.($profile['gstin'] ?? 'not given')
                    .'. Other proof: '.($profile['proof'] ?? 'not given').'.',
            ]);

            return $customer;
        });

        return response()->json([
            'data' => [
                'email' => $customer->email,
                'approval' => $customer->status ? 'approved' : 'pending',
            ],
        ], 201);
    }

    /**
     * Exchange credentials of an approved retailer for a token.
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $key = 'vk7-login|'.strtolower($data['email']).'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, self::MAX_LOGIN_ATTEMPTS)) {
            return $this->fail(trans('Too many attempts. Please try again in a few minutes.'), 'TOO_MANY_ATTEMPTS', 429);
        }

        $customer = $this->customerRepository->findOneByField('email', $data['email']);

        if (
            ! $customer
            || ! Hash::check($data['password'], $customer->password)
        ) {
            RateLimiter::hit($key, self::LOGIN_LOCK_SECONDS);

            return $this->fail(trans('The email or password is incorrect.'), 'INVALID_CREDENTIALS', 401);
        }

        RateLimiter::clear($key);

        if (! $customer->status) {
            return $this->fail(trans('This account is waiting for approval.'), 'ACCOUNT_PENDING', 403);
        }

        if (! $customer->is_verified) {
            return $this->fail(trans('Verify your email address first.'), 'EMAIL_NOT_VERIFIED', 403);
        }

        if ($customer->is_suspended) {
            return $this->fail(trans('This account is suspended.'), 'ACCOUNT_SUSPENDED', 403);
        }

        return response()->json([
            'token' => $customer->createToken('frontend', ['retailer'], now()->addDays(self::TOKEN_DAYS))->plainTextToken,
            'token_type' => 'Bearer',
            'expires_in_days' => self::TOKEN_DAYS,
            'data' => $this->profile($customer),
        ]);
    }

    /**
     * Revoke the token used on this request.
     */
    public function logout(): JsonResponse
    {
        $this->customer()->currentAccessToken()->delete();

        return response()->json(['message' => trans('Signed out.')]);
    }

    /**
     * Return the signed-in retailer.
     */
    public function me(): JsonResponse
    {
        return response()->json(['data' => $this->profile($this->customer())]);
    }

    /**
     * Shape a retailer for the frontend.
     */
    protected function profile($customer): array
    {
        $company = $customer->type === 'company'
            ? $customer
            : $customer->companies()->first();

        return [
            'cart_count' => (int) app(CartRepository::class)->findOneWhere(['customer_id' => $customer->id, 'is_active' => 1])?->items_qty,
            'id' => $customer->id,
            'first_name' => $customer->first_name,
            'last_name' => $customer->last_name,
            'email' => $customer->email,
            'phone' => $customer->phone,
            'type' => $customer->type,
            'company' => $company ? [
                'id' => $company->id,
                'business_name' => $company->businessName(),
            ] : null,
        ];
    }
}
