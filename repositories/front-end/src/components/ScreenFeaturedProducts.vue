<template>
  <div
    id="screen-featured-products" class="screen screen--featured-products" style="opacity: 0;">
    <h1 class="screen__title">
      <div class="screen__title__text">
        {{title}}
      </div>
      <div class="screen__title__line"></div>
    </h1>

    <div v-if="$config.RFID_ENABLED" class="screen__intro">
      <!--{{ $config.TEXT.PICK_PRODUCT }}-->
    </div><!-- .screen__intro -->

    <div
      v-on:scroll="transformCards"
      class="products-grid">
      <div class="products">
        <product-card
          v-for="product in featuredProducts"
          v-bind:key="product.id"
          v-bind:product="product"
          v-bind:layout="'xlarge'"
          v-bind:source="'Featured Products'"
          ref="productCard">
        </product-card>
      </div><!-- .products -->
    </div><!-- .products-grid -->

    <button
      v-if="$config.RFID_ENABLED && $config.PICK_PRODUCT_ANIMATION"
      v-on:click="toggleModal"
      type="button"
      class="link-modal">
      ?
    </button>

    <portal to="modal-container" v-if="$config.RFID_ENABLED && $config.PICK_PRODUCT_ANIMATION && showModal">
      <modal-template class="modal--hide-close" key="featured-products">
        <div class="featured-modal">
          <div class="illustration">
            <lottie-container
              v-bind:path="'howto'"
              v-bind:autoplay="true"
              v-bind:loop="true"
              ref="lottieHowto"></lottie-container>
          </div><!-- .illustration -->

          <button
            v-on:click="toggleModal"
            type="button"
            class="featured-modal__button">
            <span class="featured-modal__button__text">
              Got it
            </span>
            <span class="featured-modal__button__background"></span>
          </button>
        </div>
      </modal-template>
    </portal>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import ModalTemplate from '@/components/ModalTemplate'
import { Portal, PortalTarget } from 'portal-vue'
import ProductCard from '@/components/ProductCard'
import {TimelineLite, Linear, Power2, Power3} from 'gsap/all'
import $ from 'jquery'

export default {
  name: 'ScreenFeaturedProducts',
  components: {
    LottieContainer,
    ModalTemplate,
    Portal,
    PortalTarget,
    ProductCard
  },
  props: [
    'featuredProductsModal',
    'products',
    'featuredProductsList'
  ],
  data () {
    return {
      showModal: false,
      title: 'Featured Products'
    }
  },
  computed: {
    featuredProducts () {
      return this.featuredProductsList
    }
  },
  created: function () {
    // Events
    this.$on('transition-leave', this.onTransitionLeave)
  },
  destroyed: function () {
    // Events
    this.$off('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {
    console.log('products inside spotlig', this.products)
    this.$nextTick(function () {
      // Set cards transformation first
      this.transformCards()

      this.$nextTick(function () {
        // Then call transition
        this.transitionEnter()
      })
    })
  },
  methods: {
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      let kioskConfig = localStorage.getItem('config_data')
      let obj = JSON.parse(kioskConfig)
      let navs = obj.catalog.layout.navigation.items
      let navItem = navs.filter(o => {
        return o.link === '/featured-products'
      })
      this.title = navItem[0].label

      // Selectors
      var self = this
      var container = $(this.$el)
      var products = container.find('.product-card')
      var animation = this.$refs.productCard && this.$refs.productCard.length > 0 ? this.$refs.productCard[0].$refs.lottieBlockIntro.animation : false

      // Before animation
      container.css({opacity: ''})

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container.find('.screen__title, .screen__intro'),
        0.5,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.1,
        0
      )

      tl.from(
        container.find('.screen__title__line'),
        0.5,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeInOut
        },
        0
      )

      tl.from(
        container.find('.products-grid'),
        0.5,
        {
          alpha: 0,
          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        0
      )

      products.first().each(function () {
        var product = $(this)

        tl.staggerFrom(
          product.add(product.find('.product-image')),
          0.8,
          {
            alpha: 0,
            scale: 0.8,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.2,
          0.3
        )

        tl.call(function () {
          if (animation !== false) {
            animation.play()

            animation = null
          }
        }, null, null, 0.6)

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
          0.7
        )

        product = null
      })

      tl.staggerFrom(
        products.slice(1, 3),
        0.8,
        {
          alpha: 0,
          x: 50,
          clearProps: 'transform, opacity',
          ease: Power2.easeOut
        },
        0.1,
        0.7
      )

      if (this.$config.RFID_ENABLED && this.featuredProductsModal === false) {
        tl.call(this.toggleModal)
      }

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

        tl.kill()

        tl = null
        container = null
        products = null
      })

      tl.play()
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)
      var products = container.find('.product-card')

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerTo(
        container.find('.screen__title, .screen__intro').reverse(),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.1,
        0
      )

      tl.to(
        container.find('.screen__title__line'),
        0.5,
        {
          scaleX: 0,
          ease: Power3.easeInOut
        },
        0
      )

      tl.to(
        container.find('.products-grid'),
        0.5,
        {
          alpha: 0,
          ease: Linear.easeNone
        },
        0
      )

      tl.to(
        products,
        0.5,
        {
          alpha: 0,
          scale: 0.9,
          ease: Power3.easeIn
        },
        0
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null
        products = null

        done()
      }, null, null, Math.max(1, tl.duration()))

      tl.play()
    },

    /**
     * Toggal instruction modal
     */
    toggleModal: function (event) {
      this.showModal = !this.showModal

      // Trigger event to track how many times the modal has been opened
      this.$root.$emit('featured-products-modal')
    },

    /**
     * Set cards transformation based on their position
     */
    transformCards: function (event) {
      var self = this
      var container = $('.products-grid')
      var cards = $('.product-card')
      var maxSpace = 360

      // Get container center
      var containerCenter = container.width() / 2

      cards.each(function (index) {
        var card = $(this)
        var box = card.find('.product-card__card')
        var animation = self.$refs.productCard[index].$refs.lottieBlockIntro.animation

        // Calculate distance between card center and container center
        var cardCenter = card.position().left + (card.outerWidth(true) / 2)
        var dist = containerCenter - cardCenter

        /// Keep distance within boundaries
        if (dist > maxSpace) {
          dist = maxSpace
        } else if (dist < -maxSpace) {
          dist = -maxSpace
        }

        // Calculate intensity based on distance
        var gap = dist / maxSpace
        var intensity = 1 - Math.sqrt(Math.pow(gap, 2))

        box.css({transform: 'perspective(50em) scale(' + (0.8 + (0.2 * intensity)) + ') rotateY(' + (gap * 30) + 'deg)'})

        if (gap >= -0.5 && gap <= 0.5) {
          // Show card highlighting when card is near center
          if (event !== undefined && !card.hasClass('is-active')) {
            animation.setDirection(1)
            animation.play()
          }
          card.addClass('is-active')
        } else {
          // Hide card highlighting when card is far from center
          if (event !== undefined && card.hasClass('is-active')) {
            animation.setDirection(-1)
            animation.play()
          }

          card.removeClass('is-active')
        }

        card = null
        box = null
      })

      container = null
      cards = null
    }
  }
}
</script>

