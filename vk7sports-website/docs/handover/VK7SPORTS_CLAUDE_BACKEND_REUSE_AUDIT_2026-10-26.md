# VK7SPORTS: Backend Reuse Audit (Claude Code), 2026-10-26

**Mode:** Static, read-only inspection of local files. No tests, containers, DB queries, HTTP requests, installs or edits were run against any repository.
**Auditor:** Claude Code (Opus 5.5). This audit is independent of the 15 Oct author. It is still static, so it does not count as runtime QA.
**Final stack:** Not selected (out of scope by instruction).

---

## 0. Scope, sources and integrity

### 0.1 Antigravity audit check (step 1)
- `ps`/`pgrep` for `antigrav|language_server` at about 15:13 IST found **no running Antigravity process**. The only Google processes running were the Gemini.app Finder extension and launcher, plus Google Drive.
- `~/.gemini/antigravity-ide/brain/` was last written on 29 Sep 2026, and `~/.gemini/antigravity/brain/` in Apr 2026. Neither shows activity today.
- I did not touch any Antigravity command or output.

### 0.2 Code inspected
| Component | Location (canonical) | Identity |
|---|---|---|
| Bagisto core 2.5.0 (Laravel 13.31.0, PHP 8.4) | `~/PROJECTS/VK7SPORTS-BACKEND/app/packages/Webkul/*` | git `498fb8d`, tag `baseline-2026-10-15` |
| B2B Suite 3.0.1 (`bagisto/b2b-ecommerce` ref `a2b178e`) | `~/SANDBOX/bagisto-qa-codex/app/vendor/bagisto/b2b-suite/src` (the backend repo contains no `vendor/`) | src tree hash `0503f637…`, identical to `~/SANDBOX/bagisto-b2b-eval` |
| VK7 Wholesale (custom, 426 LOC) | `app/packages/VK7/Wholesale/src` | tree hash `383d7f30…`, identical in backend repo, qa-codex and eval sandboxes |
| Core patches 0001/0002 | `app/packages/Webkul/Sales/src/Repositories/OrderItemRepository.php`, `app/packages/Webkul/Admin/src/Http/Controllers/Sales/ShipmentController.php` | file hashes identical in backend repo and qa-codex |

### 0.3 Historical reports used
- **Author-run (15 Oct, same agent that wrote the code, so NOT independent QA):** `evidence/2026-10-15-sandbox/after-fix/RESULTS.md`, `evidence/2026-10-15-sandbox/e2e/W1-W10-workflow.txt` (23/23), `…/W-run-before-quote-fix-FAILED.txt`, `…/security-regression/*`, screenshots 01–33.
- **Independent attempt (Codex, 16 Oct):** `evidence/2026-10-16-codex-qa/INDEPENDENT_BACKEND_QA_REPORT.md` and `CRITICAL_DEFECT_REGISTER.md`. **Verdict: BLOCKED (environment unavailable). All cases A1–G3 were never executed.**
- **Static matrix (15 Oct):** `~/PROJECTS/VK7SPORTS-INTEGRATION/INDEPENDENT_QA_MATRIX.md` (Q1–Q12, all "NOT VERIFIED" at runtime).
- **Handoff:** `qa/CODEX-HANDOFF.md` (21 Oct). It adds price leakage as an open risk.
- I found **no independent runtime QA after 21 Oct**.

### 0.4 Areas excluded on purpose
I did not open `~/PROJECTS/VK7SPORTS-BACKEND-PRIVATE/` (`app.env`, `dot-secrets`, `db`), `~/SANDBOX/bagisto-b2b-eval/.secrets/`, any `.env`, `auth.json` or any license-key material.

### 0.5 Side effect disclosure
At the start I ran `git status -sb` once on `~/PROJECTS/VK7SPORTS-BACKEND`. Git can refresh the index stat cache when it does this, and `.git/` shows mtime 15:15 today, which matches. No tracked content changed. Every later git call used `GIT_OPTIONAL_LOCKS=0`.

---

## 1. Classification key
| Class | Meaning in this audit |
|---|---|
| IMPLEMENTED_AND_TESTED | Code present **and** passed independent runtime QA. **No capability qualifies.** |
| CODE_PRESENT_NOT_ACCEPTED | Working code path exists. Only author-run tests and/or static review exist, with no independent acceptance. |
| PARTIAL | Some primitives exist, but the VK7 business rule is not implemented end to end. |
| DESIGN_ONLY | Described in docs or plans, with no code. |
| ABSENT | No code and no design found. |
| UNKNOWN | Not determinable from local files. |

