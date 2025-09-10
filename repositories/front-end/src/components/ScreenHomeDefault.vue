<template>
  <div id="screen-home-default" class="screen screen--home" style="opacity: 0">
    <img
      v-bind:src="storeLogo"
      v-on:load="setStoreLogoRatio"
      v-on:touchstart="logoHold"
      v-on:touchend="logoRelease"
      v-bind:class="'store-logo--' + storeLogoRatio"
      ref="storeLogoImg"
      class="store-logo" />

    <div
      v-bind:class="{ 'catcher--small': !$config.RFID_ENABLED }"
      class="catcher">
      <div
        v-for="(line, index) in welcomeMessage.split('\n')"
        v-bind:key="'line' + index"
        class="catcher__line">
        {{ line }}
      </div><!-- .catcher__line -->
    </div><!-- .catcher -->

    <div v-if="$config.RFID_ENABLED" class="illustration">
      <lottie-container
        v-on:lottie-ready="$nextTick(transitionEnter)"
        v-bind:path="$config.STAND_SIDE === 'right' ? 'howto-notext-right' : 'howto-notext'"
        v-bind:autoplay="false"
        v-bind:loop="true"
        ref="lottieHowto"></lottie-container>
    </div><!-- .illustration -->

    <the-nav
      class="the-nav--large"
      ref="theNav"></the-nav>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import TheNav from '@/components/TheNav'
import { TimelineLite, Power3 } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeDefault',
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
      transitionReady: 0,
      welcomeMessage: null
    }
  },
  props: ['isActiveCartFeatureActivated'],
  created: function () {
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Set default message
    if (this.$config.RFID_ENABLED) {
      this.welcomeMessage = 'Place a \nfeatured item \non the stand.'
    } else {
      if (this.$config.TEXT.WELCOME_MESSAGE) {
        this.welcomeMessage = this.$config.TEXT.WELCOME_MESSAGE
      } else {
        this.welcomeMessage =
          'Browse our catalogue \nto see what we have \nin stock!'
      }
    }

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
      if (
        (this.$config.RFID_ENABLED && this.transitionReady < 2) ||
        (!this.$config.RFID_ENABLED && this.transitionReady < 1)
      ) {
        return
      }

      // Selectors
      var self = this
      var container = $(this.$el)
      var blockIntros = self.$refs.theNav.$refs.lottieBlockIntro

      this.$root.$emit('block-pointer', true)

      // Before animation
      container.css({ opacity: '' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container.find('.store-logo'),
        0.5,
        {
          alpha: 0
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
        container.find('.catcher__line'),
        0.8,
        {
          alpha: 0,
          y: 100,
          ease: Power3.easeOut
        },
        0.25,
        0
      )

      tl.from(
        container.find('.illustration'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeOut
        },
        0.5
      )

      if (self.$refs.lottieHowto) {
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
      }

      container.find('.the-nav .link').each(function (index) {
        var link = $(this)
        if (blockIntros[index]) {
          var animation = blockIntros[index].animation
          var start = 0.5 + 0.3 * index

          link.find('.label, .arrow').css({ transition: 'none' })

          tl.call(
            function () {
              if (animation) {
                // animation.setSpeed(0.2)
                animation.play()

                animation = null
              }
            },
            null,
            null,
            start
          )
        }
        tl.from(
          link,
          0.2,
          {
            alpha: 0
          },
          start
        )

        tl.from(
          link.find('.number__text'),
          0.5,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.number__line'),
          0.5,
          {
            scaleX: 0,
            ease: Power3.easeInOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.label'),
          0.6,
          {
            alpha: 0,
            y: 50,
            ease: Power3.easeOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.arrow'),
          0.6,
          {
            scale: 0,
            x: -50,
            ease: Power3.easeOut
          },
          start + 0.4
        )

        tl.from(
          link.find('.arrow__line'),
          0.6,
          {
            scale: 0,
            x: -10,
            ease: Power3.easeOut
          },
          start + 0.6
        )

        link = null
      })

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

        tl.kill()

        tl = null
        container = null
        blockIntros = null
      })

      tl.play()
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)
      var blockIntros = self.$refs.theNav.$refs.lottieBlockIntro
      var blockOutros = self.$refs.theNav.$refs.lottieBlockOutro

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.store-logo'),
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
        container.find('.catcher'),
        0.7,
        {
          alpha: 0
        },
        0
      )

      tl.to(
        container.find('.illustration'),
        0.5,
        {
          alpha: 0
        },
        0
      )

      if (self.$refs.lottieHowto) {
        tl.to(
          self.$refs.lottieHowto.$el,
          0.7,
          {
            alpha: 0
          },
          0
        )
      }

      container.find('.the-nav .link').each(function (index) {
        var link = $(this)
        var blockIntro = blockIntros[index]
        var blockOutro = blockOutros[index]
        // var animationOutro = self.$refs.theNav.$refs.lottieBlockOutro[index]
        var start = 0 + 0.1 * index

        blockIntro.$el.style.opacity = 0
        blockOutro.$el.style.opacity = 1

        tl.call(
          function () {
            if (blockOutro && blockOutro.animation) {
              blockOutro.animation.play()

              blockOutro = null
            }
          },
          null,
          null,
          start
        )

        tl.to(
          link.find('.number, .label, .arrow'),
          0.3,
          {
            alpha: 0,
            overwrite: 'all'
          },
          start
        )

        tl.to(
          link,
          0.2,
          {
            alpha: 0,
            overwrite: 'all'
          },
          start + 0.4
        )

        link = null
        blockIntro = null
      })

      tl.call(
        function () {
          tl.kill()

          tl = null
          container = null
          blockIntros = null
          blockOutros = null

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
      // var img = this.$refs.storeLogoImg
      // if (img) {
      //   var ratio = img.naturalHeight / img.naturalWidth

      //   if (ratio < 0.33) {
      //     this.storeLogoRatio = 'horizontal'
      //   } else if (ratio < 0.66) {
      //     this.storeLogoRatio = 'rectangle'
      //   } else if (ratio < 1.33) {
      //     this.storeLogoRatio = 'square'
      //   } else {
      //     this.storeLogoRatio = 'vertical'
      //   }
      // }

      // img = null
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
  position: fixed;
  top: 50px;
  left: 50px;

  object-fit: contain;
  object-position: center;
  opacity: 0.5;

  &--horizontal {
    width: 160px;
    height: 60px;
  }

  &--rectangle {
    width: 100px;
    height: 40px;
  }

  &--square {
    width: 90px;
    height: 90px;
  }

  &--vertical {
    width: 60px;
    height: 100px;
  }
}

.catcher {
  position: fixed;
  top: 290px;
  left: 170px;
  width: 600px;

  font: 92px/1.09 var(--font-extralight);

  &--small {
    top: 400px;
    left: 140px;
    width: 740px;

    font-size: 70px;
  }
}

.illustration {
  position: fixed;
  top: 630px;
  left: 170px;
  width: 477px;
  height: 353px;

  .lottie-container {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 987px;
    height: 730px;

    // width: 477px;
    // height: 353px;

    transform: translate3d(-50%, -50%, 0);
  }
}

.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}
</style>
