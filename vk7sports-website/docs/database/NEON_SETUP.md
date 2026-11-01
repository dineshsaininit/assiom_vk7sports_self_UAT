# VK7SPORTS on Neon

The whole system runs on PostgreSQL 17. These files create an empty, working database with no products, retailers, orders or staff.

| File | What it is |
|---|---|
| `vk7sports_schema.sql` | All 182 tables, indexes and foreign keys |
| `vk7sports_base_data.sql` | The base records the system needs to start: currency, locale, channel, product attributes, staff roles, default rules. No customers, products, orders or passwords. |

Both load cleanly into an empty database on PostgreSQL 17.5 and on Neon's PostgreSQL 18.6. On a slow connection the load can take about 8 minutes.

## 1. Create the database

1. Create a Neon project with **PostgreSQL 17**, in the region nearest your customers.
2. Copy the connection details. Use the **direct** connection, whose host does **not** contain `-pooler`.

The password in that string is a secret. Never commit it.

## 2. Load the files

Run both from `docs/database`, schema first. Use `psql`, not the Neon SQL editor: one load left only 15 of the 182 tables in place, with no working data. Afterwards, check that the database has 182 tables in `public`.

```bash
psql "postgresql://USER:PASSWORD@HOST/neondb?sslmode=require" -v ON_ERROR_STOP=1 -f vk7sports_schema.sql
```

```bash
psql "postgresql://USER:PASSWORD@HOST/neondb?sslmode=require" -v ON_ERROR_STOP=1 -f vk7sports_base_data.sql
```

## 3. Point the backend at Neon

In `backend/app/.env`:

```
DB_CONNECTION=pgsql
DB_HOST=your-endpoint.neon.tech
DB_PORT=5432
DB_DATABASE=neondb
DB_USERNAME=your-user
DB_PASSWORD=your-password
DB_SSLMODE=require
```

Then run:

```bash
php artisan config:clear
```

```bash
php artisan migrate --force
```

This should report "Nothing to migrate".

## 4. Create the owner sign-in

```bash
php artisan vk7:setup --owner-email=you@yourcompany.com --owner-name="Your Name"
```

It prints a password **once**. Save it, then sign in at `admin-login.html`.

## 5. First things to do in the admin

1. **Settings:** enter the company name, address, GSTIN, phone, and bank and UPI details. These appear on invoices and the website.
2. **Products:** add each style, with its colours, sizes, price and opening stock, then upload photos for each colour.
3. **Staff and roles:** add staff. Roles are Sales, Inventory, Warehouse and Finance.

## Good to know

- **Photos are not in the database.** Uploads are saved on the server in `storage/app/public`. Back that folder up as well, and keep it when moving servers.
- **Later code changes** reach Neon through `php artisan migrate --force`. The SQL files are for the first setup only.
- **Host the backend in the same region as the database.** Each query travels to the database and back, so distance adds up fast. From India to a Neon database in `us-east-2`, each API call took 10 to 16 seconds with `CACHE_STORE=file` and `SESSION_DRIVER=file`, and 25 to 55 seconds without them.
- **Do not set `PDO::ATTR_EMULATE_PREPARES`.** It breaks true/false comparisons on PostgreSQL.
- **Neon may pause when idle.** The first request after a pause can take a few seconds.
- **Automated tests must never point at Neon.** They use a separate database, set in `.env.testing`.
- **`vk7:demo-data` only runs in the test environment.** It refuses to add fictional products anywhere else.

## Tables VK7 added

| Table | Holds |
|---|---|
| `vk7_order_terms` | Each order's stage, advance, stock hold and invoice number |
| `vk7_payments` | Every advance and balance payment, online or by reference |
| `vk7_shipments`, `vk7_shipment_events` | Courier bookings and tracking scans |
| `vk7_enquiries` | Bulk, customised and contact enquiries |
| `vk7_stock_log` | Stock corrections and their reasons |
| `vk7_activity_log` | Who changed what |
| `vk7_sequences` | Locked counters for order, quote and invoice numbers |

All other tables belong to Bagisto and the B2B Suite. Companies are in `customers`, products in `products` and `product_flat`, stock in `product_inventories`, orders in `orders`, and quotes in `b2b_customer_quotes`.
