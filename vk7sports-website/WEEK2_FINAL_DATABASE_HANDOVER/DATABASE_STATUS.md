# VK7SPORTS database status

Verified 6 November 2026. **Database reachable; schema not initialized; no products imported; VK7 HTTP integration not operational.**

## Repositories and ownership

| Item | Actual result |
|---|---|
| Authorized UAT clone | C:/Users/pawan kumar singh/assiom_vk7sports_self_UAT |
| Project subdirectory | vk7sports-website |
| Branch / starting commit | aryan/product-data-handover / 51ebc5204b0aa8ca33dbb335913a8ed44bdf96f3 |
| Origin | https://github.com/dineshsaininit/assiom_vk7sports_self_UAT |
| Initial working tree | Clean; upstream origin/aryan/product-data-handover now configured. No push was attempted during this task. |
| Classification | Full-stack source, including Laravel/Bagisto backend and custom VK7 wholesale package, not frontend-only. |
| Actual Docker project source | C:/Users/pawan kumar singh/Documents/VK7SPORTS/vk7sports-integration |
| Docker runtime repository | https://github.com/AASIOM8/vk7sports-website.git |
| Runtime branch / commit | aryan/backend-mysql-integration / 4374f3c5e70a747d1f3e5f276f2284c46a2e803c; initially clean. |
| Compatibility | Composer JSON/lock and Moq.php differ between repositories. Product Importer matches. Do not combine their vendor/configuration without dependency/source reconciliation. |

## Actual running local database

| Check | Result |
|---|---|
| Docker engine/client | 29.8.1 / 29.8.1 |
| Compose project | vk7-backend-dev |
| MySQL container | vk7-backend-dev-mysql-1, running, no healthcheck configured |
| Engine version | MySQL 8.0.46, verified by SELECT VERSION() |
| Database / port | bagisto; host 127.0.0.1:33061 -> container 3306 |
| Table count before / after | 0 / 0, verified via information_schema.tables |
| migrations repository table | Absent, count 0 |
| Root read-only SQL | PASS |
| Configured container application-role SQL | PASS: DATABASE()=bagisto and connection probe=1 |
| Laravel DB connectivity | NOT VERIFIED: UAT vendor/config missing; separate runtime Artisan version attempt timed out before migration status. |
| Other named-project services | Mailpit running and healthy. No vk7-backend-dev-app-1 container exists. |
| Host port 8000 | Owned by unrelated ai-qa-platform-nginx-1. Not modified. |

Container credentials were used only inside the existing MySQL container, never displayed or committed. The application-role probe uses MYSQL_USER/MYSQL_PASSWORD configured in that container; it is not proof that the Laravel .env role/password match.

## Runtime prerequisites

UAT contains artisan, composer.json/lock, 213 source migration files, Bagisto and VK7 source, and a B2B Suite 3.0.1 dependency declaration. Its vendor/autoload.php, backend/app/.env, backend/app/.env.testing and backend/.env.docker are absent. Host PHP and Composer are unavailable on PATH.

The separate Docker source has vendor/autoload.php, vendor/bagisto/b2b-suite, .env and .env.docker. Its sanitized application settings are APP_ENV=local, DB_CONNECTION=mysql, DB_HOST=mysql, DB_PORT=3306, DB_DATABASE=bagisto, with a nonempty password and APP_KEY. Values were not copied to UAT. Both locks declare Laravel v13.31.0 and B2B v3.0.1, but the complete manifests/locks are not identical.

A cached vk7-backend-php84:baseline image successfully reports PHP 8.4.26. A read-only temporary Artisan version check using the Docker-source tree timed out; no persistent helper container remains.

The UAT SQL bootstrap exports target PostgreSQL, not this MySQL instance. Do not restore those files into MySQL or treat the historical 182-table export count as a guaranteed MySQL target count.
