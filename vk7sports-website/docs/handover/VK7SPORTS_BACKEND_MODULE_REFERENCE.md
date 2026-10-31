# VK7SPORTS Backend Module Reference

**Prepared:** 2026-10-26 by Claude Code (Lead Architect / Documentation role)
**Codebase:** `/Users/aasiom/PROJECTS/VK7SPORTS-BACKEND`, branch `main`, HEAD `498fb8d` (= annotated tag `baseline-2026-10-15`)
**Method:** read-only source inspection. No code was executed.

## Evidence labels

| Label | Meaning |
|---|---|
| **[SRC]** | Verified directly from source code on 2026-10-26 |
| **[HIST]** | Supported by historical documentation or evidence. The 15 Oct runtime evidence was produced by the same agent that wrote the code (author-run). |
| **[AGENT]** | Reported by another AI agent (Codex, Grok) and not re-verified here |
| **[IND]** | Independently tested at runtime. **Nothing in the backend has this label yet.** |
| **[PROP]** | Proposed but not implemented |
| **[BLOCKED/UNK]** | Unknown, or blocked from verification |

---

## 1. Platform and versions

| Item | Value | Evidence |
|---|---|---|
| E-commerce framework | Bagisto **2.5.0** | [SRC] `app/packages/Webkul/Core/src/Core.php` L31 `BAGISTO_VERSION = '2.5.0'` |
| PHP framework | Laravel **13.31.0** | [SRC] `app/composer.lock`; `docs/PINNED-VERSIONS.md` |
| PHP | 8.4 (image pin `php:8.4.26-cli`) | [SRC] `docker/Dockerfile` L5. [HIST] The pin is marked "Inferred" fidelity in `docs/PINNED-VERSIONS.md`. |
| Database | MySQL **8.0.46** | [SRC] `docker/compose.dev.yml`; [HIST] version recorded from the golden dump header |
| Mail (dev) | Mailpit v1.31.5 | [SRC] `docker/compose.dev.yml` |
| B2B extension | `bagisto/b2b-suite` **3.0.1** (MIT, GitHub `bagisto/b2b-ecommerce` ref `a2b178e`) | [SRC] `app/composer.json` L21, `app/composer.lock` |
| Custom module | `VK7\Wholesale`, autoloaded from `app/packages/VK7/Wholesale/src` | [SRC] `app/composer.json` L76; provider at `app/bootstrap/providers.php` L101 |
| Package resolution | `"repositories": [{type: path, url: packages/*/*}]` | [SRC] `app/composer.json` L165–173 |

> **Important:** the repository does **not** contain `app/vendor/`, because it is git-ignored (`.gitignore`). The B2B Suite source therefore only exists after `composer install`, or in the sandbox copy at `~/SANDBOX/bagisto-qa-codex/app/vendor/bagisto/b2b-suite/` (read-only reference). [SRC]
>
> The top-level `composer.json/` and `composer.lock/` in the repository root are **empty directories**, an artifact of the preservation copy. The real manifests are under `app/`. [SRC]

---

## 2. Module map

### 2.1 Bagisto core packages (`app/packages/Webkul/*`): upstream, used as-is except for two patched files

| Package | Responsibility for VK7 | VK7 relevance | Status |
|---|---|---|---|
| `Product` | Products, configurable (size/colour) variants, customer-group tier prices | High | [SRC] upstream. [HIST] screenshots 07–09, 23–24 |
| `Attribute` | Product attributes (size, colour, …) | High | [SRC] upstream |
| `Category` | Catalogue tree | Medium | [SRC] upstream |
| `Inventory` | Inventory sources and stock | High | [SRC] upstream |
| `Checkout` | Cart (`src/Cart.php`); **subclassed by VK7** for MOQ | High | [SRC] |
| `Sales` | Orders, invoices, shipments, refunds, order-number generators. **Patched (0001).** | High | [SRC] |
| `Admin` | Admin panel, roles/ACL (`src/Config/acl.php`), shipment controller. **Patched (0002).** | High | [SRC] |
| `Customer` | Customer accounts and groups | High | [SRC] |
| `CartRule`, `CatalogRule`, `Rule` | Promotions. Cart rules support a `cart|payment_method` condition (`CartRule/src/Repositories/CartRuleRepository.php` L160). | Medium (future full-payment discount) | [SRC] |
| `Payment` | `CashOnDelivery`, `MoneyTransfer` methods | High (payment terms) | [SRC] |
| `Paypal`, `Stripe`, `Razorpay`, `PayU`, `PhonePe`, `PayGlocal` | Gateway packages bundled by upstream Bagisto 2.5 | Unknown | [SRC] present. **[UNK]** Whether any is enabled is stored in the DB configuration, which I did not inspect. None is integrated or verified for VK7. |
| `Shipping` | Shipping methods | Medium | [SRC] |
| `User` | Admin users, `Bouncer` middleware (**rebound by VK7** for 2FA) | High | [SRC] |
| `FPC` | Full-page cache. Skips logged-in customers (`src/CacheProfiles/FullPageCacheProfile.php` L19). | Medium (price visibility) | [SRC] |
| `Shop`, `Theme` | Storefront (Blade + Vue) and theme | Medium | [SRC] |
| `MagicAI`, `SocialLogin`, `GDPR`, `RMA`, `BookingProduct`, `EUWithdrawal`, `Omnibus`, … | Upstream features not used by VK7 | Low | [SRC] present; usage **[UNK]** |

