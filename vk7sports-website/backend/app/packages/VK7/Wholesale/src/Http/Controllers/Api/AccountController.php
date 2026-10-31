<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;
use VK7\Wholesale\Repositories\EnquiryRepository;
use VK7\Wholesale\Services\BusinessReport;
use Webkul\Core\Models\CountryState;
use Webkul\Customer\Models\CustomerAddress;
use Webkul\Customer\Repositories\CustomerAddressRepository;
use Webkul\Customer\Repositories\CustomerRepository;

class AccountController extends Controller
{
    /**
     * Country every address belongs to until the business sells abroad.
     */
    public const COUNTRY = 'IN';

    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected CustomerRepository $customerRepository,
        protected CustomerAddressRepository $customerAddressRepository,
        protected EnquiryRepository $enquiryRepository,
    ) {}

    /**
     * Return the retailer's profile and addresses.
     */
    public function show(): JsonResponse
    {
        return response()->json(['data' => $this->present()]);
    }

    /**
     * Update the retailer's contact details.
     */
    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20', 'unique:customers,phone,'.$this->customer()->id],
        ]);

        $this->customer()->update($data);

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Change the password after checking the current one, and sign out other devices.
     */
    public function password(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $customer = $this->customer();

        if (! Hash::check($data['current_password'], $customer->password)) {
            throw ValidationException::withMessages(['current_password' => trans('Your current password is not correct.')]);
        }

        $customer->update(['password' => bcrypt($data['password'])]);

        $customer->tokens()->where('id', '!=', $customer->currentAccessToken()->id)->delete();

        return response()->json(['message' => trans('Password changed.')]);
    }

    /**
     * Return this retailer's running account.
     */
    public function statement(BusinessReport $report): JsonResponse
    {
        return response()->json(['data' => $report->statement($this->customer()->id)]);
    }

    /**
     * Send a reset link, answering the same whether or not the account exists.
     */
    public function forgot(Request $request): JsonResponse
    {
        $data = $request->validate(['email' => ['required', 'email']]);

        Password::broker('customers')->sendResetLink($data);

        return response()->json(['data' => ['sent' => true]]);
    }

    /**
     * Add an address.
     */
    public function storeAddress(Request $request): JsonResponse
    {
        $customer = $this->customer();

        $this->createAddress($customer, $this->validateAddress($request), ! $customer->addresses()->exists());

        return response()->json(['data' => $this->present()], 201);
    }

    /**
     * Update one of the retailer's addresses.
     */
    public function updateAddress(Request $request, int $id): JsonResponse
    {
        $address = $this->ownAddress($id);

        if (! $address) {
            return $this->fail(trans('Address not found.'), 'NOT_FOUND', 404);
        }

        $address->update($this->addressAttributes($this->validateAddress($request)));

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Delete an address, keeping at least one and always one default.
     */
    public function destroyAddress(int $id): JsonResponse
    {
        $address = $this->ownAddress($id);

        if (! $address) {
            return $this->fail(trans('Address not found.'), 'NOT_FOUND', 404);
        }

        if ($this->customer()->addresses()->count() === 1) {
            return $this->fail(trans('Keep at least one address on your account.'), 'LAST_ADDRESS');
        }

        $wasDefault = $address->default_address;

        $address->delete();

        if ($wasDefault) {
            $this->customer()->addresses()->first()->update(['default_address' => 1]);
        }

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Make one address the default.
     */
    public function defaultAddress(int $id): JsonResponse
    {
        $address = $this->ownAddress($id);

        if (! $address) {
            return $this->fail(trans('Address not found.'), 'NOT_FOUND', 404);
        }

        $this->customer()->addresses()->update(['default_address' => 0]);

        $address->update(['default_address' => 1]);

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Save a new address for a customer.
     */
    public function createAddress($customer, array $data, bool $isDefault, ?string $gstin = null): void
    {
        CustomerAddress::create(array_merge($this->addressAttributes($data, $customer), [
            'customer_id' => $customer->id,
            'default_address' => $isDefault ? 1 : 0,
            'vat_id' => $gstin,
        ]));
    }

    /**
     * Validate address input and resolve the state to its code.
     */
    public function validateAddress(Request $request): array
    {
        $data = $request->validate([
            'label' => ['required', 'string', 'max:100'],
            'line1' => ['required', 'string', 'max:255'],
            'city' => ['required', 'string', 'max:100'],
            'state' => ['required', 'string', 'max:100'],
            'pin' => ['required', 'digits:6'],
            'phone' => ['required', 'string', 'max:20'],
        ]);

        $state = CountryState::where('country_code', self::COUNTRY)
            ->where(fn ($query) => $query->where('code', $data['state'])->orWhere('default_name', $data['state']))
            ->first();

        if (! $state) {
            throw ValidationException::withMessages(['state' => trans('Enter a valid Indian state.')]);
        }

        return array_merge($data, ['state' => $state->code]);
    }

    /**
     * Find an address belonging to this retailer.
     */
    protected function ownAddress(int $id)
    {
        return $this->customer()->addresses()->where('id', $id)->first();
    }

    /**
     * Map validated input to address columns.
     */
    protected function addressAttributes(array $data, $customer = null): array
    {
        $customer ??= $this->customer();

        return [
            'company_name' => $data['label'],
            'first_name' => $customer->first_name,
            'last_name' => $customer->last_name,
            'address' => $data['line1'],
            'city' => $data['city'],
            'state' => $data['state'],
            'country' => self::COUNTRY,
            'postcode' => $data['pin'],
            'phone' => $data['phone'],
            'email' => $customer->email,
        ];
    }

    /**
     * Shape the retailer's profile for the frontend.
     */
    protected function present(): array
    {
        $customer = $this->customer();

        $company = $customer->type === 'company' ? $customer : $customer->companies()->first();

        return [
            'id' => $customer->id,
            'first_name' => $customer->first_name,
            'last_name' => $customer->last_name,
            'email' => $customer->email,
            'phone' => $customer->phone,
            'business_name' => $company?->businessName(),
            'created_at' => $customer->created_at,
            'addresses' => $customer->addresses()->get()->map(fn ($address) => [
                'id' => $address->id,
                'label' => $address->company_name,
                'line1' => $address->address,
                'city' => $address->city,
                'state' => $address->state,
                'pin' => $address->postcode,
                'phone' => $address->phone,
                'is_default' => (bool) $address->default_address,
                'gstin' => $address->vat_id,
            ])->values(),
        ];
    }
}
