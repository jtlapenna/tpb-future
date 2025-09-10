# Target Architecture (Appendix)

A single‑page view of the V2 platform. Admin UI replaces the legacy CMS; an API Gateway fronts modular **domain services**; data layers separate OLTP, search/cache, and analytics; **cross‑cutting** concerns (auth, observability, config) span everything. Built to be agent‑ready from day one.

---

## 1) One‑Page Diagram

```mermaid
flowchart LR
  subgraph Clients
    ShopperApp[Shopper Web/App]
    Displays[In‑Store Displays]
    AdminUI[Admin UI (replaces CMS)]
    Partners[Partner Apps & Personal Agents]
  end

  ShopperApp --> APIGW
  Displays --> APIGW
  AdminUI --> APIGW
  Partners --> APIGW

  subgraph Platform Edge
    APIGW[API Gateway\nRouting • AuthZ • Rate Limit • Caching\nOpenAPI/AsyncAPI]
    IdP[Identity Provider\nOIDC/OAuth2 • Passkeys]
    APIGW --- IdP
  end

  APIGW --> Products
  APIGW --> Inventory
  APIGW --> Orders
  APIGW --> Accounts
  APIGW --> Promotions
  APIGW --> Compliance
  APIGW --> Telemetry

  subgraph Domain Services
    Products[Products Service\nCatalog • Chemotype/Effects]
    Inventory[Inventory & Pricing]
    Orders[Orders & Checkout]
    Accounts[User Accounts & Consent]
    Promotions[Campaigns & Offers]
    Compliance[Policy Engine\n(State rules, limits)]
    Telemetry[Events & Analytics]
  end

  Products -->|CRUD/Queries| OLTP[(Postgres OLTP\npgvector)]
  Inventory --> OLTP
  Orders --> OLTP
  Accounts --> OLTP
  Promotions --> OLTP
  Compliance --> OLTP

  Products --> Cache[Redis Cache]
  Inventory --> Cache
  Orders --> Cache
  Promotions --> Cache

  Products --> Search[OpenSearch / Facets]
  Inventory --> Search

  Telemetry --> Bus[(Event Bus/Webhooks)]
  Bus --> Lake[S3 Data Lake (raw JSON/COAs)]
  Lake --> DWH[Warehouse (Snowflake/BigQuery)\ndbt models + tests]

  subgraph External Interfaces
    Webhooks[Partner Webhooks]
    SDKs[Partner SDKs]
  end
  Bus --> Webhooks
  APIGW --> SDKs
```

---

## 2) Components at a Glance
- **Admin UI (replaces CMS):** Modern app for products, orders, campaigns, permissions, analytics. No new features land in the legacy CMS.
- **API Gateway:** Single entry point for REST/events; authZ, rate limiting, caching, request/response normalization; publishes **OpenAPI/AsyncAPI** contracts and versioning/deprecation timelines.
- **Domain Services (modular, not microservices):** Encapsulated modules inside Rails (or split gradually):
  - **Products:** Catalog; terpenes/effects/chemotype; COA attachments; media.
  - **Inventory & Pricing:** Store‑level availability, price history, purchase limits.
  - **Orders & Checkout:** Baskets, reservations, substitutions, pick‑up ETA.
  - **Accounts & Consent:** Profiles, preferences, scopes/ledgers, loyalty, pairing.
  - **Promotions & Campaigns:** Segments, offers, A/B tests, attribution.
  - **Compliance/Policy Engine:** State rules, age/ID, dosage caps; evaluated per request.
  - **Telemetry:** Event capture (display interactions, agent pairing, rec acceptance) and outbound webhooks.
- **Data Layers:**
  - **OLTP (Postgres + pgvector):** Source of truth; typed tables (no generic JSON for core attributes).
  - **Cache/Search (Redis + OpenSearch):** Speed for hot reads and faceting.
  - **Lake/Warehouse (S3 + Snowflake/BigQuery + dbt):** Analytics, ML features; lineage and tests.

---

## 3) Agent‑Readiness
- **Identity & Consent:** OIDC/OAuth2 with **passkeys**; fine‑grained scopes for personal agents; session‑scoped pairing flows (QR/NFC).
- **Contracts:** Versioned **OpenAPI** (catalog, availability, compliance, recs) and **AsyncAPI** (inventory.updated, price.changed, batch.added, promotion.created, cart.session.started). Client SDKs auto‑generated.
- **Explainability:** Responses include rationale tokens (e.g., effects/chemotype basis) for agents to summarize to users.

---

## 4) Cross‑Cutting Concerns
- **Observability:** OpenTelemetry tracing; Sentry; correlation IDs across request → job → DB write; SLOs for sync and API latency.
- **Security:** Short‑lived tokens; httpOnly cookies; secret rotation; rate limits; least‑privilege roles; audit trails.
- **Configuration:** Feature flags for canaries/gradual rollout; environment promotion; blue/green deploys.
- **Compliance:** Policy tables with dated entries by state; consent receipts; PII minimization.

---

## 5) Migration Stance (Strangler Pattern)
- Keep the current Rails app, **modularize by domain**, and expose via the **Gateway**. Replace Angular CMS with **Admin UI** domain by domain (Products → Orders → Promotions). Move ingest/sync to event‑driven with retries/idempotency. Introduce v1.1 additive fields, then v2 endpoints.

---

## 6) Minimal Tech Choices (consistent with our stack)
- **Edge:** API Gateway (AWS API Gateway or NGINX + Kong) + IdP (Auth0/Cognito) with WebAuthn/passkeys.
- **Core:** Rails + Sidekiq; Postgres (RDS) + pgvector; Redis; OpenSearch.
- **Data:** S3 lake; Snowflake/BigQuery + **dbt** for models/tests; Airbyte/Meltano for brand/lab feeds.
- **FE:** Next.js/React + TS; shared component library across Shopper App & Admin UI.

---

**Bottom line:** One gateway, clear domains, typed data, and versioned contracts—so we can stabilize V1, ship accounts and dashboards, and plug directly into the agent economy without a big‑bang rewrite.

