<template>
  <div id="screen-cart" class="screen screen--cart" style="opacity: 0;">
    <h1 class="screen__title">
      My Cart
    </h1>

    <div class="cart">
      <div v-if="cart.length === 0" class="cart__empty">
        Your cart is empty.
      </div>

      <div v-if="cart.length === 0 && isActiveCartFeatureActivated && !isActiveCartNotFound" class="cart__empty--active-cart">
        <close-active-cart/>
      </div>

      <div v-if="cart.length === 0 && isActiveCartFeatureActivated && isActiveCartNotFound" class="cart__empty--active-cart">
        <active-cart-not-found/>
      </div>



      <div v-if="cart.length !== 0" class="cart__products">
        <div v-bind:class="{ 'cart__products--shopify': isShopify }">
          <div
            v-if="cart.length > 0"
            v-for="(line, index) in cart"
            v-bind:key="index"
            class="cart__product"
          >
            <div
              class="cart__product__separator  cart__product__separator--top"
            ></div>

            <router-link
              :to="{ name: 'product', params: { id: line.product.id } }"
            >
              <product-image
                v-bind:image="line.product.thumb_image"
                v-bind:category="line.product.catalog_category.name"
              />
            </router-link>

            <div style="width: 450px;" class="cart__product__info">
              <div class="cart__product__name">
                {{ line.product.name }}
              </div>
              <!-- .cart__product__name -->

              <div class="cart__product__selection">
                {{ line.qty }} x {{ line.price.name }}
              </div>
              <!-- .cart__product__selection -->

              <div class="cart__product__price">
                <span
                  :class="{
                    'price-discount':
                      line.priceDiscount !== line.price.basePrice &&
                      line.priceDiscount > 0
                  }"
                >
                  {{ (line.qty * line.price.basePrice) | formatPrice }}
                </span>
                <span
                  v-if="line.priceDiscount && line.priceDiscount > 0"
                  class="price-sale"
                >
                  {{ (line.qty * line.priceDiscount) | formatPrice }}
                </span>
              </div>
              <!-- .cart__product__selection -->

              <button
                v-on:click="toggleLine(index)"
                v-bind:class="{
                  'cart__product__edit-link--is-visible':
                    openedLines.indexOf(index) === -1
                }"
                type="button"
                class="cart__product__edit-link"
              >
                Edit
              </button>

              <form
                v-bind:class="{
                  'cart__product__edit-form--is-visible':
                    openedLines.indexOf(index) > -1
                }"
                class="cart__product__edit-form"
              >
                <div class="cart__product__edit-form__values">
                  <label
                    v-for="price in line.product.product_values"
                    v-bind:key="price.id"
                    v-bind:class="{
                      'cart__product__edit-form__value--is-active':
                        line.price === price
                    }"
                    class="cart__product__edit-form__value"
                  >
                    <input
                      type="radio"
                      v-bind:value="price"
                      v-model="line.price"
                    />

                    <div class="cart__product__edit-form__value__button">
                      <div class="cart__product__edit-form__value__price">
                        {{ price.value | formatPrice }}
                      </div>
                      <div class="cart__product__edit-form__value__name">
                        {{ price.name }}
                      </div>
                    </div>
                  </label>
                </div>
                <!-- .cart__product__edit-form__values -->

                <div class="cart__product__edit-form__quantity">
                  <button
                    v-on:click="line.qty = Math.max(0, line.qty - 1)"
                    v-bind:style="{ opacity: line.qty === 0 ? '0.2' : '' }"
                    type="button"
                    class="cart__product__edit-form__quantity__button cart__product__edit-form__quantity__button--minus"
                  >
                    -
                  </button>

                  <input
                    type="text"
                    v-model="line.qty"
                    class="cart__product__edit-form__quantity__field"
                  />

                  <button
                    v-on:click="line.qty = Math.min(line.maxQty, line.qty + 1)"
                    v-bind:style="{
                      opacity: line.qty === line.maxQty ? '0.2' : ''
                    }"
                    type="button"
                    class="cart__product__edit-form__quantity__button cart__product__edit-form__quantity__button--plus"
                  >
                    +
                  </button>
                </div>
                <!-- .cart__product__edit-form__quantity -->

                <button
                  v-on:click="toggleLine(index, true)"
                  type="button"
                  class="cart__product__edit-form__close"
                >
                  Done
                </button>
              </form>
              <!-- .cart__product__edit-form -->
            </div>
            <!-- .cart__product__info -->

            <div
              class="cart__product__separator  cart__product__separator--bottom"
            ></div>
          </div>
          <!-- .cart__product -->
        </div>
        <div
          class="code-container"
          v-if="isShopify && discountCode && cart.length > 0"
        >
          <span>Code used</span>
          <button
            class="cart__action cart__action--checkout cart__action--coupon"
          >
            <div class="cart__action__text">
              {{ discountCode }}
            </div>
            <!-- .cart__action__text -->
            <div
              class="cart__action__background checkout__button__background"
            ></div>
          </button>
        </div>
      </div>
      <!-- .cart__products -->

      <div v-if="cart.length > 0" class="cart__footer">
        <template v-if="isShopify">
          <div class="cart__total cart__total--justify-end">
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                Original Price:
              </div>
              <!-- .cart__total__title__text -->
            </div>
            <!-- .cart__total__title -->

            <div class="cart__total__value cart__total__value--lower">
              {{ cartTotal | formatPrice }}
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->

          <div
            class="cart__total cart__total--justify-end"
            v-if="discountCode && discountValue"
          >
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                Discount:
              </div>
              <!-- .cart__total__title__text -->
            </div>
            <!-- .cart__total__title -->

            <div class="cart__total__value cart__total__value--lower">
              {{ discountValue | formatPercentage }}
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->

          <div class="cart__has-promo" v-if="cartTotal === subTotal && hasPromo == true && !$config.ENABLE_REQUEST_TAXES">
            {{ $config.ON_SALE_TEXT }}
          </div>

          <div class="cart__actions cart__actions--qr">
            <div class="cart__actions__separator"></div>
            <div class="cart__action cart__action--qr--chekout">
              <div class="cart__action--qr--chekout-section-a">
                COMPLETE CHECKOUT ON YOUR MOBILE DEVICE
              </div>
              <div class="cart__action--qr--chekout-section-b">
                <div class="container-qr-background" v-if="shortLink">
                  <qrcode-vue
                    margin="0"
                    class="qr-code"
                    :value="shortLink"
                    size="120"
                  ></qrcode-vue>
                </div>
              </div>
              <div class="cart__action__background_qr"></div>
            </div>
          </div>

          <div
            v-on:click="showResetModal = true"
            class="cart__action cart__action--back cart__action__shopify"
          >
            <div class="cart__action__text">
              Reset Cart
            </div>
            <!-- .cart__action__text -->
            <div class="cart__action__background"></div>
          </div>
          <!-- .cart__actions -->
        </template>

        <template v-else-if="verifyTaxesAreAvailableForIntegration">
          <div class="cart__total--delay total-wrapper" v-if="showMainPrice">
            <div
              class="cart__total cart__total--delayTitle cart__total--justify-end align-right"
            >
              <div class="cart__total__title">
                <div class="cart__total__title__text">
                  Subtotal:
                </div>
              </div>
              <!-- .cart__total__title -->

              <div class="cart__total__value cart__total__value--lower">
                {{ taxObj.sub_total || subTotal | formatPrice }}
              </div>
              <!-- .cart__total__value -->
              <div
                v-if="!taxObj.tax_total && this.$config.DISABLE_TAX_MESSAGE!==true"
                :class="
                  taxObj.discount_total || taxObj.tax_total
                    ? 'cart__total__totalText'
                    : 'cart__total__taxText'
                "
              >
                {{ subTotal | formatPrice }}
                Prices do not include tax
              </div>
              <!-- .cart__total__tax -->
            </div>
            <!-- .cart__total -->
          </div>

          <div v-if="taxObj.discount_total" class="total-wrapper">
            <div
              class="cart__total cart__total--justify-end cart__total--delayOff align-right"
            >
              <div class="cart__total__title">
                <div class="cart__total__title_text">
                  DISCOUNT:
                </div>
              </div>

              <div class="cart__total__value cart__total__value--lower">
                {{
                  (taxObj.discount_total >= 0
                    ? taxObj.discount_total * -1
                    : taxObj.discount_total) | formatPrice
                }}
              </div>
            </div>
          </div>

          <div
            v-if="taxObj.tax_total"
            style="margin-bottom: 35px;"
            class="total-wrapper"
          >
            <div
              class="cart__total cart__total--justify-end cart__total--delayOff align-right"
            >
              <div class="cart__total__title">
                <div class="toggle-container">
                  <div
                    v-if="
                      this.storeType === 'leaflogix' &&
                        this.$config.ENABLE_TOGGLE_TAXES
                    "
                  >
                    <div
                      style="display: flex; font-size: 15px; justify-content: space-between; padding: 0 10px;"
                    >
                      <p>MED</p>
                      <p>REC</p>
                    </div>
                    <div class="cart__total__title__text">
                      <label class="switch">
                        <input
                          v-on:click="resetTaxes"
                          type="checkbox"
                          v-model="isRecreationalProduct"
                        />
                        <span class="slider round"></span>
                      </label>
                    </div>
                  </div>
                  <div class="cart__total__title__text space-toggle-container">
                    TAXES:
                  </div>
                </div>
                <!-- .cart__total__title__text -->
              </div>
              <!-- .cart__total__title -->

              <div
                class="cart__total__value cart__total__value--lower"
                ref="animatedElement1"
              >
                <span>{{ taxObj.tax_total | formatPrice }}</span>
              </div>
              <!-- .cart__total__value -->
            </div>
            <!-- .cart__total -->
          </div>

          <div
            v-if="taxObj.total && (taxObj.discount_total || taxObj.tax_total)"
            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 45px;"
          >
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                Total
              </div>
              <!-- .cart__total__title__text -->
              <div class="cart__total__title__line"></div>
            </div>
            <!-- .cart__total__title -->
            <div class="cart__total__value" ref="animatedElement2">
              <span>{{ taxObj.total | formatPrice }}</span>
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->
        </template>

        <template v-else>
          <div
            v-if="cartTotal - subTotal > 0"
            class="cart__total cart__total--justify-end"
          >
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                Subtotal:
              </div>
              <!-- .cart__total__title__text -->
            </div>
            <!-- .cart__total__title -->

            <div class="cart__total__value cart__total__value--lower">
              {{ subTotal | formatPrice }}
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->

          <div
            v-if="cartTotal - subTotal > 0"
            class="cart__total cart__total--justify-end"
          >
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                TAXES:
              </div>
              <!-- .cart__total__title__text -->
            </div>
            <!-- .cart__total__title -->

            <div class="cart__total__value cart__total__value--lower">
              {{ (cartTotal - subTotal) | formatPrice }}
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->

          <div class="cart__total">
            <div class="cart__total__title">
              <div class="cart__total__title__text">
                Total
              </div>
              <!-- .cart__total__title__text -->
              <div class="cart__total__title__line"></div>
            </div>
            <!-- .cart__total__title -->

            <div v-if="this.$config.DISABLE_TAX_MESSAGE!==true" class="cart__total__tax">
              Prices do not include tax
            </div>
            <!-- .cart__total__tax -->

            <div class="cart__total__value">
              {{ cartTotal | formatPrice }}
            </div>
            <!-- .cart__total__value -->
          </div>
          <!-- .cart__total -->
        </template>

        <div class="cart__has-promo" v-if="cartTotal === subTotal && hasPromo == true && !$config.ENABLE_REQUEST_TAXES">
          {{ $config.ON_SALE_TEXT }}
        </div>
        <div v-if="!isShopify" class="cart__actions">
          <div class="cart__actions__separator"></div>
          <div
            v-if="isActiveCartFeatureActivated && ((cart.length > 0 && isFromActiveCartActivation) || (isCartActivated && cart.length > 0))"
            class="keep-shopping-footer"
            >
            <active-cart-keep-shopping-finalize-order-footer
              v-bind:keep-shopping="keepShopping"
              v-bind:finalize-order="finalizeOrder"
            ></active-cart-keep-shopping-finalize-order-footer>
          </div>
          <div v-if="!isFromActiveCartActivation && !isCartActivated" class="cart__actions__separate-containers">
            <div v-on:click="showResetModal = true" class="cart__action cart__action--back"
                 :class="{'cart__action--back--active-cart-feature': isActiveCartFeatureActivated,
                 'cart__action__active-cart-feature': isActiveCartFeatureActivated}">
              <div class="cart__action__text">Reset Cart</div>
              <div class="cart__action__background"></div>
            </div>
            <div   v-if="isActiveCartFeatureActivated" v-on:click="saveCart"
                   class="cart__action cart__action--back cart__action--back--active-cart-feature cart__action__active-cart-feature">
              <div class="cart__action__text">Save Cart</div>
              <div class="cart__action__background"></div>
            </div>
            <button
              v-on:click="checkCart"
              :class="{ 'checkout__button--offline': isOffline,
              'cart__action--checkout--active-cart-feature': isActiveCartFeatureActivated,
              'cart__action__active-cart-feature': isActiveCartFeatureActivated }"
              class="cart__action cart__action--checkout"
            >
              <div class="cart__action__text">
                {{ !isOffline ? 'Checkout' : 'offline' }}
              </div>
              <div class="cart__action__background checkout__button__background"></div>
            </button>
          </div>
        </div>
        <!-- .cart__actions -->
      </div>
      <!-- .cart__footer -->
    </div>
    <!-- .cart -->

    <portal to="modal-container" v-if="showResetModal">
      <modal-template class="modal--hide-close modal--small" key="reset-modal">
        <div class="reset-modal">
          <h2 class="reset-modal__title">
            Reset Cart
          </h2>

          <div class="reset-modal__text">
            This will empty your cart and redirect you to home screen.<br />
            Do you want to continue?
          </div>

          <div class="reset-modal__actions">
            <div
              v-on:click="showResetModal = false"
              class="reset-modal__button reset-modal__button--back"
            >
              <div class="reset-modal__button__text">
                Continue session
              </div>
              <div class="reset-modal__button__background"></div>
            </div>
            <!-- .reset-modal__button -->

            <div v-on:click="resetSession" class="reset-modal__button">
              <div class="reset-modal__button__text">
                Start over
              </div>
              <div class="reset-modal__button__background"></div>
            </div>
            <!-- .reset-modal__button -->
          </div>
          <!-- .reset-modal__actions -->
        </div>
        <!-- .reset-modal -->
      </modal-template>
    </portal>

    <portal to="modal-container" v-if="showErrorModal">
      <modal-template class="modal--hide-close modal--small" key="error-modal">
        <div class="error-modal">
          <h2 class="error-modal__title">
            Sorry
          </h2>

          <div class="error-modal__text">
            {{ errorMessage }}
          </div>

          <div class="error-modal__actions">
            <div
              v-on:click="showErrorModal = false"
              class="error-modal__button"
            >
              <div class="error-modal__button__text">
                Got it
              </div>
              <div class="error-modal__button__background"></div>
            </div>
            <!-- .error-modal__button -->
          </div>
          <!-- .error-modal__actions -->
        </div>
        <!-- .error-modal -->
      </modal-template>
    </portal>
  </div>
  <!-- .screen -->
