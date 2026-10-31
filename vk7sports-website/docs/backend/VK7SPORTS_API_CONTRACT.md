# VK7SPORTS API Contract v1

For the frontend (Dinesh). The site already calls this through `frontend/assets/js/api-live.js`. Base URL in development: `http://127.0.0.1:8000/api/v1`. Setup is in [VK7SPORTS_BACKEND_SETUP.md](VK7SPORTS_BACKEND_SETUP.md).

All data in development is fictional. Business rules are planning defaults, not owner-confirmed (see [VK7SPORTS_BACKEND_REQUIREMENTS.md](VK7SPORTS_BACKEND_REQUIREMENTS.md)). Read rules such as the minimum from `GET /meta` and show the server's messages. Do not hard-code them, because they will change.

## Rules for every call

- Send and receive JSON. Sign in with `POST /auth/login`, then send `Authorization: Bearer <token>`. No cookies or CSRF token are needed. Tokens last 30 days.
- The server decides prices, stock and the minimum. Never send a price, and never trust one calculated in the browser.
- Errors look like this. Branch on `code`, and display `message`:

```json
{ "message": "This account is waiting for approval.", "code": "ACCOUNT_PENDING" }
```

Validation errors return 422 with `{ "message": "...", "errors": { "field": ["..."] } }`.

| Status | Meaning | What the UI should do |
|---|---|---|
| 401 | No token, or an expired or revoked one | Send to login |
| 403 | Account pending or suspended | Show the message |
| 404 | Not found, **or belongs to another retailer** | Show "not found" |
| 409 | The same order is already being placed | Wait, then reload the orders list |
| 422 | Rule or validation failure | Show the message on the form |
| 429 | Too many requests (240 a minute, login 20, forms 10) | Ask them to retry shortly |

## Pages and the endpoints behind them

