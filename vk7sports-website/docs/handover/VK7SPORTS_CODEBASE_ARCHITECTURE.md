# VK7SPORTS Codebase Architecture

**Prepared:** 2026-10-26 by Claude Code (read-only). This document describes **what exists**. It does not describe the target architecture, because the final stack has **not** been selected.
**Labels:** [SRC] source-verified · [HIST] historical document · [AGENT] other AI agent · [IND] independently tested (none) · [PROP] proposed · [UNK] unknown or blocked.

---

## 1. Authoritative codebase

| Component | Authoritative location | Why |
|---|---|---|
| **Backend (and the only data-connected storefront)** | `~/PROJECTS/VK7SPORTS-BACKEND`, `main` @ `498fb8d`, tag `baseline-2026-10-15` | It is the only executable backend. It is under Git, its content is hash-identical to the 15 Oct sandbox and the QA copy, and it was preserved by founder decision F1. [GIT][SRC] |
| Frontend prototype V1 | `~/PROJECTS/VK7SPORTS/app/VK7SPORTS_Prototype` @ `144008c` | Tracked in Git with two remotes [GIT] |
| Frontend prototypes V2/V3 | `~/PROJECTS/VK7SPORTS-CODEX-FRONTEND`, `~/PROJECTS/VK7SPORTS-INTEGRATION` | Original folders, containing tests and docs. The MASTER copies are incomplete. [SRC] |
| Documents | `~/PROJECTS/VK7SPORTS-MASTER` | Canonical document store (DEC-007) [HIST] |

**Not authoritative:**
- **Sandboxes:** `~/SANDBOX/bagisto-b2b-eval`, `~/SANDBOX/bagisto-qa-codex`. These are historical runtime copies. Keep them read-only.
- **Copies:** `03_FRONTEND_AND_PROTOTYPES`, the Grok package, and the backups in `~/PROJECTS/vk7sports-backups`.
- **Private store:** `~/PROJECTS/VK7SPORTS-BACKEND-PRIVATE` holds secrets and dumps. Never use it as source.

The newest files are **not** automatically authoritative. For example, the MASTER frontend copies (22 Oct) are newer than the originals (15 Oct) but are missing the tests.

---

## 2. System overview (as built)

```
                         ┌────────────────────────────────────────────────────────────┐
  Retailer (browser) ───▶│  Bagisto 2.5.0 storefront (Blade + Vue, B2B Suite theme)    │
  Admin/staff (browser) ▶│  Bagisto admin panel (+ B2B screens, VK7 settings)          │
                         │────────────────────────────────────────────────────────────│
                         │  Laravel 13.31 / PHP 8.4  (php artisan serve in Docker)     │
                         │   ├─ Webkul core packages (Product, Checkout, Sales, …)     │
                         │   │    └─ patched: Sales OrderItemRepository, Admin Shipment│
                         │   ├─ B2B Suite 3.0.1 (companies, quotes, catalogues, credit)│
                         │   └─ VK7\Wholesale (MOQ, sequencer, quote→cart, 2FA, 422)   │
                         └───────────────┬───────────────────────┬────────────────────┘
                                         │                       │
                                 MySQL 8.0.46              Mailpit (dev mail trap)
                                 (bagisto / bagisto_qa)

  Frontend prototypes V1/V2/V3 ── static or ES-module demos, NO connection to the above
```
[SRC] `docker/compose.dev.yml`, `app/bootstrap/providers.php` L100–101.

---

## 3. Layers and responsibilities

| Layer | Implementation | Key paths | Status |
|---|---|---|---|
| Presentation (real) | Bagisto Shop and Admin views. Six published B2B/VK7 overrides. Built B2B theme. | `app/packages/Webkul/Shop`, `app/packages/Webkul/Admin`, `app/resources/views/vendor/**`, `app/public/themes/b2b-suite/` | [SRC]. [HIST] screenshots |
| Presentation (demo) | V1 HTML; V2/V3 ES modules | See `VK7SPORTS_FRONTEND_REFERENCE.md` | [SRC], mock only |
| Domain: catalogue and pricing | Configurable products, customer-group tier prices, company catalogues | `Webkul/Product`, B2B `Helpers/CompanyCatalog.php` | [SRC] |
| Domain: B2B accounts | Company registration and approval, company roles | B2B `RegistrationController`, `Config/shop/acl.php` | [SRC] |
| Domain: quotes | RFQ, negotiation, quote → cart → PO | B2B `QuoteController`, `CustomerQuoteRepository`; VK7 override | [SRC], with defects D-01 to D-05 |
| Domain: ordering rules | MOQ (cart error and order backstop), order numbering | VK7 `Moq.php`, `Cart.php`, `OrderNumberSequencer.php` | [SRC] |
| Domain: inventory and fulfilment | Reservation on order, deduction on shipment, tracking | `Webkul/Sales`, `Webkul/Admin` (patched), `Webkul/Inventory` | [SRC]. [HIST] author-run races |
| Payments | Cash on Delivery, Money Transfer, Pay By Credit (B2B). Gateway packages present but VK7 use is unknown. | `Webkul/Payment`, B2B `Payment/PayByCredit.php` | [SRC]. **No advance/COD split.** |
| Security | Admin ACL, admin 2FA enforcement (VK7), company ACL, CSRF (Laravel) | `Webkul/User`, VK7 `Http/Middleware/Bouncer.php`, B2B `CustomerBouncerMiddleware` | [SRC]. [HIST] author-run security tests |
| Persistence | MySQL via Laravel migrations (core + B2B + 1 VK7) | `*/Database/Migrations` | [SRC] |
| Runtime | Docker: PHP 8.4 CLI image, MySQL, Mailpit; loopback-only ports | `docker/` | [SRC]. **Not started from this repo yet** (Docker access is decision F2/F3). |

