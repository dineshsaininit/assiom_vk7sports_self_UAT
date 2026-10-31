# 09 — VK7SPORTS ASSET AND CONTENT AUDIT

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Scope:** Forensic inventory and classification of all media, branding assets, client data, and commercial content.

---

## 1. Asset Inventory & Status Determination

Every asset discovered on disk or referenced in code is classified into one of: `READY`, `PLACEHOLDER`, `DUPLICATE`, `OUTDATED`, or `UNKNOWN`.

| Asset Name / Reference | Asset Type | Format / Location | Status | Evidence / Notes |
|---|---|---|---|---|
| **VK7SPORTS Brand Logo** | Logo / Wordmark | Pure CSS styled text in HTML (`VK7<span>SPORTS</span>`) | **PLACEHOLDER** | No vector SVG or high-resolution PNG logo file exists in the repository. |
| **Favicon** | Browser Icon | None | **OUTDATED / MISSING** | No `favicon.ico` or apple-touch-icon exists. Browsers return 404. |
| **Cricket Category Image** | Marketing Banner | Remote Unsplash URL (`photo-1531415074968...`) | **PLACEHOLDER** | Generic stock photo; fails offline; not owned by client. |
| **Football Category Image** | Marketing Banner | Remote Unsplash URL (`photo-157995236387...`) | **PLACEHOLDER** | Generic stock photo; fails offline. |
| **Basketball Category Image** | Marketing Banner | Remote Unsplash URL (`photo-1546519638-6...`) | **PLACEHOLDER** | Generic stock photo; fails offline. |
| **Volleyball Category Image** | Marketing Banner | Remote Unsplash URL (`photo-16128720877...`) | **PLACEHOLDER** | Generic stock photo; fails offline. |
| **Athletics Category Image** | Marketing Banner | Remote Unsplash URL (`photo-14618968369...`) | **PLACEHOLDER** | Generic stock photo; fails offline. |
| **New Arrivals / Best Sellers** | Marketing Banners | Remote Unsplash URLs (3 images) | **PLACEHOLDER** | Generic stock fitness photos. |
| **Client Segment Banners** | Marketing Banners | Remote Unsplash URLs (5 images: Schools, Clubs, etc.) | **PLACEHOLDER** | Generic stock campus and gym photos. |
| **Mumbai Cricket Team Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Web-scraped photo; potential trademark liability. |
| **Apex Custom Sublimation Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Sample sublimation design photo. |
| **Inter Miami CF Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Third-party MLS club jersey; severe trademark infringement risk if sold commercially. |
| **Pro Sublimated Football Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Sample jersey photo. |
| **VK7 Athletic Training Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Sample training tee photo. |
| **Custom Teamwear Sublimation** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Sample jersey photo. |
| **AFG Away Official Jersey** | Product Photo | Embedded base64 JPEG in `ShopPage.html` (~25 KB) | **PLACEHOLDER** | Afghanistan national cricket team jersey photo; trademark risk. |
| **Typography: Inter & Montserrat** | Web Fonts | Google Fonts CDN `<link>` tags | **READY** | Standard open-source Google Fonts; functional via CDN. |
| **Customizer Jersey Illustration** | Vector Graphic | Inline SVG / Canvas markup in `custom-teamwear.html` | **PLACEHOLDER** | Schematic vector front jersey; back view is a mirrored illusion. |
| **Admin KPI Chart** | Interface Chart | Inline SVG polyline in `AdminDashboardPage.html` | **PLACEHOLDER** | Hardcoded dummy coordinate points. |
| **Standalone Media Folder (`06_ASSETS`)** | Directory | `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/06_ASSETS/` | **EMPTY** | Directory was created on 14 Sep 2026 but contains **zero files**. |

---

## 2. Real Client Data vs. Mock / Demo Data Separation

A fundamental requirement of this forensic audit is to establish what **actual business content** currently exists for VK7SPORTS versus fabricated demonstration copy.

### Table: Real Client Data vs. Mock Data

