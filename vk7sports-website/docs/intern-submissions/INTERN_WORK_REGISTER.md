# INTERN WORK REGISTER — VK7SPORTS

**Register Date:** 11 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Location:** `/Users/aasiom/PROJECTS/VK7SPORTS-CANONICAL/docs/intern-submissions/`  
**Mandate:** Authoritative register of all historical intern and contributor submissions for the VK7SPORTS project.

---

## Document Transfer & Verification Status
> [!NOTE]
> **TRANSFER & VERIFICATION COMPLETED (11 October 2026):**  
> The two required intern submissions were transferred from ChatGPT and verified at `/Users/aasiom/Downloads/`:
> 1. `Task1_VK7SPORTS_Prototype_Walkthrough(2).docx` (2,185,918 bytes)  
>    - SHA-256: `7cab3abe1c88ddcd221c729e0cd1c0c6266cab7a5fbed1c2cc665b8716052c54`  
>    - MD5: `91f9b4c064c9f07b069dcc7dcadb20f7`  
>    - Comparison against base `Task1_VK7SPORTS_Prototype_Walkthrough.docx`: **`IDENTICAL`**  
> 2. `Task_2_Backend_Plan(2).docx` (3,127,953 bytes)  
>    - SHA-256: `c479a1ca65e7765153ced8c1f886225edc06b8ef817d276b11035feadc73d4c2`  
>    - MD5: `0151e1121b08acc3568e14255d6cad51`  
>    - Comparison against base `Task_2_Backend_Plan.docx`: **`IDENTICAL`**  
> Both the exact `(2)` files and the historical base copies are preserved in `/Users/aasiom/PROJECTS/VK7SPORTS-CANONICAL/docs/intern-submissions/`.


## 1. Submission Record: Task 1 — Revised Prototype Walkthrough

- **Document Name:** `Task1_VK7SPORTS_Prototype_Walkthrough.docx` (and reference `Task1_VK7SPORTS_Prototype_Walkthrough(2).docx`)
- **Original Locations:** 
  - `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/02_PROTOTYPES/Task1_VK7SPORTS_Prototype_Walkthrough.docx`
  - `/Users/aasiom/PROJECTS/VK7SPORTS/Task1_VK7SPORTS_Prototype_Walkthrough.docx`
- **Contributor:** VK7SPORTS Frontend/UI Intern (Internal AASIOM development team)
- **Submission Date:** Mid-September 2026 (Preserved mtime: 14 September 2026; re-indexed 25 September 2026)
- **Task Objective:** Reconcile customer storefront wireframes and administrative screens with the revised B2B wholesale business model.
- **Deliverables Submitted:** Word document walkthrough detailing UI revisions, module restructuring, and screen-by-screen requirements.
- **Features Described:**
  - Narrowing storefront audience strictly to **B2B shopkeepers and retailers**.
  - Replacing "Shop by Sport" with 4 primary apparel categories: **Jerseys, Pants/Track Pants, Shorts, T-Shirts/Training Tops**.
  - **Removal of Custom Teamwear design builder** (customers cannot change designs).
  - Enforcing **24-piece Minimum Order Quantity (MOQ)** per product line (allowing mixed sizes and colors).
  - Wholesale tier volume pricing.
  - Two allowed payment modes: **100% Online** or **10% Online Advance + 90% COD** (100% COD blocked).
  - Simplified 7-module Admin Dashboard: Dashboard, Products, Inventory, Orders, Customers, Notifications, Settings.
- **Architecture Proposed:** Static UI reference coupled with backend API integrations for catalog, pricing, inventory, and order status.
- **Evidence of Actual Implementation:**
  - **MOCK_ONLY / UI_ONLY:** Prototype files in `app/VK7SPORTS_Prototype/` represent the visual layout idea, but retain outdated sport-based categories and still contain the custom teamwear builder.
- **Missing Implementation:**
  - Zero code enforcement of 24 MOQ.
  - Zero color × size wholesale quantity grid.
  - Zero category restructuring in code (prototype still says "Shop By Sport" and "Shop Jerseys").
  - Zero admin module screens exist beyond a static dashboard mockup.
- **Conflicts with Other Requirements:**
  - **Major Conflict:** Conflicts directly with the existing prototype codebase where `custom-teamwear.html` is the primary interactive feature. Task 1 demands removing customization entirely.
  - Conflicts with July 2026 Master Blueprint which envisioned retail single-piece D2C sales, corporate custom kits, and school tournament wear.
- **Relevance to Current Project:** **CRITICAL (AUTHORITATIVE REQUIREMENT CANDIDATE).** This represents the most mature, simplified, and operationally realistic B2B wholesale specification drafted for the project.

---

## 2. Submission Record: Task 2 — Backend Implementation Blueprint

- **Document Name:** `Task_2_Backend_Plan.docx` (and reference `Task_2_Backend_Plan(2).docx`)
- **Original Locations:**
  - `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/03_BACKEND_PLAN/Task_2_Backend_Plan.docx`
  - `/Users/aasiom/PROJECTS/VK7SPORTS/Task_2_Backend_Plan.docx`
