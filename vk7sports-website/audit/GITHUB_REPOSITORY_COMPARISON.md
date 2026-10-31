# GITHUB REPOSITORY FORENSIC COMPARISON

**Audit Date:** 11 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Repositories Inspected:**
1. `https://github.com/Anvora-Global/vk7sports-website`
2. `https://github.com/AASIOM8/vk7sports-website`

---

## 1. High-Level Comparison Summary

| Comparison Dimension | `Anvora-Global/vk7sports-website` | `AASIOM8/vk7sports-website` | Divergence / Verdict |
|---|---|---|---|
| **Repository Visibility** | Private | Private | Identical |
| **Default Branch** | `main` | `main` | Identical |
| **Active Branches** | `main` (only) | `main` (only) | Identical |
| **Total Commit Count** | 3 commits | 3 commits | **100% IDENTICAL** |
| **HEAD Commit SHA** | `7308e0e980a45a0701f0617fa80fa92e2778cdca` | `7308e0e980a45a0701f0617fa80fa92e2778cdca` | **MATCH (Zero divergence)** |
| **Contributors** | 1 (`Nooruzma-Khan`) | 1 (`Nooruzma-Khan`) | Identical |
| **Tracked Files in Tree** | Exactly 6 files | Exactly 6 files | Identical |
| **Open Issues / PRs** | 0 issues, 0 PRs | 0 issues, 0 PRs | Identical |
| **Repository Creation Date**| 2026-08-04T12:34:04Z | 2026-09-13T20:40:48Z | Different (AASIOM8 created during migration) |
| **Repository Description** | *"Official repository for the VK7SPORTS website..."* | None (Blank) | Metadata difference only |

---

## 2. Commit History Audit

Both repositories contain the **exact identical three commits**:

```text
Commit 1:
SHA:    1ba7bc7525de3389622475edcc544ee0846d6077
Author: Nooruzma-Khan <knooruzma@gmail.com>
Date:   2026-08-04 18:04:05 +0530
Title:  Initial commit

Commit 2:
SHA:    4eb2ee9f5829e8f9074ac6d71c2640c67d8ea8d1
Author: Nooruzma-Khan <knooruzma@gmail.com>
Date:   2026-08-04 18:18:46 +0530
Title:  Add initial VK7SPORTS prototype

Commit 3 (HEAD):
SHA:    7308e0e980a45a0701f0617fa80fa92e2778cdca
Author: Nooruzma-Khan <knooruzma@gmail.com>
Date:   2026-08-04 18:21:35 +0530
Title:  Update README.md
```

**Forensic Finding:** Zero commits have been authored, merged, or pushed to either remote repository since 4 August 2026.

---

## 3. File Tree Verification

Both remote repositories contain the exact same 6 tracked files at HEAD:
1. `README.md` (532 bytes, SHA `f100cb56dfb6f0497d72e5dd3dc121960216926a`)
2. `VK7SPORTS_Prototype/AdminDashboardPage.html` (19,843 bytes, SHA `5bdc4e1f8758baa25ea460ad1c83f04c039bf7d6`)
3. `VK7SPORTS_Prototype/HomePage.html` (22,109 bytes, SHA `c879847040773944d8b4049bb5f31228daae3d42`)
4. `VK7SPORTS_Prototype/ShopPage.html` (200,862 bytes, SHA `194e3a2dd6f1fb9ad5602a34f6ecfbfe2d99309b`)
5. `VK7SPORTS_Prototype/VK7SPORTS_Prototype_Description_Report.docx` (157,879 bytes, SHA `9267355947b249b68fb77a1f060cdee8fd0c6d5d`)
6. `VK7SPORTS_Prototype/custom-teamwear.html` (122,301 bytes, SHA `b73502b809c543dfd816231daf82a803772fee05`)

---

## 4. Uncommitted Local Work & Checkouts

Three local checkouts exist on the Mac:

1. **`PROJECTS/FREELANCE/VK7SPORTS/repo-audit`:**
   - Tracking: `Anvora-Global/vk7sports-website`
   - State: **Clean.** 0 uncommitted changes. Exactly matches both remotes.
2. **`AASIOM8-GITHUB-MIGRATION-WORKSPACE/tmp-clones/vk7sports-website`:**
   - Tracking: Dual remotes (`origin` → Anvora-Global, `aasiom8` → AASIOM8)
   - State: **Clean.** 0 uncommitted changes. Exactly matches both remotes.
3. **`.gemini/antigravity-ide/scratch/vk7sports-website`:**
   - Tracking: `Anvora-Global/vk7sports-website`
   - State: **DIRTY.** 4 modified HTML files, 1 untracked file (`index.html`).
   - Uncommitted changes: Local relative link rewrites and Account-to-Admin link wiring.
   - Status: **Isolated tool scratch. Never committed or pushed to either remote.**

---

## 5. Determination & Remote Recommendation

### Determination:
`AASIOM8/vk7sports-website` is a **100% byte-for-byte mirror** of `Anvora-Global/vk7sports-website`. There is **zero divergence, zero unique commits, and zero conflicting branches** between the two remotes.

### Recommended Canonical Remote Destination:
**`https://github.com/AASIOM8/vk7sports-website.git`**

- **Why:**
  1. It is directly managed under the primary active organization account (`AASIOM8`).
  2. The authenticated GitHub CLI token on this Mac has full admin/push scopes for `@AASIOM8`.
  3. It preserves the exact 3 historical commits authored by Nooruzma Khan in August 2026.
  4. It avoids creating a redundant third repository on GitHub.
