# VK7SPORTS product-data handover

Prepared 6 November 2026 for the database owner and backend intern.

**Complete:** blank collection templates, offline validator/converter, synthetic tests, native Bagisto CSV example, field/table mapping, read-only verification SQL and missing-input register. **Blocked:** populated business dataset and an actual import, because the approved product master, stock, prices and assets are unavailable. There are no actual business products in this package.

Repository: `C:\Users\pawan kumar singh\assiom_vk7sports_self_UAT`

Package: `vk7sports-website/docs/database/product-handover/`

Branch: `aryan/product-data-handover`

Base: `main` at `e745b38ba928b4361fd68a07abc5eecabaf863d7`

Start with [BACKEND_INTERN_HANDOVER.md](BACKEND_INTERN_HANDOVER.md) for the concise operational handoff.

Use [PRODUCT_DATA_INTAKE.md](PRODUCT_DATA_INTAKE.md) to collect identifiers, colour/size variants, counted source-level stock, prices and MOQ through the existing validated blank templates. The [database configuration checklist](DATABASE_CONFIGURATION_HANDOFF.md) lists the exact connection and product-import settings the operator must supply.

## Files to hand to the intern

| File/directory | Purpose |
|---|---|
| `templates/styles.csv` | One approved parent style per row, descriptions, MOQ, currency/tax policy and size-chart reference. |
| `templates/variants.csv` | One sellable SKU per approved colour/size pair, price, measured weight and image references. |
| `templates/inventory.csv` | Counted on-hand stock per SKU/source/date; supports multiple sources per SKU. |
| `templates/tiers.csv` | Fixed unit prices by SKU, customer group and quantity interval. |
| `templates/media.csv` | Image and size-chart manifest with explicit style/SKU ownership. |
| `templates/allowed_combinations.csv` | Approved colour/size combinations; never generate the Cartesian product. |
| `templates/inventory_sources.csv`, `customer_groups.csv`, `attribute_options.csv`, `configuration.csv` | Target reference data to obtain from the operator; blank until confirmed. |
| `templates/bagisto_import.csv` | Header-only native output layout. Upload a generated CSV, not an intake template. |
| `validate.py` | Read-only validation and native CSV preparation, Python 3.10+ standard library. |
| [FIELD_DICTIONARY.md](FIELD_DICTIONARY.md) | Field requirements and Bagisto table relationships. |
| [IMPORTER_CONTRACT.md](IMPORTER_CONTRACT.md) | Exact implementation contract and source references. |
| [MISSING_DATA_AND_APPROVALS.md](MISSING_DATA_AND_APPROVALS.md) | Business/configuration inputs and approval gates. |
| [verify.sql](verify.sql) | PostgreSQL preflight and reconciliation SELECT queries. |
| `tests/fixtures/synthetic/`, `tests/expected/` | Explicitly synthetic test input, native CSV and report; never import as business data. |

## Shortest path to a usable business dataset

1. The business/data owner fills copies of the ten intake/reference CSVs. Keep their exact headers. All files must be present; `tiers.csv` and `customer_groups.csv` may be header-only if every SKU has an approved `tier_policy=none`. Preserve source and approval evidence separately.
2. The operator supplies current channel, locale, attribute family, existing colour/size options, inventory sources and customer groups. Verify categories and required family attributes against the target using `verify.sql`. The reference CSVs are assertions from that evidence, not a live connection.
3. Validate offline, resolve errors and blockers, review warnings, then generate the native CSV. Deliver the normalized CSVs, native output, JSON report, approvals, media/size charts and expected per-SKU totals together.
4. In an **authorized staging environment**, the intern/operator uses the existing Bagisto Product Importer with the add/update action, correct image source, CSV separator comma, and validation/error review enabled. Use its normal queued import, linking and indexing phases; wait for completion and inspect failed rows/images. Do not upload synthetic fixtures or SQL bootstrap exports.
5. Reconcile SKU identities, parent links, option IDs, source-level stock, prices, tiers, images and indexes with the approved files. Record import ID, source-file hashes, row counts and operator sign-off before any separately authorized UAT load.

No new tables, API endpoint, migration or database initialization is needed for the supported product/variant/stock mapping. If the business requires per-style aggregated tier prices, per-style MOQ overrides or a storefront size-chart feature, retain those requirements as blocked integration work rather than silently changing their meaning.

## Commands

Run from this package directory. These commands only read input unless the operator explicitly captures stdout to a file.

