<template>
  <div
    @click="redirectToProduct"
    v-bind:class="[
      {
        'product-card--is-featured': isFeatured,
        'product-card--sharedscreen': sharedScreenConfig,
        'with-attributes': showAttributesInCard
      },
      'product-card--' + layout
    ]"
    class="product-card"
  >
    <div class="product-card__card">
      <div
        class="product-card__inner"
        v-bind:style="{
          zIndex: this.source === 'Featured Products' ? 3 : null
        }"
      >
        <div class="brand" v-if="layout === 'full'">
          <img
            v-bind:src="product.brand.logo.url"
            v-if="product.brand.logo"
            class="brand__logo"
          />

          <div class="brand__name" v-if="!product.brand.logo">
            {{ product.brand ? product.brand.name : '' }}
          </div>
          <!-- .brand -->
        </div>

        <product-image
          v-bind:image="product.thumb_image"
          :promo="
            product.store_product_promotions.length > 0
              ? product.store_product_promotions[0].promotion
              : null
          "
          v-bind:category="product.catalog_category.name"
          v-bind:size="layout"
          v-bind:isFeatured="isFeatured"
          v-bind:isMedicalOnly="product.is_medical_only"
        />

        <div class="product-card__info">
          <div
            v-if="layout !== 'full'"
            class="product-card__first-line"
            :class="sourceValue"
          >
            <div
              v-if="product.brand && product.brand.name !== ''"
              class="product-card__brand "
            >
              {{ product.brand.name }}
            </div>
            <div
              class="product-card__type"
              v-for="(type, index) in types"
              :key="index"
            >
              {{ type.value }}
            </div>
          </div>

          <div class="product-card__name">
            {{
              this.$config.PRODUCT_UI.toLowerCase() === 'condensed' &&
              product.name.length > maxNumberOfCharacters
                ? `${product.name.slice(0, maxNumberOfCharacters)}...`
                : product.name
            }}
          </div>

          <div v-if="layout === 'full' && type" class="product-card__type">
            {{
              product.attribute_values.ungrouped.filter(
                o => o.name === 'Type'
              )[0].value
            }}
          </div>

          <div
            v-if="layout === 'full' && !type"
            class="product-card__emptyType"
          ></div>

          <div v-if="layout === 'full'" class="product-card__graphs">
            <product-graphs
              v-bind:size="'small'"
              v-bind:attributes="product.attribute_values"
            ></product-graphs>
          </div>

          <div
            class="product-card__attributes"
            v-if="showAttributesInCard && layout != 'full'"
          >
            <span
              v-if="thc && isZeroValue(thc.value) == false"
              :style="{ color: attributesColor }"
            >
              {{ totalThc ? 'Total THC' : thc.name }} : {{ thcValue }}
            </span>
            <span
              v-if="cbd && isZeroValue(cbd.value) == false"
              :style="{ color: attributesColor }"
            >
              {{ removeNbspAndTrim(`&nbsp;&nbsp;&nbsp;&nbsp;${cbd.name}`) }} : {{ removeNbspAndTrim(cbdValue) }}
            </span>
          </div>

          <div
            v-if="sortedPrices.length > 0 && sortedPrices[0].value"
            :class="`product-card__price ${source === 'Brands' || (source === 'Effects + Uses' && !isFromModalOpen) ? 'price-brands-container' : 'price-container'}`"
          >
            <small v-if="sortedPrices[0].name">
            {{sortedPrices[0].name}}
            </small>
            <template>
              <span
                :class="
                  discountPrice &&
                  discountPrice > 0 &&
                  parseFloat(selectedPrice.value) != parseFloat(discountPrice)
                    ? 'price-discount'
                    : ''
                "
                >{{ sortedPrices[0].value | formatPrice }}</span
              >
              <span
                :class="
                  discountPrice &&
                  discountPrice > 0 &&
                  parseFloat(selectedPrice.value) != parseFloat(discountPrice)
                    ? 'price-sale'
                    : ''
                "
              >
                {{
                  discountPrice &&
                  discountPrice > 0 &&
                  parseFloat(selectedPrice.value) != parseFloat(discountPrice)
                    ? `$${discountPrice}`
                    : ''
                }}
              </span>
            </template>
          </div>

          <button
            v-if="
              $config.SHOPPING_ENABLED && quickCart && sortedPrices.length > 0
            "
            v-on:click.stop="toggleAddToCartForm"
            type="button"
            class="product-card__add-to-cart"
          >
            Add to cart
          </button>
          <div class="product-card__rfid" v-if="indexOrder">
            <span>{{ indexOrder }}</span>
          </div>
        </div>
        <!-- .info -->
      </div>
      <!-- .product-card__inner -->

      <div v-if="layout === 'xlarge'" class="product-card__background"></div>
      <lottie-container
        v-if="layout === 'xlarge'"
        v-bind:path="'block-featured-intro'"
        v-bind:autoplay="false"
        v-bind:loop="false"
        ref="lottieBlockIntro"
        class="product-card__highlight"
      ></lottie-container>
    </div>
    <!-- .product-card__card -->

    <portal to="modal-container" v-if="$config.SHOPPING_ENABLED && showModal">
      <modal-template class="modal--hide-close" key="{'product-' + product.id}">
        <div
          :class="[
            'add-to-cart-modal',
            { 'add-to-cart-modal__prices-with': sortedPrices.length > 7 }
          ]"
        >
          <product-image
            v-bind:image="product.thumb_image"
            v-bind:promo="
              product.store_product_promotions.length > 0
                ? product.store_product_promotions[0].promotion
                : null
            "
            v-bind:category="product.catalog_category.name"
            v-bind:size="'large'"
          />

          <form class="add-to-cart-modal__form">
            <div class="add-to-cart-modal__brand">
              {{
                product.brand ? (product.brand ? product.brand.name : '') : ''
              }}
            </div>

            <div class="add-to-cart-modal__name">{{ product.name }}</div>

            <div class="add-to-cart-modal__values">
              <label
                class="add-to-cart-modal__value"
                v-for="(price, index) in sortedPrices"
                v-bind:key="price.id"
                v-bind:class="{
                  'add-to-cart-modal__value--is-active': selectedPrice === price
                }"
                style="width: auto;"
              >
                <input
                  type="radio"
                  v-bind:value="price"
                  v-model="selectedPrice"
                  v-on:change="onChangeValue"
                />

                <div class="add-to-cart-modal__value__button">
                  <div
                    style="display: flex; flex-direction: column; gap: 10px; padding:"
                  >
                    <div
                      class="add-to-cart-modal__value__price"
                      :class="{
                        'price-add-to-cart':
                          discountPrice && discountPrice > 0 && index === 0
                      }"
                      :style="{
                        color:
                          discountPrice && discountPrice > 0 && index === 0
                            ? 'rgba(255, 255, 255, 0.5)'
                            : ''
                      }"
                    >
                      <span
                        style="width: 104px;"
                        v-if="discountPrice && discountPrice > 0 && index === 0"
                      >
                        ORIGINALLY
                      </span>
                      <span
                        :class="{
                          'price-discount w-full text-center':
                            discountPrice && discountPrice > 0 && index === 0
                        }"
                      >
                        {{ price.value | formatPrice }}
                      </span>
                    </div>
                    <!-- sale price with discount -->
                    <div
                      v-if="discountPrice && discountPrice > 0 && index === 0"
                      :class="{
                        'price-add-to-cart': discountPrice && discountPrice > 0
                      }"
                    >
                      <span
                        style="width: 104px;"
                        v-if="discountPrice && discountPrice > 0 && index === 0"
                      >
                        SALE PRICE</span
                      >
                      <div class="add-to-cart-modal__value__price price-sale">
                        {{ discountPrice | formatPrice }}
                      </div>
                    </div>
                    <div
                      v-if="discountPrice && discountPrice > 0 && index === 0"
                      class="price-add-to-cart"
                    >
                      <div style="min-width: 104px; opacity: 0;"></div>
                      <span
                        :class="{
                          'w-full text-center':
                            discountPrice && discountPrice > 0 && index === 0
                        }"
                      >
                        {{ price.name }}
                      </span>
                    </div>
                  </div>

                  <div
                    v-if="!discountPrice || discountPrice < 0 || index !== 0"
                    class="add-to-cart-modal__value__name"
                  >
                    {{ price.name }}
                  </div>

                  <lottie-container
                    v-bind:path="'block-default-intro'"
                    v-bind:autoplay="false"
                    v-bind:loop="false"
                    class="add-to-cart-modal__value__background add-to-cart-modal__value__background--intro intro"
                  ></lottie-container>

                  <lottie-container
                    v-bind:path="'block-default-outro'"
                    v-bind:autoplay="false"
                    v-bind:loop="false"
                    v-bind:frame="
                      selectedPrice === price ? 'firstFrame' : 'lastFrame'
                    "
                    class="add-to-cart-modal__value__background add-to-cart-modal__value__background--outro outro"
                  ></lottie-container>
                </div>
              </label>
            </div>
            <!-- .add-to-cart-modal__values -->

            <div class="add-to-cart-modal__quantity">
              <button
                v-on:click="selectedQty = Math.max(1, selectedQty - 1)"
                v-bind:style="{ opacity: selectedQty === 1 ? '0.2' : '' }"
                type="button"
                class="add-to-cart-modal__quantity__button add-to-cart-modal__quantity__button--minus"
              >
                -
              </button>

              <input
                type="text"
                v-model="selectedQty"
                class="add-to-cart-modal__quantity__field"
              />

              <button
                v-on:click="
                  selectedQty = Math.min(product.stock, selectedQty + 1)
                "
                v-bind:style="{
                  opacity: selectedQty === product.stock ? '0.2' : ''
                }"
                type="button"
                class="add-to-cart-modal__quantity__button add-to-cart-modal__quantity__button--plus"
              >
                +
              </button>
            </div>
            <!-- .add-to-cart-modal__quantity -->

            <div class="add-to-cart-modal__actions">
              <button
                v-on:click="toggleAddToCartForm"
                type="button"
                class="add-to-cart-modal__button add-to-cart-modal__button--close"
              >
                <span class="add-to-cart-modal__button__text">Cancel</span>
                <span class="add-to-cart-modal__button__background"></span>
              </button>

              <button
                v-bind:class="{
                  'add-to-cart-modal__button--is-disabled':
                    status !== 'isAvailable'
                }"
                v-on:click="addToCart"
                type="button"
                class="add-to-cart-modal__button add-to-cart-modal__button--submit"
              >
                <span class="add-to-cart-modal__button__text">Add to cart</span>
                <span class="add-to-cart-modal__button__background"></span>
              </button>

              <div
                v-bind:class="{
                  'add-to-cart-modal__notification--is-visible':
                    status === 'isAdded'
                }"
                class="add-to-cart-modal__notification"
              >
                {{ status === 'isAdding' ? messageIsAdding : messageIsAdded }}
              </div>
              <!-- .add-to-cart-modal__notification -->
            </div>
            <!-- .add-to-cart-modal__actions -->
          </form>
          <!-- .add-to-cart-modal -->
        </div>
        <!-- .add-to-cart-modal -->
      </modal-template>
    </portal>

    <portal
      to="modal-container"
      v-if="$config.SHOPPING_ENABLED && showOffLineModal"
    >
      <modal-template class="modal--hide-close" key="{'product-' + product.id}">
        <div class="add-to-cart-modal">
          <div class="offline-message">
            <p class="offline-message__text">
              Kiosk is currently offline, add to cart option has been disabled
            </p>
            <button
              v-on:click="showOffLineModal = false"
              type="button"
              class="offline-message__close-button"
            >
              close
            </button>
          </div>
        </div>
        <!-- .add-to-cart-modal -->
      </modal-template>
    </portal>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import ModalTemplate from '@/components/ModalTemplate'
