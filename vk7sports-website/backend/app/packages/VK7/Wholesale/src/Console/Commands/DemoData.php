<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Event;
use Webkul\Attribute\Repositories\AttributeRepository;
use Webkul\Category\Repositories\CategoryRepository;
use Webkul\Inventory\Repositories\InventorySourceRepository;
use Webkul\Product\Repositories\ProductRepository;

class DemoData extends Command
{
    /**
     * Fictional garment categories and the style placed in each.
     */
    public const STYLES = [
        ['category' => 'Jerseys', 'sku' => 'TEST-STYLE-01', 'name' => 'TEST Training Jersey', 'price' => 500],
        ['category' => 'Track Pants', 'sku' => 'TEST-STYLE-02', 'name' => 'TEST Track Pant', 'price' => 700],
        ['category' => 'Shorts', 'sku' => 'TEST-STYLE-03', 'name' => 'TEST Match Short', 'price' => 400],
        ['category' => 'T-Shirts', 'sku' => 'TEST-STYLE-04', 'name' => 'TEST Practice Tee', 'price' => 300],
    ];

    /**
     * Units of stock given to each fictional variant.
     */
    public const VARIANT_STOCK = 50;

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:demo-data';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create fictional DEMO products with size and colour variants for development';

    /**
     * Create a new command instance.
     */
    public function __construct(
        protected ProductRepository $productRepository,
        protected CategoryRepository $categoryRepository,
        protected AttributeRepository $attributeRepository,
        protected InventorySourceRepository $inventorySourceRepository,
    ) {
        parent::__construct();
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        if (app()->isProduction()) {
            $this->components->error('Demo data is not allowed in production.');

            return self::FAILURE;
        }

        foreach (self::STYLES as $style) {
            if ($this->productRepository->findOneByField('sku', $style['sku'])) {
                continue;
            }

            $this->createStyle($style, $this->findOrCreateCategory($style['category']));

            $this->components->task($style['sku']);
        }

        return self::SUCCESS;
    }

    /**
     * Create a configurable style with a variant for each colour and size.
     */
    protected function createStyle(array $style, int $categoryId): void
    {
        $locale = core()->getDefaultLocaleCodeFromDefaultChannel();

        $channel = core()->getDefaultChannel();

        $sourceId = $this->inventorySourceRepository->first()->id;

        $colors = $this->attributeRepository->findOneByField('code', 'color')->options->take(2);

        $sizes = $this->attributeRepository->findOneByField('code', 'size')->options->take(4);

        $product = $this->productRepository->create([
            'type' => 'configurable',
            'attribute_family_id' => 1,
            'sku' => $style['sku'],
            'super_attributes' => [
                'color' => $colors->pluck('id')->all(),
                'size' => $sizes->pluck('id')->all(),
            ],
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
                'inventories' => [$sourceId => self::VARIANT_STOCK],
            ];
        }

        $this->productRepository->update([
            'channel' => $channel->code,
            'locale' => $locale,
            'sku' => $style['sku'],
            'name' => $style['name'],
            'url_key' => strtolower($style['sku']),
            'short_description' => 'Fictional DEMO product. Not a real VK7SPORTS item.',
            'description' => 'Fictional DEMO product. Not a real VK7SPORTS item.',
            'status' => 1,
            'visible_individually' => 1,
            'new' => 1,
            'featured' => 1,
            'guest_checkout' => 0,
            'manage_stock' => 1,
            'weight' => 0.3,
            'channels' => [$channel->id],
            'categories' => [$categoryId],
            'variants' => $variants,
        ], $product->id);

        Event::dispatch('catalog.product.update.after', $product->fresh());
    }

    /**
     * Find a demo category under the channel root, creating it when missing.
     */
    public function findOrCreateCategory(string $name): int
    {
        $locale = core()->getDefaultLocaleCodeFromDefaultChannel();

        $slug = strtolower(str_replace(' ', '-', $name));

        $existing = $this->categoryRepository->findBySlug($slug);

        if ($existing) {
            return $existing->id;
        }

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
}
