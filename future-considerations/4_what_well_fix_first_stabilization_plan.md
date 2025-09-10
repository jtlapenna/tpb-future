# What We’ll Fix First (Stabilization Plan)

A crisp, sequenced plan for the **minimum work** that cuts today’s fires and **directly becomes V2’s backbone**.

---

## Priority Map (why this order)
1) **POS/CMS Sync Reliability** → stops the biggest fires; becomes V2’s ingestion layer.  
2) **API Contracts & Error Handling** → makes failures predictable; unblocks additive data fields.  
3) **Auth & Security Hygiene** → reduces risk now; establishes consent/identity for accounts.  
4) **CI/CD & Observability** → fewer regressions; faster incident recovery.  
5) **Product Data Enrichment (terpenes/effects)** → unlocks personalization + Agent API.  
6) **API Versioning & Deprecation** → safe path to V2 without big‑bang.

> **Scope guardrail:** No new Angular CMS features, no deep Vue 2 refactors, no premature microservices.

---

## Fix #1 — POS/CMS Sync Reliability (Highest ROI)
**Goals**: Make ingestion **resilient, observable, and idempotent**.

**Actions**  
- Add **circuit breakers** and **exponential backoff** around all POS/vendor calls.  
- Make all writes **idempotent** (idempotency keys; safe retries).  
- Introduce **retry policies** + **dead‑letter/poison queue** with operator reprocess tools.  
- Refactor into **per‑vendor adapters/mappers** with unit tests per field.  
- Emit **structured logs** + **correlation IDs** across request → job → DB write.

**Definition of Done**  
- Sync success rate ≥ **99% daily**; median POS→catalog latency target set and met.  
- Runbook for reprocessing failures exists and is used.  
- Dashboards show per‑vendor error rates and time‑to‑recover.

**V2 Payoff**  
- These components become the **V2 ingestion service** for data + agents.

---

## Fix #2 — API Contracts & Error Handling (Cross‑Repo)
**Goals**: Standardize how we fail; make clients predictable.

**Actions**  
- Publish a **shared error code registry** (machine & human‑readable).  
- Return consistent **JSON error envelopes** from the API; map in FE/CMS interceptors.  
- Add **integration tests** that simulate upstream outages/timeouts.  
- Document **success/error contracts** per endpoint.

**Definition of Done**  
- All repos use the same codes; 1‑pager “error handling guide” checked into each repo.  
- CI includes outage simulation suite; new endpoints can’t merge without contracts.

**V2 Payoff**  
- Contracts/code map become the basis for **partner/public APIs** and agent integrations.

---

## Fix #3 — Auth & Security Hygiene
**Goals**: Reduce security risk and prep for **User Accounts**.

**Actions**  
- Move to **short‑lived access + refresh tokens**; rotate secrets.  
- Use **httpOnly secure cookies** or in‑memory storage (no LocalStorage).  
- Draft **consent scopes** for agent access (profile, preferences, purchase constraints).

**Definition of Done**  
- Token lifetime policy documented and enforced in CI.  
- Security scanning (deps/images) blocks critical vulns.  
- Consent scopes agreed for Accounts v1.

**V2 Payoff**  
- Establishes the identity/consent model for **accounts + agent handshake**.

---

## Fix #4 — CI/CD & Observability
**Goals**: Ship safely; see issues before customers do.

**Actions**  
- Remove **manual SSH** steps; deterministic deploys with environment promotion.  
- Add **Dependabot/Renovate** + audits (npm/bundle/image) to CI.  
- Implement **end‑to‑end tracing** (trace IDs across FE/BE/jobs); error budgets + SLOs for sync.

**Definition of Done**  
- Pipelines are no‑SSH; releases are tagged and traceable in Sentry/logs.  
- Dashboards show SLOs; alerts fire on breach.

**V2 Payoff**  
- Provides the reliability substrate for new FE/Admin UI and APIs.

---

## Fix #5 — Product Data Enrichment (Products Domain First)
**Goals**: Make the catalog **useful to people and agents**.

**Actions**  
- Extend schema with **terpenes/effects/lab results** as **typed tables**.  
- Update importers + CMS writes; expose via **additive API** fields.  
- Add **validation scripts** + backfill plan.

**Definition of Done**  
- New attributes available end‑to‑end (ingest → API → UI).  
- Basic search facets and **recommendations** unblocked.

**V2 Payoff**  
- Fuels **personalization, dashboards**, and the **Cannabis Agent API**.

---

## Fix #6 — API Versioning & Deprecation
**Goals**: Evolve without breaking; pave the road to V2.

**Actions**  
- Introduce **v1.1** (additive) and define criteria for **v2** endpoints.  
- Publish a clear **deprecation policy** and timeline.  
- Generate clients from **OpenAPI**; start **AsyncAPI** for events.

**Definition of Done**  
- New fields ship on v1.1; downstream clients adopt without breakage.  
- Deprecation policy linked in repos and customer docs.

**V2 Payoff**  
- Versioning lets us ship V2 services behind stable contracts.

---

## Timeline Snapshot (first 90 days)
- **Weeks 1–4:** Fix #1 + Fix #2 foundations; token policy/CI audits started.  
- **Weeks 5–8:** Poison queue + operator tools; tracing & SLO dashboards; start enrichment schema.  
- **Weeks 9–12:** v1.1 endpoints live; validation/backfill running; versioning + deprecation guide published.

---

## Success Metrics
- **Sync Success Rate ≥ 99%**; **MTTR ↓**; **support hours/week ↓**.  
- **Error budget adherence**; outage simulations pass in CI.  
- **New attributes in production** and consumed by at least one UI/API client.  
- **No critical vulns** at merge; **no manual SSH** in pipelines.

---

## Out‑of‑Scope (now)
- Angular CMS feature work (security patches only).  
- Deep refactors of Vue 2 app.  
- Full microservices split or big‑bang rewrites.

---

**Bottom line:** We fix the smallest set of things that collapses support drag **and** assembles the V2 spine—so every hour spent now pays twice.

