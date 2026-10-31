<?php

namespace VK7\Wholesale;

use VK7\Wholesale\Exceptions\QuoteLockedException;
use Webkul\B2BSuite\Models\CustomerQuote;
use Webkul\B2BSuite\Repositories\CustomerQuoteItemRepository;

class QuoteLock
{
    /**
     * Largest difference between an order price and its negotiated price treated as rounding.
     */
    public const PRICE_TOLERANCE = 0.01;

    /**
     * Create a new instance.
     */
    public function __construct(protected CustomerQuoteItemRepository $customerQuoteItemRepository) {}

    /**
     * Return the violation message for a cart, or null when every quoted line matches its quote.
     */
    public function cartViolation($cart): ?string
    {
        foreach ($cart->items as $item) {
            if ($message = $this->violation($item->additional ?? [], (int) $item->quantity, (float) $item->base_price)) {
                return $message;
            }
        }

        return null;
    }

    /**
     * Reject an order whose quoted lines differ from what was negotiated.
     *
     * @throws QuoteLockedException
     */
    public function assertOrder(array $data): void
    {
        foreach ($data['items'] ?? [] as $item) {
            $message = $this->violation(
                $item['additional'] ?? [],
                (int) $item['qty_ordered'],
                (float) $item['base_price'],
                $data['customer_id'] ?? null
            );

            if ($message) {
                throw new QuoteLockedException($message);
            }
        }
    }

    /**
     * Whether a cart line was created from a quote.
     */
    public function isLocked($item): bool
    {
        return ! empty($item->additional['quote_item_id']);
    }

    /**
     * Compare a line against its quote and describe the first difference found.
     */
    protected function violation(array $additional, int $qty, float $basePrice, ?int $customerId = null): ?string
    {
        if (empty($additional['quote_item_id'])) {
            return null;
        }

        $quoteItem = $this->customerQuoteItemRepository->find($additional['quote_item_id']);

        if (
            ! $quoteItem
            || (int) $quoteItem->customer_quote_id !== (int) ($additional['quote_id'] ?? 0)
            || $quoteItem->quote->status !== CustomerQuote::STATUS_ACCEPTED
        ) {
            return trans('This line refers to a quote that is not accepted. Remove it from the cart.');
        }

        if (
            $customerId
            && ! $this->belongsToBuyer($quoteItem->quote, $customerId)
        ) {
            return trans('This line refers to a quote from another account. Remove it from the cart.');
        }

        if (
            $qty !== (int) $quoteItem->negotiated_qty
            || abs($basePrice - (float) $quoteItem->base_negotiated_price) > self::PRICE_TOLERANCE
        ) {
            return trans('Quantity and price of :name are locked by the accepted quote.', [
                'name' => $quoteItem->name,
            ]);
        }

        return null;
    }

    /**
     * Whether the customer is the quote's requester or belongs to its company.
     */
    protected function belongsToBuyer($quote, int $customerId): bool
    {
        return (int) $quote->customer_id === $customerId
            || (int) $quote->company_id === $customerId
            || $quote->company?->members?->contains('id', $customerId);
    }
}
