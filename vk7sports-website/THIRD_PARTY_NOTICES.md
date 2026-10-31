# Third-party notices

This private repository contains or derives from third-party software. Original licence files are kept unmodified.

| Component | Where in this repo | Licence | Notice |
|---|---|---|---|
| Bagisto 2.5.0 (Webkul Software) | `backend/app/` (upstream tree incl. `packages/Webkul/`, built themes in `public/themes/`) | MIT | `backend/app/LICENSE` (unmodified) |
| Bagisto B2B Suite 3.0.1 (Webkul), `bagisto/b2b-suite` | Composer dependency (not vendored); published views under `backend/app/resources/views/vendor/`, built theme `backend/app/public/themes/b2b-suite/` | MIT | Reproduced below |
| Composer dependencies (237 packages incl. dev) | Not vendored; pinned in `backend/app/composer.lock` | Mostly MIT/BSD/Apache-2.0; see below | Each package ships its own licence on `composer install` |
| Core patches 0001/0002 | `backend/patches/`, applied in `backend/app/packages/Webkul/` | MIT (modifications of Bagisto) | `backend/app/LICENSE` |

**Copyleft dependencies in `composer.lock`, not distributed by this repository:** `mpdf/mpdf` (GPL-2.0-only), `nette/schema` and `nette/utils` (GPL-2.0-only / GPL-3.0-only, dual), `enshrined/svg-sanitize` (GPL-2.0-or-later), `dompdf/dompdf` (LGPL-2.1), `dompdf/php-font-lib` (LGPL-2.1-or-later), `dompdf/php-svg-lib` (LGPL-3.0-or-later), `ezyang/htmlpurifier` (LGPL-2.1-or-later), `khaled.alshamaa/ar-php` (LGPL-3.0), `apimatic/jsonmapper` (OSL-3.0). **Obtain legal review before distributing any build or deploying for third parties.**

**Licence of AASIOM/VK7-authored code** (`backend/app/packages/VK7/`, `prototypes/v2-codex-catalogue/`, docs): not yet decided by AASIOM. All rights reserved until decided.

## B2B Suite licence (verbatim from `bagisto/b2b-suite` 3.0.1 `LICENSE`)

```
MIT License

Copyright (c) 2025 Webkul

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
