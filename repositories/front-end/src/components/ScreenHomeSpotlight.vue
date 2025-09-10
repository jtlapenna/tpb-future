<template>
  <div
    id="screen-home-default"
    class="screen screen--home"
  >
    <div
      v-if="isGeneratingIndex"
      class="message-generating"
    >Index is being generated, please wait.</div>

    <template v-if="!isGeneratingIndex">
      <div
        class="catcher"
        :class="{'catcher-brand': useBrandSpotlight, 'default-view': !isGeneratingIndex && showDefault  }"
      >
        <img
          v-bind:src="storeLogo"
          v-on:load="setStoreLogoRatio"
          v-on:touchstart="logoHold"
          v-on:touchend="logoRelease"
          v-bind:class="'store-logo--' + storeLogoRatio"
          ref="storeLogoImg"
          class="store-logo"
        />

        <div
          v-if="showDefault"
          v-bind:class="{ 'catcher--small': !$config.RFID_ENABLED}"
          class="catcher"
        >
          <div
            v-for="(line, index) in welcomeMessage.split('\n')"
            v-bind:key="'line' + index"
            class="catcher__line"
          >
            {{ line }}
          </div><!-- .catcher__line -->
        </div><!-- .catcher -->

        <div
          v-if="$config.RFID_ENABLED && (showDefault || (isGeneratingIndex && !useBrandSpotlight))"
          class="illustration"
        >
          <lottie-container
            v-bind:path="$config.STAND_SIDE === 'right' ? 'howto-notext-right' : 'howto-notext'"
            v-bind:autoplay="false"
            v-bind:loop="true"
            ref="lottieHowto"
          ></lottie-container>
        </div><!-- .illustration -->
        <div
          v-if="!isGeneratingIndex && !showDefault"
          class="catcher--title"
          style="position:relative"
        >
          <div class="catcher--title__container">
            <div class="title-container">
              <span>{{welcomeMessage}}</span>
              <div class="catcher--title__line complete-with"></div>
            </div>
            <img
              v-if="currentBrandLogo && useBrandSpotlight"
              :src="currentBrandLogo"
              class="catcher--title__logo"
            >
          </div>
        </div>

        <div
          class="slider"
          style="position:relative"
          v-if="showDefault == false"
        >
          <Slider
            v-bind:useBrandSpotlight="useBrandSpotlight"
            v-bind:products="products"
            v-bind:brands="brands"
            v-bind:product_Id="product_Id"
            v-bind:brand_Id="brand_Id"
            v-bind:url_Brand_Video="url_Brand_Video"
            v-bind:url_Brand_Image="url_Brand_Image"
            v-on:onUpdateBrandLogo="UpdateBrandLogo"
            v-bind:useNoCardsConfig="true"
            v-bind:isGeneratingIndex="isGeneratingIndex"
          />
        </div>
      </div>
      <the-nav
        class="the-nav--large"
        ref="theNav"
      ></the-nav>
    </template>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>
<script>
import LottieContainer from '@/components/LottieContainer'
import TheNav from '@/components/TheNav'
import Slider from '@/components/Slider'
import { TimelineLite, Power3 } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'
export default {
  name: 'ScreenHomeSpotlight',
  components: {
    ActiveCartButton,
    TheNav,
    Slider,
    LottieContainer
  },
  props: ['products', 'brands', 'isGeneratingIndex', 'isActiveCartFeatureActivated'],
  data () {
    return {
      navLayout: 'large',
      reloadTimeout: null,
      storeLogoRatio: 'horizontal',
      imgs: [],
      currentBrandLogo: null,
      currentCatalog: null
    }
  },
  created: function () {
    // Set store logo

    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  mounted () {
    this.$nextTick(this.transitionEnter)
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
      //  Selectors

      var self = this
      var container = $(this.$el)

      if (this.isGeneratingIndex) {
        container.css({ opacity: '' })
        return
      }
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

      try {
        tl.play()
      } catch (e) {
        console.error(e)
      }
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
    },
    /**
     * This method brigs the info of the current brand from the
     */
    UpdateBrandLogo: function (currentLogo) {
      this.currentBrandLogo = currentLogo
    }
  },
  computed: {
    spotlightProduct: function () {
      return this.products.find((p) => p.id === this.product_Id)
    },
    spotlightBrand: function () {
      return this.brands.find((b) => b.id === this.brand_Id)
    },

    showDefault: function () {
      if (this.useBrandSpotlight) {
        return this.spotlightBrand == null
      } else {
        return this.spotlightProduct == null
      }
    },
    welcomeMessage: function () {
      if (this.showDefault) {
        if (this.$config.RFID_ENABLED) {
          return 'Place a \nfeatured item \non the stand.'
        } else {
          if (this.$config.TEXT.WELCOME_MESSAGE) {
            return this.$config.TEXT.WELCOME_MESSAGE
          } else {
            return 'Browse our catalogue \nto see what we have \nin stock!'
          }
        }
      } else {
        return this.useBrandSpotlight ? 'Brand Spotlight' : 'Product Spotlight'
      }
    },

    storeLogo: function () {
      return this.$config.STORE_LOGO
    },
    product_Id: function () {
      return this.$config.PRODUCT_ID
    },
    brand_Id: function () {
      return this.$config.BRAND_ID
    },
    url_Brand_Image: function () {
      return this.$config.URL_BRAND_IMAGE
    },
    url_Brand_Video: function () {
      return this.$config.URL_BRAND_VIDEO
    },
    useBrandSpotlight: function () {
      return this.$config.USE_BRAND_SPOTLIGHT
    }
  },
  watch: {
    isGeneratingIndex () {
      this.$nextTick(() => {
        this.transitionEnter()
      })
    }
  }
}
</script>
<style scoped lang="scss">
.message-generating {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  animation: alpha-pulse 2s linear infinite;
  transform: translate3d(0, -50%, 0);
  color: #fff;
  text-align: center;
}
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

.default-view {
  top: 100px;
  font: 68px/1.09 var(--font-extralight);
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

.catcher {
  position: fixed;
  top: 155px;
  left: 110px;
  width: 765px;

  font: 92px/1.09 var(--font-extralight);

  &--big {
    position: absolute;
    top: 150px;
    left: 70px;
  }

  &--small {
    font-size: 70px;
    top: 355px;
  }

  &--title {
    font-size: 50px;
    height: 74px;
    font-weight: 100;
    position: relative;
    display: flex;
    align-items: center;
    font-family: muliextralight;
    overflow: visible;

    &__container {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    &__logo {
      width: 250px;
      height: auto;
    }
    &__line {
      display: block;
      position: absolute;
      bottom: 0;
      left: 0;
      width: 1.25em;
      height: 0.25em;

      background: var(--main-color);
      transform-origin: 0 0;
    }
  }
}

.catcher-brand {
  top: 200px !important;
}

.slider {
  margin-top: 25px;
}

.catcher--title__logo {
  position: absolute;
  right: 0px;
  bottom: 0px;
  max-height: 100px !important;
  max-width: 400px !important;
  height: auto !important;
  width: auto !important;
}

.complete-with {
  margin-left: 4px;
  width: 47px !important;
}

.title-container {
  overflow: hidden;
  height: 60px;
}

.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}
</style>
