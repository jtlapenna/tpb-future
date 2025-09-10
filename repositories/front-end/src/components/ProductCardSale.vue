<template>
  <div class="card-container"  @click.prevent="redirectToProduct"
 :class="[{ 'for-split-screen': isForSplitScreen}, 'card-container--size-' + cardZise]" >
      <div class="card-title" v-if="isForSplitScreen">
        <div class="card-brand-name-container">
          <p class="card-brand">{{ product.name ? product.name : "" }}</p>
          <div v-if="product.brand && product.brand.name" class="card-type">
              <p class="card-type__paragraph">{{ product.brand.name.trim() }}</p>
          </div>
          <div v-if="type " class="card-type">
              <p class="card-type__paragraph" >{{ type.trim() }}</p>
          </div>
        </div>
      </div>

      <product-image
        v-bind:image="product.thumb_image"
        :promo="
          product.store_product_promotions.length > 0
            ? product.store_product_promotions[0].promotion
            : null
        "
        v-bind:category="product.catalog_category.name"
        v-bind:size="'layout'"
      />
    <div
      class="card-attributes"
      v-if="isForSplitScreen"
    >
      <span
        v-if="thc && isZeroValue(thc.value) == false"
        :style="{ color: attributesColor }"
      >
        {{ thc.name }} : {{ thcValue }}
      </span>
      <span
        v-if="cbd && isZeroValue(cbd.value) == false"
        :style="{ color: attributesColor }"
      >
        {{ ` ${cbd.name}` }} : {{ cbdValue }}
      </span>
    </div>

    <p class="card-brand" v-if="!isForSplitScreen">
      {{ product.brand ? product.brand.name : "" }}
    </p>
    <p
      class="card-name "
      v-if="!isForSplitScreen"
      :class="{ 'small-text': product.name.length > 15 }"
    >
      {{ product.name }}
    </p>
    <div
      v-if="sortedPrices.length > 0 && sortedPrices[0].value"
      class="card-price"
    >
      <small>From</small>
      {{ sortedPrices[0].value | taxAdded(tax) | formatPrice }}
    </div>

    <button
      class="add-to-cart"
      v-if="$config.SHOPPING_ENABLED && quickCart && sortedPrices.length > 0"
      v-on:click.stop="toggleAddToCartForm"
    ></button>
    <div
    v-if="indexOrder"
    class="product-card__rfid">
      <span>{{indexOrder}}</span>
    </div>

    <portal to="modal-container" v-if="$config.SHOPPING_ENABLED && showModal">
      <modal-template class="modal--hide-close" key="{'product-' + product.id}">
        <div class="add-to-cart-modal">
          <product-image
            v-bind:promo="
              product.store_product_promotions.length > 0
                ? product.store_product_promotions[0].promotion
                : null
            "
            v-bind:image="product.thumb_image"
            v-bind:category="product.catalog_category.name"
            v-bind:size="'large'"
          />

          <form class="add-to-cart-modal__form">
            <div class="add-to-cart-modal__brand">
              {{
                product.brand ? (product.brand ? product.brand.name : "") : ""
              }}
            </div>

            <div class="add-to-cart-modal__name">{{ product.name }}</div>

            <div class="add-to-cart-modal__values">
              <label
                v-for="price in sortedPrices"
                v-bind:key="price.id"
                v-bind:class="{
                  'add-to-cart-modal__value--is-active': selectedPrice === price
                }"
                class="add-to-cart-modal__value"
              >
                <input
                  type="radio"
                  v-bind:value="price"
                  v-model="selectedPrice"
                  v-on:change="onChangeValue"
                />

                <div class="add-to-cart-modal__value__button">
                  <div class="add-to-cart-modal__value__price">
                    {{ price.value | taxAdded(tax) | formatPrice }}
                  </div>
                  <div class="add-to-cart-modal__value__name">
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
                {{ status === "isAdding" ? messageIsAdding : messageIsAdded }}
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
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import ModalTemplate from '@/components/ModalTemplate'
import { Portal, PortalTarget } from 'portal-vue'
import ProductGraphs from '@/components/ProductGraphs'
import ProductImage from '@/components/ProductImage'
import $ from 'jquery'
import isCardWithAttributes from '@/mixins/isCardWithAttributes'

