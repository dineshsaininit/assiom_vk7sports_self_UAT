# VK7SPORTS: Claude Backend Audit Summary, 2026-10-26

**Full report:** `08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_REUSE_AUDIT_2026-10-26.md` (SHA-256 `09fce235de7c61e9bb90005aec1dc6640806459e1214c7be38fabdea44d79d4c`, identical to the original at `~/VK7SPORTS-AUDIT-OUTPUT/`).
**Method:** static, read-only source and report inspection by Claude Code (Opus 5.5). No tests, containers, DB queries, HTTP requests or code changes. The final stack is not selected.
**Companion review:** `06_QA_AND_TESTING/VK7SPORTS_CODEX_INDEPENDENT_QA_EVIDENCE_2026-10-26.md`, a Codex evidence review written the same day. It is a document review, not a test run.

## Verification key (used in every table)

| Code | Meaning |
|---|---|
| **SRC** | Confirmed by source-code inspection (this audit, 26 Oct) |
| **HIST** | Reported in historical evidence. All 15 Oct runtime results are **author-run**, by the same agent that wrote the code. |
| **IND** | Independently tested at runtime. **No finding has this status.** The Codex A–G run on 16 Oct was BLOCKED, and the Codex work on 26 Oct reviewed evidence only. |
| **NV** | Not yet verified at runtime by an independent party |

Paths: **B** = `~/PROJECTS/VK7SPORTS-BACKEND` (HEAD `498fb8d`). **B2B** = `~/SANDBOX/bagisto-qa-codex/app/vendor/bagisto/b2b-suite/src` (B has no `vendor/`). **VK7** = `B/app/packages/VK7/Wholesale/src`.

---

## 1. Backend components discovered

| Component | Version / identity | Location | Status |
|---|---|---|---|
| Bagisto core | 2.5.0, Laravel 13.31.0, PHP 8.4, MySQL 8.0.46 | `B/app/packages/Webkul/*`; pins in `B/docs/PINNED-VERSIONS.md` | SRC; PHP image pin is "Inferred" fidelity (HIST) |
| B2B Suite | 3.0.1, `bagisto/b2b-ecommerce` ref `a2b178e` (lockfile) | B2B (identical tree hash in the eval and qa-codex sandboxes) | SRC |
| VK7 Wholesale (custom, 426 LOC) | Tree hash identical in B, qa-codex and eval sandboxes | VK7 | SRC |
| Core patches 0001 / 0002 | Direct edits to upstream files | `B/patches/`, `B/docs/CORE-PATCHES.md` | SRC; hashes match the qa-codex copy |
| Git baseline | Annotated tag `baseline-2026-10-15` (tag object `5058907…`) → commit `498fb8d` = HEAD | B | SRC. **Correction to the Codex review of 26 Oct:** HEAD and the tag are the *same commit*. The differing hash is the annotated-tag object, not a different commit. |
| QA kit | `B/qa/tools/*`, `B/qa/reset.sh`, `B/qa/acceptance_preflight.py` | B | SRC (inspected only). `reset.sh` is destructive and was not run. |

## 2. Reusable functionality

