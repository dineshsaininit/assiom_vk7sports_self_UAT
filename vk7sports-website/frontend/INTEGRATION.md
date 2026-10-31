# Connecting the backend

The retailer pages are connected. `assets/js/api-live.js` replaces the demo methods in `api.js` with calls to `/api/v1` and returns the same shapes, so the screens did not need rewriting. The API itself is described in `docs/backend/VK7SPORTS_API_CONTRACT.md`.

## Switching mode

In `assets/js/config.js`:

| Setting | Live (default) | Demo |
|---|---|---|
| `apiMode` | `'live'` | `'mock'` |
| `demoMode` | `false` | `true` |
| `apiBase`, `adminUrl` | Backend address | Not used |

Run the backend and serve this folder (see `README.md`). Change `apiBase` and `adminUrl` when the backend moves. Demo mode is unchanged, for walkthroughs without a backend.

## The contract the pages rely on

- Every method returns a Promise.
- Failures throw `new VK7.ApiError(message, { code, status, fields })`. `fields` is `{ fieldName: 'message' }`, shown beside each field. `status: 401` sends the user to sign-in; `status: 404` shows "not found".
- Sign-in uses a bearer token kept in the browser, not a session cookie. No CSRF token is needed.
- The browser never decides a price, stock or minimum. The server enforces them.

## What is live and what is not

| Area | State in live mode |
|---|---|
| Catalogue, cart, quotes, checkout, orders, addresses, enquiries | Live |
| Advance and balance payment, statement | Live, on the simulated gateway until Razorpay test keys are added |
| Courier tracking and map | Live, on the simulated courier |
| Staff dashboard, clients, orders, payments, dispatch, business overview, activity log | Live through `/api/v1/admin/*` |
| Staff enquiries, quotes, products, inventory, staff users, settings | Open the Bagisto admin panel, listed in `BAGISTO_SCREENS` in `api-live.js` |
| Staff notifications, retailer notifications | Empty: no backend yet |
| Shop logins, customised-order artwork | Not available yet: "contact sales" |

The map uses Leaflet from cdnjs and OpenStreetMap tiles, so it needs internet. Without it the scans still show. Heavy production use of the public OpenStreetMap tile server is not allowed: choose a tile provider before going live.
