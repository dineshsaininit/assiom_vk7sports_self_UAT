# VK7SPORTS Technical Intern Handover

**Prepared:** 2026-10-26 by Claude Code (Lead Architect / Documentation role).

**Source of roles:** the AASIOM assignment brief of 26 Oct 2026.
- **None of these four names appears in any VK7SPORTS project file yet.** The earlier documents name other contributors; see `VK7SPORTS_DEVELOPMENT_HISTORY.md`.
- The roles should be confirmed in `01_PROJECT_CONTROL` by the founder.

**Scope rule:** this handover assigns **study and documentation work only**. No intern task below depends on an unresolved commercial policy, and no implementation starts without founder approval.

---

## Shared starting point (all four interns)

1. Read `VK7SPORTS_DEVELOPER_ONBOARDING.md` §1 (ground rules) and §2 (reading path).
2. Understand these five facts:
   - The only executable backend is **Bagisto 2.5.0 + B2B Suite 3.0.1 + VK7 Wholesale** in `~/PROJECTS/VK7SPORTS-BACKEND` (`main` @ `498fb8d`).
   - All three frontends are **mock demos**, with no backend connection.
   - **Nothing has been independently tested.** All runtime passes were author-run.
   - The commercial rules are **provisional or pending**: MOQ basis, payments, custom orders, shortage and price visibility.
   - The final technology stack is **not selected**.
3. **Approval required for every intern:** running Docker or the backend, running any test or script, Git commits, pushes or remotes, opening anything in `VK7SPORTS-BACKEND-PRIVATE`, contacting the client, and any code change.

---

## 1. Deepanjal: Backend development

| # | Item | Detail |
|---|---|---|
| 1 | Components to study | VK7 Wholesale package; B2B Suite quotes, companies and catalogues; Bagisto Checkout/Sales order pipeline; the two core patches |
| 2 | Documents | `VK7SPORTS_BACKEND_MODULE_REFERENCE.md`, `VK7SPORTS_CODEBASE_ARCHITECTURE.md` §4–5, `M/08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_REUSE_AUDIT_2026-10-26.md`, `~/PROJECTS/VK7SPORTS-BACKEND/docs/CORE-PATCHES.md`, `qa/CODEX-HANDOFF.md` |
| 3 | Code locations | `app/packages/VK7/Wholesale/src/**`; `app/packages/Webkul/Sales/src/Repositories/OrderRepository.php`, `OrderItemRepository.php`; `app/packages/Webkul/Checkout/src/Cart.php`; B2B (read-only sandbox copy) `src/Http/Controllers/Shop/QuoteController.php`, `src/Repositories/CustomerQuoteRepository.php`, `src/Listeners/Order.php` |
| 4 | Functionality to understand | How VK7 rebinds Cart, Bouncer and the quote repository. How MOQ works as a cart error plus the order backstop inside the transaction. The quote lifecycle (draft → open → negotiation → accepted → ordered). Stock reservation and shipment deduction. The order-number sequencer and why it is config-activated. |
| 5 | Open issues for this role | D-01 duplicate quote numbers; D-03 non-atomic accept → cart; D-04 negotiated price at any quantity; D-05 RFQ idempotency; D-07 sequencer binding; D-08 retry/log; D-13 default-allow ACL; core-patch upgrade risk |
| 6 | Start now (read-only or docs) | (a) Write a sequence diagram of RFQ → order from source, with file:line references. (b) For each of D-01, D-03, D-04, D-05 and D-07, write a **design note** covering the root cause, the proposed fix location (VK7 package only) and the test needed. **Do not code it.** (c) List every `Event::listen` and container rebind across VK7 and B2B. |
| 7 | Needs approval | Any code change, including the D-01 to D-13 fixes. Running the Docker stack or Pest tests. Any work on payments (10/90 COD, advance, discount), custom orders (MOQ 100) or shortage/backorder: **these are blocked until the owner decides the policy**. |

## 2. Dinesh Saini: Frontend development

