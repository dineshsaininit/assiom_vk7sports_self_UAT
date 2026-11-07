# Native Product Importer contract

Specification is the source at base commit e745b38ba928b4361fd68a07abc5eecabaf863d7, not a generic Bagisto CSV. Paths below are relative to vk7sports-website.

Primary file: backend/app/packages/Webkul/DataTransfer/src/Helpers/Importers/Product/Importer.php.

| Source section | Verified behavior |
|---|---|
| validColumnNames (~224), constructor (~285) | Fixed import columns plus attribute codes loaded from attributes. The automated source-contract test checks every emitted column against this list and the base export's actual attributes. |
| getValidationRules (~561) | Requires sku/url_key plus editable required family attributes; exact live family rules still require native validation. |
| prepareProducts (~1191) | Inserts or updates products by SKU/type/family. |
| prepareCustomerGroupPrices (~1260) | Splits records on pipe, replaces commas with ampersands and uses parse_str; missing group lookup resolves null. |
| prepareCategories (~1311) | Splits categories on slash and looks up matching translated names independently. Does not create a category hierarchy. |
| prepareChannels (~1379), prepareRowForDb (~2688) | Attaches selected row channel; when channel omitted it defaults to core()->getDefaultChannelCode(). This package omits channel and requires one verified default channel. |
| prepareInventories / saveInventories (~1475) | Comma-separated source=quantity, source looked up by code; unknown source skipped. Submitted quantities overwrite, not increment. |
| prepareImages / validateImages (~1545), resolveImageFile (~1658), saveImages (~1690) | Comma-separated locations; mode is file or URL; local paths resolve under storage/app/import/<images_directory_path>/. Updates can replace old images/files. |
| prepareConfigurableVariants (~1854), saveConfigurableVariants (~1880) | Parent configurable_variants encodes child SKU and super-attribute labels; linking writes child parent_id and EAV option IDs. parent_sku is an accepted column but is not read to establish this relationship in this source. |
| getSuperAttributeOptions (~2594) | findWhereIn('admin_name', optionLabels), then matches attribute ID and label. Requires existing exact options; creates none. |

Supporting source: Product/src/Type/Configurable.php (parent skipAttributes include price/weight/manage_stock), Core/src/Rules/Slug.php (SKU rules), packages/VK7/Wholesale/src/Moq.php (MOQ modes/core_config) and Services/CatalogueDesk.php (style edits can overwrite differing child prices). The first three Webkul paths are under backend/app/packages/Webkul; VK7 paths are under backend/app/packages.

## Emitted columns, in order

```text
sku,parent_sku,locale,attribute_family_code,type,categories,images,name,description,short_description,status,visible_individually,guest_checkout,weight,price,url_key,manage_stock,inventories,configurable_variants,customer_group_prices
```

One configurable parent followed by its simple children. Parent price/weight/inventories/tiers are empty. Child configurable_variants is empty. Parent images are the deduplicated union of its children's images; size charts are excluded. Child name is style name plus colour and size; url_key is lowercase SKU. Unlisted dictionary fields are written as empty CSV fields.

Nested row formats (metavariables, not actual products):

- Parent configurable_variants: sku=<encoded-child>,color=<encoded-label>,size=<encoded-label>|sku=<next-child>,color=<label>,size=<label>
- Child inventories: <source-code>=<integer>,<second-source>=<integer>
- Child customer_group_prices: group=<code>,qty=<minimum>,type=fixed,price=<value>|group=<code>,qty=<next-minimum>,type=fixed,price=<value>
- images: <location>,<location>. CSV quoting encloses fields containing commas.

The converter URL-encodes nested option values before replacing query separators with commas, preserving spaces, plus signs, ampersands, commas and percent characters through PHP parse_str. Only approved supplied variant combinations are emitted.

Tier max_qty is validated but omitted: native tiers have minimum thresholds only. Therefore finite final ranges, gaps and overlaps cannot be exported faithfully and are rejected. Per-style aggregated thresholds cannot be represented by per-variant tiers and block export.

## Native preflight remains necessary

Check source/target version, existing SKUs/URL keys, categories, required family attributes, exact options, locale/default channel, source-channel assignments, currency, tax, weight and MOQ settings. Supplied reference CSVs are not live verification. The closed legacy Bagisto admin may prevent access to an importer UI in this VK7 deployment; the operator must identify an existing authorized importer entry point. No new CLI command, API or reopened admin is delivered.

Use the existing import action for adding/updating products, normal validation/import/link/index phases and appropriate queues. Never select delete/replace/reset operations to load this package. Existing tiers/categories may remain on update; images can be replaced; opening stock can overwrite current counts. Staging reconciliation and later UAT authorization remain required.

The header-only template and tests/expected/synthetic_bagisto.csv demonstrate the actual row layout. Synthetic output is never a business import.
