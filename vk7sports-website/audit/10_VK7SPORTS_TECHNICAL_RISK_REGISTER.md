# 10 — VK7SPORTS TECHNICAL RISK REGISTER

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Standard:** Forensic vulnerability, architectural debt, and operational hazard classification.  
**Severity Rating Scale:** `CRITICAL` (System/business blocker), `HIGH` (Severe defect/security hazard), `MEDIUM` (Operational impediment), `LOW` (Minor technical debt).

---

## Technical Risk & Debt Register

| Risk ID | Category | Technical Hazard / Finding | Severity | Evidence / Source Location | Impact / Business Risk |
|---|---|---|---|---|---|
| **TR-01** | **Architecture** | **Total Absence of Backend & Persistence** | **CRITICAL** | Zero backend routes, controllers, or database schemas in Git HEAD (`repo-audit/`). | Impossible to process transactions, record user orders, authenticate users, or maintain inventory. Zero application exists today. |
| **TR-02** | **Security** | **Unauthenticated World-Readable Admin Dashboard** | **CRITICAL** | `VK7SPORTS_Prototype/AdminDashboardPage.html` is an unauthenticated static HTML file. | Anyone with URL can access back-office interface. If backend APIs are connected without authentication gates, administrative takeover is immediate. |
| **TR-03** | **Security / Fraud** | **Client-Authoritative Insecure Price Calculation** | **CRITICAL** | `custom-teamwear.html` line 1050: `'₹' + (qty * 1299)`. Zero server pricing service. | Users can manipulate client DOM, local storage, or payload to purchase items at arbitrary prices (e.g. ₹1). |
| **TR-04** | **Scope Oscillation** | **Implementation of Formally Removed Customizer** | **HIGH** | `custom-teamwear.html` is the most complex page in repo, but Task 1 explicitly removed customizer. | Continuing development on customizer burns budget building a feature the client explicitly discarded. |
| **TR-05** | **Data Integrity** | **Absence of Inventory Locking & Stock Authority** | **HIGH** | `ShopPage.html` hardcodes `<span class="stock-tag">In Stock</span>` across all cards. | High risk of overselling, stockouts, and dispute when multiple wholesale shopkeepers purchase limited variant inventory. |
| **TR-06** | **Legal / IP** | **Unlicensed Third-Party Sports Team Branding** | **HIGH** | `ShopPage.html` lines 833–950 uses "Inter Miami CF", "Mumbai Cricket Team", "AFG Away". | Severe legal risk of trademark infringement, cease-and-desist notices, or payment gateway account termination if launched publicly. |
| **TR-07** | **Repository** | **Repository Fragmentation & Scratch Contamination** | **HIGH** | `.gemini/antigravity-ide/scratch/vk7sports-website` has uncommitted link rewrites wiring Account to Admin. | If an engineer or automated pipeline commits from the scratch checkout, customer accounts will be wired to the admin portal. |
| **TR-08** | **Code Quality** | **Embedded Base64 JPEGs Bloating HTML** | **MEDIUM** | `ShopPage.html` is 200 KB because 7 product images are inlined as base64 strings. | Extremely slow initial HTML parsing, terrible cache efficiency, and poor repository maintainability. |
| **TR-09** | **Reliability** | **External CDN Image Hotlinking** | **MEDIUM** | `HomePage.html` loads 13 images from `images.unsplash.com`. | Any network failure, Unsplash rate limiting, or image deletion breaks the storefront visually. Fails completely in air-gapped or offline setups. |
| **TR-10** | **User Experience** | **Broken Core Navigation & Dead Buttons** | **MEDIUM** | All anchors across all pages are `href="#"`. Mobile hamburger on Home has zero JS listener. | Prototype cannot be navigated as a website. Mobile visitors on the homepage are trapped. |
| **TR-11** | **Code Structure** | **Four Duplicated Monolithic HTML Files** | **MEDIUM** | Header, footer, CSS resets, and styling duplicated across 4 HTML files (~3,450 lines). | Any header or footer change requires manual copy-pasting across four independent files. No modular component architecture. |
| **TR-12** | **Product Integrity** | **Deceptive Toast Notifications on Enquiries** | **MEDIUM** | `custom-teamwear.html` lines 1058–1075: buttons toast "Enquiry submitted successfully" with 0 network calls. | Users believe their bulk enquiry has been sent to VK7SPORTS, but data is discarded immediately. |
| **TR-13** | **Quality Assurance** | **Complete Absence of Automated Tests** | **HIGH** | 0 test files, 0 test frameworks, 0 CI test runners. | Zero regression protection. Every future build step is prone to breaking business rules without detection. |
| **TR-14** | **Deployment** | **Missing Infrastructure & Deployment Configuration** | **HIGH** | No Dockerfile, `fly.toml`, Vercel config, Nginx config, or `.env.example`. | System has no deployment target, environment variables contract, or staging environment. |
| **TR-15** | **Business Rule** | **Zero Enforcement of 24-Piece MOQ** | **HIGH** | No MOQ validation logic exists anywhere in code or database. | Shopkeepers can place single-item retail orders, completely defeating the B2B wholesale business model. |

---

## Ranked Top 10 Critical Risks

1. **TR-01 (Backend Absence):** Zero backend code or database exists — the project is 100% greenfield in code.
2. **TR-02 (Admin Security):** Admin Dashboard is a world-readable static HTML page with zero authentication.
3. **TR-03 (Pricing Authority):** The only pricing logic runs insecurely in the client browser (`qty * 1299`).
4. **TR-07 (Scratch Contamination):** Scratch repository checkout has uncommitted link rewrites connecting customer accounts to the admin portal.
5. **TR-04 (Scope Conflict):** The repo's most elaborate page (`custom-teamwear.html`) was formally removed in the latest specification.
6. **TR-06 (IP / Trademark Infringement):** Catalogue uses trademarked club names ("Inter Miami CF", "Mumbai Cricket Team").
7. **TR-15 (MOQ Absence):** Core commercial requirement of 24-piece minimum order quantity is completely unenforced.
8. **TR-05 (Inventory Absence):** Stock is a hardcoded visual string; zero inventory locking exists.
9. **TR-13 (Zero Tests / CI):** No automated tests, typechecks, or linters exist.
10. **TR-10 (Broken Navigation):** All links are `href="#"` and mobile hamburger menu is broken on Home.