---

## 2. Capability matrix (step 3–4)

| # | Capability | Class | Evidence (file › function / report) | Notes and gaps |
|---|---|---|---|---|
| 1 | Registration and account approval | CODE_PRESENT_NOT_ACCEPTED | B2B `Http/Controllers/Shop/Customer/RegistrationController.php` › `store` (L63–78: `status = require_company_approval ? 0 : 1`); VK7 `Providers/WholesaleServiceProvider.php` › `boot` L51–58 (personal accounts → status 0 when `vk7.security.storefront.personal_account_approval`); author-run W1–W3 PASS (`e2e/W1-W10-workflow.txt`) | Approval is just a single active/inactive flag. There are no credit or KYC/GST checks and no rejection reason. The approval settings live in the DB config, not in code. |
| 2 | Catalogue and variants (size/colour) | CODE_PRESENT_NOT_ACCEPTED | Core `Product/src/Type/Configurable.php`; screenshots 07–09 (`evidence/2026-10-15-sandbox/`) | This is a generic Bagisto configurable product. The VK7 attribute set (sizes, colours, fabric, GSM, team print) is not defined in code, and catalogue data is fictional. |
| 3a | MOQ 24 standard: cart, checkout, order | CODE_PRESENT_NOT_ACCEPTED | VK7 `Moq.php` › `cartViolation`, `assertOrder`, `violation`, `applies`; `Cart.php` › `getErrors`; backstop listener `WholesaleServiceProvider.php` L49 on `checkout.order.save.before`, which fires inside the order transaction (`Sales/src/Repositories/OrderRepository.php` › `createOrderIfNotThenRetry` L50–53); author-run B, M, S PASS (`after-fix/RESULTS.md`) | The default is **disabled** (`Config/system.php` L22–26). 24 and per_style are only set in the golden DB and are explicitly "provisional". The counting basis (per style, variant or order) still needs owner confirmation. |
| 3b | MOQ 24 at RFQ / quote stage | ABSENT | B2B `Http/Controllers/Shop/QuoteController.php` › `store` L54–110 checks only the monetary `minimum_amount` (L69–74). No MOQ call exists. | See D-02. Below-MOQ quotes can be negotiated and accepted, then fail at checkout. |
| 4 | MOQ 100 for custom orders | ABSENT | `Moq.php` has a single global `min_qty`. No custom-order product type, flag or attribute exists anywhere (grep across core, B2B and VK7). | Needs a "custom order" concept first, then a per-type MOQ. |
| 5a | Tier prices (quantity breaks, company catalogue prices) | CODE_PRESENT_NOT_ACCEPTED | Core `Product/src/Type/AbstractType.php` L905–1018 (customer-group tier resolution); B2B `Helpers/CompanyCatalog.php` › `setPrices`, `normalizeTier`, `provisionGroup`; screenshots 23, 24 | Prices are scoped by a hidden customer group for each catalogue. Tier rows with `customer_group_id = NULL` apply to **all groups, guests included** (L909). |
| 5b | Negotiated prices (via quotes) | CODE_PRESENT_NOT_ACCEPTED (with defects) | B2B `Repositories/CustomerQuoteRepository.php` › `createOrUpdateMessageQuotation`; VK7 `Repositories/CustomerQuoteRepository.php` › `updateCart` (sets `custom_price`); author-run W5–W7 PASS after the VK7 fix (pre-fix FAIL in `W-run-before-quote-fix-FAILED.txt`) | Defects D-03 and D-04 below. |
| 6 | 10% advance / 90% COD | ABSENT | Payment methods are only `Payment/src/Payment/CashOnDelivery.php`, `MoneyTransfer.php` and B2B `Payment/PayByCredit.php`. No grep hit anywhere for deposit, advance or partial payment. | Needs a split-payment model: deposit invoice, balance due on delivery, and order state gating. |
| 7 | Optional full-payment discount (percentage pending) | ABSENT | No implementation. Primitive available: core cart rules support a `cart|payment_method` condition (`CartRule/src/Repositories/CartRuleRepository.php` L160; `Rule/src/Helpers/Validator.php` L96). | This only works once a distinct "full prepayment" payment method exists, and the percentage is still pending. |
| 8 | Custom order 70–80% advance (rule pending) | ABSENT | Same as #6, and no custom-order concept exists (#4). | Blocked by the owner rule as well as by missing code. |
| 9 | RFQ / quotes | CODE_PRESENT_NOT_ACCEPTED (with confirmed defects) | B2B `QuoteController.php` › `store`, `updateCart`, `submitQuote`, `rejectQuote`, `quoteConditions` (company scoping L585–605); `QuoteRequest.php` › `rules` (buyer status allowlist draft/open on route `b2b.shop.quotes.store`, which matches `Routes/shop-routes.php` L48); author-run W5–W7, cross-company view isolation (`security-regression/S-isolation-quote-view-investigation.txt`) | Defects D-01 to D-05. There is no idempotency guard, as the 15 Oct static matrix Q6 also notes. |
| 10 | Inventory (reservation, oversell protection) | CODE_PRESENT_NOT_ACCEPTED | Core `OrderItemRepository` › `manageInventory` (+ patch 0001); `ShipmentController` › `isInventoryValidate` (+ patch 0002); `docs/CORE-PATCHES.md`; author-run R0 control reproduces the oversell on unpatched code, while A2–A4, R1–R3, C, D and W8 PASS | The core patches are direct edits to upstream files, which carries upgrade risk. They have not been reviewed for bundle, grouped or downloadable products (`CORE-PATCHES.md` risks 1–6). |
| 11 | Shortage and backorder (20–30 day fulfilment) | PARTIAL | Only primitive: the global toggle `catalog.inventory.stock_options.back_orders` (`Admin/src/Config/system.php` L2689; `Product/src/Type/Configurable.php` L545; `OrderItemRepository.php` L123); screenshot 21 | There is no lead time, shortage request, partial-allocation or "notify when available" workflow. The toggle is store-wide, so turning it on removes oversell protection everywhere. |
| 12 | Dispatch and tracking | CODE_PRESENT_NOT_ACCEPTED | Core shipments with tracking number and carrier title; partial shipments; author-run W9–W10 PASS (tracking `TESTTRACK-B-1/2`, lifecycle emails) | No carrier or API integration. Tracking is entered by hand. |
| 13 | Admin and role permissions | CODE_PRESENT_NOT_ACCEPTED | Core admin roles (`Admin/src/Config/acl.php`); B2B `Config/admin/acl.php`, `Config/shop/acl.php` (company-user roles, 22 keys each), `Http/Middleware/CustomerBouncerMiddleware.php` › `handle`; VK7 `Http/Middleware/Bouncer.php` › `isTwoFactorRequired`, `mustEnrol`; screenshot 25 (staff denied catalogue); `evidence/2026-10-15-sandbox/2fa/*` | `CustomerBouncerMiddleware` **allows any route not in the ACL map** (L24–33), so the policy is default-allow for unmapped routes. W10 notes: "AUDIT actor columns on order/invoice/shipment/company tables: none", so there is no who-did-what audit trail. |

