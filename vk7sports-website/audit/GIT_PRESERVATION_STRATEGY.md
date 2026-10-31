# GIT HISTORY PRESERVATION STRATEGY

**Audit Date:** 10 October 2026  
**Auditor:** VK7SPORTS Project Forensic Auditor (AASIOM Technologies)  
**Objective:** Guarantee that the canonical repository history (the 3 historical commits authored on 4 August 2026) is never flattened, destroyed, or rewritten.

---

## 1. Existing Git History That Must Be Preserved

The Git repository (`AASIOM8/vk7sports-website` / `Anvora-Global/vk7sports-website`) contains 3 authenticated historical commits:

```text
7308e0e980a45a0701f0617fa80fa92e2778cdca (2026-08-04 18:21:35) Update README.md
4eb2ee9f5829e8f9074ac6d71c2640c67d8ea8d1 (2026-08-04 18:18:46) Add initial VK7SPORTS prototype
1ba7bc7525de3389622475edcc544ee0846d6077 (2026-08-04 18:04:05) Initial commit
```

**Rule:** Under NO circumstances should `git init` be run to overwrite this repository with an artificial "Initial Commit" that erases Nooruzma Khan's commit timestamps and lineage.

---

## 2. Evaluation of Git Integration Strategies

### Option A: Direct In-Tree Monorepo Expansion (RECOMMENDED)
- **Mechanism:**
  1. Use the existing clean clone (`/Users/aasiom/PROJECTS/FREELANCE/VK7SPORTS/repo-audit`).
  2. Inside this Git repository, restructure `VK7SPORTS_Prototype/` into `app/VK7SPORTS_Prototype/`.
  3. Commit the new directories (`docs/`, `assets/`, `data/`, `design/`, `audit/`, `archive-reference/`, `PROJECT_STATUS.md`, `SOURCE_MANIFEST.md`).
  4. Commit SHA `7308e0e` remains the unbroken direct ancestor of all future commits.
- **Advantages:**
  - 100% linear history preservation.
  - No submodules or external repository dependencies.
  - GitHub automatically renders complete history dating back to August 2026.
  - Zero risk of detached history or git corruption.

### Option B: Tagged Legacy Preservation & Clean Greenfield Branch
- **Mechanism:**
  1. Tag commit `7308e0e` with annotated tag `v0.1.0-prototype` or `archive/client-html-prototype`.
  2. Create branch `legacy/html-prototype` pointing at `7308e0e`.
  3. Evolve branch `main` with the new production monorepo.
- **Advantages:**
  - Preserves exact prototype snapshot under an immutable tag.
  - Allows clean separation between the static prototype and the upcoming Next.js application.

### Option C: Standalone Monorepo with Submodule (NOT RECOMMENDED)
- **Mechanism:** Embed `vk7sports-website` as a Git submodule inside `VK7SPORTS-CANONICAL/app`.
- **Disadvantages:** Submodule synchronization overhead, complex CI/CD cloning, developer friction.

---

## 3. Recommended Action for Om & ChatGPT

Proceed with **Option A + Option B**:
1. Tag commit `7308e0e` as `v0.1.0-html-prototype` to permanently freeze the historical demo state.
2. Push the consolidated canonical structure (`docs/`, `assets/`, `data/`, `app/`, `audit/`) as the next commit on branch `main` of `https://github.com/AASIOM8/vk7sports-website.git`.
3. **DO NOT PUSH YET.** Wait for founder and ChatGPT review before executing Git commits or pushes.
