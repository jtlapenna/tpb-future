# Data Track: Enrich → Normalize → Expose

Turn 8+ years of product + behavior data into the **engine** for personalization, dashboards, and the Cannabis Agent API.

---

## Why This Matters
- **Agents prefer structured truth.** Rich, consistent product data + clean events make us the vertical intelligence layer.
- **Retail value today.** Dashboards and recommendations drive lift before agents are mainstream.
- **V2 backbone.** A stable data model + contracts avoid rework and unlock scalable APIs.

---

## ENRICH — Add the Missing Meaning
**Goal:** Capture modern attributes that power relevance and safety.

**What to add**
- **Chemotype & Effects:** Primary/secondary terpenes, dominant cannabinoids, expected effects (calming, focus, sleep), onset/duration.
- **Lab & Safety:** COAs (potency, contaminants), batch/lot metadata, test dates, lab brand.
- **Form & Dose:** Form factor (flower, edible, tincture), dosage per serving, total dosage, units.
- **Compliance & Availability:** Age/state constraints, purchase limits, store‑level stock & price history.
- **Merch & Marketing:** Brand, lineage, tags (organic, solventless), images/assets.

**Sources & Ingestion**
- **POS → CMS:** Extend import mappers for new attributes (additive, optional).
- **Brand/Lab Feeds:** Accept CSV/JSON/S3 drops; parse COAs; auto‑link by GTIN/SKU/batch.
- **Manual QA via Admin UI:** Products domain interface for missing/override fields.

**Backfill Strategy**
- Partner outreach for historical COAs; parse PDFs to structured fields.
- Heuristics/LLM assist to assign likely effects from terpene profiles (flag low confidence for review).
- Track **data provenance** (source, timestamp, confidence) on every attribute.

**Deliverables**
- Extended product schema (typed fields, not generic JSON) and import specs.
- Brand/Lab feed spec + sample files.
- Enrichment runbook (backfill + QA workflow).

---

## NORMALIZE — Make It Consistent & Reliable
**Goal:** A canonical, queryable model with strong data contracts and quality gates.

**Canonical Model (Products domain first)**
- `product` (immutable identity)  
- `product_variant` (size, form, dose)  
- `batch` (COA, test results, dates)  
- `chemotype` (terpenes %, cannabinoids %)  
- `effects` (normalized labels + confidence)  
- `inventory_price` (store, price, availability, effective_at)  
- `media_asset` (images, docs, COA files)

**IDs & Matching**
- Prefer **GTIN/SKU/batch**; fall back to deterministic fuzzy match with review queue.
- Maintain **surrogate keys** and **SCD‑2** for slowly changing attributes (history preserved).

**Quality Gates**
- **Contracts:** JSON Schemas for inbound feeds; reject/park on violation.
- **Tests:** Not Null/Unique/Accepted Values/Referential integrity (dbt tests).  
- **Freshness SLAs:** POS→catalog median lag; COA recency checks.
- **Reconciliation:** Daily counts by store/brand/variant vs. POS.

**Privacy & Consent**
- PII/PHI minimization; separate subject tables from behavior.  
- **Consent ledger** tied to User Accounts for any agent‑visible personalization.

**Deliverables**
- Canonical ERD + data dictionary.  
- dbt project with models, tests, and freshness rules.  
- Validation scripts + reconciliation dashboards.

---

## EXPOSE — Make It Useful to People and Agents
**Goal:** Controlled, well‑documented interfaces for UIs, partners, and agents.

**APIs (OpenAPI)**
- **Catalog:** products, variants, chemotype/effects, images.  
- **Availability:** store inventory, price, purchase limits.  
- **Compliance:** state rules, age checks, policy flags.  
- **Recommendations:** query by goal (sleep, calm), budget, sensitivity.

**Events (AsyncAPI/Webhooks)**
- `inventory.updated`, `price.changed`, `batch.added`, `product.deprecated`, `promotion.created`, `cart.session.started`.

**Search & Retrieval**
- Text + faceted search (form, effects, terpenes).  
- Embedding index (pgvector) for similarity (“like this, but gentler”).

**Dashboards (Retail Data SaaS)**
- Product performance by effect/chemotype.  
- Agent‑assisted vs human‑assisted conversions.  
- Stockouts, pricing elasticity, promo lift.

**Feeds for Agents (Outside Cannabis)**
- For affiliate niches: publish **HTML + JSON** per item/post; align to **schema.org/Product**; include canonical links + affiliate IDs.

**Contracts & Governance**
- Versioned endpoints (v1.1 additive → v2).  
- Rate limits, auth scopes, error code registry.  
- Changelog + deprecation timelines.

**Deliverables**
- Public OpenAPI/AsyncAPI docs + SDKs.  
- Reference queries/snippets; example webhooks; test sandboxes.

---

## 0–90–180 Day Plan
**0–90 days**  
- Extend schema; implement POS mapper changes (optional additive fields).  
- Stand up dbt with base models/tests; create reconciliation dashboard.  
- Ship v1.1 catalog endpoints with new attributes; add two webhooks.  
- Pilot dashboard tiles (freshness, stockouts, top effects).

**90–180 days**  
- Onboard 1–2 brand/lab feeds; parse COAs; backfill priority SKUs.  
- Launch effects‑aware recommendations API; enable basic agent query patterns.  
- Expand AsyncAPI events; add partner sandbox; publish SDKs.  
- Begin Cannabis Agent API pilot with a willing store/brand.

---

## KPIs
- **Coverage:** % of active SKUs with terpene/effects populated.  
- **Freshness:** median POS→catalog lag (mins).  
- **Quality:** dbt test pass rate; rejected feed %; reconciliation diffs.  
- **Adoption:** # of API consumers; dashboard MAUs; webhook deliveries.  
- **Impact:** agent‑assisted conversion rate; uplift in AOV for effects‑matched baskets.

---

## Risks & Mitigation
- **COA variability:** Normalize via adapters; keep provenance; human review queue.  
- **Matching ambiguity:** Confidence scores + review tooling; avoid silent merges.  
- **Compliance drift:** Policy tables by state with dated entries; tests enforce.
- **Partner fragility:** Webhook retries + dead letters; sandbox contracts.

---

## Tech Notes (aligns with our stack choices)
- Warehouse & transforms: **dbt + Snowflake/BigQuery**; raw lake on S3.  
- OLTP: **Postgres** with typed tables; **pgvector** for similarity search.  
- Contracts: **OpenAPI/AsyncAPI**; JSON Schemas in a schema repo.  
- Observability: lineage in dbt, traces/logs with IDs; SLOs for freshness.

---

**Bottom line:** Enrich the facts, normalize the truth, and expose it with contracts. That turns our data from a byproduct into the **product** that powers V2, the Cannabis Agent API, and agent‑ready affiliate feeds.

