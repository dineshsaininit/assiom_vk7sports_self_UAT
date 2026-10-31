# VK7SPORTS — UI/UX Specification for Figma

**For:** the designer(s) working in Figma
**Scope:** MVP-1 only. Nothing in this document is optional; nothing outside it is in scope.
**Date:** 28 July 2026
**Companion document:** `VK7SPORTS_Website_Strategy_Audit.md` (business rationale — read §36, §42–47 if you want the "why")

---

## 0. Before you open Figma — five things that decide whether this design succeeds

1. **This is a phone-first site for people at work.** A sports teacher between classes. A gym owner on the floor. A coach on a ground. Design every screen at **360 × 800** first, then 768, then 1440. If it only works at 1440, it does not work.

2. **Two audiences, one homepage.** A person buying one training tee, and an institution buying 300 jerseys. The homepage must let both self-identify within one screen height. Do not average them into a vague "sportswear brand" page — that serves neither.

3. **The most valuable screens are not the pretty ones.** The mock-up approval page and the internal worklists carry more business value than the homepage. Do not spend 70% of the effort on the hero section.

4. **Every price shown is a commercial decision, not a layout element.** Where you place price, and whether tax is included, is specified per screen below. Do not improvise.

5. **Honesty over polish.** No fake stock counts, no fake "23 people viewing", no fake reviews, no fake urgency timers. The customers are professionals with long memories and this is a relationship business.

---

## 1. Brand direction

**Positioning:** premium technical sportswear, manufactured and supplied at scale. Credible to a procurement officer, aspirational to an athlete.

**Reference note:** the owner likes `wildshark-b2b.com`. **Take from it only:** the confidence, the density of useful information, the clarity of the B2B path. **Do not take:** layout, colour, component structure, imagery style or copy. This is an original design.

**Tone to hit:** *equipment*, not *fashion*. Confident, factual, capable. The site should feel like a supplier a school would trust with a ₹6 lakh order — not like a boutique.

**Tone to avoid:** playful, pastel, minimal-to-the-point-of-empty, or startup-generic (gradient blobs, floating 3D shapes, oversized rounded cards).

### 1.1 Colour

Define as Figma variables with light-mode only in MVP.

| Token | Role | Guidance |
|---|---|---|
| `color/brand/primary` | Primary brand | Deep, saturated, confident. Must pass 4.5:1 on white for text use. |
| `color/brand/primary-hover` | Interactive state | ~10% darker |
| `color/brand/accent` | Sparingly — CTAs, active states | One accent only. Two accents will make it look like a marketplace. |
| `color/ink/900 → 100` | Text scale, 5 steps | 900 for headings, 700 body, 500 secondary, 300 disabled |
| `color/surface/base` | Page background | Near-white, not pure white |
| `color/surface/raised` | Cards, sheets | White |
| `color/surface/sunken` | Section bands | Very light neutral |
| `color/border/subtle`, `border/strong` | Dividers, inputs | |
| `color/status/success` | In stock, delivered, approved | |
| `color/status/warning` | Low stock, pending approval, at risk | |
| `color/status/danger` | Out of stock, failed, overdue | |
| `color/status/info` | Neutral informational states | |

**Rule:** status colours are never used decoratively. If a designer uses `status/success` green for a marketing button, order status becomes unreadable.

### 1.2 Typography

| Token | Size / line-height | Use |
|---|---|---|
| `type/display` | 40–56 / 1.1 | Homepage hero only |
| `type/h1` | 28–32 / 1.2 | Page titles |
| `type/h2` | 22–24 / 1.3 | Section headings |
| `type/h3` | 18–20 / 1.4 | Card titles, PDP sections |
| `type/body-lg` | 17 / 1.6 | Lead paragraphs |
| `type/body` | 15–16 / 1.6 | Default. **Never below 15px for body on mobile.** |
| `type/caption` | 13 / 1.4 | Metadata, helper text |
| `type/label` | 13 / 1.2, uppercase, tracked | Form labels, badges |
| `type/mono` | 14 | Order numbers, SKU codes, quotation numbers, AWB |

Two families maximum: one for headings, one for body. A separate mono for reference numbers is allowed and recommended — order numbers get read aloud on phone calls.

### 1.3 Spacing, radius, elevation

