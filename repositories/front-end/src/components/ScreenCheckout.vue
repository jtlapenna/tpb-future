<template>
  <div id="screen-checkout" class="screen screen--checkout" style="opacity: 0;">
    <button v-if="isActiveCartFeatureActivated" v-on:click="goBack()" type="button" class="link-back">
      <span class="link-back__arrow"></span>
      <span class="link-back__text">Back</span>
      <span class="link-back__background"></span>
    </button>
    <transition v-on:enter="onContentTransitionEnter" v-on:leave="onContentTransitionLeave" v-bind:css="false"
      mode="out-in">
      <div v-if="!result && this.$config.POS_TYPE !== 'shopify'" class="checkout" key="checkout">
        <div class="checkout__intro">
          <div v-if="!isActiveCartFeatureActivated" class="checkout__intro__text">
            Submit your info to complete your order. You can pay at the register.
          </div><!-- .checkout__intro__text -->

          <div v-if="isActiveCartFeatureActivated" class="checkout__intro__text__active-cart">
            <span v-if="isFromActiveCartActivation"> Submit your info to retrieve an </span>
            <span v-if="!isFromActiveCartActivation && !isFromCheckout"> Submit your info to create an </span>
            <span v-if="!isFromActiveCartActivation && isFromCheckout"> Submit your info to complete your order or check your items if you have an active cart. </span>
            <div v-if="!isFromCheckout" class="active-cart-info-icon">
              <active-cart-button v-bind:size="'small'" v-bind:info-mode="true"></active-cart-button>
            </div>
          </div>
          <span v-if="!isFromActiveCartActivation && !isFromCheckout" class="small-text">If you already have a cart, items will be added to it.</span>


          <div class="checkout__intro__separator"></div>
        </div><!-- .checkout__intro -->

        <component v-bind:is="checkoutComponent" v-bind:cart="cart" v-on:error="errorHandler" :discountCode="discountCode"
          v-on:success="successHandler" />

        <div v-bind:class="{ 'checkout__error--is-visible': error }" class="checkout__error">
          {{ error }}
        </div><!-- .checkout__error -->
      </div><!-- .checkout -->
    </transition>

    <transition v-on:enter="onContentTransitionEnter" v-on:leave="onContentTransitionLeave" v-bind:css="false"
      mode="out-in">
      <div v-if="result" key="result" class="result">
        <strong>Thank you</strong>
        <div>{{ result }}</div>

        <button v-on:click="restartSession" type="button" class="result__button">
          <span class="result__button__text">
            Start a new session
          </span><!-- .result__button__text -->
          <span class="result__button__background"></span>
        </button>
      </div><!-- .result -->
    </transition>
  </div><!-- .screen -->
</template>

