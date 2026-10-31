# Bagisto + B2B Suite — isolated feasibility sandbox (VK7SPORTS)

Created 2026-10-15. Local only, fictional data only. Not connected to the VK7SPORTS repo.

## Versions
- Bagisto v2.5.0 (tag, commit 4e7f086) — Laravel 13, PHP 8.4
- bagisto/b2b-suite v3.0.1 (Composer)
- Runtime: `Dockerfile.eval` (php:8.4-cli) + MySQL 8.0 + Mailpit, via `compose.eval.yml`
  (Bagisto's bundled docker-compose.yml needs laravel/sail, which is not a dependency.)

## Start / stop
    cd ~/SANDBOX/bagisto-b2b-eval
    docker compose -f compose.eval.yml up -d      # app → http://127.0.0.1:8000, mail → http://127.0.0.1:8025
    docker compose -f compose.eval.yml stop       # stop, keep data
    docker compose -f compose.eval.yml down -v    # REMOVE containers + DB volume (only when you decide)

All ports bind to 127.0.0.1 only.

## Test accounts (fictional, local only)
- Admin: installer default (admin@example.com / <redacted> was REMOVED 2026-10-15. Login: .secrets/admin-email.txt + admin-password.txt; 2FA TOTP secret: .secrets/admin-totp-secret.txt (all chmod 600, never commit). Recovery: evidence/2fa/2FA-RECOVERY-RUNBOOK.md
- Staff (restricted role "TEST Order Desk"): staff.orderdesk@example.test / <redacted>
- Retailer company "Fictional Sports Mart": ravi.retailer@example.test / <redacted>

## Evidence
- `evidence/*.png` — screenshots of each tested step (01–26)
- `evidence/composer-audit-licenses.txt` — dependency audit + license list
- `q.sh "<SQL>"` — helper to query the sandbox DB

## Inventory + MOQ fix (2026-10-15)
- Patches: `patches/0001-*.patch`, `patches/0002-*.patch` (applied in `app/`); MOQ package: `app/packages/VK7/Wholesale`
- Tests: `tests/order_driver.py` (storefront HTTP), `tests/repo_race.sh` (DB-level race), `tests/stock.sh`, `tests/set_moq.sh`
- Fictional buyers: buyer01..buyer12@example.test / <redacted>
- Results: `evidence/after-fix/RESULTS.md`; pre-fix baseline: `evidence/baseline-before-fix/`
- Separate test DB `bagisto_test` (used only for Bagisto's Pest suites)

## Security + 2FA + E2E (2026-10-15)
- Mode: APP_ENV=production, APP_DEBUG=false, php-production.ini (expose_php Off). Config is cached: run `php artisan optimize` after .env changes; run `config:clear` before Pest.
- Settings (sandbox provisional, owner to confirm): require 2FA for all admins = ON; personal accounts need approval = ON; MOQ 24 per_style = ON
- Tests: tests/admin_2fa.py, tests/security_regression.py, tests/e2e_workflow.py ; evidence: evidence/{security,2fa,e2e,security-regression,final}/
- Staff test user now uses 2FA: .secrets/staff-totp-secret.txt
