<template>
  <div id="screen-brands" class="screen screen--brands" style="opacity: 0">
    <div v-if="isGeneratingIndex == true" class="message-generating">
      Index is being generated, please wait.
    </div>

    <div
      class="brands"
      v-if="isGeneratingIndex == false"
      v-show="isBrandsListSelected"
    >
      <div v-on:scroll="checkLetter" class="brands__scroller">
        <div
          v-if="featuredBrands.length > 0"
          class="brands__group brands__group--featured"
        >
          <h2 class="brands__title">
            <div class="brands__title__text">
              Featured brands
            </div>
            <div class="brands__title__line"></div>
          </h2>

          <ul class="brands__list">
            <li
              v-for="brand in featuredBrands"
              v-bind:key="brand.id"
              v-bind:class="{
                'brands__brand--is-active': selectBrandId === brand.id
              }"
              v-on:click="selectBrand(brand)"
              class="brands__brand"
            >
              <img
                v-bind:src="brand.logo.url"
                v-if="brand.logo"
                class="brands__brand__logo"
              />
              <div class="brands__brand__name">
                {{ brand.name }}
              </div>
              <!-- .brands__brand__name -->
            </li>
          </ul>

          <div class="brands__group__separator"></div>
        </div>
        <!-- .brands__featured -->

        <div class="brands__group brands__group--other">
          <h2 class="brands__title">
            <div class="brands__title__text">
              {{ featuredBrands.length > 0 ? 'Other brands' : 'Brands' }}
            </div>
            <div class="brands__title__line"></div>
          </h2>

          <ul class="brands__list">
            <li
              v-for="brand in filteredBrands"
              v-bind:key="brand.id"
              v-bind:class="{
                'brands__brand--is-active': selectBrandId === brand.id
              }"
              v-bind:data-id="brand.id"
              v-bind:data-letter="brand.name.substr(0, 1)"
              v-on:click="selectBrand(brand)"
              class="brands__brand"
            >
              <img
                v-bind:src="brand.logo.url"
                v-if="brand.logo"
                class="brands__brand__logo"
              />
              <div class="brands__brand__name">
                {{ brand.name }}
              </div>
              <!-- .brands__brand__name -->
            </li>
          </ul>
        </div>
        <!-- .brands__other -->
      </div>
      <!-- .brands__scroller -->

      <div v-if="filteredBrands.length > 10" class="brands__navigation">
        <ul class="brands__navigation__letters">
          <li
            v-for="letter in brandsLetters"
            v-bind:key="letter"
            v-on:click="scrollToLetter(letter)"
            v-bind:class="{
              'brands__navigation__letter--is-active': activeLetter === letter
            }"
            class="brands__navigation__letter"
          >
            {{ letter }}
          </li>
        </ul>
      </div>
      <!-- .brands__navigation -->

      <lottie-container
        v-bind:path="'block-default-intro'"
        v-bind:autoplay="false"
        v-bind:loop="false"
        ref="lottieBlockIntro"
      ></lottie-container>
    </div>
    <!-- .brands -->

    <div
      class="brand"
      :class="{ 'brand-full': !isBrandsListSelected }"
      v-if="isGeneratingIndex == false"
      style="opacity: 0;"
    >
      <div class="brand__title" v-if="selectedBrand">
        <img
          v-bind:src="selectedBrand.logo.url"
          v-if="selectedBrand.logo"
          class="brand__title__logo"
        />
        <div class="brand__title__name">
          {{ selectedBrand.name }}
        </div>
        <!-- .brand__title__name -->
      </div>
      <!-- .brand__title -->

      <div
        v-if="selectedBrand && selectedBrand.description"
        v-html="selectedBrand.description.replace(/\n/g, '<br />')"
        class="brand__description"
      ></div>
      <div
        v-if="filterCategoryByBrand.length > 1 && productsContainerHasScroll"
        class="brand-categories-container"
      >
        <div
          v-for="(category, index) in filterCategoryByBrand"
          :key="index"
          :class="{
            'brand-categories-container__selected': isSelected(category)
          }"
          @click="selectCategory(category)"
        >
          <span :class="{ 'selected-text': isSelected(category), 'unselected-text': !isSelected(category) }">{{
            category.toUpperCase()
          }}</span>
        </div>
      </div>
      <!-- .brand__description -->

      <div class="brand__separator"></div>

      <div
        :class="
          filterCategoryByBrand.length > 0
            ? 'brand-category'
            : 'brand__products'
        "
        ref="productsGrid"
      >
        <div
          style="width: 100%; margin-bottom: 40px;"
          v-if="filterCategoryByBrand.length > 0"
          v-for="(products, category) in groupedByCategory"
          :key="category"
          :ref="'category-group-' + category"
        >
          <div class="filters__title">
            <div class="filters__title__text">
              {{ capitalizeFirstLetter(category) }}
            </div>
            <div class="filters__title__line"></div>
          </div>
          <div class="brand-category__products">
            <div v-for="product in products" :key="product.id">
              <product-card
                :product="product"
                :source="'Brands'"
                :layout="'small'"
              ></product-card>
            </div>
          </div>
        </div>
        <product-card
          v-for="product in productPage"
          v-if="!filterCategoryByBrand.length > 0"
          v-bind:key="product.id"
          v-bind:product="product"
          v-bind:source="'Brands'"
          v-bind:layout="'small'"
        >
        </product-card>
        <infinite-loading
          :identifier="selectedBrand != null ? selectedBrand.id : 'generallist'"
          @infinite="loadMore"
        >
          <template slot="spinner">
            <div style="width:100%">
              <TpbSpinner width="10vw" height="10vw" />
            </div>
          </template>
          <template slot="no-more">
            <div></div>
          </template>
          <template slot="no-results">
            <div></div>
          </template>
        </infinite-loading>
      </div>
      <!-- .brand__products -->
    </div>
    <!-- .brand -->
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import ProductCard from '@/components/ProductCard'
import { TweenLite, TimelineLite, Linear, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import HasProductsPaginated from '../mixins/HasProductsPaginated'
import store from '../store/store'

export default {
  name: 'ScreenBrands',
  mixins: [HasProductsPaginated],
  components: {
    LottieContainer,
    ProductCard
  },
  props: ['products', 'brands', 'isGeneratingIndex', 'categories'],
  data() {
    return {
      selectedBrand: null,
      activeLetter: '',
      localProducts: this.products.sort((productA, productB) => {
        if (productA.id < productB.id) {
          return -1
        }
        if (productA.id > productB.id) {
          return 1
        }
        return 0
      }),
      selectedCategory: null,
      productsContainerHasScroll: false,
      isBrandTransition: true,
      selectedCategoryId: null
    }
  },
  watch: {
    '$route.query': {
      handler(newQueryParams, oldQueryParams) {
        if (JSON.stringify(newQueryParams) === JSON.stringify(oldQueryParams)) {
          return
        }

        let newBrand = this.filteredBrands.find(b => b.id === Number(newQueryParams.brand))

        if (newBrand.id !== this.selectBrandId) {
          this.selectBrand(newBrand, true)
          this.scrollToBrand(newBrand.id)

          if (newQueryParams.category && this.selectedCategoryId !== Number(newQueryParams.category)) {
            this.selectedCategoryId = Number(newQueryParams.category)
          }

          return
        }

        if (newQueryParams.category && this.selectedCategoryId !== Number(newQueryParams.category)) {
          this.selectedCategoryId = Number(newQueryParams.category)
          const category = this.categories.find(cat => cat.id === Number(newQueryParams.category))
          this.selectedCategory = category.name
          this.scrollToSelectedCategory()
        }
      }
    },
    products(newVal, oldVal) {
      if (
        this.localProducts.length === 0 ||
        !(
          JSON.stringify(
            oldVal.map(product => product.id).sort((a, b) => a - b)
          ) ===
          JSON.stringify(
            newVal.map(product => product.id).sort((a, b) => a - b)
          )
        )
      ) {
        this.localProducts = newVal.sort((productA, productB) => {
          if (productA.id < productB.id) {
            return -1
          }
          if (productA.id > productB.id) {
            return 1
          }
          return 0
        })
        this.fetchData()
      }
    },
    isGeneratingIndex(newVal, val) {
      this.$nextTick(() => {
        this.fetchData(true)
      })
    },
    groupedByCategory: {
      handler() {
        this.$nextTick(this.checkScroll)
      },
      deep: true
    }
  },
  mounted() {
    this.$nextTick(this.checkScroll)
  },
  computed: {
    selectBrandId() {
      return this.selectedBrand ? this.selectedBrand.id : 0
    },
    brandsLetters() {
      var letters = []

      this.filteredBrands.forEach(brand => {
        var letter = brand.name.substr(0, 1)
        if (!letters.includes(letter)) {
          letters.push(letter)
        }
      })

      return letters
    },
    filteredBrands() {
      if (this.brands !== null) {
        var brands = this.brands

        // Only show brands with products
        brands = brands.filter(function(brand) {
          return brand.hasProducts
        })

        // Sort brands alphabetically
        return brands.sort(function(a, b) {
          return a.name
            .toLowerCase()
            .trim()
            .localeCompare(b.name.toLowerCase().trim())
        })
      } else {
        return this.brands
      }
    },
    featuredBrands() {
      return this.filteredBrands.filter(function(brand) {
        return brand.isFeatured
      })
    },
    otherBrands() {
      return this.filteredBrands.filter(function(brand) {
        return !brand.isFeatured
      })
    },
    filteredProducts() {
      var self = this

      if (self.selectedBrand !== null) {
        // Get products for the selected brand
        var products = this.localProducts.filter(function(product) {
          return (
            product.brand &&
            product.brand.id ===
              (self.selectedBrand ? self.selectedBrand.id : product.brand.id)
          )
        })

        // If option is enabled, put featured products on top
        if (this.$config.SORT_FEATURED.BRANDS === true) {
          return products.sort(function(a, b) {
            if (a.isFeatured && !b.isFeatured) {
              return -1
            } else if (!a.isFeatured && b.isFeatured) {
              return 1
            }

            return 0
          })
        } else {
          return products
        }
      } else {
        let products = this.localProducts
        return products
      }
    },
    sourceCard() {
      return this.$route.params.fromEspotlight ? 'Brand Spotlight' : 'Brands'
    },
    isBrandsListSelected() {
      return (
        this.$route.query['source'] === 'ScreenBrands' ||
        !this.$route.query['brand']
      )
    },
    filterCategoryByBrand() {
      if (!this.selectedBrand) {
        return []
      }

      const filteredProducts = this.products.filter(
        product => product.brand && product.brand.id === this.selectedBrand.id
      )

      if (filteredProducts.length === 0) {
        return []
      }

      const categories = filteredProducts.reduce((acc, product) => {
        if (product.catalog_category && product.catalog_category.name) {
          if (Array.isArray(product.catalog_category.name)) {
            acc.push(...product.catalog_category.name)
          } else {
            acc.push(product.catalog_category.name)
          }
        }
        return acc
      }, [])

      const uniqueCategories = [...new Set(categories)].sort((a, b) =>
        a.localeCompare(b)
      )

      return uniqueCategories
    },
    groupedByCategory() {
      const grouped = this.filteredProducts.reduce((acc, product) => {
        const categoryName = product.catalog_category.name
        if (!acc[categoryName]) {
          acc[categoryName] = []
        }
        acc[categoryName].push(product)
        return acc
      }, {})

      // Convert the grouped object into an array of entries, sort them, and convert back to an object
      const sortedGrouped = Object.entries(grouped)
        .sort((a, b) => a[0].localeCompare(b[0]))
        .reduce((acc, [key, value]) => {
          acc[key] = value
          return acc
        }, {})

      return sortedGrouped
    }
  },
  created: function() {
    // Validate the routes for the scroll transition
    this.$router.afterEach((to, from) => {
      if (
        from.path.split('/')[1] !== 'product' &&
        to.path.split('/')[1] === 'brands'
      ) {
        store.commit('setSelectedNavigationBrand', true)
      } else {
        store.commit('setSelectedNavigationBrand', false)
      }
    })
    this.fetchData(true)

    // Events
    this.$on('transition-leave', this.onTransitionLeave)

    // Set product page to 1
    // this.setCurrentPage(1)
  },
  beforeDestroy() {
    if (this.$refs.productsGrid) {
      localStorage.setItem('brandsOffset', this.$refs.productsGrid.scrollTop)
    }
  },
  destroyed: function() {
    // Events
    this.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    productOffset: {
      get: () => {
        return localStorage.getItem('brandsOffset')
      },
      set: val => {
        return localStorage.setItem('brandsOffset', val)
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
      container.find('.brands__scroller').css({ overflow: 'hidden' })

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.call(
        function() {
          if (self.$refs.lottieBlockIntro) {
            self.$refs.lottieBlockIntro.animation.play()
          }
        },
        null,
        null,
        0
      )

      tl.from(
        container.find('.brands__group__separator'),
        0.7,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power2.easeInOut
        },
        0.1
      )

      tl.staggerFrom(
        container.find('.brands__navigation__letter'),
        0.6,
        {
          alpha: 0,
          x: 10,
          clearProps: 'opacity, transform',
          ease: Power3.easeOut
        },
        0.05,
        0
      )

      container.find('.brands__group').each(function(index) {
        var group = $(this)
        var start = 0.5 + 0.3 * index

        tl.from(
          group.find('.brands__title__text'),
          0.5,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          start
        )

        tl.from(
          group.find('.brands__title__line'),
          0.5,
          {
            scaleX: 0,
            clearProps: 'transform',
            ease: Power3.easeInOut
          },
          start
        )

        tl.staggerFrom(
          group.find('.brands__brand').slice(0, 8),
          0.6,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          start
        )

        group = null
      })

      tl.call(
        function() {
          if (self.selectedBrand && self.selectBrand !== null && self.isBrandTransition) {
            self.scrollToBrand(self.selectedBrand.id)
          }

          self.brandTransitionEnter(() => self.scrollToSelectedCategory())
        },
        null,
        null,
        0.4
      )

      tl.call(function() {
        self.$root.$emit('block-pointer', false)
      })

      tl.call(
        function() {
          if (container) {
            container.find('.brands__scroller').css({ overflow: '' })
          }
        },
        null,
        null,
        0.6
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
      var self = this
      var container = $(this.$el)
      var animation = self.$refs.lottieBlockIntro.animation.play()

      // Before animation
      container.find('.brands__scroller').css({ overflow: 'hidden' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.call(function() {
        self.brandTransitionLeave(false)
      })

      tl.to(
        container.find('.brands__group__separator'),
        0.7,
        {
          scaleX: 0,
          ease: Power2.easeInOut
        },
        0
      )

      tl.to(
        container.find('.brands__navigation__letter'),
        0.6,
        {
          alpha: 0
        },
        0
      )

      container.find('.brands__group').each(function(index) {
        var group = $(this)
        var start = 0.1 * index

        tl.to(
          group.find('.brands__title__text'),
          0.5,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeOut
          },
          start
        )

        tl.to(
          group.find('.brands__title__line'),
          0.5,
          {
            scaleX: 0,
            ease: Power3.easeInOut
          },
          start
        )

        tl.to(
          group.find('.brands__list'),
          0.6,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeOut
          },
          start
        )

        group = null
      })

      tl.call(
        function() {
          if (animation) {
            animation.setDirection(-1)
            animation.play()

            animation = null
          }
        },
        null,
        null,
        0.2
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

    /**
     * Brand transition enter
     */
    brandTransitionEnter: function(done) {
      // Selectors
      var container = $(this.$el)
      if (!container) {
        if (done !== false) {
          done()
        }
        return
      }

      var brand = container.find('.brand')

      // Before animation
      brand.css({ opacity: '' })
      brand.find('> *').css({ opacity: '' })
      // if there is an brand scroll position already stored , scroll to
      if (this.$refs.productsGrid) {
        const selectedNavigationBrand = store.state.selectedNavigationBrand
        const toScroll = selectedNavigationBrand
          ? 0
          : localStorage.getItem('brandsOffset')
        brand.find('.brand__products').scrollTop(toScroll)
        // this.$refs.productsGrid.scrollTo(0, toScroll)
      }

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        brand.find('.brand__title, .brand__description'),
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
        brand.find('.brand__separator'),
        0.7,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power3.easeInOut
        },
        0.1
      )

      tl.staggerFrom(
        brand.find('.product-image').slice(0, 10),
        0.7,
        {
          alpha: 0,
          x: -20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.1,
        0.3
      )

      tl.staggerFrom(
        brand.find('.product-card__info').slice(0, 10),
        0.5,
        {
          alpha: 0,
          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        0.1,
        0.35
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null
        brand = null

        if (done !== false) {
          done()
        }
      })

      tl.play()
    },

    /**
     * Brand transition leave
     */
    brandTransitionLeave: function(done) {
      // Selectors
      var container = $(this.$el)
      if (!container) {
        if (done !== false) {
          done()
        }
        return
      }

      var brand = container.find('.brand')
      brand.data('wait', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerTo(
        brand.find('> *').reverse(),
        0.5,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform',
          ease: Power3.easeIn
        },
        0.05,
        0
      )

      tl.call(function() {
        brand.data('wait', false)

        tl.kill()

        tl = null
        container = null
        brand = null

        if (done !== false) {
          done()
        }
      })

      tl.play()
    },

    /**
     * Check active letter
     */
    checkLetter: function() {
      // Selectors
      var container = $(this.$el)
      var brands = container.find('.brands__brand')
      var topBrand = null

      brands.each(function(index) {
        var brand = $(this)

        if (brand.offset().top > -40) {
          topBrand = brand
          return false
        }

        brand = null
      })

      if (topBrand) {
        this.activeLetter = topBrand.attr('data-letter')
      }

      container = null
      brands = null
      topBrand = null
    },

    /**
     * Fetch data
     */
    fetchData: function(doTransition = false) {
      var self = this

      if (self.isGeneratingIndex) {
        return false
      }

      if (!self.brands) {
        this.brands.forEach(function(brand) {
          // Ignore brands with not product
          if (brand.total_products === 0) {
            brand.hasProducts = false
            return
          } else {
            brand.hasProducts = true
          }

          // Get products from this brand
          var products = self.products.filter(function(product) {
            return product.brand && product.brand.id === brand.id
          })

          // Check if brand has some featured products
          brand.isFeatured = products.some(function(product) {
            return product.isFeatured
          })
        })
      }

      if (self.$route.query.brand) {
        this.selectedBrand = this.getBrand(Number(this.$route.query.brand))
      } else {
        this.selectedBrand = null
      }

      if (self.$route.query.category) {
        const productByBrandAndCategory = this.getCategoryByBrand(
          Number(this.$route.query.category)
        )
        this.selectCategory(productByBrandAndCategory[0].catalog_category.name)
      } else {
        this.selectedCategory = null
      }

      // Set default brand to the first one
      if (this.featuredBrands.length > 0) {
        if (!self.$route.query.brand) {
          this.selectedBrand = this.featuredBrands[0]
          this.isBrandTransition = false
        }
      } else {
        // Set default brand to the first one
        if ((this.filteredBrands.length > 0 && !self.$route.query.brand) && !self.$route.query.category) {
          this.selectedBrand = this.filteredBrands[0]
        }
      }

      // if (self.$gsClient && self.selectedBrand) {
      //   self.$gsClient.track('Brand', {
      //     event_category: 'Selection',
      //     brand_name: self.selectedBrand.name,
      //     total_products: self.selectedBrand.total_products,
      //     id: self.selectedBrand.id
      //   })
      //   this.selectedBrand = this.filteredBrands[0]
      // }

      if (self.$gsClient && self.selectedBrand) {
        if (this.$route.params.fromEspotlight) {
          self.$gsClient.track('Brand from Spotlight', {
            event_category: 'Selection',
            brand_name: self.selectedBrand.name,
            total_products: self.selectedBrand.total_products,
            id: self.selectedBrand.id
          })
        }
        self.$gsClient.track('Brand', {
          event_category: 'Selection',
          brand_name: self.selectedBrand.name,
          total_products: self.selectedBrand.total_products,
          id: self.selectedBrand.id
        })
      }

      // Fetch is done, call transition on next tick
      if (doTransition) {
        this.$nextTick(this.transitionEnter)
      }
    },

    /**
     * Get brand per id
     * @param {Integer} brandId Brand ID
     */
    getBrand: function(brandId) {
      return this.filteredBrands.find(function(brand) {
        return brand.id === brandId
      })
    },

    /**
     * Get category per id
     * @param {Integer} categoryId Category ID
     */
    getCategoryByBrand: function(categoryId) {
      return this.products.filter(product => {
        return (
          product.catalog_category && product.catalog_category.id === categoryId && product.brand &&
          this.selectedBrand.id === product.brand.id
        )
      })
    },

    /**
     * Select brand
     * @param  {Object} brand
     */
    selectBrand: function(brand, isTriggerFromUri = false) {
      var self = this
      self.setCurrentPage(1)
      // Wait between transitions
      if (
        $(this.$el)
          .find('.brand')
          .data('wait') === true
      ) {
        return
      }

      // Call brand transition leave with a callback
      this.brandTransitionLeave(function() {
        // Select brand then call transition on next tick
        self.selectedBrand = brand
        if (self.$gsClient && self.selectedBrand) {
          self.$gsClient.track('Brand', {
            event_category: 'Selection',
            brand_name: self.selectedBrand.name,
            total_products: self.selectedBrand.total_products,
            id: self.selectedBrand.id
          })
        }

        if (!isTriggerFromUri) {
          self.resetSelectedCategory()
        }

        self.updateRoute()

        self.$nextTick(function() {
          self.brandTransitionEnter(
            () => self.scrollToSelectedCategory()
          )
        })
      })
    },

    /**
     * Scroll to brand
     */
    scrollToBrand: function(id) {
      // Selectors
      var container = $(this.$el)
      if (id === null) {
        return
      }
      var brand = container.find('.brands__brand[data-id="' + id + '"]').first()
      var scroller = container.find('.brands__scroller')

      var maxScroll = scroller[0].scrollHeight - $(window).height()
      if (scroller && brand.position()) {
        var scroll = brand.position().top - 40 + scroller.scrollTop()
        scroll = Math.min(scroll, maxScroll)
      } else {
        scroll = 0
      }

      if (brand.length === 1) {
        // Animation
        TweenLite.to(scroller, 0.8, {
          scrollTo: scroll,
          ease: Power3.easeInOut
        })
      }

      container = null
      brand = null
      scroller = null
    },

    /**
     * Scroll to letter
     */
    scrollToLetter: function(letter) {
      // Selectors
      var container = $(this.$el)
      var brand = container
        .find('.brands__brand[data-letter="' + letter + '"]')
        .first()
      var scroller = container.find('.brands__scroller')

      var maxScroll = scroller[0].scrollHeight - $(window).height()
      var scroll = brand.position().top - 40 + scroller.scrollTop()
      scroll = Math.min(scroll, maxScroll)

      if (brand.length === 1) {
        brand.trigger('click')

        // Animation
        TweenLite.to(scroller, 0.8, {
          scrollTo: scroll,
          ease: Power3.easeInOut
        })
      }

      container = null
      brand = null
      scroller = null
    },

    /**
     * Update route with params
     */
    updateRoute: function() {
      var params = {}

      if (this.selectedBrand) {
        params.brand = this.selectedBrand.id
        params.source = 'ScreenBrands'
      }

      if (this.selectedCategoryId) {
        let newCategory = this.categories.find(a => a.id === this.selectedCategoryId)

        if (newCategory) {
          this.selectedCategory = newCategory.name
          this.selectedCategoryId = newCategory.id
          params.category = newCategory.id
        }
      }

      this.$router.replace({ query: params })
        .catch(err => {
          if (err.name !== 'NavigationDuplicated') {
            console.log(err) // Handle other errors if necessary
          }
        })
    },
    selectCategory(category) {
      this.selectedCategory = category
      const categorySelected = this.categories.find(a => a.name === category)

      this.$router.replace({ query: { ...this.$route.query, category: categorySelected.id } })
        .catch(err => {
          if (err.name !== 'NavigationDuplicated') {
            console.log(err) // Handle other errors if necessary
          }
        })

      this.scrollToSelectedCategory()
    },
    isSelected(category) {
      return this.selectedCategory === category
    },
    resetSelectedCategory() {
      this.selectedCategory = null
      this.selectedCategoryId = null
    },
    scrollToSelectedCategory() {
      this.$nextTick(() => {
        const container = $(this.$el)
        const selectedElement = this.$refs[`category-group-${this.selectedCategory}`][0]
        if (selectedElement) {
          const selectedElementRect = selectedElement.getBoundingClientRect()

          const scroller = container.find('.brand-category')[0]
          const containerRect = scroller.getBoundingClientRect()
          const targetY = selectedElementRect.top - containerRect.top + scroller.scrollTop - 40

          TweenLite.to(scroller, 0.8, {
            scrollTo: { y: targetY, autoKill: false },
            ease: Power3.easeInOut
          })
        }
      })
    },
    capitalizeFirstLetter(string) {
      if (!string) return ''
      return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()
    },
    checkScroll() {
      this.productsContainerHasScroll = false
      const container = this.$refs.productsGrid
      if (container && container.scrollHeight > container.clientHeight) {
        this.productsContainerHasScroll = true
      } else {
        this.productsContainerHasScroll = false
      }
    }
  }
}
</script>

<style scoped lang="scss">
.brands {
  position: absolute;
  top: 0;
  left: 0;
  width: 360px;
  height: 100%;

  &__scroller {
    padding: 50px;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    overflow-x: hidden;
    overflow-y: scroll;
    z-index: 2;
  }

  &__navigation {
    position: absolute;
    top: 10px;
    bottom: 10px;
    left: calc(100% + 10px);

    flex-grow: 0;
    flex-shrink: 0;
    z-index: 2;

    &__letters {
      display: flex;
      margin: 0;
      padding: 0;
      height: 100%;

      flex-direction: column;
      justify-content: flex-start;
      list-style-type: none;
    }

    &__letter {
      display: flex;
      margin: 0.77em 0 0;
      padding: 0;
      width: 3.38em;
      height: 100%;

      align-items: center;
      background: rgba($white, 0.1);
      border-radius: 5px;
      flex-grow: 1;
      flex-shrink: 1;
      justify-content: center;
      transition: color 0.2s ease;

      color: rgba($white, 0.35);
      font: 0.65em/1 var(--font-semibold);
      letter-spacing: 0.1em;
      text-align: center;
      text-transform: uppercase;

      &:first-child {
        margin-top: 0;
      }

      &--is-active {
        color: $white;
      }
    }

    &__arrow {
      display: inline-block;
      position: relative;
      width: 1px;
      height: 10px;

      background: $white;
      opacity: 0.35;

      &:before,
      &:after {
        display: block;
        position: absolute;
        bottom: 0;
        left: 0;
        width: 1px;
        height: 5px;

        background: $white;
        content: '';
        transform-origin: 50% 100%;
      }

      &:before {
        transform: rotateZ(-35deg);
      }

      &:after {
        transform: rotateZ(35deg);
      }

      &--up {
        transform: rotateZ(180deg);
      }
    }
  }

  .lottie-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    z-index: 1;
  }

  /deep/ .lottie-container {
    path {
      fill: rgba($black, 0.3);
    }
  }

  &__group {
    width: 260px;

    &__separator {
      margin: 60px -20px 40px;
      display: block;
      height: 1px;

      background-color: rgba($white, 0.1);
      transform-origin: 0 0;
    }

    &:first-child {
      .brands__title:before {
        display: none;
      }
    }
  }

  &__title {
    display: block;
    padding: 0 0 10px;
    margin: 0 0 35px;
    position: relative;

    font: 0.8em/1 var(--font-bold);
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

  &__list {
    margin: 0;
    padding: 0;

    list-style: none;
  }

  &__brand {
    display: flex;
    padding: 0 20px;
    width: 260px;
    height: 140px;

    align-items: center;
    background: transparent;
    border-radius: 30px;
    flex-direction: column;
    justify-content: center;
    opacity: 0.5;

    font: 0.7em/1 var(--font-semibold);
    letter-spacing: 0.1em;
    line-height: 1.4;
    text-align: center;
    text-transform: uppercase;

    &__logo {
      display: block;
      width: calc(100% - 40px);
      height: calc(100% - 40px);

      object-fit: contain;

      & + .brands__brand__name {
        display: none;
      }
    }

    &--is-active {
      background: rgba($white, 0.05);
      opacity: 1;
    }
  }
}

.brand {
  display: flex;
  position: absolute;
  top: 80px;
  right: 120px;
  bottom: 0;
  left: 515px;

  align-items: flex-start;
  flex-direction: column;
  justify-content: stretch;

  &__title {
    margin: 0 0 25px;

    font: 2.9em/1.2 var(--font-extralight);
    text-indent: -0.05em;

    &__logo {
      display: block;
      max-width: 300px;
      max-height: 150px;

      object-fit: contain;

      & + .brand__title__name {
        display: none;
      }
    }
  }

  &__description {
    padding: 0 0 45px;
  }

  &__separator {
    display: block;
    width: 100%;
    height: 1px;

    background-color: rgba($white, 0.1);
    flex-grow: 0;
    flex-shrink: 0;
  }

  &__products {
    display: flex;
    margin: 0 0 0 -30px;
    padding: 45px 30px 30px 30px;
    width: calc(100% + 60px);

    align-content: flex-start;
    align-items: flex-start;
    flex-direction: row;
    flex-grow: 1;
    flex-shrink: 1;
    flex-wrap: wrap;
    justify-content: space-between;
    overflow-x: hidden;
    overflow-y: scroll;

    >>> .product-card {
      margin: 85px 0 0;
      width: calc(50% - 25px);

      &:nth-child(-n + 2) {
        margin-top: 0;
      }

      &:last-child {
        margin-bottom: 45px;
      }
    }
  }

  /deep/ .product-card {
    &__inner {
      display: flex;
      align-items: center;
    }

    &__attributes {
      .span {
        text-align: left;
      }
    }

    .promotion {
      min-width: 80px;
      min-height: 80px;

      .text {
        font-size: 14px;
      }

      .min-sm-text {
        font-size: 10px;
      }
    }
  }
}

.brand-category {
  display: flex;
  margin: 0 0 0 -30px;
  padding: 35px 30px 30px 30px;
  width: calc(100% + 60px);

  align-content: flex-start;
  align-items: flex-start;
  flex-direction: column;
  flex-grow: 1;
  flex-shrink: 1;
  overflow-x: hidden;
  overflow-y: scroll;

  >>> .product-card {
    margin: 85px 0 0;
    width: calc(50% - 25px);

    &:nth-child(-n + 2) {
      margin-top: 0;
    }

    &:last-child {
      margin-bottom: 45px;
    }
  }

  &__products {
    display: grid;
    margin: 0 0 0 -30px;
    padding: 35px 30px 30px 30px;
    width: calc(100% + 60px);
    grid-template-columns: repeat(2, 1fr);
    gap: 30px;

    .product-card {
      margin: 0 1rem 1rem 0;
    }
  }
}

.brand-full {
  left: 120px;
}

.infinite-loading-container {
  width: 100%;
  padding: 1rem;
}

.brand-categories-container {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  gap: 1rem;
  font-family: Arial, sans-serif;
}

.brand-categories-container div {
  background-color: rgba(255, 255, 255, 0.123);
  border-radius: 1rem;
  color: white;
  margin-right: 1rem;
  margin-bottom: 1rem;
  padding: 0.5rem 1rem;
  cursor: pointer;
}

.brand-categories-container div.brand-categories-container__selected {
  background-color: var(--main-color);
  color: white;
  border-radius: 1rem;
  margin-right: 1rem;
  padding: 0.5rem 1rem;
}

.selected-text {
  font-weight: bold;
}

.unselected-text {
  opacity: 0.4;
}

.filters {
  position: relative;
  width: 440px;
  height: 100%;

  flex-grow: 0;
  flex-shrink: 0;
  overflow: hidden;
  transition: width 0.5s cubic-bezier(0.77, 0, 0.175, 1);

  &__title {
    display: block;
    padding: 0 0 0px 0;
    margin: 0 0 0 0px;
    position: relative;

    font: 16px/1 var(--font-bold);
    letter-spacing: 0.1em;

    &__line {
      display: block;
      position: absolute;
      bottom: 0;
      left: 0;
      width: 25px;
      height: 5px;
      margin-left: 3px;

      background: var(--main-color);
      transform-origin: 0 0;
    }

    &__text {
      display: block;
      padding: 0 0 8px 0;
      margin: 0 0 0 0px;
      position: relative;

      font: 43px/1 var(--font-extralight);
      letter-spacing: 2px;
    }
  }
}
</style>
