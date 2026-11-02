<?php

namespace VK7\Wholesale\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\StockLog;
use Webkul\Attribute\Repositories\AttributeOptionRepository;
use Webkul\Attribute\Repositories\AttributeRepository;
use Webkul\Category\Repositories\CategoryRepository;
use Webkul\Inventory\Repositories\InventorySourceRepository;
use Webkul\Product\Models\ProductProxy;
use Webkul\Product\Repositories\ProductRepository;

class CatalogueDesk
{
    /**
     * Create a new service instance.
     */
    public function __construct(
        protected ProductRepository $productRepository,
        protected CategoryRepository $categoryRepository,
        protected AttributeRepository $attributeRepository,
        protected AttributeOptionRepository $attributeOptionRepository,
        protected InventorySourceRepository $inventorySourceRepository,
        protected ActivityRecorder $activity,
    ) {}

    /**
     * List every style.
     */
    public function styles()
    {
        return ProductProxy::query()->whereNull('parent_id')->orderBy('id', 'desc')->get()->map(fn ($product) => $this->style($product));
    }

    /**
     * Return one style for editing.
     */
    public function find(int $id): array
    {
        $product = $this->product($id);

        return array_merge($this->style($product), [
            'description' => $product->description,
            'summary' => $product->short_description,
            'category_id' => $product->categories->first()?->id,
        ]);
    }

    /**
     * List categories under the store's root.
     */
    public function categories()
    {
        return $this->categoryRepository
            ->getVisibleCategoryTree(core()->getDefaultChannel()->root_category_id)
            ->map(fn ($category) => ['id' => $category->id, 'name' => $category->name])
            ->values();
    }

    /**
     * Find a category by name, creating it when new.
     */
    public function categoryId(string $name): int
    {
        $slug = Str::slug($name);

        $existing = $this->categoryRepository->findBySlug($slug);

        if ($existing) {
            return $existing->id;
        }

        $locale = core()->getDefaultLocaleCodeFromDefaultChannel();

        return $this->categoryRepository->create([
            'locale' => 'all',
            'name' => $name,
            'slug' => $slug,
            'description' => $name,
            'status' => 1,
            'position' => 1,
            'display_mode' => 'products_only',
            'parent_id' => core()->getDefaultChannel()->root_category_id,
            'attributes' => [],
            $locale => ['name' => $name, 'slug' => $slug, 'description' => $name],
        ])->id;
    }

    /**
     * Create a style with one variant for each colour and size.
     */
    public function create(array $data, string $actor): int
    {
        if ($this->productRepository->findOneByField('sku', $data['style'])) {
            throw new BusinessRuleException(trans('That style code is already in use.'), 'DUPLICATE_STYLE');
        }

        $id = DB::transaction(function () use ($data) {
            $colours = $this->colourOptions($data['colours']);

            $sizes = $this->sizeOptions($data['sizes']);

            $product = $this->productRepository->create([
                'type' => 'configurable',
                'attribute_family_id' => 1,
                'sku' => $data['style'],
                'super_attributes' => ['color' => array_values($colours), 'size' => array_values($sizes)],
            ]);

            $this->save($product, $data, (int) ($data['stock'] ?? 0));

            return $product->id;
        });

        $this->activity->record($actor, 'Added product', $data['name'], $data['style']);

        return $id;
    }

    /**
     * Update a style's details and price, adding any new colours and sizes.
     */
    public function update(int $id, array $data, string $actor): void
    {
        $product = $this->product($id);

        DB::transaction(function () use ($product, $data) {
            $this->save($product, $data, null);

            foreach ($this->newVariants($product, $data) as $variant) {
                $this->save($product->fresh(), $data, null, ['variant_0' => $variant]);
            }
        });

        $this->activity->record($actor, 'Updated product', $data['name'], $product->sku);
    }

