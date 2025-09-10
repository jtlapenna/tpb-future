# 12–24 Month Hybrid Roadmap (Quarter by Quarter)

A dual‑engine plan that sequences **quick wins → validation → scale** across (A) Affiliate/Feeds and (B) Data SaaS + Cannabis Agent API, while we stabilize V1 and assemble the V2 spine (accounts + data + contracts).

---

## Legend & Assumptions
- **Engine A**: Affiliate/Content Feeds (outside cannabis) → near‑term cash, agent‑ready JSON feeds.
- **Engine B**: Retail Data SaaS + Cannabis Agent API (inside cannabis) → defensibility + scale.
- **Platform**: Stabilization + V2 spine (POS sync, error handling, auth, observability, accounts, Admin UI).
- **Gates**: Each quarter has explicit **success criteria** to unlock the next phase.

---

## Year 1 — Quick Wins & Validation (Months 0–12)

### Q1 (Months 0–3)
**Platform**  
- POS/CMS sync: circuit breakers, retries, idempotency, poison queue.  
- API contracts: shared error code registry + outage simulation tests.  
- Security/CI: short‑lived tokens; remove manual SSH; enable dependency audits.

**Data Track**  
- Extend schema for **terpenes/effects**; stand up **dbt** with base models/tests.  
- Publish **v1.1 catalog** endpoints (additive fields) + 2 webhooks.

**Frontend & Accounts**  
- Next.js shell + **Auth + Profile + Preferences + Consent (MVP)**.

**Engine A**  
- Scale from **4 → 7 sites**; enforce **HTML + JSON** output per post (schema.org/Product).  
- Baseline SEO health (core vitals, indexation).

**Engine B**  
- **Retail Data Dashboard v1** (freshness, stockouts, top effects) to 2 pilot stores.

**Gates / KPIs**  
- Sync success ≥ **99% daily**; support hours ↓ 25%.  
- ≥ **40%** of active SKUs with effects populated.  
- 7 affiliate sites live; JSON feed validation passes.  
- 2 stores using dashboards weekly.

---

### Q2 (Months 4–6)
**Platform**  
- End‑to‑end tracing; correlation IDs across request → job → DB write.  
- Error budgets + SLO dashboards for sync.

**Data Track**  
- Brand/Lab feed spec; onboard first **COA** sources; provenance tracking.  
- Backfill high‑velocity SKUs; validation + reconciliation dashboards live.

**Frontend & Accounts**  
- **In‑store pairing** (QR/passkey) with **session consent**.

**Admin UI**  
- **Products domain MVP** (create/edit with new attributes).

**Engine A**  
- Content templates for top niches; **RPM** improvements; email capture.

**Engine B**  
- Add **effects‑aware facets** to dashboards; prepare partner sandbox for APIs.

**Gates / KPIs**  
- Median POS→catalog lag ≤ **15 min**.  
- ≥ **60%** of active SKUs with effects; ≥ **80%** dbt test pass rate.  
- 25% of in‑store sessions attempt pairing; 10% consent completion.  
- 3 stores on dashboards; NPS ≥ +20.

---

## Year 1–2 — Productization & Early Scale (Months 7–18)

### Q3 (Months 7–9)
**Platform**  
- Publish **OpenAPI** for catalog/availability; start **AsyncAPI** event contracts.

**Data Track**  
- Launch **effects‑aware recommendations API** (goal/budget/sensitivity).  
- Expand COA parsing; batch/lot lineage in model.

**Frontend & Accounts**  
- Personalization live (safer alternatives, budget‑aware recs).  
- Transparency receipts: “your agent used: preferences + budget.”

**Admin UI**  
- **Orders domain MVP**; role‑based access + audit trail.

**Engine A**  
- **Developer feed portal** (keys, docs, usage tiers) for 2 niches.

**Engine B**  
- **Campaigns** in Retailer Console (segments: new‑to‑store gentle edibles, sleep‑focused).  
- Partner sandbox open (mock data + SDK alpha).

