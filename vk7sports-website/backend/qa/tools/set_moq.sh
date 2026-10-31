#!/bin/sh
# set_moq.sh enabled(0|1) min_qty mode(per_style|per_variant|per_order) admin_orders(0|1)   (QA only)
#   e.g. set_moq.sh 1 24 per_style 1   (golden default)   |   set_moq.sh 0 24 per_style 1   (MOQ off)
cd "$(dirname "$0")/../.."
qa/tools/q.sh "update core_config set value='$1' where code='vk7.moq.settings.enabled';
update core_config set value='$2' where code='vk7.moq.settings.min_qty';
update core_config set value='$3' where code='vk7.moq.settings.mode';
update core_config set value='$4' where code='vk7.moq.settings.apply_to_admin_orders';" >/dev/null
docker compose --env-file .env.docker -f "${QA_COMPOSE_FILE:-docker/compose.qa.yml}" exec -T app php artisan cache:clear >/dev/null 2>&1
qa/tools/q.sh "select code,value from core_config where code like 'vk7.moq.%';"
