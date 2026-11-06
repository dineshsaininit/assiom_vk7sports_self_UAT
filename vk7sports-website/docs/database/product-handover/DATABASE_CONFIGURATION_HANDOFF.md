# Database configuration handoff for the backend intern

Prepared 6 November 2026 from source verified identical in the Desktop copy and this UAT clone. No credential values were read, collected or written. Running UAT host/provider/version and credentials remain unverified.

## Connection details the deployment operator must supply

| Detail | Source requirement / status |
|---|---|
| Environment and database purpose | Identify authorized staging versus UAT; tests must use an isolated database, never the live Neon target. |
| Database technology | Documented target PostgreSQL 17 / Neon. Export header is PostgreSQL 17.5; this does not prove current server version. |
| DB_CONNECTION | pgsql for the documented target. Generic source default is not deployment evidence. |
| DB_HOST | Actual approved endpoint, including whether direct or pooled; not available here. |
| DB_PORT | Actual port; source default 5432. |
| DB_DATABASE | Exact existing database name; do not assume the source default laravel. |
| DB_USERNAME | Approved least-privilege role for the intended operation. |
| DB_PASSWORD | Required secret supplied through the team's secure secret channel, never in CSV, Git, this document or chat. |
| DB_SSLMODE | require for the documented Neon setup; source fallback prefer is not the intended Neon policy. |
| DB_URL | Optional alternative connection URL supported by source. Confirm whether it is set and consistent with DB_* values. Treat the entire URL as secret; never paste it into deliverables. |
| DB_CHARSET / DB_PREFIX | Source defaults utf8 / empty string; confirm target expectations. |
| PostgreSQL schema | Source search_path is public; exports use public. No DB_SCHEMA environment key is wired in this connection. |
| Network / access | Confirm endpoint access, SSL requirements and role permissions. An existing read-only connection suffices for verify.sql; importing requires separately authorized write access. |

Actual keys above were verified in backend/app/config/database.php. A configured local connection and Laravel dependencies were unavailable during verification. Do not run an installer or restore bootstrap SQL against an existing database to obtain configuration.

## Product import configuration and reference inputs

- Target default channel code/count, channel locale and base currency. Converter currently supports one intended channel; native CSV omits channel and the importer chooses its default.
- Locale code, attribute-family code and all required editable attributes. color and size must be configurable attributes in that family with exact existing attribute_options.admin_name labels.
- Category names and IDs: native categories splits on slash and resolves each name independently; verify uniqueness and assignments, not just a display path.
- Active inventory-source codes/IDs and their channel_inventory_sources assignments. Use counted absolute stock per SKU/source/date; reservations remain separate.
- Exact customer-group codes/IDs for tiers. Unknown groups can become all-group prices and unknown inventory sources can be skipped by the native importer.
- Currency, weight unit kgs, tax-price basis: intake inclusive/exclusive corresponds to native including_tax/excluding_tax. Confirm HSN/tax-category/rate applicability with the business; no rates are inferred.
- MOQ settings: vk7.moq.settings.enabled, min_qty, mode (per_style/per_variant/per_order), apply_to_admin_orders. The provisional 24/per_style seed is not owner approval. Importer does not apply per-product MOQ.
- Import action for adding/updating products, image mode (file/URL), local images_directory_path or verified remote URLs, storage permissions, supported authorized importer entry point and queue workers. Legacy admin is closed; do not assume importer UI access.
- File images resolve under backend/app/storage/app/import/<images_directory_path>/. Size charts are handover attachments; no native size-chart field is assumed.
- Record import/link/index completion and per-SKU reconciliation. Existing snapshots overwrite stock; prior tiers/categories may remain and images can be replaced.

Use templates/configuration.csv and the source/group/option reference templates only after obtaining verified operator evidence. README.md and IMPORTER_CONTRACT.md describe the offline converter and native format. verify.sql is read-only PostgreSQL preflight/reconciliation and has not been executed here.

## Required business inputs

Approved style and variant SKUs, valid colour-size pairs, names/categories/descriptions, measured weights, stock by SKU/source/date, base prices and currency/tax basis, MOQ approval, tier schedules or explicit no-tier approval, photos, size charts, source references and approval evidence. No approved launch style/SKU count is currently available.

A passing synthetic test is not a populated business dataset or a successful database import.
