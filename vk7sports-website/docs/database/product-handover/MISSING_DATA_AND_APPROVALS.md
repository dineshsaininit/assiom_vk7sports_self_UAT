# Missing data and approval register

The user confirmed the approved VK7SPORTS product/SKU master and opening-stock dataset are unavailable. Completion of engineering deliverables is authorized; business facts and approvals below remain pending. No approval reference, business product, price or stock figure has been invented.

## Completed

- Ten blank intake/reference templates and one native output-header template.
- Read-only reusable validation/conversion, explicit synthetic segregation, automated tests and synthetic native output.
- Required fields, relationship/option/source/media validation, inventory/price/tier rules.
- Field dictionary, source-verified Bagisto mapping, PostgreSQL verification queries.
- Backend-intern procedure and prior-delivery comparison. Local commit only.

## Required inputs and decisions

| ID | Input / approval | Responsible role | State / consequence |
|---|---|---|---|
| DATA-01 | Authoritative style/variant master, launch counts, SKU rules, names and category assignments | Business/catalogue owner | Unavailable; cannot populate styles/variants or certify completeness. |
| DATA-02 | Approved colour-size combinations and exact option labels | Catalogue owner + target operator | Pending; cannot expand combinations or invent native options. |
| DATA-03 | Counted opening stock per SKU/source/date, source-to-channel assignment and reservation context | Inventory owner + operator | Unavailable; unknown stock is not zero. No usable opening-stock load yet. |
| DATA-04 | Base prices, currency, tax basis, HSN/tax category/rates as applicable | Commercial/tax owner | Unavailable; no tax rules or prices inferred. |
| DATA-05 | MOQ quantity, aggregation, enabled/admin enforcement | Business owner + operator | Pending; seed 24/per_style is provisional configuration, not approval. |
| DATA-06 | Tier prices/ranges/customer groups/aggregation OR explicit no-tier approval | Commercial owner | Pending; per-style aggregate tier policy blocks native export. |
| DATA-07 | Approved images, ownership/rights, SKU associations and files/accessible URLs | Catalogue/media owner | Unavailable; remote URL availability/contents not checked offline. |
| DATA-08 | Measured weight and size charts, chart ownership and usage approval | Product owner | Unavailable; chart is an attachment, no storefront integration assumed. |
| ENV-01 | Exact running UAT engine/version/provider and authorized staging connection | Deployment operator | Not verified locally. Documented/export PostgreSQL is evidence, not a live probe. |
| ENV-02 | Default channel, locale, family/required attributes, color/size existing options, categories, active sources, groups and settings | Target operator | Pending. Fill reference CSVs from target evidence; confirm categories resolve unambiguously. |
| ENV-03 | PHP/Composer dependencies, configured app/database, supported importer entry point and workers | Backend intern/operator | Unavailable locally; no Laravel import/queue/image-download execution. Legacy admin is closed; do not assume UI access. |
| ACCEPT-01 | Approved input evidence, validation report, staging import ID and per-SKU reconciliation/sign-off | Data owner + intern/operator | Pending real inputs/runtime. No staging/UAT load claimed. |

## Acceptance gates

The offline package is ready to receive approved data. A business dataset is ready only when all required source values are supplied, validation exits 0, warnings are reviewed, target references/configuration match, and approval evidence is checked. A database load is accepted only after an authorized staging import/link/index run and reconciliation against exact approved SKU/source/price records.

Per-style MOQ overrides, mixed-variant aggregated tier pricing and storefront size-chart display require explicit integration decisions outside this database-only delivery. Existing APIs are untouched.
