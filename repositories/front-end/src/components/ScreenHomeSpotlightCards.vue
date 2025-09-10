<template>
  <div id="screen-home-default" class="screen screen--home" style="opacity: 0">
 <div
      class="catcher" :class="{'catcher-brand': useBrandSpotlight }"  v-if="!isGeneratingIndex && !showDefault" >
      <div class="catcher--title" >
        <div class="catcher--title__container" >
            <div class="title-container" style="position:relative">
              <span :class="{'catcher-title--reduced': useBrandSpotlight }">{{welcomeMessage}}</span>
              <div class="catcher--title__line complete-with"></div>
            </div>
        <img v-if="currentBrandLogo && useBrandSpotlight" :src="currentBrandLogo" class="catcher--title__logo">
      </div>
      </div>
      <div class="slider" :class="{ sliderBrand: useBrandSpotlight }" >
        <Slider
          v-bind:useBrandSpotlight="useBrandSpotlight"
          v-bind:products="products"
          v-bind:brands="brands"
          v-bind:product_Id="product_Id"
          v-bind:brand_Id="brand_Id"
          v-bind:url_Brand_Video="url_Brand_Video"
          v-bind:url_Brand_Image="url_Brand_Image"
          v-bind:fixed_button ="true"
          v-on:onUpdateBrandLogo="UpdateBrandLogo"
          />
      </div>
    </div>
    <div :class="{'cards-container': !isGeneratingIndex && !showDefault, 'cards-container-brand': useBrandSpotlight && !showDefault, 'default':showDefault}" >
      <screen-home-cards
        v-bind:isGeneratingIndex="isGeneratingIndex"
        v-bind:products="products"
        v-bind:brands="brands"

        v-bind:sharedScreenConfig="true"/>
    </div>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>
<script>
import Slider from '@/components/Slider'
import ScreenHomeCards from '@/components/ScreenHomeCards'
import { TimelineLite, Power3, Power2, Linear } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'
export default {
  name: 'ScreenHomeSpotlightCards',
  components: {
    ActiveCartButton,
    Slider,
    ScreenHomeCards
  },
  props: [
    'products', 'brands', 'isGeneratingIndex', 'isActiveCartFeatureActivated'
  ],
  data () {
    return {
      navLayout: 'large',
      reloadTimeout: null,
      storeLogo: null,
      storeLogoRatio: 'horizontal',
      welcomeMessage: null,
      useBrandSpotlight: false,
      product_Id: null,
      brand_Id: null,
      url_Brand_Image: null,
      url_Brand_Video: null,
      imgs: [],
      currentBrandLogo: null,
      currentCatalog: null
    }
  },
  created: function () {
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Set config
    this.product_Id = this.$config.PRODUCT_ID
    this.brand_Id = this.$config.BRAND_ID
    this.url_Brand_Image = this.$config.URL_BRAND_IMAGE
    this.url_Brand_Video = this.$config.URL_BRAND_VIDEO
    this.useBrandSpotlight = this.$config.USE_BRAND_SPOTLIGHT

    // Set default message
    if (this.useBrandSpotlight) {
      this.welcomeMessage = 'Brand Spotlight'
    } else {
      this.welcomeMessage = 'Product Spotlight'
    }
    this.$parent.$on('transition-leave', this.onTransitionLeave)
    // Call transition enter on next tick
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
      // Selectors
      var self = this
      var container = $(this.$el)
      var products = container.find('.product-card')

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
      // console.log('products', container.find('.products-grid'))
      tl.from(
        container.find('.products-grid'),
        1,
        {
          alpha: 0,

          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        0
      )

      var start = 0.3
      products.each(function () {
        var product = $(this)

        tl.from(
          product.add(product.find('.product-image')),
          0.8,
          {
            alpha: 0,
            scale: 0.8,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          start
        )

        tl.staggerFrom(
          product.find('.product-card__info > *'),
          0.5,
          {
            alpha: 0,
            y: 30,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          start + 0.4
        )

        start += 0.1

        product = null
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
      var self = this
      var container = $(el)
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
      tl.to(
        container.find('.products-grid'),
        0.5,
        {
          alpha: 0,
          y: -30,
          ease: Power2.easeIn
        },
        0
      )
      tl.to(
        container.find('.link'),
        0.5,
        {
          alpha: 0,
          y: -10,
          ease: Power2.easeIn
        },
        0
      )

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
    },
    /**
     * This method brigs the info of the current brand from the
     */
    UpdateBrandLogo: function (currentLogo) {
      this.currentBrandLogo = currentLogo
    }
  },
  computed: {
    showDefault: function () {
      if (!this.isGeneratingIndex && !this.useBrandSpotlight) {
        if (this.products) {
          let product = this.products.find(p => p.id === this.product_Id)
          if (!product) {
            return true
          }
        }
      } else if (!this.isGeneratingIndex && this.useBrandSpotlight) {
        if (this.brands) {
          let brand = this.brands.find(b => b.id === this.brand_Id)
          if (!brand) {
            return true
          }
        }
      }
      return false
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
  top: 120px;
  left: 60px;
  width: 400px;
  &--title{
    font-size: 50px;
    font-weight:100;
    position: relative;
    display: flex;
    align-items: center;
    font-family: muliextralight;
    &__container{
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    &__logo{
      width: 250px;
      height: auto;
    };
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

.catcher-title--reduced{
  font-size: 40px !important;
}

.catcher-brand{
  top: 250px !important;
  width: 550px !important;
}

.slider{
  margin-top: 25px;
}

.sliderBrand{
  margin-top: 0px !important;
}

.cards-container{
  width: calc(100% - 476px);
  position: absolute;
  right: 0px;
  height: 100%;
}

.cards-container-brand{
  width: calc(100% - 626px) !important;
}

.catcher--title__logo{
  position: absolute;
  right: 0px;
  bottom: 0px;
  max-height: 100px !important;
  max-width: 250px !important;
  height: auto !important;
  width: auto !important;
}

.complete-with{
  margin-left: 4px;
  width: 47px !important;
}

.title-container{
  overflow: hidden;
}

.default{
  width: 100% !important;
  height: 100% !important;
}

.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}

</style>