| # | Item | Detail |
|---|---|---|
| 1 | Components to study | V1 intern HTML prototype; V2 Codex catalogue (size × colour matrix, MOQ evaluation); V3 integrated demo (admin queue, tracking); Bagisto Shop theme and the six B2B/VK7 view overrides |
| 2 | Documents | `VK7SPORTS_FRONTEND_REFERENCE.md`; `~/PROJECTS/VK7SPORTS-INTEGRATION/VERIFIED_BACKEND_INTERFACES.md`, `BUSINESS_INTEGRATION_CONTRACT.md` (draft), `CONSOLIDATION_PLAN.md`; `M/05_DOCUMENTATION_AND_SPECS/VK7SPORTS_Figma_UIUX_Spec.md` |
| 3 | Code locations | `~/PROJECTS/VK7SPORTS/app/VK7SPORTS_Prototype/*.html`; `~/PROJECTS/VK7SPORTS-CODEX-FRONTEND/{app,model,data}.mjs`; `~/PROJECTS/VK7SPORTS-INTEGRATION/{app,operations,workspace}.mjs`; backend `app/resources/views/vendor/shop/**`, `app/packages/Webkul/Shop/src/Resources/views/` |
| 4 | Functionality to understand | Which screens exist in which version. That no frontend calls an API. How `model.mjs::evaluate()` handles the MOQ basis, and why "unconfirmed" is never eligible. How the real Bagisto storefront renders cart, RFQ modal and account. |
| 5 | Open issues for this role | Headless vs Bagisto-theme direction (founder/stack decision). No bulk size × colour matrix exists in Bagisto. Price-visibility policy (DEC-006, D-06). Unescaped fixture interpolation in V2/V3 (`CONSOLIDATION_PLAN.md` L33–41). Image and licence rights unknown (`ATTRIBUTION.md` L9). The MASTER copies lack tests. |
| 6 | Start now (read-only or docs) | (a) Build a screen inventory that maps each screen to V1/V2/V3/Bagisto status. (b) Gap list against the Figma spec. (c) Map V3 demo actions to the real Bagisto routes in `VERIFIED_BACKEND_INTERFACES.md`, marking which route is missing (for example, there is no standalone MOQ endpoint). (d) Accessibility review notes from reading the markup. |
| 7 | Needs approval | Running the demo servers or `node --test`. Any new frontend code or framework choice (Next.js is mentioned in plans but **not approved**). Integrating with the backend API. Any UI showing prices, payment options or custom-order flows (policy pending). |

## 3. Aryan Vasisth: Database, research and technical coordination

| # | Item | Detail |
|---|---|---|
| 1 | Components to study | Bagisto MySQL schema (core migrations); B2B Suite migrations (25); `vk7_sequences`; inventory reservation tables; the historical, unimplemented PostgreSQL designs |
| 2 | Documents | `VK7SPORTS_BACKEND_MODULE_REFERENCE.md` §3; `VK7SPORTS_DEVELOPMENT_HISTORY.md` (database rows); `M/05_DOCUMENTATION_AND_SPECS/02_Original_DB_Schema.docx`; `~/PROJECTS/VK7SPORTS/design/diagrams/vk7sports_ER_Diagram.pdf`; `M/01_PROJECT_CONTROL/MASTER-STATUS.md` (restore drill, VK7-DEV-005 customer-group findings) |
| 3 | Code locations | `app/packages/Webkul/*/src/Database/Migrations/`; B2B `src/Database/Migrations/` (sandbox copy); `app/packages/VK7/Wholesale/src/Database/Migrations/` |
| 4 | Functionality to understand | Customers vs companies (`customers.type`). Customer groups and how they drive tier and catalogue prices. `product_ordered_inventories` (reservations). Quote tables. Why the earlier PostgreSQL designs do not apply to this codebase. |
| 5 | Open issues for this role | No unique index on quote and PO numbers (D-01). Restore drill status is contradictory (VERIFIED vs no raw logs). Orphan customer-group records (VK7-DEV-005). Decision-ID collisions (VK7-DEV-002). F4, F5 and F7 are undocumented. The stack decision is open. |
| 6 | Start now (read-only or docs) | (a) Write an ER document of the **actual** Bagisto + B2B + VK7 tables relevant to VK7, built from the migration files. (b) A comparison table of the intern schema (Aug), the Task 2 design and the actual Bagisto tables. (c) Coordination register: consolidate F/DEC/G/VK7-DEV decision IDs into one list and flag gaps for the founder. (d) Research brief on Indian B2B payment models (advance + COD) as **input** to an owner decision, not as a design. |
| 7 | Needs approval | Any DB query, import, dump access or restore (dumps are in private storage). Schema changes or migrations. Fixing contradictions in project-control files (propose them; the founder or document owner edits). |

