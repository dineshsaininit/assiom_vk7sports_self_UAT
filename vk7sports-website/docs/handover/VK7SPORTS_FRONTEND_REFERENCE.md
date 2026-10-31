# VK7SPORTS Frontend Reference

**Prepared:** 2026-10-26 by Claude Code. **Method:** read-only inspection plus SHA-256 comparison of copies. **Nothing was run.** No browser, no `node --test`, no server.
**Labels:** [SRC] verified from source, git or hashes · [HIST] historical documentation · [AGENT] claim by another AI agent (the authoring Codex agent's own test reports) · [IND] independently tested (**none**) · [PROP] proposed · [UNK] unknown or blocked.

> **Bottom line:** there are **three distinct frontend codebases**. All three are **demonstrations with mock data**. **None makes a network call or is connected to the Bagisto backend.** [SRC: no `fetch`, `XMLHttpRequest`, `axios` or `/api` in any of them]
>
> The real storefront that exists today is Bagisto's own Blade/Vue storefront with the B2B Suite theme, inside the backend repository (see `VK7SPORTS_BACKEND_MODULE_REFERENCE.md` §2.2).

---

## 1. Versions at a glance

| | V1 Intern static prototype | V2 Codex catalogue prototype ("Phase 1.5") | V3 Integrated quotation demo |
|---|---|---|---|
| Authoritative path | `~/PROJECTS/VK7SPORTS/app/VK7SPORTS_Prototype/` | `~/PROJECTS/VK7SPORTS-CODEX-FRONTEND/` | `~/PROJECTS/VK7SPORTS-INTEGRATION/` |
| Git | Yes. Added `4eb2ee9` (2026-08-04, author Nooruzma-Khan). Moved under `app/` in `144008c` (2026-10-11) with unchanged content. | **Not in git** | **Not in git** |
| Dated | Aug 2026 (file mtimes are 11 Oct, the consolidation date) | 15 Oct 2026, 02:35–02:43 | 15 Oct 2026, 03:30–03:39 (docs to 12:53) |
| Author | Intern (per the MASTER folder name `01_intern_prototype`, and git author) | Codex agent [HIST: `VK7SPORTS-INTEGRATION/FEATURE_COMPARISON.md` L3] | Codex agent, adapting V2 plus `~/Downloads/VK7SPORTS_Interactive_Prototype.zip` patterns [HIST: `ATTRIBUTION.md` L6]. The ZIP's authorship is unverified. |
| Technology | Plain HTML, inline CSS and JS. Google Fonts and Unsplash images loaded remotely. | Native ES modules (`index.html` L3), CSS, `<dialog>`, SVG garment art (`art.mjs`). No dependencies or build step. | Same as V2, plus `operations.mjs` and `workspace.mjs` |
| Data | Hard-coded HTML. `localStorage` keys `vk7-team-name`, `vk7-shirt-color` (custom-teamwear.html L1066–1069). | `data.mjs`: 6 fictional products with per-variant stock and **no prices** (L1) | Same `data.mjs` (identical hash), plus in-memory session records |
| Backend link | None | None (`README.md` L48: "No Bagisto compatibility claim is made") | None (`BACKEND_INTEGRATION_REQUIREMENTS.md` L3: "No adapter, endpoint, auth integration or backend was implemented") |
| Tests | None | 20 `node:test` tests in `tests/` (model 8, fixtures 3, ui 9) | 26 `node:test` tests in `tests/` (adds operations 4, workspace 2) |
| Test results | — | [AGENT] "20 automated tests passed" (`README.md` L61, `VALIDATION.md` L7), self-reported by the author on 15 Oct. Browser scenarios **not executed** (`VALIDATION.md` L52). | [AGENT] "26 passed, 0 failed" (`INTEGRATION_STATUS.md` L25), self-reported. Browser scenarios not executed (L51). |

**Copies (byte-identical, not separate versions)** [SRC, SHA-256 file by file]:
- `VK7SPORTS-MASTER/03_FRONTEND_AND_PROTOTYPES/01_intern_prototype/` is the same as V1 (all 5 files).
- `…/02_codex_catalogue_prototype/` is the same as V2's runtime files, **without `tests/`**.
- `…/03_integrated_quotation_system/` is the same as V3's runtime files and README, **without `tests/`, `qa/` or the governance documents** (INTEGRATION_STATUS, BLOCKERS, CONTRACT, etc.).
- `~/Desktop/VK7SPORTS_GROK_AUDIT_PACKAGE/app/` is the same as V1.

Use the original folders for study. The MASTER READMEs refer to `tests/` and directories that are not in the copy.

---

## 2. V1: Intern static prototype

| Page | Content | Interactivity [SRC] |
|---|---|---|
| `HomePage.html` (735 lines) | Hero, Shop by Sport, Featured Collections, Customer Type, Why VK7, newsletter | **No `<script>` at all.** All links are `href="#"`. The newsletter form has no action (L723). |
| `ShopPage.html` (1,022) | 7 hard-coded jersey cards (for example ₹1,299 at L855). Filters L757–819, sort L833. | Only `toggleFilters()` (L1012–1019). Filters and sort do nothing. |
| `custom-teamwear.html` (1,095) | Jersey customiser and bulk enquiry form (quantity bands 10–25 … 100+, L946) | Colour swatches, name preview, logo upload under 3 MB (L1030–1045). `updateSummary()` = qty × 1299 (L1047–1051). Quote and enquiry show a toast only (L1063, L1071). Quantity is `min=1` (L907), so there is **no MOQ**. |
| `AdminDashboardPage.html` (597) | Hard-coded KPIs and chart | Only `toggleMenu()` (L589–595) |
| `VK7SPORTS_Prototype_Description_Report.docx` | Intern's description report | Not opened |

Notes:
- The pages do not link to each other.
- The sample data `VK7SPORTS/data/sample-*.json` (MOQ 24; tiers 24–49 at 0%, 50–99 at −10%, 100+ at −20%; `is_sample_data: true`) is **not used by any page** [SRC].
- Earlier audits classify these pages as UI_ONLY/MOCKED (`VK7SPORTS/audit/08_VK7SPORTS_PAGE_AUDIT.md`) [HIST]. Custom teamwear was flagged as a scope conflict (08 L88) [HIST].
- **Correction to audits 07/08:** they say HomePage has a menu button with no listener. HomePage has no menu button at all. `mobile-menu-btn` occurs only in ShopPage, custom-teamwear and AdminDashboardPage. [SRC grep]
- **Run instructions:** none are documented. Opening the files in a browser is the evident method, but it is undocumented and untested here.

---

## 3. V2: Codex catalogue prototype

All of these are in `app.mjs` [SRC]:

| Workflow | Function (line) |
|---|---|
| Catalogue with search and category filter | `renderCatalogue` (L11), input handlers (L52) |
| Simulated loading, empty, error and retry | `loadCatalogue` (L21), L16–17 |
| Product detail dialog | `openProduct` (L28) |
| **Size × colour quantity matrix** | `matrixLines` (L33), `validateMatrix` (L34), `saveMatrix` (L35) |
| Quotation draft panel | `renderDraft` (L22) |
| Summary with shortage acknowledgement | `openSummary` (L36) |
| Simulated submit (850 ms timer), failure and retry | `submitDemo` (L43, L47). Fixed reference `DEMO-VK7-001` (L49). |

Business rules in code [SRC]:
- MOQ threshold input defaults to **24** (`index.html` L14) and the user can edit it.
- `model.mjs` › `evaluate()` (L2–16): the threshold must be 1–9999, and the basis is `unconfirmed | basket | product | variant`. **`unconfirmed` is never eligible**, which deliberately reflects that the owner has not chosen a basis.
- Shortage text "Additional stock may require 20–30 days" (`app.mjs` L26, 34, 40).
- **No prices, tiers, advance or COD.**

Documented commands [HIST]. These are **documented but not tested in this handover**:
- Preview: `python3 -m http.server 8767 --bind 127.0.0.1 --directory /Users/aasiom/PROJECTS/VK7SPORTS-CODEX-FRONTEND`, then open `http://127.0.0.1:8767`. Do not use `file://`. (`README.md` L10–13)
- Checks: `node --test tests/*.test.mjs`; `node --check app.mjs` (and the other modules). (`README.md` L52–59)
- The author recorded that the preview server **failed** in its sandbox (`README.md` L63, `PermissionError`).

Limitations [HIST `README.md` L65–71]:
- Timer-based submission.
- Fictional stock.
- Unconfirmed MOQ basis.
- No persistence, export, tracking or integration.
- No browser or accessibility verification.
- "Phase 2 requires Om's approval" (L73).

---

## 4. V3: Integrated quotation demo

Differences from V2 [SRC]:
- `app.mjs` imports `createSession` and `setupWorkspace` (L1–8). Submission creates unique `DEMO-VK7-###` references (L53), and there is a "View demo tracking" button (L54–55).
- `operations.mjs` › `createSession()` (L6–24): in-memory records. It rejects ineligible requests (L13), and `update()` accepts only allowlisted statuses and messages (L4–5, L19).
- `workspace.mjs`: inventory table (L10), **demo admin quotation queue** with status and message (L11, L28), and tracking view with history plus a "NOT SENT" message preview (L12–14).

Integration documents (same folder) [HIST]:

| Doc | Use |
|---|---|
| `VERIFIED_BACKEND_INTERFACES.md` | Read-only map of real Bagisto routes, for example `POST /customer/account/quotes`, `GET /api/products` (L24–39). A standalone MOQ endpoint is **missing** (L35). |
| `BUSINESS_INTEGRATION_CONTRACT.md` | Draft contract: "Not an approved production contract" (L3). "MOQ 24 is confirmed; basis is not" (L10). |
| `BACKEND_INTEGRATION_REQUIREMENTS.md` | Integration requirements. Nothing implemented (L3). |
| `INTEGRATION_BLOCKERS.md` | P0 MOQ basis is blocked by owner decision (L9). Quote conversion risk (L11). RFQ idempotency (L14). Estimate 7–13 engineer-days (L37). |
| `CONSOLIDATION_PLAN.md` | "frontend demonstration baseline, not the production commerce foundation" (L5). The demo admin "must not become a production admin route" (L39). |
| `INDEPENDENT_QA_MATRIX.md` | Q1–Q12 backend QA matrix (also in MASTER `05_…`) |
| `INTEGRATION_STATUS.md`, `FEATURE_COMPARISON.md`, `SOURCE_INVENTORY.md`, `ATTRIBUTION.md`, `COPY_MANIFEST.json` | Status, provenance and copy hashes. Note ATTRIBUTION L9: no licence was found for any source. |

Documented commands [HIST, not tested here]:
- Preview: `python3 -m http.server 8769 --bind 127.0.0.1 --directory /Users/aasiom/PROJECTS/VK7SPORTS-INTEGRATION` (`README.md` L10–13).
- Checks: `node --test tests/*.test.mjs` (`README.md` L52–59).
- The copied `VALIDATION.md` still names port 8767 and the V2 folder, so it is stale for V3.

Limitations [HIST]:
- Session-only records, so a refresh loses them.
- No auth, persistence, real inventory or notifications.
- Renderers interpolate fixture data, so **untrusted data would need escaping** (`CONSOLIDATION_PLAN.md` L33–41).
- Image and licence rights unknown.

---

## 5. Frontend ↔ backend relationship

```
V1 intern HTML ──(no link)
V2 Codex demo  ──(no link)          Bagisto storefront (Blade/Vue, B2B Suite theme)
V3 Integrated  ──(no link; interface  ── lives in VK7SPORTS-BACKEND/app, is the only UI
                 map documented only)     wired to real data (MOQ, quotes, orders)
```

| Capability | V1 | V2 | V3 | Bagisto storefront (backend repo) |
|---|---|---|---|---|
| Catalogue | Static cards | Mock | Mock | Real [SRC]. Author-run screenshots [HIST]. |
| Size × colour matrix | — | Mock | Mock | Configurable products. Bagisto adds variants one at a time. A bulk matrix is **not present** [SRC: no matrix view in VK7 or B2B overrides]. |
| MOQ feedback | — | Client-side, basis unconfirmed | Same | Server-side `Moq.php` |
| RFQ / quotation | Toast only | Mock submit | Mock records with admin queue | B2B Suite quotes (defects D-01 to D-05) |
| Tracking | — | — | Mock | Shipment tracking numbers |
| Prices | Retail ₹ hard-coded | None | None | Catalogue and tier prices |

Integration has **not been designed as an approved API contract**. Choosing between a headless frontend (V2/V3 calling Bagisto APIs) and a customised Bagisto storefront is a **founder decision** and is part of the open stack decision. [PROP]