---

## 4. Key runtime flows (source-traced)

### 4.1 Retailer onboarding
Registration form → B2B `RegistrationController::store` → customer `type=company`, `status=0` if approval is required → admin activates the account → login is allowed. [SRC]
Personal (non-company) accounts can also be held pending through the VK7 listener (`WholesaleServiceProvider` L51–58). [SRC]

### 4.2 Direct order with MOQ
1. Add to cart.
2. VK7 `Cart::getErrors` → `Moq::cartViolation` shows the `MOQ_NOT_MET` notice.
3. Checkout → `OrderRepository::createOrderIfNotThenRetry`. Inside a DB transaction, the `checkout.order.save.before` event fires `Moq::assertOrder` (backstop), then the order is saved.
4. `manageInventory` reserves stock (patch 0001) and the transaction commits. [SRC]

### 4.3 Quote (RFQ) to order
1. Cart → "Request quote" → B2B `Shop/QuoteController::store`. This checks only a monetary minimum (**no MOQ**). The quote number comes from `max(id)+1` (**D-01**). Quote and items are saved in a transaction, then the cart is removed.
2. Admin negotiates (`Admin/QuoteController`).
3. Buyer accepts → `updateCart`. Status is committed as `accepted` first, then the VK7 variant-aware `updateCart` rebuilds the cart **without a transaction** (**D-03**). The cart line gets `custom_price`, which persists if the buyer changes the quantity (**D-04**).
4. Checkout (§4.2). The B2B `Listeners/Order::afterCreated` marks the quote `ordered`/PO. [SRC]

### 4.4 Fulfilment
Admin invoice → shipment (patch 0002 checks physical stock) → tracking number → buyer sees tracking. Partial shipments are supported. [SRC]. [HIST] W9–W10.

---

## 5. Extension pattern (how VK7 customises Bagisto)

VK7 **does not edit vendor code**. Instead it uses Laravel container rebinding and events in `WholesaleServiceProvider` [SRC]:

| Mechanism | Example |
|---|---|
| Singleton or bind override | `BaseCart → VK7\Cart`, `BaseBouncer → VK7 Bouncer`, `B2B CustomerQuoteRepository → VK7 override`, `ExceptionHandler → VK7 Handler` |
| Event listener | `checkout.order.save.before` (MOQ backstop), `customer.registration.after` (approval) |
| View render event | `bagisto.shop.checkout.cart.breadcrumbs.after` (cart notice) |
| Admin config | `Config/system.php` merged into `core` config (Configure › VK7 Wholesale) |
| Migration | `vk7_sequences` |

The **exceptions** are the two core patches (F9), which edit upstream files directly. New code should follow the rebinding pattern inside `app/packages/VK7/`.

---

## 6. External services and integrations

| Service | Status |
|---|---|
| Mail | Mailpit dev trap only [SRC]. No production SMTP is configured in the repo [UNK]. |
| Payment gateways (PayPal, Stripe, Razorpay, PayU, PhonePe, PayGlocal) | Upstream packages are present [SRC]. Enablement is in the DB config [UNK]. **Not integrated or verified for VK7.** |
| Elasticsearch, S3, Reverb, Octane, Socialite, laravel/ai | Declared upstream dependencies in `app/composer.json` [SRC]. VK7 use is unknown [UNK]. |
| Carriers / shipping APIs | None. Tracking numbers are entered by hand. [SRC] |
| CDNs (frontend V1) | Google Fonts, Unsplash images [SRC] |
| GitHub | V only (`AASIOM8`, `Anvora-Global` remotes). The backend has **no remote**. [GIT] |

---

## 7. Architectural risks

1. Two direct core patches make upgrades risky (`B/docs/CORE-PATCHES.md`). [HIST]
2. B2B Suite 3.0.x is three weeks old and single-vendor. [SRC]
3. There are no VK7 unit tests, and independent runtime acceptance has never run. [SRC][AGENT]
4. Commercial rules (payments, custom orders, shortage) are not modelled. [SRC]
5. Frontend direction (headless vs Bagisto theme) is undecided. [PROP]
