# Bagisto core patches — retained for baseline verification (F9, approved 2026-10-21)

Status: **RETAINED AS-IS. Not refactored.** Both patches are direct edits to upstream Bagisto 2.5.0 core files.
They stay in the baseline so the 15 Oct behaviour can be verified exactly. Refactoring is deferred (proposed VK7-DEV-004).

| Patch | File | Change | Why (evidence) |
|---|---|---|---|
| `patches/0001-sales-reserve-configurable-variant-stock.patch` | `app/packages/Webkul/Sales/src/Repositories/OrderItemRepository.php` (`manageInventory`, `updateProductOrderedInventories`) | Child-line quantity falls back to the parent's when the child's `qty_ordered` is 0/falsy (`?:` instead of `isset`/`??`) | Unpatched Bagisto stored configurable child lines with qty 0, so no stock was reserved and variants oversold. Reproduced on unpatched code: `evidence/after-fix/R0-control-unpatched-race.txt`; oversold orders #3/#4 in `evidence/baseline-before-fix/` |
| `patches/0002-admin-validate-variant-stock-on-shipment.patch` | `app/packages/Webkul/Admin/src/Http/Controllers/Sales/ShipmentController.php` (`isInventoryValidate`) | Composite children without `qty_ordered` are no longer skipped; shipment quantity is checked against physical stock | Admin could ship more than physical stock: `evidence/after-fix/32-C3-ship-24-with-10-in-stock-before-fix.png` vs `33-C3-...-refused.png` |

## Risks (documented, not yet mitigated)

1. **Upgrade conflicts.** Any Bagisto upgrade that touches these files will conflict or silently drop the fix. Each upgrade must reapply and re-test both patches. Composer updates do not overwrite them (the files are in-repo packages, not `vendor/`).
2. **Changed semantics (0001).** `qty_ordered == 0` now means "use the parent's quantity". This is correct for configurable child lines, which is the observed bug. It has **not been reviewed for bundle, grouped, downloadable or booking products**, which share this code path.
3. **Stricter shipment validation (0002).** Shipments of composite children are now always checked against physical stock. This was not tested for product types whose children carry no inventory (e.g. virtual or downloadable) and could block such shipments.
4. **No PHP unit tests.** Coverage comes only from live-stack Python scenarios (A2–A4, R1–R3, C, D, W8–W9). Bagisto's own Pest suites showed no new failures (1225 pass / 11 fail, same 11 on unmodified Bagisto in a smaller 252-test baseline run).
5. **Not independently verified.** All evidence was produced by the same agent that wrote the patches (15 Oct). Codex QA A–G remains BLOCKED.
6. **Locking assumptions.** The fix relies on Bagisto's existing `lockForUpdate` in `manageInventory`, which is not altered by the patch. Behaviour under MySQL isolation settings other than the default (REPEATABLE READ) is untested.

## Rules until refactored

- Do not edit these two files further except to revert or re-apply the patch exactly.
- Any Bagisto version change must re-run: R0 control on unpatched code, A2–A4, R1–R3, C, D and W1–W10.
- The patch files under `patches/` are the reference. The applied files must match them (checked by hash in `PRESERVATION.md`).
