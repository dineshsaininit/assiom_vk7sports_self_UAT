# 08 — VK7SPORTS PAGE-BY-PAGE AUDIT

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Scope:** Forensic evaluation of every existing and planned page/screen in the VK7SPORTS project.

---

## 1. Existing Customer Storefront Screens

### Page 1: Home Page
- **Path / Route:** `VK7SPORTS_Prototype/HomePage.html`
- **File Size & Lines:** 22,109 bytes | 736 lines
- **Declared Title:** `VK7SPORTS - Gear Up For The Season`
- **Purpose:** Brand storefront landing page to introduce VK7SPORTS, highlight sports categories, showcase customer segments, and present value propositions.
- **Implementation Status:** **UI_ONLY / MOCKED**
- **Responsiveness:**
  - CSS contains media queries (`@media (max-width: 768px)`).
  - Visual layout collapses into single-column cards on mobile.
  - **Critical Mobile Bug:** The hamburger button `<button class="mobile-menu-btn">` has **no JavaScript listener**. Mobile navigation cannot be opened.
- **Data Source:**
  - 100% hardcoded static HTML copy.
  - 13 external stock photographs loaded directly from `images.unsplash.com`.
- **Functionality:**
  - Zero active functionality.
  - All 13 navigation links are `href="#"`.
  - Search input has no event handlers.
  - "Shop Now" hero button has no click handler.
  - Newsletter "Subscribe" form has no `action` URL and no script handler.
- **Known Issues:**
  - Broken links (`href="#"`).
  - Mobile hamburger menu completely unresponsive.
  - Hard dependency on external Unsplash image servers; fails to render images offline.
  - Outdated information architecture (categorized by Sport and Client Type instead of garment category).
- **Current Relevance:** Useful strictly as visual inspiration for brand color tokens (Navy/Red) and hero layout density. Unusable as application code.

---

### Page 2: Product Catalogue (Shop Page)
- **Path / Route:** `VK7SPORTS_Prototype/ShopPage.html`
- **File Size & Lines:** 200,862 bytes | 1,023 lines
- **Declared Title:** `VK7SPORTS - Shop (Product Listing Page)`
- **Purpose:** Browse and discover products, apply filters, and select items for purchase.
- **Implementation Status:** **UI_ONLY / MOCKED**
- **Responsiveness:**
  - Responsive CSS grid collapses from 3 columns on desktop to 2 columns on tablet and 1 column on mobile.
  - Mobile filter drawer implemented with CSS translate and overlay (`toggleFilters()` script on lines 1012–1022).
- **Data Source:**
  - Exactly 7 hardcoded product cards embedded in HTML.
  - 7 product photos embedded directly into the HTML as large `data:image/jpeg;base64` strings (explaining the 200 KB file size).
- **Functionality:**
  - Mobile filter drawer opens and closes when tapping "Filters" button.
  - **Zero catalog functionality:**
    - Filter checkboxes (Sport, Category, Size, Price slider, In-stock) have no JavaScript listeners; checking them changes nothing.
    - Sort dropdown (`#sort`) has no change listener.
    - Hardcoded counter *"Showing 7 jerseys"* never updates.
    - Product cards are non-clickable `<div>` elements; cannot navigate to product detail.
- **Known Issues:**
  - Massive HTML file bloat due to inline base64 image strings.
  - Non-functional filtering and sorting.
  - Product cards use third-party trademarked names (*"Inter Miami CF Authentic On-Field Jersey"*, *"Mumbai Cricket Team Official Jersey"*) which are illegal for commercial sale without licensing.
  - Displays single-piece retail prices (₹899–₹2499) instead of wholesale quantity tier prices.
  - Categories are jersey-only; missing track pants, shorts, and training t-shirts.
- **Current Relevance:** Useful reference for filter group naming and mobile filter drawer styling. Obsolete for product modeling and data architecture.

---

### Page 3: Custom Teamwear Configurator
- **Path / Route:** `VK7SPORTS_Prototype/custom-teamwear.html`
- **File Size & Lines:** 122,301 bytes | 1,096 lines
- **Declared Title:** `VK7SPORTS | Custom Teamwear`
- **Purpose:** Interactive teamwear kit design customizer allowing teams and clubs to customize jersey colors, enter team names, upload logos, and request bulk quotes.
- **Implementation Status:** **PARTIAL (Client Prototype)**
- **Responsiveness:**
  - Two-column layout (preview left, configuration controls right) stacks vertically on viewports below 992px.
- **Data Source:**
  - Inline SVG/CSS jersey graphics and browser DOM memory.
  - Browser `localStorage` holds `vk7-team-name` and `vk7-shirt-color`.
