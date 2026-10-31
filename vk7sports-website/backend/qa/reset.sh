#!/bin/sh
# Reset the QA environment to the golden baseline (fixtures + scenario stock). QA project only.
set -e
cd "$(dirname "$0")/.."
[ -f .env.docker ] && { set -a; . ./.env.docker; set +a; }
: "${MYSQL_ROOT_PASSWORD:?}" "${MYSQL_USER:?}" "${MYSQL_PASSWORD:?}"
test -f qa/golden.sql.gz || { echo "missing qa/golden.sql.gz"; exit 1; }
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql mysql -uroot -e "DROP DATABASE IF EXISTS bagisto_qa; CREATE DATABASE bagisto_qa; GRANT ALL ON bagisto_qa.* TO '$MYSQL_USER'@'%';" 2>/dev/null
gunzip -c qa/golden.sql.gz | docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T -e MYSQL_PWD="$MYSQL_PASSWORD" mysql mysql -u"$MYSQL_USER" bagisto_qa 2>/dev/null
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T app sh -c 'php artisan optimize:clear >/dev/null; php artisan indexer:index --type=inventory --type=price --mode=full >/dev/null 2>&1; : > storage/logs/laravel.log; rm -f storage/race-order.json'
curl -s -X DELETE ${QA_MAILPIT:-http://127.0.0.1:8125}/api/v1/messages >/dev/null || true
echo "QA reset done:"; qa/tools/q.sh "select (select count(*) from customers) customers, (select count(*) from orders) orders, (select count(*) from b2b_customer_quotes) quotes, (select count(*) from product_ordered_inventories) reservations;"
