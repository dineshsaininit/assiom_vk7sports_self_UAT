# VK7SPORTS frontend

The complete website: public pages, retailer account and staff back office (50 pages). Everything runs on the real backend by default; see `INTEGRATION.md`. In live mode the staff catalogue, quote and staff-user screens open the Bagisto admin panel.

## Run it

Start the backend first (`docs/backend/VK7SPORTS_BACKEND_SETUP.md`), then serve this folder and open http://127.0.0.1:8080:

```bash
php -S 127.0.0.1:8080 -t .
```

For the sample-data demo with no backend, set `apiMode: 'mock'` and `demoMode: true` in `assets/js/config.js`. The sign-ins and walkthrough below apply only to that demo.

## Demo sign-ins

The password for all of these is `Demo@123`. The sign-in pages have one-click buttons.

| Who | Email | Sign in at |
|---|---|---|
| Approved retailer | alpha@example.test | `login.html` |
| Second approved retailer | charlie@example.test | `login.html` |
| Retailer awaiting approval | bravo@example.test | `login.html` |
| Owner (sees everything) | owner@example.test | `admin-login.html` |
| Administrator | admin@example.test | `admin-login.html` |
| Sales | sales@example.test | `admin-login.html` |
| Inventory | inventory@example.test | `admin-login.html` |
| Warehouse | warehouse@example.test | `admin-login.html` |
| Finance | finance@example.test | `admin-login.html` |

Data is saved in the browser. **Reset demo** in the yellow strip restores the sample data.

## Suggested client walkthrough

1. Browse `index.html` and `catalogue.html` as a visitor: no prices are shown.
2. Register a new shop. It shows as awaiting approval.
3. Sign in as Sales and approve the shop under Retailers.
4. Sign in as the shop, open a style and enter quantities. Under 24 pieces is blocked.
5. Check out, then enter a payment reference on the order page.
6. Sign in as Finance and verify the payment. The order becomes Confirmed.
7. Sign in as Warehouse: start packing, dispatch, mark delivered.
8. Sign in as Finance and record the balance. The order becomes Paid in full.
9. Sign in as Owner to see the dashboard, reports and activity log.

## Files

| Path | Purpose |
|---|---|
| `*.html` | One small file per page. All pages share the scripts below. |
| `assets/css/vk7.css` | Design system: navy `#0A1121`, red `#E31B23`, Montserrat and Inter |
| `assets/js/config.js` | Company details, bank details, demo switch |
| `assets/js/seed.js` | Sample products, retailers and staff |
| `assets/js/api.js` | Stand-in backend. **This is the file to replace.** See `INTEGRATION.md`. |
| `assets/js/ui.js` | Header, footer, forms, status badges, size and colour grid |
| `assets/js/pages-*.js` | Page content: public, retailer account, staff |
| `assets/img/products/` | 33 cleaned product photos |

## Before real use

Enter these in `config.js` when VK7SPORTS supplies them. Until then pages show a yellow "To be confirmed" tag: legal name, GSTIN, address, phone, WhatsApp, email, UPI and bank details.

Business values such as the minimum order and advance percentage are on the staff Settings page. They are planning defaults, not owner-approved terms.

Policy pages are drafts and carry a visible draft notice until a legal adviser approves them.

Set `demoMode: false` in `config.js` to remove the demo strip and sign-in shortcuts.
