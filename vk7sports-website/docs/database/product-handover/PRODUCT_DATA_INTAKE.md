# Product-data intake: blank templates and validation rules

Use copies of the existing header-only CSVs in templates/. They form one normalized intake package: style fields are collected once, sellable variants once, and stock once per SKU/source. This supports multiple sources without duplicate product records. Keep the supplied column names; these intake files are not the native Bagisto upload layout.

No approved business records are available. Leave the committed templates blank. Do not turn missing prices, stock, MOQ or option approvals into plausible values.

## What the business must supply

Every row in every file requires data_class=business, a traceable source_ref and approval_ref backed by real evidence. Those fields are assertions; offline validation cannot verify the authority of an approval.

| Blank template | Required collection fields | Validation rules |
|---|---|---|
| [styles.csv](templates/styles.csv) | style_sku, name, category_path, short_description, description, status, moq_qty, moq_basis, currency, tax_basis, size_chart_id | Unique parent SKU, max 64 ASCII letters/digits joined by hyphens; name max 255; approved active/hidden status; positive integer MOQ; per_style/per_variant/per_order basis; currency and tax basis must match configuration. Chart ID must resolve to a size_chart manifest record owned by the style. |
| [variants.csv](templates/variants.csv) | sku, style_sku, colour, size, price, weight_kg, tier_policy, image_ids | Unique variant SKU max 255, distinct from every style; existing exact parent; approved colour/size pair and exact existing native option labels; positive price and measured weight; tier_policy none or provided with approval; pipe-separated required image manifest IDs. |
| [inventory.csv](templates/inventory.csv) | sku, inventory_source_code, stock_qty, stock_as_of | Exact variant and active source; unique SKU/source pair; known on-hand integer 0–2147483647 and valid YYYY-MM-DD. At least one row per variant, including a counted zero. Unknown stock is not zero. |
| [tiers.csv](templates/tiers.csv) | sku, customer_group, min_qty, max_qty, unit_price, quantity_basis | Approved fixed unit prices by SKU/group; positive integer minimum; maximum >= minimum or blank for final unbounded interval; no gaps/overlaps; nonincreasing prices <= base. per_variant supported; style aggregation blocks native output. |
| [media.csv](templates/media.csv) | media_id, style_sku, sku, kind, location | Unique manifest ID; correct owner; kind image or size_chart; sku may be blank for a style asset. File must exist under --media-root, or use a well-formed HTTP(S) URL requiring separate availability/content/rights checks. |

All fields above are required except tiers.max_qty and media.sku. Shared provenance fields are also required. Monetary values accept at most eight whole and four fractional digits; no zero/negative price, exponent, currency symbol, NaN or rounding. Labels must use exact approved spelling; colour is max 100 and size max 20 characters.

## References to obtain from the target operator

| Blank template | Required source |
|---|---|
| [allowed_combinations.csv](templates/allowed_combinations.csv) | Approved style_sku, colour, size combinations. List actual approved pairs; do not generate every possible combination. |
| [inventory_sources.csv](templates/inventory_sources.csv) | Current code/status values from inventory_sources; confirm source-channel assignments separately. |
| [customer_groups.csv](templates/customer_groups.csv) | Existing explicit customer-group codes for pricing tiers; all-groups fallback is excluded. |
| [attribute_options.csv](templates/attribute_options.csv) | Existing family/attribute/label references for native color and size. The importer does not create missing options. |
| [configuration.csv](templates/configuration.csv) | Exactly one verified default channel, channel_count=1, locale, attribute family, currency, weight_unit=kgs, tax basis and common MOQ policy. Confirm native MOQ enabled/admin enforcement separately. |

All ten CSV files must be present. tiers.csv and customer_groups.csv can contain only headers if every variant has approved tier_policy=none. Keep source approvals, stock-date evidence and expected style/SKU/source totals with the batch.

## Fill and validate

1. Copy the ten intake/reference CSVs to an incoming/ directory; preserve the originals and exact headers. Use UTF-8 CSV, decimal points and text SKUs.
2. Complete style records, approved combinations and operator references, then variant rows, source-level counts, tiers and media. No placeholder products belong in a business batch.
3. From the product-handover directory run:

```powershell
py -3 -B validate.py --data-dir incoming
# For a manifest containing local files:
py -3 -B validate.py --data-dir incoming --media-root incoming/media
```

Errors and mapping blockers produce exit 1; successful offline mapping checks produce exit 0. Missing values and unknown/TBD/TBC/N/A/null/? markers are reported. Review warnings even after exit 0. Synthetic inputs are rejected by default; never enable --allow-synthetic for business data.

4. After resolving all findings, use the same command with --bagisto-csv to prepare native output. CSV goes to stdout and JSON to stderr; failure emits no CSV. Use the UTF-8 capture procedure in [README.md](README.md). This does not import anything.
5. Hand over normalized source files, evidence/approvals, media/size charts, native CSV, JSON report and exact expected SKU/source/price totals.

See [FIELD_DICTIONARY.md](FIELD_DICTIONARY.md) for the complete field contract, [IMPORTER_CONTRACT.md](IMPORTER_CONTRACT.md) for actual Bagisto encoding, and [DATABASE_CONFIGURATION_HANDOFF.md](DATABASE_CONFIGURATION_HANDOFF.md) for required target settings. Live reference verification and a separately authorized staging import remain pending.