    /**
     * Store uploaded photos for one colour of a style.
     */
    public function addPhotos(int $id, string $colour, array $files, string $actor): void
    {
        $product = $this->product($id);

        $optionId = $this->attributeRepository->findOneByField('code', 'color')->options()->where('admin_name', $colour)->value('id');

        $variants = $product->variants()->get()->where('color', $optionId);

        if ($variants->isEmpty()) {
            throw new BusinessRuleException(trans('That colour is not on this style.'), 'UNKNOWN_COLOUR');
        }

        foreach ($files as $file) {
            $path = $this->storePhoto($product->id, $file);

            $this->attachPhoto($product->id, $path);

            foreach ($variants as $variant) {
                $this->attachPhoto($variant->id, $path);
            }
        }

        Event::dispatch('catalog.product.update.after', $product->fresh());

        $this->activity->record($actor, 'Added product photos', $product->name, $colour);
    }

    /**
     * Remove a photo from a style and all its variants.
     */
    public function removePhoto(int $id, int $imageId, string $actor): void
    {
        $product = $this->product($id);

        $path = DB::table('product_images')->where('id', $imageId)->where('product_id', $product->id)->value('path');

        if (! $path) {
            throw new BusinessRuleException(trans('Photo not found.'), 'NOT_FOUND', 404);
        }

        DB::table('product_images')->where('path', $path)->delete();

        Storage::disk('public')->delete($path);

        Event::dispatch('catalog.product.update.after', $product->fresh());

        $this->activity->record($actor, 'Removed product photo', $product->name);
    }

    /**
     * List stock per size and colour.
     */
    public function inventory()
    {
        return ProductProxy::query()->whereNull('parent_id')->orderBy('id', 'desc')->get()->map(fn ($product) => [
            'id' => $product->id,
            'name' => $product->name,
            'style' => $product->sku,
            'rows' => $product->variants()->get()->map(function ($variant) {
                $onHand = (int) DB::table('product_inventories')->where('product_id', $variant->id)->sum('qty');

                $held = (int) DB::table('product_ordered_inventories')->where('product_id', $variant->id)->sum('qty');

                return [
                    'variant_id' => $variant->id,
                    'colour' => $this->optionLabel('color', $variant->color),
                    'size' => $this->optionLabel('size', $variant->size),
                    'on_hand' => $onHand,
                    'held' => $held,
                    'available' => max(0, $onHand - $held),
                ];
            })->values(),
        ]);
    }

    /**
     * Change stock for one size and colour, keeping the reason.
     */
    public function adjustStock(int $variantId, int $change, string $reason, ?string $note, string $actor): void
    {
        $variant = ProductProxy::query()->whereNotNull('parent_id')->find($variantId);

        if (! $variant) {
            throw new BusinessRuleException(trans('Product not found.'), 'NOT_FOUND', 404);
        }

        $sourceId = $this->inventorySourceRepository->first()->id;

        $held = (int) DB::table('product_ordered_inventories')->where('product_id', $variant->id)->sum('qty');

        DB::transaction(function () use ($variant, $sourceId, $change, $held, $reason, $note, $actor) {
            $row = DB::table('product_inventories')
                ->where('product_id', $variant->id)
                ->where('inventory_source_id', $sourceId)
                ->lockForUpdate()
                ->first();

            $after = (int) ($row->qty ?? 0) + $change;

            if ($after < $held) {
                throw new BusinessRuleException(trans('Stock cannot go below the :held pieces held for orders.', ['held' => $held]), 'STOCK_HELD');
            }

            DB::table('product_inventories')->updateOrInsert(
                ['product_id' => $variant->id, 'inventory_source_id' => $sourceId, 'vendor_id' => 0],
                ['qty' => $after],
            );

            StockLog::create([
                'product_id' => $variant->id,
                'product' => $variant->parent->name,
                'variant' => $this->optionLabel('color', $variant->color).' / '.$this->optionLabel('size', $variant->size),
                'change' => $change,
                'on_hand' => $after,
                'reason' => $reason,
                'note' => $note,
                'actor' => $actor,
            ]);
        });

        Event::dispatch('catalog.product.update.after', $variant->parent);

        $this->activity->record($actor, 'Stock correction', $variant->sku, ($change > 0 ? '+' : '').$change.', '.$reason);
    }