</template>

<script>
import ModalTemplate from '@/components/ModalTemplate'
import { Portal, PortalTarget } from 'portal-vue'
import ProductImage from '@/components/ProductImage'
import { TimelineLite, Linear, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'
import api from '../api/api'
import vuexStore from '../store/store'
import { GSAP_ANIMATION } from '@/const/globals.js'
import QrcodeVue from 'qrcode.vue'
import { firebaseConfig } from '../const/globals'
import { getOrderChanges } from '@/api/messaging'
import * as Sentry from '@sentry/vue'
import CloseActiveCart from './CloseActiveCart.vue'
import ActiveCartNotFound from './ActiveCartNotFound.vue'
import ActiveCartKeepShoppingFinalizeOrderFooter from './ActiveCartKeepShoppingFinalizeOrderFooter.vue'
import dayjs from 'dayjs'

export default {
  name: 'ScreenCart',
  components: {
    ActiveCartKeepShoppingFinalizeOrderFooter,
    ActiveCartNotFound,
    ModalTemplate,
    Portal,
    PortalTarget,
    ProductImage,
    QrcodeVue,
    CloseActiveCart
  },
  props: ['cart', 'cartTotal', 'isOffline', 'products'],
  data() {
    return {
      errorMessage: null,
      openedLines: [],
      discountCode: null,
      discountValue: 0,
      showErrorModal: false,
      showResetModal: false,
      hasPromo: false,
      shortLink: null,
      orderCode: null,
      unsubscribeFromOrder: null,
      codeInInput: null,
      taxes: null,
      storeType: null,
      taxObj: {},
      showMainPrice: false,
      duration: 1,
      isRecreationalProduct: false,
      finalizingOrder: false,
      isSending: false,
    }
  },
  computed: {
    ...mapState(['connected']),
    ...mapGetters('cart', ['isFromActiveCartActivation',
      'isActiveCartNotFound',
      'isCartActivated',
      ]),
    ...mapGetters('products', ['getFrozenPrices']),
    // TODO: Get this from the state?

    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },

    subTotal: function() {
      let subtotal = 0
      this.cart.forEach(line => {
        let catalogProduct = this.products.find(
          element => element.id === line.product.id
        )
        line.maxQty = catalogProduct.stock
        if (line.price) {
          subtotal += parseFloat(line.price.basePrice) * line.qty
        }
      })
      return subtotal
    },
    productsSku() {
      return this.cart.map(item => ({
        size_id: item.product.sku,
        quantity: item.qty,
        price: item.price.value,
        unit_price: item.price.basePrice,
        is_recreational_product: this.isRecreationalProduct
      }))
    },
    isShopify() {
      return this.$config.POS_TYPE === 'shopify'
    },
    verifyTaxesAreAvailableForIntegration() {
      return (
        this.storeType === 'treez' ||
        this.storeType === 'covasoft' ||
        this.storeType === 'leaflogix' ||
        this.storeType === 'blaze'
      )
    },
    attributes() {
      return this.orderCode && this.kioskId
        ? `order_id=${this.orderCode}&catalog_id=${this.kioskId}`
        : ''
    },
    kioskId() {
      return this.$config.API.CATALOG_ID
    },
    permaLink() {
      if (this.$config.STORE_URL) {
        let baseURl = this.$config.STORE_URL
        baseURl = baseURl.startsWith('https://')
          ? baseURl
          : `https://${baseURl}`

        this.cart.forEach((cartItem, index) => {
          const { product, qty } = cartItem
          let productSku = product.sku.split(':')
          baseURl = `${baseURl}${index === 0 ? '/cart/' : ','}${
            productSku[productSku.length - 1]
          }:${qty}`
        })

        if (this.attributes) {
          baseURl = `${baseURl}?${this.attributes}`
        }

        if (this.discountCode) {
          baseURl = `${baseURl}${this.attributes ? '&' : '?'}discount=${
            this.discountCode
          }`
        }

        return baseURl
      }
      return ''
    }
  },
  watch: {
    cart: function(newCart, oldCart) {
      // show current cart and old cart when updated
      console.log(
        '%c OLD CART %o',
        'background-color:#000;color:white;',
        oldCart
      )

      console.log(
        '%c NEW CART %o',
        'background-color:#000;color:white;',
        newCart
      )

      this.getShortLinks()
    }
  },
  filters: {
    taxAdded: function(price, product) {
      let lowestTax = 0
      let categoryTaxes = product.category_taxes
      let storeTaxes = product.store_taxes
      if (categoryTaxes && categoryTaxes.length > 0) {
        lowestTax = Math.min.apply(
          Math,
          categoryTaxes.map(a => a.value)
        )
      } else if (storeTaxes && storeTaxes.length > 0) {
        lowestTax = Math.min.apply(
          Math,
          storeTaxes.map(a => a.value)
        )
      }
      if (lowestTax === 0) return price
      let numPrice = parseFloat(price)
      return parseFloat(numPrice + numPrice * (lowestTax / 100))
    },
    formatPrice: function(price) {
      let numPrice = Number(price).toFixed(2)
      return '$' + numPrice
    }
  },
  created: function() {
    const self = this;
    vuexStore.dispatch('setTotalCart', null)
    this.storeType = this.$config.POS_TYPE
    var promos = 0
    this.cart.forEach(line => {
      let catalogProduct = self.products.find(
        element => element.id === line.product.id
      )
      line.maxQty = catalogProduct.stock

      if (line.product.store_product_promotions.length > 0) {
        promos = promos + 1
      }
      console.log(
        'HAS PROMO',
        line.product.store_product_promotions.length > 0,
        promos
      )
    })

    this.isRecreationalProduct = this.$config.CUSTOMER_TYPE_RECREATIONAL

    // set message if promo on products
    self.hasPromo = promos > 0

    if (
      this.$config.ENABLE_REQUEST_TAXES ||
      (this.storeType === 'treez' &&
        this.$config.PAYMENT_GATEWAY.NAME === 'Aeropay')
    ) {
      this.fetchTaxes(true)
    } else {
      this.showMainPrice = true
      this.taxObj = { sub_total: this.subTotal, discount_total: this.subTotal - this.cartTotal, total: this.cartTotal }
    }

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$on('transition-leave', this.onTransitionLeave)
  },
  mounted: function() {
    // Keyboard
    if (this.$config.PRODUCT_UI === 'condensed') {
      $('.input').onScreenKeyboard({
        rewireReturn: 'search'
      })

      $('.input').on('keyup', function(e) {
        this.dispatchEvent(new Event('input'))
      })
    } else {
      $('.input-osk').onScreenKeyboard({
        rewireReturn: 'search'
      })

      $('.input-osk').on('keyup', function(e) {
        this.dispatchEvent(new Event('input'))
      })
    }

    // Hide keyboard
    $('#osk-container:visible .osk-hide').click()
    // listen click outside keyboard in order to hide it
    this.listenClick()

    if (this.isShopify) {
      this.orderCode = this.generateCode()
      this.listenForOrderUpdate()
      this.checkCart()
    }
  },
  destroyed: function() {
    // Events
    this.setIsActiveCartNotFound(false)
    this.$off('transition-leave', this.onTransitionLeave)
  },

  beforeDestroy() {
    if (this.unsubscribeFromOrder != null) {
      this.unsubscribeFromOrder()
    }
  },
  methods: {
    ...mapMutations('cart', ['setIsFromActiveCartActivation', 'setIsActiveCartNotFound', 'setIsFromSaveCart', 'resetActiveCartSession', 'setIsFromCheckout']),
    ...mapActions('cart', ['updateProductInActiveCart']),
    animateCartTotalValue() {
      // Selectors
      var container1 = $(this.$refs.animatedElement1)
      var container2 = $(this.$refs.animatedElement2)

      // Before animation
      container1.add(container2).css({ opacity: '' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container1,
        this.duration,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container2,
        this.duration,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container1 = null
        container2 = null
      })

      tl.play()
    },

    resetTaxes() {
      this.isRecreationalProduct = !this.isRecreationalProduct
      this.fetchTaxes()
    },

    /**
     * Generate an aleatory code for the order
     */

    generateCode(length = 20) {
      let result = ''
      const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
      for (let i = 0; i < length; i++) {
        result += characters.charAt(
          Math.floor(Math.random() * characters.length)
        )
      }
      return result
    },

    listenForOrderUpdate() {
      let self = this
      const env = self.currentEnv.name !== 'prod' ? self.currentEnv.name : null
      this.unsubscribeFromOrder = getOrderChanges(
        {
          kioskId: this.kioskId,
          orderId: this.orderCode,
          env
        },
        data => {
          console.log(data)
          if (data) {
            let message = self.$config.CHECKOUT_MESSAGE
              ? self.$config.CHECKOUT_MESSAGE
              : 'Please pick up your order at the designated register.'
            this.$emit('success', message)
          }
        }
      )
    },

    /**
     * Screen transition enter
     */
    transitionEnter: function() {
      // Selectors
      var container = $(this.$el)

      // Before animation
      container.css({ opacity: '' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container.find('.screen__title, .cart__empty'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.cart__product__separator:visible').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.product-image').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.keep-shopping-footer').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.cart__empty--active-cart').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.cart__product__info').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.cart__product__price').slice(0, 5),
        GSAP_ANIMATION.duration,
        {
          x: -10,
          alpha: 0,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.from(
        container.find('.cart__total__title__text'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -10,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.cart__has-promo'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -10,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.cart__total__title__line'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerFrom(
        container.find('.cart__total__value, .cart__total__tax'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.from(
        container.find('.cart__actions__separator'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.cart__actions__separator'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerFrom(
        container.find('.cart__action__background'),
        GSAP_ANIMATION.duration,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.cart__action__text, .cart__offline-message'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.keep-shopping-finalize-order'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 200,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null
      })

      tl.play()
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function(el, done) {
      // Selectors
      var container = $(this.$el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.cart__product').reverse(),
        GSAP_ANIMATION.duration,
        {
          alphcheckCarta: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.screen__title, .cart__empty'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerTo(
        container.find('.cart__footer > *').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerTo(
        container.find('.keep-shopping-footer > *').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerTo(
        container.find('.cart__empty--active-cart').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerTo(
        container.find('.keep-shopping-finalize-order').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 200,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.call(
        function() {
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

    saveCart() {
      var self = this

      this.errorMessage = null

      // Format cart
      var items = []
      self.cart.forEach(function(line) {
        var item = {
          name: line.product.name,
          brand: line.product.brand ? line.product.brand.name : '',
          category: line.product.catalog_category.name,
          price: line.price.value,
          base_price: line.price.basePrice,
          product_id: line.product.id,
          product_value_id: line.price.id,
          quantity: line.qty,
          tag_list: line.product.tag_list,
          stock: line.product.stock
        }

        items.push(item)
      })

      var cart = {
        items: items
      }

      // Check order
      console.log('Checking cart', cart)
      if (self.$gsClient) {
        self.$gsClient.track('Checking cart', { items: cart.items })
      }

      self.$http
        .post('/carts/validate', {
          cart: cart
        })
        .then(function(response) {
          if (response.data.success === true) {
            if (self.isShopify) {
              self.getShortLinks()
            } else {
              self.setIsFromActiveCartActivation(false)
              self.setIsFromSaveCart(true)
              self.$router.push({ name: 'checkout' })
            }
          } else {
            self.errorMessage = response.data.message
            self.showErrorModal = true
          }
        })
        .catch(function(error) {
          // Validation error
          Sentry.captureException(error)
          console.log('error check', error)
          self.errorMessage = error.response.data.message
          self.showErrorModal = true
        })
    },

    /**
     * Check cart
     */
    checkCart: function(e) {
      var self = this

      this.errorMessage = null

      // Format cart
      var items = []
      self.cart.forEach(function(line) {
        var item = {
          name: line.product.name,
          brand: line.product.brand ? line.product.brand.name : '',
          category: line.product.catalog_category.name,
          price: line.price.value,
          base_price: line.price.basePrice,
          product_id: line.product.id,
          product_value_id: line.price.id,
          quantity: line.qty,
          tag_list: line.product.tag_list,
          stock: line.product.stock
        }

        items.push(item)
      })

      var cart = {
        items: items
      }

      // Check order
      console.log('Checking cart', cart)
      if (self.$gsClient) {
        self.$gsClient.track('Checking cart', { items: cart.items })
      }

      self.$http
        .post('/carts/validate', {
          cart: cart
        })
        .then(function(response) {
          if (response.data.success === true) {
            if (self.isShopify) {
              self.getShortLinks()
            } else {
              self.setIsFromActiveCartActivation(false)
              self.setIsFromCheckout(true)
              self.$router.push({ name: 'checkout' })
            }
          } else {
            self.errorMessage = response.data.message
            self.showErrorModal = true
          }
        })
        .catch(function(error) {
          // Validation error
          Sentry.captureException(error)
          console.log('error check', error)
          self.errorMessage = error.response.data.message
          self.showErrorModal = true
        })
    },

    /**
     * Get Short links from firebase
     */
    getShortLinks: function() {
      let body = {
        dynamicLinkInfo: {
          domainUriPrefix: 'https://url.aimservices.tech',
          link: this.permaLink
        }
      }
      console.log('permalink', body)
      try {
        this.$httpEmpty
          .post(
            `https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${firebaseConfig.apiKey}`,
            body
          )
          .then(response => {
            this.shortLink = response.data.shortLink
          })
          .catch(error => {
            console.log(error)
            this.shortLink = this.permaLink
          })
      } catch (error) {
        Sentry.captureException(error)
        console.log(this.permaLink)
        this.shortLink = this.permaLink
      }
    },

    /**
     * Delete from cart
     * @param  {Integer} index
     */
    deleteFromCart: function(index) {
      // Trigger global delete from cart event
      this.$root.$emit('delete-from-cart', index)
    },

    /**
     * Reset link
     */
    resetSession: function() {
      if (self.$gsClient) {
        self.$gsClient.track('Session ended', { reason: 'Reset Cart' })
      }
      // Reset session
      this.$root.$emit('restart-session')
    },

    /**
     * Toggle line edit form
     * @param  {Integer} index
     */
    toggleLine: function(index, disableTreezRequest = false) {
      var self = this
      if (this.openedLines.indexOf(index) === -1) {
        // Line is not yet open, open it
        this.openedLines.push(index)
      } else {
        // Line is open, close it but leave others opened
        var newOpenedLines = []


        this.openedLines.forEach(function(newIndex) {
          if (newIndex !== index) {
            newOpenedLines.push(newIndex)
          }
        })

        this.openedLines = newOpenedLines

        this.cart.forEach(function(line, loopIndex) {
          if (loopIndex === index) {
            if (self.$gsClient) {
              self.$gsClient.track('Edit cart', {
                product_id: line.product.id,
                name: line.product.name,
                qty: line.qty,
                maxQty: line.maxQty,
                price: line.price.value
              })
            }
            try {
              if (self.isActiveCartFeatureActivated) {
                self.updateProductInActiveCart({productId: line.product.id, quantity: line.qty})
              }
            } catch(e) {
              console.log(e)
            }
          }
        })

        this.cart.forEach(function(line, index) {
          // If line qty is null remove it from cart
          if (line.qty === 0) {
            self.deleteFromCart(index)
          }
        })
        if (self.isShopify) {
          self.getShortLinks()
        }
      }

      if (this.$config.ENABLE_REQUEST_TAXES && this.storeType !== 'leaflogix') {
        this.fetchTaxes()
      }

      if (
        this.$config.ENABLE_REQUEST_TAXES &&
        disableTreezRequest &&
        this.storeType === 'leaflogix'
      ) {
        this.fetchTaxes()
      }
    },


    listenClick() {
      $(document).on('click', e => {
        // get keyboard element
        const keyboard = $('#osk-container')
        const inputForm = $('input')

        // if the target of the click isn't the container nor a descendant of the container
        if (
          !e.target.classList.contains(
            this.$config.PRODUCT_UI === 'condensed' ? 'input' : 'input-osk'
          )
        ) {
          if (!inputForm.is(e.target) && keyboard.find(e.target).length === 0) {
            $('#osk-container:visible .osk-hide').click()
          }
        }
      })
    },

    /**
     * Fetch cart taxes
     */
    async fetchTaxes(fromMountedHookCycle = false) {
      if (
        this.$config.ENABLE_REQUEST_TAXES ||
        (this.storeType === 'treez' &&
          this.$config.PAYMENT_GATEWAY.NAME === 'Aeropay')
      ) {
        try {
          const response = await api.getTaxes({
            order: {
              items: this.productsSku
            }
          })
          if (response) {
            this.taxObj = {
              sub_total: response.data.order.sub_total,
              discount_total: response.data.order.discount_total,
              tax_total: response.data.order.tax_total,
              total: response.data.order.total
            }
          } else {
            this.taxObj = {
              sub_total: null,
              discount_total: null,
              tax_total: null,
              total: null
            }
          }
          this.animateCartTotalValue()
          vuexStore.dispatch('setTotalCart', response.data.order.total)
          this.showMainPrice = true
          if (fromMountedHookCycle) {
            this.$nextTick(() => {
              this.titleWithDelay()
            })
          }
          console.log('ORDER TAXES RESPONSE', response.data.order)
        } catch (e) {
          Sentry.captureException(e)
          this.taxObj.sub_total = this.subTotal
          if (this.showMainPrice === false) {
            this.showMainPrice = true
            this.$nextTick(() => {
              this.titleWithDelay()
            })
          }
          if (this.taxObj.tax_total && this.taxObj.total) {
            this.taxObj.tax_total = null
            this.taxObj.total = null
            vuexStore.dispatch('setTotalCart', null)
            this.titleWithDelay()
          }
          console.error(e)
        }
      }
    },
    keepShopping() {
      this.$root.$emit('reset-session')
      this.resetActiveCartSession()
      this.$router.push({name: 'keep-shopping'})
    },

    finalizeOrder() {
      this.isFinalizingOrder = true
    },

    isSingleItemCart() {
      return this.cart.length === 1
    },

    isTwoItemsCart() {
      return this.cart.length === 2
    },

    isMultipleItemsCart() {
      return this.cart.length > 2
    },

  }
}
</script>

<style scoped lang="scss">
.screen {
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  padding: calc(230px - 4em) 45px 0 90px;

  flex-direction: column;
  justify-content: stretch;

  &__title {
    margin: 0;

    font: 4em/1 var(--font-extralight);
  }
}

.total-wrapper {
  display: block;
  height: 95px;

  .align-right {
    float: right;
  }
}

.cart {
  margin: 2.5em 0 0;
  position: relative;

  flex-grow: 1;

  // I'm sorry future self, but I can't change parent container to use flex because I don't
  // know the implications of that with other components.
  &__empty--active-cart {
    margin: -2.5m auto 0;
    text-align: center;
    position: absolute;
    top: 35%;
    left: 45%;
    transform: translate(-50%, -50%);
  }
  &__products {
    margin: 0 -10px;
    padding: 0 15px 45px 10px;
    position: absolute;
    top: 0;
    left: 0;
    width: 850px;
    height: 100%;

    overflow-x: hidden;
    overflow-y: scroll;

    &--shopify {
      max-height: 74%;
      overflow-x: hide;
      overflow-y: auto;
    }
  }

  &__has-promo {
    font: 0.8em/1 var(--font-bold);
    margin: 2.5rem 0px 1em;
    //opacity: 0.4;
    line-height: 1.25em;
    letter-spacing: 0.135em;
    text-transform: uppercase;
    text-align: center;
    color: var(--main-color);
  }

  &__product {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    padding: 30px 90px 30px 0;
    position: relative;

    align-items: flex-start;
    flex-direction: row;
    justify-content: flex-start;

    &__separator {
      display: block;
      position: absolute;
      left: 0;
      width: 100%;
      height: 1px;

      background: rgba($white, 0.3);

      &--top {
        top: 0;
      }

      &--bottom {
        display: none;
        bottom: 0;
      }
    }

    &:last-child .cart__product__separator--bottom {
      display: block;
    }

    &__name {
      margin: 10px 0 0;

      font: 1em/1.4 var(--font-extralight);
      letter-spacing: 0.05em;
    }

    &__selection {
      color: rgba($white, 0.5);
      font: 1em/1.4 var(--font-light);
    }

    &__price {
      position: absolute;
      top: 46px;
      right: 0;

      font: 0.9em/1 var(--font-extrabold);
      letter-spacing: 0.1em;

      @at-root .app--tablet & {
        font-size: 1em;
      }
    }

    &__edit-link {
      margin: 0;
      padding: 0;
      height: 0;

      background: none;
      border: none;
      overflow: hidden;
      transition-duration: 0.3s;
      transition-property: height, margin;
      transition-timing-function: cubic-bezier(0.645, 0.045, 0.355, 1);

      color: var(--main-color);
      font: 0.8em/1 var(--font-semibold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &--is-visible {
        margin-top: 0.63em;
        height: 1em;
      }
    }

    &__edit-form {
      margin: 0;
      height: 0;

      overflow: hidden;
      transition-duration: 0.3s;
      transition-property: height, margin;
      transition-timing-function: cubic-bezier(0.645, 0.045, 0.355, 1);

      &__values {
        display: -webkit-box;
        display: -ms-flexbox;
        display: flex;
        margin: 0 0 1em;

        flex-direction: row;
        justify-content: flex-start;
      }

      &__value {
        margin: 0 1.25em 0 0;
        overflow: hidden;
        position: relative;
        width: 6.25em;
        height: 5.63em;

        font: 0.8em/1 var(--font-bold);
        text-align: center;

        input {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;

          opacity: 0;
        }

        &__button {
          display: -webkit-box;
          display: -ms-flexbox;
          display: flex;
          padding: 10px;
          width: 100%;
          height: 100%;

          background: none;
          border-radius: 1.25em;
          flex-direction: column;
          justify-content: center;
        }

        &__price {
          font-size: 1.38em;
        }

        &__name {
          overflow: hidden;
          margin: 5px 0 0;
          max-height: 2em;

          font-size: 0.88em;
          letter-spacing: 0.05em;
          text-transform: uppercase;
        }

        &--is-active {
          .cart__product__edit-form__value__button {
            background-color: rgba($white, 0.1);
          }
        }

        &:last-child {
          margin-right: 0;
        }
      }

      &__quantity {
        float: left;
        margin: 0 1.5em 0 0;

        &__field {
          width: 3.06em;
          height: 2.44em;

          background: none;
          border: none;
          vertical-align: top;

          color: $white;
          font: 0.9em/2.44em var(--font-semibold);
          text-align: center;
        }

        &__button {
          display: inline-block;
          position: relative;
          width: 2.2em;
          height: 2.2em;

          background: rgba($white, 0.1);
          border: none;
          border-radius: 50%;
          vertical-align: top;

          text-align: center;

          &:before,
          &:after {
            display: block;
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0.5em;
            height: 0.1em;

            background: $white;
            content: '';
            transform: translate3d(-50%, -50%, 0);
          }

          &--plus:after {
            transform: translate3d(-50%, -50%, 0) rotateZ(90deg);
          }
        }
      }

      &__close {
        float: left;
        width: 8.33em;
        height: 3.67em;

        background: var(--main-color);
        border: none;
        border-radius: 1.83em;

        color: $white;
        font: 0.6em/3.67em var(--font-extrabold);
        letter-spacing: 0.2em;
        text-align: center;
        text-transform: uppercase;
      }

      &--is-visible {
        height: 7.7em;
      }
    }
  }

  &__footer {
    position: fixed;
    right: 45px;
    bottom: 80px;
    width: 560px;
    display: flex;
    flex-direction: column;

    @at-root .app--tablet & {
      bottom: 100px;
    }
  }

  &__total {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    padding: 0 0 1.25em;

    align-items: center;
    flex-direction: row;
    justify-content: space-between;

    &__title {
      display: block;
      padding: 0 0 0.63em;
      position: relative;

      font: 0.8em/1 var(--font-extrabold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

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

    &__value {
      margin-right: -0.06em;

      font: 4em/1 var(--font-extralight);

      &--lower {
        font: 3em/1 var(--font-extralight) !important;
        min-width: 280px;
        text-align: end;
      }

      &--lower {
        font: 3em/1 var(--font-extralight) !important;
        min-width: 280px;
        text-align: end;
      }
    }

    &__tax {
      position: absolute;
      top: 7.45em;
      right: 0;

      opacity: 0.4;
      z-index: 4;

      font-size: 0.55em;
      letter-spacing: 0.135em;
      line-height: 1;
      text-transform: uppercase;

      @at-root .app--tablet & {
        top: 5.4em;
        font-size: 0.8em;
      }
    }

    &__totalText {
      position: absolute;
      top: 25.45em;
      right: 0;

      opacity: 0.4;
      z-index: 4;

      font-size: 0.55em;
      letter-spacing: 0.135em;
      line-height: 1;
      text-transform: uppercase;

      @at-root .app--tablet & {
        top: 15.6em;
        font-size: 0.8em;
      }
    }

    &__taxText {
      position: absolute;
      top: 6.8em;
      right: 0;

      opacity: 0.4;
      z-index: 4;

      font-size: 0.55em;
      letter-spacing: 0.135em;
      line-height: 1;
      text-transform: uppercase;

      @at-root .app--tablet & {
        top: 4.4em;
        font-size: 0.8em;
      }
    }

    &--justify-end {
      -webkit-box-pack: end;
      -ms-flex-pack: end;
      justify-content: end;
    }
  }

  &__actions {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    position: relative;
    margin-top: 15px;

    &--qr {
      flex-direction: column;
    }

    &__separator {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 1px;

      background: rgba($white, 0.1);
    }

    &__separate-containers {
      display: flex;
      width: 100%;
      justify-content: space-between;
      margin-top: 1em;
    }

  }

  &__action {
    position: relative;
    width: 260px;
    height: 4em;

    background: transparent;
    border: none;

    color: $white;
    font: 1em/4em var(--font-extrabold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;

    &__active-cart-feature {
      font: 0.7em/4em var(--font-extrabold);
    }

    &__shopify {
      margin-right: auto;
      margin-left: auto;
    }

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

      background: $ebonyclay;
      border-radius: 2em;
      transform: translate3d(-50%, 0, 0);
      z-index: 1;

      &_qr {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1;
        background: white;
        color: #ffffff;
        opacity: 0.3;
        border-radius: 2em;
      }
    }

     &--back--active-cart-feature,&--checkout--active-cart-feature {
       margin-left: 1.5rem;
     }

    &--checkout {
      &--active-cart-feature {
        margin-left: 1.5rem;
      }
      .cart__action__background {
        background: var(--main-color);
      }
    }

    &--coupon {
      margin-left: 1rem;
    }

    &--qr--chekout {
      margin-bottom: 30px;
      width: 100%;
      min-height: 170px;
      display: -webkit-box;
      display: -ms-flexbox;
      display: flex;
      justify-content: space-between;
      height: auto;
      padding: 20px 0;

      &-section-a {
        width: 70% !important;
        line-height: 30px;
        display: -webkit-box;
        display: -ms-flexbox;
        display: flex;
        align-items: center;
      }

      &-section-b {
        width: 30% !important;
      }
    }
  }

  &__offline-message {
    position: absolute;
    right: 0;
    width: 260px;

    color: rgba($white, 0.3);
    font: 0.55em/1.3 var(--font-semibold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;

    @at-root .app--tablet & {
      font-size: 0.7em;
    }
  }

  &__qr_code__container {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    width: 50%;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 1em;

    &__label {
      text-align: center;
      margin-bottom: 16px;
      font-size: 16px;
    }
  }
}

.product-image {
  margin: 0 30px 0 0;
  width: 100px;
}

.reset-modal {
  text-align: center;

  &__title {
    margin: 0;

    font: 50px/1 var(--font-extralight);
  }

  &__text {
    margin: 20px 0 40px;

    // opacity: 0.5;
  }

  &__actions {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    position: relative;

    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
  }

  &__button {
    margin: 0 0 0 20px;
    position: relative;
    width: 200px;
    height: 50px;

    background: none;
    border: none;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
      opacity 0.2s linear;

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

    &:first-child {
      margin-left: 0;
    }

    &--back {
      .reset-modal__button__background {
        background: $ebonyclay;
      }
    }
  }
}

.error-modal {
  text-align: center;

  &__title {
    margin: 0;

    font: 50px/1 var(--font-extralight);
  }

  &__text {
    margin: 20px 0 40px;

    // opacity: 0.5;
  }

  &__actions {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    position: relative;

    flex-direction: row;
    justify-content: center;
  }

  &__button {
    margin: 0 0 0 20px;
    position: relative;
    width: 200px;
    height: 50px;

    background: none;
    border: none;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
      opacity 0.2s linear;

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

.inputs-container {
  width: 100%;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;

  input {
    margin: 0px 0px 0px 1em;
    width: 75%;
    font-size: 20px;
    padding: 0.5em 0.75em;
    display: block;
    background: none;
    border: 2px solid rgba($white, 0.1);
    border-top-left-radius: 10px;
    border-bottom-left-radius: 10px;
    color: $white;
    flex-grow: 1;

    &:focus {
      border-color: $white;
    }
  }

  &__separator {
    display: inline-block;

    &:before {
      content: ' / ';
      opacity: 0.2;
    }
  }

  &__input-control {
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    flex-grow: 1;
  }

  &__search-coupon {
    display: block;
    overflow: hidden;
    margin: 0px 0 0;
    position: relative;
    width: 2em;
    height: 45px;

    background-color: $charade;
    border: none;
    border-top-right-radius: 10px;
    border-bottom-right-radius: 10px;

    color: transparent;
    text-indent: -999em;

    &:before {
      display: block;
      margin: -0.35em 0 0 -0.55em;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 1em;
      height: 0.8em;

      background-image: url('~@/assets/img/icon-search.svg');
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
      content: '';
    }
  }
}

.container-qr-background {
  width: 130px;
  height: 130px;
  background: #ffffff;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  justify-content: center;
  align-items: center;
}

.qr-code {
  width: 120px;
  height: 120px;
}

.code-container {
  font-weight: bold;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
}

.toggle-container {
  display: flex;
  justify-content: center;
  align-items: center;
}

.space-toggle-container {
  margin-left: 50px;
}

.switch {
  position: relative;
  display: inline-block;
  width: 128px;
  height: 44px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #1f3244;
  -webkit-transition: 0.4s;
  transition: 0.4s;
  border: 5px solid;
}

.slider:before {
  position: absolute;
  content: '';
  height: 26px;
  width: 26px;
  left: 8px;
  bottom: 4px;
  background-color: white;
  -webkit-transition: 0.4s;
  transition: 0.4s;
}

input:focus + .slider {
  box-shadow: 0 0 1px #2196f3;
}

input:checked + .slider:before {
  -webkit-transform: translateX(71px);
  -ms-transform: translateX(71px);
  transform: translateX(78px);
}

/* Rounded sliders */
.slider.round {
  border-radius: 34px;
  border-color: var(--main-color);
}

.slider.round:before {
  border-radius: 50%;
  border-color: var(--main-color);
}

.price-discount {
  color: #999;
  margin-right: 15px;
  text-decoration: line-through;
  text-decoration-color: var(--main-color);
  text-decoration-thickness: 2px;
}

.price-sale {
  padding: 4px 6px;
  border-radius: 8px;
  background-color: var(--main-color);
  color: white;
}

.keep-shopping-footer {
  margin-top: 2.5rem;
  margin-left: 4rem;
}

.keep-shopping-finalize-order-single-item {
  margin-top: 18rem;
}

.keep-shopping-finalize-order-two-items {
  margin-top: 28rem;
}

.keep-shopping-finalize-order-multiple-items {
  margin-top: 15rem;
  margin-left: 55rem;
}



</style>
