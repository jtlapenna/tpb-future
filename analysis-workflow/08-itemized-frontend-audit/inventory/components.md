# Components (Initial Inventory)

Screen Components:
- ScreenBlank.vue
- ScreenBrands.vue
- ScreenCart.vue
- ScreenCheckout.vue
- ScreenCheckoutActiveCartCreator.vue
- ScreenCheckoutBlaze.vue
- ScreenCheckoutCovasoft.vue
- ScreenCheckoutEmail.vue
- ScreenCheckoutFlowhub.vue
- ScreenCheckoutLeaflogix.vue
- ScreenCheckoutShopify.vue
- ScreenDebugCache.vue
- ScreenEffectsUses.vue
- ScreenFeaturedProducts.vue
- ScreenHome.vue
- ScreenHomeCards.vue
- ScreenHomeCCC.vue
- ScreenHomeDefault.vue
- ScreenHomeQuickCheckout.vue
- ScreenHomeRfidNav.vue
- ScreenHomeRfidSwipe.vue
- ScreenHomeSplitCards.vue
- ScreenHomeSpotlight.vue
- ScreenHomeSpotlightCards.vue
- ScreenHomeSwipe.vue
- ScreenHomeSwipeNav.vue
- ScreenHomeVideoImageBackground.vue
- ScreenIframeTest.vue
- ScreenProduct.vue
- ScreenProductImage.vue
- ScreenProductVideo.vue
- ScreenProducts.vue
- ScreenProductsPromotions.vue
- ScreenUploadEvents.vue

UI/Feature Components:
- ActiveCartButton.vue
- ActiveCartCheckoutCompleted.vue
- ActiveCartFinalizeOrderButton.vue
- ActiveCartKeepShopping.vue
- ActiveCartKeepShoppingButton.vue
- ActiveCartNotFound.vue
- LottieContainer.vue
- ModalTemplate.vue
- ProductCard.vue
- ProductCardBlank.vue
- ProductCardMenuBoard.vue
- ProductGraphs.vue
- ProductImage.vue
- ShareButton.vue
- Slider.vue
- Spinner.vue
- TheBrandSlideshow.vue
- TheNav.vue
- TheSidebar.vue

## Modernization Plan (Action + Complexity)

Legend: action = replace | port | refactor | delete; complexity = S | M | L | XL

Screen Components:
- ScreenHome.vue — replace; L
- ScreenHome* variants — refactor to layout system; M-L
- ScreenProducts.vue — replace; L
- ScreenProduct.vue — replace; L
- ScreenCart.vue — replace; L
- ScreenCheckout*.vue (Blaze/Treez/Flowhub/Leaflogix/Shopify/Covasoft) — replace with provider adapters; XL
- ScreenFeaturedProducts.vue — refactor; M
- ScreenEffectsUses.vue — refactor; M
- ScreenBrands.vue — refactor; M
- ScreenUploadEvents.vue — refactor/move; M
- ScreenIframeTest.vue — delete; S

UI/Feature Components:
- ProductCard.vue — replace (port React ProductCard); M
- ProductCardBlank.vue — delete; S
- ProductCardMenuBoard.vue — refactor; M
- ProductImage.vue — replace; M
- ProductGraphs.vue — refactor; M
- Slider.vue — replace with library; M
- Spinner.vue — replace with library; S
- ModalTemplate.vue — replace with MUI Dialog; M
- LottieContainer.vue — port or use react-lottie; S
- ShareButton.vue — refactor; S
- ActiveCart* components — refactor/port; M
- TheSidebar.vue / TheNav.vue — replace (MUI/Nav primitives); M
- TheBrandSlideshow.vue — refactor or library; M
