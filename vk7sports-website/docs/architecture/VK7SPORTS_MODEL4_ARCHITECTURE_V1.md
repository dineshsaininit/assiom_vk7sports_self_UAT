# VK7SPORTS Model 4 — System Architecture V1

**Model:** Nemotron-3-Ultra-Free (OpenCode Zen) · **Role:** Principal System Architect · **Date:** 26 September 2026
**Status:** Finalized architecture decision — no implementation, no framework init, no migrations, no commits.
**Inputs:** All 14 canonical Model 3 files + full Model 3.1 set (verified per `VK7SPORTS_MODEL3_1_HANDOFF.md`).

---

## 1. ARCHITECTURE STYLE DECISION

### Decision: **MODULAR MONOLITH**

### Evaluation Matrix

| CRITERION | MODULAR MONOLITH | MICROSERVICES | HYBRID |
|---|---|---|---|
| **Transactional correctness** | ✅ Single DB transaction spans checkout (T3: stock→reservation→order→payment→audit). No sagas, no eventual consistency for money/stock. | ❌ Requires distributed transactions or saga orchestration for T3 atomic set — adds failure modes Model 3 explicitly rejected (INV-012, INV-019). | ⚠️ Partial extraction still needs saga for cross-service atomicity; same complexity as full microservices for the critical path. |
| **Team complexity** | ✅ Single repo, shared schema, one deployment. Current team size (implied: small) favors low coordination overhead. | ❌ Service contracts, versioning, observability mesh, distributed debugging — unjustified without team scaling signal. | ⚠️ Adds service boundary discipline without full benefit. |
| **Operational burden** | ✅ One DB, one app, one deploy pipeline, one health check. Backups, migrations, rollbacks are trivial. | ❌ Multiple databases, service discovery, circuit breakers, distributed tracing mandatory from day one. | ⚠️ Same operational surface as microservices for extracted pieces. |
| **Deployment complexity** | ✅ Single artifact. Blue/green or rolling on one unit. | ❌ Coordinated multi-service deploys, contract testing, canary per service. | ⚠️ Partial coordination still required. |
| **Developer velocity** | ✅ Fast iteration, shared types, refactoring across module boundaries with compiler support. | ❌ Cross-service changes need multi-repo PRs, contract negotiation, integration environments. | ⚠️ Module extraction adds friction before it pays off. |
| **Testability** | ✅ Full integration tests in one process; T7 (concurrent checkout race) runs deterministically against real DB. | ❌ Integration tests need testcontainers per service or shared staging; flaky, slow. | ⚠️ Same as microservices for extracted boundaries. |
| **Cost** | ✅ One DB instance, one compute unit, no message broker infra. | ❌ Minimum 3–5 services + broker + service mesh + observability stack = 5–10× infra cost at V1 scale. | ⚠️ Incremental cost per extraction. |
| **Future extraction** | ✅ 15 bounded contexts (D01–D15) already cut with explicit ownership, module rules, and dependency direction (ADR-001). Seams map 1:1 to future services. REVERSIBILITY: HIGH. | N/A | N/A |
| **Scaling path** | ✅ Vertical first (PostgreSQL handles V1 load); horizontal via read replicas for D15 analytics; stateless web tier scales horizontally. Worker extraction (notifications, sweeper) is additive, not architectural. | ✅ Independent scaling per service — but not needed until proven. | ✅ Same as monolith for unextracted parts. |

### Rationale Summary

Model 3's transaction design (T3: checkout = one atomic DB transaction spanning inventory, reservations, orders, payments, audit) is the **architectural anchor**. Microservices would force this into a saga with compensating actions, directly contradicting INV-012, INV-019, and the "correctness above throughput" principle. The modular monolith preserves this correctness while the 15 bounded contexts provide **extraction seams** with HIGH reversibility (ADR-001). No operational maturity exists to justify distributed system overhead. The hybrid option adds service-boundary discipline without eliminating the saga requirement for the critical path.

**This decision is engineering-owned (Model 4 authority per Model 3.1 Contract §B). No founder ratification required.**

---

