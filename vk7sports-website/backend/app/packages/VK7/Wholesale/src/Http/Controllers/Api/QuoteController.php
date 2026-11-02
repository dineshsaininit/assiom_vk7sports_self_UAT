<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Exceptions\MoqNotMetException;
use VK7\Wholesale\Repositories\CustomerQuoteRepository;
use Webkul\B2BSuite\Models\CustomerQuote;
use Webkul\B2BSuite\Notifications\Notifier;
use Webkul\B2BSuite\Repositories\CustomerQuoteMessageRepository;
use Webkul\Checkout\Facades\Cart;
use Webkul\User\Repositories\AdminRepository;

class QuoteController extends Controller
{
    /**
     * Statuses a retailer can no longer reject.
     */
    public const FINAL_STATUSES = [
        CustomerQuote::STATUS_ORDERED,
        CustomerQuote::STATUS_COMPLETED,
        CustomerQuote::STATUS_REJECTED,
        CustomerQuote::STATUS_EXPIRED,
    ];

    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected CustomerQuoteRepository $customerQuoteRepository,
        protected CustomerQuoteMessageRepository $customerQuoteMessageRepository,
        protected AdminRepository $adminRepository,
    ) {}

    /**
     * List the quotes this retailer's company may see.
     */
    public function index(Request $request): JsonResponse
    {
        $quotes = $this->customerQuoteRepository->scopeQuery(
            fn ($query) => $query->where($this->scope())->orderByDesc('id')
        )->paginate(max(1, min((int) $request->query('limit', 15), 100)));

        return response()->json([
            'data' => collect($quotes->items())->map(fn ($quote) => $this->summary($quote))->values(),
            'meta' => [
                'current_page' => $quotes->currentPage(),
                'last_page' => $quotes->lastPage(),
                'total' => $quotes->total(),
            ],
        ]);
    }

    /**
     * Turn the current cart into a quote request.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'target_amount' => ['nullable', 'numeric', 'gt:0'],
        ]);

        $customer = $this->customer();

        $company = $customer->type === 'company' ? $customer : $customer->companies()->first();

        if (! $company) {
            return $this->fail(trans('Quotes need a company account.'), 'NO_COMPANY', 403);
        }

        if (! Cart::getCart()) {
            return $this->fail(trans('The cart is empty.'), 'CART_EMPTY');
        }

        $target = $data['target_amount'] ?? null;

        if (
            $target
            && round((float) $target, 2) > round((float) Cart::getCart()->base_sub_total, 2)
        ) {
            return $this->fail(trans('Enter an amount up to the list value of this quote.'), 'INVALID_AMOUNT');
        }

        $numbers = $this->customerQuoteRepository->generateQuotationNumber(null);

        try {
            $quote = $this->customerQuoteRepository->create(array_merge(['name' => $data['name']], $numbers, [
                'status' => CustomerQuote::STATUS_OPEN,
                'customer_id' => $customer->id,
                'company_id' => $company->id,
                'agent_id' => $company->sales_rep_id ?? $this->adminRepository->first()?->id,
                'customer_name' => $customer->name,
                'customer_email' => $customer->email,
            ]));
        } catch (MoqNotMetException $e) {
            return $this->fail($e->getMessage(), 'MOQ_NOT_MET');
        }

        if ($target) {
            $this->customerQuoteRepository->offerAmount($quote->refresh(), (float) $target, 'customer', $customer->id);
        }

        Notifier::quote($quote, 'requested', 'admin');

        return response()->json(['data' => $this->detail($quote->refresh())], 201);
    }

    /**
     * Return one quote with its lines and messages.
     */
    public function show(int $id): JsonResponse
    {
        $quote = $this->find($id);

        return $quote
            ? response()->json(['data' => $this->detail($quote)])
            : $this->notFound();
    }

    /**
     * Send the retailer's amount for the whole quote.
     */
    public function counter(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['amount' => ['required', 'numeric', 'gt:0']]);

        $quote = $this->find($id);

        if (! $quote) {
            return $this->notFound();
        }

        if (! in_array($quote->status, [CustomerQuote::STATUS_OPEN, CustomerQuote::STATUS_NEGOTIATION])) {
            return $this->fail(trans('This quote can no longer be changed.'), 'QUOTE_CLOSED');
        }

        try {
            $this->customerQuoteRepository->offerAmount($quote, (float) $data['amount'], 'customer', $this->customer()->id);
        } catch (BusinessRuleException $e) {
            return $this->fail($e->getMessage(), $e->errorCode, $e->status);
        }

        Notifier::quote($quote->refresh(), 'countered', 'admin');

        return response()->json(['data' => $this->detail($quote)]);
    }

    /**
     * Accept the latest admin offer and move it into the cart, both or neither.
     */
    public function accept(int $id): JsonResponse
    {
        $quote = $this->find($id);

        if (! $quote) {
            return $this->notFound();
        }

        if (
            $quote->expiration_date
            && now()->startOfDay()->gt($quote->expiration_date)
        ) {
            return $this->fail(trans('This quote has expired.'), 'QUOTE_EXPIRED');
        }

        $canAccept = $quote->status === CustomerQuote::STATUS_NEGOTIATION
            && $this->customerQuoteMessageRepository->getLastQuotationMessage($quote->id, 'admin');

        if (
            ! $canAccept
            && $quote->status !== CustomerQuote::STATUS_ACCEPTED
        ) {
            return $this->fail(trans('There is no offer from VK7SPORTS to accept yet.'), 'NO_OFFER');
        }

        try {
            DB::transaction(function () use ($quote) {
                $quote->update(['status' => CustomerQuote::STATUS_ACCEPTED]);

                $this->customerQuoteRepository->updateCart($quote->id);
            });
        } catch (\Throwable $e) {
            Cart::initCart($this->customer());

            return $this->fail($this->publicMessage($e, trans('This offer could not be accepted. Please try again.')), 'ACCEPT_FAILED');
        }

        if ($canAccept) {
            Notifier::quote($quote, 'accepted', 'admin');
        }

        return response()->json(['data' => $this->detail($quote->refresh())]);
    }

    /**
     * Decline a quote.
     */
    public function reject(int $id): JsonResponse
    {
        $quote = $this->find($id);

        if (! $quote) {
            return $this->notFound();
        }

        if (in_array($quote->status, self::FINAL_STATUSES)) {
            return $this->fail(trans('This quote can no longer be changed.'), 'QUOTE_CLOSED');
        }

        $quote->update(['status' => CustomerQuote::STATUS_REJECTED]);

        Notifier::quote($quote, 'rejected', 'admin');

        return response()->json(['data' => $this->detail($quote->refresh())]);
    }

    /**
     * Conditions that keep a retailer inside its own company's quotes.
     */
    protected function scope(): array
    {
        $customer = $this->customer();

        $conditions = ['soft_deleted' => 0];

        if ($customer->type === 'company') {
            return $conditions + ['company_id' => $customer->id];
        }

        if ($company = $customer->companies()->first()) {
            return $conditions + ['company_id' => $company->id];
        }

        return $conditions + ['customer_id' => $customer->id];
    }

    /**
     * Find a quote this retailer may see.
     */
    protected function find(int $id)
    {
        return $this->customerQuoteRepository->findOneWhere($this->scope() + ['id' => $id]);
    }

    /**
     * Respond the same way for a missing quote and another retailer's quote.
     */
    protected function notFound(): JsonResponse
    {
        return $this->fail(trans('Quote not found.'), 'NOT_FOUND', 404);
    }

    /**
     * Shape a quote for listing screens.
     */
    protected function summary($quote): array
    {
        $amounts = $this->customerQuoteRepository->amounts($quote);

        return [
            'id' => $quote->id,
            'quotation_number' => $quote->quotation_number,
            'po_number' => $quote->po_number,
            'name' => $quote->name,
            'status' => $quote->status,
            'state' => $quote->state,
            'total' => (float) $quote->base_total,
            'negotiated_total' => (float) $quote->base_negotiated_total,
            'pieces' => (int) $quote->items->sum('qty'),
            'list_total' => $this->customerQuoteRepository->listTotal($quote),
            'latest_amount' => $amounts ? end($amounts)['amount'] : null,
            'latest_from' => $amounts ? end($amounts)['from'] : null,
            'expiration_date' => $quote->expiration_date,
            'order_id' => $quote->order_id,
            'created_at' => $quote->created_at,
        ];
    }

    /**
     * Shape a quote with its lines and messages.
     */
    protected function detail($quote): array
    {
        return array_merge($this->summary($quote), [
            'can_accept' => $quote->status === CustomerQuote::STATUS_NEGOTIATION
                && (bool) $this->customerQuoteMessageRepository->getLastQuotationMessage($quote->id, 'admin'),
            'items' => $quote->items->map(fn ($item) => [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'name' => $item->name,
                'sku' => $item->sku,
                'options' => json_decode($item->additional ?? '[]', true)['attributes'] ?? [],
                'qty' => (int) $item->qty,
                'price' => (float) $item->base_price,
                'negotiated_qty' => (int) $item->negotiated_qty,
                'negotiated_price' => (float) $item->base_negotiated_price,
                'negotiated_total' => (float) $item->base_negotiated_total,
            ])->values(),
            'amounts' => $this->customerQuoteRepository->amounts($quote),
        ]);
    }
}
