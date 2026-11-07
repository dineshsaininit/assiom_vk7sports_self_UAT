# MongoDB Atlas: repository audit (evidence)

Date: 7 November 2026. Audit only: read-only commands, no database writes, no migrations, no secrets read or printed.

## Repository state

| Item | Value |
|---|---|
| Remote | `github.com/dineshsaininit/assiom_vk7sports_self_UAT` |
| Audit branch | `claude/vk7sports-mongodb-atlas-c18a34` (worktree, clean, at `e745b38` = `origin/main`) |
| PR #1 branch | `aryan/product-data-handover` at `36ce376`, 3 commits ahead of `main`, docs and product-handover tooling only (45 files, +1902). Local and remote are identical. Not merged. |
| Other branch | `origin/feature/backend-api` at `eac786a` (older than `main`) |

## Backend

| Item | Finding |
|---|---|
| Location | `vk7sports-website/backend/app` (Bagisto, `bagisto/b2b-suite 3.0.1`) |
| Framework | Laravel `v13.31.0` (composer.lock), PHP `^8.4` |
| Custom code | `packages/VK7/Wholesale` (API controllers, services, 7 Eloquent models, 5 migrations) |
| Configured engine | `.env.example`: `DB_CONNECTION=mysql`. Docker dev: `mysql:8.0.46` container running. `docs/database/NEON_SETUP.md`: PostgreSQL 17 / Neon, 182 tables with foreign keys |
| MongoDB today | None. No `mongodb/*` package, no `ext-mongodb`, no Mongo connection in `config/database.php` |
| Backend Docker image | `php:8.4.26-cli`; extensions `bcmath calendar exif gd intl pdo_mysql zip sockets pcntl` (no `mongodb`) |
| Local tooling | `php`, `composer`, `gh`, `mongosh` not installed on the host. `docker`, `node 24` available |

## Can MongoDB Atlas replace the SQL database?

No. Evidence:

- Bagisto core runs on about 182 relational tables with foreign keys (`NEON_SETUP.md`).
- The wholesale package depends on SQL transactions and row locks: 15 `DB::transaction` / `lockForUpdate` uses, including order numbering (`Sequence.php`), stock holds (`CatalogueDesk.php`), cart and quote moves.
- All models extend `Illuminate\Database\Eloquent\Model` on SQL tables (`vk7_*`) and relate to Bagisto models (orders, customers).

Swapping `DB_CONNECTION` to MongoDB would break the store, admin and checkout.

## Can MongoDB Atlas run alongside it?

Yes. `mongodb/laravel-mongodb` 5.11.0 (Sept 2026) declares `illuminate/support ^12|^13.0`, PHP `^8.2`, `ext-mongodb ^1.21|^2`, so it fits Laravel 13 / PHP 8.4. It adds a second `mongodb` connection. Bagisto keeps MySQL/PostgreSQL.

Good fit (append-only, no cross-table transactions):

1. **Activity / audit log**: `Services/ActivityRecorder::record()` is the single write path for `vk7_activity_log`. Mirror each record to Atlas.
2. **Shipment tracking events and raw courier payloads** (`vk7_shipment_events`, Delhivery responses).
3. **Enquiry / quote history snapshots** for reporting.

Keep in SQL: orders, payments, stock, sequences, carts, customers, catalogue.

## Required changes (now made, see `03_VERIFICATION_EVIDENCE.md`)

1. Dockerfile: add `mongodb` to `install-php-extensions`.
2. `composer require mongodb/laravel-mongodb:^5.11` (inside the container).
3. `config/database.php`: add a `mongodb` connection that reads `MONGODB_URI` and `MONGODB_DATABASE`. `.env.example` gets empty placeholders only.
4. `ActivityRecorder`: write to SQL as now, then mirror to Atlas. An Atlas failure is logged and never breaks the request.
5. Pest test plus `artisan` health command: ping Atlas, insert a test document, read it back, delete it.

`.env` is gitignored (`backend/app/.gitignore:5`, `backend/.gitignore:3`), so the Atlas URI stays local.
