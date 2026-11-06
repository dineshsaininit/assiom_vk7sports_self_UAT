# Backend/API integration report

**VK7 runtime integration: BLOCKED / NOT VERIFIED. No endpoint, token or test result was invented.**

## Existing routes verified from UAT source

Route file: backend/app/packages/VK7/Wholesale/src/Routes/api.php. WholesaleServiceProvider loads it; it defines prefix api/v1 with ForceJson and throttle:vk7-api middleware.

| Route | Source purpose / access |
|---|---|
| GET /api/v1/meta | Store metadata including configured MOQ; optional retailer authentication. |
| GET /api/v1/categories | Category tree; optional retailer authentication. |
| GET /api/v1/products?include_grid=1 | Product listing with variant grid; optional retailer authentication. |
| GET /api/v1/products/{product} | Product by actual ID/URL key with size/colour grid and inventory context; optional retailer authentication. |
| POST /api/v1/moq/check | Non-saving MOQ/stock evaluation in CartController::check; requires authenticated retailer. |
| GET /api/v1/auth/me | Requires authenticated retailer. |
| POST /api/v1/auth/login | Login with existing approved retailer credentials; throttled. Not called. |

AuthenticateRetailer reads a Bearer token through PersonalAccessToken, checks expiry and retailer ability, and requires an eligible active/verified account. Authenticated calls can update token last_used_at. No credentials/tokens were guessed, generated or used. Source-declared 401 behavior is not an observed live VK7 response.

Existing SQL relations and connection inputs are documented in [DATABASE_STATUS.md](DATABASE_STATUS.md), [BACKEND_HANDOVER_DEEPANJAL.md](BACKEND_HANDOVER_DEEPANJAL.md) and the earlier database handover. No API functionality was changed.

## Executed safe probes

Direct localhost requests used Accept: application/json and disabled HTTP proxies.

| URL on 127.0.0.1:8000 | Observed HTTP result |
|---|---|
| /api/v1/meta | 404, Server nginx, application/json, top-level key error |
| /api/v1/products?include_grid=1 | 404, Server nginx, application/json, top-level key error |
| /api/v1/auth/me | 404, Server nginx, application/json, top-level key error |

Port ownership was then verified as ai-qa-platform-nginx-1, project ai-qa-platform, mapping host 8000 to container 80. **These are responses from an unrelated application, not VK7 API tests.** That service was not stopped or altered.

No VK7 app container exists. The cached PHP image works, but the temporary read-only Artisan check timed out. Laravel route:list was not reached; the route inventory above is source evidence only.

## Result by requested capability

| Capability | Result |
|---|---|
| MySQL transport / existing container roles | PASS: read-only root and configured application-role SELECTs. |
| Laravel database connectivity | BLOCKED: UAT .env/vendor absent, separate runtime not successfully booted. |
| Product listing | NOT VERIFIED against VK7; wrong-service 404 recorded separately. |
| Product variant retrieval | NOT EXECUTED: no verified VK7 service or genuine product identifier. |
| Inventory availability | NOT VERIFIED: no initialized tables/approved stock; source supports grid/check evaluation. |
| Runtime MOQ validation | NOT EXECUTED: requires initialized policy/product/account/token data. |
| Offline product/stock/MOQ-policy input validation | PASS: existing 48-test suite. Not runtime business-rule evidence. |

## Next steps

Resolve source/runtime alignment, additive initialization, genuine inputs and an unused VK7 localhost port. Verify the service identity before API testing. Obtain a real authorized retailer/test account and token securely. Then record actual status codes, sanitized response shapes, product IDs/SKUs, source-level stock and MOQ boundary results against the approved policy. Use existing routes above; do not invent a new API. Do not run destructive Laravel test suites against bagisto/Neon.
