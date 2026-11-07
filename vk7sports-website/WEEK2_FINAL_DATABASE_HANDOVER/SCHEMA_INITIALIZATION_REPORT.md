# Schema initialization report

**Status: BLOCKED; no migration, seed, install, reset or database import executed.** Actual bagisto table count remained 0 before and after inspection.

## What exists

- UAT: backend/app/artisan, composer.json/lock, real Bagisto migrations, VK7 custom migrations.
- 213 PHP migration files in the UAT application's source directories.
- B2B dependency declared as bagisto/b2b-suite 3.0.1; its installed code exists only in the separate Docker-source tree.
- PostgreSQL setup assets: docs/database/vk7sports_schema.sql and vk7sports_base_data.sql. These are historical setup assets, not a MySQL initialization route.
- Docker: running MySQL and Mailpit; PHP 8.4.26 image cached; no VK7 app container.

## Why installation was not run

The documented docs/backend/VK7SPORTS_BACKEND_SETUP.md procedure starts with VK7_CORE_INSTALL=1 and bagisto:install, then B2B installation, migrations and VK7 setup. The source backend/app/packages/Webkul/Installer/src/Console/Commands/Installer.php calls db:wipe and migrate:fresh at lines 118–119. This conflicts directly with the task's prohibition on wipe/fresh/reset/force commands. No installer was run, even though the current database is empty.

The source documentation also uses migrate --force and warns that the installer can ignore testing/environment overrides. Those instructions were inspected, not executed. VK7 setup can set provisional business policy and emit a password, so it was not invoked.

The UAT clone lacks installed dependencies and configuration. The existing Docker-source repository has a different branch, remote, Composer manifest/lock and MOQ implementation. Its vendor/.env were not transplanted into UAT. A temporary read-only php artisan --version attempt against that source timed out (configured subprocess timeout: 90 seconds). migrate:status and route:list planned after it were not reached. SQL independently confirms the migrations table does not exist.

Port 8000 is occupied by an unrelated project's nginx container. The existing Compose app service cannot bind its configured port there without an explicit port decision. That unrelated service was left unchanged.

## Exact safe next steps for Deepanjal

1. Obtain the team's canonical backend decision: UAT commit/branch versus the existing AASIOM8 integration repository. Preserve both histories and local secrets. Do not silently combine source/vendor folders.
2. For the chosen source, verify the complete lock against installed dependencies or install that exact lock in the approved PHP runtime. Supply secure local .env/.env.docker configuration and verify target host/database/APP_ENV before any write.
3. Establish a reviewed additive bootstrap procedure for an empty MySQL database: verify core migrations, required setup seeders, B2B boot ordering and custom migration dependencies. The reset-based documented installer is not permitted by this request. An unreviewed substitute is not supplied as an executable recipe.
4. Recheck the target table count and grants. Run migration status before writes once Laravel can boot. Do not assume 0 tables remains true later.
5. Execute only an approved non-destructive procedure without --force, fresh, wipe, drop or reset. Record exact commands, exit codes, table names/counts and migration ledger.
6. Validate locale/currency/channel/family/options, warehouse associations, B2B configuration and business-approved MOQ. Seed defaults are not business approval.
7. Record any outstanding seeds, migrations or indexes separately; table existence alone is not a working Bagisto store.

Do not run the PostgreSQL exports into MySQL. Do not initialize another replacement project. Existing Docker volumes were preserved.
