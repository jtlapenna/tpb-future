# User Accounts as the Foundation

User accounts aren’t a feature—they’re the **spine of V2**. They provide identity, consent, preferences, and history that connect **humans ↔ store systems ↔ personal AI agents**. Accounts let us personalize safely today and become the **agent handshake** tomorrow.

---

## Why Accounts, Why Now
- **Identity & Consent**: Agents require a trusted identity and explicit permissions. Accounts provide both.
- **Personalization That Matters**: Effects‑aware recommendations, safer alternatives, budget rules, and loyalty.
- **Retailer Value Fast**: Dashboards by segment, targeted promotions, and attribution (agent‑assisted vs human‑assisted).
- **Architectural Wedge**: Rebuilding the front end for accounts forces a modern, maintainable surface without a risky full rewrite.

---

## What Accounts Must Contain (MVP → V2)
**MVP (first ship)**
- **AuthN/Z**: OIDC/OAuth2 with passkeys/WebAuthn; short‑lived access + refresh tokens (httpOnly cookies).
- **Profile**: Name (optional), contact (optional), store preference, language.
- **Preferences**: Effects goals (sleep/calm/focus), disliked effects, dosage sensitivity, budget.
- **Consent Ledger**: Fine‑grained scopes (e.g., `profile.read`, `preferences.read`, `inventory.view`, `offers.receive`, `events.share_aggregated`). Timestamped, revocable.
- **History (PII‑lite)**: Recent in‑store sessions (aggregated), saved lists, red‑flagged products.

**V2 (after MVP stability)**
- **Loyalty & Rewards**: Points, tiers, perks; wallet integration.
- **Agent Links**: OAuth client credentials for personal agents; device pairing keys (QR/NFC/passkey) with session scoping.
- **Household/Shared Profiles**: Optional sub‑profiles; parental controls.
- **Privacy Toolbox**: Data export, delete, scope review, transparency receipts (“your agent used: effects + budget”).

---

## In‑Store Pairing & Session Flow
1) Shopper taps **Pair Agent** on a TPB display → QR/passkey prompt.
2) Shopper approves **session consent** (what data is shared, for how long, for what purpose).
3) **Store agent** (our system) exchanges context with **personal agent**: inventory, effects, contraindications, budget.
4) Display surfaces human‑readable recs; agent updates plan/cart; retailer attribution recorded.
5) Session auto‑expires; shopper can revoke anytime from account.

---

## Retailer Console & Use Cases (Enabled by Accounts)
- **Segments & Campaigns**: “New‑to‑store gentle edibles”, “Sleep‑focused, low‑dose”.
- **Personalized Offers**: Per‑segment promotions visible **on displays** and **inside agents**.
- **Attribution**: Which conversions were agent‑assisted? What’s the uplift vs. control?
- **Compliance Guardrails**: State‑aware purchase limits and eligibility baked into offers.

---

## Architecture Blueprint
- **Accounts Service** (Next.js/React front end; API behind gateway).
- **Identity Provider** (Auth0/Cognito) with **passkeys** and OIDC.
- **Consent Ledger** (append‑only store with scope records, reason, TTL).
- **Preference Store** (typed tables for effects, dose, budget; provenance/updated_at).
- **Policy Engine** (state rules, purchase limits; evaluated per request/session).
- **Events Bus** (session started/ended, offer viewed, rec accepted) with webhooks for retailer systems.
- **Audit & Privacy** (access logs, export/delete flows, consent receipts).

> Design contracts first: OpenAPI for REST, AsyncAPI for events; generate clients for FE/Admin/partners.

---

## Sequencing & Scope (6–12 Months)
**0–90 days**
- Stand up **modern front end** shell (Next.js/React + TS).  
- Implement **Auth + Profile + Preferences + Consent** (MVP).  
- Add **Pair Agent** flow (QR/passkey) with **session‑scoped consent**.

**90–180 days**
- Ship **personalized recs/deals** powered by enriched product data.  
- Launch **Retailer Console v1** (segments, simple campaigns, attribution).  
- Add **Agent Links** (OAuth clients) + transparency receipts; expand privacy tools.

**180–270 days**
- Loyalty wallet, household profiles, deeper policy engine hooks.  
- Harden Admin UI; expand effects‑aware analytics.

---

## KPIs (to prove it’s working)
- **Account Penetration**: % sessions with logged‑in users (target + month‑over‑month growth).
- **Consent Rate**: % of users granting pairing scopes in‑store; revocation rate.
- **Personalization Uplift**: AOV + conversion lift for consented users vs. baseline.
- **Time‑to‑Basket**: Reduced minutes when agent is paired.
- **Retailer Adoption**: # of active campaigns; attribution completeness.

---

## Guardrails & Risk Mitigation
- **Friction**: Use passkeys; minimize required fields; progressive profiling.
- **Privacy**: Default‑deny scopes, short TTLs, easy revocation; plain‑language consent.
- **Security**: No tokens in LocalStorage; rotate secrets; scoped OAuth for agents.
- **Compliance**: State‑aware policy engine; age/ID checks; audit trails.
- **Support Load**: Self‑serve account tools; clear error messaging; analytics for drop‑offs.

---

## Why This is the Foundation of V2
- Accounts create the **identity + consent** layer agents require.  
- Preferences/history power **personalization** and safer suggestions at the display.  
- The same contracts and scopes enable the **Cannabis Agent API** and future third‑party integrations.  
- Building accounts forces the **modern FE + Admin UI** that V2 needs—without a full rewrite.

**Bottom line:** Ship accounts early and everything else lines up—personalization, agent pairing, dashboards, APIs. This is the most leveraged investment we can make for both short‑term value and long‑term defensibility.

