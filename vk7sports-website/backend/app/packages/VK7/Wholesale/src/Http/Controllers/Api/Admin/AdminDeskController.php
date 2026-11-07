<?php

namespace VK7\Wholesale\Http\Controllers\Api\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Http\Controllers\Api\Controller;
use VK7\Wholesale\Models\Enquiry;
use VK7\Wholesale\Repositories\CustomerQuoteRepository;
use VK7\Wholesale\Services\ActivityRecorder;
use VK7\Wholesale\Services\CatalogueDesk;
use VK7\Wholesale\Services\InvoiceDesk;
use VK7\Wholesale\Services\StoreSettings;
use Webkul\B2BSuite\Models\CustomerQuote;
use Webkul\Sales\Repositories\OrderRepository;
use Webkul\User\Models\AdminProxy;
use Webkul\User\Models\RoleProxy;

class AdminDeskController extends Controller
{
    /**
     * Follow-up states an enquiry can be in.
     */
    public const ENQUIRY_STATUSES = ['new', 'contacted', 'converted', 'closed'];

    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected CatalogueDesk $catalogue,
        protected StoreSettings $settings,
        protected InvoiceDesk $invoices,
        protected ActivityRecorder $activity,
        protected CustomerQuoteRepository $quotes,
        protected OrderRepository $orderRepository,
    ) {}

    /**
     * List every style.
     */
    public function products(): JsonResponse
    {
        return response()->json(['data' => $this->catalogue->styles()]);
    }

    /**
     * Return one style.
     */
    public function product(int $id): JsonResponse
    {
        return $this->guarded(fn () => response()->json(['data' => $this->catalogue->find($id)]));
    }

    /**
     * List categories.
     */
    public function categories(): JsonResponse
    {
        return response()->json(['data' => $this->catalogue->categories()]);
    }

    /**
     * Create a style.
     */
    public function storeProduct(Request $request): JsonResponse
    {
        $data = $this->validatedProduct($request, true);

        return $this->guarded(fn () => response()->json(['data' => [
            'id' => $this->catalogue->create($data, $this->staffName($request)),
        ]], 201));
    }

    /**
     * Update a style.
     */
    public function updateProduct(Request $request, int $id): JsonResponse
    {
        $data = $this->validatedProduct($request, false);

        return $this->guarded(function () use ($id, $data, $request) {
            $this->catalogue->update($id, $data, $this->staffName($request));

            return response()->json(['data' => $this->catalogue->find($id)]);
        });
    }

    /**
     * Upload photos for one colour of a style.
     */
    public function uploadPhotos(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'colour' => ['required', 'string', 'max:100'],
            'photos' => ['required', 'array', 'min:1', 'max:10'],
            'photos.*' => ['required', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
        ]);

        return $this->guarded(function () use ($id, $data, $request) {
            $this->catalogue->addPhotos($id, $data['colour'], $request->file('photos'), $this->staffName($request));

            return response()->json(['data' => $this->catalogue->find($id)], 201);
        });
    }

    /**
     * Remove a photo.
     */
    public function removePhoto(Request $request, int $id, int $imageId): JsonResponse
    {
        return $this->guarded(function () use ($id, $imageId, $request) {
            $this->catalogue->removePhoto($id, $imageId, $this->staffName($request));

            return response()->json(['data' => $this->catalogue->find($id)]);
        });
    }

    /**
     * List stock per size and colour.
     */
    public function inventory(): JsonResponse
    {
        return response()->json(['data' => $this->catalogue->inventory()]);
    }

    /**
     * Correct stock with a reason.
     */
    public function adjustStock(Request $request): JsonResponse
    {
        $data = $request->validate([
            'variant_id' => ['required', 'integer'],
            'change' => ['required', 'integer', 'not_in:0'],
            'reason' => ['required', 'string', 'max:100'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        return $this->guarded(function () use ($data, $request) {
            $this->catalogue->adjustStock($data['variant_id'], $data['change'], $data['reason'], $data['note'] ?? null, $this->staffName($request));

            return response()->json(['data' => $this->catalogue->inventory()]);
        });
    }

    /**
     * List stock corrections.
     */
    public function stockLog(): JsonResponse
    {
        return response()->json(['data' => $this->catalogue->stockLog()]);
    }

    /**
     * List every quote.
     */
    public function quotesList(): JsonResponse
    {
        return response()->json(['data' => CustomerQuote::query()->with(['items', 'customer'])->latest('id')->get()->map(fn ($quote) => $this->quote($quote))]);
    }

    /**
     * Return one quote with its messages.
     */
    public function quoteDetail(int $id): JsonResponse
    {
        $quote = CustomerQuote::find($id);

        if (! $quote) {
            return $this->fail(trans('Quote not found.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => array_merge($this->quote($quote), [
            'amounts' => $this->quotes->amounts($quote),
        ])]);
    }

    /**
     * Send staff's amount for the whole quote to the retailer.
     */
    public function sendOffer(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['amount' => ['required', 'numeric', 'gt:0']]);

        $quote = CustomerQuote::find($id);

        if (
            ! $quote
            || ! in_array($quote->status, [CustomerQuote::STATUS_OPEN, CustomerQuote::STATUS_NEGOTIATION])
        ) {
            return $this->fail(trans('This quote can no longer be changed.'), 'QUOTE_CLOSED');
        }

        return $this->guarded(function () use ($quote, $data, $request, $id) {
            $this->quotes->offerAmount($quote, (float) $data['amount'], 'admin', $request->attributes->get('staff')->id);

            $this->activity->record($this->staffName($request), 'Sent quote offer', $quote->quotation_number, (string) $data['amount']);

            return $this->quoteDetail($id);
        });
    }

    /**
     * Accept the retailer's latest amount, which becomes the final price of the quote.
     */
    public function acceptQuote(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['amount' => ['required', 'numeric', 'gt:0']]);

        $quote = CustomerQuote::find($id);

        if (
            ! $quote
            || $quote->status !== CustomerQuote::STATUS_NEGOTIATION
        ) {
            return $this->fail(trans('This quote can no longer be changed.'), 'QUOTE_CLOSED');
        }

        $amounts = $this->quotes->amounts($quote);

        $latest = $amounts ? end($amounts) : null;

        if (
            ! $latest
            || $latest['from'] !== 'retailer'
            || abs($latest['amount'] - (float) $data['amount']) >= 0.01
        ) {
            return $this->fail(trans('The retailer\'s amount has changed. Please check it again.'), 'AMOUNT_CHANGED');
        }

        $quote->update(['status' => CustomerQuote::STATUS_ACCEPTED]);

        $this->activity->record($this->staffName($request), 'Accepted quote amount', $quote->quotation_number, (string) $data['amount']);

        return $this->quoteDetail($id);
    }

    /**
     * Decline a quote.
     */
    public function rejectQuote(Request $request, int $id): JsonResponse
    {
        $quote = CustomerQuote::find($id);

        if (
            ! $quote
            || ! in_array($quote->status, [CustomerQuote::STATUS_OPEN, CustomerQuote::STATUS_NEGOTIATION])
        ) {
            return $this->fail(trans('This quote can no longer be changed.'), 'QUOTE_CLOSED');
        }

        $quote->update(['status' => CustomerQuote::STATUS_REJECTED]);

        $this->activity->record($this->staffName($request), 'Rejected quote', $quote->quotation_number);

        return $this->quoteDetail($id);
    }

    /**
     * List enquiries, leaving out trade applications, which appear under clients.
     */
    public function enquiries(): JsonResponse
    {
        return response()->json(['data' => Enquiry::query()->where('type', '!=', 'retailer_application')->latest('id')->get()->map(fn ($enquiry) => $this->enquiry($enquiry))]);
    }

    /**
     * Update an enquiry's follow-up.
     */
    public function updateEnquiry(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(self::ENQUIRY_STATUSES)],
            'note' => ['nullable', 'string', 'max:1000'],
            'follow_up_on' => ['nullable', 'date'],
        ]);

        $enquiry = Enquiry::find($id);

        if (! $enquiry) {
            return $this->fail(trans('Enquiry not found.'), 'NOT_FOUND', 404);
        }

        $notes = $enquiry->notes ?? [];

        if (! empty($data['note'])) {
            $notes[] = ['at' => now()->toIso8601String(), 'by' => $this->staffName($request), 'text' => $data['note']];
        }

        $enquiry->update(['status' => $data['status'], 'follow_up_on' => $data['follow_up_on'] ?? null, 'notes' => $notes]);

        return response()->json(['data' => $this->enquiry($enquiry)]);
    }

    /**
     * List staff and the roles they can hold.
     */
    public function staff(): JsonResponse
    {
        return response()->json(['data' => [
            'staff' => AdminProxy::query()->with('role')->orderBy('id')->get()->map(fn ($staff) => [
                'id' => $staff->id,
                'name' => $staff->name,
                'email' => $staff->email,
                'role_id' => $staff->role_id,
                'role' => $staff->role?->name,
                'active' => (bool) $staff->status,
            ]),
            'roles' => RoleProxy::query()->orderBy('id')->get(['id', 'name', 'description']),
        ]]);
    }

    /**
     * Add a staff member, setting a first password.
     */
    public function storeStaff(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:admins,email'],
            'password' => ['required', 'string', 'min:10'],
            'role_id' => ['required', 'integer', 'exists:roles,id'],
        ]);

        AdminProxy::query()->create(array_merge($data, ['password' => bcrypt($data['password']), 'status' => 1]));

        $this->activity->record($this->staffName($request), 'Added staff user', $data['email']);

        return $this->staff();
    }

    /**
     * Change a staff member's name and role.
     */
    public function updateStaff(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'role_id' => ['required', 'integer', 'exists:roles,id'],
        ]);

        $staff = AdminProxy::query()->find($id);

        if (! $staff) {
            return $this->fail(trans('Staff member not found.'), 'NOT_FOUND', 404);
        }

        if (
            $staff->id === $request->attributes->get('staff')->id
            && $staff->role_id !== $data['role_id']
        ) {
            return $this->fail(trans('You cannot change your own role.'), 'OWN_ROLE');
        }

        $staff->update($data);

        $this->activity->record($this->staffName($request), 'Updated staff user', $staff->email);

        return $this->staff();
    }

    /**
     * Turn a staff member's access on or off, ending their sessions when off.
     */
    public function toggleStaff(Request $request, int $id): JsonResponse
    {
        $staff = AdminProxy::query()->find($id);

        if (! $staff) {
            return $this->fail(trans('Staff member not found.'), 'NOT_FOUND', 404);
        }

        if ($staff->id === $request->attributes->get('staff')->id) {
            return $this->fail(trans('You cannot deactivate your own login.'), 'OWN_LOGIN');
        }

        $staff->update(['status' => ! $staff->status]);

        if (! $staff->status) {
            $staff->tokens()->delete();
        }

        $this->activity->record($this->staffName($request), $staff->status ? 'Reactivated staff user' : 'Deactivated staff user', $staff->email);

        return $this->staff();
    }

    /**
     * Return business rules and company details.
     */
    public function settings(): JsonResponse
    {
        return response()->json(['data' => $this->settings->all()]);
    }

    /**
     * Save business rules and company details.
     */
    public function saveSettings(Request $request): JsonResponse
    {
        $data = $request->validate([
            'moqEnabled' => ['required', 'boolean'],
            'moq' => ['required', 'integer', 'min:1'],
            'moqMode' => ['required', Rule::in(['per_style', 'per_variant', 'per_order'])],
            'advancePct' => ['required', 'numeric', 'min:20', 'max:100'],
            'codMinScore' => ['sometimes', 'integer', 'between:0,100'],
            'codMinOrders' => ['sometimes', 'integer', 'between:0,100'],
            'codMaxOrder' => ['sometimes', 'numeric', 'min:0', 'max:100000000'],
            'newMidValue' => ['sometimes', 'numeric', 'min:0', 'max:100000000'],
            'newMidPct' => ['sometimes', 'numeric', 'between:20,100'],
            'newPrepaidAbove' => ['sometimes', 'numeric', 'min:0', 'max:100000000'],
            'cancelConfirmedPct' => ['sometimes', 'numeric', 'between:0,50'],
            'cancelPackingPct' => ['sometimes', 'numeric', 'between:0,50'],
            'lateDays' => ['sometimes', 'integer', 'between:1,90'],
            'holdHours' => ['required', 'integer', 'min:1'],
            'quoteValidityDays' => ['required', 'integer', 'min:1'],
            'lowStock' => ['required', 'integer', 'min:0'],
            'taxInvoiceApproved' => ['required', 'boolean'],
            'legalName' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:500'],
            'gstin' => ['nullable', 'string', 'max:20'],
            'phone' => ['nullable', 'string', 'max:30'],
            'whatsapp' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'hours' => ['nullable', 'string', 'max:255'],
            'upiId' => ['nullable', 'string', 'max:100'],
            'bankName' => ['nullable', 'string', 'max:100'],
            'accountName' => ['nullable', 'string', 'max:100'],
            'accountNumber' => ['nullable', 'string', 'max:30'],
            'ifsc' => ['nullable', 'string', 'max:20'],
        ]);

        $this->settings->save($data);

        $this->activity->record($this->staffName($request), 'Changed settings', 'Business settings');

        return $this->settings();
    }

    /**
     * Return an order's invoice.
     */
    public function invoice(int $id): JsonResponse
    {
        $order = $this->orderRepository->find($id);

        if (! $order) {
            return $this->fail(trans('Order not found.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => $this->invoices->build($order)]);
    }

    /**
     * Validate a style's fields.
     */
    protected function validatedProduct(Request $request, bool $creating): array
    {
        return $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'style' => $creating ? ['required', 'string', 'max:64', 'regex:/^[A-Za-z0-9-]+$/'] : ['nullable', 'string'],
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'price' => ['required', 'numeric', 'gt:0'],
            'summary' => ['nullable', 'string', 'max:500'],
            'description' => ['nullable', 'string', 'max:5000'],
            'status' => ['required', Rule::in(['active', 'hidden'])],
            'stock' => ['nullable', 'integer', 'min:0'],
            'weight' => ['nullable', 'numeric', 'min:0'],
            'colours' => ['required', 'array', 'min:1'],
            'colours.*.name' => ['required', 'string', 'max:100'],
            'colours.*.hex' => ['nullable', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'sizes' => ['required', 'array', 'min:1'],
            'sizes.*' => ['required', 'string', 'max:20'],
        ]);
    }

    /**
     * Create a category.
     */
    public function storeCategory(Request $request): JsonResponse
    {
        $data = $request->validate(['name' => ['required', 'string', 'max:100']]);

        return response()->json(['data' => ['id' => $this->catalogue->categoryId($data['name']), 'name' => $data['name']]], 201);
    }

    /**
     * Shape a quote.
     */
    protected function quote($quote): array
    {
        $amounts = $this->quotes->amounts($quote);

        return [
            'id' => $quote->id,
            'number' => $quote->quotation_number,
            'status' => $quote->status,
            'company' => $quote->customer?->businessName() ?: $quote->customer?->name,
            'name' => $quote->name,
            'list_total' => $this->quotes->listTotal($quote),
            'latest_amount' => $amounts ? end($amounts)['amount'] : null,
            'latest_from' => $amounts ? end($amounts)['from'] : null,
            'created_at' => $quote->created_at,
            'expiration_date' => $quote->expiration_date,
            'items' => $quote->items->map(fn ($item) => [
                'id' => $item->id,
                'name' => $item->name,
                'sku' => $item->sku,
                'options' => json_decode((string) $item->additional, true)['attributes'] ?? [],
                'qty' => (int) $item->qty,
                'price' => (float) $item->price,
                'negotiated_price' => (float) $item->negotiated_price,
            ])->values(),
        ];
    }

    /**
     * Shape an enquiry.
     */
    protected function enquiry(Enquiry $enquiry): array
    {
        return [
            'id' => $enquiry->id,
            'number' => 'ENQ-'.str_pad((string) $enquiry->id, 5, '0', STR_PAD_LEFT),
            'type' => $enquiry->type,
            'name' => $enquiry->name,
            'business_name' => $enquiry->business_name,
            'email' => $enquiry->email,
            'phone' => $enquiry->phone,
            'city' => $enquiry->city,
            'quantity' => $enquiry->quantity,
            'message' => $enquiry->message,
            'status' => $enquiry->status,
            'notes' => $enquiry->notes ?? [],
            'follow_up_on' => $enquiry->follow_up_on?->toDateString(),
            'created_at' => $enquiry->created_at,
        ];
    }

    /**
     * The name recorded against staff actions.
     */
    protected function staffName(Request $request): string
    {
        return $request->attributes->get('staff')->name;
    }

    /**
     * Turn a broken business rule into the shared error response.
     */
    protected function guarded(callable $action): JsonResponse
    {
        try {
            return $action();
        } catch (BusinessRuleException $e) {
            return $this->fail($e->getMessage(), $e->errorCode, $e->status);
        }
    }
}
