<template>
  <div id="screen-home-rfidswipe" v-bind:class="{ left_To_Right: $config.LEFT_TO_RIGHT }" class="screen screen--home" style="opacity: 0;">
    <div class="half-screen half-screen--illustration">
      <div class="half-screen__title">
        <div class="half-screen__title__text">
          Welcome
        </div>

        <div class="half-screen__title__line"></div>
      </div><!-- .half-screen__title -->

      <div class="illustration">
        <lottie-container
          v-on:lottie-ready="$nextTick(transitionEnter)"
          v-bind:path="$config.STAND_SIDE === 'right' ? 'howto-notext-right' : 'howto-notext'"
          v-bind:autoplay="false"
          v-bind:loop="true"
          ref="lottieHowto"></lottie-container>
      </div><!-- .illustration -->

      <div class="catcher">
        <div class="catcher__text">
          Place a featured item<br/>
          on the stand

          <div v-if="!$config.LEFT_TO_RIGHT" class="catcher__arrow"></div>
          <div v-if="$config.LEFT_TO_RIGHT" class="catcher__arrow_botom_ringht"></div>
        </div><!-- .catcher__text -->
      </div><!-- .catcher -->
    </div><!-- .half-screen -->

    <div class="screen-separator">
      <div class="screen-separator__label">
        Or
      </div><!-- screen-separator__label -->
    </div><!-- .screen-separator -->

    <div class="half-screen">
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
    </div><!-- .half-screen -->
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import {TimelineLite, Power2, Power3} from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeRfidSwipe',
  components: {
    ActiveCartButton,
    LottieContainer
  },
  data () {
    return {
      reloadTimeout: null,
      storeLogoRatio: 'horizontal',
      storeLogo: null,
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
      // Wait for animation load and instance creation before enter
      this.transitionReady++
      if (this.transitionReady < 2) {
        return
      }

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
        container.find('.half-screen__title__text'),
        0.5,
        {
          alpha: 0,
          x: -10,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
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

      tl.from(
        container.find('.half-screen__title__line'),
        0.5,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeInOut
        },
        0
      )

      tl.staggerFrom(
        container.find('.catcher'),
        0.8,
        {
          alpha: 0,
          y: 100,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.4,
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
        container.find('.store-logo'),
        0.5,
        {
          alpha: 0,
          clearProps: 'opacity'
        },
        0.5
      )

      tl.fromTo(
        container.find('.screen-separator'),
        0.7,
        {
          transform: 'perspective(20em) rotateY(-90deg)'
        },
        {
          transform: 'perspective(20em) rotateY(0)',
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        0.3
      )

      tl.call(function () {
        if (self.$refs.lottieHowto) {
          self.$refs.lottieHowto.animation.play()
        }
      }, null, null, 1)

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
        container.find('.store-logo, .catcher, .swipe-animation, .illustration'),
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

      tl.to(
        container.find('.half-screen__title__text'),
        0.5,
        {
          alpha: 0,
          x: -10,
          ease: Power3.easeIn
        },
        0
      )

      tl.to(
        container.find('.half-screen__title__line'),
        0.5,
        {
          scaleX: 0,
          ease: Power3.easeInOut
        },
        0
      )

      tl.fromTo(
        container.find('.screen-separator'),
        0.6,
        {
          transform: 'perspective(20em) rotateY(0)'
        },
        {
          transform: 'perspective(20em) rotateY(90deg)',
          ease: Power2.easeInOut
        },
        0
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
      console.log(e)
      // On swipe launch slideshow
      if (self.$gsClient) {
        self.$gsClient.track('Swipe Event')
      }
      if (this.$route.name !== 'blank') {
        this.$router.push({ name: 'blank' })
      }
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
    display: flex;
    left: 0;

    background: transparent !important;
    flex-direction: row;
  }

  .left_To_Right{
    flex-direction: row-reverse !important;
  }

  .half-screen {
    position: relative;
    width: 50%;
    height: 100%;

    &__title {
      display: block;
      padding: 0 0 10px;
      position: absolute;
      top: 270px;
      left: 140px;

      font: 16px/1 var(--font-bold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &__line {
        display: block;
        position: absolute;
        bottom: 0;
        left: 0;
        width: 20px;
        height: 4px;

        background: var(--main-color);
        transform-origin: 0 0;
      }
    }

    &--illustration {
      mask-image: linear-gradient(to right, rgba(0, 0, 0, 1.0) 75%, transparent 92%);
    }
  }

  .screen-separator {
    display: flex;
    margin: 0 0 0 -62px;
    position: absolute;
    top: 0;
    left: 50%;
    width: 125px;
    height: 100%;

    flex-direction: column;
    justify-content: center;

    &:before,
    &:after {
      display: block;
      position: absolute;
      top: 0;
      bottom: 0;
      left: 50%;
      width: 1px;

      background: rgba($white, 0.2);
      content: '';
      transform: translate3d(-50%, 0, 0);
    }
    &:before {
      bottom: calc( 50% + 125px / 2 );
    }
    &:after {
      top: calc( 50% + 125px / 2 );
    }

    &__label {
      display: block;
      width: 125px;
      height: 125px;

      background: rgba($bluecharcoal, 0.2);
      border: 1px solid rgba($white, 0.3);
      border-radius: 50%;

      color: var(--secondary-color) !important;
      font: 30px/125px var(--font-extralight);
      text-align: center;
      text-transform: uppercase;
    }
  }

  .store-logo {
    position: absolute;
    top: 50%;
    left: 50%;

    object-fit: contain;
    object-position: center;
    transform: translate3d(-50%, -50%, 0);

    &--horizontal {
      width: 480px;
      height: 120px;
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
      width: 280px;
      height: 360px;
    }
  }

  .illustration {
    position: absolute;
    bottom: 400px;
    left: 50%;
    width: 500px;
    height: 290px;

    transform: translate3d(-50%, 0, 0);

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
    top: 780px;
    left: 0;
    width: 100%;

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
        content: '';
        transform-origin: 0 50%;
      }

      &:before {
        transform: translate3d(0, -50%, 0) rotateZ(-40deg);
      }

      &:after {
        transform: translate3d(0, -50%, 0) rotateZ(40deg);
      }
    }

    &__arrow_botom_ringht{
      width: 38px;
      height: 2px;
      right: 0px;
      bottom: 0px;
      transform: rotate(45deg);
      background: var(--secondary-color) !important;
      position: absolute;
      &:after {
        display: block;
        position: absolute;
        left: 13px;
        top: -10px;
        right: 0px;
        border-bottom: 3px solid;
        border-right: 3px solid;
        width: 20px;
        height: 20px;
        content: '';
        transform: rotate(-45deg);
      }
    }
  }

  .swipe-animation {
    position: absolute;
    top: 880px;
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
