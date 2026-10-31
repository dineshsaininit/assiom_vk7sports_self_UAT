# VK7SPORTS backend — independent QA handoff for Codex

Prepared 2026-10-21 by Claude Code (backend preservation lead). Status: **preparation only**. The preservation
repository (F1) and Docker access (F2/F3) are awaiting founder approval. Nothing here authorises code changes.

## Your goal

Independently confirm or refute the 15 Oct 2026 self-tested results. Report PASS / FAIL / BLOCKED with raw
output. Do not fix defects; report them.

## What is under test

- Bagisto 2.5.0 (Laravel 13.31, PHP 8.4, MySQL 8.0.46) + B2B Suite 3.0.1 (`bagisto/b2b-ecommerce` ref `a2b178e`).
- Custom code: `app/packages/VK7/Wholesale/src/`
  - MOQ: `Moq.php`, `Cart.php`, order backstop at `Providers/WholesaleServiceProvider.php:49`
  - variant-aware quote → cart: `Repositories/CustomerQuoteRepository.php`
  - row-locked order numbers: `OrderNumberSequencer.php`, active only via `core_config` (present in golden DB)
  - 422 mapping: `Exceptions/Handler.php`
  - admin 2FA enforcement: `Http/Middleware/Bouncer.php`
- Core edits retained by founder decision F9: `patches/0001`, `patches/0002`. Risks are in `docs/CORE-PATCHES.md`.
- MOQ policy in fixtures (enabled, 24, per_style) is **provisional test configuration**, not owner policy.

## Targets (in order of preference)

1. The tagged `baseline-2026-10-15` in the new local repository, once F1 is approved. Record the git SHA in every report.
2. Until then: `~/SANDBOX/bagisto-qa-codex` (code-identical to dev, verified 2026-10-21). Ports 8100 / 33100 / 8125, project `bagisto-qa`.

Never use port 8000, project `bagisto-b2b-eval`, DB `bagisto`, or `~/SANDBOX/bagisto-b2b-eval/.secrets/`.

## Environment (previous blocker)

Your 16 Oct run was BLOCKED because the seatbelt sandbox denied the Docker socket and loopback ports.
The founder will choose one option (F3):

- (a) a scoped profile allowing only the Docker socket and `127.0.0.1:8100/33100/8125`
- (b) a human runs the commands below and gives you raw logs to judge
- (c) static review only (results stay NOT VERIFIED)

## Parameterized tooling (for the new repository)

The scripts in `qa/tools/` are parameterized copies (founder decision F8). Originals are untouched in the sandboxes.
Settings come from `.env.docker` (copy `.env.docker.example`; fictional local values only):

`MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `QA_BASE`, `QA_MAILPIT`, `QA_DB_NAME`, `QA_COMPOSE_FILE`,
`QA_PASSWORD` (fixture buyers), `QA_ADMIN_EMAIL`, `QA_ADMIN_PASSWORD`, `QA_ADMIN_2FA` (0 for golden DB),
`QA_RETAILER_EMAIL`, `QA_STAFF_EMAIL` / `QA_STAFF_PASSWORD` (security_regression only; no staff fixture exists in golden).

Scripts exit with a clear message when a variable is missing. They never print credential values.

## Commands (repository layout)

```sh
cp .env.docker.example .env.docker            # fill fictional values
docker compose --env-file .env.docker -f docker/compose.qa.yml up -d --build
docker compose --env-file .env.docker -f docker/compose.qa.yml exec app composer install --no-interaction --prefer-dist
qa/reset.sh                                    # before EVERY scenario; expect 7 customers / 0 orders / 0 quotes / 0 reservations
qa/tools/q.sh "select code,value from core_config where code like 'vk7.%'"   # capture live policy first
set -a; . ./.env.docker; set +a
python3 qa/tools/order_driver.py place qa.alpha 148:23       # A1: expect MOQ rejection, 0 orders
python3 qa/tools/order_driver.py place qa.alpha 148:24       # A2: expect exactly 1 order + 24 reserved
python3 qa/tools/order_driver.py race 147:24 qa.alpha qa.beta   # D1: expect exactly 1 success
qa/tools/repo_race.sh 2 147:24                               # D2: same invariant, bypassing cart checks
python3 qa/tools/e2e_workflow.py workflow                    # W1–W10: 15 Oct result was 23/23
```

The full A1–G3 matrix with reproduction steps is in `INDEPENDENT_BACKEND_QA_REPORT.md` (your 16 Oct report).

## Priority

1. MOQ A1–A5, races D1–D2, multi-variant quote → order C1–C3, authorisation F1–F4.
2. Your four open risks: RFQ-stage MOQ, duplicate RFQ, mixed-variant conversion, inventory under transaction failure (E1–E2).
3. G1–G3 (invalid transitions, repeat order POST, duplicate dispatch).
4. New: price leakage. An unapproved or other-company session must not receive company catalogue or tier prices in HTML/JSON.

## Evidence rules

- One file per scenario: `evidence/<YYYY-MM-DD>-codex/<ID>.txt` with command, exit code, raw output and before/after DB counts.
- `q.sh` exit status is not meaningful (QA-01); parse its output.
- BLOCKED is never PASS. No real names, emails, payments or prices. Pest suites only against a separate test database.

## Coordination

| Party | May write to | Must not write to |
|---|---|---|
| Codex | `bagisto-qa-codex` runtime state, own evidence folder | `bagisto-b2b-eval`, repository code, any `.secrets/` |
| Claude Code | New repository (after F1) and `~/AASIOM-INFRA/vk7sports-backend-prep/` | Both `~/SANDBOX` trees |

Claude reads `bagisto-qa-codex` only between Codex runs. Tell the founder when a run is in progress.
