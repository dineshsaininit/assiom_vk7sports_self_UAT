<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Webkul\Category\Repositories\CategoryRepository;
use Webkul\Product\Repositories\ProductRepository;

class CatalogController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected ProductRepository $productRepository,
        protected CategoryRepository $categoryRepository,
    ) {}

    /**
     * Return the settings the frontend shapes its screens around.
     */
    public function meta(): JsonResponse
    {
        return response()->json(['data' => [
            'moq' => [
                'enabled' => (bool) core()->getConfigData('vk7.moq.settings.enabled'),
                'min_qty' => (int) core()->getConfigData('vk7.moq.settings.min_qty'),
                'mode' => core()->getConfigData('vk7.moq.settings.mode') ?: 'per_style',
            ],
            'payments' => [
                'advance_percent' => (float) (core()->getConfigData('vk7.payments.terms.advance_percent') ?: 10),
                'hold_hours' => (int) (core()->getConfigData('vk7.payments.terms.hold_hours') ?: 48),
                'gateway' => config('vk7.payments.gateway'),
            ],
            'prices_visible' => $this->canSeePrices(),
            'currency' => core()->getBaseCurrencyCode(),
            'enquiry_types' => EnquiryController::TYPES,
        ]]);
    }

    /**
     * Return the category tree.
     */
    public function categories(): JsonResponse
    {
        $tree = $this->categoryRepository->getVisibleCategoryTree(core()->getCurrentChannel()->root_category_id);

        return response()->json(['data' => $tree->map(fn ($category) => $this->category($category))->values()]);
    }

    /**
     * List products with search, category and attribute filters.
     */
    public function products(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:255'],
            'category_id' => ['nullable', 'integer'],
            'color' => ['nullable', 'string'],
            'size' => ['nullable', 'string'],
            'sort' => ['nullable', 'string', 'max:50'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
            'page' => ['nullable', 'integer', 'min:1'],
            'include_grid' => ['nullable', 'boolean'],
        ]);

        $params = array_filter([
            'name' => $filters['q'] ?? null,
            'category_id' => $filters['category_id'] ?? null,
            'color' => $filters['color'] ?? null,
            'size' => $filters['size'] ?? null,
            'sort' => $filters['sort'] ?? null,
            'limit' => $filters['limit'] ?? 12,
            'channel_id' => core()->getCurrentChannel()->id,
            'status' => 1,
            'visible_individually' => 1,
        ]);

        $products = $this->productRepository->getAll($params);

        return response()->json([
            'data' => collect($products->items())->map(fn ($product) => $request->boolean('include_grid')
                ? array_merge($this->card($product), ['grid' => $this->grid($product)])
                : $this->card($product))->values(),
            'meta' => [
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
                'per_page' => $products->perPage(),
                'total' => $products->total(),
            ],
        ]);
    }

    /**
     * Return one product with its size and colour grid, by id or URL key.
     */
    public function product(string $product): JsonResponse
    {
        $model = ctype_digit($product)
            ? $this->productRepository->find($product)
            : $this->productRepository->findBySlug($product);

        if (
            ! $model
            || $model->parent_id
            || ! $model->status
            || ! $model->visible_individually
            || ! $this->isVisibleToCaller($model)
        ) {
            return $this->fail(trans('Product not found.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => array_merge($this->card($model), [
            'description' => $model->description,
            'images' => $model->images->map(fn ($image) => $image->url)->values(),
            'grid' => $this->grid($model),
        ])]);
    }

    /**
     * Whether the caller's company catalog includes the product.
     */
    protected function isVisibleToCaller($product): bool
    {
        return ! method_exists($this->productRepository, 'isVisible')
            || $this->productRepository->isVisible($product);
    }

    /**
     * Shape a category and its children.
     */
    protected function category($category): array
    {
        return [
            'id' => $category->id,
            'name' => $category->name,
            'slug' => $category->slug,
            'children' => $category->children->map(fn ($child) => $this->category($child))->values(),
        ];
    }

    /**
     * Shape a product for listing screens, leaving prices out for callers who may not see them.
     */
    protected function card($product): array
    {
        return [
            'id' => $product->id,
            'sku' => $product->sku,
            'name' => $product->name,
            'url_key' => $product->url_key,
            'type' => $product->type,
            'short_description' => $product->short_description,
            'categories' => $product->categories->map(fn ($category) => $category->slug)->values(),
            'base_image' => $product->images->first()?->url,
            'in_stock' => $product->getTypeInstance()->isSaleable(),
            'prices' => $this->prices($product),
        ];
    }

    /**
     * Shape the size and colour grid; stock counts go to signed-in retailers only.
     */
    protected function grid($product): ?array
    {
        if ($product->type !== 'configurable') {
            return null;
        }

        $attributes = $product->super_attributes;

        return [
            'attributes' => $attributes->map(fn ($attribute) => [
                'code' => $attribute->code,
                'label' => $attribute->admin_name,
                'options' => $attribute->options
                    ->whereIn('id', $product->variants->pluck($attribute->code)->unique())
                    ->map(fn ($option) => ['id' => $option->id, 'label' => $option->admin_name, 'swatch' => $option->swatch_value])
                    ->values(),
            ])->values(),
            'variants' => $product->variants->map(fn ($variant) => [
                'id' => $variant->id,
                'sku' => $variant->sku,
                'options' => $attributes->mapWithKeys(fn ($attribute) => [$attribute->code => $variant->{$attribute->code}]),
                'images' => $variant->images->map(fn ($image) => $image->url)->values(),
                'in_stock' => $variant->getTypeInstance()->isSaleable(),
                'stock' => $this->customer() ? (int) $variant->getTypeInstance()->totalQuantity() : null,
                'prices' => $this->prices($variant),
            ])->values(),
        ];
    }

    /**
     * Return prices only when the caller may see them.
     */
    protected function prices($product): ?array
    {
        return $this->canSeePrices()
            ? $product->getTypeInstance()->getProductPrices()
            : null;
    }
}