- **Spacing scale:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80. Nothing off-scale.
- **Radius:** `sm 4` (inputs, badges), `md 8` (cards, buttons), `lg 16` (sheets, modals), `full` (avatars, pills). Nothing larger than 16 — heavy rounding reads as consumer-app, not supplier.
- **Elevation:** three levels only — `raised` (cards), `overlay` (dropdowns, sheets), `modal`. Subtle shadows. This brand is not glassy.

### 1.4 Grid and breakpoints

| Breakpoint | Width | Columns | Gutter | Margin |
|---|---|---|---|---|
| Mobile | 360–767 | 4 | 16 | 16 |
| Tablet | 768–1023 | 8 | 24 | 24 |
| Desktop | 1024–1439 | 12 | 24 | 32 |
| Wide | 1440+ | 12 | 32 | max content width 1280, centred |

### 1.5 Imagery

- **Product:** consistent on a single neutral background, identical crop, identical lighting, identical model pose across a family. Inconsistent product photography destroys premium positioning faster than any other single factor.
- **Lifestyle / action:** real Indian sport contexts — school grounds, academies, gyms, local clubs. Not stock photography of American athletes.
- **Teamwear gallery:** real delivered kits, photographed on real teams where permission exists. This is the highest-value imagery on the site.
- **Do not use:** supplier catalogue images, WhatsApp-compressed photos, or renders.
- Every image needs alt text. Specify alt-text patterns in the design file so content entry has a rule to follow.

---

## 2. Component library to build in Figma

Build these as components with variants. Anything not on this list is out of scope.

### Foundations
`Button` (primary / secondary / ghost / danger × sm/md/lg × default/hover/pressed/disabled/loading, with optional leading and trailing icon)
`Input` (text / number / phone / email × default/focus/filled/error/disabled, with label, helper text, error text, character counter)
`Select`, `Multi-select`, `Checkbox`, `Radio`, `Toggle`, `Textarea`
`File Upload` (empty / dragging / uploading with progress / success with thumbnail / error with reason)
`Date Picker` (mobile-native pattern)
`Quantity Stepper` (with min, max, and a max-reached state — **the max state must be designed, it carries a business rule**)
`Badge` (status colours + neutral)
`Tag / Pill` (filter chips: default / selected / removable)
`Breadcrumb`, `Pagination`, `Tabs`, `Accordion`
`Toast` (success / error / info), `Inline Alert` (4 severities)
`Modal`, `Bottom Sheet` (mobile equivalent of modal — use sheets on mobile, not centred modals)
`Skeleton Loader`, `Empty State` (illustration + message + one action), `Error State`
`Spinner`

### Commerce
`Product Card` (image, name, price, colour swatches, badge slot; states: default / hover / sold-out / made-to-order)
`Product Grid`
`Colour Swatch Selector` (available / selected / unavailable)
`Size Selector` (available / selected / out-of-stock-with-strike / low-stock)
`Size Chart Sheet` — **mobile bottom sheet, never a new page**
`Price Block` (MRP struck + selling price + tax note variant for B2C inclusive and B2B exclusive)
`Stock Indicator` (In stock / Only N left / Sold out / Made to order)
`Pin Code Checker` (input + serviceable / not serviceable / ETA result)
`Cart Line Item` (image, name, variant, qty stepper, line total, remove)
`Order Summary Panel` (subtotal, shipping, tax note, total)
`Payment Method Selector` (UPI / Card / Netbanking / COD, with a **COD-unavailable-with-reason** state)
`Order Status Tracker` (horizontal on desktop, vertical on mobile; 5 steps retail, 4 steps custom, with a **delayed/on-hold** variant)

### B2B and teamwear
`Enquiry Form Block`
`Size-Quantity Grid` (rows = sizes, column = quantity, with a running total — used for bulk without names)
`Roster Table` (row = player: name, number, size; add/remove rows; **paste-from-spreadsheet affordance**; mobile = stacked cards, not a scrolling table)
`Placement Picker` (garment outline with tappable zones: chest left, chest centre, back, sleeves, collar; selected zones expand to method + colour + size inputs)
`Artwork Upload Card` (with file-requirement guidance visible *before* upload, and a rejected state showing the reason)
`Mock-up Viewer` (front/back/side thumbnails, tap to zoom, version label)
`Approval Panel` — see §3.7, the most important component in the file
`Quotation Summary Card` (number, date, valid-until with a days-remaining indicator, total, status badge, download PDF)
`MOQ Notice` (inline, factual)
`Lead Time Notice`

