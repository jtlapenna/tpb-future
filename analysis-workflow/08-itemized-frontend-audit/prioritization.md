# Frontend Modernization Prioritization (Critical Path)

Guiding principle: Ship the shopper flow first (Browse → Product → Cart → Checkout), then expand to layouts, analytics, and PWA. Group work to minimize context switching and maximize reuse.

## Phase 0: Foundations ( unblock everything )
1) Build/Config → Vite, TypeScript, ESLint/Prettier, MUI theme, Tailwind optional (system: build, config)  
   - Blocks: all UI work
2) Router mapping → Next.js App Router, typed routes, nav helpers (router)  
   - Blocks: pages/components
3) HTTP client → typed axios/fetch + interceptors (api/http.js, urls.js)  
   - Blocks: API domains, data fetching
4) State setup → Redux Toolkit store + React Query (state/store.js)  
   - Blocks: products/cart/user slices

## Phase 1: Core Shopping Flow (MVP)
5) ProductCard + ProductImage (components)  
   - Reuse e-comm patterns; unlocks list/detail
6) Products List (pages/components: ScreenProducts)  
   - Filters, paging; depends on products API domain
7) Product Detail (ScreenProduct)  
   - Gallery/specs; depends on ProductCard/Image
8) Cart (ScreenCart + RTK cart slice)  
   - Port RTK cart; persistence
9) API domains: products, categories, brands (api)  
   - Server-state hooks and DTOs

## Phase 2: Checkout Unification (XL)
10) Checkout adapters (Blaze/Treez/Flowhub/Leaflogix/Shopify/Covasoft)  
    - Single flow + provider adapters; payment/validation
11) ActiveCart views (keep-shopping, created, thank-you)  
    - Session and timers; integrate with checkout

## Phase 3: Layouts, Discovery, Promotions
12) Home layouts consolidation → configurable layout system (ScreenHome*)  
    - M-L, multiple variants in one system
13) Featured / Effects-Uses / Brands (pages/components)  
    - Refactors with shared widgets

## Phase 4: Reliability, Analytics, PWA
14) Analytics SDK + event schema + instrumentation (analytics)  
    - Unified event model, batching
15) PWA/Offline → Workbox, background sync, cache (pwa)  
    - Replace custom SW; integrate with React Query
16) On-screen keyboard replacement (kiosk)  
    - Modern lib; kiosk ergonomics

## Phase 5: Cleanup & Low-Value Items
17) Move dev-only pages to admin; delete legacy (iframe, debug)  
18) Firebase functions/messaging: migrate or isolate to admin (firebase)

---

## Dependencies & Blockers
- Foundations (0) → prerequisite to Phases 1–5
- API domains (9) → needed by (6–8, 12–13)
- Checkout adapters (10) → depends on cart and API domains

## Suggested Sprinting (2-week sprints)
- Sprint 1: Phase 0 + 5–6  
- Sprint 2: 7–9  
- Sprint 3–4: 10–11  
- Sprint 5: 12–13  
- Sprint 6: 14–16  
- Sprint 7: 17–18

## Risk Notes
- Highest risk: Checkout adapters (XL), RFID/hardware abstractions if included later
- Mitigate by: contract-first adapter design, feature flags, dark-launch
