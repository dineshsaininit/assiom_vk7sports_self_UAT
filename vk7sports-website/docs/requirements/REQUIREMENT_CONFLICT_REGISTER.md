# REQUIREMENT CONFLICT REGISTER — VK7SPORTS

**Date:** 11 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Location:** `/Users/aasiom/PROJECTS/VK7SPORTS-CANONICAL/docs/requirements/`  
**Purpose:** Precise enumeration of all conflicts between historical implementations/documents and the revised intern requirements, identifying the exact decisions required from Om.

---

## Conflict Summary Table

| ID | Business Rule Domain | Older Implementation / Document (July–August 2026) | Revised Intern Requirement (Task 1 & Task 2) | Current Code State (Git HEAD `7308e0e`) | Om's Decision Required |
|---|---|---|---|---|---|
| **RC-01** | **Target Buyer / Audience** | Omnichannel: Retail D2C individual athletes, schools, colleges, academies, gymnasiums, corporate tournaments, and dealers. | Exclusively B2B wholesale shopkeepers and sportswear retail store owners. | Mixed: `HomePage.html` features marketing for Schools, Colleges, Clubs, Academies, Corporate. | **Confirm:** Is VK7SPORTS strictly wholesale to retail shopkeepers, or are schools and retail consumers still supported? |
| **RC-02** | **Design Customization** | Core feature: Interactive jersey configurator (`custom-teamwear.html`), logo upload, player roster entry, artwork approval. | **REMOVED COMPLETELY:** No design customization. Ready-to-ship catalog apparel only. | **MAJOR CONFLICT:** `custom-teamwear.html` exists and is the only interactive page in the repo. | **Confirm:** Do we permanently delete/disable `custom-teamwear.html` as requested by Task 1, or preserve it? |
| **RC-03** | **Product Category Taxonomy** | Sport-first navigation: Cricket, Football, Basketball, Volleyball, Athletics. | Garment-first taxonomy: 1. Jerseys, 2. Pants/Track Pants, 3. Shorts, 4. T-Shirts/Training Tops. | `ShopPage.html` is titled "Shop Jerseys"; filters are Cricket, Football, etc. | **Confirm:** Replace sport categories with the 4 garment categories across navigation and catalog? |
| **RC-04** | **Minimum Order Quantity (MOQ)** | Single-piece purchases allowed for retail; unverified bulk MOQ ("10–25" in enquiry dropdown). | Strict **24 pieces per product style** minimum. Orders under 24 units are blocked. | Zero MOQ logic in code. Customizer quantity input allows `1`. | **Confirm:** Is 24 pieces per product line the non-negotiable hard minimum for all checkouts? |
| **RC-05** | **Variant Aggregation for MOQ** | Not specified in early docs; bulk was handled via custom offline quotes. | Combined colors and sizes of the *same product* count toward the 24-piece MOQ. | No wholesale matrix screen exists to enter multi-variant quantities. | **Confirm:** Approve the color × size wholesale quantity entry grid on product detail pages? |
| **RC-06** | **Pricing Model** | Fixed retail unit prices (₹899–₹2,499) on cards; flat client multiplier `qty * 1299` in customizer. | Server-authoritative quantity tier pricing: 24–49 pcs (Base), 50–99 pcs (Volume), 100+ pcs (Bulk). | Static retail prices displayed. Zero tier pricing in code. | **Provide:** Authoritative rupee price schedule per tier bracket for each product. |
| **RC-07** | **Inventory Architecture** | Intern August ERD used single `stock_quantity` column; shop cards hardcode "In Stock". | Granular SKU-level inventory (`ProductVariant`), checked on quantity change and checkout. | Hardcoded `<span class="stock-tag">In Stock</span>` across all cards. Zero database. | **Confirm:** Authorize SKU-level inventory schema with reservation locking during checkout? |
| **RC-08** | **Payment Modes & COD** | Information Architecture listed multiple options: Full, advance, part, balance, COD, NEFT, RTGS. | Two modes only: 1. 100% Online, 2. 10% Online Advance + 90% COD. **100% COD prohibited.** | No checkout or payment gateway integration in code. | **Confirm:** Enforce mandatory 10% advance on all COD orders and block 100% COD? |
| **RC-09** | **Order Lifecycle & Tracking** | Informal status notes in intern DB schema; no customer tracking views. | Strict 7-stage state machine (`Placed` to `Delivered`) with courier name, tracking number, and tracking URL. | Zero order entities or tracking views exist in code. | **Confirm:** Adopt the 7-stage state machine as the standard order lifecycle? |
| **RC-10** | **Admin Console Scope** | Wireframe sidebar lists: Dashboard, Section, Product, Product Management, User Management, Order Management, Bulk Enquiries, Promotions, Reports. | Exactly 7 operational modules: 1. Dashboard, 2. Products, 3. Inventory, 4. Orders, 5. Customers, 6. Notifications, 7. Settings. | Unlinked `<li>` elements in `AdminDashboardPage.html`. 6 of 7 screens do not exist. | **Confirm:** Build the Admin portal strictly around the 7 revised modules? |

---

## Strategic Recommendation

The revised intern requirements in Task 1 and Task 2 are **substantially superior** to the older July 2026 documents. They reduce implementation risk, eliminate complex customizer manufacturing bottlenecks, protect cash flow with the 10% advance deposit rule, and establish clear operational boundaries for an MVP.

**Recommendation:** Om and ChatGPT should formally **ratify Task 1 and Task 2 as the authoritative baseline**, superseding all conflicting July 2026 documents and decommissioning `custom-teamwear.html`.
