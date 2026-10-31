<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use VK7\Wholesale\Moq;
use VK7\Wholesale\QuoteLock;
use Webkul\Checkout\Facades\Cart;
use Webkul\Product\Repositories\ProductRepository;

class CartController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected ProductRepository $productRepository,
        protected Moq $moq,
        protected QuoteLock $quoteLock,
    ) {}

    /**
     * Check grid lines against the minimum and stock without saving anything.
     */
    public function check(Request $request): JsonResponse
    {
        $lines = $this->resolveLines($request);

        if ($lines instanceof JsonResponse) {
            return $lines;
        }

        $shortages = $lines
            ->filter(fn ($line) => ! $line['stock_item']->haveSufficientQuantity($line['qty']))
            ->map(fn ($line) => [
                'product_id' => $line['product']->id,
                'variant_id' => $line['variant']?->id,
                'sku' => $line['stock_item']->sku,
                'requested' => $line['qty'],
                'available' => (int) $line['stock_item']->getTypeInstance()->totalQuantity(),
            ])
            ->values();

        return response()->json(['data' => [
            'moq' => $this->moq->evaluate($lines->map(fn ($line) => [
                'style' => $line['product']->id,
                'variant' => $line['stock_item']->sku,
                'name' => $line['product']->name,
                'qty' => $line['qty'],
            ])),
            'stock_ok' => $shortages->isEmpty(),
            'shortages' => $shortages,
        ]]);
    }

    /**
     * Return the cart with its totals and rule checks.
     */
    public function show(): JsonResponse
    {
        return response()->json(['data' => $this->present()]);
    }

    /**
     * Add grid lines to the cart, all of them or none.
     */
    public function store(Request $request): JsonResponse
    {
        $lines = $this->resolveLines($request);

        if ($lines instanceof JsonResponse) {
            return $lines;
        }

        try {
            DB::transaction(fn () => $this->addLines($lines));
        } catch (\Throwable $e) {
            Cart::initCart($this->customer());

            return $this->fail($e->getMessage(), 'CART_REJECTED');
        }

        return response()->json(['data' => $this->present()], 201);
    }

    /**
     * Replace every line of one style with the grid's quantities, all of them or none.
     */
    public function replaceStyle(Request $request, int $productId): JsonResponse
    {
        $data = $request->validate([
            'lines' => ['present', 'array', 'max:500'],
            'lines.*.variant_id' => ['nullable', 'integer'],
            'lines.*.qty' => ['required', 'integer', 'min:1', 'max:100000'],
        ]);

        $request->merge(['lines' => array_map(fn ($line) => array_merge($line, ['product_id' => $productId]), $data['lines'])]);

        $lines = $data['lines'] ? $this->resolveLines($request) : collect();

        if ($lines instanceof JsonResponse) {
            return $lines;
        }

        $existing = Cart::getCart()?->items()->where('product_id', $productId)->whereNull('parent_id')->get() ?? collect();

        if ($existing->contains(fn ($item) => $this->quoteLock->isLocked($item))) {
            return $this->fail(trans('Quantity is locked by the accepted quote.'), 'QUOTE_LOCKED');
        }

        try {
            DB::transaction(function () use ($existing, $lines) {
                foreach ($existing as $item) {
                    Cart::removeItem($item->id);
                }

                $this->addLines($lines);

                Cart::getCart() && Cart::collectTotals();
            });
        } catch (\Throwable $e) {
            Cart::initCart($this->customer());

            return $this->fail($e->getMessage(), 'CART_REJECTED');
        }

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Change the quantity of a line that did not come from a quote.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['qty' => ['required', 'integer', 'min:1', 'max:100000']]);

        $item = $this->ownLine($id);

        if (! $item) {
            return $this->fail(trans('Cart line not found.'), 'NOT_FOUND', 404);
        }

        if ($this->quoteLock->isLocked($item)) {
            return $this->fail(trans('Quantity is locked by the accepted quote.'), 'QUOTE_LOCKED');
        }

        try {
            Cart::updateItems(['qty' => [$id => $data['qty']]]);
        } catch (\Throwable $e) {
            return $this->fail($e->getMessage(), 'CART_REJECTED');
        }

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Remove a line from the cart.
     */
    public function destroy(int $id): JsonResponse
    {
        if (! $this->ownLine($id)) {
            return $this->fail(trans('Cart line not found.'), 'NOT_FOUND', 404);
        }

        Cart::removeItem($id);

        Cart::collectTotals();

        return response()->json(['data' => $this->present()]);
    }

    /**
     * Validate grid lines and load the products they refer to.
     */
    protected function resolveLines(Request $request)
    {
        $data = $request->validate([
            'lines' => ['required', 'array', 'min:1', 'max:500'],
            'lines.*.product_id' => ['required', 'integer'],
            'lines.*.variant_id' => ['nullable', 'integer'],
            'lines.*.qty' => ['required', 'integer', 'min:1', 'max:100000'],
        ]);

        $lines = collect();

        foreach ($data['lines'] as $line) {
            $product = $this->productRepository->find($line['product_id']);

            $variant = ! empty($line['variant_id']) ? $product?->variants->firstWhere('id', $line['variant_id']) : null;

            if (
                ! $product
                || $product->parent_id
                || ! $product->status
                || ($product->type === 'configurable' && ! $variant)
                || (method_exists($this->productRepository, 'isVisible') && ! $this->productRepository->isVisible($product))
            ) {
                return $this->fail(trans('A selected product or variant is not available.'), 'INVALID_LINE', 422, ['line' => $line]);
            }

            $lines->push([
                'product' => $product,
                'variant' => $variant,
                'stock_item' => $variant ?? $product,
                'qty' => (int) $line['qty'],
            ]);
        }

        return $lines;
    }

    /**
     * Add resolved lines to the cart.
     */
    protected function addLines($lines): void
    {
        foreach ($lines as $line) {
            Cart::addProduct($line['product'], array_filter([
                'product_id' => $line['product']->id,
                'quantity' => $line['qty'],
                'selected_configurable_option' => $line['variant']?->id,
                'super_attribute' => $line['variant'] ? $this->superAttributes($line['product'], $line['variant']) : null,
            ]));
        }
    }

    /**
     * Map a variant to the option ids the core cart expects.
     */
    protected function superAttributes($product, $variant): array
    {
        return $product->super_attributes
            ->mapWithKeys(fn ($attribute) => [$attribute->id => $variant->{$attribute->code}])
            ->all();
    }

    /**
     * Find a cart line belonging to this retailer's cart.
     */
    protected function ownLine(int $id)
    {
        return Cart::getCart()?->items()->where('id', $id)->whereNull('parent_id')->first();
    }

    /**
     * Shape the cart for the frontend.
     */
    protected function present(): ?array
    {
        Cart::refreshCart();

        $cart = Cart::getCart();

        if (! $cart) {
            return null;
        }

        return [
            'id' => $cart->id,
            'items_qty' => (int) $cart->items_qty,
            'sub_total' => (float) $cart->base_sub_total,
            'tax_total' => (float) $cart->base_tax_total,
            'shipping_total' => (float) $cart->selected_shipping_rate?->base_price,
            'grand_total' => (float) $cart->base_grand_total,
            'currency' => $cart->cart_currency_code,
            'items' => $cart->items->map(fn ($item) => [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'variant_id' => $item->child?->product_id,
                'sku' => $item->child?->sku ?? $item->sku,
                'name' => $item->name,
                'options' => $item->additional['attributes'] ?? [],
                'qty' => (int) $item->quantity,
                'price' => (float) $item->base_price,
                'total' => (float) $item->base_total,
                'locked_by_quote' => $this->quoteLock->isLocked($item),
                'url_key' => $item->product?->url_key,
                'image' => $item->product?->images->first()?->url,
                'available' => (int) ($item->child?->product ?? $item->product)?->getTypeInstance()->totalQuantity(),
            ])->values(),
            'moq' => $this->moq->evaluate($this->moq->cartLines($cart)),
            'error' => Cart::hasError() ? Cart::getErrors() : null,
        ];
    }
}
