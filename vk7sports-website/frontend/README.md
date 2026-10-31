# VK7SPORTS frontend

The website, retailer account and the single admin. All data comes from the backend; there is no sample data.

## Run it

Start the backend (`docs/backend/VK7SPORTS_BACKEND_SETUP.md`), then serve this folder and open http://127.0.0.1:8080:

```bash
php -S 127.0.0.1:8080 -t .
```

| Who | Sign in at |
|---|---|
| Retailers | `login.html` |
| Staff | `admin-login.html`. Create the first account with `php artisan vk7:setup`. |

Bagisto's own admin panel is closed and redirects here. Set `VK7_ADMIN_URL` in the backend's `.env` to this site's real address when it moves.

## Files

| Path | Purpose |
|---|---|
| `*.html` | One small file per page. All pages share the scripts below. |
| `assets/css/vk7.css` | Design system: navy `#0A1121`, red `#E31B23`, Montserrat and Inter |
| `assets/js/config.js` | The backend's address |
| `assets/js/api.js` | Every call to the backend |
| `assets/js/ui.js` | Header, footer, forms, status badges, size and colour grid, tracking map, invoice |
| `assets/js/pages-*.js` | Page content: public, retailer account, admin |
| `assets/img/products/` | Supplied photos. The home, about and customised pages use a few of them. Catalogue photos are uploaded in the admin. |

Company and bank details are entered in the admin's Settings page, not in code.

## Good to know

- Online payment and the courier are simulated until keys are added. See section 6 of the backend setup guide.
- The tracking map loads Leaflet from cdnjs and OpenStreetMap tiles, so it needs internet. Heavy production use of the public tile server is not allowed: choose a tile provider before going live.
- Shop staff logins and customised-order artwork approval are not built. Notifications are empty.
