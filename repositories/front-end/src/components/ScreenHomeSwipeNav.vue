<template>
  <div id="screen-home-swipenav" class="screen screen--home" style="opacity: 0">
    <img
      v-bind:src="storeLogo"
      v-on:load="setStoreLogoRatio"
      v-on:touchstart="logoHold"
      v-on:touchend="logoRelease"
      v-bind:class="'store-logo--' + storeLogoRatio"
      ref="storeLogoImg"
      class="store-logo" />

    <div class="catcher">
        <div class="catcher__text">
          Swipe to get started
        </div><!-- .catcher__text -->
    </div><!-- .catcher -->

    <div class="swipe-animation" style="display: none;">
    </div><!-- .swipe-animation -->

    <div v-if="welcomeMessage" class="message">
      {{ welcomeMessage }}
    </div>

    <the-nav
      class="the-nav--large the-nav--large--visual the-nav--round"
      v-bind:isVisual="true"
      ref="theNav"></the-nav>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import TheNav from '@/components/TheNav'
import {TimelineLite, Linear, Power3} from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeRfidNav',
  components: {
    ActiveCartButton,
    TheNav
  },
  data () {
    return {
      navLayout: 'large',
      reloadTimeout: null,
      storeLogo: null,
      storeLogoRatio: 'horizontal',
      welcomeMessage: null
    }
  },
  props: ['isActiveCartFeatureActivated'],
  created: function () {
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Set default message
    if (this.$config.TEXT.WELCOME_MESSAGE) {
      this.welcomeMessage = this.$config.TEXT.WELCOME_MESSAGE
    } else if (this.$config.RFID_ENABLED) {
      this.welcomeMessage = '< or place a featured item on the stand.'
    }

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
        0.5,
        {
          alpha: 0,
          clearProps: 'opacity'
        },
        0
      )

      tl.from(
        container.find('.active-button-container'),
        0.5,
        {
          alpha: 0
        },
        0
      )

      tl.staggerFrom(
        container.find('.catcher, .message'),
        0.8,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.2,
        0.3
      )

      container.find('.the-nav .element').each(function (index) {
        var element = $(this)
        var start = 0.3 + 0.1 * index

        element.find('.label').css({transition: 'none'})

        tl.from(
          element,
          0.3,
          {
            alpha: 0,
            clearProps: 'opacity',
            ease: Linear.easeNone
          },
          start
        )

        tl.staggerFrom(
          element.find('.title, .text, .button'),
          0.6,
          {
            alpha: 0,
            y: 20,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          start + 0.1
        )

        tl.from(
          element.find('.label'),
          0.6,
          {
            alpha: 0,
            x: -50,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          start + 0.1
        )

        element = null
      })

      tl.call(function () {
        self.$root.$emit('block-pointer', false)
      })

      tl.set(
        container.find('.swipe-animation'),
        {
          display: ''
        },
        2.5
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
        container.find('.store-logo, .catcher, .message, .swipe-animation'),
        0.7,
        {
          alpha: 0
        },
        0
      )

      tl.to(
        container.find('.active-button-container'),
        0.7,
        {
          alpha: 0
        },
        0
      )

      container.find('.the-nav .element').each(function (index) {
        var element = $(this)
        var start = 0 + 0.1 * index

        tl.to(
          element.find('.label, .arrow, .title, .text, .button'),
          0.3,
          {
            alpha: 0
          },
          start
        )

        tl.to(
          element,
          0.2,
          {
            alpha: 0
          },
          start + 0.2
        )

        element = null
      })

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      }, null, null, 1)

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
  }

  .store-logo {
    position: absolute;
    bottom: calc( 50% + 30px );
    left: 25%;

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
    position: absolute;
    top: calc( 50% + 30px );
    left: 0;
    width: 50%;

    color: var(--secondary-color) !important;
    font: 40px/1.22 var(--font-extralight);
    letter-spacing: 0.04em;
    text-align: center;

    &__text {
      display: inline-block;
      position: relative;
    }
  }

  .swipe-animation {
    position: absolute;
    top: calc( 50% + 110px );
    left: 25%;
    width: 140px;
    height: 40px;

    transform: translate3d(-50%, 0, 0);

    &:before {
      display: block;
      position: absolute;
      top: 0;
      right: 0;
      width: 40px;
      height: 40px;

      animation: swipe-dot 1.8s cubic-bezier(0.86, 0, 0.07, 1) 0s infinite normal, swipe-alpha 1.8s linear 0s infinite normal;
      background: rgba($white, 0.85);
      border-radius: 50%;
      content: '';
      transform: translate3d(50%, 0, 0);
    }
  }

  .message {
    position: absolute;
    bottom: 190px;
    left: 0;
    width: 50%;

    opacity: 0.5;

    font: 16px/1.22 var(--font-regular);
    letter-spacing: 0.15em;
    text-align: center;
    text-transform: uppercase;
  }
  .active-button-container {
    position: absolute;
    bottom: 1.5rem;
    left: 1.5rem;
  }
</style>