**Gates / KPIs**  
- ≥ **75%** effects coverage; ≥ **90%** dbt pass.  
- Pairing attempt ≥ **40%**; consent ≥ **20%**; AOV +5% for consented users.  
- 5 stores on dashboards; 2 partner devs using portal.

---

### Q4 (Months 10–12)
**Platform**  
- Versioning/deprecation policy published (v1.1 additive → path to v2).

**Data Track**  
- Expand events (`inventory.updated`, `price.changed`, `batch.added`).

**Frontend & Accounts**  
- Household profiles; loyalty wallet (points/tiers) optional.

**Admin UI**  
- Promotions builder tied to segments; compliance guardrails enforced.

**Engine A**  
- First **feed licensing** deals (2–5 customers).  
- Curated premium lists for top niches.

**Engine B**  
- **Agent API prototype** behind feature flag with 1 brand + 1 retailer (non‑public).  
- SDK beta (JS) + webhook samples.

**Gates / KPIs**  
- ≥ **8–12** stores on dashboards; agent‑assisted conversion logging live.  
- ≥ **3** feed licensees; monthly API calls ≥ 50k (prototype partners).  
- Personalization uplift: AOV +8–12% for consented users.

---

## Year 2 — Scale & Partner Mode (Months 13–24)

### Q5 (Months 13–15)
**Platform**  
- Harden infra for multi‑tenant scale; rate limits; API analytics.

**Data Track**  
- Expand brand/lab network; COA coverage ≥ **70%** of active SKUs.

**Frontend & Accounts**  
- Deeper policy engine integration (state rules, purchase caps) at recommendation time.

**Admin UI**  
- Analytics tiles for agent‑assisted vs human‑assisted conversions; promo lift.

**Engine A**  
- 2–3 more niches; bundle pricing for multi‑niche access.

**Engine B**  
- **Agent API pilot** GA for select partners; add OAuth client management for agents.

**Gates / KPIs**  
- 15–25 stores on dashboards; 3–6 brand/retailer partners in pilot.  
- Monthly API calls ≥ **250k**; SLO adherence ≥ 99.9%.

---

### Q6 (Months 16–18)
**Platform**  
- Public **status page**; postmortem cadence; change management policy.

**Data Track**  
- Recommender v2 (re‑rank with outcomes/feedback); similarity search (pgvector) exposed.

**Frontend & Accounts**  
- Deeper personalization (location‑aware, time‑of‑day, tolerance learning).

**Admin UI**  
- Campaign experiments (A/B), budget pacing, multi‑store rollouts.

**Engine A**  
- 10+ licensees across niches; API usage tiers tuned.

**Engine B**  
- **Agent API** paid plans; partner marketplace page; reference integrations.

**Gates / KPIs**  
- ≥ **30–40** stores on dashboards; ≥ **5–10** paying API customers.  
- Agent‑assisted conversion rate tracked in 70% of participating stores.

---

### Q7–Q8 (Months 19–24)
**Focus: Scale & Moat**  
- Regional rollouts with multi‑store groups; data partnerships for outcomes.  
- Expand feeds and APIs into adjacent categories (CBD wellness, travel‑adjacent experiences) as fits.

**Targets**  
- **Engine A**: $15k–$30k/mo steady; 15+ licensees; 4–6 niches.  
- **Engine B**: 40–80 stores on dashboards; 10–20 paying API partners; monthly API calls ≥ **1M**.

---

## Risks & Pivots
- **SEO/Platform shifts (A)** → diversify niches, capture email, keep JSON outputs stable for agents.  
- **Data quality (B)** → provenance, QA queue, vendor SLAs; pause scale if dbt test rate < 90%.  
- **Compliance** → policy engine updates per state; legal review checkpoints each quarter.  
- **Partner timing** → keep dashboards delivering value even if API adoption lags.

---

## Operating Rhythm
- Monthly: KPI review, stop‑doing list, scope resets.  
- Quarterly: Gate review; advance only if prior gates cleared.  
- Always: Build once, monetize twice (shared content, data, contracts).

