# UNMERGED UNIQUE WORK & DIVERGENCE REGISTER

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Purpose:** Forensic record of all unique, divergent, or modified code discovered in historical/scratch checkouts that was **deliberately NOT merged** into `VK7SPORTS-CANONICAL/app/`.

---

## 1. Summary of Unmerged Code Findings

During the forensic audit across all checkouts of `vk7sports-website`, only one checkout was found to contain unmerged code modifications:
- **Source Location:** `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/`
- **Base Commit:** `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- **Modification Date:** 31 August 2026 (approx 16:36–16:39 IST)
- **Worktree State:** 4 modified tracked HTML files, 1 untracked file (`index.html`)

Per forensic instructions, this code was **isolated and not merged** into `app/` to prevent contamination of the clean canonical baseline.

---

## 2. Granular Unmerged Work Items

### Item 1: Root Landing Portal (`index.html`)
- **Source Path:** `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/index.html`
- **File / Commit Status:** Untracked file (3,719 bytes, 120 lines). Created 31 August 2026.
- **What is Unique:**
  - Placed at repository root (where users/browsers naturally look for an entrypoint).
  - Contains instant meta-refresh redirect: `<meta http-equiv="refresh" content="0; url=VK7SPORTS_Prototype/HomePage.html">`.
  - Styled with dark mode glassmorphism card and links to all prototype pages.
- **Why it May Matter:**
  - The canonical repository currently has no root `index.html` (only `README.md` and subfolder `VK7SPORTS_Prototype/`). Serving the repo via GitHub Pages or static host requires an entrypoint at root.
- **Recommended Action for Om & ChatGPT:**
  - **EVALUATE FOR FUTURE STATIC HOSTING.** Do not merge directly yet. If a static demonstration host is deployed, a sanitized root entrypoint is useful, but should point to the production app once built.

---

### Item 2: Inter-Page Navigation Wiring (`href` Rewrites)
- **Source Path:** 
  - `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/VK7SPORTS_Prototype/HomePage.html`
  - `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/VK7SPORTS_Prototype/ShopPage.html`
  - `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/VK7SPORTS_Prototype/custom-teamwear.html`
- **File / Commit Status:** Working tree uncommitted diff against commit `7308e0e`.
- **What is Unique:**
  - Replaces dummy `href="#"` links with actual relative file paths:
    - "Shop By Sport" → `ShopPage.html`
    - "Teamwear" → `custom-teamwear.html`
    - "Bulk Orders" → `custom-teamwear.html`
    - "About" → `#why-vk7` (added anchor ID on Home value section)
    - Hero "Shop Now" button → `onclick="window.location.href='ShopPage.html'"`
- **Why it May Matter:**
  - Makes the static prototype clickable and navigable as a multi-page demonstration.
- **Recommended Action for Om & ChatGPT:**
  - **DO NOT MERGE INTO PRODUCTION CODE.** Keep canonical `app/` as the exact upstream mirror of commit `7308e0e`. When the real Next.js application is built, Next.js routing (`<Link href="/shop">`) will replace all static HTML anchors cleanly.

---

### Item 3: "View Store ↗" Quick Navigation Button
- **Source Path:** `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website/VK7SPORTS_Prototype/AdminDashboardPage.html`
- **File / Commit Status:** Working tree uncommitted diff (line 398).
- **What is Unique:**
  - Added a header action button: `<a href="HomePage.html" style="...">View Store ↗</a>`.
  - Linked admin logo back to `HomePage.html`.
- **Why it May Matter:**
  - Provides quick toggle between the admin console and the public storefront.
- **Recommended Action for Om & ChatGPT:**
  - A standard feature for e-commerce admin panels (e.g., Shopify). Include as a requirement in the future authenticated Admin UI, but do not patch into the static prototype HTML.

---

### Item 4: Customer "Account" Link Wired to Admin Dashboard (CRITICAL HAZARD)
- **Source Path:**
  - `HomePage.html` (line 563): `<span>Account</span>` replaced with `<a href="AdminDashboardPage.html">Admin</a>`
  - `ShopPage.html` (line 733): `<span>Account</span>` replaced with `<a href="AdminDashboardPage.html">Admin</a>`
  - `custom-teamwear.html` (line 778): Topbar Account replaced with `<a href="AdminDashboardPage.html">Admin Portal</a>`
- **File / Commit Status:** Working tree uncommitted diff.
- **What is Unique:**
  - Bypassed the customer account boundary completely by routing ordinary shoppers directly to the unauthenticated Admin Dashboard.
- **Why it May Matter:**
  - **SEVERE ARCHITECTURAL HAZARD.** Demonstrates how informal scratch edits can introduce critical security regressions.
- **Recommended Action for Om & ChatGPT:**
  - **REJECT PERMANENTLY.** Under no circumstances should this wiring ever be committed or merged into any canonical repository.
