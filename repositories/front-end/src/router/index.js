import Vue from 'vue'
import Router from 'vue-router'
import ScreenBlank from '@/components/ScreenBlank'
import ScreenBrands from '@/components/ScreenBrands'
import ScreenCart from '@/components/ScreenCart'
import ScreenCheckout from '@/components/ScreenCheckout'
import ScreenDebugCache from '@/components/ScreenDebugCache'
import ScreenEffectsUses from '@/components/ScreenEffectsUses'
import ScreenFeaturedProducts from '@/components/ScreenFeaturedProducts'
import ScreenHome from '@/components/ScreenHome'
import ScreenProduct from '@/components/ScreenProduct'
import ScreenProducts from '@/components/ScreenProducts'
import ScreenUploadEvents from '@/components/ScreenUploadEvents'
import ScreenProductsPromotions from '@/components/ScreenProductsPromotions'
import ScreenIframeTest from '@/components/ScreenIframeTest'
import ActiveCartKeepShopping from '@/components/ActiveCartKeepShopping'
import ActiveCartCheckoutCompleted from '@/components/ActiveCartCheckoutCompleted'
import ThankYouOrderCompleted from '@/components/ThankYouOrderCompleted'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: ScreenHome
    },
    {
      path: '/blank',
      name: 'blank',
      component: ScreenBlank
    },
    {
      path: '/debug-cache',
      name: 'debug-cache',
      component: ScreenDebugCache
    },
    {
      path: '/products/:categoryId',
      name: 'category',
      component: ScreenProducts
    },
    {
      path: '/products',
      name: 'products',
      component: ScreenProducts
    },
    {
      path: '/on-sale',
      name: 'on-sale',
      component: ScreenProductsPromotions
    },
    {
      path: '/product/:id',
      name: 'product',
      component: ScreenProduct,
      props: { source: null }
    },
    {
      path: '/brands',
      name: 'brands',
      component: ScreenBrands
    },
    {
      path: '/effects-uses',
      name: 'effects-uses',
      component: ScreenEffectsUses
    },
    {
      path: '/featured-products',
      name: 'featured-products',
      component: ScreenFeaturedProducts
    },
    {
      path: '/cart',
      name: 'cart',
      component: ScreenCart
    },
    {
      path: '/checkout',
      name: 'checkout',
      component: ScreenCheckout
    },
    {
      path: '/analytics',
      name: 'analytics',
      component: ScreenUploadEvents
    },
    {
      path: '/iframe-test',
      name: 'iframe',
      component: ScreenIframeTest
    },
    {
      path: '/active-cart/keep-shopping',
      name: 'keep-shopping',
      component: ActiveCartKeepShopping
    },
    {
      path: '/active-cart/created',
      name: 'active-cart-created',
      component: ActiveCartCheckoutCompleted
    },
    {
      path: '/thank-you',
      name: 'thank-you',
      component: ThankYouOrderCompleted
    },
  ]
})