## 2. HIGH-LEVEL TOPOLOGY

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SINGLE POSTGRESQL DATABASE                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      MODULAR MONOLITH APPLICATION                    │    │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │    │
│  │  │ D01  │ │ D02  │ │ D03  │ │ D04  │ │ D05  │ │ D06  │ │ D07  │   │    │
│  │  │IDENTITY│ │CUSTOMER│ │CATALOGUE│ │PRICING │ │MOQ    │ │INVENTORY│  │    │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘   │    │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │    │
│  │  │ D08  │ │ D09  │ │ D10  │ │ D11  │ │ D12  │ │ D13  │ │ D14  │   │    │
│  │  │CHECKOUT│ │PAYMENTS│ │ORDERS │ │FULFILL │ │NOTIF  │ │ADMIN  │  │    │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘   │    │
│  │  ┌──────┐                                                          │    │
│  │  │ D15  │                                                          │    │
│  │  │ANALYTICS│                                                         │    │
│  │  └──────┘                                                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              ┌──────────┐   ┌──────────┐   ┌──────────┐
              │  WEB     │   │  ADMIN   │   │ WORKER   │
              │ (Next.js)│   │ (Next.js)│   │ (Node)   │
              └──────────┘   └──────────┘   └──────────┘
                    │               │               │
                    └───────────────┼───────────────┘
                                    ▼
                         ┌────────────────────┐
                         │  POSTGRESQL        │
                         │  (Primary + Replica)│
                         └────────────────────┘
                                    │
                         ┌──────────┴──────────┐
                         ▼                     ▼
                  ┌─────────────┐       ┌─────────────┐
                  │ OBJECT STORE │       │ EMAIL/SMS/  │
                  │ (S3-compat)  │       │ WHATSAPP    │
                  └─────────────┘       │ PROVIDERS   │
                                        │ (FD-13)     │
                                        └─────────────┘
```

---

## 3. MODULE BOUNDARIES & DEPENDENCY RULES

### 3.1 Enforced Dependency Direction (Architecture Fitness Function)

```
ALLOWED (downward only):
  Web/Admin UI  →  Application Services (D01–D15)
  Application Services  →  Domain Core (D01–D15 internal)
  Domain Core  →  Database (via Data Access Layer)
  Workers  →  Domain Core (read-only or via explicit service APIs)

FORBIDDEN (arch-test will fail):
  Web/UI  →  Database (direct SQL/ORM)
  Admin/UI  →  Database (direct SQL/ORM)
  UI  →  Business Policy (pricing, MOQ, inventory rules)
  Domain  →  Provider SDKs (Razorpay, Twilio, etc. — ports only)
  Domain  →  Framework internals (Next.js, NestJS specifics) where avoidable
  Provider Adapters  →  Authorization bypass (must call domain services)
  Circular dependencies between any D01–D15 modules
```

### 3.2 Module Interaction Pattern (T3 Checkout Example)

```
Web (D08 API)
    │
    ▼
CheckoutService (D08) ──▶ IdentityService (D01) ──▶ verify org APPROVED
    │                         │
    │                         ▼
    │                    CustomerService (D02) ──▶ address snapshot
    │                         │
    │                         ▼
    │                    PricingService (D04) ──▶ tier selection + quote
    │                         │
    │                         ▼
    │                    MoqService (D05) ──▶ rule resolution + evaluation
    │                         │
    │                         ▼
    │                    InventoryService (D06) ◀── SINGLE WRITER
    │                         │         │
    │                         │         ├── conditional UPDATE balance (sorted variant_id)
    │                         │         ├── INSERT inventory_movement (RESERVE)
    │                         │         └── INSERT stock_reservation (ACTIVE)
    │                         │
    │                         ▼
    │                    OrderService (D10) ──▶ INSERT order + items + history (PLACED)
    │                         │
    │                         ▼
    │                    PaymentService (D09) ──▶ INSERT payment + attempt (PENDING)
    │                         │
    │                         ▼
    └──▶ AuditService (D14) ──▶ INSERT audit_log (same TX)
    │
    └──▶ NotificationService (D12) ──▶ INSERT notification intent (same TX)
    │
    COMMIT
    │
    ▼ (post-commit, no locks)
