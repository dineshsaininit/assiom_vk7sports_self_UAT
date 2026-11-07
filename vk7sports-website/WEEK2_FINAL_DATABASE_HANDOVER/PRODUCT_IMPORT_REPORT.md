# Product dataset and import report

**Real business import: NOT PERFORMED. Development-fixture database import: NOT PERFORMED.**

No approved SKU master, stock counts, commercial prices, MOQ approval or product media are available. Schema initialization is blocked. No records were generated to fill those gaps.

## Available inputs

| Source, relative to vk7sports-website | Classification / evidence |
|---|---|
| data/sample-products.json | 3 records, all explicitly is_sample_data=true / SAMPLE_PLACEHOLDER. Not approved VK7 products. |
| data/sample-categories.json; data/sample-tier-pricing.json | Illustrative category/pricing planning data, not an approved source. |
| backend/app/storage/app/public/data-transfer/samples/csv/products.csv | Generic Bagisto importer examples; previously verified 26 rows. |
| backend/app/packages/Webkul/Admin/tests/e2e-pw/data/data-transfer/ | XLS/XLSX/CSV test inputs, not business inventory. |
| docs/database/vk7sports_schema.sql | PostgreSQL historical schema, 182 CREATE TABLE definitions; not product data. |
| docs/database/vk7sports_base_data.sql | Setup records, zero product INSERT statements; no supplied genuine catalogue. |
| docs/database/product-handover/tests/fixtures/synthetic/ | Explicit synthetic validation inputs; isolated from business templates. 1 style, 2 variants, 3 stock rows, 6 tiers and 3 media references; never imported. |

The live MySQL schema has no products/inventory/MOQ tables to query. Product/variant/inventory row counts are therefore **not available**, rather than successful count queries returning zero.

## Existing ready-to-fill deliverables

Use [PRODUCT_DATA_INTAKE.md](../docs/database/product-handover/PRODUCT_DATA_INTAKE.md), the ten normalized blank intake/reference CSVs under docs/database/product-handover/templates/, and [FIELD_DICTIONARY.md](../docs/database/product-handover/FIELD_DICTIONARY.md). Do not create a second incompatible intake format.

The actual source-compatible importer is backend/app/packages/Webkul/DataTransfer/src/Helpers/Importers/Product/Importer.php. [IMPORTER_CONTRACT.md](../docs/database/product-handover/IMPORTER_CONTRACT.md) documents the actual emitted columns and nested formats. configurable_variants establishes child links; parent_sku alone does not. Existing color/size options are required. Unknown source codes can be skipped and unknown customer groups can become all-group prices, so reference validation must happen first.

The existing converter emits native CSV only after successful offline validation, and never writes to a database. Existing synthetic expected CSV is a test artifact, not an imported catalogue.

## Validation executed this task

Python 3.13, standard library: 48 unittest methods passed in 7.469 seconds. Covers required/types, identifiers and parent references, approved combinations/existing options, stock bounds/source references, prices/tier intervals, policy mismatches, media references/path checks, synthetic segregation, CSV parsing/encoding and actual-source header compatibility.

These are offline tests. They do not verify real business facts, a successful Laravel import, current MySQL products, stock availability or runtime MOQ enforcement. Do not confuse a fixture validation pass with business dataset delivery.

## Inputs still required

Approved style/variant master and launch counts, exact allowed pairs, category/name/description content, measured weights, source-level stock/date, existing source/group/option references, base prices/currency/tax basis, MOQ policy approval, tier schedule or no-tier approval, images and size charts, plus traceable source and approval evidence.

After approved schema initialization and receipt of data, validate and prepare UTF-8 native CSV, obtain local-import approval for the frozen batch, use the existing importer/link/index workflow, then reconcile exact parent/variant identities, source quantities, tier minima and configured MOQ. Stock snapshots are absolute quantities; do not replay them over active sales.