**Summary:** 0 IMPLEMENTED_AND_TESTED, 9 CODE_PRESENT_NOT_ACCEPTED (counting rows 1, 2, 3a, 5a, 5b, 9, 10, 12, 13), 1 PARTIAL, 0 DESIGN_ONLY, 5 ABSENT (3b, 4, 6, 7, 8), 0 UNKNOWN.

---

## 3. Defects and regressions (step 5)

"REPORTED" means a prior report raised it. "CONFIRMED_BY_STATIC_INSPECTION" means I traced the code path in this audit. Neither has been reproduced at runtime by independent QA.

| ID | Defect | Status | Evidence | Severity (if exercised) |
|---|---|---|---|---|
| D-01 | **Duplicate quote numbers.** The quotation and PO number is `max(id) + 1`, computed **before and outside** the creation transaction, and there is **no unique index** on `quotation_number`/`po_number`. Two concurrent RFQs read the same max and get the same `QO…`/`PO…`. Deleting the highest quote row also causes the number to be reused. | **CONFIRMED_BY_STATIC_INSPECTION** (REPORTED only indirectly: Q6 "reference collisions", Codex B1–B3 BLOCKED) | B2B `Repositories/CustomerQuoteRepository.php` › `generateQuotationNumber` L200–225; called at `Shop/QuoteController.php` › `store` L81 and `Admin/QuoteController.php` L114; migration `2026_06_19_100017_create_b2b_customer_quotes_table.php` L16–17 (`string()->nullable()`, no unique) | High (commercial or document ambiguity, emails sent with a duplicate reference) |
| D-02 | **MOQ not enforced at RFQ.** Quote creation checks only a monetary minimum. A quote for 23 pieces can be created, negotiated and accepted, and is then rejected at checkout by the order backstop. | **CONFIRMED_BY_STATIC_INSPECTION**; REPORTED as "open risk, policy unresolved" (Codex A3, Q3, `CODEX-HANDOFF.md` L71) | `Shop/QuoteController.php` › `store` L69–74; MOQ hooks exist only in `VK7/Wholesale/src/Cart.php` › `getErrors` and the `checkout.order.save.before` listener | Medium (bad UX and wasted negotiation). Whether this counts as a defect depends on the owner's decision. |
| D-03 | **Non-atomic quote → cart conversion.** The buyer's "accept and add to cart" first commits `status = accepted` and sends a notification, then runs `updateCart`. That loop calls `removeItem`, `addProduct`, `custom_price` save and `collectTotals` per item with **no DB transaction**. If item *n* fails (for example out of stock), items 1…n-1 are already replaced, the quote stays `accepted`, and the exception is only flashed. | **CONFIRMED_BY_STATIC_INSPECTION**; REPORTED as a risk (Q9, Codex C3/E1 BLOCKED) | B2B `Shop/QuoteController.php` › `updateCart` L218–227; VK7 `Repositories/CustomerQuoteRepository.php` › `updateCart` L32–63 (and the base version L139–195) | High |
| D-04 | **Negotiated price applies to any quantity.** After conversion, the cart line keeps `custom_price` and `additional.quote_id`. Core `Cart::updateItems` lets the buyer change the quantity while keeping `custom_price`, and nothing in B2B or VK7 locks quote-line quantity. So a price negotiated for 24 pieces can be checked out at, say, 500. The order listener then marks the quote `ordered` without comparing quantities. | **CONFIRMED_BY_STATIC_INSPECTION** (not previously reported) | Core `Checkout/src/Cart.php` › `updateItems` L348–393 and the price path L999; B2B `Listeners/Order.php` › `afterCreated` (no qty/price/status check) | High (direct margin loss). The UI may hide the qty box, but the server does not enforce it. Verify at runtime. |
| D-05 | **No RFQ idempotency.** A double-click or retry creates two quotes and, combined with D-01, can create two quotes with the same number. The cart is removed only after commit (`Cart::removeCart` after the transaction), so a parallel second request still sees the cart. | CONFIRMED_BY_STATIC_INSPECTION (no guard); REPORTED (Q6 "Idempotency guard MISSING") | B2B `CustomerQuoteRepository.php` › `create` L45–80 | Medium–High |
| D-06 | **Price exposure to unauthenticated or unapproved visitors.** Neither core nor B2B has a "hide prices from guests" setting (B2B `Config/admin/system.php` fields reviewed). Guests see list prices, plus any tier rows with `customer_group_id = NULL`. Company catalogue prices are group-scoped, and FPC skips logged-in customers (`FPC/src/CacheProfiles/FullPageCacheProfile.php` L19), so **cross-company** leakage is not shown statically. | Guest list-price visibility: **CONFIRMED_BY_STATIC_INSPECTION** (missing feature). Cross-company price leakage: **REPORTED** (`CODEX-HANDOFF.md` L73), **not confirmed**. | `Product/src/Type/AbstractType.php` L905–912 | Medium. High if the business requires login-to-see-price. |
| D-07 | Order-number collisions on the default sequencer. The VK7 row-locked `OrderNumberSequencer` only works if the admin config selects it, and it is not bound in code. A fresh install or a config reset falls back to the colliding default. | REPORTED (R0 "order-number collisions") and CONFIRMED_BY_STATIC_INSPECTION (wiring) | `VK7/Wholesale/src/OrderNumberSequencer.php`; `Sales/src/Generators/OrderSequencer.php` L32; `CODEX-HANDOFF.md` ("active only via core_config") | Medium (configuration drift) |
| D-08 | An MOQ rejection is retried up to 3 times, and **each attempt logs the full order payload** (addresses, email) at error level. `MoqNotMetException` is not in the no-retry list. | CONFIRMED_BY_STATIC_INSPECTION | `Sales/src/Repositories/OrderRepository.php` › `createOrderIfNotThenRetry` L90–115 | Low (PII in logs, noise) |
| D-09 | Quote attachments are written to storage inside the DB transaction. If the transaction rolls back, the files are orphaned. | CONFIRMED_BY_STATIC_INSPECTION | B2B `CustomerQuoteRepository.php` › `upload` L89–135 | Low |
| D-10 | Configurable variants oversold (unpatched core) and admin able to ship beyond stock | REPORTED and fixed by core patches 0001/0002. The fix has only author-run verification. | `docs/CORE-PATCHES.md`; `after-fix/R0-control-unpatched-race.txt`; screenshots 32/33 | Critical if a patch is lost during an upgrade |
| D-11 | Base B2B quote → cart kept only the last variant of a style | REPORTED and fixed by the VK7 override (W6 FAIL before, PASS after) | `W-run-before-quote-fix-FAILED.txt` L12–15; VK7 `CustomerQuoteRepository::updateCart` L37–39 | High if the override binding is lost |
| D-12 | QA tooling: `q.sh` always exits 0, and the repo-race builder validates stock before the transaction | REPORTED (Codex QA-01/QA-02) | `qa/tools/q.sh`; `qa/tools/repo_race.php` | Test-validity risk |

