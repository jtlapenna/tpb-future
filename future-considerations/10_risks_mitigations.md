# Risks & Mitigations

A compact playbook to avoid the **“stripped bridge” trap**, keep customers happy via **reliability**, enforce **dependency/security automation**, and **test data integrity early**—while we assemble the V2 spine.

---

## 0) Risk Posture
- **Bias to reliability over scope.** Every change must reduce support toil or improve data quality; otherwise defer.
- **Proof gates each quarter.** Advance only if SLOs + data-quality bars are met.
- **Build once, monetize twice.** Shared contracts/data across TPB + affiliate feeds; fewer moving parts.

---

## 1) “Stripped Bridge” Product (Downgrade Risk)
**Risk**: A minimal interim product with *fewer* features than V1 feels like a downgrade, confuses customers, and increases churn.

**Mitigations**
- **No parity clone, no feature strip.** Replace *surfaces*, not value: migrate only the **core flows customers use** and prove equal/better reliability before sunset.
- **Guardrail KPIs before any cutover**:
  - Core flow success rate ≥ **99%** (browse → add to cart → checkout/hand-off).
  - Support tickets/store/week **↓ 30–50%** vs. V1 baseline.
  - NPS **≥ baseline** for migrated stores for 30 days.
- **Strangler pattern**: keep V1 running; route just **one domain at a time** (Products → Orders → Promotions) behind the new gateway.
- **Kill switch**: instant rollback to V1 per store; feature flags + canaries (5% → 25% → 100%).

---

## 2) Customer Happiness = Reliability First
**Risk**: Churn from intermittent sync failures, slow recoveries, and opaque incidents.

**Mitigations**
- **SLOs & Error Budgets**:
  - Sync success (daily) ≥ **99%**; median POS→catalog lag ≤ **15 min**.
  - Incident **MTTR** ↓ by **50%** via playbooks + runbooks.
- **Observability**: OpenTelemetry traces; correlation IDs from request → job → DB; red/amber dashboards by store & vendor.
- **Operational tooling**: Poison queue + replay; operator console for reprocessing; synthetic checks per store.
- **Proactive comms**: Status page, incident timelines, and RCA within 48h.

**Go/No‑Go for rollouts**
- Two weeks of green SLOs in a canary cohort **before** expanding.

---

## 3) Dependency & Security Drift
**Risk**: Aging dependencies, unpatched CVEs, ad‑hoc secrets, and brittle pipelines.

**Mitigations**
- **Automated Updates**: Renovate/Dependabot for npm/Ruby; weekly PR batch; semantic version gates.
- **Security Gates in CI**: SCA (deps), SAST (code), container scans (Trivy/Grype); block on **critical** findings.
- **SBOM & Provenance**: Generate **CycloneDX** SBOM per build; signed images; immutable tags.
- **Secrets & Auth**: Short‑lived tokens, httpOnly cookies; rotation schedule; 2FA for admins; use Secrets Manager/KMS.
- **Infra Hygiene**: No manual SSH; environment promotion; least‑privilege IAM; periodic pen-tests.

**Success Signals**
- Zero critical vulns at merge; time‑to‑patch criticals ≤ **72h**; pipelines fully reproducible.

---

## 4) Data Integrity (Test Early, Test Always)
**Risk**: Enrichment (terpenes/effects/COAs) introduces inconsistency; bad joins/mapping erode trust and downstream recs.

**Mitigations**
- **Contracts at Ingest**: JSON Schemas per source; strict validation → quarantine on violation.
- **dbt Tests**: not‑null/unique/accepted‑values/referential‑integrity; freshness rules; coverage dashboards by store/brand.
- **Provenance & Confidence**: Track source, timestamp, method (manual/COA/LLM), confidence score; surface low‑confidence to human QA.
- **Reconciliation**: Daily POS vs. catalog counts; deltas trigger alerts; backfill runbooks.
- **Golden Datasets**: Curated SKUs/batches used for regression checks and demo accuracy.

**Readiness Bars**
- Effects coverage ≥ **60–75%** of active SKUs; dbt test pass ≥ **90%**; COA recency within policy.

---

## 5) Scope Creep & Migration Debt
**Risk**: V2 swells into parity rebuild; endless migrations stall delivery.

**Mitigations**
- **V2‑spine checklist** only: accounts, contracts, ingestion, Admin UI (Products first). Everything else waits.
- **Hard WIP limits**: team can run only N concurrent epics.
- **Versioning Discipline**: v1.1 additive fields; deprecation timelines documented; generated clients.

---

## 6) Compliance & Policy Drift
**Risk**: State rules change; offers/recs violate limits; legal exposure.

**Mitigations**
- **Policy Engine**: versioned, dated rules per state; evaluated at recommendation time.
- **Pre‑flight Checks**: purchase caps, age/ID, contraindications.
- **Auditability**: consent receipts; immutable logs; quarterly legal review.

---

## 7) SEO/Market Timing (Affiliate Feeds)
**Risk**: Algorithm volatility delays outside‑cannabis revenue; agent‑feed demand slower than expected.

**Mitigations**
- Diversify niches; capture email; syndicate content; keep **JSON outputs** stable for agents; add B2B feed licensing to reduce SEO exposure.

---

## 8) Team Burnout
**Risk**: Sustained overwork stalls execution quality.

**Mitigations**
- Automate the repetitive (support, ETL, releases). 90‑minute **focus blocks**; weekly “stop‑doing” list; rotate on‑call; clear quarterly gates to celebrate wins.

---

## 9) Vendor/Platform Lock‑In
**Risk**: Over‑anchoring to a single cloud/tool limits leverage.

**Mitigations**
- Open standards (OpenAPI/AsyncAPI); exportable data; infra as code; choose services with clean exit paths.

---

## Quarterly Proof Gates (Examples)
- **Q1**: Sync SLOs met 2 consecutive weeks; zero critical CVEs at merge; dbt pass ≥ 85%; JSON feed validator green.
- **Q2**: Pairing consent ≥ 10%; effects coverage ≥ 60%; MTTR ↓ 50%; first feed licensee signed.
- **Q3**: AOV uplift ≥ 5% for consented users; dbt pass ≥ 90%; 2 brand COA integrations live.
- **Q4**: Agent API prototype used by ≥ 2 partners; dashboards weekly MAU growth; zero Sev‑1s in 30 days.

---

## Who Owns What (RACI snapshot)
- **Reliability & Observability**: Eng Lead (R), SRE (A), FE/BE devs (C), Ops (I)
- **Security & Dependencies**: Security/Platform (R/A), Eng Leads (C), All Devs (I)
- **Data Quality**: Data Eng (R), PM (A), Brand Ops (C), Support (I)
- **Compliance**: PM/Legal (R/A), Eng (C), Customer Success (I)

---

**Bottom line:** Avoid the downgrade trap by **replacing surfaces, not value**; keep customers happy through **measurable reliability**; let **automation** enforce security/dependencies; and make **data quality** a first‑class gate—so every step toward V2 is safe, defensible, and non‑wasteful.

