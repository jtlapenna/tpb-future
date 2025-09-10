<template>
  <div  id="screen-product" :class="{ 'screen--product--full-screen': getIsFullScreenProduct() }" class="screen screen--product" style="opacity: 0">
    <div v-show="!getIsFullScreenProduct()" class="product">
      <button v-on:click="goBack()" type="button" class="link-back">
        <span class="link-back__arrow"></span>
        <span class="link-back__text">Back</span>
        <span class="link-back__background"></span>
      </button>

      <div class="product__main">
        <div class="product__main__inner">
          <header class="product__header">
            <h1 class="product__title">{{ name }}</h1>

            <div class="product__meta">
              <span v-if="type" class="product__meta__label">{{ type }}</span>

              <span v-if="brand" class="product__meta__label">
                <router-link
                  :to="{ name: 'brands', query: { brand: product.brand.id } }"
                  >{{ brand }}</router-link
                >
              </span>

              <span v-if="rating > 0" class="product__rating">
                <div
                  v-for="index in 5"
                  v-bind:key="'note' + index"
                  class="product__rating__note"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="25"
                    height="15"
                    viewBox="0 0 25 15"
                  >
                    <path
                      v-if="index <= rating"
                      class="product__rating__star product__rating__star--plain"
                      d="M8 0L5.5 4.9 0 5.7l4 3.8L3 15l5-2.6 4.9 2.6-.9-5.4 4-3.8-5.5-.8L8 0z"
                    />
                    <path
                      class="product__rating__star"
                      d="M8 0L5.5 4.9 0 5.7l4 3.8L3 15l5-2.6 4.9 2.6-.9-5.4 4-3.8-5.5-.8L8 0z"
                    />
                  </svg>
                </div>
                <!-- .note -->
              </span>
              <!-- .product__rating -->
            </div>
            <!-- .product__meta -->
          </header>
          <!-- .product__header -->

          <ul class="product__tabs">
            <li
              v-for="(tab, index) in tabs"
              v-show="index >= (tabsPage - 1) * 4 && index < tabsPage * 4"
              v-bind:key="'tab-' + index"
              v-bind:class="{ 'product__tab--is-active': activeTab === tab }"
              v-on:click="activeTab = tab"
              class="product__tab"
            >
              {{ tab }}
              <div class="product__tab__line"></div>
            </li>

            <li
              v-if="tabs && tabs.length > 4"
              v-on:click="switchTabsPage"
              class="product__tab product__tab--more"
            >
              More
              <div class="product__tab__icon"></div>
            </li>
          </ul>

          <div class="product__blocks">
            <transition
              v-on:enter="blockTransitionEnter"
              v-on:leave="blockTransitionLeave"
              v-bind:css="false"
              mode="out-in"
            >
              <section
                v-if="activeTab === 'Overview'"
                key="blockOverview"
                class="product__block section product__block--overview"
              >
                <div class="product__content product__content--text">
                  <div class="product__content__inner">
                    <div
                      class="product__content__description"
                      v-html="
                        description
                          ? description
                          : $config.TEXT.PRODUCT_DESCRIPTION
                      "
                    ></div>
                    <a
                      v-if="video"
                      v-bind:href="video"
                      data-fancybox="video"
                      class="button-video"
                      >Watch video</a
                    >
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->

                <div
                  v-if="images && images.length > 1"
                  class="product__content product__content--gallery"
                >
                  <h2 class="product__content__smalltitle">
                    <div class="product__content__smalltitle__text">
                      Gallery
                    </div>
                    <!-- .product__content__smalltitle__text -->
                    <div class="product__content__smalltitle__line"></div>
                  </h2>
                  <div class="product__content__inner">
                    <div class="gallery">
                      <div
                        v-for="(image, index) in images"
                        v-bind:key="image.id"
                        v-on:click="openGallery(index)"
                        class="gallery__thumb"
                      >
                        <a>
                          <img
                            v-bind:src="image.url"
                            alt
                            class="gallery__thumb__media"
                          />
                        </a>
                      </div>
                      <!-- .gallery__thumb -->
                    </div>
                    <!-- .gallery -->
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->

                <div
                  v-if="copyright && hasGraphs"
                  class="product__content product__content--copyright"
                >
                  <div class="product__content__inner">
                    <div class="product__copyright">
                      <div class="product__copyright__label">Powered by</div>

                      <img
                        src="/static/img/logo-wikileaf.svg"
                        class="product__copyright__logo product__copyright__logo--wikileaf"
                        v-if="
                          copyright &&
                            copyright.toLowerCase().indexOf('wikileaf') !== -1
                        "
                      />

                      <img
                        src="/static/img/logo-potguide.svg"
                        class="product__copyright__logo product__copyright__logo--potguide"
                        v-if="
                          copyright &&
                            copyright.toLowerCase().indexOf('potguide') !== -1
                        "
                      />
                    </div>
                    <!-- .product__copyright -->
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->

                <div
                  v-if="hasGraphs"
                  class="product__content product__content--graphs"
                >
                  <h2 class="product__content__smalltitle">
                    <div class="product__content__smalltitle__text">
                      Content
                    </div>
                    <!-- .product__content__smalltitle__text -->
                    <div class="product__content__smalltitle__line"></div>
                  </h2>

                  <div class="product__content__inner">
                    <product-graphs
                      v-bind:attributes="product.attribute_values"
                      v-bind:copyright="copyright"
                      v-bind:size="'medium'"
                    ></product-graphs>
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->

                <div
                  v-if="colors && colors.length > 0"
                  class="product__content product__content--colors"
                >
                  <h2 class="product__content__smalltitle">
                    <div class="product__content__smalltitle__text">Colors</div>
                    <!-- .product__content__smalltitle__text -->
                    <div class="product__content__smalltitle__line"></div>
                  </h2>
                  <div class="product__content__inner">
                    <div class="colors">
                      <div
                        v-for="(color, index) in colors"
                        v-bind:key="index"
                        v-bind:style="'background-color: ' + color.hex"
                        class="colors__color"
                      >
                        <div class="colors__color__inner">
                          <img
                            v-if="color.image"
                            v-bind:src="color.image"
                            v-bind:alt="color.name"
                            class="colors__color__image"
                          />
                          {{ color.name }}
                        </div>
                        <!-- .colors__color__inner -->
                      </div>
                      <!-- .colors__color -->
                    </div>
                    <!-- .colors -->
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->

                <div
                  v-if="tags && tags.length > 0 && showTags"
                  class="product__content product__content--tags"
                >
                  <h2 class="product__content__smalltitle">
                    <div class="product__content__smalltitle__text">Tags</div>
                    <!-- .product__content__smalltitle__text -->
                    <div class="product__content__smalltitle__line"></div>
                  </h2>

                  <div class="product__content__inner">
                    <ul class="tags">
                      <li
                        v-for="(tag, index) in tags"
                        v-bind:key="index"
                        class="tags__tag"
                      >
                        <router-link :to="tagRoute(tag)">{{ tag }}</router-link>
                      </li>
                    </ul>
                  </div>
                  <!-- .product__content__inner -->
                </div>
                <!-- .product__content -->
              </section>

              <section
                v-if="activeTab === 'Flavor'"
                key="blockFlavor"
                class="product__block product__block--flavor"
              >
                <div
                  v-for="paragraph in flavor"
                  v-bind:key="paragraph.name"
                  class="product__content product__content--text"
                >
                  <h2 class="product__content__title title-h2">
                    {{ paragraph.name }}
                  </h2>

                  <p>{{ paragraph.value }}</p>
                </div>
              </section>

              <section
                v-for="attribute in textAttributes"
                v-if="activeTab === attribute.name"
                v-bind:key="'block' + attribute.name"
                class="product__block product__block--text"
              >
                <div class="product__content product__content--text">
                  <div
                    v-html="
                      attribute.text
                        ? attribute.text.replace(/\n/g, '<br />')
                        : ''
                    "
                  ></div>
                </div>
              </section>

              <section
                v-if="activeTab === 'Attributes'"
                key="blockAttributes"
                class="product__block product__block--attributes"
              >
                <div class="attributes">
                  <div
                    v-for="group in attributes"
                    v-bind:key="group.name"
                    v-bind:class="
                      'attributes__group--' + group.name.toLowerCase()
                    "
                    class="attributes__group"
                  >
                    <h2 class="attributes__title title-h2">{{ group.name }}</h2>

                    <div
                      v-for="attribute in group.attributes"
                      v-bind:key="attribute.name"
                      class="attributes__attribute"
                    >
                      <div class="attributes__name">{{ attribute.name }}</div>
                      <!-- attributes__name -->

                      <div class="attributes__bar">
                        <div
                          class="attributes__progress"
                          v-bind:style="{
                            width: Number(attribute.value) * 100 + '%'
                          }"
                        ></div>
                      </div>
                      <!-- .attributes__bar -->
                    </div>
                    <!-- .attributes__attribute -->
                  </div>
                  <!-- .attributes__group -->
                </div>
                <!-- .attributes -->
              </section>

              <section
                v-if="activeTab === 'Similar products'"
                key="blockSimilar"
                class="product__block product__block--similar"
              >
                <product-card
                  v-for="product in similarProducts"
                  v-bind:key="product.id"
                  v-bind:product="product"
                  v-bind:source="'Similars'"
                  v-bind:layout="'small'"
                ></product-card>
              </section>
            </transition>
          </div>
          <!-- .product__blocks -->
        </div>
        <!-- product__main__inner -->

        <lottie-container
          v-bind:path="'block-default-intro'"
          v-bind:autoplay="false"
          v-bind:loop="false"
          ref="lottieBlockIntro"
        ></lottie-container>
      </div>
      <!-- .product__main -->

      <product-image
        :promo="promotion"
        v-bind:image="this.image"
        v-bind:category="this.category"
        v-bind:isMedicalOnly="product.is_medical_only"
        v-bind:isProductDetail="true"
      />
      <template>
        <form
          v-if="sortedPrices && sortedPrices.length > 0"
          class="product__add-to-cart"
        >
          <div class="product__add-to-cart__values">
            <label
              v-for="(price, index) in sortedPrices"
              v-bind:key="price.id"
              v-bind:class="{
                'product__add-to-cart__value--is-active':
                  selectedPrice.id === price.id
              }"
              class="product__add-to-cart__value"
            >
              <input
                type="radio"
                v-bind:value="price"
                v-model="selectedPrice"
                v-on:change="onChangeValue"
              />

              <div class="product__add-to-cart__value__button">
                <template>
                  <div
                    :class="[
                      sortedPrices.length > 3
                        ? 'pricesContainerExceed'
                        : 'pricesContainer'
                    ]"
                  >
                    <div
                      class="product__add-to-cart__value__price"
                      :style="{
                        color:
                          discountPrice && discountPrice > 0 && index === 0
                            ? '#999'
                            : ''
                      }"
                      :class="[
                        discountPrice && discountPrice > 0 && index === 0
                          ? 'price-description'
                          : '',
                        sortedPrices.length <= 1 &&
                        sortedPrices.length <= 2 &&
                        !discountPrice
                          ? 'price-container-limit'
                          : sortedPrices.length > 2
                          ? 'price-container-exceed'
                          : 'price-container'
                      ]"
                    >
                      <span
                        v-if="discountPrice && discountPrice > 0 && index === 0"
                        class="price-description"
                        >ORIGINALLY</span
                      >

                      <span
                        :class="
                          discountPrice &&
                            discountPrice > 0 &&
                            index === 0 &&
                            parseFloat(selectedPrice.value) !==
                              parseFloat(discountPrice) &&
                            'price-discount '
                        "
                        style="justify-self: start; align-self: center;"
                      >
                        {{ price.value | formatPrice }}
                      </span>
                    </div>

                    <div
                      class="product__add-to-cart__value__price price-container price-description"
                      v-if="discountPrice && discountPrice > 0 && index === 0"
                    >
                      <span class="price-description">SALE PRICE</span>

                      <span
                        style="justify-self: start; align-self: center;"
                        class="price-sale"
                      >
                        {{
                          discountPrice &&
                          discountPrice > 0 &&
                          index === 0 &&
                          parseFloat(selectedPrice.value) !==
                            parseFloat(discountPrice)
                            ? `$${discountPrice}`
                            : ''
                        }}
                      </span>
                    </div>

                    <div
                      class="product__add-to-cart__value__price price-container price-description"
                      v-if="discountPrice && discountPrice > 0 && index === 0"
                    >
                      <span class="price-description"></span>

                      <span style="justify-self: start; align-self: center;">
                        {{ price.name }}
                      </span>
                    </div>
                  </div>
                </template>

                <div
                  class="product__add-to-cart__value__name"
                  v-if="!discountPrice"
                >
                  {{ price.name }}
                </div>

                <lottie-container
                  v-bind:path="'block-default-intro'"
                  :autoplay="false"
                  :loop="false"
                  class="product__add-to-cart__value__background product__add-to-cart__value__background--intro intro"
                ></lottie-container>

                <lottie-container
                  v-bind:path="'block-default-outro'"
                  v-bind:autoplay="false"
                  v-bind:loop="false"
                  v-bind:frame="
                    selectedPrice === price ? 'firstFrame' : 'lastFrame'
                  "
                  class="product__add-to-cart__value__background product__add-to-cart__value__background--outro outro"
                ></lottie-container>
              </div>
            </label>
          </div>
          <!-- .product__add-to-cart__values -->

          <div
            v-if="$config.SHOPPING_ENABLED && product.stock > 0"
            class="product__add-to-cart__quantity"
          >
            <button
              v-on:click="selectedQty = Math.max(1, selectedQty - 1)"
              v-bind:style="{ opacity: selectedQty === 1 ? '0.2' : '' }"
              type="button"
              class="product__add-to-cart__quantity__button product__add-to-cart__quantity__button--minus"
            >
              -
            </button>

            <input
              type="text"
              v-model="selectedQty"
              disabled
              class="product__add-to-cart__quantity__field"
            />

            <button
              v-on:click="
                selectedQty = Math.min(product.stock, selectedQty + 1)
              "
              v-bind:style="{
                opacity: selectedQty === product.stock ? '0.2' : ''
              }"
              type="button"
              class="product__add-to-cart__quantity__button product__add-to-cart__quantity__button--plus"
            >
              +
            </button>
          </div>
          <!-- .product__add-to-cart__quantity -->

          <button
            v-if="$config.SHOPPING_ENABLED"
            :disabled="connected === false"
            v-bind:class="{
              'product__add-to-cart__submit--is-disabled':
                status !== 'isAvailable',
              'product__add-to-cart__submit--is-offline': connected === false
            }"
            v-on:click="addToCart"
            type="button"
            class="product__add-to-cart__submit"
          >
            <span class="product__add-to-cart__submit__text">
              {{ connected ? 'Add to cart' : 'Offline' }}
            </span>
            <span class="product__add-to-cart__submit__background"></span>
          </button>

          <div
            v-if="$config.SHOPPING_ENABLED"
            v-bind:class="{
              'product__add-to-cart__notification--is-visible':
                status === 'isAdded'
            }"
            class="product__add-to-cart__notification"
          >
            {{ status === 'isAdding' ? messageIsAdding : messageIsAdded }}
          </div>
          <!-- .product__add-to-cart__notification -->
        </form>
      </template>

      <!-- .product__add-to-cart -->
    </div>
    <div v-show="getIsFullScreenProduct()" >
