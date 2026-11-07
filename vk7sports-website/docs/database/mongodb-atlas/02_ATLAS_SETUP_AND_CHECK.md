# MongoDB Atlas: setup and connection check

MySQL stays the main database. Atlas only receives a copy of each staff activity-log entry (`vk7_activity_log`). If Atlas is down or not configured, the backend keeps working and logs a warning.

## 1. Create the cluster (Atlas web console)

1. Create a project, for example `VK7SPORTS-UAT`.
2. Create a cluster: tier **M0 (free)**, provider AWS, region **Mumbai (ap-south-1)**.
3. **Database Access**: add a user with a password, with the built-in role *Read and write to any database* or, better, a custom role limited to the `vk7sports_uat` database.
4. **Network Access**: add your current IP address. Avoid `0.0.0.0/0`.
5. **Connect → Drivers**: copy the `mongodb+srv://...` string.

## 2. Configure the backend (local only)

In `backend/app/.env` (gitignored, never committed):

```
MONGODB_URI=mongodb+srv://USER:PASSWORD@CLUSTER.mongodb.net/?retryWrites=true&w=majority&appName=vk7sports
MONGODB_DATABASE=vk7sports_uat
MONGODB_TIMEOUT_MS=2000
VK7_ATLAS_MIRROR=true
```

URL-encode special characters in the password (`@` becomes `%40`).

## 3. Rebuild the PHP image and install packages

The image now includes `ext-mongodb 2.5.5` and is tagged `vk7-backend-php84:mongodb`; the old `:baseline` image is untouched.

```bash
docker compose --env-file .env.docker -f docker/compose.dev.yml build app
docker compose --env-file .env.docker -f docker/compose.dev.yml run --rm app composer install --no-interaction
```

## 4. Prove the connection

```bash
docker compose --env-file .env.docker -f docker/compose.dev.yml run --rm app php artisan vk7:atlas-check --report=atlas/check.json
```

It pings Atlas, writes one check document, reads it back, deletes it, and prints the server version, round-trip time and how many activity entries are mirrored. The JSON report (in `storage/app/atlas/check.json`) contains no credentials.

## 5. Switch off

Empty `MONGODB_URI` or set `VK7_ATLAS_MIRROR=false`, then `php artisan optimize:clear`. Nothing else changes.
