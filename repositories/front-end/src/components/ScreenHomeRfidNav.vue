<template>
  <div id="screen-home-rfidnav" class="screen screen--home" style="opacity: 0">
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
          Place a featured item<br/>
          on the stand

          <div class="catcher__arrow"></div>
        </div><!-- .catcher__text -->
    </div><!-- .catcher -->

    <div class="illustration">
      <lottie-container
        v-on:lottie-ready="$nextTick(transitionEnter)"
        v-bind:path="$config.STAND_SIDE === 'right' ? 'howto-notext-right' : 'howto-notext'"
        v-bind:autoplay="false"
        v-bind:loop="true"
        ref="lottieHowto"></lottie-container>
    </div><!-- .illustration -->

    <the-nav
      class="the-nav--large the-nav--large--visual"
      v-bind:isVisual="true"
      ref="theNav"></the-nav>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import TheNav from '@/components/TheNav'
import { TimelineLite, Linear, Power3 } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeRfidNav',
  components: {
    ActiveCartButton,
    LottieContainer,
    TheNav
  },
  data () {
    return {
      navLayout: 'large',
      reloadTimeout: null,
      storeLogo: null,
      storeLogoRatio: 'horizontal',
      transitionReady: 0
    }
  },
  props: ['isActiveCartFeatureActivated'],
  created: function () {
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  destroyed: function () {
    // Events
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Wait for animation load and instance creation before enter
      this.transitionReady++
      if (this.transitionReady < 2) {
        return
      }

      // Selectors
      var self = this
      var container = $(this.$el)

      // Before animation
      container.css({ opacity: '' })

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
        container.find('.illustration'),
        0.5,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.2
      )

      tl.from(
        container.find('.catcher'),
        0.8,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.3
      )

      tl.call(
        function () {
          if (self.$refs.lottieHowto) {
            self.$refs.lottieHowto.animation.play()
          }
        },
        null,
        null,
        1
      )

      container.find('.the-nav .element').each(function (index) {
        var element = $(this)
        var start = 0.3 + 0.1 * index

        element.find('.label, .arrow').css({ transition: 'none' })

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

        tl.from(
          container.find('.active-button-container'),
          0.5,
          {
            alpha: 0
          },
          0
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

        tl.from(
          element.find('.arrow'),
          0.6,
          {
            scale: 0,
            x: -50,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          start + 0.4
        )

        tl.from(
          element.find('.arrow__line'),
          0.6,
          {
            scale: 0,
            x: -10,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          start + 0.6
        )

        element = null
      })

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

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
        container.find('.store-logo, .catcher, .illustration'),
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
          container.find('.active-button-container'),
          0.7,
          {
            alpha: 0
          },
          0
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

      tl.call(
        function () {
          tl.kill()

          tl = null
          container = null

          done()
        },
        null,
        null,
        1
      )

      tl.play()
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
  top: 180px;
  left: 210px;

  object-fit: contain;
  object-position: left center;
  transform: translate3d(0, -50%, 0);
  z-index: 2;

  &--horizontal {
    width: 320px;
    height: 80px;
  }

  &--rectangle {
    width: 220px;
    height: 80px;
  }

  &--square {
    width: 200px;
    height: 200px;
  }

  &--vertical {
    width: 120px;
    height: 200px;
  }
}

.illustration {
  position: fixed;
  top: 380px;
  left: 200px;
  width: 500px;
  height: 290px;

  .lottie-container {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 1169px;
    height: 865px;

    // width: 477px;
    // height: 353px;

    transform: translate3d(-50%, -50%, 0);
  }
}

.catcher {
  position: absolute;
  top: 800px;
  left: 0;
  width: 50%;

  color: var(--secondary-color) !important;
  font: 44px/1.22 var(--font-extralight);
  letter-spacing: 0.04em;
  text-align: center;

  &__text {
    display: inline-block;
    position: relative;
  }

  &__arrow {
    position: absolute;
    top: 21px;
    left: -62px;
    width: 38px;
    height: 2px;

    background: var(--secondary-color) !important;
    border-radius: 1px;
    vertical-align: top;

    &:before,
    &:after {
      display: block;
      position: absolute;
      top: 50%;
      left: 0;
      width: 18px;
      height: 2px;

      background: inherit;
      border-radius: inherit;
      content: "";
      transform-origin: 0 50%;
    }

    &:before {
      transform: translate3d(0, -50%, 0) rotateZ(-40deg);
    }

    &:after {
      transform: translate3d(0, -50%, 0) rotateZ(40deg);
    }
  }
}
.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}
</style>