<style scoped lang="scss">
  .screen {
    display: flex;
    padding: 110px 90px 0;

    flex-direction: column;
    justify-content: stretch;

    &__title {
      margin: 0 0 40px;
      position: relative;

      font: 80px/1 var(--font-extralight);
      text-indent: -0.08em;

      &__line {
        display: block;
        position: absolute;
        bottom: -10px;
        left: 0;
        width: 45px;
        height: 7px;

        background: var(--main-color);
        transform-origin: 0 0;
      }
    }

    &__intro {
      max-width: 650px;

      opacity: 0.3;

      @at-root .app--tablet & {
        opacity: 0.5;
      }
    }
  }

  .products-grid {
    margin: 30px -90px 0;
    padding: 20px 0 30px;

    overflow-x: scroll;
    overflow-y: hidden;
    mask-image: linear-gradient(to right, transparent 0%, rgba(0, 0, 0, 1.0) 10%, rgba(0, 0, 0, 1.0) 90%, transparent 100%);
    mask-origin: padding-box;
  }

  .products {
    display: flex;
    padding: 0;

    flex-direction: row;

    &:before,
    &:after {
      display: block;
      width: 600px;
      height: 460px;

      content: '';
      flex-grow: 0;
      flex-shrink: 0;
    }
  }

  .product-card {
    margin: 0 -20px;

    flex-grow: 0;
    flex-shrink: 0;

    &:first-child {
      margin-left: 0;
    }

    &:last-child {
      margin-right: 0;
    }
    &--xlarge {
      &.with-attributes{
        padding-bottom: 0px!important;
      }
    }

    /deep/ .product-image__waves {
      display: none;
    }

    /deep/ .product-card__background {
      background: rgba($white, 0.1);
      border-radius: 30px;
      transition: background 0.3s linear, opacity 0.3s linear;
    }
    /deep/ .product-card__highlight {
      border-radius: 30px;
      overflow: hidden;
    }

    &.is-active {
      /deep/ .product-card__card {
        opacity: 1;
      }
      // transform: perspective(50em) scale(1) rotateY(0) !important;

      /deep/ .product-card__background {
        // background: linear-gradient(219deg, rgba(#8314FF, 0.8) 0%, rgba(#FF239A, 0.8) 100%);
      }
    }
  }

  .link-modal {
    position: fixed;
    top: 130px;
    right: 30px;
    width: 70px;
    height: 70px;

    background-color: rgba($white, 0.05);
    border: none;
    border-radius: 50%;

    color: $white;
    font: 22px/1 var(--font-regular);
    text-indent: -999em;

    &:before {
      display: block;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 91px;
      height: 62px;

      background-image: url('~@/assets/img/howto-icon.svg');
      background-repeat: no-repeat;
      background-size: contain;
      transform: translate3d(-50%, -50%, 0);
      content: '';
    }
  }

  .featured-modal {
    .illustration {
      margin: 0 auto;
      position: relative;
      width: 705px;
      height: 494px;

      .lottie-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 1041px;
        height: 730px;

        transform: translate3d(-50%, -50%, 0);
      }
    }

    &__button {
      display: block;
      margin: 20px auto 0;
      position: relative;
      width: 100px;
      height: 50px;

      background: none;
      border: none;
      opacity: 1;
      transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1), opacity 0.2s linear;

      color: $white;
      font: 12px/50px var(--font-extrabold);
      letter-spacing: 0.2em;
      text-align: center;
      text-transform: uppercase;

      &__text {
        display: block;
        position: relative;

        z-index: 2;
      }

      &__background {
        position: absolute;
        top: 0;
        left: 50%;
        width: 100%;
        height: 100%;

        background: var(--main-color);
        border-radius: 25px;
        transform: translate3d(-50%, 0, 0);
      }
    }
  }

</style>
