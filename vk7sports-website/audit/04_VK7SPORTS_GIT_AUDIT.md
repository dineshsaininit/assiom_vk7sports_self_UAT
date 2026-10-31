# 04 — VK7SPORTS GIT AUDIT

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Mode:** READ-ONLY Forensic Inspection (No fetch, pull, push, reset, checkout, or merge operations)

---

## 1. Remote GitHub Repositories

Forensic inspection was executed via authenticated GitHub API (`gh`) across organizations `Anvora-Global` and `AASIOM8`.

### A. Upstream Origin: `Anvora-Global/vk7sports-website`
- **Remote URL:** `https://github.com/Anvora-Global/vk7sports-website.git`
- **Repository ID / Node:** `O_kgDOEoW64A`
- **Created At:** 2026-08-04T12:34:04Z
- **Updated At:** 2026-08-04T12:53:36Z
- **Visibility:** Private
- **Default Branch:** `main`
- **Parent / Fork:** None (`parent: null` — original root repository)
- **Description:** *"Official repository for the VK7SPORTS website, including the initial client prototype and ongoing development."*
- **Branches:** `main` (only)
- **Tags:** None
- **Commit Count:** 3 commits

### B. Migration Mirror: `AASIOM8/vk7sports-website`
- **Remote URL:** `https://github.com/AASIOM8/vk7sports-website.git`
- **Repository ID / Node:** `U_kgDOERx89w`
- **Created At:** 2026-09-13T20:40:48Z
- **Updated At:** 2026-09-13T20:45:42Z
- **Visibility:** Private
- **Default Branch:** `main`
- **Parent / Fork:** None (`parent: null` — standalone mirrored repository)
- **Description:** None (blank)
- **Branches:** `main` (only)
- **Tags:** None
- **Commit Count:** 3 commits

### Forensic Relationship:
Both remotes share the **exact identical commit tree and commit hashes**. `AASIOM8/vk7sports-website` is a direct mirror of `Anvora-Global/vk7sports-website` created on 13 September 2026 during an organization migration pass. Neither remote has diverged.

---

## 2. Remote Commit History (Both Repositories)

The complete Git history of VK7SPORTS consists of exactly three commits:

```text
* commit 7308e0e980a45a0701f0617fa80fa92e2778cdca (HEAD, origin/main, aasiom8/main)
| Author: Nooruzma-Khan <knooruzma@gmail.com>
| Date:   Tue Aug 4 18:21:35 2026 +0530
|
|     Update README.md
|
* commit 4eb2ee9f5829e8f9074ac6d71c2640c67d8ea8d1
| Author: Nooruzma-Khan <knooruzma@gmail.com>
| Date:   Tue Aug 4 18:18:46 2026 +0530
|
|     Add initial VK7SPORTS prototype
|
* commit 1ba7bc7525de3389622475edcc544ee0846d6077
  Author: Nooruzma-Khan <knooruzma@gmail.com>
  Date:   Tue Aug 4 18:04:05 2026 +0530

      Initial commit
```

**Forensic Finding:** Zero commits have been made to either remote repository since 4 August 2026 18:21:35 IST (over two months of dormancy in code commits).

---

## 3. Local Git Repositories Audit

Three local working copies of `vk7sports-website` were discovered on the Mac filesystem.

### Repository 1: `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/repo-audit`
- **Role:** **CANONICAL VERIFIED AUDIT CHECKOUT**
- **Disk Size:** 952 KB total (working tree: 524 KB, `.git`: 428 KB)
- **Current Branch:** `main`
- **HEAD Commit:** `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- **HEAD Subject:** `Update README.md`
- **Remotes:**
  - `origin` → `https://github.com/Anvora-Global/vk7sports-website.git` (fetch & push)
- **Status:** **CLEAN**
  - Untracked files: 0
  - Modified files: 0
  - Stash entries: 0
  - Ahead / behind: 0 / 0 relative to `origin/main`
- **Tracked Files in HEAD (6 files):**
  1. `README.md` (532 bytes)
  2. `VK7SPORTS_Prototype/AdminDashboardPage.html` (19,843 bytes)
  3. `VK7SPORTS_Prototype/HomePage.html` (22,109 bytes)
  4. `VK7SPORTS_Prototype/ShopPage.html` (200,862 bytes)
  5. `VK7SPORTS_Prototype/VK7SPORTS_Prototype_Description_Report.docx` (157,879 bytes)
  6. `VK7SPORTS_Prototype/custom-teamwear.html` (122,301 bytes)

---

