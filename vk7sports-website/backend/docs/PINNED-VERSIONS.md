# Pinned build inputs (F6, approved 2026-10-21)

Resolved 2026-10-21 from Docker Hub and GitHub. "Fidelity" = confidence that this matches what ran on 15 Oct 2026.

| Input | Pin | Source of truth | Fidelity |
|---|---|---|---|
| PHP base image | `php:8.4.26-cli@sha256:1d2cf2b7d715b5b3aa959f0150ccbcc7b71e0181b637e443abf40a7fb56bf79a` (arm64 manifest `sha256:3cbf9ac1…bde5d4`) | Docker Hub; 8.4.26 pushed 2026-10-07 = newest 8.4 patch at build time | **Inferred.** Confirm with `php -v` in cached image `bagisto-eval-php84` when Docker access is approved (F2) |
| PHP extension installer | release `2.12.0`, SHA-256 `dc76dd16cb7b66da01b07ae9aa9a2c76278836284f8ba034757a7fc207c53269` (verified in Dockerfile) | GitHub releases: 2.12.0 (2026-09-24) current at build time; 2.12.1 published 2026-10-15 10:24 UTC, after the build | High |
| Composer | `2.10.3` via `@composer-2.10.3` | GitHub releases: newest 2.x at build time (2026-08-27) | Inferred |
| PHP extensions | bcmath calendar exif gd intl pdo_mysql zip sockets pcntl | Bundled with PHP; versions follow the PHP pin | High |
| MySQL | `mysql:8.0.46@sha256:7dcddc01f13bab2f15cde676d44d01f61fc9f99fe7785e86196dfc07d358ae2b` (arm64 `sha256:213bbfaf…2458e`) | Server version in `qa/golden.sql.gz` header | High |
| Mailpit | `axllent/mailpit:v1.31.5@sha256:94f6b70c1436defae6799d9ac7ff0eeff9540465b842026d5cdb018f1c0234ea` | v1.31.5 (2026-10-11) current at build; v1.31.6 published 2026-10-15 05:02 UTC | High |
| PHP packages | `app/composer.lock` (Bagisto 2.5.0, Laravel v13.31.0, bagisto/b2b-suite v3.0.1 ref `a2b178e`) | Lockfile, unchanged | Exact |

Multi-arch index digests are pinned, so Intel and Apple Silicon hosts both resolve to the same release.
Re-pinning is a deliberate change: update this table and re-run the reproduction.