import { Portal, PortalTarget } from 'portal-vue'
import ProductGraphs from '@/components/ProductGraphs'
import ProductImage from '@/components/ProductImage'
import $ from 'jquery'
import { mapActions, mapGetters, mapState } from 'vuex'
import isCardWithAttributes from '../mixins/isCardWithAttributes'
export default {
  name: 'ProductCard',
  mixins: [isCardWithAttributes],
  components: {
    LottieContainer,
    ModalTemplate,
    Portal,
    PortalTarget,
    ProductGraphs,
    ProductImage
  },
  props: {
    quickCart: {
      type: Boolean,
      default: true
    },
    layout: String,
    product: Object,
    source: String,
    sharedScreenConfig: Boolean,
    indexOrder: Number,
    isFromModalOpen: Boolean
  },
  filters: {
    taxAdded: function(price, tax) {
      if (tax === 0) return price
      let numPrice = parseFloat(price)
      return parseFloat(numPrice + numPrice * (tax / 100))
    },
    formatPrice: function(price) {
      let numPrice = Number(price).toFixed(2)
      numPrice = numPrice.includes('.00')
        ? numPrice.slice(0, numPrice.indexOf('.00'))
        : numPrice
      return '$' + numPrice
    }
  },
  data() {
    return {
      messageIsAdded: 'Product added',
      messageIsAdding: 'Adding product',
      selectedPrice: null,
      selectedQty: 1,
      showOffLineModal: false,
      showModal: false,
      status: 'isAvailable',
      type: null,
      onLine: true,
      spotlightBrandId: null,
      maxNumberOfCharacters: 22,
      totalThc: false
    }
  },
  computed: {
    ...mapState(['connected']),
    isFeatured: function() {
      return this.product.isFeatured
    },
    productPrices() {
      return this.product.product_values
    },

    // showAttributesInCard () {
    //   return this.$config.SHOW_PRODUCT_ATTRIBUTES
    // },
    // thc () {
    //   return this.groupedAttributeValues ? this.groupedAttributeValues.find(x => x.name === 'THC') : null
    // },
    // thcValue () {
    //   return addPercentage(this.thc.value)
    // },
    // cbdValue () {
    //   return addPercentage(this.cbd.value)
    // },
    // cbd () {
    //   return this.groupedAttributeValues ? this.groupedAttributeValues.find(x => x.name === 'CBD') : null
    // },
    // attributesColor () {
    //   return this.$config.ATTRIBUTE_COLORS
    // },
    // showAttributes () {
    //   return this.$config.SHOW_ATTRIBUTES
    // },

    sortedPrices: function() {
      if (this.productPrices && this.productPrices.length > 1) {
        let array = this.productPrices
        console.log('Prices', this.productPrices[0].value)
        return array.sort((a, b) => {
          return Number(a.value) - Number(b.value)
        })
      } else {
        return this.productPrices
      }
    },
    tax: function() {
      let lowestTax = 0
      let categoryTaxes = this.product.category_taxes
      let storeTaxes = this.product.store_taxes
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
      return lowestTax
    },
    types: function() {
      return 'ungrouped' in this.product.attribute_values
        ? this.product.attribute_values.ungrouped.filter(
          attributeValue => attributeValue.name === 'Type'
        )
        : []
    },
    sourceValue: function() {
      return this.source === 'Brands' || (this.source === 'Effects + Uses' && !this.isFromModalOpen)
        ? 'text-align-left'
        : ''
    },
    discountPrice: function() {
      // Check if there are promotions and extract the discount price if available
      const rawDiscountPrice =
        this.product.store_product_promotions.length > 0
          ? this.product.store_product_promotions[0].discount_price
          : null

      // Return formatted price or null
      if (rawDiscountPrice !== null) {
        // Convert to a number and format to two decimal places
        const formattedPrice = parseFloat(rawDiscountPrice).toFixed(2)

        // Check if the formatted price ends in '.00', remove '.00' if it does
        return formattedPrice.endsWith('.00')
          ? formattedPrice.slice(0, -3)
          : formattedPrice
      } else {
        return null
      }
    }
  },
  created: function() {
    var self = this

    self.totalThc = this.$config.USE_TOTAL_THC

    this.spotlightBrandId = this.$config.BRAND_ID

    // console.table([ {name:"SHOPPING_ENABLED",val:this.$config.SHOPPING_ENABLED}, {n<ame:"QUICKCART",val: this.quickCart == undefined ?false:true } , {name:'SORTED', val:this.sortedPrices.length>0} ]) ;

    // Set default price to the lower one

    this.selectedPrice = this.sortedPrices ? this.sortedPrices[0] : null
    // Ungrouped attributes
    if (
      this.product.attribute_values &&
      this.product.attribute_values.ungrouped
    ) {
      this.product.attribute_values.ungrouped.forEach(function(attribute) {
        if (attribute.name === 'Type') {
          self.type = attribute.value
        }
      })
    }

    // Events
    this.$root.$on('product-added', this.onProductAdded)
    this.$root.$on('product-not-added', this.onProductNotAdded)
  },
  mounted() {},

  methods: {
    ...mapGetters('cart', ['isCartActivated']),
    ...mapActions('cart', ['addProductToActiveCart']),
    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },
    /**
     * Redirect to product cart
     */
    redirectToProduct() {
      this.$router.push({
        name: 'product',
        params: { id: this.product.id, source: this.source }
      })
    },

    updateOnlineStatus(e) {
      const { type } = e
      this.onLine = type === 'online'
    },
    /**
     * Product added callback
     */
    onProductAdded: function(product) {
      // Current product has been added to cart
      if (product.product === this.product) {
        this.status = 'isAdded'

        var self = this
        // Show a message for 1s and come back to default state
        setTimeout(function() {
          self.status = 'isAvailable'
          self.selectedQty = 1
          self.showModal = false
        }, 1000)
      }
    },

    /**
     * Product not added callback
     */
    onProductNotAdded: function(product) {
      // Current product has not been added to cart
      if (product.product === this.product) {
        this.status = 'isAvailable'
      }
    },

    /**
     * Change value animation
     */
    onChangeValue: function(event) {
      var newValue = $(event.currentTarget).parent()
      var oldValue = $('.add-to-cart-modal__value--is-active')

      var newIntroAnim = newValue
        .find('.lottie-container.intro')
        .data('lottieAnimation')
      var newOutroAnim = newValue
        .find('.lottie-container.outro')
        .data('lottieAnimation')
      newIntroAnim.goToAndPlay(0, true)
      newOutroAnim.goToAndStop(27, true)

      var oldIntroAnim = oldValue
        .find('.lottie-container.intro')
        .data('lottieAnimation')
      var oldOutroAnim = oldValue
        .find('.lottie-container.outro')
        .data('lottieAnimation')
      oldIntroAnim.goToAndStop(0, true)
      oldOutroAnim.goToAndPlay(0, true)

      newValue = null
      oldValue = null
      newIntroAnim = null
      newOutroAnim = null
      oldIntroAnim = null
      oldOutroAnim = null
    },

    /**
     * Add to cart function
     */

    addToCart: function() {
      this.status = 'isAdding'
      let frozenPrice = { ...this.selectedPrice }
      let isPriceWithDiscount = false

      frozenPrice.basePrice = frozenPrice.value
      if (this.tax > 0) {
        let numPrice = parseFloat(frozenPrice.basePrice)
        frozenPrice.value = parseFloat(numPrice + numPrice * (this.tax / 100))
      }

      if (this.discountPrice && this.discountPrice > 0) {
        this.sortedPrices[0].id === frozenPrice.id
          ? (isPriceWithDiscount = true)
          : (isPriceWithDiscount = false)
      }

      // Trigger global event with product information
      this.$root.$emit('add-to-cart', {
        product: this.product,
        price: frozenPrice,
        qty: this.selectedQty,
        priceDiscount:
          this.discountPrice && this.discountPrice > 0 && isPriceWithDiscount
            ? this.discountPrice
            : null
      })
    },

    /**
     * Toggle quick add to cart form
     */
    toggleAddToCartForm: function(event) {
      let self = this
      let source = 'Quick Add To Cart'

      if (
        this.product.brand != null &&
        this.spotlightBrandId === this.product.brand.id
      ) {
        source = 'Brand Spotlight'
      }
      if (self.$gsClient) {
        self.$gsClient.track('Product view', {
          source: source,
          name: this.product.name,
          id: this.product.sku,
          product_id: this.product.id,
          brand: this.product.brand ? this.product.brand.name : 'unknow',
          category: this.product.catalog_category.name,
          quantity: this.product.stock,
          price: this.selectedPrice ? this.selectedPrice.value : '',
          tag_list: this.product.tag_list,
          stock: this.product.stock
        })
      }
      console.log(this.connected)
      if (this.connected) {
        this.showModal = !this.showModal
      } else {
        this.showOffLineModal = true
      }
      // var container = $('.add-to-cart-modal').first()
      // console.log(container)
      setTimeout(() => {
        const nonSelectedVals = $('.add-to-cart-modal__value')
          .not('.add-to-cart-modal__value--is-active')
          .toArray()
        console.log('nonSelectedVals', nonSelectedVals)
        nonSelectedVals.forEach(valuebtn => {
          console.log(valuebtn)
          var oldIntroAnim = $(valuebtn)
            .find('.lottie-container.intro')
            .data('lottieAnimation')
          var oldOutroAnim = $(valuebtn)
            .find('.lottie-container.outro')
            .data('lottieAnimation')
          oldIntroAnim.goToAndStop(0, true)
          oldOutroAnim.goToAndPlay(0, true)
        })
      }, 250)
    },
    removeNbspAndTrim(str) {
      return str.replace(/&nbsp;/g, '').trim()
    }
  }
}
</script>

