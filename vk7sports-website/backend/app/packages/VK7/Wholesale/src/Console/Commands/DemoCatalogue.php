<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Webkul\Attribute\Repositories\AttributeOptionRepository;
use Webkul\Attribute\Repositories\AttributeRepository;
use Webkul\Inventory\Repositories\InventorySourceRepository;
use Webkul\Product\Repositories\ProductRepository;

class DemoCatalogue extends Command
{
    /**
     * Sample styles built from the supplied product photos. Names, codes, prices and stock are placeholders.
     */
    public const STYLES = [
        ['sku' => 'VK7-TEE-01', 'name' => 'Performance Crew Tee', 'category' => 'T-Shirts', 'price' => 285, 'sizes' => ['S', 'M', 'L', 'XL', 'XXL'], 'summary' => 'Lightweight crew-neck training tee in a wide colour range.', 'colours' => [
            'Sky Blue' => ['#BBD9F1', ['tee-sky-front', 'tee-sky-back', 'tee-sky-model']],
            'Mint Green' => ['#BFE5BE', ['tee-mint-front', 'tee-mint-back', 'tee-mint-side', 'tee-mint-model']],
            'Aqua' => ['#B6EADD', ['tee-aqua-front', 'tee-aqua-flat']],
            'Lemon' => ['#F4EDA8', ['tee-lemon-model', 'tee-lemon-back']],
            'Lavender' => ['#C5B8F0', ['tee-lavender-model']],
            'Steel Blue' => ['#5F7FA6', ['tee-steel-action']],
            'Black' => ['#1F1F1F', ['tee-black-back']],
        ]],
        ['sku' => 'VK7-SNG-01', 'name' => 'Laser-Cut Training Singlet', 'category' => 'Singlets', 'price' => 265, 'sizes' => ['S', 'M', 'L', 'XL', 'XXL'], 'summary' => 'Racer-back singlet with laser-cut ventilation.', 'colours' => [
            'Violet' => ['#7A6AD8', ['singlet-violet-front', 'singlet-violet-back', 'singlet-violet-pair', 'singlet-violet-detail']],
            'White' => ['#FFFFFF', ['singlet-white-front', 'singlet-white-back']],
        ]],
        ['sku' => 'VK7-JKT-01', 'name' => 'Hooded Training Jacket', 'category' => 'Jackets', 'price' => 690, 'sizes' => ['S', 'M', 'L', 'XL'], 'summary' => 'Light full-zip hooded jacket with side pockets.', 'colours' => [
            'Coral' => ['#F08A6C', ['jacket-coral-front', 'jacket-coral-side', 'jacket-coral-full', 'jacket-coral-detail']],
        ]],
        ['sku' => 'VK7-CRG-01', 'name' => 'Utility Cargo Pants', 'category' => 'Pants', 'price' => 620, 'sizes' => ['M', 'L', 'XL', 'XXL'], 'summary' => 'Relaxed cargo pants with zip and flap pockets.', 'colours' => [
            'Charcoal' => ['#2D3543', ['cargo-charcoal-full', 'cargo-charcoal-logo', 'cargo-charcoal-zip', 'cargo-charcoal-pocket']],
            'Ash Grey' => ['#CFD2D4', ['cargo-ash-logo', 'cargo-ash-waist']],
        ]],
        ['sku' => 'VK7-LST-01', 'name' => 'Long-Sleeve Training Top', 'category' => 'Long-Sleeve Tops', 'price' => 340, 'sizes' => ['S', 'M', 'L'], 'summary' => 'Fitted long-sleeve top for training and warm-up.', 'colours' => [
            'Sage Grey' => ['#B9C6BE', ['longsleeve-sage-back']],
        ]],
    ];

    /**
     * Sample stock per size and colour.
     */
    public const STOCK = 120;

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:demo-catalogue {--images= : Folder holding the product photos}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create the sample VK7 catalogue from the supplied photos, for development';

