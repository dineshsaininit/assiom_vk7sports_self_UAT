<?php

namespace VK7\Wholesale\Repositories;

use Webkul\B2BSuite\Repositories\CustomerQuoteRepository as BaseCustomerQuoteRepository;
use Webkul\Checkout\Facades\Cart;

class CustomerQuoteRepository extends BaseCustomerQuoteRepository
{
    /**
     * Move a quote into the cart, replacing only the cart line of the same variant, so a quote holding
     * several sizes or colours of one style keeps every line (the base version kept only the last).
     */
    public function updateCart($id)
    {
        $quote = $this->find($id);

        $cart = Cart::getCart();

        if (! $cart) {
            $cart = $this->cartRepository->create([
                'company_id' => $quote?->customer?->company_id ?? null,
                'is_guest' => 1,
                'channel_id' => core()->getCurrentChannel()->id,
                'global_currency_code' => $baseCurrencyCode = core()->getBaseCurrencyCode(),
                'base_currency_code' => $baseCurrencyCode,
                'channel_currency_code' => core()->getChannelBaseCurrencyCode(),
                'cart_currency_code' => core()->getCurrentCurrencyCode(),
            ]);
        }

        foreach ($quote->items as $quoteItem) {
            $product = $this->productRepository->find($quoteItem->product_id);

            $additional = $quoteItem->additional ? json_decode($quoteItem->additional, true) : [];

            $existingCartItem = $cart->items
                ->where('product_id', $product->id)
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

            foreach ($cart->items->where('product_id', $product->id) as $cartItem) {
                if (
                    ($cartItem->additional['quote_id'] ?? null) == $quote->id
                    && ($cartItem->additional['quote_item_id'] ?? null) == $quoteItem->id
                ) {
                    $cartItem->custom_price = $quoteItem->base_negotiated_price;
                    $cartItem->save();
                }
            }

            Cart::collectTotals();
        }
    }
}