<style scoped lang="scss">
.product-sales {
  .products-grid {
    .product-card {
      .card-brand {
        font-size: 16px;
      }
    }
  }
}

.product-card {
  position: relative;

  &__first-line div:last-child {
    margin: 0;
  }

  &__first-line {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
  }

  .text-align-left {
    justify-content: flex-start;
  }

  &__card {
    display: block;
    position: relative;
    width: 100%;
    height: 100%;
  }

  &__rfid {
    display: none;
  }

  &__info {
    margin-top: auto;
  }

  &__promotion {
    width: 5rem;
    height: 5rem;
    padding: 0.6em;
    border-radius: 50%;
    position: absolute;
    background-color: var(--main-color);
    top: 0px;
    left: 0px;
    text-align: center;
    z-index: 2000;
    display: flex;
    justify-content: center;
    align-items: center;

    font: 18px var(--font-regular);

    div {
      word-break: break-word;
      text-align: center;
      width: 100%;
      line-height: 1.2;
      color: #ffffff;
    }

    span {
      margin: auto 0px;
    }

    &-min-text {
      font-size: 11px;
    }
  }

  &__attributes {
    margin-bottom: 0.5em;
    font: 15px/1.4 var(--font-extrabold);

    span {
      font-weight: var(--font-extrabold);
    }
  }

  &__brand {
    color: $white;
    font: 0.55em/1 var(--font-bold);
    letter-spacing: 0.05em;
    text-transform: uppercase;

    @at-root .app--tablet & {
      font-size: 0.7em;
      letter-spacing: 0.1em;
    }

    &:before {
      display: inline-block;
      margin: 0 2px 0 0;
      width: 2px;
      height: 10px;

      background-color: var(--main-color);
      content: '';
      vertical-align: top;
    }
  }

  &__type {
    margin: 1em auto 0;
    position: relative;

    color: $white;
    font: 0.55em/1 var(--font-semibold);
    letter-spacing: 0.25em;
    text-align: center;
    text-transform: uppercase;

    &:before {
      display: inline-block;
      margin: 0 5px 0 0;
      width: 2px;
      height: 10px;

      background-color: var(--main-color);
      content: '';
      vertical-align: top;
    }
  }

  &__name {
    margin: 0.4em 0;

    color: $white;
    font: 1em/1.4 var(--font-extralight);

    @at-root .app--tablet & {
      font-size: 1.4em;
    }
  }

  &__price {
    color: rgba($white, 0.5);
    font: 0.8em/1 var(--font-light);

    @at-root .app--tablet & {
      font-size: 0.9em;
    }

    small {
      font-size: 0.8em;
    }
  }

  &__add-to-cart {
    display: block;
    overflow: hidden;
    margin: 15px 0 0;
    position: relative;
    width: 2em;
    height: 2em;

    background-color: $charade;
    border: none;
    border-radius: 50%;

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

      background-image: url('~@/assets/img/icon-quick-cart.svg');
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
      content: '';
    }
  }

  &__inner {
    position: relative;
    width: 100%;
    height: 100%;
  }

  &__background,
  &__highlight {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    z-index: 1;
  }

  &__highlight {
    z-index: 2;
  }

  &--large,
  &--xlarge {
    padding: 0 0 260px;
    width: 300px;

    text-align: center;

    &.with-attributes {
      padding-bottom: 300px;
    }

    /*@at-root .app--tablet & {
      padding-bottom: 320px;
    }*/

    .product-card {
      &__info {
        position: absolute;
        top: 335px;
        left: 0;
        width: 100%;
      }

      &.with-attributes {
        padding-bottom: 300px !important;
      }

      &__add-to-cart {
        margin-left: auto;
        margin-right: auto;
        width: 2.2em;
        height: 2.2em;

        &:before {
          margin: -0.4em 0 0 -0.65em;
          width: 1.15em;
          height: 0.95em;
        }
      }
    }

    .product-image {
      margin: 0 auto;
      width: 300px;
    }
  }

  &--xlarge {
    padding: 0;
    width: 400px;
    height: 570px;

    .product-card {
      &__inner {
        padding: 60px 0 0;
      }

      &__info {
        display: flex;
        top: 360px;
        bottom: 0;

        align-items: center;
        flex-direction: column;
        justify-content: center;
      }
    }
  }

  &--small,
  &--xsmall {
    a {
      display: flex;
      width: 100%;

      align-items: flex-start;
      flex-direction: row;
      justify-content: flex-start;
    }

    .product-image {
      margin: 0 40px 0 0;
      width: 130px;
    }

    .product-card {
      &__info {
        margin: 8px 0 0;
        flex-shrink: 1;
      }

      &__promotion {
        font-size: 12px;
        left: 0;
        top: 0;
        width: 48px;
        height: 48px;
      }
    }
  }

  &--xsmall {
    .product-image {
      margin-right: 20px;
      width: 90px;
    }
  }

  &--full {
    background: rgba($white, 0.1);
    border-radius: 30px;

    .product-card {
      &__inner {
        padding: 180px 10px 0;

        @at-root .app--tablet & {
          padding-top: 0;
          display: flex;
          flex-direction: column;
        }

        .product-card__emptyType {
          height: 15px;
        }
      }

      &__name {
        margin-top: 35px;
        max-height: 2.2em;

        overflow: hidden;

        font-size: 1.5em;
        line-height: 1.1;
        text-align: center;
      }

      &__graphs {
        display: flex;
        margin: 0;
        /*margin: 35px 0 0;*/
        height: 168px;

        align-items: center;
        flex-direction: row;
        justify-content: center;

        @at-root .app--tablet & {
          margin-top: 25px;
        }
      }

      &__price {
        margin: 0;
        /*margin: 35px 0 0;*/

        color: $white;
        font-size: 1.1em;
        text-align: center;

        @at-root .app--tablet & {
          margin-top: 15px;
          font-size: 1.3em;
        }

        small {
          display: block;
          margin: 0 0 0.75em;

          opacity: 0.5;

          font-size: 0.5em;
          letter-spacing: 0.39em;
          text-transform: uppercase;

          @at-root .app--tablet & {
            margin-bottom: 0.5em;
          }

          @at-root .app--tablet & {
            font-family: var(--font-bold);
          }
        }
      }

      &__add-to-cart {
        margin: 0.5em auto;

        @at-root .app--tablet & {
          font-size: 1.2em;
        }
      }
    }

    .brand {
      position: absolute;
      top: 30px;
      left: 20px;

      width: calc(100% - 40px);
      height: calc(180px - 60px);

      @at-root .app--tablet & {
        height: 110px;
        position: relative;
        margin-bottom: 15px;
      }

      &__logo {
        display: block;
        margin: 0 auto;
        width: 100%;
        max-width: 160px;
        height: 100%;

        object-fit: contain;
      }

      &__name {
        display: flex;
        width: 100%;
        height: 100%;

        align-items: center;
        flex-direction: row;
        justify-content: center;

        font: 14px/1 var(--font-semibold);
        letter-spacing: 0.1em;
        line-height: 1.4;
        text-align: center;
        text-transform: uppercase;
      }
    }

    .product-image {
      margin: 0 auto;
      height: auto;
      margin-top: 15px;
    }
  }
}

