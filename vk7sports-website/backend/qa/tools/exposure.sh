#!/bin/sh
# exposure.sh LABEL -> probes sensitive paths, headers, error leakage on the sandbox (127.0.0.1 only)
B="${QA_BASE:-http://127.0.0.1:8100}"
echo "### $1"
for p in /.env /.env.example /storage/logs/laravel.log /composer.json /composer.lock /.git/config /artisan /vendor/autoload.php /phpinfo.php /_debugbar/open /telescope /horizon /install /installer /storage/race-order.json /admin /admin/login; do
  printf "%-28s %s\n" "$p" "$(curl -s -o /dev/null -w '%{http_code}' $B$p)"
done
echo "-- response headers on /:"
curl -sI $B/ | grep -iE "^(x-powered-by|server|x-frame-options|x-content-type-options|strict-transport-security|content-security-policy|referrer-policy|set-cookie)" | sed -E 's/(=)[^;]{12,}/\1<value>/'
echo "-- error leakage (forced server error):"
curl -s -H 'Accept: application/json' -H 'X-Requested-With: XMLHttpRequest' "$B/api/checkout/cart" -X POST -H 'Content-Type: application/json' -d '{"product_id":"x","quantity":"y"}' -o /tmp/err.json -w 'POST cart bad payload -> %{http_code}\n'
python3 -c "import json;d=json.load(open('/tmp/err.json'));print('  keys:',list(d)[:6],'| leaks trace:', 'trace' in d or 'file' in d)" 2>/dev/null || head -c 200 /tmp/err.json
curl -s "$B/customer/account/orders/view/999999999" -o /tmp/err.html -w 'GET missing order (guest) -> %{http_code}\n'
curl -s "$B/this-page-does-not-exist-$$" -o /tmp/404.html -w 'GET unknown page -> %{http_code}\n'
grep -c -iE "stack trace|vendor/laravel|Whoops|Symfony\\\\Component|#0 /var/www" /tmp/err.html /tmp/404.html
