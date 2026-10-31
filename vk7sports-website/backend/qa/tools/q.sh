#!/bin/sh
# Run SQL against the QA database only. Credentials come from .env.docker / environment (F8); never hard-coded.
# Known limitation QA-01 (unchanged): exit status is that of grep, so always check the printed output.
cd "$(dirname "$0")/../.." || exit 1
[ -f .env.docker ] && { set -a; . ./.env.docker; set +a; }
: "${MYSQL_USER:?set MYSQL_USER (see .env.docker.example)}" "${MYSQL_PASSWORD:?set MYSQL_PASSWORD}"
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T -e MYSQL_PWD="$MYSQL_PASSWORD" mysql \
  mysql -u"$MYSQL_USER" "${QA_DB_NAME:-bagisto_qa}" -e "$1" 2>&1 | grep -v "Using a password"