#screen-home-cards {
  .product-card__rfid {
    display: block;
    font-size: 16px;
    position: absolute;
    margin-bottom: 10px;
    margin-left: 10px;
    bottom: 0;
  }
}

.add-to-cart-modal {
  display: flex;
  position: relative;

  align-items: flex-start;
  flex-direction: row;
  justify-content: flex-start;

  text-align: left;

  .product-image {
    margin: 5px 60px 0 30px;
    width: 300px;
  }

  &__prices-with {
    overflow-x: auto;
  }

  &__form {
    flex-grow: 1;
    flex-shrink: 1;
  }

  &__brand {
    opacity: 0.2;

    font: 0.55em var(--font-semibold);
    letter-spacing: 0.05em;
    text-transform: uppercase;

    @at-root .app--tablet & {
      font-size: 0.65em;
      letter-spacing: 0.1em;
    }
  }

  &__name {
    margin: 0.33em 0 1em;

    font: 1.5em var(--font-extralight);
  }

  &__values {
    display: flex;
    margin: 0 -5px;
    width: 100%;

    flex-direction: row;
    justify-content: flex-start;
  }

  &__value {
    margin: 0 0.36em;
    overflow: hidden;
    position: relative;
    width: 7.14em;
    height: 8.57em;

    flex-grow: 0;
    flex-shrink: 0;

    font: 0.7em/1 var(--font-bold);
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
      display: flex;
      padding: 0.71em;
      position: relative;
      width: 100%;
      height: 100%;

      background: none;
      border-radius: 1.43em;
      flex-direction: column;
      justify-content: center;
      overflow: hidden;
    }

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      z-index: 1;
    }

    /deep/ .lottie-container {
      path {
        fill: rgba($white, 0.1);
      }
    }

    .lottie-container.outro {
      display: none;
    }

    &--is-active {
      .lottie-container.outro {
        display: block;
      }
    }

    &__price {
      font-size: 1.57em;
    }

    &__name {
      overflow: hidden;
      margin: 10px 0 0;
      max-height: 2em;

      letter-spacing: 0.1em;
      text-transform: uppercase;
    }
  }

  &__quantity {
    float: left;
    margin: 1.5em 4em 0 0;

    @at-root .app--tablet & {
      font-size: 1.2em;
    }

    &__field {
      width: 3.21em;
      height: 1.79em;

      background: none;
      border: none;
      vertical-align: top;

      color: $white;
      font: 1.4em/1.79em var(--font-extralight);
      text-align: center;

      @at-root .app--tablet & {
        width: 2.5em;
      }
    }

    &__button {
      display: inline-block;
      position: relative;
      width: 2.5em;
      height: 2.5em;

      background: rgba($white, 0.1);
      border: none;
      border-radius: 50%;
      vertical-align: top;

      &:before,
      &:after {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0.7em;
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

  &__actions {
    display: flex;
    margin: 1.5em 0 0;
    position: relative;

    flex-direction: row;
    justify-content: flex-end;

    @at-root .app--tablet & {
      font-size: 1.2em;
    }
  }

  &__button {
    margin: 0 0 0 1.67em;
    position: relative;
    height: 4.17em;

    background: none;
    border: none;
    flex-grow: 0;
    flex-shrink: 0;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
      opacity 0.2s linear;

    color: $white;
    font: 0.6em/4.17em var(--font-extrabold);
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

      background: rgba($white, 0.1);
      border-radius: 2.08em;
      transform: translate3d(-50%, 0, 0);
    }

    &:first-child {
      margin-left: 0;
    }

    &--close {
      width: 10.33em;
    }

    &--submit {
      width: 13.33em;

      .add-to-cart-modal__button__background {
        background: var(--main-color);
      }
    }

    &--is-disabled {
      opacity: 0;
      transform: translate3d(0, 10px, 0);
      pointer-events: none;
    }
  }

  &__notification {
    position: absolute;
    bottom: 18px;
    right: 0;
    width: 8em;

    opacity: 0;
    pointer-events: none;
    transform: translate3d(0, -10px, 0);
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
      opacity 0.2s linear;

    color: $white;
    font-size: 0.7em;
    line-height: 1;
    text-align: center;

    &--is-visible {
      opacity: 1;
      transform: translate3d(0, 0, 0);
    }
  }
}

.offline-message {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  width: 100%;

  &__text {
    text-align: center;
    color: rgba($white, 0.3);
  }

  &__close-button {
    border: 0px;
    padding: 1rem;
    width: 10em;
    border-radius: 250px;
    color: white;
    background-color: rgba(255, 255, 255, 0.1);
    font: 0.6em var(--font-extrabold);
    letter-spacing: 0.2em;
    text-align: center;
    text-transform: uppercase;
  }
}

.product-card--sharedscreen {
  min-width: calc(16.6% - 40px) !important;

  .product-card__inner {
    padding-left: 10px !important;
    padding-right: 10px !important;
  }

  .product-card__name {
    height: 49.6px;
  }

  .product-card__emptyType {
    margin: 13.2px auto 0;
    height: 12.8px;
  }
}

.price-container {
  display: flex;
  gap: 10px;
  align-items: center;
  justify-content: center;
}

.price-brands-container {
  display: flex;
  gap: 10px;
  align-items: center;
  justify-content: start;
}

.price-sale {
  padding: 4px 6px;
  border-radius: 8px;
  background-color: var(--main-color);
  color: white;
  font-size: 19px;
}

.price-add-to-cart {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  font-size: 1.1rem !important;
}

.price-discount {
  text-decoration: line-through;
  text-decoration-color: var(--main-color);
  text-decoration-thickness: 2px;
}

.text-center {
  text-align: center;
}

.w-full {
  width: 100%;
}
</style>
