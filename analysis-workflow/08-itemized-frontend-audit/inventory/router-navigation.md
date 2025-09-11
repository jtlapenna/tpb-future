# Router & Navigation

Findings:
- Centralized routes in src/router/index.js (17 routes)
- Widespread programmatic navigation via this..push/replace/go
- Guards/hooks found: beforeRouteLeave (TheNav.vue), afterEach (ScreenBrands.vue)

Modernization Plan:
- Next.js App Router + typed routes helpers
- Centralize navigation helpers; remove scattered push/replace calls
- Convert guards/afterEach logic into hooks and effectful middleware

Action + Complexity:
- route mapping — replace; M
- navigation helpers — replace; S
- guard logic ports — refactor; M
