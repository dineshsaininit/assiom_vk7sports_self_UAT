# VK7SPORTS Developer Onboarding

**Prepared:** 2026-10-26 by Claude Code.

> **Read this first.**
> - **No setup procedure in this document has been verified end-to-end from the repository.** The backend Docker stack in `VK7SPORTS-BACKEND/docker/` was written on 21 Oct and has **never been started from this repository**. Docker access is pending founder decisions F2/F3.
> - Each step below is marked:
>   - **✅ VERIFIED (read-only)**: safe to do now.
>   - **📄 DOCUMENTED, UNTESTED**: written in project files but not executed in this handover.
>   - **⛔ REQUIRES APPROVAL**: do not do it without founder approval.

---

## 1. Ground rules (apply from day 1)

1. **Read before you run.** For the first phase, onboarding is read-only.
2. **Never open or copy** `~/PROJECTS/VK7SPORTS-BACKEND-PRIVATE/`, any `.env` / `.env.docker` / `.secrets/` folder, TOTP files or `*.sql.gz` dumps.
3. **Never edit** `app/packages/Webkul/**`, the upstream Bagisto core. New backend code belongs in `app/packages/VK7/Wholesale/` and only after approval. The two patched core files are frozen (decision F9, `docs/CORE-PATCHES.md`).
4. **Never touch** the sandboxes `~/SANDBOX/bagisto-b2b-eval` and `~/SANDBOX/bagisto-qa-codex`. They are historical evidence.
5. **Never** run `qa/reset.sh`. It drops a database.
6. **Never** push to GitHub, create remotes, rewrite history or commit to `main` without approval.
7. Use **fictional data only** (`@example.test` accounts). No real customer names, prices or payments.
8. Label everything you report as source-verified, historical, agent-reported, independently tested, proposed or unknown, just as these docs do.

---

## 2. Reading path (✅ VERIFIED, read-only)

| Order | Document | Location (`M` = `~/PROJECTS/VK7SPORTS-MASTER`) |
|---|---|---|
| 1 | Architecture | `M/05_DOCUMENTATION_AND_SPECS/CODEBASE_HANDOVER/VK7SPORTS_CODEBASE_ARCHITECTURE.md` |
| 2 | Development history | `…/CODEBASE_HANDOVER/VK7SPORTS_DEVELOPMENT_HISTORY.md` |
| 3 | Backend module reference | `…/CODEBASE_HANDOVER/VK7SPORTS_BACKEND_MODULE_REFERENCE.md` |
| 4 | Frontend reference | `…/CODEBASE_HANDOVER/VK7SPORTS_FRONTEND_REFERENCE.md` |
| 5 | Business facts and conflicts | `M/02_BUSINESS_REQUIREMENTS/CLIENT_PROFILE_AND_BUSINESS_FACTS.md`, `REQUIREMENT_CONFLICT_REGISTER.md` |
| 6 | Decisions and status | `M/01_PROJECT_CONTROL/DECISION-REGISTER.md`, `MASTER-STATUS.md` (note the contradictions in the History doc §4) |
| 7 | Backend audit summary | `M/08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_AUDIT_SUMMARY_2026-10-26.md` |
| 8 | QA matrices | `M/05_DOCUMENTATION_AND_SPECS/INDEPENDENT_QA_MATRIX.md`; `~/PROJECTS/VK7SPORTS-BACKEND/qa/CODEX-HANDOFF.md` |
| 9 | Core patches and pins | `~/PROJECTS/VK7SPORTS-BACKEND/docs/CORE-PATCHES.md`, `docs/PINNED-VERSIONS.md` |
| 10 | Codex reviews (26 Oct) | `M/06_QA_AND_TESTING/VK7SPORTS_CODEX_INDEPENDENT_QA_EVIDENCE_2026-10-26.md`, `VK7SPORTS_GITHUB_REPOSITORY_QA_REPORT.md` |

**External study (general knowledge, not project-specific):** Laravel service container, providers and events; Eloquent migrations; Bagisto package structure (Concord modules, repositories, DataGrids, the `core()->getConfigData` config system); Blade + Vue in Bagisto; MySQL transactions and `SELECT … FOR UPDATE`.

---

## 3. Exploring the code safely (✅ VERIFIED, read-only commands)

These commands only read. `GIT_OPTIONAL_LOCKS=0` stops Git from touching its index.

```sh
cd ~/PROJECTS/VK7SPORTS-BACKEND
GIT_OPTIONAL_LOCKS=0 git log --oneline --decorate          # 6 commits, tag baseline-2026-10-15
GIT_OPTIONAL_LOCKS=0 git show --stat 7caa01e               # the VK7 Wholesale package commit
ls app/packages/VK7/Wholesale/src                          # all custom backend code (~577 lines)
cat app/packages/VK7/Wholesale/src/Providers/WholesaleServiceProvider.php   # how VK7 hooks into Bagisto
cat patches/0001-*.patch patches/0002-*.patch              # the two core patches
ls evidence/2026-10-15-sandbox                             # author-run evidence and screenshots
```

Reading the B2B Suite source: the backend repo has **no `app/vendor/`** (it is git-ignored). Read the B2B Suite in the read-only sandbox copy `~/SANDBOX/bagisto-qa-codex/app/vendor/bagisto/b2b-suite/src/`, and **do not modify it**. Its source tree is hash-identical to the eval sandbox copy.

