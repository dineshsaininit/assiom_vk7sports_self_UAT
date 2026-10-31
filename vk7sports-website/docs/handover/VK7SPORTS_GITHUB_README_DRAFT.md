<!-- DRAFT prepared 2026-10-26 by Claude Code for founder review. Not published. Intended as README.md of the proposed private repository `vk7sports-backend` (see VK7SPORTS_REPOSITORY_STRUCTURE_PROPOSAL.md). -->

# VK7SPORTS: B2B Wholesale Sportswear Platform

AASIOM Technologies Private Limited is developing a B2B wholesale ordering platform for **VK7SPORTS**. Retailers and shopkeepers will use it to browse sportswear by size and colour, order in minimum quantities, request quotations and track dispatch.

> ⚠️ **Status: pre-production evaluation baseline. NOT production-ready.**
> - No feature has passed independent acceptance testing.
> - Key commercial rules (payment terms, custom orders, shortage handling, price visibility) are awaiting client approval.
> - The final technology stack has not been formally selected.

---

## Current status

| Area | Status |
|---|---|
| Backend (Bagisto + B2B Suite + VK7 Wholesale) | Code present. Tested only by its author on 15 Oct 2026 (fictional data). Independent QA was attempted but blocked. |
| Frontend | Three demonstration prototypes with mock data (separate repositories or folders). Not connected to this backend. The Bagisto storefront in this repository is the only data-connected UI. |
| Commercial policies | MOQ 24 provisional (counting basis undecided). Payments, custom orders (MOQ 100), shortage and backorder, and price visibility are pending. |
| Known defects | Confirmed by source review, not yet reproduced: duplicate quote numbers, non-atomic quote → cart, negotiated price persists when quantity changes, no RFQ idempotency. See `docs/`. |
| Deployment | None. No CI at repository root. No production environment. |

## Software components

| Component | Version | Location |
|---|---|---|
| Bagisto (Laravel e-commerce) | 2.5.0 | `app/` (upstream tree, `app/packages/Webkul/`) |
| Laravel / PHP | 13.31.0 / 8.4 | `app/composer.lock`, `docker/Dockerfile` |
| B2B Suite (Webkul, MIT) | 3.0.1 | Composer dependency `bagisto/b2b-suite` (installed into `app/vendor/`, not committed) |
| **VK7 Wholesale (custom)** | — | `app/packages/VK7/Wholesale/`: MOQ rules, variant-aware quote → cart, row-locked order numbers, admin 2FA enforcement, readable order rejections |
| Core patches | 0001, 0002 | `patches/`, applied in `app/packages/Webkul/Sales` and `Admin` (variant stock reservation, shipment stock check) |
| Database | MySQL 8.0.46 | `docker/compose.*.yml` |
| Dev mail | Mailpit 1.31.5 | `docker/compose.*.yml` |

## Repository organisation

```
app/                 Bagisto application (keep upstream layout)
  packages/VK7/      VK7 custom code: all new backend work goes here
  packages/Webkul/   upstream Bagisto core (do not edit; two patched files are frozen)
  resources/views/vendor/   published view overrides (B2B / VK7)
docker/              Dockerfile and compose files (dev, qa); loopback-only ports
patches/             reference copies of the core patches
qa/                  QA kit and scenario tools (destructive scripts: see warnings)
docs/                architecture, module reference, onboarding, history, core patches, pinned versions
evidence/            historical test evidence (author-run, 15–16 Oct 2026)
```

## Documentation

| Read | For |
|---|---|
| `docs/VK7SPORTS_CODEBASE_ARCHITECTURE.md` | System overview and flows |
| `docs/VK7SPORTS_BACKEND_MODULE_REFERENCE.md` | Modules, source locations, status |
| `docs/VK7SPORTS_FRONTEND_REFERENCE.md` | Prototype versions and integration status |
| `docs/VK7SPORTS_DEVELOPER_ONBOARDING.md` | How to start (verified vs untested steps) |
| `docs/VK7SPORTS_DEVELOPMENT_HISTORY.md` | Evidence-backed project history |
| `docs/CORE-PATCHES.md`, `docs/PINNED-VERSIONS.md` | Patch risks and pinned build inputs |
| `qa/CODEX-HANDOFF.md` | Independent QA brief |

## Prerequisites (for approved developers)

- Docker with Compose (the stack uses `docker/compose.dev.yml`, project `vk7-backend-dev`)
- Network access for Composer packages (Packagist / GitHub)
- Familiarity with Laravel (service container, events, migrations) and Bagisto packages

**The local setup procedure has not yet been verified from a clean clone.** See `docs/VK7SPORTS_DEVELOPER_ONBOARDING.md` §5 for what is known to be missing:
- `app/.env` values
- dependency installation
- database initialisation
- VK7 admin settings

No installation commands are given here until that procedure has been tested and recorded.

## Known limitations

- No independent runtime acceptance; all passing results are author-run.
- No PHP unit tests for the VK7 package.
- Not implemented:
  - 10% advance / 90% COD payment split
  - Custom orders (MOQ 100, advance)
  - Full-payment discount
  - Shortage/backorder workflow
  - Carrier integration
  - Admin actor audit trail
  - Guest price hiding
- MOQ is **disabled by default**. The order-number sequencer must be selected in admin settings.
- Direct core patches must be re-applied and re-tested on every Bagisto upgrade.
- B2B Suite 3.0.x is a new release line from a single vendor.

## Contribution workflow (proposed)

1. Work is assigned and approved by the project lead. No unapproved changes.
2. Branch from `main`: `feat/…`, `fix/<defect-id>-…` or `docs/…`.
3. Put new backend behaviour in `app/packages/VK7/`. Do not edit `app/packages/Webkul/`.
4. Keep commits small, and reference the decision or defect ID.
5. Open a pull request. It needs at least one reviewer approval. Report test evidence with its provenance (author-run vs independent).
6. Never merge to `main` directly. Never rewrite history. Never move the `baseline-2026-10-15` tag.

## Security precautions

- **Never commit:** `.env`, `.env.docker`, `app/.env`, `.secrets/`, TOTP secrets, database dumps (`*.sql.gz`) or storage archives. `.gitignore` and `.gitleaks.toml` are provided. Run a secret scan before every push.
- Use fictional data only (`@example.test`) in development and QA.
- All Docker ports bind to `127.0.0.1`. Do not expose them.
- Do not run `qa/reset.sh` except against an approved, isolated QA database. It **drops** the database.
- Admin 2FA can be enforced (Configure › VK7 Wholesale › Security). Recovery is via `php artisan vk7:admin-2fa-reset`.
- Report security issues privately to the project lead, not in public issues.

## Licence

Bagisto and B2B Suite are MIT-licensed. Some transitive dependencies are GPL or LGPL (for example `mpdf/mpdf` GPL-2.0-only). Legal review is required before any distribution. The licence for VK7-specific code is **to be decided by AASIOM**.