## 4. Lavanya Srivastav: Documentation and QA support

| # | Item | Detail |
|---|---|---|
| 1 | Components to study | QA kit (`qa/`), historical evidence (`evidence/`), the QA matrices, and the evidence-labelling conventions |
| 2 | Documents | `M/05_DOCUMENTATION_AND_SPECS/INDEPENDENT_QA_MATRIX.md`; `~/PROJECTS/VK7SPORTS-BACKEND/qa/CODEX-HANDOFF.md`; `evidence/2026-10-16-codex-qa/INDEPENDENT_BACKEND_QA_REPORT.md`; `M/06_QA_AND_TESTING/VK7SPORTS_CODEX_INDEPENDENT_QA_EVIDENCE_2026-10-26.md`; `M/08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_AUDIT_SUMMARY_2026-10-26.md` §8; all docs in this `CODEBASE_HANDOVER` folder |
| 3 | Code locations | `~/PROJECTS/VK7SPORTS-BACKEND/qa/tools/*`, `qa/reset.sh` (read only, **never run**), `evidence/2026-10-15-sandbox/**`; frontend `tests/*.test.mjs` in V2/V3 |
| 4 | Functionality to understand | The difference between author-run, agent-reported and independent results. What each historical test (R0–R3, A, B, C, D, M, S, W1–W10) checked. Why "BLOCKED" is never "PASS". Known weaknesses of the QA tools (q.sh exit status, the repo-race payload, marker-based isolation checks). |
| 5 | Open issues for this role | Independent acceptance has never been executed. New test cases are needed for D-01, D-03, D-04 and D-06. 11 Pest failures need triage. Documentation contradictions are listed in `VK7SPORTS_DEVELOPMENT_HISTORY.md` §4. The onboarding setup is unverified. |
| 6 | Start now (read-only or docs) | (a) A traceability matrix linking requirement → QA case (A–G / Q1–Q12) → evidence file → status. (b) Draft written test cases for D-01, D-03, D-04 and D-06 using fictional data, **without executing them**. (c) A glossary and documentation index for the future GitHub `docs/`. (d) Proof-read these handover documents against the source paths, and record any broken references. |
| 7 | Needs approval | Executing any test, script or environment. Changing existing reports or the project-control registers. Publishing any document to GitHub. |

---

## Items no intern may start (blocked by commercial policy)

| Blocked item | Waiting for |
|---|---|
| MOQ basis change or MOQ at RFQ | Owner: per_style / per_variant / per_order, and whether MOQ applies at RFQ |
| Custom-order flow (MOQ 100) | Owner: definition of a custom order |
| 10% advance / 90% COD, custom-order 70–80% advance, full-payment discount | Owner: payment rules, refund and cancellation, discount percentage |
| Shortage/backorder (20–30 days) | Owner: shortage policy |
| Guest price hiding | Owner: DEC-006 final rule |
| Production stack and frontend framework | Founder: stack decision |

## Suggested first-week cadence (proposal)

- **Days 1–2:** shared reading.
- **Day 3:** each intern presents a 10-minute walkthrough of their area, from the source.
- **Days 4–5:** the read-only and documentation tasks in item 6 above. The outputs go to the founder for review before any task needing approval begins.
