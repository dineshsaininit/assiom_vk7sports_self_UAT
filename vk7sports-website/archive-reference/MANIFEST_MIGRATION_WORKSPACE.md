# ARCHIVE REFERENCE: AASIOM8 MIGRATION WORKSPACE

**Archive Subject:** Organization Migration Staging Clones and Verification Logs  
**Original Location on Mac:**
1. `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/tmp-clones/vk7sports-website/` (Git checkout)
2. `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/projects/vk7sports-website/` (Log files)
3. `/Users/aasiom/AASIOM8-GITHUB-MIGRATION-WORKSPACE/handoff/projects/vk7sports-website/` (Duplicate log files)

---

## Retained Historical Manifest

On 13–14 September 2026, an organization-wide migration pass was executed to migrate repositories to the `AASIOM8` GitHub organization.

### Verification Evidence:
- Cloned upstream repository: `https://github.com/Anvora-Global/vk7sports-website.git`
- Added new remote: `aasiom8` → `https://github.com/AASIOM8/vk7sports-website.git`
- Pushed exact identical tree at commit `7308e0e980a45a0701f0617fa80fa92e2778cdca`
- Generated verification logs:
  - `GIT_STATE_BEFORE.txt` (Snapshot at 2026-09-13T19:11:19+0530)
  - `GIT_STATE_AFTER.txt` (Snapshot at 2026-09-14T02:21:05+0530)
  - `HEAD_VERIFICATION.txt` (Match: YES, SHA `7308e0e`)
  - `REMOTE_STATE.txt` (Both remotes verified)
  - `SECURITY_SCAN.txt` (Pass: 0 secrets found, 6 tracked files)

### Why It Is Not Part of Active Project Code:
- It is a temporary migration staging workspace.
- The repository was successfully verified and pushed to `AASIOM8/vk7sports-website`.
- Retained in place as migration telemetry.