---

## 4. License and vendor-maintenance risk (step 6)

I read only metadata and license texts. I did not read any keys.

| Item | Finding | Risk |
|---|---|---|
| Bagisto core | MIT (`app/LICENSE`, `composer.json`) | Low (license) |
| B2B Suite 3.0.1 | MIT (`vendor/bagisto/b2b-suite/LICENSE`, composer `license: MIT`), sourced from public GitHub `bagisto/b2b-ecommerce` | Low on license. **Medium–High on maintenance:** 3.0.0 shipped on 6 Oct 2026 and 3.0.1 on 7 Oct 2026, so this is a brand-new major line with 1 patch release. It ships from a single vendor (Webkul). The suite overrides core views and repositories, which couples it tightly to Bagisto 2.5.x. |
| Transitive licenses (`composer.lock`, 182 pkgs) | 157 MIT. Copyleft packages: `mpdf/mpdf` (GPL-2.0-only), `enshrined/svg-sanitize` (GPL-2.0-or-later), `nette/*` (BSD/GPL dual), `dompdf/*`, `htmlpurifier`, `ar-php` (LGPL), `apimatic/jsonmapper` (OSL-3.0) | Low for a server-side, non-distributed SaaS. **Needs legal review** before any on-premises or distributed delivery (GPL-2.0-only mpdf). |
| Known vulnerabilities | `composer audit` on 15 Oct: `league/commonmark`, 1 high (GHSA-3q6v-r5mr-hxv8, DoS) and 1 medium (GHSA-97jj-33gv-5xf9), plus one more truncated entry (≤0.22.0) | Medium. The audit needs re-running. It is 11 days old. |
| Core forks | 2 direct edits to upstream core files (patches 0001/0002), plus 4 container rebindings in VK7 (Cart, Bouncer, CustomerQuoteRepository, ExceptionHandler) | **High upgrade friction.** Every Bagisto or B2B upgrade needs a re-diff and a re-run of R0, A2–A4, R1–R3, C, D and W1–W10. A silent override loss brings back D-10 and D-11. |
| Platform pins | Laravel 13.31, PHP 8.4.26, MySQL 8.0.46 (`docs/PINNED-VERSIONS.md`). The PHP image pin is "Inferred" fidelity. | Low–Medium |
| Bus factor | All custom code and all runtime evidence come from one AI author, and independent QA has never executed | High (process) |