- **Contributor:** VK7SPORTS Backend Intern / Architecture Lead
- **Submission Date:** Mid-September 2026 (Preserved mtime: 14 September 2026; re-indexed 25 September 2026)
- **Task Objective:** Define the complete backend architecture, relational database schema, and REST API contracts supporting the customer storefront and admin portal.
- **Deliverables Submitted:** Word document specification detailing PostgreSQL tables, admin endpoints, customer APIs, and business rule validation mechanisms.
- **Features Described:**
  - Relational hierarchy: Product → Color → Size → SKU.
  - Dynamic Wholesale Pricing Tiers (`min_qty`, `max_qty`, `price_per_piece`).
  - Granular Inventory Control mapped to ProductVariant SKUs.
  - Order state advancement: `Processing → Packed → Shipped → Out for Delivery → Delivered`.
  - Courier tracking attachment (courier partner, tracking number, tracking URL).
  - Revalidation logic during checkout (re-verifying price, stock availability, and 24 MOQ).
- **Architecture Proposed:**
  - Database: PostgreSQL (Users, Categories, Products, ProductVariants, Inventory, PricingTiers, Orders, OrderItems).
  - API Routes:
    - `POST /api/admin/products`
    - `POST /api/admin/products/:id/variants`
    - `POST /api/admin/products/:id/pricing-tiers`
    - `PATCH /api/admin/inventory`
    - `GET /api/admin/orders`
    - `PATCH /api/admin/orders/:id/status`
    - `PATCH /api/admin/orders/:id/tracking`
    - Customer APIs for `/api/catalog`, `/api/cart`, `/api/checkout`.
- **Evidence of Actual Implementation:**
  - **DOCUMENTED_ONLY (0% IN CODE):** Exactly 0 lines of backend code, 0 API controllers, and 0 SQL tables exist in the repository.
- **Missing Implementation:**
  - Entire backend service, server runtime, ORM models, migrations, authentication middleware, and API endpoints.
- **Conflicts with Other Requirements:**
  - Streamlines and simplifies the earlier 25-page intern database schema (which had 25+ tables including coupons, custom kits, reviews, and support tickets). Task 2 focuses tightly on core wholesale commerce.
- **Relevance to Current Project:** **CRITICAL (PRIMARY BACKEND BLUEPRINT).** Provides the exact schema and endpoint design needed for the upcoming greenfield backend implementation.

---

## 3. Historical Submission Record: August 2026 Intern DB Schema & ERD

- **Document Names:** `02_Original_DB_Schema.docx` (3.03 MB) and `vk7sports_ER_Diagram.pdf` (1.38 MB)
- **Original Location:** `/Users/aasiom/PROJECTS/AASIOM/AASIOM_OM_MASTER_MERGED_ARCHIVE/VK7SPORTS_Backend_Complete_Chat_Package/`
- **Contributor:** Previous Backend Intern (August 2026)
- **Submission Date:** 10 August 2026
- **Task Objective:** First-pass comprehensive e-commerce database design for VK7SPORTS.
- **Deliverables Submitted:** 25-page Word document schema specification and visual ER diagram covering ~25 entities.
- **Features Described:** Users, roles, addresses, categories, products, variants, media, carts, cart items, coupons, orders, order items, payments, custom kit designs, bulk enquiries, wishlists, reviews, support tickets, banners, and activity logs.
- **Evidence of Actual Implementation:** **DOCUMENTED_ONLY.** Reviewed by senior architect on 10 August 2026 (`VK7SPORTS_Backend_Improvement_Manual.pdf`). Intern never implemented code.
- **Relevance to Current Project:** **HISTORICAL ARCHIVE.** Over-engineered for the current simplified wholesale model; superseded by Task 2.

---

## 4. Historical Submission Record: Initial HTML Prototype & Repo Setup

- **Files:** `HomePage.html`, `ShopPage.html`, `custom-teamwear.html`, `AdminDashboardPage.html`, `README.md`, `VK7SPORTS_Prototype_Description_Report.docx`
- **Original Location:** `https://github.com/Anvora-Global/vk7sports-website.git` @ commits `1ba7bc7`, `4eb2ee9`, `7308e0e`
- **Contributor:** `Nooruzma-Khan <knooruzma@gmail.com>`
- **Submission Date:** 4 August 2026 (18:04–18:21 IST)
- **Task Objective:** Build initial visual demonstration prototype in HTML/CSS for client feedback.
- **Deliverables Submitted:** 4 static HTML pages and Word description report committed to GitHub.
- **Evidence of Actual Implementation:** **IMPLEMENTED AS STATIC PROTOTYPE.** This is the physical code that exists in Git HEAD today.
- **Relevance to Current Project:** **CANONICAL CODE BASELINE.** Forms the current visual reference.
