# VK7SPORTS Development History

**Prepared:** 2026-10-26 by Claude Code, from read-only inspection of Git history and project documents.
**Labels:**
- **[GIT]** verified from a Git commit or ref
- **[SRC]** verified from source or file metadata
- **[HIST]** historical project document
- **[AGENT]** report by an AI agent (Claude, Codex, AGY/Antigravity, Grok, the "Model 1–6" deliberation agents)
- **[IND]** independently tested (none)
- **[PROP]** proposed, not implemented

Path roots:
- **M** = `~/PROJECTS/VK7SPORTS-MASTER`
- **V** = `~/PROJECTS/VK7SPORTS` (website repo)
- **B** = `~/PROJECTS/VK7SPORTS-BACKEND`

> **Key point for new developers:** the project went through several **planning** stacks (NestJS/Medusa, Next.js/Drizzle/PostgreSQL) that were **never implemented**. The only executable backend is the **Bagisto 2.5.0 + B2B Suite + VK7 Wholesale** codebase, built in mid-October 2026. The only frontends are three **mock/demo** prototypes.

---

## 1. Chronology

### Phase 0: Discovery and planning (July – early August 2026)
| Date | Event | Evidence |
|---|---|---|
| Jul 2026 | Client briefings record business facts (about ₹1 crore/month turnover, sourcing from China, Taiwan and India, offline and WhatsApp sales) | [HIST] `M/02_BUSINESS_REQUIREMENTS/CLIENT_PROFILE_AND_BUSINESS_FACTS.md` L10–15. Later graded "reported, unverified" by the Recovery Audit [AGENT]. |
| 28 Jul | Website Strategy Audit; Figma UI/UX spec | [HIST] `M/05_DOCUMENTATION_AND_SPECS/VK7SPORTS_Website_Strategy_Audit.md` L3; `VK7SPORTS_Figma_UIUX_Spec.md` |
| 29 Jul | Business OS, Enterprise Information Architecture, Pre-Discovery Draft; Project Lead Handbook issued to Pradnya Gaikwad | [HIST] `V/docs/execution-plans/*`, `M/05_…/Enterprise_Information_Architecture.docx` |
| 1 Aug | Master Blueprint v1.0 (NestJS / Medusa / PostgreSQL) | [HIST] `V/docs/architecture/Premium_Apparel_Project_Master_Blueprint_v1.0.docx`. **[PROP], never implemented.** |

### Phase 1: Intern static prototype and schema (August 2026)
| Date | Event | Evidence |
|---|---|---|
| 4 Aug | Repo initialised. Four static HTML pages plus a description report added. README. | [GIT] V `1ba7bc7`, `4eb2ee9`, `7308e0e` (author Nooruzma-Khan), pushed to `Anvora-Global/vk7sports-website` |
| 5 Aug | ER diagram | [SRC] `V/design/diagrams/vk7sports_ER_Diagram.pdf` (PDF creation date) |
| ~Aug | Intern database schema (PostgreSQL-style: UUID, JSONB, single stock column; omni-channel tables including custom kit designs) | [HIST] `M/05_…/02_Original_DB_Schema.docx`. **[PROP], never implemented.** |
| 10 Aug | Backend Improvement Manual reviewing the schema ("useful first pass… not production-ready") | [HIST] `M/05_…/VK7SPORTS_Backend_Improvement_Manual.pdf` p1 |
| 31 Aug | Antigravity IDE scratch edits, never committed (included an unsafe Account → Admin link) | [AGENT] `V/audit/UNMERGED_UNIQUE_WORK.md` L11–15, 70–81 |