Frontends: open the HTML files of V1 in a browser by double-clicking them. This has no side effects, but it is not documented by the author.

---

## 4. Running the frontend demos (📄 DOCUMENTED, UNTESTED)

These come from the authors' READMEs. Their own runs of the preview server failed in a sandbox (`PermissionError`), and the browser scenarios were never executed.

| Demo | Command (as documented) | Source of instruction |
|---|---|---|
| V2 catalogue | `python3 -m http.server 8767 --bind 127.0.0.1 --directory ~/PROJECTS/VK7SPORTS-CODEX-FRONTEND` → open `http://127.0.0.1:8767` | `VK7SPORTS-CODEX-FRONTEND/README.md` L10–13 |
| V3 integrated | `python3 -m http.server 8769 --bind 127.0.0.1 --directory ~/PROJECTS/VK7SPORTS-INTEGRATION` → open `http://127.0.0.1:8769` | `VK7SPORTS-INTEGRATION/README.md` L10–13 |
| Unit tests (V2/V3) | `node --test tests/*.test.mjs` from the original folder (not the MASTER copy, which lacks `tests/`) | READMEs L52–59 |

Running these local demos is low-risk: they are static, have no network calls and only use loopback. They still count as "running code", so get your supervisor's OK first.

---

## 5. Backend local setup (⛔ REQUIRES APPROVAL, 📄 UNTESTED)

**What exists in the repository:**
- `docker/Dockerfile` (PHP 8.4.26 + extensions + Composer 2.10.3)
- `docker/compose.dev.yml` (project `vk7-backend-dev`; app on `127.0.0.1:8000`, MySQL `127.0.0.1:33061`, Mailpit `127.0.0.1:8025`)
- `docker/compose.qa.yml`
- `.env.docker.example`
- `app/.env.example`

**What is missing** (so the stack cannot be started from the repo alone):

| Missing item | Why it matters |
|---|---|
| `.env.docker` | Must be created from the example with fictional values. It is untracked. |
| `app/.env` | Not in the repo. It must be derived from `app/.env.example`. The correct values for this stack have **not been documented** (DB host `mysql`, DB name, mail host, app key). |
| `app/vendor/` | Needs `composer install` inside the container (network access to Packagist/GitHub) |
| Database contents | Either a fresh Bagisto install (upstream command `php artisan bagisto:install`, defined in `app/packages/Webkul/Installer/src/Console/Commands/Installer.php` L30, **never run for this repo**) or the golden QA dump (`qa/golden.sql.gz`), which is kept **outside** the repo in private storage |
| VK7 configuration | MOQ, 2FA, approval and the order-number generator are DB settings (Admin › Configure). A fresh install has **MOQ disabled** and uses the **default (colliding) order sequencer**. |
| Admin 2FA | If enforced, use the recovery command `php artisan vk7:admin-2fa-reset {email} --reason=…` (`VK7/Wholesale/src/Console/Commands/ResetAdminTwoFactor.php` L16) |

The QA-environment commands in `qa/CODEX-HANDOFF.md` ("Commands" section) are the most complete written procedure. They have **never been executed successfully by an independent party**. Codex's 16 Oct attempt was BLOCKED.

**Recommended first approved task:** a supervised "fresh clone → running stack" dry run that records every command and its output. Use the result to replace this section with a VERIFIED procedure.

---

## 6. Where things are (cheat sheet)

| I want to… | Look at |
|---|---|
| Understand MOQ | `app/packages/VK7/Wholesale/src/Moq.php`, `Cart.php`, `Config/system.php` |
| Understand quotes | B2B `src/Http/Controllers/Shop/QuoteController.php`, `src/Repositories/CustomerQuoteRepository.php`; VK7 `Repositories/CustomerQuoteRepository.php` |
| Understand order creation | `app/packages/Webkul/Sales/src/Repositories/OrderRepository.php` › `createOrderIfNotThenRetry` |
| Understand stock reservation | `app/packages/Webkul/Sales/src/Repositories/OrderItemRepository.php` › `manageInventory` (patched) |
| Understand admin permissions | `app/packages/Webkul/Admin/src/Config/acl.php`; B2B `src/Config/admin/acl.php` |
| See what was tested and how | `evidence/2026-10-15-sandbox/after-fix/RESULTS.md`, `evidence/2026-10-15-sandbox/e2e/W1-W10-workflow.txt`, `qa/tools/*` |
| See known defects | `M/08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_AUDIT_SUMMARY_2026-10-26.md` §3 |

---

## 7. Glossary

| Term | Meaning |
|---|---|
| MOQ | Minimum order quantity: 24 pieces standard (provisional) and 100 for custom orders (not built) |
| RFQ / quote | Request for quotation (B2B Suite `b2b_customer_quotes`) |
| PO | Purchase order: a quote that has been converted into an order |
| per_style / per_variant / per_order | MOQ counting basis. **The owner has not decided which applies.** |
| Golden DB | Fictional QA seed database (`qa/golden.sql.gz`, private storage) |
| W1–W10, A1–G3, Q1–Q12 | Historical workflow tests, the Codex QA cases and the QA matrix IDs |
| F1–F9 | Founder decisions (only F1, F2, F3, F6, F8 and F9 are documented) |
| D-01 to D-13 | Defect IDs from the 26 Oct Claude audit |
