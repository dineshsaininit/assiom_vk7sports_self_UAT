# MongoDB Atlas side connection: verification evidence

Date: 7 November 2026. Branch `claude/vk7sports-mongodb-atlas-c18a34`, based on `main` at `e745b38`. Not yet committed or pushed.

## Status

| Item | Result |
|---|---|
| Code change | Done (see list below) |
| Tests against a real MongoDB 8.0 server (local Docker) | **8 passed, 17 assertions** |
| Existing VK7 suite: does the change break anything? | **No new failures**: same 43 failures on original and changed code (environment gaps, see below) |
| Pint code style | Pass (7 files) |
| **Live MongoDB Atlas cluster `vk7sports-uat`** | **VERIFIED 2026-11-07 18:38 IST**: ping, insert, read back, delete all OK; MongoDB 8.0.37; database `vk7sports_uat`; user `vk7sports_app` (readWrite); round trip 4257 ms. Report: `evidence/atlas-live-check.json` |
| Live activity mirror into Atlas | Not run against Atlas (`mirrored_activity: 0`). Mirror path proven on local MongoDB only (test 7). |

## Handover for Deepanjal

- **Branch:** `claude/vk7sports-mongodb-atlas-c18a34` (local worktree, uncommitted, not pushed).
- **SQL stays primary:** `database.default` is unchanged (`DB_CONNECTION`, MySQL by default). Atlas only gets a copy of `vk7_activity_log` entries after the SQL commit.
- **To run on the dev stack:** add `MONGODB_URI`, `MONGODB_DATABASE`, `MONGODB_TIMEOUT_MS` to `backend/app/.env`; `docker compose --env-file .env.docker -f docker/compose.dev.yml build app`; `composer install`; `php artisan optimize:clear`; `php artisan vk7:atlas-check`.
- **Credentials:** only in the gitignored `.env`, mounted into the container at `/var/www/html/.env`. Check output and report show the host, never the user or password.
- **Atlas side:** cluster `vk7sports-uat` (M0), database `vk7sports_uat`, collections `activity_log` (mirror) and `connection_checks` (left empty by the check). Network Access must list each server's public IP.

## Limitations

- Only the activity log is mirrored. Orders, payments, stock, carts, customers and catalogue stay in SQL only.
- Mirroring is synchronous with a 2–5 s timeout; one Atlas outage adds at most one timeout per process per 60 s cooldown. Entries written during an outage or cooldown are not back-filled.
- No unique index on `sql_id` yet; a retry could duplicate a document.
- M0 is a free shared tier: no backups, no SLA, limited throughput. Not for production.
- Pending review: the Dockerfile installer checksum correction and the compose image tag change.

## What changed

| File | Change |
|---|---|
| `backend/docker/Dockerfile` | Adds `mongodb-2.5.5` PHP extension. Corrects the installer checksum to `3f49c71f…`, which matches the GitHub 2.12.0 release, the working dev Dockerfile and the `:baseline` image (the repo value was stale and the build failed). |
| `backend/docker/compose.{dev,qa}.yml` | App image tag `:baseline` → `:mongodb`, so the existing image is not overwritten. |
| `composer.json` / `composer.lock` | Adds `mongodb/laravel-mongodb ^5.11` and its dependency `mongodb/mongodb`. No other package version changed. |
| `config/database.php` | New `mongodb` connection from `MONGODB_URI`, 2 s timeouts. Default connection unchanged (MySQL). |
| `.env.example` | Empty placeholders only. |
| `Wholesale/src/Services/AtlasMirror.php` | New. Copies an activity entry to Atlas **after** the SQL transaction commits. On any Atlas error: SQL entry kept, warning logged with credentials removed, Atlas skipped for 60 s. |
| `Wholesale/src/Services/ActivityRecorder.php` | Saves to SQL as before, then calls the mirror. |
| `Wholesale/src/Console/Commands/AtlasCheck.php` | New `vk7:atlas-check`: ping, write, read back, delete; optional JSON report without credentials. |
| `Wholesale/tests/Feature/AtlasMirrorTest.php` | 8 tests. |

## Test environment (all disposable)

Private Docker network `vk7-atlas-test`, nothing shared with the dev stack (`vk7-backend-dev-*`) or its MySQL:

- PostgreSQL 17.5 in memory, loaded from `docs/database/vk7sports_schema.sql` + `vk7sports_base_data.sql` (182 tables). `php artisan migrate` could not be used: the B2B Suite provider queries `channels` while booting, so it fails on an empty database.
- MongoDB 8.0.32 in memory.
- Test image `vk7-backend-php84:mongodb-pgtest` = `:mongodb` + `pdo_pgsql` (test only, not in the Dockerfile).

## Atlas mirror tests (`evidence/atlas-mirror-tests.log`)

1. SQL only when no connection string is set.
2. Unreachable MongoDB never breaks activity logging; password not in the log.
3. Cooldown skips MongoDB after a failure.
4. Credentials hidden in host display and error messages.
5. `vk7:atlas-check` fails clearly without `MONGODB_URI`.
6. `vk7:atlas-check` fails when the server cannot be reached.
7. A committed activity entry appears in MongoDB with the same `sql_id`.
8. `vk7:atlas-check` passes against a live server and leaves no check document.

## Regression comparison

`evidence/vk7-suite-baseline.log` (original code) and `evidence/vk7-suite-with-change.log` (this change) were run on the same disposable database. The failure lists (`failures-*.txt`) are identical: 43 each. They come from the test environment, not this change:

- Vite manifests missing (`public/themes/*/build` is not in git) → HTTP 500 on pages that render mail/views.
- No staff/admin fixtures in the base data → `createToken() on null`.

These tests need the team's QA database and built frontend assets to pass; that was not available here.

## Next steps

1. Review and commit; open a PR to `main`.
2. Optional: record one staff action on the dev stack and confirm it appears in Atlas `activity_log`.
3. Before production: paid tier with backups, unique index on `sql_id`, back-fill job for missed entries.
