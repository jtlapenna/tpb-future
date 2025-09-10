<template>
  <div id="screen-home-swipe" :class="{'home screen--home--with-background-visible': isBackGroundvisible}" class="screen screen--home" ng- style="opacity: 0;">
    <img
      v-bind:src="storeLogo"
      v-on:load="setStoreLogoRatio"
      v-on:touchstart="logoHold"
      v-on:touchend="logoRelease"
      v-bind:class="'store-logo--' + storeLogoRatio"
      ref="storeLogoImg"
      class="store-logo" />

    <div class="catcher">
      Swipe to get started
    </div><!-- .catcher -->

    <div class="swipe-animation" style="display: none;">
    </div><!-- .swipe-animation -->
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import {TimelineLite, Power3} from 'gsap/all'
import $ from 'jquery'
import {GSAP_ANIMATION} from '@/const/globals.js'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeSwipe',
  components: { ActiveCartButton },
  data () {
    return {
      reloadTimeout: null,
      storeLogoRatio: 'horizontal',
      storeLogo: null
    }
  },
  props: ['isActiveCartFeatureActivated'],
  computed: {
    isBackGroundvisible () {
      return this.$config.BACKGROUND_IMAGE_TOP
    }
  },
  created: function () {
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$root.$on('app-swipe', this.onSwipe)
    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  destroyed: function () {
    // Events
    this.$root.$off('app-swipe', this.onSwipe)
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {
    // Remove buggy sidebar on transitionleave event
    let sidebar = document.querySelector('#the-sidebar')

    if (sidebar) {
      sidebar.remove()
    }
  },
  methods: {
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Selectors
      var self = this
      var container = $(this.$el)

      // Before animation
      container.css({opacity: ''})

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container.find('.store-logo'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.active-button-container'),
        0.5,
        {
          alpha: 0
        },
        0
      )

      tl.from(
        container.find('.catcher'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        self.$root.$emit('block-pointer', false)
      })

      tl.set(
        container.find('.swipe-animation'),
        {
          display: ''
        },
        GSAP_ANIMATION.append
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null
      })

      tl.play()
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.swipe-animation'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.catcher'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.active-button-container'),
        0.7,
        {
          alpha: 0
        },
        0
      )

      tl.to(
        container.find('.store-logo'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Swipe event
     */
    onSwipe: function (e) {
      let self = this
      // On swipe launch slideshow
      if (self.$gsClient) {
        self.$gsClient.track('Swipe Event')
      }
      this.$router.push({ name: 'blank' })
    },

    /**
     * Hold logo
     */
    logoHold: function () {
      this.$root.$emit('start-hard-refresh')
    },

    /**
     * Release logo
     */
    logoRelease: function () {
      this.$root.$emit('stop-hard-refresh')
    },

    /**
     * Calculate logo ratio
     */
    setStoreLogoRatio: function () {
      var img = this.$refs.storeLogoImg
      if (img) {
        var ratio = img.naturalHeight / img.naturalWidth

        if (ratio < 0.33) {
          this.storeLogoRatio = 'horizontal'
        } else if (ratio < 0.66) {
          this.storeLogoRatio = 'rectangle'
        } else if (ratio < 1.33) {
          this.storeLogoRatio = 'square'
        } else {
          this.storeLogoRatio = 'vertical'
        }
      }

      img = null
    }
  }
}
</script>

<style scoped lang="scss">
  .screen--home {
    left: 0;

    background: transparent !important;
    &--with-background-visible{
      .catcher{
        display: none;
      }
      .swipe-animation{
        top: 775px;
      }
    }
  }

  .store-logo {
    position: absolute;
    bottom: 510px;
    left: 50%;

    object-fit: contain;
    object-position: center bottom;
    transform: translate3d(-50%, 0, 0);

    &--horizontal {
      width: 1000px;
      height: 160px;
    }

    &--rectangle {
      width: 600px;
      height: 160px;
    }

    &--square {
      width: 320px;
      height: 320px;
    }

    &--vertical {
      width: 300px;
      height: 400px;
    }
  }

  .catcher {
    display: none;
    position: absolute;
    top: 600px;
    left: 0;
    width: 100%;

    color: var(--secondary-color) !important;
    font: 44px/1 var(--font-extralight);
    letter-spacing: 0.04em;
    text-align: center;
  }

  .swipe-animation {
    position: absolute;
    top: 700px;
    left: 50%;
    width: 140px;
    height: 62px;

    transform: translate3d(-50%, 0, 0);

    &:before {
      display: block;
      position: absolute;
      top: 0;
      right: 0;
      width: 62px;
      height: 62px;

      animation: swipe-dot 1.8s cubic-bezier(0.86, 0, 0.07, 1) 0s infinite normal, swipe-alpha 1.8s linear 0s infinite normal;
      background: rgba($white, 0.85);
      border-radius: 50%;
      content: '';
      transform: translate3d(50%, 0, 0);
    }
  }
  .active-button-container {
    position: absolute;
    bottom: 1.5rem;
    left: 1.5rem;
  }
</style>
