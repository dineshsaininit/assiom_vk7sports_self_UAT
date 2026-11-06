# Remaining blockers

Status recorded 6 November 2026. These are actionable blockers, not requests to invent replacement data or rebuild the architecture.

| ID | Blocker / evidence | What Deepanjal or the responsible owner must provide |
|---|---|---|
| B1 | UAT and Docker runtime use different repositories/branches; manifests/locks and MOQ source differ. | Team confirms canonical backend branch/commit and reconciles changes without automatic merge, reset or vendor copying. |
| B2 | UAT vendor/autoload.php, .env and .env.docker absent; no host PHP/Composer. Separate runtime has dependencies but Artisan version attempt timed out. | Working PHP runtime with exact lock dependencies, including licensed B2B Suite 3.0.1, plus secure local configuration. Diagnose the timed-out bind-mounted runtime before using it for writes. |
| B3 | Actual MySQL bagisto has 0 tables. Documented installer calls db:wipe/migrate:fresh; task forbids both. | Reviewed additive migration/setup sequence for core/B2B/VK7 and authorization for its exact local target. If the team chooses a destructive installer, that requires a separate explicit change of the current prohibition; not performed here. |
| B4 | VK7 app container absent; host port 8000 owned by ai-qa-platform-nginx-1. | Approved unused localhost port and healthy VK7 app/worker startup using canonical source; preserve unrelated project. |
| B5 | No approved master/stock/pricing/assets. Only placeholders, generic examples and labelled synthetic fixtures. | Business-approved style/variant master and expected counts, colour/size pairs, counted stock/date/source, weights, prices/tax, MOQ/tier or no-tier approval, media/charts, provenance. |
| B6 | Exact target reference records cannot exist/verify before schema and setup. | Locale/channel/currency/family/options/category/source/group/config evidence, including source-channel assignments and approved MOQ. |
| B7 | No verified VK7 service/account/token or genuine product IDs for runtime API tests. | Authorized eligible retailer test identity, secure Bearer token and real product/variant identifiers. Record real product/grid/stock/MOQ statuses after setup. |
| B8 | PostgreSQL exports belong to documented Neon target; local service is MySQL. | Maintain engine-specific initialization and verification. Do not import PostgreSQL SQL into MySQL. Prior verify.sql is PostgreSQL-specific. |

## Completed and unblocked

- Actual repo/container ownership, MySQL version/counts, secret presence (not values), source relationships and API route contract identified.
- Existing local application DB role and root read-only SQL connectivity confirmed.
- 48 offline synthetic validation tests passed.
- Required reports and actionable intern handover produced; existing source, CSVs, schema work, volumes and other services preserved.

Not completed: schema initialization, Laravel migration status execution, real or fixture database import, runtime variant/stock/MOQ validation, authenticated VK7 HTTP verification. Local HTTP 404 evidence belongs to the unrelated nginx service and is not an API acceptance result.