export default {
  components: {
    LottieContainer,
    ModalTemplate,
    Portal,
    PortalTarget,
    ProductGraphs,
    ProductImage
  },
  mixins: [isCardWithAttributes],
  props: {
    quickCart: {
      type: Boolean,
      default: true
    },
    indexOrder: {
      type: Number
    },
    isForSplitScreen: {
      type: Boolean,
      default: () => false
    },

    product: {
      type: Object,
      default: () => null
    },

    cardZise: {
      type: Number,
      default: () => null
    }
  },
  filters: {
    taxAdded: function (price, tax) {
      if (tax === 0) return price
      let numPrice = parseFloat(price)
      return parseFloat(numPrice + numPrice * (tax / 100))
    }
  },
  data () {
    return {
      showModal: false,
      prices: this.product.product_values,
      messageIsAdded: 'Product added',
      messageIsAdding: 'Adding product',
      status: 'isAvailable',
      selectedPrice: null,
      selectedQty: 1,
      type: null
    }
  },
  created: function () {
    var self = this
    // console.table([ {name:"SHOPPING_ENABLED",val:this.$config.SHOPPING_ENABLED}, {name:"QUICKCART",val: this.quickCart == undefined ?false:true } , {name:'SORTED', val:this.sortedPrices.length>0} ]) ;

    // Set default price to the lower one
    this.selectedPrice = this.sortedPrices[0]
    // Ungrouped attributes
    if (
      this.product.attribute_values &&
      this.product.attribute_values.ungrouped
    ) {
      this.product.attribute_values.ungrouped.forEach(function (attribute) {
        if (attribute.name === 'Type') {
          self.type = attribute.value
        }
      })
    }

    // Events
    this.$root.$on('product-added', this.onProductAdded)
    this.$root.$on('product-not-added', this.onProductNotAdded)
  },
  methods: {
    onProductAdded: function (product) {
      // Current product has been added to cart
      if (product.product === this.product) {
        this.status = 'isAdded'

        var self = this
        // Show a message for 1s and come back to default state
        setTimeout(function () {
          self.status = 'isAvailable'
          self.selectedQty = 1
          self.showModal = false
        }, 1000)
      }
    },
    onProductNotAdded: function (product) {
      // Current product has not been added to cart
      if (product.product === this.product) {
        this.status = 'isAvailable'
      }
    },
    toggleAddToCartForm: function (event) {
      this.showModal = !this.showModal
    },

    onChangeValue: function (event) {
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
    addToCart: function () {
      this.status = 'isAdding'
      let frozenPrice = { ...this.selectedPrice }

      frozenPrice.basePrice = frozenPrice.value
      if (this.tax > 0) {
        let numPrice = parseFloat(frozenPrice.basePrice)
        frozenPrice.value = parseFloat(numPrice + numPrice * (this.tax / 100))
      }

      // Trigger global event with product information
      this.$root.$emit('add-to-cart', {
        product: this.product,
        price: frozenPrice,
        qty: this.selectedQty
      })
    }
  },

  computed: {
    sortedPrices () {
      if (this.product === undefined) {
        return []
      }
      var unordoredPrices = this.product.product_values

      if (unordoredPrices && unordoredPrices.length > 1) {
        console.log('Prices', unordoredPrices[0].value)
        return unordoredPrices.sort(function (a, b) {
          return Number(a.value) - Number(b.value)
        })
      } else {
        return unordoredPrices
      }
    },
    tax: function () {
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
    }
  }
}
</script>

<style lang="scss" scoped>
.card-container {
  position: relative;
  padding: 1rem 1.5rem;

  .product-card__rfid {
    font-size: 16px;
    position: absolute;
    margin-bottom: 10px;
    margin-left: 10px;
    bottom: 0;
    left: 15px;
  }
}

@mixin forSplitScreen {
  &.for-split-screen {
    border-radius: 40px;
    padding-top: 1rem;

    .card {
      &-brand {
        font-size: 1.25rem;
        font-family: var(--font-regular);
        color: #fff;
        text-align: center;
      }

      &-title{
        height: 80px;
        max-width: 100%;
        display: flex;
        flex-direction: column;
        justify-content: start;
      }

      &-brand{
        // width: 100%;
        max-height: 40px;
        width: 100%;
        white-space: wrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      &-type {
        margin: 1em auto 0;
        position: relative;
        display: flex;
        width: 100%;

        align-items: center;
        justify-content: center;
        color: $white;
        font: 0.55em/1 var(--font-semibold);
        letter-spacing: 0.25em;
        text-align: center;
        text-transform: uppercase;

        &__paragraph{
          max-width: 98%;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        &:before {
          display: inline-block;
          margin: 0 5px 0 0;
          width: 2px;
          height: 10px;

          background-color: var(--main-color);
          content: "";
          vertical-align: top;
        }
      }
      &-price {
        color: $white;
        font-size: 1.10em;
        text-align: center;
        small {
          display: block;
          margin: 0 0 0.75em;
          opacity: 0.5;
          font-size: 0.5em;
          letter-spacing: 0.39em;
          text-transform: uppercase;
        }
      }
      &-attributes {
        margin-bottom: 0.5em;
        font: 0.55em/1 var(--font-semibold);
        span {
          font-weight: var(--font-extrabold);
        }
        min-height: 13px;
        height: 13px;
        width: 100%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
    .product {
      &-image {
        margin: 1rem auto;
        width: 138px !important;
        height: 138px !important;
      }
    }
  }
}

.card {
  width: 100%;
  height: 100%;
  &-container {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 1rem;
    padding: 1rem;
    display: flex;
    height: 100%;
    flex-direction: column;
    min-width: 170px;
    width: 100%;
    justify-content: space-between;
    align-items: center;
    text-align: center;
    @include forSplitScreen();

    &--size-1{
      width: 100% !important;
      flex: 0 100% !important;
    };
    &--size-2{
      width: 50% !important;
      flex: 0 50% !important;
    };
    &--size-3{
      width: 33.33% !important;
      flex: 0 33.33% !important;
    };
    &--size-4{
      width: 25% !important;
      flex: 0 25% !important;
    };
    &--size-5{
      width: 20% !important;
      flex: 0 20% !important;
    };
    &--size-6{
      width: 16% !important;
      flex: 0 16% !important;
    };
    &--size-7{
      width: 14% !important;
      flex: 0 14% !important;
    };
    &--size-8{
      width: 12.5% !important;
      flex: 0 12.5% !important;
    };
    &--size-9{
      width: 11.1% !important;
      flex: 0 11.1% !important;
    };
    &--size-10{
      width: 10% !important;
      flex: 0 10% !important;
    }
  }
  &-title {
    font-size: 0.75rem;
    color: rgba(0, 0, 0, 0.3);
  }
  &-image {
    width: 230px;
    height: 230px;
    object-fit: cover;
    border-radius: 50%;
    margin-bottom: 0.75;
    &-container {
      position: relative;
    }
    &.loader {
      background-image: url("~@/assets/img/image-loader.gif");
    }
  }
  &-promotion {
    width: 100px;
    height: 100px;
    padding: 0.6em;
    border-radius: 50%;
    position: absolute;
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;

    font-family: var(--font-regular);
    font-size: 18px;
    color: #fff;
    left: -22px;
    top: -6px;
    background-color: var(--main-color);

    word-break: break-word;
    text-align: center;

    span {
      margin: auto 0px;
    }
    .min-text {
      font-size: 12px;
    }
  }
  &-brand {
    color: rgba($white, 0.3);
    font: 8px var(--font-bold);
    letter-spacing: 0.05em;
    margin-bottom: 0;
    text-transform: uppercase;
  }
  &-name {
    margin: 0.4em 0;
    color: $white;
    text-transform: uppercase;
    &.small-text {
      font-size: 14px;
    }
    font: 1em var(--font-extralight);
  }
  &-price {
    color: rgba($white, 0.5);
    font: 0.8em/1 var(--font-light);
    margin-bottom: 0.5rem;
    @at-root .app--tablet & {
      font-size: 0.9em;
    }

    small {
      font-size: 0.8em;
    }
  }
}
p {
  margin: 0px;
}
.add-to-cart {
  display: block;
  overflow: hidden;
  margin: 8px 0 0;
  position: relative;
  width: 2em;
  height: 2em;
  flex-shrink: 0;
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

    background-image: url("~@/assets/img/icon-quick-cart.svg");
    background-position: center;
    background-repeat: no-repeat;
    background-size: contain;
    content: "";
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
    margin: 0 60px 0 0;
    width: 300px;
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
        content: "";
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

.product-image {
  width: 210px;
  margin-bottom: 1rem;
  /deep/ .promotion {
    .text {
      font-size: 20px;
      &.min-text {
        font-size: 16px;
      }
      &.min-sm-text {
        font-size: 13px;
      }
    }
  }
}

.image-container{
  width: 100%;
  display: flex;
  justify-content: center;
}

.product-sales {

  .product-card-container {

    .card-container {
      padding: 1em;
    }
  }
  .card-brand {
    font-size: 16px;
  }
}

</style>