| Data Domain | Discovered Content | Classification | Forensic Evidence & Details |
|---|---|---|---|
| **Product Names** | "Mumbai Cricket Team Official Jersey", "Inter Miami CF Authentic On-Field Jersey", "AFG Away Official Sublimated Jersey", "Apex Custom Sublimation Jersey" | **MOCK / DEMO DATA** | Extracted from `ShopPage.html` lines 833–950. Names are demo placeholders utilizing unlicensed third-party sports teams. Zero real client product names exist. |
| **Product SKUs** | None in HTML; `Task_2_Backend_Plan.docx` mentions hypothetical format `VK7-JER-BLU-M` | **MOCK / SPECULATIVE** | No real SKU master spreadsheet or product inventory list exists on disk. |
| **Product Descriptions** | Short generic marketing strings ("High-performance technical jersey") | **MOCK / DEMO DATA** | Placeholder copy; no technical fabric specs (GSM, polyester blend, dri-fit specs) provided by client. |
| **Prices** | Retail prices ₹899, ₹1,199, ₹1,299, ₹1,499, ₹1,699, ₹1,899, ₹2,499 | **MOCK / DEMO DATA** | Hardcoded on prototype cards. Not confirmed by client as actual wholesale prices. |
| **Wholesale Tier Pricing** | Task 2 mentions bands (24–49 pcs, 50–99 pcs, 100+ pcs) with NO actual rupee amounts | **DOCUMENTED_ONLY (EMPTY)** | Rupee pricing per tier bracket is completely blank. The founder has not ratified the price tier matrix. |
| **Minimum Order Quantity (MOQ)** | Mentioned as "24 pieces" in Task 1 walkthrough; "10–25" in enquiry dropdown | **CONTRADICTORY / UNRATIFIED** | 24-piece MOQ is stated in Task 1 docx but not ratified by client contract. Prototype allows quantity 1. |
| **Garment Categories** | Prototype: Cricket, Football, Basketball, Volleyball, Athletics. Task 1: Jerseys, Pants, Shorts, T-Shirts | **CONTRADICTORY SPECS** | Two conflicting taxonomy models exist across documents. No official client category list ratified. |
| **Sizes** | S, M, L, XL | **STANDARD PLACEHOLDER** | Generic apparel sizing labels. No size measurement chart (chest, length in inches/cm) provided by client. |
| **Colors** | Blue, Red, White, Black, Green, Navy | **STANDARD PLACEHOLDER** | Basic CSS color names. No Pantone codes or fabric swatch references. |
| **Stock Levels** | "In Stock" on all 7 cards; Admin orders count: "37" | **MOCK / FAKE DATA** | Fabricated numbers to populate UI wireframes. |
| **Company Legal Details** | "VK7SPORTS" | **MINIMAL REAL DATA** | Brand name VK7SPORTS is real. Legal entity name, GSTIN, registered corporate address, and IEC code are **MISSING**. |
| **Contact Information** | `sales@vk7sports.com`, placeholder telephone numbers | **UNVERIFIED PLACEHOLDER** | Email domain `vk7sports.com` exists in copy; unverified if DNS/MX records are active. |
| **Store Policies** | Footer links: "Privacy Policy", "Terms of Service", "Return Policy", "Shipping Policy" | **MOCK / EMPTY** | Every policy link is `href="#"`. Zero policy text has been authored or approved by legal counsel. |
| **Wholesale Retailer Terms** | None | **MISSING** | Payment terms, credit policies, freight/shipping responsibility, and return terms for shopkeepers are missing. |
| **Payment Gateway Credentials** | None | **MISSING** | No Razorpay or Cashfree merchant credentials or API keys exist. |

---

## 3. Client Readiness Verdict

### Overall Content Readiness: **0% (BLOCKED ON CLIENT INPUTS)**

The VK7SPORTS project has **zero usable commercial content ready for a production launch**:
1. **No Product Catalog:** We have no spreadsheet, database dump, or document listing VK7SPORTS' real apparel items.
2. **No Real Pricing:** We do not know what VK7SPORTS charges for a bulk order of 24, 50, or 100 jerseys.
3. **No Commercial Photography:** VK7SPORTS has supplied zero high-resolution product photography, flat-lays, or ghost mannequin images.
4. **No Legal Framework:** No GST number, company address, terms of sale, or return policies exist.

**Conclusion:** Launching or coding a production e-commerce store is impossible until VK7SPORTS / client provides an authoritative Product Master Spreadsheet (SKUs, names, descriptions, wholesale tier prices, sizes, colors) and authentic photography assets.
