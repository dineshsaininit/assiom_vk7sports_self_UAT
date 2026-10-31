# VK7SPORTS Backend Setup

How to run the backend on a Windows machine without Docker. The database is PostgreSQL 17 (Neon in real use; see [NEON_SETUP.md](../database/NEON_SETUP.md)). The app is in `backend/app`. Linux and Mac are the same apart from the install commands. Docker files also exist in `backend/docker`, but they were not used here.

## Before you start

- **The installer wipes the database named in `.env`.** It checks the name, not the server (defect F1). Check `DB_HOST`, `DB_PORT` and `DB_DATABASE` first, and never point it at a server holding real data.
- The installer **ignores `--env=testing`** and the `DB_DATABASE` environment variable. It reinstalled over the development database when tried. The only safe way to install a second database is to edit `.env`, as shown in the test section.
- Use only fictional data. Never commit `.env` or `.env.testing`.

## 1. Tools

PHP 8.4, Composer 2, PostgreSQL 17 or a Neon database, Node 20 or later.

```bash
winget install --id PHP.PHP.NTS.8.4 -e
```

```bash
winget install --id PostgreSQL.PostgreSQL.17 -e
```

Create a `php.ini` beside `php.exe` from `php.ini-development`. Set `extension_dir = "ext"` and `memory_limit = 2G`, and enable: `curl fileinfo gd intl mbstring openssl pdo_pgsql pgsql exif zip sockets sodium`.

## 2. Code and settings

From `backend/app`:

```bash
composer install --no-scripts
```

```bash
cp .env.example .env
```

In `.env`, set `APP_NAME=VK7SPORTS`, `APP_URL=http://127.0.0.1:8000`, `APP_CURRENCY=INR`, `MAIL_MAILER=log`, `DB_CONNECTION=pgsql`, your `DB_*` values, and `DB_SSLMODE=require` for Neon. Create an empty database, then:

```bash
mkdir -p bootstrap/cache storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs storage/app/public
```

```bash
php artisan key:generate
```

**If the project is inside OneDrive:** OneDrive marks folders read-only and PHP then refuses to start, with "bootstrap/cache directory must be present and writable". Run these in the Windows command prompt or PowerShell. Moving the project out of OneDrive is better, because syncing `vendor` and `node_modules` is slow.

```powershell
attrib -R bootstrap\cache /D; attrib -R storage /D; attrib -R "storage\*" /S /D; attrib -R public /D; attrib -R "public\*" /D
```

## 3. Install, in this order

The B2B Suite reads the database while starting, so a fresh install fails unless it is held back. `VK7_CORE_INSTALL=1` does that. In PowerShell:

```powershell
$env:VK7_CORE_INSTALL='1'; php artisan bagisto:install --no-interaction; Remove-Item Env:\VK7_CORE_INSTALL
```

```bash
php artisan b2b-suite:install --no-interaction
```

```bash
php artisan migrate --force
```

```bash
php artisan vk7:setup --owner-email=you@yourcompany.com --owner-name="Your Name"
```

- `vk7:setup` writes the planning defaults (24 per style, hidden guest prices, company approval, 7-day quotes, 10% advance, 48-hour hold), creates the Sales, Inventory, Warehouse and Finance roles, and sets the owner sign-in. It prints the password once and replaces the installer's public default.
- The store starts empty. Add real products in the admin.
- If you change `core_config` directly, run `php artisan cache:clear`, or the old values stay in use.

## 4. Build the admin and shop assets

These are not in git, and without them the admin panel and checkout crash with "Vite manifest not found".

```bash
cd packages/Webkul/Shop && npm install && npm run build
```

```bash
cd packages/Webkul/Admin && npm install && npm run build
```

## 5. Run

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

API: `http://127.0.0.1:8000/api/v1/meta`. The admin is `admin-login.html` on the website. Bagisto's `/admin` redirects there; to reach it for emergency work, set `VK7_CLOSE_BAGISTO_ADMIN=false`.

Serve the website from the `frontend` folder and open `http://127.0.0.1:8080`:

```bash
php -S 127.0.0.1:8080 -t .
```

CORS currently allows any origin in `config/cors.php`. That is safe for token calls in development. Restrict it to the frontend's address before any deployment.

## 6. Payments and courier

Both are swappable, and both default to a simulation, so nothing here needs an account.

| `.env` setting | Default | Meaning |
|---|---|---|
| `VK7_PAYMENT_GATEWAY` | `demo` | `demo` or `razorpay` |
| `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET` | empty | From the Razorpay dashboard, in test mode |
| `VK7_PAYMENTS_ALLOW_LIVE` | `false` | A `rzp_live_` key is refused unless this is `true`. **Leave it false until Om authorises real payments.** |
| `VK7_COURIER` | `demo` | `demo` or `delhivery` |

The `demo` gateway refuses to run when `APP_ENV=production`, because a simulated result would otherwise count as money.

**To use Razorpay test mode:** set the first three rows, run `php artisan config:clear`, and pay with Razorpay's test cards. Point a webhook at `/api/v1/webhooks/razorpay` for the `payment.captured` event; it needs a public address, so it cannot reach a local machine without a tunnel. Without it, payments still confirm through the browser. This path has only been tested against a faked Razorpay response, never the real service.

**To add a courier:** implement `CourierProvider` (`book` and `track`) in `packages/VK7/Wholesale/src/Couriers`, add it to `Config/vk7.php`, and set `VK7_COURIER`. `DelhiveryCourier` is the empty slot for this: it reports "not connected" until written against a real account. Use `Delivered` as the final scan status so the order moves on. A real courier also needs its scans fetched on a schedule, or from its webhook, through `ShipmentDesk::refresh`.

Terms are in the admin's Settings page. A change applies to new orders only.

## 7. Tests

Tests need their own database. Create `vk7_test`, then copy `.env` to `.env.testing` and change `DB_DATABASE=vk7_test` and `APP_ENV=testing`.

Install into it by pointing `.env` at it temporarily. Run the commands in section 3 up to `migrate`, then **put `.env` back**. Do not run `vk7:setup` here: the tests apply the rules and their own fictional data themselves, and roll both back. Never point the tests at Neon.

```bash
php vendor/bin/pest --testsuite="VK7 Feature Test" --no-coverage
```

Check the code style before committing:

```bash
php vendor/bin/pint packages/VK7
```