### Phase 2: Scope pivot, migration and multi-model planning (September 2026)
| Date | Event | Evidence |
|---|---|---|
| 13–14 Sep | GitHub migration: added `AASIOM8/vk7sports-website` remote and pushed `7308e0e`; secret scan PASS | [HIST] `~/AASIOM8-GITHUB-MIGRATION-WORKSPACE/projects/vk7sports-website/*.txt`; [GIT] V remotes `origin` (AASIOM8) and `anvora` (Anvora-Global) |
| ~14 Sep | Intern Task 1 (prototype walkthrough) and Task 2 (backend plan) pivot scope to **B2B shopkeepers**: MOQ 24, 100% online or 10/90 COD, 7 admin modules, no customiser. Task 2 is an 8-table PostgreSQL design. | [HIST] `M/06_QA_AND_TESTING/Task1_…docx`, `Task_2_Backend_Plan.docx`, `INTERN_WORK_REGISTER.md` L25–92; assessed as "specifications, not software" (`INTERN_SUBMISSION_ANALYSIS.md` L118–120) |
| 14 Sep | Canonical development path declared UNRESOLVED | [HIST] `V/archive-reference/HISTORICAL_CANONICAL_PATH_20260914.md` |
| 25–27 Sep | Multi-model deliberations. Current State Audit scores **0/24 capabilities implemented**. Model 4 ADR proposes Next.js + Drizzle + PostgreSQL (not founder-ratified). Model 6 CI plan is "documentation only". | [AGENT] `V/archive-reference/multi-model-deliberations/04_AUDITS/VK7SPORTS_CURRENT_STATE_AUDIT.md` L3–30, `…MODEL4_TECH_STACK_ADR.md` L1–5, `06_MODEL6/…CI_RELEASE_PLAN.md` L5. **[PROP]** |

### Phase 3: Freeze, audit and consolidation (early–mid October 2026)
| Date | Event | Evidence |
|---|---|---|
| 6 Oct | "Freeze production code until commercial signoff" (DEC-VK7-010) | [AGENT] Recovery Audit §G, citing NotebookLM (`M/08_AGENT_REPORTS/VK7SPORTS_Historical_Development_Recovery_Audit.pdf`) |
| 10–11 Oct | Read-only forensic audit (13 reports); Requirement Conflict Register RC-01 to RC-10 | [AGENT] `V/audit/01–13_*.md`; `M/02_…/REQUIREMENT_CONFLICT_REGISTER.md` |
| 11 Oct | Commit `144008c`: "consolidate complete VK7SPORTS project workspace" (62 files). Prototype moved to `app/` with unchanged content. Both remotes at this commit. | [GIT] V `144008c` |
| 13 Oct | Consolidation and security reports. Backups (workspace tarball and git bundle). | [AGENT] `V/VK7SPORTS_CONSOLIDATION_REPORT.md`; [SRC] `~/PROJECTS/vk7sports-backups/` |

### Phase 4: Backend evaluation and implementation (14–16 October 2026)
| Date | Event | Evidence |
|---|---|---|
| 14–15 Oct | Isolated **Bagisto 2.5.0 + B2B Suite 3.0.1** sandbox built with fictional data. Company registration and approval, configurable variants, RFQ, tier pricing, shipments and tracking exercised. | [HIST] `B/docs/SANDBOX-README-2026-10-15.md`; screenshots `B/evidence/2026-10-15-sandbox/01–26*.png` |
| 15 Oct | **Defects found and fixed:** configurable variants oversold (R0 reproduced), admin could over-ship, order-number collisions, quote → cart kept only the last variant | [HIST] `B/evidence/…/after-fix/R0-control-unpatched-race.txt`, `…/e2e/W-run-before-quote-fix-FAILED.txt` |
| 15 Oct | Fixes: core patches 0001/0002, the VK7 Wholesale package (MOQ, sequencer, variant-aware quote → cart, 422 handler), admin 2FA enforcement, personal-account approval | [SRC] `B/app/packages/VK7/Wholesale/src/*`, `B/patches/*` |
| 15 Oct | Author-run tests: races, MOQ, ledger, W1–W10 workflow **23/23**, security regression, Pest 1225 pass / 11 fail (the same 11 fail on unmodified Bagisto) | [HIST/AGENT, author-run, **not independent**] `B/evidence/…/after-fix/RESULTS.md`, `…/e2e/W1-W10-workflow.txt`, `…/final/pest-regression.txt` |
| 15 Oct | Codex frontend prototypes: catalogue (Phase 1.5, 20 tests self-reported) and integrated quotation demo (26 tests self-reported). Read-only Bagisto interface audit. Integration contract **draft**. | [AGENT] `~/PROJECTS/VK7SPORTS-CODEX-FRONTEND/VALIDATION.md`, `~/PROJECTS/VK7SPORTS-INTEGRATION/INTEGRATION_STATUS.md`, `VERIFIED_BACKEND_INTERFACES.md` |
| 16 Oct | Codex independent backend QA: **BLOCKED — environment unavailable** (sandbox denied Docker and loopback). It retracted an earlier "critical defects" wording. | [AGENT] `B/evidence/2026-10-16-codex-qa/INDEPENDENT_BACKEND_QA_REPORT.md` |
| 17 Oct | G01 scope: founder selected **Option B** (wholesale core plus multi-segment enquiry); owner approval pending. Architecture review and Execution Baseline v1.0. | [HIST] `M/02_…/VK7SPORTS_G01_Product_Scope_Decision_Brief.docx`; `M/08_AGENT_REPORTS/*17Oct*.pdf`, `VK7SPORTS_Current_Execution_Baseline_v1.0.pdf` |