### Repository 2: `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/tmp-clones/vk7sports-website`
- **Role:** **MIGRATION CLONE / MIRROR WORKSPACE**
- **Disk Size:** 960 KB total (working tree: 524 KB, `.git`: 436 KB)
- **Current Branch:** `main`
- **HEAD Commit:** `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- **Remotes:**
  - `origin` → `https://github.com/Anvora-Global/vk7sports-website.git` (fetch & push)
  - `aasiom8` → `https://github.com/AASIOM8/vk7sports-website.git` (fetch & push)
- **Status:** **CLEAN**
  - Untracked files: 0
  - Modified files: 0
  - Stash entries: 0
  - Ahead / behind: 0 / 0 relative to `origin/main` and `aasiom8/main`
- **Byte Comparison with Repo 1:** 100% byte-for-byte identical working tree (`diff -r` returns zero differences).

---

### Repository 3: `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website`
- **Role:** **TOOL SCRATCH (DIRTY / CONTAMINATED)**
- **Disk Size:** 956 KB total (working tree: 528 KB, `.git`: 428 KB)
- **Current Branch:** `main`
- **HEAD Commit:** `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- **Remotes:**
  - `origin` → `https://github.com/Anvora-Global/vk7sports-website.git` (fetch & push)
- **Status:** **DIRTY (UNCOMMITTED CHANGES)**
  - Modified files (4):
    - `VK7SPORTS_Prototype/AdminDashboardPage.html`
    - `VK7SPORTS_Prototype/HomePage.html`
    - `VK7SPORTS_Prototype/ShopPage.html`
    - `VK7SPORTS_Prototype/custom-teamwear.html`
  - Untracked files (1):
    - `index.html` (3,719 bytes)
  - Stash entries: 0

#### Forensic Analysis of Repository 3 Modifications:
The uncommitted diff in Repository 3 represents local navigation wiring introduced on 31 August 2026:
1. Replaced dummy `href="#"` links with relative links between prototype pages:
   - `HomePage.html` links "Shop By Sport" to `ShopPage.html`, "Teamwear" to `custom-teamwear.html`.
   - "Shop Now" hero button wired with inline `onclick="window.location.href='ShopPage.html'"`.
   - Replaced "Account" link in customer headers with direct link to `AdminDashboardPage.html` (`<a href="AdminDashboardPage.html">Admin</a>`).
2. Added `index.html` at repository root containing a meta-refresh redirect (`<meta http-equiv="refresh" content="0; url=VK7SPORTS_Prototype/HomePage.html">`) and an styled landing portal card.
3. In `AdminDashboardPage.html`, added a "View Store" link pointing to `HomePage.html`.

**Critical Risk Assessment:**
Wired customer "Account" links directly to the unauthenticated Admin Dashboard. If committed or migrated into production, this would represent a severe architectural confusion and security bypass. **This scratch copy must NOT be committed or merged.**

---

## 4. Other Related Non-Git Directories

| Directory Path | Git Repo? | Description |
|---|---|---|
| `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/` | NO | Umbrella folder holding `00_SOURCE`, `01_CLIENT_REQUIREMENTS`, `02_PROTOTYPES`, `03_BACKEND_PLAN`, `04_AUDITS`, `05_HANDOFFS`, `06_MODEL6`, and `repo-audit/`. |
| `/Users/aasiom/PROJECTS/VK7SPORTS/` | NO | Contains loose duplicate copies of `Task_2_Backend_Plan.docx` and `Task1_VK7SPORTS_Prototype_Walkthrough.docx`. |
| `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/projects/vk7sports-website/` | NO | Holds migration verification text snapshots (`GIT_STATE_AFTER.txt`, `HEAD_VERIFICATION.txt`, etc.). |
| `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/handoff/projects/vk7sports-website/` | NO | Duplicate copy of migration verification text snapshots. |

---

## 5. Classification of All Copies

| Copy / Location | Classification | Rationale |
|---|---|---|
| `Anvora-Global/vk7sports-website` | **HISTORICAL UPSTREAM** | Original remote where initial commits were pushed. |
| `AASIOM8/vk7sports-website` | **CANONICAL REMOTE MIRROR** | Maintained under company GitHub organization `AASIOM8`. |
| `PROJECTS/FREELANCE/VK7SPORTS/repo-audit` | **CANONICAL LOCAL CHECKOUT** | Retained verified clean audit checkout matching upstream HEAD. |
| `AASIOM8-GITHUB-MIGRATION-WORKSPACE/tmp-clones/vk7sports-website` | **MIGRATION MIRROR** | Clean clone created for dual-remote migration; exact match. |
| `.gemini/antigravity-ide/scratch/vk7sports-website` | **SCRATCH / CONTAMINATED** | Dirty tool state with local navigation edits and untracked file. |
| `PROJECTS/VK7SPORTS/` | **HISTORICAL SCRATCH** | Non-git directory holding loose docx files; duplicate of freelance subfolder. |