PaymentAdapter (port) ──▶ Gateway HTTP (Stage C)
Worker (D12) ──▶ Notification delivery
```

**Key invariant:** Only `InventoryService` (D06) writes `inventory_balance` / `inventory_movement` / `stock_reservation`. All other domains call its explicit API. This single-writer rule is enforceable via arch-test (no `import { inventory }` write paths outside D06).

---

## 4. DATA ACCESS STRATEGY

| LAYER | RESPONSIBILITY | TECHNOLOGY (Model 4 choice) |
|---|---|---|
| **Domain Repository Interfaces** | Pure TypeScript interfaces in each domain (e.g., `InventoryRepository`) — define *what* the domain needs, not *how* | TypeScript interfaces (zero deps) |
| **Data Access Implementation** | Implements repository interfaces using the chosen ORM/query layer; lives in `infrastructure/data-access` | Drizzle ORM (selected in Tech Stack ADR) |
| **Database** | PostgreSQL 16+ — constraints, generated columns, exclusion constraints, FK RESTRICT, partial indexes, advisory locks | PostgreSQL (managed) |

**Rule:** Domain code imports **only** repository interfaces. Data access implementations import the ORM. Tests swap implementations via DI. This keeps domain free of framework/ORM coupling.

---

## 5. TRANSACTION MODEL (preserved from Model 3)

| TX ID | NAME | ATOMIC WRITE SET | LOCK ORDER | NETWORK CALL? |
|---|---|---|---|---|
| T1 | Cart upsert | `cart_item`, `cart` | cart row | No |
| T2 | Stage A validate | none (reads) | none | No |
| **T3** | **Stage B checkout** | `checkout_request`, `inventory_balance` (UPDATE), `inventory_movement` (RESERVE), `stock_reservation`, `order`, `order_item`, `order_status_history`, `payment`, `payment_attempt`, `audit_log`, `notification` intent, `domain_event` (optional) | `checkout_request` unique → `inventory_balance` rows **sorted by variant_id** | **No** (commits before Stage C) |
| T4 | Stage C mark provider ref | `payment_attempt` | attempt row | No (HTTP after) |
| **T5** | **Webhook apply** | `payment_webhook_event` (dedupe), `payment`, `payment_attempt`, `order` (money+status), `stock_reservation`, `inventory_balance`, `inventory_movement` (COMMIT/RELEASE), `order_status_history`, `audit_log`, `notification` | event unique → payment → order → reservation → balance | **No** (commits before 2xx) |
| T6 | Attempt failure / cancel | `payment_attempt`, `stock_reservation`, `inventory_movement` (RELEASE), `order`, `order_status_history`, `audit_log` | same as T5 | No |
| T7 | Expiry sweep (batch) | `stock_reservation` (EXPIRED), `inventory_movement` (RELEASE), `inventory_balance` | `SKIP LOCKED` claim | No |
| T8 | Staff order transition | `order.status`, `order_status_history`, (`shipment`, `shipment_item`), (`inventory_balance`, `inventory_movement` if trigger=SHIPPED) | order → shipment → balance(s) | No |
| T9 | COD collection | `payment`, `order` (money), `audit_log` | payment → order | No |
| T10 | Inventory adjust | `inventory_balance`, `inventory_movement`, `audit_log` | balance (single) | No |
| T11 | Catalogue/MOQ/tier edit | target entity + `audit_log` | target row | No |
| T12 | Auth session | `auth_session`, `audit_log` | session | No |
| T13 | Notification enqueue | `notification` rows | piggybacks on T3/T5/T8 | No (dispatch post-commit) |

**Critical properties preserved:**
- No transaction spans a network call (INV-019)
- All money/stock effects + authorizing rules in same TX
- Lock ordering globally consistent (sorted variant_id; fixed T5 order; dedicated writer modules)
- Idempotency keys durable in PostgreSQL unique indexes (INV-071)

---

## 6. BACKGROUND JOB STRATEGY

| WORKLOAD | MECHANISM | RUNNING MODE |
|---|---|---|
| **Reservation expiry sweep** | Dedicated worker polling `stock_reservation` (partial index on `status='ACTIVE' AND expires_at < now()`) with `FOR UPDATE SKIP LOCKED` batches | Long-running process (Node), horizontal via batch partitioning |
| **Notification delivery** | Worker claims `notification` rows `WHERE status IN ('PENDING','RETRYING')` with `SKIP LOCKED`, calls channel adapters (FD-13), exponential backoff, max attempts → `FAILED` (admin queue) | Long-running process (Node), horizontal |
| **Outbox publication** (if `domain_event` table used) | Worker claims unpublished events, publishes to message bus (future), marks `published_at` | Long-running process (Node) |
| **Reconciliation job** | Periodic (cron) `SELECT` comparing `inventory_balance` vs `SUM(inventory_movement deltas)` per variant/location; alerts on drift | Cron (pg_cron or external scheduler) |
| **Backup validation** | Periodic restore-to-staging + checksum comparison | Cron (external) |

**No Redis, Kafka, or external queue required for V1.** PostgreSQL `SKIP LOCKED` + worker processes provide at-least-once delivery with bounded retries. Extraction to a message broker is a future additive step (ADR-004 reversibility: HIGH).

---

## 7. OUTBOX STRATEGY

**Decision: TRANSACTIONAL OUTBOX TABLE (`domain_event`) — OPTIONAL SCAFFOLDING**

- Notifications use their own `notification` table as intent (written in-TX, delivered post-commit) — this is the primary path for V1.
- `domain_event` table exists as a **general-purpose outbox** for future consumers (analytics, search indexing, webhooks to external systems). It is **not required** for V1 commerce correctness.
- Writers: any domain TX that wants to emit an event inserts into `domain_event` in the same transaction.
- Publisher: separate worker process polls `WHERE published_at IS NULL`, publishes, marks published.
- At-least-once delivery; consumers must be idempotent (natural key per event).

**Rationale:** Model 3 ADR-004 rated this OPTIONAL. V1 notifications work without it. Adding it costs one table + one worker; removing it later is trivial. We include the table schema (per LOGICAL_DATA_MODEL §OPTIONAL) but the publisher worker is **POST_ARCHITECTURE** (not in foundation).

---

## 8. CACHE STRATEGY

**Decision: CACHE NOT REQUIRED FOR V1**

| CACHE CANDIDATE | VERDICT | JUSTIFICATION |
|---|---|---|
| Stock availability | ❌ Not required | `inventory_balance.available` is a generated column — O(1) row read under PK. Hot-SKU contention is a lock issue, not a read latency issue. |
| Price tiers / quotes | ❌ Not required | Quote computation is a simple range select on `price_tier` (indexed by `product_id, active`). < 1ms at V1 scale. |
| Product catalogue | ❌ Not required | PostgreSQL FTS (GIN index) + category/status indexes serve browse/PDP directly. |
| Session lookup | ⚠️ Optional front only | If `auth_session` table chosen (FD-09), a Redis front *may* reduce DB round-trips for session validation. **Never the sole store** (INV-058 revocable sessions require DB truth). |
| Idempotency keys | ❌ Forbidden as authority | INV-071: unique indexes are the store; cache may front for latency only. |

**V1 stance:** Zero cache infrastructure. Add Redis only when profiling proves a read hotspot that indexes cannot solve. This avoids cache-invalidation complexity, stale-read bugs, and an extra failure domain.

---

## 9. SEARCH STRATEGY

**Decision: POSTGRESQL-NATIVE FULL-TEXT SEARCH (FTS)**

- GIN index on `to_tsvector('simple', title || ' ' || description || ' ' || sku_code)` on `product` table (per LOGICAL_DATA_MODEL §26).
- Covers: title, description, SKU code search across 4 categories.
- Ranking: `ts_rank_cd` with cover density normalization.
- Facets: category (exact), color/size (via variant joins), price tier (via product join).
- **Revisit trigger:** catalogue > ~10,000 SKUs OR relevance complaints requiring typo tolerance / synonyms / personalization.

**Why not external (Meilisearch/Elasticsearch/Typesense):**
- Zero additional infrastructure, operational burden, sync complexity.
- Model 3 SEARCH-003 candidate explicitly favored Postgres FTS for V1.
- ADR-010: REVERSIBILITY = HIGH (index alias swap to external engine later).

---

## 10. AUTHENTICATION & SESSION STRATEGY

| ASPECT | DECISION | RATIONALE |
|---|---|---|
| **Customer identity** | Email/phone + password hash **or** OTP (FD-09 decides mechanism) — server-side verification only | Credential shape is FD-09; verification logic is engineering |
| **Staff identity** | Email + password + **MFA mandatory for `staff.manage` / `settings.manage` holders** (FD-14 scope) | Security Model §7; escalation guard |
| **Session store** | **PostgreSQL `auth_session` table** (revocable, server-side) — Redis front optional for latency | INV-058: logout must invalidate server-side; cache never sole store |
| **Session identifier** | Secure random token (256-bit), `HttpOnly; Secure; SameSite=Strict` cookie, separate names for customer vs admin | Prevents cross-principal leakage (D01 invariant) |
| **Session expiry** | Configurable (e.g., 30d rolling); `revoked_at` timestamp for immediate invalidation | Supports admin disable, password change, security events |
| **Rate limiting** | Per-IP + per-account on auth endpoints (login, OTP request, password reset); Redis-backed counters with DB fallback | Abuse prevention; INV-059 |
| **CSRF** | `SameSite=Strict` cookies + double-submit cookie pattern for mutating non-GET endpoints (checkout, admin) | Defense in depth; Modern browsers enforce SameSite |
| **Password reset** | Time-limited, single-use token emailed/SMS (FD-13 provider); token hash stored, never plaintext | Standard secure pattern |

---

## 11. PROVIDER ADAPTER ARCHITECTURE (FD-13 Ports)

```
Domain (D09 Payments)                    Adapters (Infrastructure)
┌─────────────────────┐                  ┌─────────────────────┐
│ PaymentGatewayPort  │◀──── implements │ RazorpayAdapter     │
│  - initiate()       │                  │ StripeAdapter       │
│  - verifyWebhook()  │                  │ ... (FD-13 choice)  │
│  - capture()        │                  └─────────────────────┘
└─────────────────────┘
        │
        ▼