### 2.2 B2B Suite 3.0.1 (`vendor/bagisto/b2b-suite/src`): third-party, unmodified

| Area | Key source | Responsibility | Status |
|---|---|---|---|
| Company registration and approval | `Http/Controllers/Shop/Customer/RegistrationController.php` › `store` L63–78 | Company sign-up. `status = 0` (pending) when `b2b.general.settings.require_company_approval` is set. | [SRC]. [HIST] W1–W3 PASS (author-run) |
| Company users and roles (storefront ACL) | `Config/shop/acl.php`, `Http/Middleware/CustomerBouncerMiddleware.php` › `handle` | Permissions inside a buyer company. **Routes missing from the ACL map are allowed by default** (L24–33). | [SRC] |
| Admin ACL additions | `Config/admin/acl.php`, `Menu.php` | Admin permissions for B2B screens | [SRC] |
| Quotes / RFQ | `Http/Controllers/Shop/QuoteController.php` (`store`, `view`, `updateCart`, `submitQuote`, `rejectQuote`, `quoteConditions`); `Http/Controllers/Admin/QuoteController.php`; `Repositories/CustomerQuoteRepository.php`; `Http/Requests/QuoteRequest.php` | Request, negotiate, accept, convert to cart. Quotes are scoped to a company (`quoteConditions` L585–605). | [SRC]. Has defects (§4) |
| Purchase orders | `DataGrids/*/CustomerPurchaseOrderDataGrid.php`, `Listeners/Order.php` › `afterCreated` | Quote becomes a PO when the order is placed | [SRC] |
| Company catalogues and pricing | `Helpers/CompanyCatalog.php` (`provisionGroup`, `setPrices`, `normalizeTier`, `assignCompanies`) | Per-company catalogue backed by a hidden customer group, with tier prices | [SRC]. [HIST] screenshots 23–24 |
| Company credit / Pay By Credit | `Helpers/CreditManager.php`, `Payment/PayByCredit.php`, `Http/Middleware/EnsurePayByCreditWithinLimit.php` | Credit-limit payment method | [SRC] present. **Not evaluated for VK7.** |
| Requisition lists, quick order | `Http/Controllers/Shop/RequisitionListController.php` | Saved re-order lists | [SRC] present, not evaluated |
| Routes | `Routes/shop-routes.php` (63 `Route::` lines), `Routes/admin-routes.php` (62) | — | [SRC] |
| Schema | `Database/Migrations/` (25 migrations: `b2b_customer_quotes`, `b2b_customer_quote_items`, `…_messages`, `…_attachments`, `…_quotations`, company attributes, catalogues, credit, invitations, …) | — | [SRC] |
| Vendor tests | `tests/e2e-pw/` (Playwright) | Upstream end-to-end suite | [SRC] present. **Not run for VK7.** |

Published view overrides that VK7 commits into the app [SRC, commit `6b6538c`]:
`app/resources/views/vendor/admin/customers/customers/index/create.blade.php`, `app/resources/views/vendor/shop/checkout/cart/request-quote-modal.blade.php`, `…/checkout/cart/summary.blade.php`, `…/components/layouts/account/navigation.blade.php`, `…/customers/account/profile/index.blade.php`, `…/customers/sign-in.blade.php`. The built theme assets are in `app/public/themes/b2b-suite/`.

