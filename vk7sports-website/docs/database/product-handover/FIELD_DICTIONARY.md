# Intake fields and Bagisto mapping

All templates are UTF-8 comma-delimited CSV with exact headers, one header row, and proper CSV quoting. BOM is accepted. Preserve SKUs as text. Decimal points only, no currency symbols or thousands separators. Unknown is missing information, never zero. Empty required values and explicit unknown/TBD/TBC/N/A/null/? markers fail validation. No prices, stock or options are inferred.

## Shared provenance: every table

| Field | Rule |
|---|---|
| data_class | Required: business or synthetic. Never mix classes in one batch. Synthetic requires an explicit test flag and SYNTHETIC- SKU identifiers. |
| source_ref | Required traceable source filename/record or evidence identifier; supporting evidence must accompany handover. |
| approval_ref | Required approval evidence identifier. Presence is not proof of approval; the operator checks it. |

Every field below is required except tiers.max_qty (blank means unbounded) and media.sku (blank means shared style asset). All ten CSV files must exist. Customer groups and tiers may have no rows for an explicitly approved no-tier batch.

## Collection templates

| CSV | Fields and rules |
|---|---|
| styles.csv | style_sku: unique parent ID, ASCII letters/digits joined by hyphens, max 64; name: approved name max 255; category_path: slash-separated existing category names, no empty segments; short_description and description: approved text; status: active or hidden; moq_qty: positive integer; moq_basis: per_style, per_variant or per_order; currency: uppercase three-letter code; tax_basis: inclusive or exclusive; size_chart_id: manifest size_chart ID owned by this style. |
| variants.csv | sku: unique sellable SKU, same ASCII syntax, max 255, distinct from all styles; style_sku: exact parent reference; colour: exact approved and existing native color admin_name, max 100; size: exact approved/native size admin_name, max 20; price: positive numeric(12,4); weight_kg: measured positive decimal, same input precision bound; tier_policy: approved none or provided; image_ids: nonempty pipe-separated manifest IDs for images belonging to this SKU or its style. Generated variant name (style name + colour + size) must fit 255. |
| inventory.csv | sku: exact variant reference; inventory_source_code: exact active source reference; stock_qty: known on-hand nonnegative integer, max 2147483647; stock_as_of: valid YYYY-MM-DD. Unique SKU/source pair, at least one row per variant. Counted zero is valid; unavailable counts must not become zero. These are absolute quantities, not deltas or available stock after reservations. |
| tiers.csv | sku: variant reference; customer_group: explicit existing group code (all is excluded); min_qty: positive integer; max_qty: integer >= minimum or blank for final unbounded range; unit_price: positive numeric(12,4), <= variant base price, nonincreasing with volume; quantity_basis: per_variant supported, other values block native export. Each SKU/group schedule must be contiguous without overlaps and end unbounded. Base price applies below the first threshold. |
| media.csv | media_id: unique letters/digits/underscore/hyphen ID; style_sku: owner; sku: optional owner within style; kind: image or size_chart; location: HTTP(S) URL without credentials, or relative forward-slash file path under --media-root. No literal commas, traversal or mixed URL/file product-image modes. File presence is checked, not image decoding/rights; remote links are shape-checked and warned, never fetched. |
| allowed_combinations.csv | style_sku, colour, size: exact approved combinations. Unique ignoring case; variant spellings must match. This is an approval list, not a list generated from possible sizes and colours. |
| inventory_sources.csv | code: existing source identifier (letters/digits/underscore/hyphen); status: active or inactive. Inactive sources cannot receive supplied inventory. Operator supplies current target references and channel assignment evidence. |
| customer_groups.csv | code: exact existing customer-group identifier, same code syntax; explicit groups only. Needed for tier rows. |
| attribute_options.csv | attribute_family_code, attribute_code, label: verified existing options for the selected family. attribute_code is color or size; label is exact admin_name. Operator confirms family membership, attribute type/configurability and existence; this file creates nothing. |
| configuration.csv | Exactly one row: channel_code (verified default), channel_count=1, locale, attribute_family_code, currency (three uppercase letters), weight_unit=kgs, tax_basis=inclusive or exclusive, moq_qty (positive), moq_basis (per_style/per_variant/per_order). Codes use letters/digits/underscore/hyphen. Every style's MOQ/currency/tax policy must match this record. Confirm native MOQ enabled/admin behavior separately. |

Duplicates are detected ignoring identifier case; references require exact spelling. Stock and quantity bounds use 32-bit signed integer capacity. Money is positive, at most eight whole and four fractional digits; no rounding, exponent, NaN, infinity or free/zero-price inference. Multiline descriptions are accepted as quoted CSV. No other control characters are accepted.

## Actual schema relationships

| Intake/native concept | Existing Bagisto relationship |
|---|---|
| style_sku / configurable row | products(id, sku, type=configurable, attribute_family_id), parent_id NULL. |
| variant sku / simple row | products row linked by products.parent_id to parent. The configurable_variants field, not parent_sku alone, drives source linking. |
| colour/size labels | Existing attributes and attribute_options; parent product_super_attributes; child product_attribute_values.integer_value stores option ID. Attribute family membership uses attribute_groups and attribute_group_mappings. |
| name, descriptions, price, weight, visibility/status | product_attribute_values EAV values; derived product_flat and price indexes. Price/weight supplied on simple children. |
| category_path -> categories | category_translations.name resolves each slash-separated name independently; product_categories links matches. No automatic category creation or hierarchy validation. Names must be unambiguous on target. |
| inventory_source_code + stock_qty -> inventories | product_inventories(product_id, inventory_source_id, vendor_id=0, qty), references inventory_sources. Channel availability also depends on channel_inventory_sources. |
| Reservations | product_ordered_inventories(product_id, channel_id, qty). Not created/cleared here; reconcile separately. |
| tier rows -> customer_group_prices | product_customer_group_prices(product_id, customer_group_id, qty, value_type=fixed, value). qty is minimum; max_qty has no native destination. |
| image references -> images | product_images plus actual storage files; parent gets ordered union of child image references. |
| size_chart_id / manifest size_chart | Attachment handover only. No existing native size-chart field is assumed or populated. |
| MOQ | core_config vk7.moq.settings.enabled, min_qty, mode, apply_to_admin_orders. No per-product MOQ column is imported. |
| Currency / tax_basis / channel | Verified target policy, not silently applied by intake import. Native price tax values including_tax/excluding_tax correspond to inclusive/exclusive. |
| Provenance, stock_as_of, approval list | Retained as handover evidence; no invented native columns. |

No product_variants table or new inventory table is required. Native CSV syntax and source methods are documented in [IMPORTER_CONTRACT.md](IMPORTER_CONTRACT.md).