    /**
     * Create a new command instance.
     */
    public function __construct(
        protected ProductRepository $productRepository,
        protected AttributeRepository $attributeRepository,
        protected AttributeOptionRepository $attributeOptionRepository,
        protected InventorySourceRepository $inventorySourceRepository,
        protected DemoData $demoData,
    ) {
        parent::__construct();
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        if (app()->isProduction()) {
            $this->components->error('Sample data is not allowed in production.');

            return self::FAILURE;
        }

        $images = $this->option('images') ?: base_path('../../frontend/assets/img/products');

        if (! File::isDirectory($images)) {
            $this->components->error('Photo folder not found: '.$images);

            return self::FAILURE;
        }

        foreach (self::STYLES as $style) {
            if (! $this->productRepository->findOneByField('sku', $style['sku'])) {
                $this->createStyle($style, $images);
            }

            $this->components->task($style['sku']);
        }

        return self::SUCCESS;
    }

    /**
     * Create a configurable style with a variant for each colour and size, and its photos.
     */
    protected function createStyle(array $style, string $images): void
    {
        $colours = collect(array_keys($style['colours']))->mapWithKeys(fn ($name) => [$name => $this->optionId('color', $name, $style['colours'][$name][0])]);

        $sizes = collect($style['sizes'])->mapWithKeys(fn ($name) => [$name => $this->optionId('size', $name)]);

        $channel = core()->getDefaultChannel();

        $sourceId = $this->inventorySourceRepository->first()->id;

        $product = $this->productRepository->create([
            'type' => 'configurable',
            'attribute_family_id' => 1,
            'sku' => $style['sku'],
            'super_attributes' => ['color' => $colours->values()->all(), 'size' => $sizes->values()->all()],
        ]);

        $variants = [];

        foreach ($product->variants()->get() as $variant) {
            $variants[$variant->id] = [
                'sku' => $variant->sku,
                'name' => $style['name'].' '.$variant->sku,
                'price' => $style['price'],
                'weight' => 0.3,
                'status' => 1,
                'color' => $variant->color,
                'size' => $variant->size,
                'inventories' => [$sourceId => self::STOCK],
            ];
        }

        $this->productRepository->update([
            'channel' => $channel->code,
            'locale' => core()->getDefaultLocaleCodeFromDefaultChannel(),
            'sku' => $style['sku'],
            'name' => $style['name'],
            'url_key' => strtolower($style['sku']),
            'short_description' => $style['summary'],
            'description' => $style['summary'],
            'status' => 1,
            'visible_individually' => 1,
            'new' => 1,
            'featured' => 1,
            'guest_checkout' => 0,
            'manage_stock' => 1,
            'weight' => 0.3,
            'channels' => [$channel->id],
            'categories' => [$this->demoData->findOrCreateCategory($style['category'])],
            'variants' => $variants,
        ], $product->id);

        $fresh = $product->fresh();

        foreach ($style['colours'] as $name => [, $photos]) {
            $paths = $this->storePhotos($fresh->id, $photos, $images);

            $this->attachPhotos($fresh, $paths);

            foreach ($fresh->variants()->get()->where('color', $colours[$name]) as $variant) {
                $this->attachPhotos($variant, $paths);
            }
        }

        Event::dispatch('catalog.product.update.after', $product->fresh());
    }

    /**
     * Find an attribute option by label, creating it when missing.
     */
    protected function optionId(string $code, string $label, ?string $swatch = null): int
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
     * Copy photos into public product storage.
     */
    protected function storePhotos(int $productId, array $photos, string $folder): array
    {
        return collect($photos)->map(function ($photo) use ($productId, $folder) {
            $path = 'product/'.$productId.'/'.$photo.'.jpg';

            Storage::disk('public')->put($path, File::get($folder.DIRECTORY_SEPARATOR.$photo.'.jpg'));

            return $path;
        })->all();
    }

    /**
     * Link stored photos to a product or variant.
     */
    protected function attachPhotos($product, array $paths): void
    {
        foreach ($paths as $position => $path) {
            DB::table('product_images')->insert([
                'type' => 'images',
                'path' => $path,
                'product_id' => $product->id,
                'position' => $position,
            ]);
        }
    }
}
