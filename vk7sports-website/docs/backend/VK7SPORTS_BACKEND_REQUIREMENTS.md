# VK7SPORTS Backend Requirements and Status

**Date:** 31 October 2026. **Branch:** `feature/backend-api`. **Prepared by:** Claude Code, for review by the backend owner. This is author testing, not independent acceptance.

**Sources:** `VK7SPORTS_ALL_REQUIREMENTS`, the two-week plan, Day 1 and Day 2 assignments, Starter Kit documents 01-03 (`FINAL 1-3`), `plan VK7SPORTS`, the handover and audit files in this repository, and the code itself. Where they differ, the newest (30 October) wins. Companion documents: [API contract](VK7SPORTS_API_CONTRACT.md), [setup guide](VK7SPORTS_BACKEND_SETUP.md).

## 1. Summary

The backend now has a tested JSON API for a separate frontend. It covers registration with approval, the catalogue with a size × colour grid, the minimum order, cart, quotes, offline checkout, order tracking and enquiries. Staff use the existing Bagisto admin panel.

It is **not production-ready**. Payments, ledger, stock-hold expiry, backorders, audit log and owner dashboard are not built. No business rule is owner-confirmed, and nobody independent has tested it.

### Three things to resolve first

1. **This repository may be behind another copy.** The Starter Kit describes commit `fe52cdb` (27 October) with VK7 tests, a quote price lock and locked quote numbers. That commit is not in this repository, which contained no VK7 tests. Some of this work may duplicate those fixes. Om should confirm which code base is the master before merging.
2. **Architecture changed from the preferred option.** The documents prefer FE-1 (a Bagisto theme). This work follows FE-2 (a separate frontend and new API), because that is how the frontend is being built. The documents call for Om's decision on this; the backend owner reports that Om approved this work. Record it.
3. **Governance.** The documents require independent review before merging, and no reviewer is named. Treat this branch as a pull request awaiting review.

## 2. Requirements and status

Status: **Tested** = automated test and/or live HTTP run by the author. **Existing** = shipped with Bagisto or the B2B Suite and not tested here. **Not built**, **Deferred** = excluded by the plan.

| Requirement | Status | Where |
|---|---|---|
| Retailer registration and login | Tested | `POST /auth/register`, `/auth/login` |
| Admin approval before access | Tested for blocking; approving through the admin screen not run | B2B Companies screen |
| Permissions for approved and unapproved retailers | Tested | Token middleware |
| One retailer cannot reach another's data | Tested for quotes and orders on the API | 404 on another retailer's records |
| Catalogue, images, styles, variants | Tested; demo products have no images | `GET /products`, `/products/{id}` |
| Size and colour selection, variant stock | Tested | `grid` in product detail |
| Search and filtering | Search tested; colour, size, category and sort filters not tested | `GET /products` |
| MOQ 24, regular orders | Tested at quote, cart error and order | `Moq.php`, `POST /moq/check` |
| MOQ 100, custom orders | Not built; custom orders are enquiry-only (decision Q7) | `POST /enquiries` |
| Quote request, offer, view | Tested; the offer was created through the repository, not the admin screen | `/quotes` |
| Backend validation of quantity and price | Tested | `QuoteLock.php` |
| Approved quote to order | Tested with 4 variants at the negotiated price | `/quotes/{id}/accept`, `/checkout/*` |
| Unique order numbers | Tested sequentially, including a counter behind a restored database | `Sequence.php`, unique indexes |
| Order status and retailer tracking | Tested for listing; shipment data not exercised | `/orders` |
| Admin management of orders and quotes | Existing | Bagisto admin |
| Stock checks and shortages | Tested at grid and cart | `/moq/check` |
| Backorder and replenishment | Not built; awaits owner | |
| 48-hour stock hold and expiry (R-16) | Not built | |
| Price hiding from visitors (R-03) | Tested on the API and old JSON routes; old HTML pages now redirect guests | `HidePricesFromGuests.php` |
| Enquiries and follow-up queue | Tested; status update not tested | `/enquiries`, Admin enquiries page |
| 10% advance / 90% COD, ledger, invoices | **Deferred**; only offline methods accepted, no money handled | |
| R-26 status names | Not built; Bagisto's statuses are returned | |
| Pick list, packing slip, LR number | Not built; Bagisto shipments exist | |
| Audit log, owner dashboard, event emails | Not built | |
| Hosting, backup, monitoring | Not started | |

## 3. Pages for the frontend

| Page | Backend |
|---|---|
| Home, catalogue, product detail with grid | Ready |
| Register, login, account | Ready |
| Cart, quote request, quote list and detail | Ready |
| Checkout (offline), orders, order tracking | Ready |
| Enquiry and custom-order enquiry | Ready |
| About, contact, policies | Static; content awaits the owner |
| Password reset, profile edit, address book, shop staff logins | **No API yet** |
| Payment screens, statement or ledger | Deferred |
| All admin screens, including approval | Bagisto `/admin`; none needed in the frontend |

Old prototypes (`custom-teamwear.html`, retail prices, licensed club names) must not be copied across. They conflict with the requirements or carry trademark risk.

## 4. Defects