    /**
     * The latest stock corrections.
     */
    public function stockLog()
    {
        return StockLog::query()->latest('id')->limit(200)->get();
    }

    /**
     * The number of sizes at or below the given level, and the lowest of them.
     */
    public function lowStock(int $level): array
    {
        $rows = $this->inventory()->flatMap(fn ($style) => $style['rows']->map(fn ($row) => [
            'product' => $style['name'],
            'variant' => $row['colour'].' / '.$row['size'],
            'available' => $row['available'],
        ]))->where('available', '<=', $level)->sortBy('available')->values();

        return ['count' => $rows->count(), 'rows' => $rows->take(6)->values()];
    }

    /**
     * Find a style or stop.
     */
    protected function product(int $id)
    {
        $product = ProductProxy::query()->whereNull('parent_id')->find($id);

        if (! $product) {
            throw new BusinessRuleException(trans('Product not found.'), 'NOT_FOUND', 404);
        }

        return $product;
    }

    /**
     * Shape a style for the admin screens.
     */
    protected function style($product): array
    {
        $variants = $product->variants()->get();

        $inventory = DB::table('product_inventories')->whereIn('product_id', $variants->pluck('id'))->sum('qty');

        $held = DB::table('product_ordered_inventories')->whereIn('product_id', $variants->pluck('id'))->sum('qty');

        return [
            'id' => $product->id,
            'name' => $product->name,
            'style' => $product->sku,
            'price' => (float) $variants->first()?->price,
            'status' => $product->status ? 'active' : 'hidden',
            'available' => max(0, (int) $inventory - (int) $held),
            'sizes' => $variants->pluck('size')->unique()->map(fn ($id) => $this->optionLabel('size', $id))->values(),
            'colours' => $variants->groupBy('color')->map(fn ($group, $optionId) => [
                'name' => $this->optionLabel('color', $optionId),
                'hex' => $this->attributeOptionRepository->find($optionId)?->swatch_value,
                'images' => $group->first()->images->map(fn ($image) => ['id' => $this->parentImageId($product->id, $image->path), 'url' => $image->url])->values(),
            ])->values(),
        ];
    }

    /**
     * Find the style's copy of a variant's photo.
     */
    protected function parentImageId(int $productId, string $path): ?int
    {
        return DB::table('product_images')->where('product_id', $productId)->where('path', $path)->value('id');
    }

    /**
     * Save a style's details on it and every variant; opening stock applies only to a new style.
     */
    protected function save($product, array $data, ?int $stock, array $newVariants = []): void
    {
        $channel = core()->getDefaultChannel();

        $sourceId = $this->inventorySourceRepository->first()->id;

        $variants = [];

        foreach ($product->variants()->get() as $variant) {
            $variants[$variant->id] = [
                'sku' => $variant->sku,
                'name' => $data['name'].' '.$variant->sku,
                'price' => $data['price'],
                'weight' => (float) ($data['weight'] ?? 0.3),
                'status' => 1,
                'color' => $variant->color,
                'size' => $variant->size,
                'images' => $this->keptImages($variant),
                'inventories' => [$sourceId => $stock ?? (int) DB::table('product_inventories')->where('product_id', $variant->id)->sum('qty')],
            ];
        }

        $slug = Str::slug($product->sku);

        $this->productRepository->update([
            'channel' => $channel->code,
            'locale' => core()->getDefaultLocaleCodeFromDefaultChannel(),
            'sku' => $product->sku,
            'name' => $data['name'],
            'url_key' => $slug,
            'short_description' => ($data['summary'] ?? null) ?: $data['name'],
            'description' => ($data['description'] ?? null) ?: (($data['summary'] ?? null) ?: $data['name']),
            'status' => ($data['status'] ?? 'active') === 'active' ? 1 : 0,
            'visible_individually' => 1,
            'new' => 1,
            'featured' => 1,
            'guest_checkout' => 0,
            'manage_stock' => 1,
            'weight' => (float) ($data['weight'] ?? 0.3),
            'channels' => [$channel->id],
            'categories' => [$data['category_id']],
            'images' => $this->keptImages($product),
            'variants' => $variants + $newVariants,
        ], $product->id);

        Event::dispatch('catalog.product.update.after', $product->fresh());
    }

