#!/bin/sh
# stock.sh show | stock.sh set VARIANT_ID QTY   (QA only; re-indexes after set)
cd "$(dirname "$0")/../.."
if [ "$1" = set ]; then
  qa/tools/q.sh "update product_inventories set qty=$3 where product_id=$2 and inventory_source_id=1;" >/dev/null
  docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T app php artisan indexer:index --type=inventory --mode=full >/dev/null 2>&1
fi
qa/tools/q.sh "select p.id variant, p.sku, i.qty physical, coalesce(o.qty,0) reserved, i.qty-coalesce(o.qty,0) sellable
  from products p join product_inventories i on i.product_id=p.id and i.inventory_source_id=1
  left join product_ordered_inventories o on o.product_id=p.id and o.channel_id=1 where p.parent_id=144 order by p.id;"