```powershell
py -3 -B validate.py --data-dir incoming
py -3 -B validate.py --data-dir incoming --media-root incoming/media
py -3 -B validate.py --data-dir incoming --media-root incoming/media --bagisto-csv
py -3 -B -m unittest discover -s tests -v
```

Validation prints JSON to stdout. CSV preparation prints native CSV to stdout and JSON diagnostics to stderr; on error it emits **no CSV**. Exit 0 means the offline format/mapping checks passed, 1 means errors or blockers, and 2 means invalid command arguments. It does not certify business authenticity, live references, media content or import success. `database_verified` and `business_authenticity_verified` remain false.

On Windows PowerShell 5, ordinary redirection may produce UTF-16. To save a business CSV as UTF-8 safely, from this directory:

```powershell
$preparedCsv = & py -3 -B validate.py --data-dir incoming --media-root incoming/media --bagisto-csv
if ($LASTEXITCODE -ne 0) { throw 'Resolve validation errors before export.' }
$outputPath = Join-Path (Get-Location) 'reports/bagisto-products.csv'
if (Test-Path -LiteralPath $outputPath) { throw 'Choose a new output path.' }
[void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($outputPath))
[IO.File]::WriteAllText($outputPath, ($preparedCsv -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
```

For a URL-only manifest, omit `--media-root`. Remote availability, image decoding and usage rights still need review. For file images, transfer assets to the native importer's configured `storage/app/import/<images_directory_path>/` and retain the same relative names. Size charts remain handover attachments, not product images.

`incoming/`, `reports/` and Python caches are locally ignored. Do not commit operational records or source evidence accidentally. Empty committed templates deliberately fail validation; an empty dataset cannot be represented as an accepted handover.

## Required target configuration and caveats

- One intended/default channel; the CSV does not set a channel. Confirm `configuration.channel_code` is the target's default. This initial converter blocks multi-channel targets.
- Existing locale and family, required product attributes, configurable `color` and `size` attributes with exact existing option labels. Options are **not** created by this importer.
- Existing active inventory sources attached to that channel, and exact customer-group codes for any tiers. Unknown sources may be skipped; unknown groups may become all-group prices in the importer. The offline validator rejects references absent from the supplied lists.
- Existing category names and unambiguous category assignments. Native `categories` resolves slash-separated names independently; it does not create a hierarchy or enforce a supplied path.
- Channel base currency matches the approved currency; weight unit is `kgs`; tax setting matches `inclusive` / `exclusive` (`including_tax` / `excluding_tax` in native configuration).
- Existing `vk7.moq.settings.enabled`, `min_qty`, `mode` and `apply_to_admin_orders` require operator confirmation. MOQ is global/channel configuration, not imported per product. The seed minimum 24 is not business approval.
- The converter sets `manage_stock=1`, `guest_checkout=0`, parent visibility 1 and child visibility 0; status comes from approved intake. These are declared technical import defaults.
- Never replay stock snapshots blindly over ongoing sales. Existing SKUs may be updated, images replaced, and prior tiers/categories retained by upsert. Review collisions and stale rows on staging; this package does not delete or reconcile live records.

## Verified local results and limits

48 automated tests pass on Python 3.13, including actual-source column checks, nested delimiter encoding, malformed data, relationships, quantities, pricing intervals, media references and non-mutation. The valid synthetic batch has 1 parent style, 2 variant SKUs, 3 inventory rows, 6 tier rows and 3 media references. Its stock total is 9 **synthetic** units. The native example has 3 product rows. Three remote-media warnings are expected because fixture URLs use `example.invalid`.

Synthetic tests require `--allow-synthetic`; that flag must never be used for a business handover. No network requests or database connections are made by the script or tests.

The documented target/export technology is PostgreSQL (Neon target; export PostgreSQL 17.5). Exact running UAT provider/version remains unverified. The previously inspected SQL exports are setup records, not the missing business catalogue. Local PHP/Laravel dependencies and live database access are unavailable, so Laravel importer execution, image downloads, queue processing and SQL execution have **not** been tested. Run the supplied SQL only against an authorized PostgreSQL connection with `ON_ERROR_STOP=1`; it is wrapped in a read-only transaction.

See [PRIOR_DELIVERY_COMPARISON.md](PRIOR_DELIVERY_COMPARISON.md) for retained functionality, historical evidence and the intentionally changed intake interface.