<!--      <screen-product-image></screen-product-image>-->
      <screen-product-video v-if="isVideo()(video)" v-bind:video-src="video">
      </screen-product-video>

      <screen-product-image v-if="isImage()(video)" v-bind:image-src="video">
      </screen-product-image>
    </div>
    <!-- .product -->
  </div>

</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import ProductCard from '@/components/ProductCard'
import ProductGraphs from '@/components/ProductGraphs'
import ProductImage from '@/components/ProductImage'
import { TimelineLite, Linear, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import ProductRepo from '@/api/products/ProductsRepo'
import { mapGetters, mapMutations, mapState } from 'vuex'
import { GSAP_ANIMATION } from '@/const/globals.js'
import ScreenProductVideo from './ScreenProductVideo.vue'
import ScreenProductImage from './ScreenProductImage.vue'

export default {
  name: 'ScreenProduct',
  components: {
    ScreenProductImage,
    ScreenProductVideo,
    LottieContainer,
    ProductCard,
    ProductGraphs,
    ProductImage
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
  props: ['products'],
  data() {
    return {...this.defaultData(), routeTimeout: null, animationTimeout: null}
  },
  computed: {
    ...mapState(['connected']),

    hasGraphs: function() {
      let hasGraphs = false

      if (
        this.product !== null &&
        this.product !== undefined &&
        this.product.attribute_values &&
        this.product.attribute_values.ungrouped
      ) {
        this.product.attribute_values.ungrouped.forEach(function(attribute) {
          if (
            ['THC', 'THCA', 'CBD'].includes(attribute.name.toUpperCase()) &&
            parseFloat(attribute.value) > 0
          ) {
            hasGraphs = true
          }
        })
      }

      return hasGraphs
    },
    sortedPrices: function() {
      var unordoredPrices = this.prices
      if (unordoredPrices && unordoredPrices.length > 0) {
        return unordoredPrices.sort(function(a, b) {
          return Number(a.value) - Number(b.value)
        })
      } else {
        return unordoredPrices
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
    showTags: function() {
      return this.$config.POS_TYPE !== 'shopify'
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
  created() {
    // Set id from route params
    this.id = this.$route.params.id
    this.backToSale = this.$route.query.back_on_sale === true

    // Fetch data

    // Events

    this.$root.$on('product-added', this.onProductAdded)
    this.$root.$on('product-not-added', this.onProductNotAdded)
    this.$on('transition-leave', this.onTransitionLeave)
  },

  mounted() {
    this.fetchData()
  },
  destroyed: function() {// Events
    this.$root.$off('product-added', this.onProductAdded)
    this.$root.$off('product-not-added', this.onProductNotAdded)
    this.$off('transition-leave', this.onTransitionLeave)
    this.setIsFullScreenProduct(false)
  },
  watch: {
    'product.id': {
      handler(newId, oldId) {
        if (oldId && newId !== oldId) {
          if (this.routeTimeout) {
            clearTimeout(this.routeTimeout)
            this.routeTimeout = null
          }
          if (this.animationTimeout) {
            clearTimeout(this.animationTimeout)
            this.animationTimeout = null
          }
        }
      }
    },
    // video: {
    //   immediate: true,
    //   handler(newVideo, oldVideo) {
    //     // debugger;
    //     // // Handle new video
    //     // if (newVideo) {
    //     //   // If you're using the video in a video element, you may need to wait for the next tick
    //     //   this.$nextTick(() => {
    //     //     const videoElement = document.querySelector('video'); // Or use a ref
    //     //     if (videoElement) {
    //     //       videoElement.play().catch(err => console.warn('Video autoplay failed:', err));
    //     //     }
    //     //   });
    //     // }
    //   }
    // },
    $route(to, from) {
      var self = this
      console.log('cambiando de ruta')
      if (this.timeout) {
        clearTimeout(this.timeout)
        this.timeout = null
      }
      if(this.animationTimeout) {
        clearTimeout(this.animationTimeout)
        this.animationTimeout = null
      }
      // Close opened fancybox
      $.fancybox.close()

      // Call transition leave with a callback
      this.onTransitionLeave(this.$el, function() {
        // Disable tab animation and reset tab after transition leave
        self.blockTransitionEnabled = false

        // Reset data
        var data = self.defaultData()

        for (let property in data) {
          let value = data[property]
          self[property] = value
        }

        // Changing from a product to another
        self.id = self.$route.params.id

        self.$nextTick(function() {
          // After reset enable tab animation and fetch new data
          self.blockTransitionEnabled = true
          self.fetchData()
        })
      })
    }
  },
  methods: {
    ...mapGetters('products', [ 'getIsFullScreenProduct', 'isImage', 'isVideo']),
    ...mapMutations('products', [ 'setIsFullScreenProduct' ]),

    moveToHomeWithDelay: function() {
      const self = this
      if (this.getIsFullScreenProduct()) {
        if (self.timeout) {
          clearTimeout(self.timeout)
          self.timeout = null
        }
        if (self.animationTimeout) {
          clearTimeout(self.animationTimeout)
          self.animationTimeout = null
        }
        self.animationTimeout = setTimeout(() => {
          self.$root.$emit('animate-full-screen-background')
        }, 28000)
        self.timeout = setTimeout(() => {
          self.$router.push({ name: 'home' })
          clearTimeout(self.timeout)
        }, 30000)
      }
    },
    /**
     * Product default data
     */
    defaultData: function() {
      return {
        activeTab: 'Overview',
        attributes: [],
        backToSale: false,
        blockTransitionEnabled: true,
        brand: null,
        category: null,
        colors: [],
        copyright: null,
        description: null,
        flavor: null,
        id: null,
        image: null,
        images: [],
        promotion: null,
        messageIsAdded: 'Product added',
        messageIsAdding: 'Adding product',
        name: null,
        prices: null,
        product: null,
        rating: 0,
        selectedPrice: null,
        selectedQty: 1,
        similarProducts: [],
        status: 'isAvailable',
        tabs: [],
        tabsPage: 1,
        tags: [],
        textAttributes: [],
        thumbnail: null,
        type: null,
        video: null,
        currentPage: 1
      }
    },

    /**
     * Screen transition enter
     */
    transitionEnter: function() {
      // Selectors
      var self = this

      var container = $(this.$el)

      // Before animation
      container.css({ opacity: '' })
      container
        .find('.product__tab--is-active .product__tab__line')
        .css({ transition: 'none', transform: 'none' })
      container.find('.product__block').css({ opacity: 0 })

        this.$root.$emit('block-pointer', true)


      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container.find('.product__main .lottie-container--block-default-intro'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.link-back__background'),
        GSAP_ANIMATION.duration,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.fromTo(
        container.find('.link-back__arrow'),
        GSAP_ANIMATION.duration,
        {
          scale: 0
        },
        {
          scale: 1,
          clearProps: 'transform',
          ease: Power2.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.fromTo(
        container.find('.link-back__text'),
        GSAP_ANIMATION,
        {
          alpha: 1
        },
        {
          alpha: 0,
          ease: Linear.easeNone
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerFromTo(
        container.find('.product__title, .product__meta'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30
        },
        {
          alpha: 1,
          y: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      container.find('.product__tab:visible').each(function(index) {
        var tab = $(this)
        var start = GSAP_ANIMATION.tween + 0.1 * index

        tl.fromTo(
          tab,
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 30
          },
          {
            alpha: 1,
            y: 0,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          start
        )

        tl.fromTo(
          tab.filter('.product__tab--is-active').find('.product__tab__line'),
          GSAP_ANIMATION.duration,
          {
            scaleX: 0
          },
          {
            scaleX: 1,
            clearProps: 'transform, transition',
            ease: Power3.easeInOut
          },
          start + 0.1
        )

        tl.fromTo(
          tab.filter('.product__tab--more').find('.product__tab__icon'),
          GSAP_ANIMATION.duration,
          {
            scale: 0
          },
          {
            scale: 1,
            clearProps: 'transform, transition',
            ease: Power3.easeInOut
          },
          start + 0.1
        )

        tab = null
      })

      tl.call(
        function() {
          if (container) {
            self.blockTransitionEnter(
              container.find('.product__block').get(0),
              false
            )
          }
        },
        null,
        null,
        0.8
      )

      tl.staggerFromTo(
        container.find('.product-image, .product__add-to-cart__value'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30
        },
        {
          alpha: 1,
          y: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      const nonSelectedVals = container
        .find('.product__add-to-cart__value')
        .not('.product__add-to-cart__value--is-active')
        .toArray()
      console.log('nonSelectedVals', nonSelectedVals)

      if (nonSelectedVals) {
        tl.call(
          () => {
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
          },
          null,
          null,
          0.5
        )
      }

      tl.fromTo(
        container.find('.product__add-to-cart__quantity'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30
        },
        {
          alpha: 1,
          y: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.product__add-to-cart__submit__background'),
        GSAP_ANIMATION.duration,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.fromTo(
        container.find('.product__add-to-cart__submit__text'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 20
        },
        {
          alpha: 1,
          y: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function() {
        self.$root.$emit('block-pointer', false)

        tl.kill()

        tl = null
        container = null
      })

      tl.play()

      // self.transitionEnter = () => {}
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function(el, done) {
      // Selectors
      var self = this
      var container = $(el)
      var blockAnimation = self.$refs.lottieBlockIntro.animation

      // Before animation
      container

        .find('.product__tab--is-active .product__tab__line')
        .css({ transition: 'none' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerTo(
        container
          .find(
            '.product-image, .product__add-to-cart__values, .product__add-to-cart__quantity,  .product__add-to-cart__submit'
          )
          .reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn,
          overwrite: 'all'
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.fromTo(
        container.find('.link-back'),
        GSAP_ANIMATION.duration,
        {
          alpha: 1,
          x: 0
        },
        {
          alpha: 0,
          x: -10,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.append
      )

      tl.call(
        function() {
          self.blockTransitionLeave(container.find('.product__block'), false)
        },
        null,
        null,
        0
      )

      tl.to(
        container.find('.product__tab--is-active .product__tab__line'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.product__tab'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn,
          overwrite: 'all'
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerTo(
        container.find('.product__title, .product__meta').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.call(
        function() {
          if (blockAnimation) {
            blockAnimation.setDirection(-1)
            blockAnimation.play()

            blockAnimation = null
          }
        },
        null,
        null,
        0.6
      )

      tl.to(
        container.find('.product__main .lottie-container--block-default-intro'),
        GSAP_ANIMATION.duration,
        {
          scaleX: 0,
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(
        function() {
          if (container) {
            container
              .find(
                '.product-image, .product__add-to-cart__values, .product__add-to-cart__quantity,  .product__add-to-cart__submit, .link-back, .product__tab--is-active .product__tab__line, .product__tab, .product__title, .product__meta'
              )
              .css({ opacity: '', transform: '' })
            container
              .find('.product__tab--is-active .product__tab__line')
              .css({ transition: '' })
            container.css({ opacity: 0 })
          }

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
     * Block transition enter
     */
    blockTransitionEnter: function(el, done) {
      // Transition disabled, call done callback directly
      if (this.blockTransitionEnabled === false) {
        done()
        return
      }

      // Selectors
      var container = $(el)

      // Before animation
      container.css({ opacity: '' })

      // Animation
      var tl = new TimelineLite()
      // tl.pause()

      if (container.hasClass('product__block--overview')) {
        container.find('.product__content').each(function(index) {
          var content = $(this)
          var start = GSAP_ANIMATION.tween * index

          tl.from(
            content.find('.product__content__smalltitle__text'),
            GSAP_ANIMATION.duration,
            {
              alpha: 0,
              x: -10,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            start
          )

          tl.from(
            content.find('.product__content__smalltitle__line'),
            GSAP_ANIMATION.duration,
            {
              scaleX: 0,
              clearProps: 'transform',
              ease: Power3.easeInOut
            },
            start
          )

          tl.from(
            content.find('.product__content__inner'),
            GSAP_ANIMATION.duration,
            {
              alpha: 0,
              y: 30,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            start + 0.2
          )

          if (content.hasClass('product__content--graphs')) {
            content.find('.graph').each(function(index) {
              var graph = $(this)

              start = start + 0.3 * index

              tl.staggerFrom(
                graph.find(
                  '.graph__line, .graph__label, .graph__value, .graph__limit'
                ),
                GSAP_ANIMATION.duration,
                {
                  alpha: 0,
                  y: 30,
                  clearProps: 'transform, opacity',
                  ease: Power3.easeOut
                },
                GSAP_ANIMATION.tween,
                start + 0.2
              )

              if (graph.hasClass('graph--circle')) {
                tl.from(
                  graph.find('circle:last-child'),
                  GSAP_ANIMATION.duration,
                  {
                    strokeDashoffset: 383,
                    ease: Power3.easeOut
                  },
                  start + 0.4
                )
              } else if (graph.hasClass('graph--gauge')) {
                tl.from(
                  graph.find('circle:last-child'),
                  GSAP_ANIMATION.duration,
                  {
                    strokeDashoffset: 484,
                    ease: Power3.easeOut
                  },
                  start + 0.4
                )
              }

              graph = null
            })
          }

          content = null
        })
      } else if (container.hasClass('product__block--flavor')) {
        tl.staggerFrom(
          container.find('.product__content > *'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            x: function(index, target) {
              return $(target).is('.product__content__title') ? -10 : 0
            },
            y: function(index, target) {
              return $(target).is('.product__content__title') ? 0 : 30
            },
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          GSAP_ANIMATION.tween
        )
      } else if (container.hasClass('product__block--attributes')) {
        container.find('.attributes__group').each(function(index) {
          var group = $(this)
          var start = GSAP_ANIMATION.tween * index

          tl.from(
            group.find('.attributes__title'),
            GSAP_ANIMATION.duration,
            {
              alpha: 0,
              x: -10,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            start
          )

          tl.staggerFrom(
            group.find('.attributes__name'),
            GSAP_ANIMATION.duration,
            {
              alpha: 0,
              y: 30,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            GSAP_ANIMATION.tween,
            start + 0.1
          )

          tl.staggerFrom(
            group.find('.attributes__bar'),
            GSAP_ANIMATION.duration,
            {
              scaleX: 0,
              clearProps: 'transform',
              ease: Power3.easeInOut
            },
            GSAP_ANIMATION.tween,
            start + 0.2
          )

          tl.staggerFrom(
            group.find('.attributes__progress'),
            GSAP_ANIMATION.duration,
            {
              scaleX: 0,
              clearProps: 'transform',
              ease: Power3.easeInOut
            },
            GSAP_ANIMATION.tween,
            start + 0.3
          )

          group = null
        })
      } else if (container.hasClass('product__block--similar')) {
        tl.staggerFrom(
          container.find('.product-image').slice(0, 4),
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
          container.find('.product-card__info').slice(0, 4),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            clearProps: 'opacity',
            ease: Linear.easeNone
          },
          GSAP_ANIMATION.tween,
          GSAP_ANIMATION.append
        )
      } else {
        tl.from(container, 0.5, {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        })
      }

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        if (done !== false) {
          done()
        }
      })

      tl.play()
    },

    /**
     * Block transition leave
     */
    blockTransitionLeave: function(el, done) {
      // Transition disabled, call done callback directly
      if (this.blockTransitionEnabled === false) {
        done()
        return
      }

      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      if (
        container.hasClass('product__block--overview') ||
        container.hasClass('product__block--flavor')
      ) {
        tl.staggerFromTo(
          container.find('.product__content').reverse(),
          GSAP_ANIMATION.duration,
          {
            alpha: 1,
            y: 0
          },
          {
            alpha: 0,
            y: 30,
            ease: Power3.easeIn
          },
          GSAP_ANIMATION.tween
        )

        tl.call(function() {
          if (container) {
            container
              .find('.product__content')
              .css({ opacity: '', transform: '' })
            container.css({ opacity: 0 })
          }
        })
      } else if (container.hasClass('product__block--attributes')) {
        tl.staggerTo(
          container.find('.attributes__group').reverse(),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 30,
            ease: Power3.easeIn
          },
          GSAP_ANIMATION.tween
        )

        tl.call(function() {
          if (container) {
            container
              .find('.attributes__group')
              .css({ opacity: '', transform: '' })
            container.css({ opacity: 0 })
          }
        })
      } else {
        tl.to(container, GSAP_ANIMATION.duration, {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        })
      }

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        if (done !== false) {
          done()
        }
      })
      tl.play()
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
      var oldValue = $('.product__add-to-cart__value--is-active')

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
      if (this.status !== 'isAvailable') return
      this.status = 'isAdding'

      // Trigger global event with product information
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

      console.log(this.product)
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
     * Fetch data
     */
    fetchData: async function() {
      var self = this
      let times = 0
      ProductRepo.show(self.id).subscribe(
        async product => {
          this.product = product
          console.log('Producto datos', this.product)

          if (product === undefined) {
            return
          }
          times = times + 1


          if (this.product.stock === null) {
            this.product.stock = 0
          }
          if (this.product.stock < 1) {
            this.status = 'outOfStock'
          }
          // Flat data
          if (this.product.brand) {
            this.brand = this.product.brand.name
          }
          if (this.product.catalog_category) {
            this.category = this.product.catalog_category.name
          }
          this.tags = this.product.tag_list
          this.description = this.product.description
          this.id = this.product.id
          if (this.product.primary_image) {
            this.image = this.product.primary_image
          }
          if (this.product.thumb_image) {
            this.thumbnail = this.product.thumb_image
          }

          if (
            this.product.store_product_promotions &&
            this.product.store_product_promotions.length > 0
          ) {
            this.promotion = this.product.store_product_promotions[0].promotion
          }

          this.images = this.product.images
          this.video = null
          this.$nextTick(() => {
            this.video = this.product.video_url;
          })

          // TODO: We do this because I don't want to refactor how the observer is working with the promises inside of it.
          if (this.product.is_full_screen) {
            this.setIsFullScreenProduct(true)
            this.moveToHomeWithDelay()
          } else {
            this.setIsFullScreenProduct(false)
          }

          this.name = this.product.name
          this.prices = this.product.product_values
          this.selectedPrice = this.sortedPrices[0]
          // GS event tracker
          if (self.$gsClient && times === 1) {
            self.$gsClient.track('Product view', {
              source: this.$route.params.source,
              name: this.product.name,
              id: this.product.sku,
              product_id: this.product.id,
              brand: this.brand,
              category: this.category,
              quantity: this.product.stock,
              price: this.selectedPrice ? this.selectedPrice.value : '',
              tag_list: this.product.tag_list,
              stock: this.product.stock
            })
          }

          // Ungrouped attributes
          if (
            this.product.attribute_values &&
            this.product.attribute_values.ungrouped
          ) {
            this.product.attribute_values.ungrouped.forEach(function(
              attribute
            ) {
              if (attribute.name === 'Type') {
                self.type = attribute.value
              } else if (attribute.name === 'Copyright') {
                self.copyright = attribute.value
              }
            })
          }

          // Ungrouped attributes
          if (
            this.product.attribute_values &&
            this.product.attribute_values.ungrouped
          ) {
            this.product.attribute_values.ungrouped.forEach(function(
              attribute
            ) {
              if (attribute.name === 'Type') {
                self.type = attribute.value
              } else if (attribute.name === 'Copyright') {
                self.copyright = attribute.value
              }
            })
          }

          // Grouped attributes
          if (
            this.product.attribute_values &&
            this.product.attribute_values.grouped
          ) {
            for (let attribute in this.product.attribute_values.grouped) {
              let value = this.product.attribute_values.grouped[attribute]
              value.sort(function(a, b) {
                return Number(b.value) - Number(a.value)
              })

              if (attribute === 'Flavor') {
                this.flavor = value
              } else if (
                ['Moods', 'Medical', 'Effects'].indexOf(attribute) > -1
              ) {
                this.attributes.push({
                  name: attribute,
                  attributes: value
                })
              } else if (attribute === 'Text Attributes') {
                for (var index in value) {
                  var textAttribute = {
                    name: value[index].name,
                    text: value[index].value
                  }

                  this.textAttributes.push(textAttribute)
                }
              }
            }

            this.attributes.sort(function(a, b) {
              return a.name < b.name
            })
          }

          // Add tabs
          if (times === 1) {
            self.$nextTick(() => {
              console.log('TRIGGERING ANIMATION', self.transitionEnter)
              self.transitionEnter()
            })
          }

          try {
            await self.fetchSimilars()
            this.setUpTabs()
          } catch (e) {
            console.error(e)
          }
        },
        error => {
          console.error(error)
          self.$nextTick(self.transitionEnter)
        }
      )
    },

    fetchSimilars() {
      return this.$http
        .get('products/' + this.id + '/similars?per_page=50&minimal=true')
        .then(response => {
          this.similarProducts = this.products.filter(function(product) {
            return response.data.products.includes(product.id)
          })

          if (
            this.similarProducts.length > 0 &&
            !this.tabs.includes('Similar products')
          ) {
            this.tabs.push('Similar products')
          }
          return this.similarProducts
        })
    },
    setUpTabs() {
      if (!this.tabs.includes('Overview')) {
        this.tabs.splice(0, 0, 'Overview')
      }

      if (this.tabs.includes('Flavor') === false && this.flavor) {
        this.tabs.push('Flavor')
      }

      if (this.attributes.length > 0 && !this.tabs.includes('Attributes')) {
        this.tabs.push('Attributes')
      }

      for (let attribute in this.textAttributes) {
        let value = this.textAttributes[attribute]
        if (!this.tabs.includes(value.name)) {
          this.tabs.push(value.name)
        }
      }
    },

    /**
     * Go back to previous screen
     */
    goBack: function() {
      this.$router.go(-1)
    },

    /**
     * Switch tags page
     */
    switchTabsPage: function() {
      // Selectors
      var self = this
      var container = $(this.$el)
      var tabs = container.find('.product__tab')

      // Before animation
      container

        .find('.product__tab--is-active .product__tab__line')
        .css({ transition: 'none', transform: 'none' })

      // Animation
      var tl = new TimelineLite()

      tl.staggerFromTo(
        tabs.filter(':visible'),
        GSAP_ANIMATION.duration,
        {
          alpha: 1,
          y: 0
        },
        {
          alpha: 0,
          y: 10,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function() {
        if (container) {
          tabs.css({ opacity: 0, transform: '' })

          // Set new page
          self.tabsPage++
          var maxPage = Math.ceil(self.tabs.length / 4)

          if (self.tabsPage > maxPage) {
            self.tabsPage = 1
          }
        }
      })

      tl.call(
        function() {
          tl.staggerFromTo(
            tabs.filter(':visible'),
            GSAP_ANIMATION.duration,
            {
              alpha: 0,
              y: 10
            },
            {
              alpha: 1,
              y: 0,
              ease: Power3.easeOut
            },
            GSAP_ANIMATION.tween
          )

          tl.call(function() {
            if (container) {
              container
                .find('.product__tab--is-active .product__tab__line')
                .css({ transition: '', transform: '' })
              tabs.css({ opacity: '', transform: '' })
            }
          })
        },
        null,
        null,
        '+=0.1'
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null
        tabs = null
      })

      tl.play()
    },

    /**
     * Generate tag route
     * @param  {String} tag
     * @return {Object} Route
     */
    tagRoute: function(tag) {
      var self = this

      // Default route
      var route = {
        name: 'products',
        query: {
          tags: [tag]
        }
      }

      // Check if the category link is used in nav
      var useCategory = this.$config.NAV.some(function(link) {
        return link.path === '/products/' + self.product.catalog_category.id
      })

      if (useCategory) {
        route = {
          name: 'category',
          params: {
            categoryId: self.product.catalog_category.id
          },
          query: {
            tags: [tag]
          }
        }
      }

      return route
    },

    openGallery: function(index) {
      let body = {
        images: this.images.map(i => i.url),
        index
      }
      this.$root.$emit('open-gallery', body)
    }
  }
}
</script>

<style scoped lang="scss">
.hidden {
  display: none;
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

.product {
  &__main {
    padding: 120px 80px 0;
    position: absolute;
    top: 0;
    left: 0;
    width: 820px;
    height: 100%;

    &__inner {
      display: flex;
      position: relative;
      height: 100%;

      flex-direction: column;
      justify-content: flex-start;
      z-index: 2;
    }

    .lottie-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      transform-origin: 0 0;
      z-index: 1;
    }

    /deep/ .lottie-container {
      path {
        fill: rgba($bluecharcoal, 0.3);
      }
    }
  }

  &__title {
    margin: 0 0 25px;

    font: 58px/1.2 var(--font-extralight);
    text-indent: -0.05em;
  }

  &__meta {
    &__label {
      float: left;
      margin: 0 1.82em 0 0;
      position: relative;

      color: rgba($white, 0.5);
      font: 0.55em/1 var(--font-semibold);
      letter-spacing: 0.25em;
      text-transform: uppercase;

      &:before {
        display: inline-block;
        margin: 0 0.18em 0 0;
        width: 0.18em;
        height: 0.91em;

        background-color: var(--main-color);
        content: '';
        vertical-align: top;
      }

      a {
        color: inherit;
      }
    }
  }

  &__rating {
    float: left;
    margin-top: -3px;

    svg {
      display: block;
      width: 25px;
      height: 15px;
    }

    &__note {
      float: left;
    }

    &__star {
      fill: rgba($white, 0.2);

      &--plain {
        fill: $white;
      }
    }
  }

  &__tabs {
    display: flex;
    margin: 60px 0 0.75em;
    padding: 0;
    position: relative;

    flex-direction: row;
    flex-wrap: nowrap;
    justify-content: flex-start;
    list-style: none;
  }

  &__tab {
    display: inline-block;
    margin: 0 2em 0 0;
    position: relative;

    transition: color 0.1s linear 0.15s;

    color: rgba($white, 0.3);
    font: 0.75em/1 var(--font-extrabold);
    letter-spacing: 0.1em;
    text-transform: uppercase;
    white-space: nowrap;

    &:last-child {
      margin-right: 0;
    }

    &__line {
      display: block;
      position: absolute;
      left: 0;
      bottom: -0.67em;
      width: 100%;
      height: 0.27em;

      background-color: var(--main-color);
      transform: scaleX(0);
      transition: transform 0.5s cubic-bezier(0.77, 0, 0.175, 1);
    }

    &--more {
      margin-left: 1.33em;
      padding-left: 1.13em;
      // position: absolute;
      // top: 0;
      // left: 100%;

      .product__tab__icon {
        display: block;
        position: absolute;
        top: 0.33em;
        left: 0;
        width: 0.73em;
        height: 0.73em;

        &:before,
        &:after {
          position: absolute;
          top: 0;
          left: 0;

          width: 0.73em;
          height: 0.2em;

          background: var(--main-color);
          content: '';
        }
        &:after {
          transform: rotateZ(90deg);
        }
      }
    }

    &--is-active {
      transition-delay: 0.1s;

      color: $white;

      .product__tab__line {
        transform: scaleX(1);
      }
    }
  }

  &__blocks {
    margin: 0 -70px 0 0;
    padding: 0 70px 0 0;
    position: relative;

    align-self: stretch;
    // background: red;
    flex-grow: 1;
  }

  &__block {
    overflow-x: hidden;
    overflow-y: scroll;
    padding: 15px 10px 0;
    position: absolute;
    top: 0;
    left: -10px;
    width: calc(100% + 20px);
    height: 100%;

    &--flavor,
    &--attributes {
      padding-top: 1em;
    }

    &--similar {
      margin: 0 -30px;
      padding: 15px 30px 60px;

      mask-image: linear-gradient(
        to bottom,
        transparent 0%,
        rgba(0, 0, 0, 1) 10%,
        rgba(0, 0, 0, 1) 90%,
        transparent 100%
      );
      mask-origin: padding-box;

      .product-card {
        margin: 60px 0 0;

        &:first-child {
          margin-top: 30px;
        }
      }
    }
  }

  &__content {
    margin: 0 0 55px;
    position: relative;

    &__smalltitle {
      display: block;
      margin: 0 0 2.67em;
      position: relative;
      width: 100%;

      color: rgba($white, 0.3);
      font: 0.75em/1 var(--font-extrabold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &__line {
        display: block;
        position: absolute;
        left: 0;
        bottom: -0.67em;
        width: 1.33em;
        height: 0.27em;

        background-color: var(--main-color);
        transform-origin: 0 0;
      }
    }

    &__description {
      white-space: break-spaces;
      word-break: break-word;
    }

    &--graphs {
      .product__content__inner {
        display: flex;

        align-items: center;
        flex-direction: row;
        justify-content: flex-start;
        flex-wrap: wrap;
      }
    }

    &--text {
      margin-top: 2em;

      &:first-child {
        margin-top: 0;
      }
    }

    &--gallery,
    &--colors {
      .product__content__smalltitle {
        margin-bottom: 30px;
      }
    }

    &--copyright {
      margin: -25px 0 25px;
    }
  }

  &__copyright {
    &__label {
      margin: 0 0 0.91em;

      color: rgba($white, 0.2);
      font: 0.55em/1 var(--font-semibold);
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }

    &__logo {
      display: inline-block;
      margin: 0 10px 0 0;
      height: auto;

      &:last-child {
        margin-right: 0;
      }

      &--wikileaf {
        width: 116px;

        opacity: 0.5;
      }

      &--potguide {
        width: 144px;
      }
    }

    &--graphs {
      margin: 0 0 1em;
    }
  }

  &__add-to-cart {
    position: absolute;
    left: 920px;
    top: 640px;
    width: 580px;

    &__values {
      display: flex;
      margin: 0 -5px;
      width: 100%;

      flex-direction: row;
      justify-content: stretch;
    }

    &__value {
      margin: 0 5px;
      overflow: hidden;
      position: relative;
      height: 120px;

      flex-grow: 1;
      flex-shrink: 1;

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
        padding: 10px;
        position: relative;
        width: 100%;
        height: 100%;

        background: none;
        border-radius: 20px;
        flex-direction: column;
        justify-content: center;
        overflow: hidden;
        transition: background 0.1s linear;
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
        position: relative;

        z-index: 2;

        font-size: 1.57em;
      }

      &__name {
        margin: 10px 0 0;
        position: relative;

        z-index: 2;

        letter-spacing: 0.1em;
        text-transform: uppercase;
      }
    }

    &__quantity {
      float: left;
      margin: 2.75em 0 0;

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

    &__submit {
      float: right;
      margin: 2em 0 0;
      position: relative;
      width: 12.5em;
      height: 4em;

      background: transparent;
      border: none;
      opacity: 1;
      transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
        opacity 0.2s linear;

      color: $white;
      font: 1em/4em var(--font-extrabold);
      letter-spacing: 0.05em;
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
        border-radius: 2em;
        transform: translate3d(-50%, 0, 0);
        z-index: 1;
      }

      &--is-disabled {
        opacity: 0;
        transform: translate3d(0, 10px, 0);
        pointer-events: none;
      }
      &--is-offline {
        .product__add-to-cart__submit__background {
          filter: grayscale(1);
        }
      }
    }

    &__notification {
      position: absolute;
      bottom: 33px;
      right: 0;
      width: 250px;

      opacity: 0;
      pointer-events: none;
      transform: translate3d(0, -10px, 0);
      transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
        opacity 0.2s linear;

      color: $white;
      line-height: 1;
      text-align: center;

      &--is-visible {
        opacity: 1;
        transform: translate3d(0, 0, 0);
      }
    }
  }
}

.product-image {
  position: absolute;
  top: 150px;
  left: 1005px;
  width: 410px;
  /deep/ .promotion {
    .text {
      line-height: 1.2em;
      font-size: 2rem;
      &.min-text {
        font-size: 1.75rem;
      }
      &.min-sm-text {
        font-size: 1.25rem;
      }
    }
  }
}

.title-h2 {
  margin: 0 0 0.5em;

  color: rgba($white, 0.5);
  font: 30px/1 var(--font-extralight);
}

.button-video {
  display: block;
  margin: 30px 0 0;
  padding: 0 0 0 45px;
  position: relative;
  width: 190px;
  height: 50px;

  background: rgba($white, 0.1);
  border: none;
  border-radius: 25px;

  color: $white;
  font: 14px/50px var(--font-semibold);
  letter-spacing: 0.15em;
  text-align: left;
  text-transform: uppercase;

  &:after {
    display: block;
    position: absolute;
    top: 50%;
    left: 20px;
    width: 12px;
    height: 16px;

    background-image: url('~@/assets/img/icon-play.svg');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 16px 16px;
    content: '';
    transform: translate3d(0, -50%, 0);
  }
}

.gallery {
  display: flex;

  align-items: flex-start;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: flex-start;

  &__thumb {
    margin: 0 20px 20px 0;
    position: relative;
    width: 75px;
    height: 75px;

    border-radius: 10px;
    flex-grow: 0;
    flex-shrink: 0;
    overflow: hidden;

    &--video {
      &:after {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        background-color: rgba($black, 0.5);
        background-image: url('~@/assets/img/icon-play.svg');
        background-position: center;
        background-repeat: no-repeat;
        background-size: 22px 22px;
        content: '';
      }
    }

    &__media {
      display: block;
      width: 100%;
      height: 100%;

      object-fit: cover;
    }
  }
}

.colors {
  display: flex;
  max-width: 554px;

  align-items: flex-start;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: flex-start;

  &__color {
    margin: 20px 20px 0 0;
    position: relative;
    width: 62px;
    height: 62px;

    border-radius: 50%;
    flex-grow: 0;
    flex-shrink: 0;

    text-indent: -999em;

    &:before {
      display: block;
      position: absolute;
      top: -4px;
      right: -4px;
      bottom: -4px;
      left: -4px;

      border: 4px solid rgba($white, 0.2);
      border-radius: 50%;
      content: '';
    }

    &:nth-child(-n + 7) {
      margin-top: 0;
    }

    &:nth-child(7n) {
      margin-right: 0;
    }

    &__inner {
      display: block;
      position: relative;
      width: 100%;
      height: 100%;

      border-radius: 50%;
      overflow: hidden;
    }

    &__image {
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      object-fit: cover;
    }

    &--is-active {
      &:before {
        top: -6px;
        right: -6px;
        bottom: -6px;
        left: -6px;

        border-color: $white;
        border-width: 6px;
      }
    }
  }
}

.tags {
  margin: 0;
  padding: 0;

  list-style: none;

  &__tag {
    display: inline-block;
    margin: 0 1.25em 1.25em 0;
    padding: 0.75em 1.25em;

    background: rgba($white, 0.1);
    border-radius: 1.25em;
    z-index: 2;

    color: rgba($white, 0.5);
    font: 0.8em/1 var(--font-semibold);
    letter-spacing: 0.1em;
    text-transform: uppercase;

    a {
      color: inherit;
    }

    &:last-child {
      margin-right: 0;
    }
  }
}

.attributes {
  display: flex;
  width: 100%;

  align-items: flex-start;
  flex-direction: row;
  justify-content: flex-start;

  &__group {
    margin: 0 60px 0 0;
    width: 180px;

    &:last-child {
      margin-right: 0;
    }

    &--medical {
      .attributes__progress {
        background-color: #00b0e5;
      }
    }

    &--moods {
      .attributes__progress {
        background-color: #00c796;
      }
    }

    &--effects {
      .attributes__progress {
        background-color: #e12291;
      }
    }
  }

  &__attribute {
    margin: 1.36em 0 0;

    font-size: 1.1em;
  }

  &__bar {
    display: block;
    margin: 5px 0 0;
    width: 180px;
    height: 0.5em;

    background-color: rgba($white, 0.1);
    border-radius: 0.25em;
    transform-origin: 0 0;
  }

  &__progress {
    display: block;
    width: 0;
    height: 100%;

    background-color: var(--main-color);
    border-radius: inherit;
    transform-origin: 0 0;
  }
}
.pricesContainer {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.pricesContainerExceed {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.price-discount {
  text-decoration: line-through;
  text-decoration-color: var(--main-color);
  text-decoration-thickness: 2px;
}

.price-container {
  display: grid;
  align-items: center;
  grid-template-columns: 47% auto; /* Defines two column tracks */
  width: 100%;
  font-size: 1.1rem;
  gap: 10px;
}

.price-container-limit {
  display: grid;
  align-items: center;
  justify-content: center;
  grid-template-columns: auto;
  /* Defines two column tracks */
  width: 100%;
  font-size: 1.1rem;
  gap: 10px;
}

.price-container-exceed {
  display: grid;
  align-items: center;
  grid-template-columns: 1fr 1fr; /* Defines two column tracks */
  /* Defines two column tracks */
  width: 100%;
  font-size: 1.1rem;
  gap: 10px;
}

.pricesContainerExceed > :nth-child(2) {
  gap: 37px;
}

.pricesContainerExceed > :nth-child(3) {
  gap: 37px;
}

.price-description {
  justify-self: end; /* Aligns this item at the start of the grid area */
}

.price-sale {
  padding: 4px 6px;
  border-radius: 8px;
  background-color: var(--main-color);
  color: white;
}

.screen--product--full-screen {
  left: 0 !important;
}
</style>