| Page | Endpoints |
|---|---|
| Home, navigation | `GET /meta`, `GET /categories`, `GET /products?limit=8` |
| Catalogue, search, filters | `GET /products`, `GET /categories` |
| Product detail, size × colour grid | `GET /products/{id or url_key}`, `POST /moq/check`, `POST /cart/items` |
| Register | `POST /auth/register` |
| Login, logout | `POST /auth/login`, `POST /auth/logout` |
| Account | `GET /auth/me` |
| Cart | `GET /cart`, `PUT` and `DELETE /cart/items/{id}` |
| Request a quote | `POST /quotes` |
| Quote list and detail | `GET /quotes`, `GET /quotes/{id}`, then `/counter`, `/messages`, `/accept`, `/reject` |
| Checkout | `POST /checkout/address`, `/shipping`, `/payment`, `/order` |
| Orders and tracking | `GET /orders`, `GET /orders/{id}` |
| Enquiry / contact / custom order | `POST /enquiries` |
| Forgot password | `POST /auth/forgot` |
| Profile, password, addresses | `GET` and `PUT /account`, `PUT /account/password`, `/account/addresses` |
| Public order tracking | `POST /orders/track` |
| My enquiries | `GET /enquiries/mine` |
| Pay advance or balance | `POST /orders/{id}/payments`, `/payments/{paymentId}/confirm`, `/payments/reference` |
| Account statement | `GET /account/statement` |
| Single staff admin | `/admin/*`, see [Staff business desk](#staff-business-desk). Bagisto's panel is closed. |

About, policy and other static pages need no backend. Their wording awaits the owner.

## Public endpoints

A token is optional here. With a valid token, the response includes that retailer's prices and stock counts.

### `GET /meta`

```json
{ "data": {
  "company": { "legalName": "...", "address": "...", "gstin": "...", "phone": "...", "email": "..." },
  "bank": null,
  "payments": { "advance_percent": 10, "hold_hours": 48, "gateway": "demo" },
  "moq": { "enabled": true, "min_qty": 24, "mode": "per_style" },
  "prices_visible": false,
  "currency": "INR",
  "enquiry_types": ["general", "bulk", "custom", "school_club_team", "dealer"]
} }
```

### `GET /categories`

Returns `data: [{ id, name, slug, children: [...] }]`.

### `GET /products`

Query parameters, all optional: `q` (search), `category_id`, `color` and `size` (option ids), `sort`, `limit` (1-100, default 12), `page`, `include_grid=1` (adds each product's `grid`).

```json
{ "data": [{
    "id": 10, "sku": "TEST-STYLE-02", "name": "TEST Track Pant", "url_key": "test-style-02",
    "type": "configurable", "short_description": "...", "base_image": null,
    "in_stock": true, "prices": null
  }],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 12, "total": 4 } }
```

`prices` is `null` for visitors, so show "Sign in for trade prices". `base_image` can be `null`, so you need a placeholder.

### `GET /products/{id or url_key}`

The same fields, plus `description`, `images` and `grid`. Build the grid from `attributes`, and find each cell's variant through its `options`. A size and colour pair with no variant has no cell. `grid` is `null` for a product without variants.

```json
{ "data": { "id": 10, "name": "TEST Track Pant", "images": [], "prices": { "...": "..." },
  "grid": {
    "attributes": [
      { "code": "color", "label": "Color", "options": [{ "id": 1, "label": "Red" }] },
      { "code": "size", "label": "Size", "options": [{ "id": 6, "label": "S" }] }
    ],
    "variants": [{
      "id": 11, "sku": "TEST-STYLE-02-variant-1-6",
      "options": { "color": 1, "size": 6 },
      "in_stock": true,
      "stock": 50,
      "prices": { "regular": { "price": "700.0000", "formatted_price": "₹700.00" },
                  "final":   { "price": "700.0000", "formatted_price": "₹700.00" } }
    }]
  } } }
```

For visitors, `stock` and `prices` are `null`, and only `in_stock` is sent.

### `POST /auth/register`

Required: `business_name`, `first_name`, `last_name`, `email`, `phone`, `password`, `password_confirmation`. Optional: `shop_type`, `gstin`, `proof`, and an address (`label`, `line1`, `city`, `state`, `pin`). Returns 201 with `{ "data": { "email": "...", "approval": "pending" } }`. Show "waiting for approval". The retailer cannot sign in until staff approve the client in the admin.

### `POST /auth/login`

Send `{ email, password }`. Returns:

```json
{ "token": "1|...", "token_type": "Bearer", "expires_in_days": 30,
  "data": { "id": 1, "first_name": "Test", "last_name": "Smoke", "email": "...", "phone": "...",
            "type": "company", "company": { "id": 1, "business_name": "TEST-SMOKE Traders" } } }
```

Error codes: `INVALID_CREDENTIALS` (401), `ACCOUNT_PENDING`, `EMAIL_NOT_VERIFIED`, `ACCOUNT_SUSPENDED` (403), `TOO_MANY_ATTEMPTS` (429).

### `POST /enquiries`

Required: `name`, `email`, `message`. Optional: `type` (from `enquiry_types`), `business_name`, `phone`, `city`, `quantity`, `product_id`. Returns 201. Sales sees it under Enquiries in the admin. Custom orders use this form with `type: "custom"`. There is no custom-order workflow yet.

## Retailer endpoints (token required)

`POST /auth/logout` revokes the token. `GET /auth/me` returns the same `data` as login.

### `POST /moq/check`

Run this when the grid changes. It saves nothing.

```json
{ "lines": [{ "product_id": 10, "variant_id": 11, "qty": 6 }] }
```

```json
{ "data": {
  "moq": { "enabled": true, "min_qty": 24, "mode": "per_style", "met": false,
           "shortfalls": [{ "label": "TEST Track Pant", "qty": 20, "needed": 4 }] },
  "stock_ok": false,
  "shortages": [{ "product_id": 10, "variant_id": 11, "sku": "...", "requested": 60, "available": 50 }]
} }
```

### Account

- `GET /account` returns the profile and `addresses`. `PUT /account` updates `{ first_name, last_name, phone }`.
- `PUT /account/password` takes `{ current_password, password, password_confirmation }` and signs out other devices.
- `POST /account/addresses` and `PUT /account/addresses/{id}` take `{ label, line1, city, state, pin, phone }`. `state` is an Indian state name or code. `DELETE /account/addresses/{id}` keeps at least one (`LAST_ADDRESS`). `POST /account/addresses/{id}/default` sets the default.
- `POST /auth/forgot` (public) takes `{ email }` and answers the same for any address.

### Cart

- `GET /cart` returns the cart, or `data: null` when it is empty.
- `POST /cart/items` takes the same `lines` body and **adds** to what is there, all lines or none. Errors: `INVALID_LINE`, `CART_REJECTED`.
- `PUT /cart/styles/{productId}` replaces all of a style's lines with `{ lines: [{ variant_id, qty }] }`, all or none. An empty list removes the style. `QUOTE_LOCKED` for a locked style.
- `PUT /cart/items/{id}` sets `{ qty }`. A line from an accepted quote returns `QUOTE_LOCKED`.
- `DELETE /cart/items/{id}` removes a line.

All return the cart:

```json
{ "data": { "id": 1, "items_qty": 24, "sub_total": 16800, "tax_total": 0, "shipping_total": 0,
  "grand_total": 16800, "currency": "INR",
  "items": [{ "id": 1, "product_id": 10, "variant_id": 11, "sku": "...", "name": "TEST Track Pant",
    "options": { "size": { "option_label": "S", "attribute_name": "Size" },
                 "color": { "option_label": "Red", "attribute_name": "Color" } },
    "qty": 6, "price": 700, "total": 4200, "locked_by_quote": false }],
  "moq": { "enabled": true, "min_qty": 24, "mode": "per_style", "met": true, "shortfalls": [] },
  "error": null } }
```

When `error` is set (`{ error_code, message }`), show it and disable checkout. A cart can be saved below the minimum, but it cannot be quoted or checked out.

### Quotes

`POST /quotes` with `{ name, description? }` turns the **whole current cart** into a quote and **empties the cart**. It returns 201, or `MOQ_NOT_MET`, `CART_EMPTY` or `NO_COMPANY`.

Quote object:

```json
{ "data": { "id": 1, "quotation_number": "QO000000001", "po_number": "PO000000001", "name": "...",
  "status": "open", "state": "quotation", "total": 16800, "negotiated_total": 16800,
  "expiration_date": "2026-11-07", "order_id": null, "can_accept": false, "description": null,
  "items": [{ "id": 1, "product_id": 10, "name": "...", "sku": "...", "options": {}, "qty": 6, "price": 700,
              "negotiated_qty": 6, "negotiated_price": 630, "negotiated_total": 3780 }],
  "messages": [{ "id": 1, "from": "customer", "message": "...", "created_at": "..." }] } }
```

Status flow: `open` → `negotiation` → `accepted` → `ordered` → `completed`. A quote can also become `rejected` or `expired`. Staff send offers from the admin.

| Call | Body | Notes |
|---|---|---|
| `GET /quotes` | `?limit=&page=` | Your company's quotes; items and messages are left out |
| `GET /quotes/{id}` | | |
| `POST /quotes/{id}/counter` | `{ message, items: { "<item id>": { discount_type: "percent" or "fixed", discount_value, negotiated_qty } } }` | Asks for a price. `QUOTE_CLOSED` if finished |
| `POST /quotes/{id}/messages` | `{ message }` | |
| `POST /quotes/{id}/accept` | | Show the button when `can_accept` is true. `NO_OFFER`, `QUOTE_EXPIRED` |
| `POST /quotes/{id}/reject` | `{ message }` | `QUOTE_CLOSED` if finished |

After accepting, the lines are in the cart at the negotiated price and are locked (`locked_by_quote: true`). Send the retailer to checkout. Removing a locked line is allowed. Changing its quantity is not.

### Checkout: call in this order

| Step | Body | Returns |
|---|---|---|
| `POST /checkout/address` | `{ billing: { first_name, last_name, email, address: ["line 1"], city, country: "IN", state: "MH", postcode, phone, use_for_shipping: true } }` (add a `shipping` object of the same shape when `use_for_shipping` is false) | `data.shipping_methods` |
| `POST /checkout/shipping` | `{ shipping_method: "flatrate_flatrate" }`, using a `method` from the previous response | `data.payment_methods` |
| `POST /checkout/payment` | `{ method: "moneytransfer" }` | |
| `POST /checkout/order` | | 201 `{ data: { id, order_number, status } }` |

Each step can return the cart errors `MOQ_NOT_MET`, `QUOTE_LOCKED` or `INSUFFICIENT_QUANTITY`, or `CART_EMPTY`.

Checkout stays on the offline `moneytransfer` method and places the order first. Money is then collected against the order, as described under Payments. The advance and balance are planning defaults, not owner-confirmed terms.

### Payments

Each order has a `finance` block. The server works out every amount; the browser never sends one for an online payment.

```json
{ "stage": "Awaiting advance", "advance_percent": 10, "advance_due": 684, "balance_due": 6156, "total": 6840,
  "paid": 0, "outstanding": 6840, "hold_until": "...", "payable": "advance", "gateway": "demo", "payments": [] }
```

`stage` runs `Awaiting advance` → `Confirmed` → `Packing` → `Dispatched` → `Delivered` → `Paid in full`, with `On hold`, `Cancelled` and `Expired` as side states. `payable` says what the retailer can pay now: `advance`, `balance` (only after delivery) or `null`.

| Call | Body | Notes |
|---|---|---|
| `POST /orders/{id}/payments` | `{ kind }` | Returns `{ payment_id, gateway, amount, options }`. `NOT_PAYABLE` if that payment is not due. |
| `POST /orders/{id}/payments/{paymentId}/confirm` | Razorpay's three result fields, or `{ simulated_result }` for the demo gateway | `PAYMENT_NOT_VERIFIED`, `PAYMENT_FAILED` |
| `POST /orders/{id}/payments/reference` | `{ kind, method, reference }` | `method` is `UPI` or `Bank transfer`. Finance verifies it. `DUPLICATE_REFERENCE` if already used. |
| `POST /webhooks/razorpay` | Razorpay's signed body | No token. Checked with `RAZORPAY_WEBHOOK_SECRET`. Safe to receive twice. |

An order with no advance by `hold_until` expires and its stock is released (`php artisan vk7:expire-holds`, scheduled hourly, and also run when orders are listed).

### Orders

`POST /orders/{id}/cancel` with `{ reason }` works while the order is `pending`; otherwise it returns `CANNOT_CANCEL`.

`POST /orders/track` is public. Send `{ number, phone }` where the mobile is the one on the order. It returns `stage` and `tracking` with no prices, or 404 if either does not match.

Order detail and public tracking include `tracking`, or `null` before dispatch: `{ id, courier, waybill, status, simulated, tracking_url, expected_on, delivered_at, route: [{ lat, lng, label }], events: [{ status, location, lat, lng, description, occurred_at }] }`.

`POST /checkout/order` also accepts optional `po_ref` and `notes`.

`GET /orders/{id}/invoice` returns the invoice with `company`, `bill_to`, `lines` and totals. It is a proforma until the advance is paid, then gets an `INV-` number once. `tax_invoice` stays false until the CA-approval setting is on.

`GET /orders` (`?limit=&page=`) and `GET /orders/{id}`:

```json
{ "data": { "id": 1, "order_number": "VK7-000001", "status": "pending", "status_label": "Pending",
  "total_qty": 24, "grand_total": 17040, "currency": "INR", "created_at": "...",
  "sub_total": 16800, "tax_total": 0, "shipping_total": 240, "shipping_title": "Flat Rate - Flat Rate",
  "payment_method": "moneytransfer",
  "items": [{ "id": 1, "name": "...", "sku": "...", "options": {}, "qty_ordered": 6, "qty_shipped": 0, "price": 700, "total": 4200 }],
  "shipments": [{ "id": 1, "carrier": "...", "track_number": "...", "total_qty": 24, "created_at": "..." }] } }
```

Display `stage`, not `status`. `status` is Bagisto's own value, kept in step with the stage: `pending` until the advance is verified, `processing` until paid in full, then `completed`.

## Staff business desk

Sign in with `POST /admin/login` (`{ email, password }`, a Bagisto admin user). Tokens last 12 hours and are refused on retailer routes, and the other way round. An account using two-factor sign-in gets `TWO_FACTOR_REQUIRED` and must use the panel: the desk has no second step yet. Each route needs an area from the role: `dashboard`, `retailers`, `enquiries`, `quotes`, `orders`, `payments`, `dispatch`, `products`, `inventory`, `reports`, `staff`, `settings` or `audit`. A custom role grants them through the `vk7_desk.*` permissions in Bagisto's role screen; otherwise the route returns `FORBIDDEN`.

| Area | Calls |
|---|---|
| any | `GET /admin/me`, `POST /admin/logout` |
| `dashboard` | `GET /admin/dashboard` |
| `reports` | `GET /admin/reports`: totals, `monthly`, `pending`, `retailers`, `products` |
| `retailers` | `GET /admin/clients`, `GET /admin/clients/{id}`, `POST /admin/clients/{id}/decision` `{ decision, reason }` |
| `orders` | `GET /admin/orders`, `GET /admin/orders/{id}`, `POST /admin/orders/{id}/hold`, `/resume`, `/cancel` |
| `payments` | `GET /admin/payments`, `POST /admin/payments/{id}/review` `{ accepted, reason }`, `POST /admin/orders/{id}/collection` `{ amount, method, reference }` |
| `dispatch` | `GET /admin/dispatch`, `POST /admin/orders/{id}/stage` `{ stage: "Packing" }`, `POST /admin/orders/{id}/dispatch`, `POST /admin/shipments/{id}/refresh` |
| `audit` | `GET /admin/activity` |
| `products` | `GET`, `POST /admin/categories`, `GET`, `POST /admin/products`, `GET`, `PUT /admin/products/{id}`, `POST /admin/products/{id}/photos` (multipart: `colour`, `photos[]`), `DELETE /admin/products/{id}/photos/{imageId}` |
| `inventory` | `GET /admin/inventory`, `POST /admin/inventory/adjust` `{ variant_id, change, reason, note }`, `GET /admin/stock-log` |
| `quotes` | `GET /admin/quotes`, `GET /admin/quotes/{id}`, `POST /admin/quotes/{id}/offer` `{ prices: { itemId: price }, message }`, `POST /admin/quotes/{id}/reject` `{ reason }` |
| `enquiries` | `GET /admin/enquiries`, `PUT /admin/enquiries/{id}` `{ status, note, follow_up_on }` |
| `staff` | `GET`, `POST /admin/staff`, `PUT /admin/staff/{id}`, `POST /admin/staff/{id}/toggle` |
| `settings` | `GET`, `PUT /admin/settings`: business rules, company details, bank details |

## Connecting from your app

```js
const API = import.meta.env.VITE_API_URL; // http://127.0.0.1:8000/api/v1

export async function api(path, { method = 'GET', body } = {}) {
  const token = localStorage.getItem('vk7_token');
  const res = await fetch(API + path, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    },
    body: body && JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) throw Object.assign(new Error(data.message), { status: res.status, ...data });
  return data;
}
```