### Internal (VK7 Desk)
Even though MVP-1 uses a no-code tool, design these — they define what the team configures and later builds.
`Worklist Row` (reference, customer, age with an overdue treatment, assignee, status, next action)
`Worklist Filter Bar`
`Detail Panel` (two-column on desktop: record on the left, activity timeline on the right)
`Activity Timeline Entry` (who, what, when — the audit log made visible)
`Status Changer` (dropdown with a **mandatory reason field on any cancellation or hold**)
`Quotation Builder Line Row`
`Approval Request Banner` (below floor price → Send disabled, Request Approval shown)
`Stock Adjustment Modal` (quantity, reason code, note — reason is mandatory)

---

## 3. Screen-by-screen specification

Design every screen in **three states minimum: default, loading, empty/error.** A screen without its empty state is not delivered.

### 3.1 Homepage

**Job:** let a retail buyer and an institutional buyer each identify their path within one screen height on mobile.

**Mobile stack:**
1. Sticky header — logo, search, cart, hamburger
2. Hero — one strong image, one line of positioning, **two buttons of equal visual weight: "Shop Products" and "Bulk & Team Orders"**. Equal weight is a business requirement, not a design preference.
3. Three-tile path selector: *Shop for yourself* / *Team & bulk orders* / *Become a dealer*
4. Featured categories (4–6 tiles, real product photography)
5. **Teamwear showcase** — 3 pieces of real delivered work, link to gallery. This section sells the highest-margin service; give it real space.
6. Credibility band — capability facts only, no invented statistics. Suggested content: sourcing countries, in-house printing and embroidery, customisation capability, sports covered. **Do not put numbers in the design that the business has not confirmed.** Use placeholder labels marked `[owner to confirm]`.
7. Who we supply — schools, academies, clubs, gyms, corporates, events (icons + labels, each linking to its `/bulk/*` page)
8. New arrivals / bestsellers
9. Footer — full navigation, policies, contact, GST/legal entity line

**Persistent mobile element:** a floating "Get a Quote on WhatsApp" action, above the fold on scroll. Do not hide the channel the customers already use.

### 3.2 Category / listing page

- Filters: **Sport, Product type, Size, Colour, Price.** Nothing else in MVP.
- Mobile: filter opens as a full-height bottom sheet with an "Apply" button and a visible result count. Never a desktop sidebar squeezed onto mobile.
- Applied filters shown as removable chips above the grid.
- Sort: Relevance / Newest / Price low-high / Price high-low.
- Grid: 2 columns mobile, 3 tablet, 4 desktop.
- Sold-out products stay in the grid, visually de-emphasised, never hidden — hiding them makes the catalogue look thin.
- **Empty state is mandatory:** "No products match these filters" + a clear reset + a link to bulk enquiry.

### 3.3 Product detail page (PDP)

Mobile order — this order is specified, not suggested:
1. Image gallery, swipeable, dot indicators, tap to zoom
2. Product name + short descriptor
3. **Price block** — B2C shows tax-inclusive with a small "incl. taxes" note
4. Colour swatches
5. Size selector + **"Size guide" link that opens a bottom sheet**
6. Stock indicator
7. Quantity stepper — **at max, an inline message appears: "Need more than N? Get bulk pricing →"** linking to `/bulk/enquiry` with the product pre-filled
8. Add to cart (sticky bar on scroll, showing price + button)
9. Pin code checker + delivery estimate
10. Accordion: Description · Fabric & Specifications · Size chart · Shipping & Returns
11. **"Want this with your team's logo?" band** → `/teamwear/request` with the product pre-selected. Present on every customisable product.
12. Related products

**Do not:** push the price below the fold on a 360px screen; use a carousel that traps vertical scroll; hide the size guide behind a page navigation.

### 3.4 Cart and checkout