| Capability | Class | Evidence | SRC | HIST | IND |
|---|---|---|---|---|---|
| Company registration and approval | CODE_PRESENT_NOT_ACCEPTED | B2B `Http/Controllers/Shop/Customer/RegistrationController.php` › `store` L63–78; VK7 `Providers/WholesaleServiceProvider.php` L51–58 | Yes | W1–W3 PASS (`B/evidence/2026-10-15-sandbox/e2e/W1-W10-workflow.txt`) | No |
| Catalogue and configurable variants | CODE_PRESENT_NOT_ACCEPTED | Core `Product/src/Type/Configurable.php`; screenshots 07–09 | Yes | Screenshots | No |
| MOQ 24 at cart, checkout and order | CODE_PRESENT_NOT_ACCEPTED | VK7 `Moq.php` › `cartViolation` / `assertOrder` / `violation`; `Cart.php` › `getErrors`; listener at provider L49 inside the `OrderRepository::createOrderIfNotThenRetry` transaction (L50–53) | Yes | B, M, S PASS (`after-fix/RESULTS.md`) | No |
| Tier and company-catalogue prices | CODE_PRESENT_NOT_ACCEPTED | Core `Product/src/Type/AbstractType.php` L905–1018; B2B `Helpers/CompanyCatalog.php` › `setPrices` / `normalizeTier` | Yes | Screenshots 23–24 | No |
| Quote negotiation (RFQ) | CODE_PRESENT_NOT_ACCEPTED, with defects (§3) | B2B `Http/Controllers/Shop/QuoteController.php`; `Repositories/CustomerQuoteRepository.php` | Yes | W5–W7 PASS after the VK7 fix | No |
| Variant-aware quote → cart | CODE_PRESENT_NOT_ACCEPTED | VK7 `Repositories/CustomerQuoteRepository.php` › `updateCart` | Yes | W6 FAIL before the fix, PASS after (`e2e/W-run-before-quote-fix-FAILED.txt`) | No |
| Stock reservation and oversell protection | CODE_PRESENT_NOT_ACCEPTED | `OrderItemRepository::manageInventory` (+0001); `ShipmentController::isInventoryValidate` (+0002) | Yes | R0 reproduces the bug unpatched; R1–R3, A2–A4, C, D PASS | No |
| Shipments, partial shipments, tracking numbers | CODE_PRESENT_NOT_ACCEPTED | Core Sales/Admin shipments | Yes | W9–W10 PASS | No |
| Admin roles, company-user roles, enforced admin 2FA | CODE_PRESENT_NOT_ACCEPTED | Core `Admin/src/Config/acl.php`; B2B `Config/{admin,shop}/acl.php`; VK7 `Http/Middleware/Bouncer.php` | Yes | Screenshot 25; `evidence/…/2fa/*`; security regression 19/19 | No |
| Row-locked order numbering | CODE_PRESENT_NOT_ACCEPTED (config-activated) | VK7 `OrderNumberSequencer.php` › `getLastId` | Yes | R0 shows collisions on the default; D shows unique numbers | No |

**Absent:** MOQ at RFQ, MOQ 100 for custom orders, 10% advance / 90% COD, full-payment discount, 70–80% custom-order advance. **Partial:** shortage/backorder, which is only a store-wide toggle (`catalog.inventory.stock_options.back_orders`). Absence is confirmed by SRC grep across core, B2B and VK7.

## 3. Confirmed source-code defects (SRC, all NV at runtime, none IND)

| ID | Defect | Exact source | HIST status | Severity if exercised |
|---|---|---|---|---|
| D-01 | **Duplicate quote and PO numbers.** The number is `max(id)+1`, computed outside the creation transaction. The columns are `string()->nullable()` with no unique index. Concurrent RFQs, or deleting the highest row, produce a repeated number. | B2B `Repositories/CustomerQuoteRepository.php` › `generateQuotationNumber` L200–225; callers `Shop/QuoteController.php` L81, `Admin/QuoteController.php` L114; migration `2026_06_19_100017_create_b2b_customer_quotes_table.php` L16–17 | Indirect only (Q6 "reference collisions"; Codex R5 asked for this to be inspected) | High |
| D-03 | **Non-atomic accept → cart.** The quote is committed as `accepted` and the notification sent, then items are removed and added with no transaction. A mid-loop failure leaves a half-replaced cart. | B2B `Shop/QuoteController.php` › `updateCart` L218–227; VK7 `CustomerQuoteRepository::updateCart` L32–63 | Risk only (Q9; Codex C3/E1 BLOCKED) | High |
| D-04 | **Negotiated price applies at any quantity.** Core `updateItems` keeps `custom_price` when the buyer changes quantity, and nothing locks quote lines or re-checks them at order. | Core `Checkout/src/Cart.php` › `updateItems` L348–393 and L999; B2B `Listeners/Order.php` › `afterCreated` | **Not previously reported** (Codex R4 lists "tamper negotiated qty" as a test only) | High (margin) |
| D-05 | **No RFQ idempotency.** The cart is removed only after commit, so parallel or double submits create duplicate quotes, and with D-01 they can share a number. | B2B `CustomerQuoteRepository.php` › `create` L45–80 | Q6 "Idempotency guard MISSING" | Medium–High |
| D-02 | **No MOQ at RFQ.** Only a monetary minimum is checked. | B2B `Shop/QuoteController.php` › `store` L69–74 | Codex A3 / handoff "policy unresolved" | Medium; it counts as a defect only if the owner requires MOQ at RFQ |
| D-07 | The order sequencer is active only through `core_config`, not bound in code, so a fresh install falls back to the colliding default. | VK7 `OrderNumberSequencer.php`; core `Sales/src/Generators/OrderSequencer.php` L32 | R0 collisions; `B/qa/CODEX-HANDOFF.md` | Medium |
| D-08 | An MOQ rejection is retried 3 times, and each attempt logs the full order payload (addresses, email). | Core `Sales/src/Repositories/OrderRepository.php` L90–115 | — | Low (PII in logs) |
| D-09 | Quote attachments are written inside the DB transaction and orphaned on rollback. | B2B `CustomerQuoteRepository.php` › `upload` L89–135 | — | Low |
| D-13 | Customer ACL middleware is default-allow for routes missing from the ACL map. | B2B `Http/Middleware/CustomerBouncerMiddleware.php` › `handle` L24–33 | — | Medium (depends on which routes are unmapped) |

