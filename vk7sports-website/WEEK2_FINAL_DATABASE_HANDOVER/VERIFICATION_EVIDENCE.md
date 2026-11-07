# Verification evidence

Executed 6 November 2026. Commands below are sanitized equivalents of the actual invocations; paths, SQL and options are retained, but credential values are deliberately absent. Output excerpts are observed results, not predicted acceptance results.

## E1 — Repository/runtime prerequisites

```powershell
$repoRoot = 'C:\Users\pawan kumar singh\assiom_vk7sports_self_UAT'
git -C $repoRoot branch --show-current
git -C $repoRoot rev-parse HEAD
git -C $repoRoot remote -v
git -C $repoRoot status --short --branch
Get-Command docker,php,composer,wsl -ErrorAction SilentlyContinue
```

Observed UAT branch aryan/product-data-handover; starting commit 51ebc5204b0aa8ca33dbb335913a8ed44bdf96f3; approved dineshsaininit/assiom_vk7sports_self_UAT origin; clean tree with upstream. artisan/composer/migration source exists, vendor/autoload.php and local .env/.env.docker absent. PHP/Composer unavailable on PATH.

Docker executable: C:/Users/pawan kumar singh/AppData/Local/Programs/DockerDesktop/resources/bin/docker.exe. Initial conventional Program Files candidate paths did not exist; discovery found this actual executable.

The same read-only Git commands against C:/Users/pawan kumar singh/Documents/VK7SPORTS/vk7sports-integration returned aryan/backend-mysql-integration, 4374f3c5e70a747d1f3e5f276f2284c46a2e803c, AASIOM8/vk7sports-website.git origin, clean initial tree. Its local configuration/dependencies exist. Only safe settings and secret-presence booleans were printed, never .env contents.

## E2 — Docker services and port ownership

```powershell
docker version --format '{{.Client.Version}} / {{if .Server}}{{.Server.Version}}{{end}}'
docker compose ls --format json
docker ps -a --filter label=com.docker.compose.project=vk7-backend-dev --format '{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}'
docker inspect vk7-backend-dev-mysql-1 --format '{{.Name}}|{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}|{{index .Config.Labels "com.docker.compose.project.working_dir"}}'
docker inspect vk7-backend-dev-app-1 --format '{{.Name}}|{{.State.Status}}'
docker image ls --format '{{.Repository}}:{{.Tag}}' --filter reference='*vk7*'
docker ps --filter publish=8000 --format '{{.Names}}|{{.Ports}}|{{.Label "com.docker.compose.project"}}'
wsl --list --quiet
```

Observed:
- Client/server 29.8.1 / 29.8.1.
- vk7-backend-dev has running MySQL and healthy Mailpit; MySQL maps 127.0.0.1:33061 to 3306 and has no configured healthcheck.
- Compose working directory is the Documents integration repository, not UAT.
- App inspection: error: no such object: vk7-backend-dev-app-1.
- Cached image vk7-backend-php84:baseline.
- Port 8000 maps to ai-qa-platform-nginx-1, project ai-qa-platform, host 8000 -> container 80.
- WSL listed docker-desktop.

No compose up/down, image build/pull, volume removal, prune, reset or unrelated container mutation was executed. Temporary --rm offline/read-only PHP check containers were used; a later ancestor-filtered ps returned no remaining PHP helper.

## E3 — MySQL read-only probes

The corrected invocation passed SQL through Python subprocess stdin, avoiding PowerShell/shell quote expansion. An initial SQL shell-quoting attempt failed with unexpected EOF before mysql ran; it did not modify data. This was corrected as follows:

```python
import subprocess, shutil
docker = shutil.which('docker')
command = [docker, 'exec', '-i', 'vk7-backend-dev-mysql-1',
           'sh', '-c',
           'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -u root --batch --raw']
sql = """SET SESSION TRANSACTION READ ONLY;
SELECT VERSION() AS mysql_version, @@port AS container_port;
SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='bagisto';
SELECT COUNT(*) AS bagisto_table_count FROM information_schema.tables WHERE table_schema='bagisto';"""
result = subprocess.run(command, input=sql, text=True, capture_output=True)
```