- **Guest checkout is default.** Account creation is offered after purchase, never before.
- Cart: line items, quantity steppers, order summary, one primary CTA. No cross-sells in MVP.
- Checkout as a single scrolling page with three labelled sections — **not** a multi-step wizard. Steps: Contact (phone first) → Delivery address → Payment.
- Under 10 fields total. Pin code autofills city and state.
- Payment order: **UPI, then cards, then netbanking, then COD.**
- **COD ineligible state must be designed:** a visible, plainly-worded reason ("COD is not available for this pin code" / "COD is not available on customised items"), never a silently missing option.
- Order confirmation: order number in mono, large; what happens next in three lines; "you'll get a WhatsApp update" note.
- **Design the failure states:** payment failed with retry, payment successful but order pending, session expired.

### 3.5 Bulk enquiry (`/bulk/enquiry`)

**Job:** collect enough to make the sales call productive, and let unqualified enquiries self-select out.

Fields — this is the complete list:
- Organisation name *
- Organisation type * (select)
- Contact person *, Phone/WhatsApp *, Email
- City *
- What do you need * (multi-select of product families + "Something else")
- Approximate quantity * (range select — **not** a free-text number)
- Required by (date)
- Upload (optional, multiple): logo, spec sheet, tender document
- Anything else (textarea)

**Above the form, plainly stated:** minimum order quantity, typical lead time, and "we will call you within X hours." These three lines do more filtering work than any validation rule.

**Confirmation screen:** reference number in mono, the named response commitment, and a WhatsApp link. Not a generic "thank you".

### 3.6 Custom teamwear request (`/teamwear/request`)

The most complex form on the site. Design it as **four numbered steps with a progress indicator and the ability to move backwards.** Save progress locally so a dropped connection does not lose the roster.

**Step 1 — Product & colour.** Base garment, colourway, sport.

**Step 2 — Quantities.**
- Toggle between two modes: **"Same design for everyone"** (Size-Quantity Grid) and **"Individual names and numbers"** (Roster Table).
- Roster Table: on mobile this is stacked cards, one per player, with an "Add player" button. Include a "paste from a list" affordance and a downloadable template.
- Running total always visible.

**Step 3 — Customisation.**
- Placement Picker on a garment outline.
- For each selected placement: method (print / embroidery), content type (logo / player name / player number / team name / fixed text), colours, and an artwork upload if applicable.
- **File requirements shown *before* the upload control**, in plain language: preferred formats, minimum resolution, "a photo of a logo will not print well."
- **IP warranty checkbox — mandatory, unticked by default, with full text visible, not behind a link:** *"I confirm that I own, or have permission to use, all logos and artwork I have uploaded."*

**Step 4 — Delivery & contact.** Required-by date, delivery city, contact details, notes.

**Confirmation:** reference number, what happens next in four plain steps (review → quotation → mock-up → approval), and expected timelines.

### 3.7 Mock-up approval page (`/approve/{token}`) — **the most important screen in the project**

Reached from a WhatsApp link. **No login. No account. No app.** It must work for a 55-year-old sports teacher on a mid-range Android phone on 4G.

**Layout, mobile:**
1. VK7SPORTS header + "Design approval for [Organisation]"
2. Mock-up images — front, back, side. Large, swipeable, tap to zoom.
3. **The name and number list, exactly as it will be printed.** Row per player: printed name, number, size. Any name the designer has flagged as too long or altered is visually marked with a short note.
4. A plainly worded warning block: *"Please check every spelling and number carefully. Once approved, production begins and changes are not possible without additional cost and delay."*
5. Two clear actions, unequal weight:
   - **Primary: "Approve this design"**
   - Secondary: "Request a change"
6. On tapping Approve, a confirmation sheet: type your name, tick *"I confirm this design and the name list are correct"*, submit.
7. Post-approval screen: confirmation, what happens next, and a **downloadable PDF copy of exactly what was approved.**

**Design requirements that are non-negotiable:**
- The name list must be **readable without zooming** at 360px. If 25 names do not fit legibly, paginate or stack — do not shrink.
- "Request a change" must be as easy to find as "Approve". Making approval the only easy path produces approvals of things the customer has not read, which defeats the entire purpose.
- Show the version number and date.
- Design the expired-link state and the already-approved state.

### 3.8 Order tracking (`/track`)

