# VK7SPORTS — Phase 1 frontend

An isolated, dependency-free catalogue-to-quotation demonstration for AASIOM Technologies Private Limited. All products, garment illustrations, inventory and quotation transactions are **DEMO DATA**. No prices or commercial policies are configured.

## Preview

Run this exact command in a terminal:

```sh
python3 -m http.server 8767 --bind 127.0.0.1 --directory /Users/aasiom/PROJECTS/VK7SPORTS-CODEX-FRONTEND
```

Open http://127.0.0.1:8767 in a modern browser. Stop the preview with Ctrl+C. This is a local static file server, not a commerce backend. ES modules require HTTP; do not open index.html via file://. No dependency installation or build step is needed.

## Implemented

- Six fictional sportswear products, original local SVG illustrations, category filtering and search.
- Responsive catalogue, product-detail modal and labelled size × colour quantity matrix.
- Editable quotation draft, product removal, summary with per-variant quantities, stock and shortages.
- Configurable MOQ threshold, default 24 pieces. Whole-number quantity validation (0–9,999).
- Explicitly **unconfirmed** MOQ basis, initially unset. Demo choices: across quotation, per product, per variant. Every selected group must meet the demo threshold. Selecting a demo basis never confirms a business rule.
- Simulated stock, including zero-stock variants. Shortages stay visible in the request without asserting a real backorder or shipment policy.
- Exact provisional message: “Additional stock may require 20–30 days.” Shortage acknowledgement before simulated submission.
- Quotation preparation, loading, failure/retry and success states. No customer/contact fields.
- Catalogue loading, empty-search, empty-draft and error states. Expand Demo state controls to exercise failures and an empty catalogue.
- Native keyboard-accessible controls, modal focus containment/return via native dialog, Escape dismissal, status announcements, reduced-motion styling and skip link.

## Walkthrough

1. Select Velocity training tee.
2. Enter Navy S = 12 and Navy M = 12; save quantities.
3. Expect 24 pieces and a 4-piece simulated shortage.
4. Select “Across the quotation” as the demo basis; review quotation.
5. Acknowledge provisional shortage timing; simulate request.
6. Expect DEMO-VK7-001 and a clear statement that nothing was sent or reserved.
7. Edit quantities, switch MOQ basis, change threshold, remove products and search an unmatched term to exercise alternate states.
8. To test request failure, enable the checkbox under Demo state controls before opening review. After failure, use the in-modal “Retry without simulated failure” action.

## Files and integration boundary

- `index.html`, `styles.css`: presentation; navy/red branding and catalogue/filter patterns adapted from the existing prototype. No original files changed.
- `data.mjs`: fictional product/variant/stock fixtures; replace with an approved commerce adapter later.
- `model.mjs`: pure quantity, shortage and demo MOQ evaluation.
- `art.mjs`: original illustrations without external fonts, images or network requests.
- `app.mjs`: browser state, rendering and local simulated request.
- `tests/`: Node built-in tests; no packages required.

The browser draft exists in memory only and resets on refresh. No database, credentials, payments, real submission, stock reservations or backend services. A production integration must use the approved platform for availability and business-rule validation. No Bagisto compatibility claim is made.

## Checks and validation status

```sh
cd /Users/aasiom/PROJECTS/VK7SPORTS-CODEX-FRONTEND
node --test tests/*.test.mjs
node --check app.mjs
node --check model.mjs
node --check data.mjs
node --check art.mjs
```

Phase 1.5: 20 automated tests passed; syntax checks passed. Nine tests execute application handlers against a minimal DOM double, not a real browser. See [VALIDATION.md](VALIDATION.md) for defects fixed, evidence boundaries and the full manual acceptance procedure. Tests cover MOQ boundaries/bases, invalid input, empty requests, shortages and fixture integrity. They do not prove browser rendering or event wiring.

Local HTTP preview could not start in the managed execution environment: socket binding returned `PermissionError: Operation not permitted`. No permissions were escalated. Browser end-to-end, console and layout checks remain unverified. Manual acceptance should cover 320, 768, 1024 and 1440 px, keyboard-only operation and the walkthrough above. On narrow displays, the quantity/summary tables permit horizontal scrolling within their containers.

## Known limitations

- Demo submission uses a timer and fixed demo reference; no request leaves the browser.
- Stock and garment attributes are fictional; garment image does not recolour by variant.
- MOQ basis is not a confirmed commercial rule. Demo eligibility is not real quotation acceptance.
- No durable draft, quote export, order tracking or platform integration in Phase 1.
- No browser or accessibility-tool verification was possible in this environment.

Phase 1 ends here. Phase 2 requires Om’s approval.
