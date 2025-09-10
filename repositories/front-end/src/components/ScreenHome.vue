<template>
  <component v-bind:is="homeComponent" v-bind:isGeneratingIndex="isGeneratingIndex" v-bind:products="products"
    v-bind:brands="brands" v-bind:isActiveCartFeatureActivated="isActiveCartFeatureActivated"></component>
</template>

<script>
import ScreenHomeCards from '@/components/ScreenHomeCards'
import ScreenHomeDefault from '@/components/ScreenHomeDefault'
import ScreenHomeRfidNav from '@/components/ScreenHomeRfidNav'
import ScreenHomeRfidSwipe from '@/components/ScreenHomeRfidSwipe'
import ScreenHomeSwipe from '@/components/ScreenHomeSwipe'
import ScreenHomeSwipeNav from '@/components/ScreenHomeSwipeNav'
import ScreenHomeCCC from '@/components/ScreenHomeCCC'
import ScreenMenuBoard from '@/components/ScreenMenuBoard'
import ScreenHomeQuickCheckout from '@/components/ScreenHomeQuickCheckout'
import { mapGetters, mapMutations } from 'vuex'
import ScreenHomeSpotlight from '@/components/ScreenHomeSpotlight'
import ScreenHomeSpotlightCards from '@/components/ScreenHomeSpotlightCards'
import ActiveCartButton from './ActiveCartButton.vue'
import ScreenHomeSplitCards from '@/components/ScreenHomeSplitCards.vue'
import ScreenHomeVideoImageBackground from '@/components/ScreenHomeVideoImageBackground.vue'

export default {
  name: 'ScreenHomeRouter',
  components: { ActiveCartButton },
  props: ['isGeneratingIndex', 'products', 'brands'],
  data() {
    return {
      homeComponent: null
    }
  },
  computed: {
    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },
  },

  created: function () {
    // remove scroll of product
    localStorage.removeItem('productsOffset')
    window.addEventListener('load-config-data', this.reloadApp)

    // Set home variations
    this.createLayout()

    // Events
    this.$on('transition-leave', this.onTransitionLeave)
    // set product page to 1
    this.setProductPage(1)
  },

  destroyed: function () {
    // Events
    this.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    ...mapMutations('products', { setProductPage: 'SET_CURRENT_PAGE' }),
    onTransitionLeave: function (el, done) {
      // Let dynamic component play its transition
    },

    createLayout() {
      var home = ScreenHomeDefault
      console.log('MODE', this.$config.KIOSK_MODE)

      if (this.$config.KIOSK_MODE === 'brand') {
        switch (this.$config.HOME_LAYOUT) {
          case 'swipe':
            home = ScreenHomeSwipe
            break
          case 'rfidswipe':
            home = ScreenHomeRfidSwipe
            break
          case 'rfidnav':
            home = ScreenHomeRfidNav
            break
          case 'swipenav':
            home = ScreenHomeSwipeNav
            break
          case 'on_sale':
            home = ScreenHomeCCC
            break
          case 'quick_checkout':
            home = ScreenHomeQuickCheckout
            break
          case 'video_image_background':
            home = ScreenHomeVideoImageBackground
            break
        }
      } else if (this.$config.KIOSK_MODE === 'limited') {
        if (this.$config.HOME_LAYOUT === 'split_screen') {
          home = ScreenHomeSplitCards
        } else {
          home = ScreenHomeCards
        }
      } else if (this.$config.KIOSK_MODE === 'shopping') {
        switch (this.$config.HOME_LAYOUT) {
          case 'on_sale':
            home = ScreenHomeCCC
            break
          case 'spotlight':
            home = ScreenHomeSpotlight
            break
          case 'spotlightcards':
            home = ScreenHomeSpotlightCards
            break
          case 'quick_checkout':
            home = ScreenHomeQuickCheckout
            break
        }
      } else if (this.$config.KIOSK_MODE === 'menu_boards_layout') {
        switch (this.$config.HOME_LAYOUT) {
          case 'menu_boards':
            home = ScreenMenuBoard
            break
        }
      }

      console.log('COMPONENT', home)

      this.homeComponent = home
    },

    reloadApp(data) {
      console.log('reloadApp', data)
      this.$config = data.data.config
      window.location.reload()
    }
  }
}
</script>

<style scoped lang="scss"></style>
