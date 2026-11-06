# Backend-intern handover

Package: vk7sports-website/docs/database/product-handover/, branch aryan/product-data-handover, base main e745b38ba928b4361fd68a07abc5eecabaf863d7.

## Delivered now

- Blank styles, variants, per-SKU/source inventory, tiers, media/size-chart manifest and five approval/configuration reference CSVs under templates/.
- validate.py: Python 3.10+ standard-library offline validator and native Bagisto CSV converter.
- FIELD_DICTIONARY.md and IMPORTER_CONTRACT.md: actual table relationships, exact importer columns/nested formats and limits.
- verify.sql: read-only PostgreSQL preflight/reconciliation.
- MISSING_DATA_AND_APPROVALS.md: outstanding inputs and approval gates.
- tests/: 48 synthetic-only tests, 10 fixture files, expected native CSV and validation report.
- PRIOR_DELIVERY_COMPARISON.md and prior_source_inventory.json: comparison and historical inspection evidence.

## Next actions when real inputs arrive

1. Collect approved source master, counted stock, prices/tiers or no-tier approval, MOQ policy, images, weights and size charts. Fill copies of all ten intake files; do not fill unknowns with zero or plausible values.
2. Obtain target references/configuration and verify exact existing color/size options, default channel, locale/family, unambiguous category names and source-channel assignments.
3. Run py -3 -B validate.py --data-dir incoming (add --media-root for local files). Resolve every error/blocker and review remote-image/price-overwrite warnings.
4. Run the same command with --bagisto-csv. Native CSV is stdout, JSON is stderr. Check exit 0 and capture UTF-8 using the README procedure.
5. Use an existing authorized importer entry point on staging. Legacy admin access is closed in this deployment; confirm operator access, dependencies and workers rather than adding an API for this handover.
6. Run native validation/import/link/index phases and review row/image failures. Reconcile the approved exact SKUs, parents, source-level quantities, prices/tiers and media using verify.sql. Retain batch IDs, hashes and sign-off.

## Configuration and boundaries

MOQ is existing channel/core_config policy, not an imported product column. Confirm enabled, min_qty, mode and admin enforcement. Confirm currency, inclusive/exclusive tax-price basis and kgs. The converter omits channel (native default applies), requires a single intended channel and existing exact option labels. Unknown sources/groups must not reach the importer because it can skip/fall back silently.

configurable_variants links child products; parent_sku alone does not. Native tiers are per-SKU minimum thresholds. Style-aggregated tiers and per-style MOQ overrides remain integration decisions. Size charts are attachments, not a newly implemented storefront feature.

Stock is absolute on-hand, not a delta: do not replay snapshots over sales. Images can be replaced and old tiers/categories retained. No database reset, migration, deletion or live import is part of this delivery.

## Results and blockers

48 offline tests pass, including actual-source column compatibility. Synthetic fixture: 1 parent, 2 variants, 3 inventory rows, 6 tiers, 3 media references; expected 3 product CSV rows and 3 remote-media warnings. None are genuine products.

Actual catalogue/stock/prices/assets are unavailable. PHP/vendor dependencies, database connection and importer runtime are unavailable locally. SQL and end-to-end Laravel import were not executed; live provider/version and staging acceptance remain pending. See the register for owners by role and acceptance gates.