## 4. Suspected risks requiring testing (NV)

| Risk | Basis | Reference |
|---|---|---|
| Last-stock oversell, deadlocks, double dispatch after the patches | HIST author-run only; patches unreviewed for bundle, grouped and downloadable products | `B/docs/CORE-PATCHES.md` risks 1–6; Codex R6 |
| Lost core patches or VK7 overrides on upgrade (brings back D-10 oversell and D-11 last-variant-only quote) | SRC: 2 direct core edits plus 4 container rebinds | `B/docs/CORE-PATCHES.md`; VK7 `WholesaleServiceProvider::register` |
| Cross-company access to quotes, orders or attachments | HIST 19/19 on a small sample; Codex notes the marker-based assertions are weak | `security-regression/*`; Codex R2 |
| Interrupted transaction leaving stranded stock | SRC transaction scope present; E1/E2 BLOCKED | Codex R9 |
| Pest failures (11 in the full suite) not triaged, 2 involving invoice/shipment items from another order | HIST | `B/evidence/2026-10-15-sandbox/final/pest-regression.txt`; Codex review |
| QA tool validity: `q.sh` exit masking, repo-race payload built before the stock change, reset pipeline without pipefail | SRC (tools inspected) and HIST (Codex QA-01/02; 26 Oct review) | `B/qa/tools/q.sh`, `repo_race.php`, `B/qa/reset.sh` |
| Backup restore never demonstrated | HIST (checksums recorded only) | Codex R10 |

## 5. Commercial-policy dependencies (owner decisions; these block final classification)

| Decision | Blocks |
|---|---|
| MOQ counting basis (style, variant or order), and whether MOQ applies at RFQ | 3a acceptance, D-02 |
| Definition of a custom order and its MOQ 100 basis | Custom-order build |
| Custom-order advance (70% or 80%), plus refund and cancellation of advances | Payment build |
| 10/90 COD mechanics (deposit invoice, balance on delivery, ship gating) | Payment build |
| Full-payment discount percentage | Cart-rule configuration (core supports a `cart|payment_method` condition: `CartRule/src/Repositories/CartRuleRepository.php` L160) |
| Shortage/backorder policy (20–30 days, partial allocation) | Inventory workflow |
| Whether prices are hidden from guests or unapproved accounts | D-06 |

The MOQ values in the golden DB (enabled, 24, per_style) are **provisional fixtures**, not owner policy (VK7 `Config/system.php` L18; `CODEX-HANDOFF.md`).

## 6. Security and pricing concerns

| Concern | SRC | HIST | IND |
|---|---|---|---|
| D-04 negotiated-price quantity tampering | Confirmed | Not reported | No |
| D-06 guest price visibility: no hide-price setting; tier rows with `customer_group_id = NULL` apply to everyone (core `AbstractType.php` L905–912) | Confirmed (feature absent) | Handoff L73 flags price leakage | No |
| Cross-company leakage of company-catalogue prices | Not shown. Prices are group-scoped, and FPC skips logged-in users (`FPC/src/CacheProfiles/FullPageCacheProfile.php` L19). | Reported as a risk | No |
| D-13 default-allow customer ACL | Confirmed | — | No |
| Admin 2FA enforcement and recovery | Present (VK7 `Bouncer.php`) | 2FA R1–R4 author-run | No |
| No actor audit trail on order, invoice, shipment and company tables | — | W10 INFO line | No |
| D-08 PII in error logs | Confirmed | — | No |

## 7. Licensing and vendor dependencies

