# How the website talks to the backend

`assets/js/api.js` is the only file that calls the backend. Pages use `VK7.api` and never fetch data themselves. The endpoints are listed in `docs/backend/VK7SPORTS_API_CONTRACT.md`.

- Every method returns a Promise.
- Failures throw `new VK7.ApiError(message, { code, status, fields })`. `fields` is `{ fieldName: 'message' }`, shown beside each field. `status: 401` sends the user to sign-in; `status: 404` shows "not found".
- Retailers and staff each have their own bearer token, kept in the browser. No CSRF token is needed.
- The browser never decides a price, stock or minimum. The server enforces them.

To move the backend, change `apiBase` in `assets/js/config.js`.