---

## 5. Reuse strategy estimate (step 7). Not a stack decision.

### 5.1 What is reusable as-is (if this stack is chosen)
- Bagisto catalogue, configurable variants, customer groups, cart rules, shipments and tracking, admin ACL.
- B2B Suite company accounts and approval, company users and roles, company catalogues and tier prices, the quote negotiation UI and data model.
- VK7 Wholesale: the MOQ engine (`Moq.php`, a small and readable module), the 422 error mapping, the admin 2FA enforcement, the row-locked order sequencer, and the variant-aware quote → cart override.

### 5.2 What must be fixed before reuse (estimated effort, single developer)
| Work item | Addresses | Est. effort |
|---|---|---|
| Unique index and locked sequence for quote/PO numbers, with a data migration to de-dup | D-01, D-05 | 0.5–1 day |
| Wrap the accept + `updateCart` path in a single transaction, or compensate on failure | D-03 | 1 day |
| Lock quote-line quantity in the cart, and validate qty/price/accepted status against the quote at order save | D-04 | 1–1.5 days |
| RFQ idempotency key (per cart, one open quote) | D-05 | 0.5 day |
| MOQ check at RFQ create/submit (once the owner rule is set) | D-02 | 0.5 day |
| Bind the sequencer in code, not only in config | D-07 | 0.25 day |
| Add MoqNotMetException to the no-retry list, and scrub the order-payload log | D-08 | 0.25 day |
| Guest price hiding / login-to-see-price (if required) | D-06 | 1–2 days |

