#!/bin/sh
# repo_race.sh N LINES [BUYER_EMAIL]
#   Builds ONE order payload from BUYER's cart (default qa.zeta) and fires it from N PHP processes at the same
#   instant straight into OrderRepository::create() - bypasses all HTTP/cart checks (DB-lock + backstop layer).
#   LINES = VARIANT:QTY[,VARIANT:QTY]   e.g. repo_race.sh 4 147:24   |  repo_race.sh 1 150:10 (MOQ backstop)
cd "$(dirname "$0")/../.."
cp qa/tools/repo_race.php app/storage/repo_race.php
rm -f app/storage/race-order.json
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T -e RACE_MODE=build -e RACE_LINES="$2" -e RACE_BUYER="${3:-qa.zeta@example.test}" app php artisan tinker --execute="require 'storage/repo_race.php';" | grep -E "BUILT|Exception|Error"
[ -f app/storage/race-order.json ] || { echo "BUILD FAILED - not firing"; rm -f app/storage/repo_race.php; exit 1; }
AT=$(( $(date +%s) + 12 ))
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T -e RACE_MODE=fire -e RACE_AT=$AT -e N=$1 app sh -c \
  'i=0; while [ $i -lt $N ]; do php artisan tinker --execute="require \"storage/repo_race.php\";" & i=$((i+1)); done; wait' | grep -E "PLACED|REJECTED" | sort
rm -f app/storage/repo_race.php
