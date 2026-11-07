# Backend handover for Deepanjal

Prepared 6 November 2026. **MySQL is reachable but still empty; no product import or working VK7 API is claimed.** The database engineering templates/validator are ready; initialization and runtime integration have the concrete blockers below.

## Start here

1. **Choose the canonical backend source with the team.** UAT: C:/Users/pawan kumar singh/assiom_vk7sports_self_UAT, branch aryan/product-data-handover, starting commit 51ebc5204b0aa8ca33dbb335913a8ed44bdf96f3. Actual Docker project: C:/Users/pawan kumar singh/Documents/VK7SPORTS/vk7sports-integration, branch aryan/backend-mysql-integration, commit 4374f3c5e70a747d1f3e5f276f2284c46a2e803c, origin AASIOM8/vk7sports-website. Composer and MOQ files differ. Do not transplant vendor/.env between them.
2. **Restore an exact supported runtime for the chosen source.** UAT lacks vendor and local .env/.env.docker. The other source has these and B2B Suite 3.0.1, but its read-only Artisan version attempt timed out. Cached PHP image works (8.4.26); host PHP/Composer are absent on PATH.
3. **Resolve the port collision without touching the unrelated project.** Host 8000 belongs to ai-qa-platform-nginx-1. Assign an approved unused localhost port to VK7 and record its base URL; do not stop the other project.
4. **Get an approved non-destructive bootstrap procedure.** Current documented installer calls db:wipe/migrate:fresh; those operations are forbidden. Preserve the current volume. Review additive core/B2B/VK7 migration and setup dependencies, then verify migration status and target before any later authorized write.
5. **Collect real inputs.** Approved SKUs/colour-size pairs, counted source-level stock/date, commercial prices/tiers/MOQ, measured weights, photos/charts and approval evidence. Current sample/fixture records are not business products.
6. **Validate, import only an approved batch, and reconcile.** Use the existing templates/converter and normal native importer/link/index phases once the schema/runtime is ready. Verify exact SKUs, parents/options, source quantities, prices, tiers and policy. Finally test real VK7 endpoints with an eligible retailer account/token.

## Database and existing tables

Actual local target: MySQL 8.0.46, container vk7-backend-dev-mysql-1, database bagisto, host 127.0.0.1:33061, internal mysql:3306 on vk7-backend-dev_default. Table count is 0 and migrations table is absent. Root and container application-role read-only SELECTs pass; Laravel connectivity is not verified.

The intended source relationships already exist as migrations: products configurable parent/simple child through parent_id; attributes/attribute_options and product_attribute_values for colour/size; product_super_attributes for configurable parents; product_inventories/inventory_sources/channel_inventory_sources for stock; product_ordered_inventories for reservations; product_customer_group_prices/customer_groups for tiers; core_config vk7.moq.settings.* for MOQ. No replacement product_variants or MOQ table is needed.

## Configuration to obtain securely

DB_CONNECTION=mysql, exact DB_HOST/DB_PORT for the runtime location, DB_DATABASE=bagisto, role/password, optional DB_URL precedence, APP_ENV=local, APP_KEY and approved base URL/port. Host clients use 127.0.0.1:33061; containers on the project network use mysql:3306. Do not set the container to host localhost by mistake.

Confirm default channel, locale, base currency, family/required attributes, exact existing color/size options, category assignments, active source-channel associations, customer groups, kgs weight unit, tax-price basis and MOQ enabled/min_qty/mode/admin enforcement. Source defaults are not business approval. Secrets belong in untracked local configuration/approved secret storage, not in reports or Git.

The prior configuration checklist is mainly for the documented PostgreSQL/Neon target. For this local MySQL stack use the actual settings above; do not copy pgsql/Neon SSL settings or PostgreSQL dumps into MySQL.

## Delivered files and acceptance evidence

This folder contains the seven requested reports. [VERIFICATION_EVIDENCE.md](VERIFICATION_EVIDENCE.md) records commands/results; [REMAINING_BLOCKERS.md](REMAINING_BLOCKERS.md) assigns exact inputs/actions by role.

Existing intake package: [product-handover](../docs/database/product-handover/README.md), including blank templates, field dictionary, native importer mapping, missing-data register, converter and synthetic-only tests. All 48 offline tests passed during this task. No Laravel DB/Pest import/API success is implied.

Acceptance still requires an approved non-destructive initialization, actual table/migration/reference counts, a genuine frozen dataset and reconciliation, verified VK7 service identity, authentication and live endpoint responses. No destructive command, volume removal, placeholder business import, API change or deployment was performed.