### Phase 5: Preservation and governance (21–26 October 2026)
| Date | Event | Evidence |
|---|---|---|
| 21 Oct | Recovery Audit proposes VK7-DEV-001 (put the backend under version control) | [AGENT] Recovery Audit pp. 17–18 |
| 21 Oct, 07:22–07:23 | **Backend repository created.** `main` has 6 commits (`aaf52e5` upstream base → `6b6538c` B2B → `63b57d0` patches → `7caa01e` VK7 package → `b5467c5` runtime/QA kit → `498fb8d` evidence). Branch `draft-aborted-1` holds 5 earlier commits. Annotated tag `baseline-2026-10-15` → `498fb8d`. No remote. | [GIT] B |
| 21 Oct | Founder decisions **F1** (preservation repo, executed), **F6** (pinned runtime), **F8** (parameterised QA kit), **F9** (retain core patches) | [HIST] tag message; `B/docs/PINNED-VERSIONS.md` L1; `B/docs/CORE-PATCHES.md` L1; `B/qa/CODEX-HANDOFF.md` |
| 21 Oct | Live DB dumps and restore drill reported (175 tables, 230 FKs) | [AGENT] `M/01_PROJECT_CONTROL/MASTER-STATUS.md` L41–52. Raw drill logs not located by Codex on 26 Oct [AGENT]. |
| 22 Oct | `VK7SPORTS-MASTER` created by out-of-place copy (DEC-007); accuracy corrections VK7-DOC-005 | [AGENT] `M/01_PROJECT_CONTROL/CHANGELOG.md` L7–22, `DECISION-REGISTER.md` |
| 26 Oct | Claude static backend reuse audit (D-01 to D-13). Codex evidence review ("launch readiness NOT ESTABLISHED"). Codex GitHub QA ("HOLD"). AGY Mac evidence inventory. | [AGENT] `M/08_AGENT_REPORTS/VK7SPORTS_CLAUDE_BACKEND_*_2026-10-26.md`; `M/06_QA_AND_TESTING/VK7SPORTS_CODEX_INDEPENDENT_QA_EVIDENCE_2026-10-26.md`, `VK7SPORTS_GITHUB_REPOSITORY_QA_REPORT.md`; `M/08_AGENT_REPORTS/2026-10-26_MULTI_AGENT_AUDIT/` |

---

## 2. Development by theme