### 2.3 VK7 Wholesale (`app/packages/VK7/Wholesale/src`): the custom code, 12 files, about 577 lines (commit `7caa01e`)

| File › symbol | Responsibility | How it hooks in | Status |
|---|---|---|---|
| `Moq.php` › `cartViolation`, `assertOrder`, `violation`, `applies` | Minimum order quantity. Modes are `per_style`, `per_variant` and `per_order`. It can be skipped for admin-created orders. | — | [SRC]. [HIST] tests B, M, S PASS (author-run) |
| `Cart.php` › `getErrors` | Adds the `MOQ_NOT_MET` cart error after the core cart checks | Replaces core cart as a singleton (`WholesaleServiceProvider::register` L27) | [SRC] |
| `Providers/WholesaleServiceProvider.php` | Registers everything. Order backstop `Event::listen('checkout.order.save.before', [Moq::class,'assertOrder'])` (L49). Personal-account approval listener (L51–58). Cart notice view (L60–63). | `app/bootstrap/providers.php` L101 | [SRC] |
| `Config/system.php` | Admin settings: **Configure › VK7 Wholesale** (MOQ enabled / min_qty 24 / mode / apply_to_admin_orders; require admin 2FA; personal account approval). **The MOQ default is disabled.** | Merged into core config | [SRC] |
| `Repositories/CustomerQuoteRepository.php` › `updateCart` | Variant-aware quote → cart. It fixes the base B2B version, which kept only the last variant of a style. | Container rebind of the B2B repository (L31) | [SRC]. [HIST] W6 FAIL before the fix, PASS after |
| `OrderNumberSequencer.php` › `getLastId` | Row-locked order numbering using the `vk7_sequences` table | **Only active if selected in admin** (Sales › Order Settings › order number generator). Not bound in code. | [SRC]. [HIST] R0 showed collisions on the default generator |
| `Database/Migrations/2026_10_15_000001_create_vk7_sequences_table.php` | Creates the `vk7_sequences` table and seeds it from `max(orders.id)` | `loadMigrationsFrom` | [SRC] |
| `Exceptions/Handler.php`, `Exceptions/MoqNotMetException.php` | Returns a readable 422 for MOQ or stock rejections, and passes 419/429 through | Rebinds `ExceptionHandler` (L39) | [SRC] |
| `Http/Middleware/Bouncer.php` › `isTwoFactorRequired`, `mustEnrol` | Forces every admin to enrol in 2FA when the setting is on | Rebinds core `Bouncer` (L29) | [SRC]. [HIST] `evidence/2026-10-15-sandbox/2fa/*` |
| `Console/Commands/ResetAdminTwoFactor.php` | Artisan command for admin 2FA recovery | Console only | [SRC] present. [HIST] R1–R4 recovery evidence |
| `Resources/views/cart-notice.blade.php` | Cart banner for MOQ and stock errors | View render event | [SRC] |

There are **no PHP unit tests** for VK7 Wholesale [SRC: no test files under `app/packages/VK7`].

### 2.4 Core patches (direct edits to upstream files; founder decision F9 "retain as-is")

| Patch | File › function | Purpose | Status |
|---|---|---|---|
| `patches/0001-sales-reserve-configurable-variant-stock.patch` | `app/packages/Webkul/Sales/src/Repositories/OrderItemRepository.php` › `manageInventory`, `updateProductOrderedInventories` | Configurable child lines reserve stock. Unpatched code oversold variants. | [SRC]. [HIST] R0 reproduction, R1–R3 PASS |
| `patches/0002-admin-validate-variant-stock-on-shipment.patch` | `app/packages/Webkul/Admin/src/Http/Controllers/Sales/ShipmentController.php` › `isInventoryValidate` | Stops the admin shipping more variant stock than is physically held | [SRC]. [HIST] screenshots 32/33 |

Risks and rules are in `docs/CORE-PATCHES.md`. **Do not edit these two files except to revert or re-apply the patch exactly.** [HIST]

---

## 3. Database

