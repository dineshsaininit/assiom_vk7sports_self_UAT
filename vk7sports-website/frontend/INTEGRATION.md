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

| `VK7.api` area | State in live mode |
|---|---|
| `auth` (register, login, logout, me, forgot) | Live. Registration creates a pending shop; it can sign in after staff approve it |
| `catalog` | Live. Colour, size, stock and sort filters run in the browser on the fetched list |
| `cart`, `quotes` | Live. Lines from an accepted quote are locked |
| `checkout` | Live, offline only. No money is collected. The cheapest delivery method is chosen, because courier charges are not confirmed |
| `orders` list, get, cancel, reorder, track | Live |
| `enquiries` | Live |
| `account` get, update, password, addresses | Live |
| `orders.submitPayment`, `orders.artwork`, `account.addUser`, `removeUser` | **Not available.** They show "not available online yet" |
| `account.statement` | Empty. There is no ledger yet |
| `notifications` | Empty. There are no retailer notifications yet |
| `api.admin.*` (all staff screens) | **Not connected.** `admin*.html` pages redirect to the Bagisto admin panel at `adminUrl` |

## Differences from the demo to know about

- **Payment:** checkout and order pages say VK7SPORTS will confirm payment terms. Advance amounts, hold times and the pay form appear only in demo mode, because those rules are not approved.
- **Marketing pages** (home, how it works, FAQ, customised orders) still mention the planning-default advance percentage from `api.settings` in `api-live.js`. Change the wording or those values once the owner confirms the terms.
- **Order status:** live orders show Order placed, Packing, Dispatched, Delivered or Cancelled, mapped from Bagisto. The planned status list (R-26) is not built.
- **Images:** products without photos show the VK7 mark. Colour swatches are grey until swatch colours are set on the attribute options in admin.
- **Shop type and business proof** from the application form are saved as an entry in the admin Enquiries queue, because Bagisto has no fields for them. GSTIN is also saved on the address.
- **Address label** is stored in the address company-name field.

## Staff screens still to decide

The project documents treat Bagisto's admin as the staff back office. The `admin*.html` pages remain as a design reference. For each one, either build JSON endpoints or keep the Bagisto screen. The owner dashboard, payments, dispatch record and activity log have no Bagisto equivalent either way, so those need new backend work.

## Replace before going live

- `apiBase` and `adminUrl` in `config.js`, and restrict CORS on the backend to the site's address.
- Bank and company details in `config.js`.
- Fictional products. `seed.js` and the passwords in `api.js` are demo-only and are not used in live mode; do not serve them in production if demo mode is removed.
