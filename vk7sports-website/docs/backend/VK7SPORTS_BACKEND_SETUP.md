# VK7SPORTS Backend Setup

How to run the backend on a Windows machine without Docker, as used on 31 October 2026. The app is in `backend/app`. Linux and Mac are the same apart from the install commands. Docker files also exist in `backend/docker`, but they were not used here.

## Before you start

- **The installer wipes the database named in `.env`.** It checks the name, not the server (defect F1). Check `DB_HOST`, `DB_PORT` and `DB_DATABASE` first, and never point it at a server holding real data.
- The installer **ignores `--env=testing`** and the `DB_DATABASE` environment variable. It reinstalled over the development database when tried. The only safe way to install a second database is to edit `.env`, as shown in the test section.
- Use only fictional data. Never commit `.env` or `.env.testing`.

## 1. Tools

PHP 8.4, Composer 2, MySQL 8, Node 20 or later.

```bash
winget install --id PHP.PHP.NTS.8.4 -e
```

```bash
winget install --id Oracle.MySQL -e
```

Create a `php.ini` beside `php.exe` from `php.ini-development`. Set `extension_dir = "ext"` and `memory_limit = 2G`, and enable: `curl fileinfo gd intl mbstring openssl pdo_mysql exif zip sockets sodium`.

Winget installs MySQL 8.4. The project pins 8.0.46, so results on 8.4 are not the pinned configuration.

## 2. Code and settings

From `backend/app`:

```bash
composer install --no-scripts
```

```bash
cp .env.example .env
```

In `.env`, set `APP_NAME=VK7SPORTS`, `APP_URL=http://127.0.0.1:8000`, `APP_CURRENCY=INR`, `MAIL_MAILER=log`, and your `DB_*` values. Create an empty database, then:

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
php artisan vk7:apply-policy
```

```bash
php artisan vk7:demo-data
```

- `vk7:apply-policy` writes the planning defaults (24 per style, hidden guest prices, company approval, 7-day quotes, offline payment). **Without it the minimum is off**, and the rest of the rules fall back to their defaults.
- `vk7:apply-policy` clears the cache, because settings are cached. If you change `core_config` directly, run `php artisan cache:clear`, or the old values stay in use.
- `vk7:demo-data` creates 4 fictional categories and styles with 32 variants. It refuses to run in production.

**Change the admin password straight away.** The installer creates `admin@example.com` with an upstream default password.

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

API: `http://127.0.0.1:8000/api/v1/meta`. Admin: `http://127.0.0.1:8000/admin`.

Serve the website from the `frontend` folder and open `http://127.0.0.1:8080`:

```bash
php -S 127.0.0.1:8080 -t .
```

To approve a retailer, activate the company in the B2B Companies screen in admin. To send an offer, use the B2B quote screens. Their routes are covered by automated tests; the screens have not been clicked through in a browser yet.

CORS currently allows any origin in `config/cors.php`. That is safe for token calls in development. Restrict it to the frontend's address before any deployment.

## 6. Tests

Tests need their own database. Create `vk7_test`, then copy `.env` to `.env.testing` and change `DB_DATABASE=vk7_test` and `APP_ENV=testing`.

Install into it by pointing `.env` at it temporarily. Run the commands in section 3 up to `migrate`, then **put `.env` back**. Do not run `vk7:apply-policy` or `vk7:demo-data` here: the tests run both themselves and roll them back.

```bash
php vendor/bin/pest --testsuite="VK7 Feature Test" --no-coverage
```

Check the code style before committing:

```bash
php vendor/bin/pint packages/VK7
```
