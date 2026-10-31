# 12 — VK7SPORTS SOURCE OF TRUTH

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Standard:** Forensic determination of canonical repository, remote origin, branch, and commit.

---

## 1. Canonical Designation

Based on forensic verification of Git commit graphs, working tree purity, remote URLs, and organizational governance, the authoritative source of truth for VK7SPORTS is designated as follows:

### A. Canonical Local Repository
- **Path:** `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/repo-audit`
- **Why this path is designated:**
  1. It is a **100% clean Git checkout** with zero uncommitted modifications, zero untracked files, and zero stashes.
  2. Its remote `origin` directly tracks the historical upstream repository `https://github.com/Anvora-Global/vk7sports-website.git`.
  3. It was formally verified and designated as the official retained audit source checkout in `MAC-CLEANUP-AUDIT-work/acceptance/VK7_REPOSITORY_ROLE_VERIFICATION.md` on 14 September 2026.
  4. It is nested within the primary freelance project umbrella (`/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/`) which holds all supporting documentation, blueprints, and assets.

### B. Canonical GitHub Repository
- **Upstream Historical Canonical:** `https://github.com/Anvora-Global/vk7sports-website.git`
- **Current Operational Canonical Mirror:** `https://github.com/AASIOM8/vk7sports-website.git`
- **Why both are recognized:**
  1. `Anvora-Global/vk7sports-website` is the **original upstream repository** created on 2026-08-04 where the initial prototype was pushed by Nooruzma Khan.
  2. `AASIOM8/vk7sports-website` is the **active organizational repository** under the current authenticated GitHub account (`AASIOM8`), created during the 13–14 September 2026 migration pass.
  3. Both remotes are in **100% synchronization** at the exact same commit hash (`7308e0e980a45a0701f0617fa80fa92e2778cdca`).

### C. Canonical Branch
- **Branch Name:** `main`
- **Why:** It is the default, primary, and only branch present on both remote repositories and local checkouts. No feature branches or tags exist.

### D. Canonical HEAD Commit
- **Commit SHA:** `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- **Commit Subject:** `Update README.md`
- **Author:** `Nooruzma-Khan <knooruzma@gmail.com>`
- **Committed At:** `2026-08-04 18:21:35 +0530`
- **Why:** This is the latest and final commit recorded in the Git history across all remotes and checkouts. Zero commits have been authored since this timestamp.

---

## 2. Classification of All Discovered Copies and Repositories

| Repository / Directory Path | Classification | Detailed Rationale & Status |
|---|---|---|
| `Anvora-Global/vk7sports-website` (GitHub) | **HISTORICAL UPSTREAM** | The original private repository on GitHub where the prototype was initially committed on 4 August 2026. Standalone root. |
| `AASIOM8/vk7sports-website` (GitHub) | **CANONICAL REMOTE MIRROR** | Mirrored under active organization account `AASIOM8` on 13 September 2026. Matches upstream tip byte-for-byte. Recommended destination for future work. |
| `/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/repo-audit` | **CANONICAL LOCAL CHECKOUT** | Retained clean local clone at HEAD `7308e0e`. Confirmed on 2026-09-14 as verified audit checkout. |
| `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/tmp-clones/vk7sports-website` | **MIRROR (MIGRATION STAGING)** | Staging clone created during migration pass. Has dual remotes (`origin` and `aasiom8`). Clean at `7308e0e`. Retain as migration record. |
| `/Users/aasiom/.gemini/antigravity-ide/scratch/vk7sports-website` | **SCRATCH / CONTAMINATED** | Uncommitted tool checkout containing modified HTML files and untracked `index.html`. Contains dangerous Account-to-Admin link wiring. **Must NOT be used as development base or committed.** |
| `/Users/aasiom/PROJECTS/VK7SPORTS/` | **HISTORICAL DUPLICATE** | Non-git loose folder containing duplicate copies of `Task1_VK7SPORTS_Prototype_Walkthrough.docx` and `Task_2_Backend_Plan.docx`. Candidate for archiving. |
| `/Users/aasiom/PROJECTS/AASIOM/AASIOM_OM_MASTER_MERGED_ARCHIVE/VK7SPORTS_Backend_Complete_Chat_Package/` | **HISTORICAL ARCHIVE** | Preserved evidence package containing original intern ERD and DB schema docx. Retain as historical record. |
| `/Users/aasiom/Documents/Claude/Projects/RAKSHA/VK7SPORTS/` | **HISTORICAL STRATEGY ARCHIVE** | Pre-discovery strategy audit and Figma UI/UX spec files from July 2026. App-managed directory; do not move. |

---

## 3. Preservation Directives (Read-Only Safety)

1. **Do Not Delete or Clean the Scratch Checkout:** Although `.gemini/antigravity-ide/scratch/vk7sports-website` is contaminated, it must remain untouched during this audit phase to comply with read-only rules.
2. **Do Not Push or Reset Any Remote:** Both `Anvora-Global` and `AASIOM8` must remain untouched at commit `7308e0e`.
3. **Canonical Development Path Resolution:** As established in `PROJECT_MANIFEST.md` and `VK7_REPOSITORY_ROLE_VERIFICATION.md`, a long-term dedicated development directory has **never been designated**. When implementation is authorized, a fresh, clean development directory should be created rather than developing directly inside `repo-audit` or `scratch`.