- **Functionality (The only interactive script in the repo — 83 lines):**
  - Color swatches update CSS variable `--shirt`.
  - Team name input dynamically updates text inside SVG `#teamPreview`.
  - Logo file input validates file size (<3 MB) and previews file via local `FileReader.readAsDataURL()`.
  - Quantity input computes price using client formula: `qty * 1299`.
  - "Save Design" writes to `localStorage` and triggers a cosmetic alert toast.
  - "Request a Bulk Quote" and "Send Enquiry" buttons trigger cosmetic alert toasts.
  - View switcher (Front/Back/Detail) scales front image or executes `scaleX(-1)` to fake a back view.
- **Known Issues:**
  - **MAJOR SCOPE CONFLICT:** Business requirements in Task 1 formally removed custom teamwear from the project scope. This page implements the exact feature the client requested to drop.
  - Price is calculated insecurely in the client (`qty * 1299`).
  - No server-side quote submission; user enquiries are lost on refresh.
  - Back view is a mirrored front view, which inverts team names and logos backwards!
- **Current Relevance:** Architectural dead-end unless the founder explicitly revokes the decision to remove custom teamwear.

---

## 2. Existing Administrative Screens

### Page 4: Admin Portal Dashboard
- **Path / Route:** `VK7SPORTS_Prototype/AdminDashboardPage.html`
- **File Size & Lines:** 19,843 bytes | 598 lines
- **Declared Title:** `VK7SPORTS - Admin Portal Dashboard`
- **Purpose:** Back-office administrative dashboard for monitoring store performance, orders, inventory, and enquiries.
- **Implementation Status:** **UI_ONLY / MOCKED**
- **Responsiveness:**
  - Sidebar collapses off-screen on mobile; toggles open via script binding `menuToggle` (lines 589–597).
- **Data Source:**
  - 100% hardcoded static text and SVG coordinates.
- **Functionality:**
  - Mobile sidebar toggle works.
  - **Zero administrative functionality:**
    - Zero authentication; world-readable static HTML page.
    - KPI cards display fake figures: Total Sales `3.85K`, Total Orders `37`, Bulk Enquiries `0`.
    - Chart is a static SVG polyline with fake Jan–Dec points.
    - Sidebar items (Section, Product, Product Management, User Management, Order Management, Bulk Enquiries, Promotions, Reports) are unclickable `<li>` items without links.
- **Known Issues:**
  - Severe security vulnerability if exposed in production: zero auth gate.
  - Incomplete draft copy (*"Orders & orders"*, *"Bulk Companies"*).
  - Uses non-standard `<sidebar>` HTML tag.
  - Missing all 6 required administrative modules (Products, Inventory, Orders, Customers, Notifications, Settings).
- **Current Relevance:** Layout concept reference only. Must be completely replaced by an authenticated admin application.

---

## 3. Tool Scratch Artifacts (Non-Canonical)

### Page 5: Redirection Landing Portal
- **Path / Route:** `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/index.html`
- **File Size & Lines:** 3,719 bytes | 120 lines
- **Status:** **UNTRACKED / SCRATCH ONLY**
- **Purpose:** Created on 31 August 2026 inside Antigravity scratch directory to serve as an instant redirect (`<meta http-equiv="refresh" content="0; url=VK7SPORTS_Prototype/HomePage.html">`) and landing portal card.
- **Current Relevance:** Scratch artifact. Not part of canonical Git repository.

---

## 4. Planned Screens Audit (Identified as Completely Missing)

| Planned Screen | Source Requirement | Status | Criticality |
|---|---|---|---|
| **Product Detail Page** | Standard E-Commerce Flow | **MISSING / NOT FOUND** | **CRITICAL** (Cannot view single product details or select variants) |
| **Color × Size Wholesale Matrix** | Task 1 Revised Walkthrough | **MISSING / NOT FOUND** | **CRITICAL** (Cannot enter multi-variant B2B order quantities) |
| **Cart Drawer / Cart Page** | Task 1 & Task 2 Specs | **MISSING / NOT FOUND** | **CRITICAL** (Cannot review selected items or validate 24 MOQ) |
| **Checkout & Address Form** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (Cannot collect shipping, billing, or GST credentials) |
| **Payment Gateway Screen / Modal** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (Cannot collect payments or select 10/90 COD split) |
| **Customer Auth (Login / Signup / OTP)** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (No customer identity management) |
| **Customer Account & Order History** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **HIGH** (Shopkeeper cannot reorder or review past orders) |
| **Customer Order Tracking View** | Task 1 & Task 2 Specs | **MISSING / NOT FOUND** | **HIGH** (Cannot view 7-stage order status progression) |
| **Admin Products Management** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (Cannot create or edit products/variants) |
| **Admin Inventory Management** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (Cannot update stock levels per SKU) |
| **Admin Order Management** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **CRITICAL** (Cannot advance order status or attach courier tracking) |
| **Admin Customer / Verification** | Task 2 Backend Blueprint | **MISSING / NOT FOUND** | **HIGH** (Cannot inspect shopkeeper GST credentials) |
| **Admin Notifications & Settings** | Task 1 Revised Walkthrough | **MISSING / NOT FOUND** | **MEDIUM** (Cannot configure system parameters or notifications) |
