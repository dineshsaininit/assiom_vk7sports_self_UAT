<?php

namespace VK7\Wholesale\Repositories;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Exceptions\MoqNotMetException;
use VK7\Wholesale\Moq;
use VK7\Wholesale\Sequence;
use Webkul\B2BSuite\Contracts\CustomerQuote;
use Webkul\B2BSuite\Repositories\CustomerQuoteRepository as BaseCustomerQuoteRepository;
use Webkul\Checkout\Facades\Cart;

class CustomerQuoteRepository extends BaseCustomerQuoteRepository
{
    /**
     * Seconds a cart stays locked while a quote is created from it.
     */
    public const CREATE_LOCK_SECONDS = 30;

    /**
     * Create a quote from a cart once, rejecting carts below the minimum order quantity.
     *
     * @throws MoqNotMetException
     */
    public function create(array $data): CustomerQuote
    {
        $cart = $data['cart'] ?? Cart::getCart();

        if ($message = app(Moq::class)->cartViolation($cart)) {
            throw new MoqNotMetException($message);
        }

        return Cache::lock('vk7-quote-cart-'.$cart->id, self::CREATE_LOCK_SECONDS)->block(
            self::CREATE_LOCK_SECONDS,
            function () use ($data, $cart) {
                if (! $this->cartRepository->find($cart->id)) {
                    return $this->model->where('customer_id', $data['customer_id'])->latest('id')->firstOrFail();
                }

                return parent::create(array_merge($data, ['cart' => $cart]));
            }
        );
    }

    /**
     * Generate quotation and purchase order numbers from a locked counter, so they never repeat.
     *
     * @param  int|null  $quoteId
     */
    public function generateQuotationNumber($quoteId): array
    {
        return parent::generateQuotationNumber($quoteId ?? app(Sequence::class)->next('quote', 'b2b_customer_quotes'));
    }

    /**
     * Move a quote into the cart atomically, replacing only the cart line of the same variant, so a
     * quote holding several sizes or colours of one style keeps every line.
     */
    public function updateCart($id)
    {
        try {
            DB::transaction(fn () => $this->moveToCart($this->find($id)));
        } catch (\Throwable $e) {
            Cart::initCart(auth()->guard('customer')->user());

            throw $e;
        }
    }

    /**
     * Add each quoted line to the cart at its negotiated quantity and price.
     */
    protected function moveToCart($quote): void
    {
        foreach ($quote->items as $quoteItem) {
            $product = $this->productRepository->find($quoteItem->product_id);

            $additional = $quoteItem->additional ? json_decode($quoteItem->additional, true) : [];

            $existingCartItem = Cart::getCart()?->items()
                ->where('product_id', $product->id)
                ->whereNull('parent_id')
                ->get()
                ->first(fn ($item) => ($item->additional['selected_configurable_option'] ?? null) == ($additional['selected_configurable_option'] ?? null));

            if ($existingCartItem) {
                Cart::removeItem($existingCartItem->id);
            }

            $cart = Cart::addProduct($product, array_merge($additional, [
                'product_id' => $product->id,
                'quantity' => $quoteItem->negotiated_qty,
                'quote_id' => $quote->id,
                'quote_item_id' => $quoteItem->id,
            ]));

            foreach ($cart->items()->where('product_id', $product->id)->get() as $cartItem) {
                if (
                    ($cartItem->additional['quote_id'] ?? null) == $quote->id
                    && ($cartItem->additional['quote_item_id'] ?? null) == $quoteItem->id
                ) {
                    $cartItem->custom_price = $quoteItem->base_negotiated_price;
                    $cartItem->save();
                }
            }

            Cart::refreshCart();

            Cart::collectTotals();
        }
    }
}