| Topic | Fact | Evidence |
|---|---|---|
| Engine | MySQL 8.0 (`bagisto` dev DB, `bagisto_qa` QA DB) | [SRC] `docker/compose.dev.yml`, `qa/reset.sh` |
| Schema source | Laravel migrations: Bagisto core (`app/packages/Webkul/*/src/Database/Migrations`), B2B Suite (25 migrations), VK7 (1 migration) | [SRC] |
| VK7-specific tables | `vk7_sequences (name PK, value)` only | [SRC] |
| Key VK7 business tables (existing) | `customers` (including companies, `type='company'`, `status`), `customer_groups`, `product_customer_group_prices`, `product_ordered_inventories` (reservations), `orders`/`order_items`, `shipments`, `b2b_customer_quotes`, `b2b_customer_quote_items` | [SRC] migrations |
| Known schema gap | `b2b_customer_quotes.quotation_number` / `po_number` are `string()->nullable()` with **no unique index** | [SRC] B2B migration `2026_06_19_100017_…` L16–17 |
| Seed / golden data | `qa/golden.sql.gz` is **not in the repo** (kept in the private store `~/PROJECTS/VK7SPORTS-BACKEND-PRIVATE`, per commit `b5467c5`). Do not open it without authorisation. | [SRC] `.gitignore`. [AGENT] Codex 26 Oct review |
| Earlier DB designs | `05_DOCUMENTATION_AND_SPECS/02_Original_DB_Schema.docx`, `VK7SPORTS/design/diagrams/vk7sports_ER_Diagram.pdf`. These are **designs for a different stack** and are not the schema of this codebase. | See `VK7SPORTS_DEVELOPMENT_HISTORY.md` |

---

## 4. Known defects and gaps (summary)

The full detail is in `08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_AUDIT_SUMMARY_2026-10-26.md`. Every item below is [SRC] and **not reproduced at runtime**.

| ID | Issue | Location |
|---|---|---|
| D-01 | Duplicate quote/PO numbers (`max(id)+1`, no unique index) | B2B `CustomerQuoteRepository::generateQuotationNumber` |
| D-02 | MOQ is not checked when an RFQ is created | B2B `Shop/QuoteController::store` |
| D-03 | Quote accept → cart is non-atomic | B2B `Shop/QuoteController::updateCart`; VK7 `CustomerQuoteRepository::updateCart` |
| D-04 | The negotiated price persists if the buyer changes the cart quantity | Core `Checkout/src/Cart.php::updateItems` |
| D-05 | No RFQ idempotency | B2B `CustomerQuoteRepository::create` |
| D-07 | Order sequencer is config-activated only | VK7 `OrderNumberSequencer.php` |
| D-13 | Customer ACL is default-allow for unmapped routes | B2B `CustomerBouncerMiddleware::handle` |

**Not implemented [SRC: absent]:** MOQ 100 for custom orders, the 10% advance / 90% COD split, the full-payment discount, the 70–80% custom-order advance, a shortage/backorder workflow (only a store-wide toggle exists), carrier integration, and an actor audit trail.

---

## 5. QA tooling in the repo (inspect only; do not run without approval)

| Path | Purpose | Caution |
|---|---|---|
| `qa/reset.sh` | Drops and re-imports `bagisto_qa` from `qa/golden.sql.gz` | **Destructive.** It needs the golden dump, which is not in the repo. [SRC] |
| `qa/tools/order_driver.py` | HTTP cart/checkout and race driver | [SRC] |
| `qa/tools/repo_race.sh`, `repo_race.php` | DB-level order race that bypasses the cart | [AGENT] Codex: the payload is built before the stock change |
| `qa/tools/e2e_workflow.py` | W1–W10 workflow (23 checks) | [HIST] 23/23 on 15 Oct, author-run |
| `qa/tools/security_regression.py`, `admin_2fa.py`, `bruteforce.py`, `exposure.sh` | Security scenarios | [AGENT] Codex: marker-based isolation assertions are weak |
| `qa/tools/q.sh` | SQL helper | [AGENT] Its exit status does not reliably reflect SQL errors |
| `qa/acceptance_preflight.py` | Environment preflight | [AGENT] References files that are absent from the repo |
| `qa/CODEX-HANDOFF.md` | Independent QA brief (A1–G3) | [HIST] |
| Upstream Pest suites | `app/packages/Webkul/*/tests` (Admin 138, Shop 75, Core 15, FPC 14, … test files) | [HIST] 1225 pass / 11 fail, author-run (`evidence/2026-10-15-sandbox/final/pest-regression.txt`) |
