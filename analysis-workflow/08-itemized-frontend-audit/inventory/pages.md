# Pages (Router-Defined)

- home (/) -> ScreenHome.vue
- blank (/blank) -> ScreenBlank.vue
- debug-cache (/debug-cache) -> ScreenDebugCache.vue
- category (/products/:categoryId) -> ScreenProducts.vue
- products (/products) -> ScreenProducts.vue
- on-sale (/on-sale) -> ScreenProductsPromotions.vue
- product (/product/:id) -> ScreenProduct.vue
- brands (/brands) -> ScreenBrands.vue
- effects-uses (/effects-uses) -> ScreenEffectsUses.vue
- featured-products (/featured-products) -> ScreenFeaturedProducts.vue
- cart (/cart) -> ScreenCart.vue
- checkout (/checkout) -> ScreenCheckout.vue
- analytics (/analytics) -> ScreenUploadEvents.vue
- iframe (/iframe-test) -> ScreenIframeTest.vue
- keep-shopping (/active-cart/keep-shopping) -> ActiveCartKeepShopping.vue
- active-cart-created (/active-cart/created) -> ActiveCartCheckoutCompleted.vue
- thank-you (/thank-you) -> ThankYouOrderCompleted.vue

## Modernization Plan (Action + Complexity)

Legend: action = replace | port | refactor | delete; complexity = S | M | L | XL

- home (/) -> ScreenHome.vue — action: replace; complexity: L
- blank (/blank) -> ScreenBlank.vue — action: delete; complexity: S
- debug-cache (/debug-cache) -> ScreenDebugCache.vue — action: delete (dev-only); complexity: S
- category (/products/:categoryId) -> ScreenProducts.vue — action: replace; complexity: L
- products (/products) -> ScreenProducts.vue — action: replace; complexity: L
- on-sale (/on-sale) -> ScreenProductsPromotions.vue — action: replace; complexity: M
- product (/product/:id) -> ScreenProduct.vue — action: replace; complexity: L
- brands (/brands) -> ScreenBrands.vue — action: refactor (simplify); complexity: M
- effects-uses (/effects-uses) -> ScreenEffectsUses.vue — action: refactor; complexity: M
- featured-products (/featured-products) -> ScreenFeaturedProducts.vue — action: refactor; complexity: M
- cart (/cart) -> ScreenCart.vue — action: replace; complexity: L
- checkout (/checkout) -> ScreenCheckout.vue — action: replace (provider-specific flows); complexity: XL
- analytics (/analytics) -> ScreenUploadEvents.vue — action: refactor (move to admin/dev); complexity: M
- iframe (/iframe-test) -> ScreenIframeTest.vue — action: delete; complexity: S
- keep-shopping (/active-cart/keep-shopping) -> ActiveCartKeepShopping.vue — action: refactor/port; complexity: M
- active-cart-created (/active-cart/created) -> ActiveCartCheckoutCompleted.vue — action: refactor/port; complexity: M
- thank-you (/thank-you) -> ThankYouOrderCompleted.vue — action: refactor/port; complexity: M