- Lookup by order/reference number + phone. No login.
- Retail: 5 steps. Custom: 4 steps. Bulk: 4 steps. Different components, same visual language.
- **Design the delayed state.** A stalled tracker with no explanation generates phone calls; a tracker that says "Delayed — revised date [X]" prevents them.
- Include a "Message us on WhatsApp about this order" action with the reference pre-filled.

### 3.9 Dealer application (`/dealers/apply`) and `/dealers/why-partner`

- `why-partner`: what VK7 supplies, what support is offered, what is expected. **Absolutely no prices, margins or tier structures anywhere on either page.**
- Application form: firm name, GSTIN, city, years in business, categories of interest, existing brands stocked, references, contact.
- Confirmation: reference number, "our team will verify and contact you." No timeline promise unless the owner commits to one.

### 3.10 Bulk landing pages (`/bulk/schools-and-colleges` etc.)

One template, four variants. Structure:
1. Headline naming the audience explicitly ("Sports kit for schools and colleges")
2. What we supply for this segment
3. Gallery of relevant delivered work
4. How it works — 5 steps with realistic timelines
5. MOQ and lead time, stated
6. FAQ (payment terms, customisation, delivery, sizes for children)
7. Enquiry form or a strong link to it

### 3.11 Teamwear gallery (`/teamwear/gallery`)

Simple filterable grid of real delivered work: sport, organisation type. Each item opens to photos, the sport, what was made, and a one-line note. **No prices. No client names without permission.** Design an honest low-content version — the gallery will launch with fewer items than you would like.

### 3.12 Legal and policy pages

One clean, readable template. Generous line height, `max-width` around 68 characters, a sticky table of contents on desktop. These pages will be read by procurement officers and are part of the credibility argument. Do not treat them as an afterthought.

### 3.13 VK7 Desk screens (internal)

Design at desktop 1440 first — staff use computers — but every screen must remain usable at 768 because approvals happen on phones.

**Worklist (the default landing for every role):**
- One table. Columns: reference, customer, subject, age, assignee, status, next action.
- Overdue rows carry a clear treatment (left border + a badge), never colour alone.
- Filter bar: status, assignee, date range, overdue-only.
- Bulk actions: assign, change status.
- **Empty state matters here:** "Nothing waiting on you" is a good outcome and should look like one.

**Detail view:** two columns — record data on the left, activity timeline on the right. The timeline is the audit log made human; it is what staff use to answer "what happened with this order?"

**Quotation builder:** line rows, size breakup entry, live totals, a persistent floor-price indicator, and a **Send button that visibly disables with an inline explanation when any line is below floor price**, replaced by "Request approval".

**Artwork queue (designer):** thumbnail grid, each with the request reference and age; usability decision as a two-button action with a mandatory note on rejection.

**Stock adjustment:** modal with quantity, mandatory reason code, note. Never allow a silent quantity edit.

---

## 4. Content the design depends on

Flag these to the project lead early — the design cannot be finalised without them, and they take longer to produce than the design does.

| # | Content | Blocking |
|---|---|---|
| 1 | Final product photography, single consistent standard | Every product screen |
| 2 | Real size charts with measured garment dimensions | PDP, returns rate |
| 3 | Final category structure and product names | Navigation and IA |
| 4 | Confirmed MOQ and lead times | Bulk pages, enquiry form |
| 5 | Approved legal copy for the IP warranty | Teamwear form |
| 6 | Approved policy text (returns, shipping, privacy, terms) | Policy pages |
| 7 | Delivered-work photographs with permissions | Teamwear gallery |
| 8 | The exact customer-visible status words, per channel | Trackers |
| 9 | Confirmed capability facts for the credibility band | Homepage |
| 10 | Whether prices display tax-inclusive or exclusive, per channel | Price component |

**Use visible placeholder styling for anything unconfirmed** — a distinct highlight in the Figma file — so no unverified number reaches a stakeholder review looking like a decision.

---

## 5. Accessibility requirements

- Text contrast ≥ 4.5:1; large text and UI components ≥ 3:1.
- **Status is never communicated by colour alone.** Always colour + icon or colour + text.
- Tap targets ≥ 44 × 44 px with ≥ 8px spacing.
- Visible focus states on every interactive component — design them, do not leave them to the developer.
- Every form field has a persistent visible label. Placeholder-as-label is not acceptable.
- Errors are specific and adjacent to the field, plus a summary at the top of long forms.
- Body text never below 15px on mobile.
- Design at 200% text zoom for the checkout and the approval page at minimum.
- Alt-text patterns defined for product, gallery and mock-up images.