| Theme | What was actually built | What remained a plan |
|---|---|---|
| Website prototypes | V1 static HTML (Aug) [GIT]. V2/V3 Codex demos (15 Oct) [SRC]. | Next.js storefront (Task 1, Model 4, Execution table TSK-018) [PROP] |
| Backend | Bagisto + B2B Suite + VK7 Wholesale (15 Oct, preserved 21 Oct) [GIT] | NestJS/Medusa (Blueprint), Node/PostgreSQL (Task 2), Next.js/Drizzle (Model 4) [PROP] |
| B2B customisation | MOQ engine, variant-aware quote → cart, row-locked order numbers, admin 2FA, personal-account approval, 422 handler [SRC] | Custom orders, advance payments, shortage workflow [ABSENT] |
| Database | Bagisto MySQL schema plus `vk7_sequences` [SRC] | Intern PostgreSQL schema, Task 2 8-table design, Model 4 Drizzle model [PROP] |
| Quotation and ordering | B2B Suite RFQ → negotiate → accept → cart → order (author-run W5–W7 PASS) [HIST] | Fixes for D-01 to D-05 [PROP] |
| QA | Author-run sandbox tests; Codex frontend self-tests; parameterised QA kit [HIST/SRC] | Independent backend acceptance A–G / Q1–Q12: **never executed** [BLOCKED] |

---

## 3. Corrections and retractions on record

| Date | Correction | Evidence |
|---|---|---|
| 14 Sep | `repo-audit` reclassified from canonical source to audit checkout | `V/archive-reference/HISTORICAL_CANONICAL_PATH_20260914.md` |
| 25 Sep | Model 6 provenance correction: it had falsely claimed to read a Model 5 handoff | `V/archive-reference/multi-model-deliberations/06_MODEL6/VK7SPORTS_MODEL6_1_PROVENANCE_CORRECTION.md` |
| 16 Oct | Codex: "NOT READY — CRITICAL DEFECTS" changed to "BLOCKED — ENVIRONMENT UNAVAILABLE" | `B/evidence/2026-10-16-codex-qa/CRITICAL_DEFECT_REGISTER.md` |
| 21 Oct | Recovery Audit relabels 17 Oct claims as self-tested | Recovery Audit PDF |
| 22 Oct | VK7-DOC-005 removed unverified pricing and encryption claims | `M/01_PROJECT_CONTROL/CHANGELOG.md` L7–13 |
| 26 Oct | Claude: tag `baseline-2026-10-15` and HEAD are the **same commit** `498fb8d` (`5058907` is the annotated-tag object) | [GIT] `git rev-parse 'baseline-2026-10-15^{commit}'` |

## 4. Unresolved contradictions (for the documentation owner)

1. **DEC-006 price secrecy** is listed as "Implemented in evaluation backend" (`M/01_PROJECT_CONTROL/DECISION-REGISTER.md` L56). The source has **no guest price hiding**: the B2B catalogue filter is "inert for guests" (`b2b-suite/src/Providers/B2BSuiteManager.php` L64–66), and there is no setting in core or B2B config. [SRC]
2. **Restore drill:** MASTER-STATUS says VERIFIED, but Codex could not locate the raw logs [AGENT].
3. **MOQ "enforced"** (MASTER-STATUS) vs the code default **disabled** (`VK7/Wholesale/src/Config/system.php` L22–26). The 24 setting is in the golden DB fixture only. [SRC]
4. **2FA "unit checks"** (MASTER-STATUS L70) vs no PHP unit tests (`B/docs/CORE-PATCHES.md`). 2FA testing was author-run only.
5. **Task-ID collision:** VK7-DEV-002 means different things in CHANGELOG and in the Recovery Audit.
6. **Founder decisions F4, F5 and F7 are not documented anywhere.** "F1–F4" is also reused as QA scenario IDs (security tests).
7. **The 10–11 Oct audits are stale** about git: they say no commits since 4 Aug, but HEAD is now `144008c`.
8. **Audits 07/08** say HomePage has a menu button with no listener. HomePage has no menu button at all. [SRC]
9. `INTERN_SUBMISSION_ANALYSIS.md` L7 lists a wrong SHA for the Task 2 docx (`INTERN_WORK_REGISTER.md` L19 is correct) [AGENT verified by hash].
10. The Execution table plans a "Next.js frontend prototype", but the existing prototypes use no framework.
