# Connecting the backend

Every screen gets its data through `VK7.api` in `assets/js/api.js`. No page reads data any other way. To connect the backend, replace the method bodies with `fetch()` calls and keep the same return shapes. The screens should not need changes.

## The contract

- Every method returns a Promise.
- On failure, throw `new VK7.ApiError(message, { code, status, fields })`.
  - `fields` is `{ fieldName: 'message' }`. Forms show each message beside its field.
  - `status: 401` sends the user to sign-in. `status: 404` shows a "not found" screen.
- Every `fetch` must send the session cookie and CSRF token (`credentials: 'include'`).

## Rules the server must enforce

`api.js` imitates these so the demo behaves correctly, but browser code can be edited by anyone. Each one must be enforced on the server:

1. **Price hiding (D-06, test T-2).** Visitors and unapproved retailers must never receive a price in any response. Bagisto's shop feeds such as `GET /api/products` send prices to anyone today, and hiding them on screen would still leak them.
2. **Retailer isolation.** A retailer can only read or change their own orders, quotes and statement.
3. **Minimum order, stock and price.** Recalculate these on the server. Never trust amounts, prices or totals sent by the browser.
4. **Roles.** Staff permissions must match `PERMS` in `api.js`.
5. **One submission only.** Quote and order creation must be safe against double clicks and retries.

## Method map

Routes marked **Verified** were read from `backend/app/packages/Webkul/Shop/src/Routes/`. Routes marked **Doc** come from the handover docs, because B2B Suite is a Composer package that is not in this repo. Check them against your running install. **New** means nothing exists yet and an endpoint must be built.

| `VK7.api` method | Screen | Backend | Status |
|---|---|---|---|
| `auth.login` | Sign-in | `POST /api/customer/login` | Verified |
| `auth.me` | Every page | Current customer plus cart count | New |
| `auth.logout`, `auth.forgot` | Account, reset password | Bagisto customer routes | Check |
| `auth.register` | Trade application | B2B Suite company sign-up | Doc |
| `auth.staffLogin` | Staff sign-in | Bagisto admin login, with 2FA | See note 1 |
| `catalog.categories` | Home, filters | `GET /api/categories` | Verified |
| `catalog.list`, `catalog.get` | Catalogue, product | `GET /api/products` | Verified, prices must be hidden |
| `catalog.facets` | Filters | `GET /api/categories/attributes` | Verified |
| `catalog.skus` | Quick order | B2B quick order | Doc |
| `cart.get` | Order list | `GET /api/checkout/cart` | Verified |
| `cart.setStyle`, `cart.addMany` | Size and colour grid | `POST /api/checkout/cart` | **New**: must add many variants at once with MOQ intact (test T-3) |
| `cart.setLine`, `cart.removeStyle`, `cart.clear` | Order list | `PUT` and `DELETE /api/checkout/cart` | Verified |
| `checkout.prepare` | Checkout | `GET /api/checkout/onepage/summary` | Verified |
| `checkout.place` | Checkout | `POST /api/checkout/onepage/addresses`, `.../shipping-methods`, `.../payment-methods`, `.../orders` | Verified |
| `quotes.request` | Order list | `POST /customer/account/quotes` | Doc |
| `quotes.list`, `get`, `accept`, `decline`, `message` | Quotes | B2B quote routes | Doc |
| `orders.list`, `orders.get` | My orders | Customer order routes | Check |
| `orders.reorder`, `orders.cancel` | Order page | Bagisto order routes | Check |
| `orders.submitPayment` | Order page | Payment reference | **New** |
| `orders.artwork` | Customised orders | Artwork approval | **New**: fix F7 first |
| `orders.track` | Track an order | Public lookup by number and mobile | **New** |
| `enquiries.create`, `mine`, `contact` | Enquiry forms | Enquiry queue | **New** |
| `account.get`, `update`, `password` | Shop profile | Customer profile routes | Check |
| `account.saveAddress`, `deleteAddress`, `defaultAddress` | Addresses | `/api/customer/addresses` | Verified |
| `account.addUser`, `removeUser` | Shop logins | B2B company users | Doc |
| `account.statement`, `account.overview` | Statement, overview | Retailer ledger | **New** |
| `notifications.*` | Notifications | Notification list | **New** |
| `settings` | Public terms | Public subset of settings | **New**; `vk7.moq.settings.*` exists |

### Staff screens: `api.admin.*`

| Methods | Screens | Status |
|---|---|---|
| `retailers`, `retailer`, `decideRetailer` | Retailers | Approval exists in B2B Suite; JSON endpoints needed |
| `quotes`, `quote`, `sendOffer` | Quotes | Quote logic exists; JSON endpoints needed |
| `orders`, `order`, `setOrderStatus`, `holdOrder`, `resumeOrder`, `cancelOrder` | Orders | Orders exist; VK7 statuses (R-26) are **new** |
| `authoriseProduction`, `sendArtwork` | Customised orders | **New** |
| `payments`, `verifyPayment`, `recordBalance` | Payments | **New** (Payments and Ledger module) |
| `dispatch`, `shipOrder` | Dispatch | Shipments exist; courier and LR record is **new** |
| `products`, `product`, `saveProduct` | Products | Products exist; JSON endpoints needed |
| `inventory`, `adjustStock`, `stockLog` | Inventory | Stock exists; correction log with reasons is **new** |
| `enquiries`, `updateEnquiry` | Enquiries | **New** |
| `staff`, `saveStaff`, `toggleStaff` | Staff and roles | Admin users exist; JSON endpoints needed |
| `allSettings`, `saveSettings` | Settings | Only MOQ settings exist; the others are **new** |
| `audit` | Activity log | **New** |
| `dashboard`, `counts`, `reports` | Dashboard, reports | **New** |

**Note 1, staff screens.** The project documents treat Bagisto's admin as the staff back office, with VK7 work queues added. So you have a choice for each staff screen: build the JSON endpoints above, or keep the Bagisto admin screen and link to it. The owner dashboard, payments, dispatch and activity log have no Bagisto equivalent either way.

## Moving to a Bagisto theme

FE-1, a VK7 theme inside Bagisto, is the project's preferred architecture, and that decision is not final. The CSS file carries over unchanged. The page code is plain HTML templates, so it can be moved into Blade one page at a time.

## Replace before going live

- Sample products, prices and stock in `seed.js`. Style names and codes are placeholders.
- Passwords in `api.js` and `seed.js` are demo values and are kept as plain text. Nothing like this may reach the server.
- Bank and company details in `config.js`.