<script>
import ScreenCheckoutEmail from '@/components/ScreenCheckoutEmail'
import ScreenCheckoutFlowhub from '@/components/ScreenCheckoutFlowhub'
import ScreenCheckoutLeaflogix from '@/components/ScreenCheckoutLeaflogix'
import ScreenCheckoutTreez from '@/components/ScreenCheckoutTreez'
import ScreenCheckoutCovasoft from '@/components/ScreenCheckoutCovasoft'
import ScreenCheckoutBlaze from '@/components/ScreenCheckoutBlaze.vue'
import ScreenCheckoutActiveCartCreator from '@/components/ScreenCheckoutActiveCartCreator'
import { TimelineLite, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import { mapGetters, mapMutations, mapState } from 'vuex'
import ScreenCheckoutShopifyVue from './ScreenCheckoutShopify.vue'
import ActiveCartButton from './ActiveCartButton.vue'
// import ScreenCheckoutShopify from './ScreenCheckoutShopify.vue'

export default {
  name: 'ScreenCheckout',
  components: { ActiveCartButton },
  props: ['cart', 'cartTotal', 'discountCode'],
  data() {
    return {
      checkoutComponent: null,
      error: null,
      result: null,
      timeout: null,
    }
  },
  computed: {
    ...mapState(['connected']),
    ...mapGetters('cart', ['isFromActiveCartActivation', 'isFromCheckout']),
    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },
  },
  created: function () {
    // Redirect to home if cart is empty
    console.log(this.cart)
    if (this.cart.length === 0 && !this.isActiveCartFeatureActivated) {
      this.$router.push({ name: 'home' })
    }

    // Set checkout type
    var checkout = false

    console.log('config.POS_TYPE: ', this.$config.POS_TYPE)
    switch (this.$config.POS_TYPE) {
      case 'flowhub':
        checkout = ScreenCheckoutFlowhub
        break
      case 'leaflogix':
        if (this.isActiveCartFeatureActivated) {
          checkout = ScreenCheckoutActiveCartCreator
        } else {
          checkout = ScreenCheckoutLeaflogix
        }
        break
      case 'treez':
        checkout = ScreenCheckoutTreez
        break
      case 'shopify':
        // this.result = 'Order Created successfully'
        checkout = ScreenCheckoutShopifyVue
        break
      case 'covasoft':
        checkout = ScreenCheckoutCovasoft
        break
      case 'blaze':
        checkout = ScreenCheckoutBlaze
        break
      case 'none':
        if (this.$config.ORDER_NOTIFICATION) {
          checkout = ScreenCheckoutEmail
        }
        break
    }

    if (checkout === false) {
      // Redirect to home if no checkout system matches
      this.$router.push({ name: 'home' })
    } else {
      this.checkoutComponent = checkout

      // Call transition enter on next tick
      this.$nextTick(this.transitionEnter)

      // Events
      this.$on('transition-leave', this.onTransitionLeave)
    }
  },
  destroyed: function () {
    // Events
    this.$off('transition-leave', this.onTransitionLeave)
    this.timeout && clearInterval(this.timeout)
  },
  mounted: function () {
    // Keyboard for general input
    $('.input-osk').onScreenKeyboard({
      rewireReturn: 'Continue'
    })
    $('.input-osk').on('keyup', function (e) {
      this.dispatchEvent(new Event('input'))
    })

    // Keyboard for phone input
    $('.input-phone').onScreenKeynumber({
      rewireReturn: 'Continue'
    })
    $('.input-phone').on('keyup', function (e) {
      this.dispatchEvent(new Event('input'))
    })

    // Hide keyboard
    $('#osk-container:visible .osk-hide').click()
    $('#osk-container-number:visible .osk-hide').click()

    setTimeout(() => {
      if (this.$config.POS_TYPE === 'shopify') {
        let message = this.$config.CHECKOUT_MESSAGE && self.$config.CHECKOUT_MESSAGE.trim() !== '' ? this.$config.CHECKOUT_MESSAGE : 'We will follow up about your order'
        this.successHandler(message)
      }
    }, 1000)
  },
  methods: {
    ...mapMutations('cart', ['resetActiveCartSession', 'setIsFromSaveCart', 'setIsFromCheckout', 'setIsFromActiveCartActivation']),
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Selectors
      var container = $(this.$el)

      // Before animation
      container.css({ opacity: '' })
      container.find('.checkout__button__text').css({ transition: 'none' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(container.find('.checkout__intro__text'), 0.5, {
        alpha: 0,
        y: 30,
        clearProps: 'transform, opacity',
        ease: Power3.easeOut
      })

      tl.from(container.find('.checkout__intro__text__active-cart'), 0.5, {
        alpha: 0,
        y: 30,
        clearProps: 'transform, opacity',
        ease: Power3.easeOut
      })

      tl.from(container.find('.small-text'), 0.5, {
        alpha: 0,
        y: 30,
        clearProps: 'transform, opacity',
        ease: Power3.easeOut
      })

      tl.from(
        container.find('.checkout__intro__separator'),
        0.5,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        0.1
      )

      tl.staggerFrom(
        container.find('.checkout__field, .checkout__error'),
        0.5,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.1,
        0.2
      )

      tl.from(
        container.find('.checkout__button__background'),
        0.5,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        0.3
      )
      tl.from(
        container.find(
          '.cart__qr_code__container'
        ),
        0.3,
        {
          alpha: 0,
          y: 30,
          ease: Power2.easeInOut
        },
        0.1
      )

      tl.from(
        container.find('.checkout__button__text'),
        0.5,
        {
          alpha: 0,
          y: 20,
          clearProps: 'transform, transition, opacity',
          ease: Power3.easeOut
        },
        0.6
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
        container.find('.checkout__button, .result__button'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0
      )

      tl.to(
        container.find(
          '.checkout__field, .checkout__error, .result > strong, .result > div'
        ),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.1
      )

      tl.to(
        container.find(
          '.cart__qr_code__container'
        ),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.1
      )

      tl.to(
        container.find('.checkout__intro__separator'),
        0.5,
        {
          scaleX: 0,
          ease: Power3.easeIn
        },
        0.2
      )

      tl.to(
        container.find('.checkout__intro__text'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.3
      )

      tl.to(
        container.find('.checkout__intro__text__active-cart'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.3
      )

      tl.to(
        container.find('.small-text'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0.3
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
        Math.max(1, tl.duration())
      )

      tl.play()
    },

    /**
     * Content transition enter
     */
    onContentTransitionEnter: function (el, done) {
      // Selectors
      var container = $(el)

      // Before animation

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container.find('> *'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeOut
        },
        0.1,
        0.5
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
     * Content transition leave
     */
    onContentTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Before animation

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        0.5,
        {
          alpha: 0,
          y: 50,
          clearProps: 'opacity, transform',
          ease: Power3.easeIn
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
     * Checkout error handler
     */
    errorHandler: function (message) {
      this.error = message
      if (this.$config.HEAP_ID) {
        /* eslint-disable */
        var cartSize = 0;
        let productsAnalytics = [];
        this.cart.forEach(function (product) {
          cartSize += product.qty;
          // heap.track('Cart Products', { item: product.product.name, quantity: product.qty })
          productsAnalytics.push({
            id: product.product.sku,
            name: product.product.name,
            brand: product.product.brand ? product.product.brand.name : "",
            category: product.product.catalog_category.name,
            quantity: product.qty,
            price: +product.price.value
          });
        });

        if (this.$gsClient) {
          this.$gsClient.track("Error on purchase", {
            event_category: "Sales",
            total_spend: this.cartTotal,
            cart_size: cartSize,
            currency: "USD",
            items: productsAnalytics
          }, {
            status: 'error',
            message: this.error
          });
        }

      }
    },

    /**
     * Checkout success handler
     */
    successHandler: function (message) {
      this.result = message

      // Track checkout on HEAP
      if (this.$config.HEAP_ID) {
        /* eslint-disable */
        var cartSize = 0;
        let productsAnalytics = [];
        this.cart.forEach(function (product) {
          cartSize += product.qty;
          // heap.track('Cart Products', { item: product.product.name, quantity: product.qty })
          productsAnalytics.push({
            id: product.product.sku,
            name: product.product.name,
            brand: product.product.brand ? product.product.brand.name : "",
            category: product.product.catalog_category.name,
            quantity: product.qty,
            price: +product.price.value
          });
        });

        if (this.$gsClient) {
          this.$gsClient.track("Purchase", {
            event_category: "Sales",
            total_spend: this.cartTotal,
            cart_size: cartSize,
            currency: "USD",
            items: productsAnalytics
          });
        }
        // heap.track('Cart Products', {Cart_Products: this.cart})
        /* eslint-enable */
      }

      // Hide keyboard
      $('#osk-container:visible .osk-hide').click()

      // Reset session
      this.$root.$emit('reset-session')
      this.resetActiveCartSession()
    },

    /**
     * Restart session
     */
    restartSession: function () {
      if (this.$gsClient) {
        this.$gsClient.track('Session ended', {
          reason: 'Checkout completed. Start a new session'
        })
      }
      this.$root.$emit('restart-session')
    },

    goBack: function() {
      this.$router.go(-1)
      this.timeout = setTimeout(() => {
        this.setIsFromCheckout(false)
        this.setIsFromSaveCart(false)
        this.setIsFromActiveCartActivation(false)
      }, 700)

    },
  }
}
</script>

<style scoped lang="scss">
.result {
  display: flex;
  padding: 150px 110px;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  align-items: center;
  flex-direction: column;
  justify-content: center;

  font: 1.5em/1.2 var(--font-extralight);
  text-align: center;

  strong {
    display: block;
    margin: 0 0 0.2em;

    font: normal 3.33em var(--font-extralight);
  }

  &__button {
    display: block;
    margin: 5em 0 0;
    position: relative;
    width: 16.5em;
    height: 4em;

    background: none;
    border: none;

    color: $white;
    font: 0.67em/4em var(--font-extrabold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;
    white-space: nowrap;

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
      border-radius: 2em;
      transform: translate3d(-50%, 0, 0);
      z-index: 1;
    }
  }
}

/deep/ .checkout {
  padding: 150px 45px 0 110px;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  &__intro {
    margin: 0 0 0.78em;
    padding: 0 0 0.78em;
    position: relative;
    width: 14.83em;

    font: 2.9em/1.2 var(--font-extralight);

    &__separator {
      position: absolute;
      left: 0;
      bottom: 0;
      width: 100%;
      height: 1px;

      background: rgba($white, 0.1);
    }
  }

  &__form {
    display: flex;
    width: 43em;

    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;

    &__fields {
      width: 100%;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;

      .checkout_form {
        &__field:first-child() {
          padding-right: 1rem;
        }
      }
    }
  }

  &__field {
    margin: 1em 0 0;

    &--half {
      width: calc(50% - 10px);

      &:nth-child(-n + 2) {
        margin-top: 0;
      }
    }

    &--full {
      width: 100%;

      &:nth-child(-n + 1) {
        margin-top: 0;
      }
    }
  }

  input,
  .inputs-container {
    display: block;
    padding: 0 20px;

    background: none;
    border: 3px solid rgba($white, 0.1);
    border-radius: 10px;

    color: $white;

    &:focus {
      border-color: $white;
    }
  }

  input {
    width: 100%;

    font: 1.25em/2.56em var(--font-light);

    &::placeholder {
      opacity: 0.5;

      color: $white;
      font: 1em/2.56em var(--font-light);
    }
  }

  .inputs-container {
    &__input {
      display: inline-block;
      padding: 0;
      width: auto;

      border: none;

      text-align: center;
    }

    &__separator {
      display: inline-block;

      &:before {
        content: " / ";
        opacity: 0.2;
      }
    }
  }

  &__error {
    margin: 1.25em 0 0;

    opacity: 0;
    transform: translate3d(0, 10px, 0);
    transition: all 0.2s cubic-bezier(0.55, 0.055, 0.675, 0.19);

    font: 1.1em var(--font-regular);

    &--is-visible {
      opacity: 1;
      transform: translate3d(0, 0, 0);
      transition: all 0.2s cubic-bezier(0.215, 0.61, 0.355, 1);
    }
  }

  &__button {
    position: fixed;
    right: 45px;
    bottom: 45px;
    width: 13em;
    height: 4em;

    background: none;
    border: none;

    color: $white;
    font: 1em/4em var(--font-extrabold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;

    &:after {
      display: block;
      position: absolute;
      top: calc(50% - 16px);
      left: calc(50% - 16px);
      width: 32px;
      height: 32px;

      background-image: url("~@/assets/img/loader.svg");
      background-repeat: no-repeat;
      background-size: cover;
      content: "";
      opacity: 0;
      transform: translate3d(0, 20px, 0);
      transition-delay: 0s;
      transition-duration: 0.2s;
      transition-property: opacity, transform;
      transition-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);
      z-index: 2;
    }

    &__text {
      display: block;
      position: relative;

      transition-delay: 0.2s;
      transition-duration: 0.2s;
      transition-property: opacity, transform;
      transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);
      z-index: 2;
    }

    &__background {
      position: absolute;
      top: 0;
      left: 50%;
      width: 100%;
      height: 100%;

      background: var(--main-color);
      border-radius: 2em;
      transform: translate3d(-50%, 0, 0);
      transition: filter 0.2s linear;
      z-index: 1;
    }

    &--sending {
      &:after {
        opacity: 1;
        transform: translate3d(0, 0, 0);
        transition-delay: 0.2s;
        transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);
      }

      .checkout__button__background {
        filter: grayscale(1);
      }

      .checkout__button__text {
        opacity: 0;
        transform: translate3d(0, -20px, 0);
        transition-delay: 0s;
        transition-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);
      }
    }
  }
}

.app--tablet .checkout {
  /deep/ {
    padding-top: 60px;

    .checkout {
      &__intro {
        margin-bottom: 0.5em;
        padding-bottom: 0.5em;
        width: 21.5em;

        font-size: 2em;
      }
    }

    input {
      font-size: 1.5em;
    }
  }
}

.checkout__intro__text__active-cart {
  font: 0.6em/1 var(--font-extralight);
  display: flex;
  flex-direction: row;
  position: relative;
  top: 1.1em;
}

.checkout__intro .small-text {
  font: 0.6em/1 var(--font-extralight);
  position: relative;
  top: 1.5rem;
}

.checkout__intro__text__active-cart .active-cart-info-icon {
  margin-left: 0.5em;
  position: relative;
  bottom: 0.6em;
}

.link-back {
  padding: 1.17em 1.67em 1.17em 1.83em;
  position: absolute;
  top: 40px;
  left: 45px;

  background: transparent;
  border: none;
  z-index: 2;

  color: $white;
  font: 0.6em/1 var(--font-semibold);
  letter-spacing: 0.15em;
  text-transform: uppercase;

  &__arrow {
    position: relative;
    display: inline-block;
    margin: 0 3px 0 0;
    width: 8px;
    height: 10px;

    vertical-align: top;
    z-index: 2;

    &:before,
    &:after {
      display: block;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 6px;
      height: 1px;

      background: $white;
      border-radius: 25%;
      content: '';
      transform-origin: 0 50%;
    }
    &:before {
      transform: translate3d(-50%, -50%, 0) rotateZ(-45deg);
    }
    &:after {
      transform: translate3d(-50%, -50%, 0) rotateZ(45deg);
    }
  }

  &__text {
    display: inline-block;
    position: relative;

    vertical-align: top;
    z-index: 2;
  }

  &__background {
    position: absolute;
    top: 0;
    left: 50%;
    width: 100%;
    height: 100%;

    background: rgba($white, 0.1);
    border-radius: 1.67em;
    transform: translate3d(-50%, 0, 0);
    z-index: 1;
  }
}


</style>
