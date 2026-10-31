# VK7SPORTS Repository Structure Proposal

**Prepared:** 2026-10-26 by Claude Code. **Status: PROPOSAL ONLY.** Nothing has been restructured, created on GitHub or pushed.
**Principles:** preserve the existing Git history, preserve Bagisto/Laravel conventions, keep secrets and dumps out of Git, and make each repository independently reviewable.

---

## 1. Current state [SRC unless marked otherwise]

| Location | Git? | Remote | Content | Notes |
|---|---|---|---|---|
| `~/PROJECTS/VK7SPORTS-BACKEND` | Yes, `main` + `draft-aborted-1`, tag `baseline-2026-10-15` | **None configured** | Bagisto 2.5.0 + B2B Suite 3.0.1 + VK7 Wholesale, Docker, QA kit, evidence | 6 commits, all dated 2026-10-21 and co-authored by Claude. Clean working tree. |
| `~/PROJECTS/VK7SPORTS` | Yes, `main` (`144008c`) | `origin` = `github.com/AASIOM8/vk7sports-website`, `anvora` = `github.com/Anvora-Global/vk7sports-website` | August static prototype, docs, audits, data samples, archives | **16 uncommitted or untracked entries** (for example `PLAN/`, `evidence/`, `Claude outputs/`, reports). Two remotes; which one is canonical is a founder decision. |
| `~/PROJECTS/VK7SPORTS-CODEX-FRONTEND` | No | — | Codex catalogue prototype (ES modules) | Exists only as a local copy |
| `~/PROJECTS/VK7SPORTS-INTEGRATION` | No | — | Codex integrated quotation prototype and integration contracts | Exists only as a local copy |
| `~/PROJECTS/VK7SPORTS-BACKEND-PRIVATE` | No | — | Secrets, env files, DB dumps, storage archives | **Must never go to GitHub** |
| `~/PROJECTS/VK7SPORTS-MASTER` | No | — | Canonical document store (01–09 folders) | Documentation hub |
| `~/SANDBOX/bagisto-b2b-eval`, `~/SANDBOX/bagisto-qa-codex` | No | — | Original 15 Oct sandbox and the QA copy | Historical runtime sources. Keep them read-only. |

---

## 2. Recommended structure: multi-repository under one GitHub organisation

A monorepo is **not** recommended now. The backend is a full Bagisto application tree (about 4,100 files from upstream) with its own conventions. Mixing it with static prototypes and business documents would bloat reviews and blur the code-ownership boundaries.

### Repository A: `vk7sports-backend` (private)
**Source:** push `~/PROJECTS/VK7SPORTS-BACKEND` **as-is, with its full history and tag**. Do not re-initialise or squash it.

```
vk7sports-backend/
├── app/                      # Bagisto application root. Keep Bagisto layout unchanged.
│   ├── packages/Webkul/      # upstream core (+ patches 0001/0002 applied)
│   ├── packages/VK7/Wholesale/   # VK7 custom module (all new backend code goes here)
│   ├── resources/views/vendor/   # published B2B/Bagisto view overrides
│   └── composer.json / composer.lock
├── docker/                   # Dockerfile, compose.dev.yml, compose.qa.yml
├── patches/                  # reference copies of core patches
├── qa/                       # QA kit (no golden dump; it lives in private storage)
├── docs/                     # CORE-PATCHES, PINNED-VERSIONS, handover docs (copies of CODEBASE_HANDOVER/*.md)
├── evidence/                 # historical evidence (already committed)
├── .gitignore  .gitleaks.toml  .env.docker.example
└── README.md                 # from VK7SPORTS_GITHUB_README_DRAFT.md
```

Changes needed before the first push (each one is a separate, reviewed commit, and none is made now):
1. Remove the empty root directories `composer.json/` and `composer.lock/` (preservation artifacts).
2. Add `README.md` and `docs/` handover copies.
3. Confirm the `.gitignore` header "Draft … not applied anywhere yet" is accepted (it is in fact committed). Then update the header text.
4. Run a secret scan (`.gitleaks.toml` exists) before the push, with founder approval.
5. Decide whether `evidence/` (screenshots, ~26k lines) stays in this repository or moves to a separate evidence repository or release asset.

### Repository B: `vk7sports-website` (existing, keep history)
Continue the existing `AASIOM8/vk7sports-website` history (or Anvora-Global, per founder decision). It holds the static prototypes, and optionally the two Codex prototypes as subfolders:

```
vk7sports-website/
├── app/VK7SPORTS_Prototype/        # existing August prototype (tracked)
├── prototypes/codex-catalogue/     # from VK7SPORTS-CODEX-FRONTEND (new commit, with provenance note)
├── prototypes/integrated-quotation/ # from VK7SPORTS-INTEGRATION (new commit, with provenance note)
├── data/  design/  assets/
└── README.md
```

The 16 uncommitted entries in `~/PROJECTS/VK7SPORTS` must be reviewed by the founder **before** any commit, because some are reports or PDFs that may contain client information.

### Repository C: `vk7sports-docs` (private), or keep MASTER as the document store
The business requirements, owner documents (`02_BUSINESS_REQUIREMENTS`), agent reports and handover documents. **Client-identifying PDFs and DOCX files need a confidentiality review first.** Alternative: keep `VK7SPORTS-MASTER` as the offline document store and copy only the technical Markdown into `vk7sports-backend/docs/`.

### Never in GitHub
`VK7SPORTS-BACKEND-PRIVATE/*`, any `.env*` except the `*.example` files, `*.sql.gz` dumps, `storage-app-*.tar.gz`, `.secrets/`, TOTP secrets, sandbox `q.sh` outputs containing data.

---

## 3. Branch and contribution model (proposed)

| Rule | Proposal |
|---|---|
| Default branch | `main`, protected: no direct pushes, 1 approving review, required checks once CI exists |
| Work branches | `feat/<area>-<short>`, `fix/<id>-<short>`, `docs/<short>` |
| Baseline | Keep tag `baseline-2026-10-15` immutable. Tag future accepted states as `accepted-YYYY-MM-DD`. |
| `draft-aborted-1` | Keep it locally as history. Do not push it unless the founder wants it. |
| Commits | Small and single-purpose. Reference the decision or defect ID (for example `D-01`, `F9`). |
| Core files | No edits under `app/packages/Webkul/` except patch re-application. New behaviour goes in `app/packages/VK7/`. |
| Secrets | Pre-commit gitleaks; `.env.docker` stays local |
| CI (future) | Pest (upstream + VK7 tests), Pint, gitleaks. Nothing exists yet at the repository root. The upstream workflows (`pest-tests.yml`, `pint-tests.yml`, `playwright-tests.yml`, `translation-tests.yml`, `docker-publish.yml`) sit under `app/.github/workflows/` and would not run from there. [SRC] |

---

## 4. Decisions required (founder)

1. Canonical GitHub organisation (`AASIOM8` or `Anvora-Global`) and visibility (private recommended).
2. Approve the multi-repository split (A/B/C).
3. Approve pushing the backend history as-is (6 commits, Claude co-authored).
4. Evidence placement (in-repo or separate).
5. Disposition of the 16 uncommitted entries in `~/PROJECTS/VK7SPORTS`.
6. Who has write access (interns only on feature branches, via PR).