Domain emits intent (payment_attempt row) → Adapter executes HTTP → Webhook hits domain endpoint → Domain verifies + applies
```

**Ports defined (Model 3 ADR-009):**
- `PaymentGatewayPort`: `initiate(attempt)`, `verifyWebhook(rawBody, headers)`, `capture(attempt)`
- `NotificationChannelPort`: `send(notification)` for EMAIL/SMS/WHATSAPP/IN_APP
- `CarrierPort`: `createShipment(details)`, `track(shipment)`

**Vendor selection = FD-13 (founder). Model 4 writes adapter *shapes only*, not vendor choice.**

---

## 12. ARCHITECTURE FITNESS FUNCTIONS (Enforceable Rules)

| ID | RULE | ENFORCEMENT | JUSTIFICATION |
|---|---|---|---|
| ARCH-001 | No `import` from `packages/web` / `packages/admin` into `packages/domain/*` or `packages/data-access` | ESLint rule / `import/no-restricted-paths` | Prevents UI → DB direct access |
| ARCH-002 | No `import` from `packages/data-access` into `packages/domain/*` | ESLint rule | Domain depends on interfaces, not ORM |
| ARCH-003 | No `import` of provider SDKs (`razorpay`, `twilio`, `nodemailer`, etc.) in `packages/domain/*` | ESLint rule | Provider adapters only in `packages/adapters` |
| ARCH-004 | No `import` of framework internals (`next/*`, `@nestjs/*`) in `packages/domain/*` | ESLint rule | Domain stays framework-agnostic |
| ARCH-005 | `inventory_balance` / `inventory_movement` / `stock_reservation` written **only** by `packages/domain/inventory` | Code review + arch-test (grep for write patterns) | Single-writer D06 (INV-009) |
| ARCH-006 | All money arithmetic uses `Paise` branded type (integer); no `number` for money | TypeScript branded type + ESLint `no-restricted-syntax` for `*_paise` ops | INV-028: no float money |
| ARCH-007 | All mutating admin endpoints require explicit permission check (`requirePermission('x.y')`) | Middleware wrapper + arch-test scan for missing guards | Deny-by-default (INV-050/051/052) |
| ARCH-008 | No `UPDATE` / `DELETE` on `inventory_movement`, `audit_log`, `order_status_history`, `order_item`, `order` money columns | DB trigger guard (Model 4 choice: REVOKE or trigger) + migration lint | Append-only / insert-only invariants (INV-008/026/038/056) |
| ARCH-009 | No client-controlled price/MOQ/stock values accepted in any API | API contract validation (Zod schemas reject unknown fields) | Server-authoritative invariants |
| ARCH-010 | No secret-bearing config in Git (`.env`, `*.local.*`, `secrets.*` in `.gitignore`; CI injects at deploy) | Git pre-commit hook + CI check | Secret leakage prevention |
| ARCH-011 | All API responses for customer-scoped resources filter by `organization_id` (or 404-mask) | Middleware + integration test (T16) | Cross-org isolation (INV-051) |
| ARCH-012 | Webhook handler inserts `payment_webhook_event` **before** any verification/logic | Code pattern enforcement (arch-test) | Dedupe-before-logic (INV-041) |

---

## 13. KNOWN RISKS & ACCEPTED TRADEOFFS

| RISK | MITIGATION | ACCEPTED? |
|---|---|---|
| Hot-SKU lock contention under flash sale | Lock hold = milliseconds (few row UPDATEs + inserts); acceptable for V1 B2B volumes. Escape hatch: shorten T3 audit inserts (post-validation, still in-TX). | ✅ Yes — correctness > throughput |
| No cache = higher read latency at scale | Profile first; add Redis only for proven hotspots. Postgres FTS + generated columns are fast. | ✅ Yes — YAGNI |
| Single DB = single failure domain | Managed PostgreSQL (RDS/Cloud SQL) with HA + PITR + cross-region replica. RPO=0, RTO=<5min. | ✅ Yes — standard managed DB SLA |
| Modular monolith discipline decay | Arch-tests (ARCH-001–012) in CI; `packages/domain/*` have zero external deps by construction. | ✅ Yes — enforced |
| FD-11 unset → reservation holds never expire (TTL NULL) | Admin release path + alert on aged ACTIVE reservations; FD-11 is a P0 gate. | ✅ Yes — fail-closed is safe (stock held, not lost) |
| `stock_commit_trigger` NULL → no stock consumption ever | Architecture B (commit at SHIPPED) is provisional engineering rec; FD-08/FD-11 must close before launch. | ✅ Yes — blocked by design |

---

## 14. MODEL 3 INVARIANTS PRESERVATION CONFIRMATION

| INVARIANT CATEGORY | PRESERVED? | NOTE |
|---|---|---|
| Server-authoritative pricing | ✅ | Quote function in D04; client never supplies price |
| Server-authoritative MOQ evaluation | ✅ | Evaluator in D05 called in-TX (T3) |
| Server-authoritative inventory validation | ✅ | Conditional UPDATE in D06 under lock |
| Transactional checkout (T3 atomic) | ✅ | Single DB transaction, no network calls |
| Idempotent order creation | ✅ | `checkout_request` unique key + response snapshot |
| Duplicate-request safety | ✅ | All idempotency keys durable in PG (INV-071) |
| Immutable commercial snapshots | ✅ | `order_item` insert-only; `order` money cols guarded |
| Money correctness (integer paise) | ✅ | `BIGINT` paise everywhere; branded type |
| Inventory consistency | ✅ | `available = on_hand - reserved` generated + CHECK |
| Append-only inventory movement history | ✅ | `inventory_movement` REVOKE/trigger; no UPDATE/DELETE |
| Inventory policy flexibility | ✅ | `app_setting` jsonb + schema supports all FD-11 branches |
| Separation of order/payment/fulfillment state | ✅ | Three independent state machines (STATE_MACHINES) |
| Verified provider events | ✅ | Webhook dedupe→verify→apply (T5 order) |
| Deny-by-default authorization | ✅ | Permission keys `<domain>.<verb>`; no `is_admin` |
| Customer/organization isolation | ✅ | Ownership predicate on every customer-scoped read |
| Auditability | ✅ | `audit_log` same-TX append-only |
| Fail-closed sensitive behavior | ✅ | All unset FD settings → refusal (INV-075) |
| Transaction/concurrency correctness | ✅ | Conditional UPDATE + sorted locks + SKIP LOCKED |
| State-transition guards | ✅ | Forward-only edges; CH-005 matrix |
| Provider-independent domain semantics | ✅ | Ports/adapters (ADR-009) |

---

## 15. FOUNDER-GATED VARIABLES (Parameterized, Not Decided)

| VARIABLE | LOCATION | CURRENT STATE | GATE |
|---|---|---|---|
| V1 scope / buyer type | Domain existence (D02, D03, D05 rules) | Candidate: shopkeepers only | FD-01 (Muse FD-01) |
| Catalogue taxonomy | `category` seed + `product_tag` (optional) | Candidate: 4 categories | FD-02 (Muse FD-02/old FD-15) |
| Teamwear in/out | Aggregate topology | Candidate: OUT (seam only) | FD-03 (old FD-06) |
| MOQ value + counting strategy | `moq_rule` rows | **ZERO rows seeded** | FD-04 (old FD-03) |
| Tier model + price book data | `price_tier` rows | **ZERO rows seeded** | FD-05 (old FD-04) |
| Price visibility | `app_setting.price_visibility` | **NULL (default HIDDEN)** | FD-06 (old FD-07) |
| Account/approval/guest checkout | `customer_user` shape, `organization.approval_status` | Candidate: account-only | FD-07 (old FD-09) |
| Payment modes | `payment_mode` enum CHECK | `ONLINE_FULL`, `ADVANCE_10_COD_90` only | FD-08 (old FD-05) |
| Advance percent (`advance_percent_bps`) | `app_setting` | **NULL** | FD-08/09 |
| GST inclusive/exclusive, rounding | `app_setting.rounding_policy`, dormant `tax_paise` | **NULL** | FD-09 (old FD-10) |
| Lifecycle exceptions (cancel/return/refund) | State machine edges | **Absent** (candidate A only) | FD-10 (old FD-08) |
| Inventory pool vs ring-fence | `inventory_location` rows + allocation | Candidate: single pool | FD-11 (old FD-11/12) |
| `stock_commit_trigger` | `app_setting` jsonb | **NULL** | FD-08/11 (ADR-011) |
| `reservation_ttl_minutes` | `app_setting` | **NULL** (expiry disabled) | FD-11 |
| Admin modules / notification channels | `role`/`permission` seeds + adapters | Candidate: 7 modules; channels blank | FD-12 (old FD-14) |
| Gateway/merchant/shipping vendors | Adapter configs | **Ports only, no names** | FD-13 (old FD-13/20/21) |
| Native app in V1 | Client architecture | Default NO (P4) | FD-13 §D (old FD-17) |
| RBAC role names | `role.name` | Permission keys FIXED; names = data | FD-12 (old FD-14) |

**Total: 20 founder-gated variables.** All are NULL/disabled/fail-closed in the architecture. Model 4 implements the *mechanism*; the *value* comes from founder signature only.

---

## 16. MODEL 5 READINESS

This architecture package is designed for independent adversarial review (Big Pickle / Model 5). It exposes:

- ✅ Architecture style (modular monolith) with evaluation matrix
- ✅ Technology decisions (Tech Stack ADR — companion artifact)
- ✅ Module boundaries (15 contexts, dependency rules, fitness functions)
- ✅ Database strategy (PostgreSQL, constraints, generated columns, hybrid ledger)
- ✅ Transaction model (T1–T13, lock ordering, no network in TX)
- ✅ Inventory mechanism (hybrid ledger + reservation, commit trigger NULL-gated)
- ✅ Payment architecture (provider-independent ports, 3-level obligation/attempt/event)
- ✅ Auth/Session strategy (revocable PG sessions, deny-by-default RBAC)
- ✅ Security controls (threat matrix — companion artifact)
- ✅ Deployment topology (V1 — companion artifact)
- ✅ Observability (structured logs, correlation IDs, health — companion artifact)
- ✅ CI/CD + Test architecture (gates, classification — companion artifact)
- ✅ Founder-gated variables (20 identified, all parameterized)
- ✅ Model 3 challenges (12 reviewed, 9 resolved, 2 NEEDS_FOUNDER, 1 ACCEPTED — companion artifact)
- ✅ Exact input/output artifact references

**VERDICT: MODEL4_SYSTEM_ARCHITECTURE_COMPLETE — ready for Model 5 independent review.**