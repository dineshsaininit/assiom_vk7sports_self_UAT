# Phase 1.5 validation — 15 October 2026

**CONDITIONAL PASS.** Files and local automated checks verified. Browser acceptance remains outstanding because the managed shell rejects loopback server binding with `PermissionError: [Errno 1] Operation not permitted`. No escalation, deployment or sandbox workaround attempted. No desktop/mobile screenshots are available.

## Executed checks

All nine Phase 1 files exist; this phase adds this report and `tests/ui.test.mjs`. Node syntax checks and 20 automated tests passed. The suite includes 11 original model/fixture checks and nine actual application-handler tests using a minimal DOM double. This double does not render CSS, parse HTML or reproduce native browser events/dialog behavior.

Automated coverage: search and category combinations; empty search; opening product details; saving/clearing mixed size × colour quantities; below/exact/above 24; configured thresholds and all demo bases; unconfirmed basis; shortage math and acknowledgement gate; summary preparation; asynchronous failure/retry/success; loading, ready, empty and error/retry render branches. No real transactions occur.

## Confirmed defects and fixes

- Number fields with browser `badInput` were treated as an empty zero. They now fail validation; regression executed against the supplied validity state.
- Pending loading callback overwrote a subsequently selected error/empty/ready state. It now updates only a still-loading catalogue; error-race regression passed.
- Failure instructions directed users to a checkbox behind an active modal. Added an in-modal “Retry without simulated failure” action.
- Toggling shortage acknowledgement after success could re-enable submission. Completed requests now stay disabled and the handler prevents repeat submission.
- Success status was not focusable despite a `.focus()` call. Added `tabindex="-1"`.
- Ineligible header review attempted to focus a nonexistent element. It now targets the demo-basis selector.

No visual defects are claimed as confirmed or fixed without browser evidence.

## Accessibility findings

Source includes labelled native controls, native modal dialogs, skip link, visible focus styling, status announcements and reduced-motion handling. The focus defects above were corrected. Actual Tab sequence, native focus return/trapping, screen-reader output, colour contrast and zoom/reflow remain unverified. Automated handler tests are not an accessibility audit.

## Reliable manual browser acceptance

Run from an ordinary local terminal outside the restricted agent shell:

```sh
python3 -m http.server 8767 --bind 127.0.0.1 --directory /Users/aasiom/PROJECTS/VK7SPORTS-CODEX-FRONTEND
```

Open http://127.0.0.1:8767. If that port is already in use, substitute 8768 in both command and URL. Ctrl+C stops the server. No installation needed.

Use browser DevTools responsive mode at **1440 × 900, 1024 × 768, 768 × 1024, 390 × 844 and 320 × 740**. Repeat the primary flow at desktop and 320 px. Check page-width overflow, reachable modal actions, readable labels, table scrolling inside its container, touch controls, zoom at 200%, and console/network errors. Save catalogue, quantity-matrix and quotation screenshots at desktop and mobile widths. All local modules/styles should load successfully; no external transaction requests should appear.

| Scenario | Steps and expected result |
|---|---|
| Search/filter | Search “ JACKET ”: one Court jacket. Choose Training: empty result. Reset: six cards. Each category shows two. |
| Details/navigation | Open every product, close with button and Escape; Tab stays inside modal and returns to opener. Header Collection reaches catalogue. Header quotation with an empty draft focuses the basis control and announces guidance. |
| MOQ boundaries | Select basket basis. Velocity Navy S = 23: review disabled. 24 or 25: enabled. Switch basis to Unconfirmed: disabled. Set threshold 30: 25 fails, 30 qualifies. |
| Mixed matrix | Velocity Navy S = 6, Navy M = 6, Red S = 6, Red M = 6: 24 total, shortage 6. Per-product basis passes; per-variant basis fails at 24 threshold. |
| Input validation | Negative, decimal, over-9999 and malformed number inputs cannot save. Blank means zero. Zero all fields and save: empty draft. Cancel edits: draft unchanged. |
| Shortages | Velocity Navy S = 12, Navy M = 12: total 24, shortage 4. Exact provisional 20–30-day message visible. Summary button remains disabled until acknowledgement. |
| No shortage | Stride Black M = 24: stock 24, shortage zero; no shortage acknowledgement needed. |
| Submission | Submit: loading state, then DEMO-VK7-001. Nothing sent/reserved. Toggle acknowledgement after success: submit remains disabled. Close/reopen creates a fresh demo review. |
| Failure/retry | Enable failure before review. Submit: visible error and retained quantities. Use in-modal retry-without-failure: success. |
| Catalogue states | Exercise Ready/Loading/Empty/Error controls; error retry returns catalogue and preserves draft. Search unmatched text and reset. |
| Keyboard/accessibility | Use keyboard only for filtering, matrix edits, review, acknowledgement and submission. Check focus visibility, modal containment/return, Escape, live announcements and reduced motion. |

Record actual results rather than inferring passes. Browser scenarios above have **not** been executed by this agent.

## Bagisto considerations — assessment only

Official [theme documentation](https://devdocs.bagisto.com/2.x/themes/) describes storefront Blade view replacement and compiled CSS/JS. A theme adaptation is a candidate for preserving this visual system without a separate commerce backend; it is not validated against Claude’s installed version.

Bagisto [configurable products](https://docs.bagisto.com/product-types/configurable-product) use child simple products with individual SKU/stock for size/colour combinations. Map demo variant IDs to approved real child IDs and attribute values; handle missing combinations explicitly instead of assuming every matrix cell exists.

The documented B2B [minimum cart amount](https://docs.bagisto.com/b2b-ecommerce-platform/configuration) is an amount condition, not evidence of support for a 24-piece MOQ. Claude’s platform validation must establish extension/version-specific quote capabilities and whether quantity validation needs customization. The MOQ basis is still a business decision.

Before an approved integration, define variant/availability response shapes, unavailable-stock behavior, request validation/error mapping and quote identifiers/statuses. Replace memory/timer fixtures with the approved platform flow; enforce approved quantity rules server-side there. No integration, price policy, shipment policy or platform approval is implemented in this phase.

## Remaining limitations

In-memory draft resets on refresh. Fictional stock, fixed demo reference, illustrative garment colours and timer-only submission remain. No live quotes, reservations, order tracking or payments. Responsive CSS exists but desktop/tablet/mobile appearance, browser console and native accessibility remain unverified. Phase 1.5 ends here.