| ID | Issue | Status |
|---|---|---|
| D-01 | Duplicate quote and PO numbers | Fixed and tested: locked counter, unique indexes |
| D-02 | No MOQ at quote request | Fixed and tested (planning default) |
| D-03 | Quote acceptance not atomic | Fixed on the API. The old web route still records acceptance first, though its cart update is now atomic |
| D-04 | Negotiated price at any quantity | Fixed and tested: blocked at cart and order |
| D-05 | Duplicate quote from a double submit | Fixed with a lock; **parallel requests not tested** |
| D-06 | Prices visible to guests | Fixed and tested on API and JSON routes |
| D-07 | Order sequencer depended on a setting | Fixed: bound in code |
| D-08 | MOQ rejection retried and logged with customer data | Fixed for MOQ and quote-lock rejections. Other order errors still log the full payload in a core file |
| D-09 | Attachments orphaned, public by default | Open. The API accepts no attachments, so it must stay closed until fixed |
| D-13 | Web account routes allow unmapped routes | Open on the old web routes; the API does not use that middleware |
| F1 | Installer checks only the database name | Open. Confirmed in practice: it ignores `--env=testing`. See the setup guide |
| F2 | Order numbers repeat on a restored database | Fixed and tested |
| F4 | Unique index added without a duplicate check | The new migration stops and lists duplicates; it deletes nothing |
| D-10, D-11 | Variant oversell; quote keeping last variant | Earlier fixes retained; D-11 path tested. Oversell under load not tested |
| D-12, F3, F5, F6, F8 | | Not investigated; the documents here give too little detail to act on them |

Found and fixed during this work:

- A fresh install was impossible because the B2B Suite reads the database at startup.
- A stray empty cart was created when a quote was accepted.

## 5. Test evidence (31 October 2026, MySQL 8.4.9, PHP 8.4.27, Windows)

| Suite | Result |
|---|---|
| VK7 Feature Test (new) | **18 passed**, 177 assertions |
| Live HTTP run through `php artisan serve` | Passed: CORS, approval, grid, cart, quote, checkout, order, enquiry |
| Sales Unit | 19 passed |
| Shop Feature | 673 passed, **8 failed** |
| Unit | 36 passed, **1 failed** |

The regression suites ran before the last three small changes (rate limits, order prefix setting, formatting). Only the VK7 suite was rerun after them.

The 9 failures have **not been compared against an unmodified copy**, so "not caused by this work" is a reading of the errors, not proof:

- 4 fail in `formatCurrency` with a null currency, probably because this install uses INR while test data expects another currency.
- 1 is the B2B Suite's customer model replacing the core one in `SocialLoginTest`.
- 3 are page-markup assertions on the account greeting and footer.
- 1 is missing installer icons.

The documents mention six failing tests (and earlier 11); these have not been matched against them.

**Not tested:** real concurrency (the dev server handles one request at a time), oversell under load, approving and offering through the admin screens, the Admin Feature suite (about 138 test files), Pest on MySQL 8.0, and browser use with the real frontend.

## 6. Decisions awaiting the owner, through Om

Every value below is a setting, applied by `php artisan vk7:apply-policy`, and is a planning default only.

| Decision | Current default |
|---|---|
| MOQ basis (R-04): style, variant or order | 24 per style, sizes and colours combined |
| Does MOQ apply at quote request? | Yes |
| Exceptions to MOQ (R-06), and quotes negotiated below it | None; blocked |
| Prices hidden from visitors (R-03) | Yes |
| Retailer eligibility and approver (R-01, R-02) | Companies only, manual approval, business name required; no GSTIN or document checks |
| Quote validity (R-09) | 7 days |
| Payment terms (R-10, R-11) | None; offline methods only |
| Custom order definition, MOQ 100, advance | Enquiry only |
| Shortage and backorder (R-17) | Shows a shortage; no backorder |
| Shipping partners and charges | Bagisto's seeded flat rate and free methods, **placeholder** |
| GST and invoices (R-22) | Needs the CA; tax total is 0 in demo data |
| Real products, prices, stock, images | Missing; only fictional `TEST-` data exists |
| Who sees a company's orders | Owner sees members' orders; members see their own |

## 7. What changed

All new logic is in `backend/app/packages/VK7/Wholesale`. No file in `vendor` or `packages/Webkul` was edited.

- **New:** API routes and controllers, token, price-hiding and JSON middleware, `QuoteLock`, `Sequence`, enquiries (table, admin page), `vk7:apply-policy`, `vk7:demo-data`, tests, two migrations.
- **Changed:** `Moq`, `Cart`, `OrderNumberSequencer`, `CustomerQuoteRepository`, service provider, settings; `bootstrap/providers.php` (install switch), `phpunit.xml`, `tests/Pest.php`.
- **Convention differences:** `Enquiry` has no Contract or Proxy, and the new messages and admin page are English-only rather than all 22 locales. This matches the existing VK7 code.

## 8. Next steps, in order

1. Om confirms the master code base and records the FE-2 decision.
2. Dinesh connects the frontend using the API contract, and reports any mismatch.
3. Test approval and offers through the admin panel, end to end with the real frontend.
4. Add the missing account APIs (password reset, profile, addresses) when those pages are ready.
5. An independent reviewer reruns the tests, including parallel-request and oversell checks, and compares the 9 failures against an unmodified copy.
6. Owner answers section 6; then hold expiry, statuses, audit log, and only after authorisation, payments.