---

## 6. Figma file organisation

```
📁 VK7SPORTS Design System
   Page: Foundations        colours, type, spacing, radius, elevation, icons, grids
   Page: Components         all components with variants and documented properties
   Page: Patterns           form patterns, empty states, error states, loading states

📁 VK7SPORTS Website
   Page: 00 Cover           scope, version, changelog, open questions
   Page: 01 Flows           user flows for retail, bulk, teamwear, dealer
   Page: 02 Wireframes      mobile-first, low fidelity, for approval before visual design
   Page: 03 Mobile          all screens at 360, every state
   Page: 04 Tablet          768, only where layout genuinely diverges
   Page: 05 Desktop         1440
   Page: 06 Prototype       clickable demo flows — see §7
   Page: 99 Archive         rejected directions, kept for the record

📁 VK7 Desk (Internal)
   Page: Worklists · Detail views · Quotation builder · Artwork queue · Modals
```

**Conventions:** all colours, type and spacing as Figma variables — no hard-coded hex anywhere. Auto-layout on every component. Naming: `Component/Variant/State`. Every screen frame named `[Section] Screen name — State`.

---

## 7. The demo prototype — specific guidance

This prototype's purpose is to secure budget approval from the VK7SPORTS owner. Read this section carefully; it differs from normal prototype practice.

**Prototype these four flows, in this priority order:**
1. **Institutional buyer:** homepage → bulk landing → enquiry form → confirmation → (jump) quotation received on phone → mock-up approval page → approved
2. **Custom teamwear:** teamwear hub → gallery → request form all four steps → confirmation
3. **Retail:** homepage → category → PDP with size guide → cart → checkout → confirmation
4. **Internal Desk:** enquiry worklist → open enquiry → build quotation → floor-price approval prompt → send

Flow 1 is the one that wins the budget. It shows the owner his highest-value workflow becoming defensible. Lead the walkthrough with it, not with the homepage.

**Three rules for the demo:**

- **Show manual steps as manual.** Where a human reviews, prices or approves, the prototype should say so: "Our team reviews and sends a quotation within 24 hours." A businessman finds a credible process more convincing than a magical one — and it protects you from promising automation you have not scoped.

- **Use real content wherever possible.** Real product names, real categories, real photographs if any exist, plausible Indian names and cities in the roster. Lorem ipsum and stock American athletes will cost you more credibility than an unfinished layout will.

- **Do not prototype anything on the DO NOT BUILD list.** No 3D customiser, no dealer pricing screens, no multi-currency, no app screens, no live chat, no loyalty. Anything shown becomes something expected. If the owner asks for one of them during the walkthrough, the answer is a date for a later phase and a reason, not a mock-up.

**Present alongside the prototype:** a one-page written list of what is explicitly *not* included in Phase 1, and why. Ask for sign-off on that page as well as on the design.

---

## 8. Explicitly out of scope — do not design these

Designing any of these creates an expectation the project will not fund.

3D jersey customiser · mobile app screens · dealer login area or dealer pricing screens · credit-limit or outstanding-balance screens · multi-currency or country selector · loyalty points · live chat widget · wishlist · product reviews · coupon or discount entry field · blog templates · granular production tracking for customers · dark mode · marketplace or multi-vendor screens · any dashboard of charts as a staff landing page.

---

## 9. Definition of done for design handover

- [ ] Every screen designed at 360 and 1440; tablet only where layout diverges
- [ ] Every screen has default, loading, empty and error states
- [ ] Every form has a validation-error state with real error copy written, not placeholder
- [ ] Every component uses variables — zero hard-coded colours or type sizes
- [ ] Contrast checked and recorded on every text and UI pair
- [ ] Focus states designed for every interactive component
- [ ] Prototype covers the four flows in §7
- [ ] A single page listing every unconfirmed content item, visibly marked
- [ ] Cover page states the version, date and what changed
- [ ] Design reviewed against §3 screen by screen, and against §8 for scope creep
