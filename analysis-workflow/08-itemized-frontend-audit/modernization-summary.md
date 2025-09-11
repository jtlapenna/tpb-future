# Frontend Modernization Summary (Itemized Audit)

## Executive Overview
- Based on full inventory of pages, components, state, API, mixins, and system areas.
- Includes per-item actions (replace/port/refactor/delete), difficulty, and hour estimates (human vs AI).

## Totals & Hours
# Frontend Modernization Roll-up

## Totals by Category
| Category | Human Min | Human Max | AI Min | AI Max |
|---|---:|---:|---:|---:|
| analytics | 12 | 24 | 7 | 17 |
| api | 164 | 328 | 96 | 232 |
| assets | 4 | 8 | 2 | 6 |
| build | 36 | 72 | 21 | 51 |
| components | 404 | 768 | 237 | 542 |
| config | 12 | 24 | 7 | 17 |
| docker | 4 | 8 | 2 | 6 |
| firebase | 24 | 48 | 14 | 33 |
| hosting | 12 | 24 | 7 | 17 |
| kiosk | 12 | 24 | 7 | 17 |
| mixins | 100 | 200 | 58 | 142 |
| pages | 348 | 656 | 205 | 463 |
| pwa | 24 | 48 | 14 | 34 |
| router | 24 | 48 | 14 | 34 |
| state | 88 | 176 | 52 | 124 |
| styling | 32 | 64 | 19 | 45 |

## Overall Totals
- Human: 1300-2520 hours
- AI-assisted: 762-1780 hours

## Scoring & Estimation Rubric
# Scoring & Estimation Rubric

## Fields per Item
- category: pages | components | state | api | mixins | styling | build | router | analytics | firebase | pwa
- item: primary identifier (e.g., ScreenHome.vue)
- route (optional): for pages
- action: replace | port | refactor | delete
- complexity: S | M | L | XL
- difficulty: 1-5 (maps from complexity: S=2, M=3, L=4, XL=5; adjust as needed)
- human_min/human_max: hour range for human-only dev
- ai_min/ai_max: hour range with AI-assisted dev (0.6x-0.7x of human)
- risk: low | medium | high
- deps: key dependencies (state, API, POS, etc.)
- notes: clarifying context

## Complexity → Human Hours
- S: 4-8h
- M: 12-24h
- L: 32-64h
- XL: 80-120h

## AI Assistance Adjustment
- ai_min = human_min × 0.6
- ai_max = human_max × 0.7

## Prioritization (optional)
- priority = business_impact (1-5) × (risk_weight 0.5 + effort_weight 0.5) with lower effort favored
- Use tags: core-flow, kiosk-only, admin-only to batch scheduling

## Pages (selected)
| item | route | action | complexity | human_min | human_max | ai_min | ai_max | risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ScreenHome.vue | /  | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenBlank.vue | /blank | delete | S | 4 | 8 | 2 | 6 | low |
| ScreenDebugCache.vue | /debug-cache | delete | S | 4 | 8 | 2 | 6 | low |
| ScreenProducts.vue | /products/:categoryId | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenProducts.vue | /products | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenProductsPromotions.vue | /on-sale | replace | M | 12 | 24 | 7 | 17 | medium |
| ScreenProduct.vue | /product/:id | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenBrands.vue | /brands | refactor | M | 12 | 24 | 7 | 17 | medium |
| ScreenEffectsUses.vue | /effects-uses | refactor | M | 12 | 24 | 7 | 17 | medium |
| ScreenFeaturedProducts.vue | /featured-products | refactor | M | 12 | 24 | 7 | 17 | medium |
| ScreenCart.vue | /cart | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenCheckout.vue | /checkout | replace | XL | 80 | 120 | 48 | 84 | high |
| ScreenUploadEvents.vue | /analytics | refactor | M | 12 | 24 | 7 | 17 | low |
| ScreenIframeTest.vue | /iframe-test | delete | S | 4 | 8 | 2 | 6 | low |
| ActiveCartKeepShopping.vue | /active-cart/keep-shopping | refactor/port | M | 12 | 24 | 7 | 17 | medium |
| ActiveCartCheckoutCompleted.vue | /active-cart/created | refactor/port | M | 12 | 24 | 7 | 17 | medium |
| ThankYouOrderCompleted.vue | /thank-you | refactor/port | M | 12 | 24 | 7 | 17 | medium |