    /**
     * List a product's photos so Bagisto keeps them; it deletes any photo left out of an update.
     */
    protected function keptImages($product): array
    {
        return ['files' => $product->images()->orderBy('position')->pluck('path', 'id')->all()];
    }

    /**
     * Describe each new colour and size pairing. Bagisto saves one new variant per update correctly.
     */
    protected function newVariants($product, array $data): array
    {
        $existing = $product->variants()->get()->map(fn ($variant) => $variant->color.'-'.$variant->size)->all();

        $sourceId = $this->inventorySourceRepository->first()->id;

        $variants = [];

        foreach ($this->colourOptions($data['colours']) as $colourId) {
            foreach ($this->sizeOptions($data['sizes']) as $sizeId) {
                if (in_array($colourId.'-'.$sizeId, $existing)) {
                    continue;
                }

                $sku = $product->sku.'-variant-'.$colourId.'-'.$sizeId;

                $variants['variant_'.count($variants)] = [
                    'sku' => $sku,
                    'name' => $data['name'].' '.$sku,
                    'price' => $data['price'],
                    'weight' => (float) ($data['weight'] ?? 0.3),
                    'status' => 1,
                    'color' => $colourId,
                    'size' => $sizeId,
                    'inventories' => [$sourceId => 0],
                ];
            }
        }

        return $variants;
    }

    /**
     * Find or create colour options, keeping their swatches.
     */
    protected function colourOptions(array $colours): array
    {
        $ids = [];

        foreach ($colours as $colour) {
            $ids[$colour['name']] = $this->option('color', $colour['name'], $colour['hex'] ?? null);
        }

        return $ids;
    }

    /**
     * Find or create size options.
     */
    protected function sizeOptions(array $sizes): array
    {
        $ids = [];

        foreach ($sizes as $size) {
            $ids[$size] = $this->option('size', $size);
        }

        return $ids;
    }

    /**
     * Find an attribute option by label, creating it when missing.
     */
    protected function option(string $code, string $label, ?string $swatch = null): int
    {
        $attribute = $this->attributeRepository->findOneByField('code', $code);

        $option = $attribute->options()->where('admin_name', $label)->first()
            ?? $this->attributeOptionRepository->create([
                'attribute_id' => $attribute->id,
                'admin_name' => $label,
                'sort_order' => $attribute->options()->count() + 1,
            ]);

        if ($swatch) {
            $option->update(['swatch_value' => $swatch]);
        }

        return $option->id;
    }

    /**
     * The label of an attribute option.
     */
    protected function optionLabel(string $code, $optionId): string
    {
        return (string) $this->attributeOptionRepository->find($optionId)?->admin_name;
    }

    /**
     * Save an uploaded photo under a name of our choosing.
     */
    protected function storePhoto(int $productId, UploadedFile $file): string
    {
        return $file->storeAs('product/'.$productId, Str::random(24).'.'.$file->extension(), 'public');
    }

    /**
     * Link a stored photo to a product.
     */
    protected function attachPhoto(int $productId, string $path): void
    {
        DB::table('product_images')->insert([
            'type' => 'images',
            'path' => $path,
            'product_id' => $productId,
            'position' => (int) DB::table('product_images')->where('product_id', $productId)->max('position') + 1,
        ]);
    }
}