Root query exit 0; output:

```text
mysql_version  container_port
8.0.46         3306
SCHEMA_NAME
bagisto
bagisto_table_count
0
```

A final repeat returned bagisto_table_count=0 and migration_repository_exists=0, using SELECT COUNT(*) against information_schema.tables with table_name='migrations'.

The configured container application-role probe used the same stdin approach with this internal command:

```sh
MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u "$MYSQL_USER" --batch --raw bagisto
```

SQL: SET SESSION TRANSACTION READ ONLY; SELECT DATABASE() AS database_name, 1 AS configured_application_role_connection_ok;

Exit 0; output database_name=bagisto and configured_application_role_connection_ok=1. No credentials appeared in argv values or output: credential expansion occurred only inside the container. This establishes that configured container role's access, not a completed Laravel connection.

## E4 — PHP runtime and attempted Artisan check

```powershell
docker run --rm --network none --entrypoint php vk7-backend-php84:baseline --version
```

Exit 0: PHP 8.4.26, Zend Engine 4.4.26 with OPcache.

Attempted (runtime app path bound read-only):

```text
docker run --rm --network vk7-backend-dev_default
  --mount type=bind,source=<Documents integration repository>/backend/app,target=/var/www/html,readonly
  --workdir /var/www/html
  --env VK7_CORE_INSTALL=1 --env LOG_CHANNEL=stderr
  --env CACHE_STORE=array --env SESSION_DRIVER=array
  --entrypoint php vk7-backend-php84:baseline artisan --version
```

Python raised subprocess.TimeoutExpired with configured timeout=90. The command yielded no verified Artisan version or migration result. The planned subsequent migrate:status --no-interaction and route:list --path=api/v1 --json invocations were not reached. They are **not executed tests**. No migration command was executed.

Source review located Installer.php lines 118–119 calling db:wipe and migrate:fresh. Those commands and the documented migrate --force were not run.

## E5 — HTTP probes

Python urllib used an explicit ProxyHandler({}) and requests with Accept: application/json, timeout=3 seconds.

```text
GET http://127.0.0.1:8000/api/v1/meta                   -> 404
GET http://127.0.0.1:8000/api/v1/products?include_grid=1 -> 404
GET http://127.0.0.1:8000/api/v1/auth/me                -> 404
```

Each returned Server=nginx, Content-Type=application/json and JSON top-level key error. Port ownership proves these came from ai-qa-platform-nginx-1, not VK7. No response bodies, tokens or private account data are stored. No authenticated request or write endpoint was called.

## E6 — Actual source/data and offline tests

A read-only Python check confirmed:
- schema_table_definitions: 182 (PostgreSQL export);
- products_insert_statements: 0 in base export;
- sample_json_records: 3; all_marked_samples: true;
- B2B requirement: 3.0.1.

Source byte comparison found Product Importer identical between the two repositories; composer.json, composer.lock and Moq.php differ. Both lockfiles list Laravel v13.31.0, B2B v3.0.1 and Pest v5.2.0; this does not establish full lock compatibility.

```powershell
& 'C:\Users\pawan kumar singh\AppData\Local\Programs\Python\Python313\python.exe' -B -m unittest discover -s '<UAT project>/docs/database/product-handover/tests' -v
```

Observed exit 0:

```text
Ran 48 tests in 7.469s
OK
```

Tests use labelled synthetic CSVs and isolated temporary files. They do not contact Docker, the network or a database. Existing real-data templates stay header-only. Laravel Pest/Pint were unavailable in UAT; database-mutating Laravel tests were not run against bagisto. No actual product import or runtime MOQ test was performed.

## E7 — Delivery verification

The seven reports are the only intended project changes for this task. Before the local report commit: check document links/whitespace, credential patterns and known local secret values without printing them; stage only WEEK2_FINAL_DATABASE_HANDOVER; inspect staged scope and git diff --cached --check. The resulting local commit hash and final tree status are reported in the chat, avoiding a self-referential commit hash in these documents. No push, merge, PR or deployment is authorized by this delivery.