### 5.3 What must be built new
| Capability | Est. effort | Blocked by owner decision? |
|---|---|---|
| Split payment: 10% advance + 90% COD (deposit invoice, balance tracking, order gating) | 4–7 days | Partly (refund and cancellation rules) |
| Full-payment discount (payment method + cart rule) | 1–2 days | **Yes** (percentage) |
| Custom-order type: MOQ 100, 70–80% advance, artwork/spec capture | 5–10 days | **Yes** (exact advance rule, custom-order definition) |
| Shortage/backorder workflow (per-product backorder, lead time, partial allocation, buyer notification) | 4–8 days | **Yes** (shortage policy) |
| Audit trail of admin actor on orders, invoices, shipments and companies | 2–3 days | No |
| Owner-approved catalogue attribute model | 1–2 days | Yes (attribute list) |

**Rough total** if this stack is chosen: about 3–5 developer-weeks of new and fixed backend work, plus independent QA (§6). This excludes frontend, deployment and data migration. These are estimates, not commitments.

### 5.4 Strategy options (for the decision owner, not a selection)
1. **Adopt and harden.** Keep Bagisto + B2B + VK7 and apply §5.2 and §5.3. This is the fastest route to quotes, catalogues and accounts. Long-term, it carries the core-patch and vendor-coupling cost.
2. **Reuse as a reference.** Keep the VK7 business rules (MOQ grouping, sequencer pattern, variant-aware conversion) and the QA matrix as specs and test oracles, then implement on another stack.
3. **Hybrid.** Use Bagisto for catalogue, accounts and admin only, and build RFQ and payments as VK7-owned modules so the newest and riskiest vendor code (B2B quotes) is avoided.

---

## 6. Required independent QA before approval

No runtime claim below may be accepted on the basis of the 15 Oct author-run results.

1. **Environment gate:** an approved execution profile (Codex F3 option a or b), `qa/reset.sh` against the `bagisto-qa` project only, and the live `core_config` captured for `vk7.%`, `b2b.%` and the order-number generator before each scenario.
2. **MOQ:** Codex A1–A5 (23/24, repository bypass, per_style/per_variant/per_order), plus the D-02 RFQ cases once the owner rule exists.
3. **Quotes:** B1–B3 (double-click, parallel, retry). **Assert unique quotation/PO numbers** (D-01). Then C1–C3 (multi-variant conversion, negotiated mapping, shortage after offer). Then a new case: **edit quote-line qty in the cart and check out** (D-04). Then failure injection during `updateCart` (D-03).
4. **Inventory:** D1–D2 races, E1–E2 rollback, G2 repeat order POST, G3 duplicate dispatch. Re-run R0 on unpatched code to show the patches still matter.
5. **Security:** F1–F4 (pending account, cross-company, retailer→admin, unauthenticated). **Price leakage:** check guest, pending and other-company sessions against company catalogue and tier prices in HTML and JSON (D-06). Check that 2FA enforcement covers every admin role. Probe unmapped B2B routes for the default-allow ACL.
6. **Payments** (after build): the advance/COD split, full-payment discount, and custom-order advance against approved owner rules.
7. **Upgrade drill:** apply the next Bagisto 2.5.x / B2B 3.0.x patch release, re-apply patches and overrides, and re-run items 2–5.
8. **Dependency:** re-run `composer audit` and do a license review for GPL-2.0-only `mpdf` if any distribution is planned.

Acceptance criterion (taken from `VK7SPORTS-INTEGRATION/INDEPENDENT_QA_MATRIX.md`): every case needs explicit PASS/FAIL evidence from a party other than the code author. BLOCKED never counts as PASS.

---

## 7. Open owner decisions that block classification
MOQ counting basis (per style, variant or order) and whether MOQ applies at RFQ. Definition of a custom order and its MOQ 100 basis. Exact advance percentage for custom orders (70 or 80). Full-payment discount percentage. Shortage and backorder policy (20–30 days). Whether prices must be hidden from guests or unapproved accounts. Refund and cancellation rules for advances.

*End of audit. STOP.*
