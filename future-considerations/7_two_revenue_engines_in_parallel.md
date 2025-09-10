# Two Revenue Engines in Parallel

Build durable income on **two tracks** that compound together: (A) **Outside Cannabis** via affiliate/content feeds that are agent‑ready, and (B) **Inside Cannabis** via Data SaaS + the Cannabis Agent API. Each has different time‑to‑cash and risk, but they share tech and content.

---

## Snapshot
- **Engine A – Affiliate/Content Feeds (Outside Cannabis)**  
  *Near‑term cashflow; evergreen niches; agent‑readiness baked in.*
  - Human‑readable SEO content **+ machine‑readable JSON feeds** per post/item.  
  - Niches (examples): **Longevity**, **Eco‑friendly home**, **Parenting/baby**, **LGBTQ+ lifestyle**.  
  - Monetize now via **affiliate** + ads; later via **feed/API licensing** to agent builders/retailers.

- **Engine B – Data SaaS + Cannabis Agent API (Inside Cannabis)**  
  *Moat + platform; slower to start, larger upside; strategic fit with TPB footprint.*
  - **Retail Data SaaS** (dashboards, insights, effects‑aware analytics).  
  - **Cannabis Agent API** (catalog + chemotype/effects + compliance + availability).  
  - Monetize via **SaaS**, **API subscriptions**, **brand/retailer plans**, and **data partnerships**.

---

## Monetization Ladders

### Engine A – Affiliate/Feeds
1) **Phase 1 (0–6m)**: SEO posts → affiliate links + ads; JSON feed output (schema.org/Product) published per post.  
2) **Phase 2 (6–12m)**: Bundle feeds into **niche catalogs**; sell **developer/agent access** (B2B/B2B2C).  
3) **Phase 3 (12–24m)**: Premium **curation** (e.g., longevity top‑picks), **sponsorships**, and **white‑label microfeeds** for retailers.

**Pricing ideas**  
- Affiliate/ads = market rate.  
- Feed/API = $99–$299/mo per niche for indie devs; $499–$2k/mo for retailers/platforms; usage tiers.

**Key KPIs**  
- Organic sessions, RPM, affiliate conversion rate.  
- # JSON feed consumers (agents/devs), API calls, licensing MRR.

---

### Engine B – Data SaaS + Agent API
1) **Phase 1 (0–6m)**: Retail **Data Dashboard** (freshness, stockouts, top effects); pilot with 2–3 stores.  
2) **Phase 2 (6–12m)**: Effects‑aware recs + **campaigns**; expose **v1.1 APIs** (catalog/availability/effects).  
3) **Phase 3 (12–24m)**: **Cannabis Agent API pilot** with brand + retailer; add event webhooks; partner SDKs.

**Pricing ideas**  
- Data SaaS = $299–$999/store/mo depending on modules.  
- Agent API = $0.001–$0.005/request (tiered) or $499–$3k/mo plan; brand analytics add‑ons.

**Key KPIs**  
- Store MAUs, campaign lift, agent‑assisted conversion %, API usage, partner count.

---

## Prioritization & Scoring (12–24 months)
Scored 1–5 (higher = better). Weights in parentheses.

| Stream | Time‑to‑Revenue (25%) | Profitability Potential (25%) | Defensibility (20%) | Strategic Fit w/TPB (20%) | Risk (‑10% if high) | **Weighted Score** |
|---|---:|---:|---:|---:|---:|---:|
| Affiliate Sites (existing 4 → 7+) | **5** | 3 | 2 | 3 | ‑1 | **3.4** |
| Agent‑Ready Feeds (licensing) | 3 | 4 | 3 | 3 | 0 | **3.3** |
| Retail Data SaaS (dashboards) | 3 | **5** | **4** | **5** | 0 | **4.2** |
| Cannabis Agent API | 2 | **5** | **5** | **5** | ‑1 | **4.1** |

**Interpretation**  
- **Quickest cash:** Affiliate Sites (keep pushing to hit ~$30k/mo across 7+ sites).  
- **Best overall ROI + moat:** **Retail Data SaaS** and **Agent API** (slower start, higher ceiling, deep TPB fit).  
- **Feeds licensing** grows as agent usage matures; bundle with affiliate content to lower CAC.

> Recommendation: **Run both engines**, but invest **most product/engineering** in Engine B while **content ops** drive Engine A.

---

## Shared Capabilities (one build, two revenues)
- **Content system**: n8n workflows output **HTML + JSON** per item/post.  
- **Contracts**: OpenAPI/AsyncAPI, error code registry, versioning (v1.1 → v2).  
- **Data foundation**: terpene/effects enrichment, COA parsing, dbt tests, freshness SLOs.  
- **Accounts**: identity/consent for recs, dashboards, and agent pairing.  
- **Telemetry**: event stream for attribution (human vs agent‑assisted).

---

## Execution Plan (first 12 months)
**Q1–Q2**  
- Engine A: Scale from 4 → 7 sites; enforce **JSON outputs**; standardize feed schemas.  
- Engine B: Ship **Data Dashboard v1**; expose **catalog v1.1**; begin brand COA ingestion.

**Q3**  
- Engine A: Launch **developer feed portal** (keys, docs, usage tiers).  
- Engine B: Effects‑aware recs + **campaigns** in Retailer Console; partner sandbox for APIs.

**Q4**  
- Engine A: First **feed licensing** deals; curated premium lists.  
- Engine B: **Agent API pilot** (brand + retailer); publish SDKs; event webhooks live.

---

## Risks & Mitigation
- **SEO volatility (A)**: Diversify niches; email capture; syndicate content; focus on evergreen.  
- **Data quality (B)**: Contracts + validation; human QA for low‑confidence items; provenance tracking.  
- **Compliance (B)**: Policy tables by state; automated checks; auditable logs.  
- **Market timing (A/B)**: Ship dashboards now; keep feeds agent‑ready so you’re first when demand spikes.

---

## Resourcing & Ownership
- **Engine A**: Content lead + automation (n8n) owner; monthly SEO/tech audits.  
- **Engine B**: Product/Eng lead for data + APIs; data engineer for dbt/COAs; AE for pilots.

---

## What “Good” Looks Like at 12–18 Months
- **Engine A**: 7–10 sites live; $15k–$30k/mo; 3–10 feed licensees; JSON outputs standardized.  
- **Engine B**: 10–40 stores on dashboards; 1–3 brand partners; Agent API pilot with measurable agent‑assisted uplift.

**Bottom line:** Engine A funds the transition; Engine B builds the moat. Together, they compound—and both are **agent‑ready** from day one.

