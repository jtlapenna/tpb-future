# Strategy: Stabilize V1 to Seed V2 (not wasted work)

This section explains **how to invest minimally in V1** in a way that **directly becomes V2’s backbone**. The goal is less firefighting now and zero throwaway work later.

---

## Guiding Principles
- **Stability-as-Asset:** Every fix must reduce support toil *and* become a V2 building block.
- **API‑First:** Stabilize contracts (OpenAPI/AsyncAPI), not screens. Clients should adapt to stable interfaces.
- **Identity‑Centric:** Prepare for **User Accounts** (consent, preferences) as the V2 spine.
- **Domain‑by‑Domain:** Products/Inventory first → Orders → Customers. Strangler pattern, not big‑bang.
- **Minimal CMS Spend:** Freeze Angular CMS; new admin capabilities land in a modern **Admin UI**.

---

## What to Stabilize Now (and why it seeds V2)

### 1) POS/CMS Sync Reliability (highest ROI)
**What:**
- Circuit breakers + exponential backoff on POS calls.
- Idempotent upserts with idempotency keys.
- Retry policies + dead‑letter/poison queues with operator replays.
- Per‑vendor adapter/mappers with unit tests by field.
- Structured logs + correlation IDs for each job.

**Why it seeds V2:**
- These become the **ingestion layer** for agent‑ready data and analytics.

---

### 2) API Error Handling & Versioning
**What:**
- Shared error code registry (machine + human readable).
- Consistent JSON error envelopes across repos.
- Additive **v1.1/v2** endpoints for new attributes (terpenes/effects, lab data).
- Integration tests that simulate upstream outages.

**Why it seeds V2:**
- Contracts, codes, and tests carry directly into V2 and external partner APIs.

---

### 3) Auth & Security Hygiene
**What:**
- Short‑lived access tokens + refresh tokens; rotate secrets.
- HTTP‑only secure cookies or in‑memory token handling (no LocalStorage).
- Document scopes/consents for future agent access.

**Why it seeds V2:**
- Establishes the **identity/consent model** required for User Accounts and agent handshakes.

---

### 4) Observability & CI/CD Hygiene
**What:**
- End‑to‑end tracing (trace IDs from request → job → DB write).
- Error budgets + SLOs for sync success rate/latency.
- Remove manual SSH steps; add automated security scans (deps & images).

**Why it seeds V2:**
- Gives the reliability substrate and regression safety net for new surfaces.

---

### 5) Data Enrichment (Products domain first)
**What:**
- Extend schema for terpenes/effects/lab results as **typed tables**, not generic JSON.
- Update import + CMS write paths; expose fields via additive APIs.
- Build validation scripts and backfill plan.

**Why it seeds V2:**
- Supplies the **feature data** for personalization, dashboards, and the Cannabis Agent API.

---

## What *Not* to Do (to avoid sunk cost)
- No feature work in **Angular CMS** (security patches only). Build new admin in modern stack.
- No deep refactors in **Vue 2**. Stand up a new front‑end and migrate surfaces.
- No premature microservices split. Stabilize within current Rails boundaries using modular domain services.

---

## Modernization That Pays Twice
- **New Front‑End (Next.js/React) for User Accounts**: auth, profiles, preferences, consent; add personalization next.
- **New Admin UI**: Products first (terpenes/effects), then Orders; aligns with domain‑first migration.

These unlock visible wins (dashboards, promos) and become the V2 shell.

---

## 30/60/90 Day Execution
**Day 0–30**
- Ship circuit breakers/retries + idempotency in POS sync.
- Define error code map + return envelopes; add outage simulation tests.
- Cut token lifetimes; move tokens to secure handling.
- Remove manual SSH from pipelines; enable audits (dependabot/audit tools).

**Day 31–60**
- Add poison queue + operator reprocess tools; correlation IDs in all logs.
- Extend schema for terpenes/effects; expose via v1.1 endpoints.
- Stand up Next.js shell + Auth; stub Accounts v1 (profile, preferences, consent).

**Day 61–90**
- Backfill enrichment where available; validation scripts live.
- Admin UI: Products domain MVP (create/edit with new attributes).
- Define API deprecation policy; publish OpenAPI.

---

## KPIs & SLOs (prove stabilization is working)
- **Sync Success Rate:** +X% (target 99% daily success).
- **Mean Time to Recovery (MTTR):** ↓ by Y% for sync incidents.
- **Support Hours / Week:** ↓ by Z% within 90 days.
- **Data Freshness Lag:** median mins from POS → catalog.
- **Accounts Adoption:** % of sessions with authenticated users (post‑launch).

---

## Governance & Scope Guardrails
- “**V2 Spine Only**”: if a task doesn’t reduce toil *and* carry into V2, it’s out.
- Feature flags, canary deploys, and rollback plans for every change.
- Weekly “stop‑doing” review: close or defer anything that drifts into parity rebuild.

---

## How This Becomes V2
- Stabilized sync → **ingestion service**.
- Error codes/contracts → **public/partner APIs**.
- Auth/consent → **User Accounts** & agent scopes.
- Enriched product schema → **Cannabis Agent API** & recommender features.
- Admin UI → replacement for CMS; domain‑first migration path.

**Result:** We spend once, benefit twice—**less chaos today, and the V2 core assembled piece by piece.**