| Item | Finding | Status |
|---|---|---|
| Bagisto core, B2B Suite 3.0.1, VK7 | MIT (`app/LICENSE`, B2B `LICENSE` and `composer.json`) | SRC |
| Transitive (`app/composer.lock`, 182 packages) | 157 MIT. Copyleft: `mpdf/mpdf` GPL-2.0-only, `enshrined/svg-sanitize` GPL-2.0+, `nette/*` BSD/GPL dual, dompdf / htmlpurifier / ar-php LGPL, `apimatic/jsonmapper` OSL-3.0 | SRC. Needs legal review only if the software is distributed. |
| Vulnerabilities | `league/commonmark`, 1 high + 1 medium, as of 15 Oct | HIST (`evidence/2026-10-15-sandbox/composer-audit-licenses.txt`). The audit needs re-running. |
| Vendor maturity | B2B 3.0.0 released 6 Oct 2026, 3.0.1 on 7 Oct (B2B `CHANGELOG.md`). Single vendor (Webkul), tightly coupled to Bagisto 2.5.x. | SRC |
| License keys | Not read; none needed (MIT) | — |

## 8. Outstanding independent QA requirements

All of these are **NV**. Nothing has reached IND.
1. An authorised, isolated environment with verified DB identity and fixed QA tools. Capture the live `core_config` before every case.
2. MOQ: Codex A1–A5, plus RFQ cases once the policy is set.
3. Quotes: B1–B3 asserting **unique quote and PO numbers** (D-01); C1–C3 with *distinct* per-variant negotiated prices; a **cart-quantity-edit-then-checkout** case (D-04); failure injection in `updateCart` (D-03).
4. Inventory: D1–D2, E1–E2, G2, G3; re-run the R0 control on unpatched code.
5. Security: F1–F4; price leakage for guest, pending, other-company and restricted-staff sessions over HTML and JSON (D-06); probes of unmapped B2B routes (D-13); 2FA for all admin roles.
6. Payments (after build), in a provider sandbox only (Codex R8).
7. Upgrade drill and backup-restore drill (Codex R10, R11).
8. Re-run `composer audit`, and triage the 11 Pest failures.

Acceptance rule (from `05_DOCUMENTATION_AND_SPECS/INDEPENDENT_QA_MATRIX.md`): explicit PASS/FAIL evidence from someone other than the author. BLOCKED is never PASS.

## 9. Estimated remediation effort and assumptions

| Work | Est. (1 developer) |
|---|---|
| D-01 unique index, locked sequence and de-dup migration | 0.5–1 d |
| D-03 transactional accept + cart | 1 d |
| D-04 lock quote-line qty and validate quote vs order at save | 1–1.5 d |
| D-05 RFQ idempotency | 0.5 d |
| D-02 MOQ at RFQ (after the owner rule) | 0.5 d |
| D-07, D-08 sequencer binding and retry/log fix | 0.5 d |
| D-06 login-to-see-price (if required) | 1–2 d |
| 10/90 split payment | 4–7 d |
| Full-payment discount | 1–2 d |
| Custom-order type (MOQ 100, advance, specification capture) | 5–10 d |
| Shortage/backorder workflow | 4–8 d |
| Actor audit trail | 2–3 d |
| Catalogue attribute model | 1–2 d |
| **Total** | **about 3–5 developer-weeks** |

**Assumptions:**
- The Bagisto + B2B + VK7 stack is retained.
- A developer experienced in Laravel and Bagisto does the work.
- Owner decisions in §5 arrive before the build.
- No frontend, deployment, data migration, payment-gateway onboarding or independent QA time is included.
- No new defects are found by QA.
- These are static estimates, not commitments.

## 10. Recommended next steps (decision-owner actions; no development started)

1. The owner resolves the §5 policies, starting with MOQ basis and RFQ applicability, the advance/COD mechanics and guest price visibility.
2. Approve an execution environment for independent QA (handoff option F3 a or b), and fix the QA-tool validity issues first.
3. Add D-01, D-03, D-04 and D-05 to the independent QA scope as explicit cases, so they are confirmed or refuted at runtime before any remediation is approved.
4. Make the stack decision with this summary, the full reuse audit (§5.4 options) and the Codex 26 Oct gates (pilot, payment and production all on **HOLD**).
5. Register this summary and the full report in `01_PROJECT_CONTROL/VERIFIED-FILES-MANIFEST.csv` and `CHANGELOG.md`. I did not update them, because this assignment did not authorise modifying existing files.

*STOP.*