## Components (selected)
| item | action | complexity | human_min | human_max | ai_min | ai_max | risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ScreenHome.vue | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenHome* variants | refactor to layout system | M-L | 24 | 48 | 14 | 33 | medium |
| ScreenProducts.vue | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenProduct.vue | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenCart.vue | replace | L | 32 | 64 | 19 | 45 | medium |
| ScreenCheckout* (Blaze/Treez/Flowhub/Leaflogix/Shopify/Covasoft) | replace via provider adapters | XL | 80 | 120 | 48 | 84 | high |
| ScreenFeaturedProducts.vue | refactor | M | 12 | 24 | 7 | 17 | low |
| ScreenEffectsUses.vue | refactor | M | 12 | 24 | 7 | 17 | low |
| ScreenBrands.vue | refactor | M | 12 | 24 | 7 | 17 | medium |
| ScreenUploadEvents.vue | refactor | M | 12 | 24 | 7 | 17 | low |
| ScreenIframeTest.vue | delete | S | 4 | 8 | 2 | 6 | low |
| ProductCard.vue | replace (port from React e-comm) | M | 12 | 24 | 7 | 17 | low |
| ProductImage.vue | replace | M | 12 | 24 | 7 | 17 | low |
| ProductGraphs.vue | refactor | M | 12 | 24 | 7 | 17 | low |
| Slider.vue | replace | M | 12 | 24 | 7 | 17 | low |
| Spinner.vue | replace | S | 4 | 8 | 2 | 6 | low |
| ModalTemplate.vue | replace | M | 12 | 24 | 7 | 17 | low |
| LottieContainer.vue | port | S | 4 | 8 | 2 | 6 | low |
| ShareButton.vue | refactor | S | 4 | 8 | 2 | 6 | low |
| ActiveCart* components | refactor/port | M | 12 | 24 | 7 | 17 | medium |
| TheSidebar.vue | replace | M | 12 | 24 | 7 | 17 | low |
| TheNav.vue | replace | M | 12 | 24 | 7 | 17 | low |
| TheBrandSlideshow.vue | refactor | M | 12 | 24 | 7 | 17 | low |

## State
| item | action | complexity | human_min | human_max | ai_min | ai_max |
| --- | --- | --- | --- | --- | --- | --- |
| store.js | replace | M | 12 | 24 | 7 | 17 |
| modules/cart.js | replace (port RTK cart) | L | 32 | 64 | 19 | 45 |
| modules/products.js | replace | L | 32 | 64 | 19 | 45 |
| user slice (new) | port | M | 12 | 24 | 7 | 17 |

## API Domains
| item | action | complexity | human_min | human_max | ai_min | ai_max | risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| api/http.js | replace | M | 12 | 24 | 7 | 17 | medium |
| api/urls.js | replace | S | 4 | 8 | 2 | 6 | low |
| LocalRepo/RemoteRepo/repo.js | replace | M | 12 | 24 | 7 | 17 | medium |
| db.js/dbconfig.js | refactor | M | 12 | 24 | 7 | 17 | medium |
| products domain | replace | L | 32 | 64 | 19 | 45 | medium |
| categories domain | replace | M | 12 | 24 | 7 | 17 | low |
| brands domain | replace | M | 12 | 24 | 7 | 17 | low |
| feature-tags domain | replace | M | 12 | 24 | 7 | 17 | low |
| articles domain | refactor | M | 12 | 24 | 7 | 17 | low |
| rfid domain | refactor/port | L | 32 | 64 | 19 | 45 | high |
| messaging (fb) | refactor | M | 12 | 24 | 7 | 17 | medium |

## Mixins & Plugins
| item | action | complexity | human_min | human_max | ai_min | ai_max |
| --- | --- | --- | --- | --- | --- | --- |
| MergeConfig.js | refactor | M | 12 | 24 | 7 | 17 |
| isCardWithAttributes.js | refactor | S | 4 | 8 | 2 | 6 |
| HasShopify.js | refactor | M | 12 | 24 | 7 | 17 |
| HasProductsPaginated.js | replace | M | 12 | 24 | 7 | 17 |
| redirectEvent.js | refactor | S | 4 | 8 | 2 | 6 |
| keyboardEvents.js | replace | M | 12 | 24 | 7 | 17 |
| offlineMixin.js | replace | L | 32 | 64 | 19 | 45 |
| aeropayEvent.js | refactor | M | 12 | 24 | 7 | 17 |

## System Areas
| category | item | action | complexity | human_min | human_max | ai_min | ai_max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| styling | SCSS -> MUI/Tailwind | replace | L | 32 | 64 | 19 | 45 |
| assets | Fonts/Images/SVGs | refactor | S | 4 | 8 | 2 | 6 |
| build | Webpack 3.x -> Vite | replace | L | 32 | 64 | 19 | 45 |
| build | Babel/PostCSS configs | replace | S | 4 | 8 | 2 | 6 |
| hosting | Firebase hosting config | refactor | M | 12 | 24 | 7 | 17 |
| docker | Dockerfiles | refactor | S | 4 | 8 | 2 | 6 |
| router | Route mapping to Next.js | replace | M | 12 | 24 | 7 | 17 |
| router | Nav helpers/guards | refactor | M | 12 | 24 | 7 | 17 |
| analytics | SDK + schema | replace/refactor | M | 12 | 24 | 7 | 17 |
| config | globals -> typed config | replace | M | 12 | 24 | 7 | 17 |
| firebase | Functions/messaging | refactor/replace | M-L | 24 | 48 | 14 | 33 |
| pwa | Service worker -> Workbox | replace | M | 12 | 24 | 7 | 17 |
| pwa | Background sync + uploads | refactor | M | 12 | 24 | 7 | 17 |
| kiosk | On-screen keyboard | replace | M | 12 | 24 | 7 | 17 |

## Prioritization (Critical Path)
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
