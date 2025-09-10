<template>
  <div id="screen-products" class="screen screen--products" style="opacity: 0">
    <div v-if="isGeneratingIndex" class="message-generating">
      Index is being generated, please wait.
    </div>

    <div
      class="single-col-search"
      :class="{
        'single-col-search-collapsed': $config.PRODUCT_UI !== 'condensed'
      }"
      v-if="
        !isGeneratingIndex &&
          ($config.PRODUCT_UI == 'condensed' ||
            (columnFiltersStyle === 'collapsed' && !isShopify))
      "
    >
      <form action="" v-on:submit.stop.prevent="searchProducts">
        <input
          v-model="searchValue"
          placeholder="Brand or product name..."
          class="input"
        />

        <button class="show-button">
          <img src="../assets/img/icon-search.svg" alt="Search" />
        </button>
      </form>
    </div>
    <div
      v-if="!isGeneratingIndex"
      v-bind:class="[
        'filters--' + columnFiltersStyle,
        $config.PRODUCT_UI == 'condensed'
          ? 'filters--single-col'
          : isShopify
          ? 'shopify-hidden'
          : ''
      ]"
      class="filters"
    >
      <div
        class="filters__search"
        v-bind:class="isShopify ? 'shopify-search' : ''"
        v-if="$config.PRODUCT_UI !== 'condensed'"
      >
        <form v-on:submit.stop.prevent="searchProducts" class="search-form">
          <input
            v-model="searchValue"
            placeholder="Brand or product name..."
            class="input-osk"
          />

          <button type="submit" class="search-form__button">
            <span class="search-form__button__text">
              <img src="../assets/img/icon-search.svg" alt="Search" /> </span
            ><!-- .search-form__button__text -->
            <span class="search-form__button__background"></span>
          </button>
        </form>
      </div>
      <!-- .flters__search -->

      <div class="filters__scroller">
        <transition
          v-on:enter="onToggleTransitionEnter"
          v-on:leave="onToggleTransitionLeave"
          v-bind:css="false"
          mode="out-in"
        >
          <router-link
            v-if="false"
            :to="{ name: 'products', query: { only_on_sale: !onlyOnSale } }"
          >
            <div class="on-sale-toggle">
              <div class="toggle-rail">
                <div
                  class="toggle"
                  :class="{ active: onlyOnSale == true }"
                ></div>
              </div>
              <div class="toggle-tag">
                Show On Sale products
              </div>
            </div>
          </router-link>
        </transition>

        <transition
          v-on:enter="onCategoriesTransitionEnter"
          v-on:leave="onCategoriesTransitionLeave"
          v-bind:css="false"
          mode="out-in"
        >
          <div
            v-if="!hideCategories && categories"
            v-bind:class="{
              'filters__group--is-opened': filtersCategoriesOpen,
              'is-only-filter': noCategories
            }"
            class="filters__group filters__group--icon"
          >
            <div class="filters__inner">
              <div class="filters__title">
                <div class="filters__title__text">
                  Categories
                </div>
                <div class="filters__title__line"></div>
              </div>
              <!-- .filters__title -->

              <ul class="filters__list filters__list--categories">
                <li
                  v-for="category in orderedCategories"
                  v-bind:key="category.id"
                  v-on:click="selectCategory(category.id)"
                  v-bind:class="{
                    'filters__item--is-active': category.id === filterCategory
                  }"
                  class="filters__item filters__item--icon"
                >
                  <div
                    style="display: flex; flex-direction: column; justify-content: center; align-items: center;"
                  >
                    <img
                      :src="
                        icon(
                          $config.SHOW_ALTERNATIVE_FLOWER_ICON &&
                            category.name.toLowerCase() === 'flower'
                            ? 'alternativeflower'
                            : category.name
                        )
                      "
                      class="filters__item__icon"
                    />
                    <span class="filters__item__label">
                      {{ category.name }}
                    </span>

                    <span class="filters__item__background"></span>
                  </div>
                </li>
              </ul>

              <div
                v-if="categories.length > 4 && !noCategories"
                v-on:click="toggleFiltersCategories"
                v-bind:class="{
                  'filters__toggle--is-opened': filtersCategoriesOpen
                }"
                class="filters__toggle"
              >
                <span class="filters__toggle__text">
                  {{ filtersCategoriesOpen ? 'Less' : 'More' }}
                </span>

                <span class="filters__toggle__arrow"></span>
              </div>

              <div
                class="filters__separator"
                v-if="filteredTags && filteredTags.length > 0"
              ></div>
            </div>
            <!-- .filters__inner -->
          </div>
          <!-- .filters__group -->
        </transition>

        <div
          v-if="filteredTags && filteredTags.length > 0"
          v-bind:class="{
            'filters__group--is-opened': true /*filtersTagsOpen*/
          }"
          class="filters__group filters__group--text"
        >
          <div class="filters__inner" :class="isShopify && 'hidden'">
            <div class="filters__title">
              <div class="filters__title__text">
                Tags
              </div>
              <div class="filters__title__line"></div>
            </div>
            <!-- .filters__title -->

            <ul class="filters__list filters__list--tag">
              <li
                v-for="(tag, index) in filteredTags"
                v-bind:key="index"
                v-on:click="selectTag(tag)"
                v-bind:class="{
                  'filters__item--is-active': filterTags.includes(tag)
                }"
                class="filters__item filters__item--text filters__item--tag"
              >
                <span class="filters__item__label">
                  {{ tag }}
                </span>
                <span class="filters__item__background"></span>
              </li>
            </ul>

            <!-- <div
              v-on:click="filtersTagsOpen = !filtersTagsOpen"
              v-bind:class="{ 'filters__toggle--is-opened': filtersTagsOpen }"
              class="filters__toggle">
              <span class="filters__toggle__text">
                {{ filtersTagsOpen ? 'Less' : 'More' }}
              </span>

              <span class="filters__toggle__arrow"></span>
            </div> -->
          </div>
          <!-- .filters__inner -->
        </div>
        <!-- .filters__group -->
      </div>
      <!-- .filters__scroller -->

      <lottie-container
        v-bind:path="'block-default-intro'"
        v-bind:autoplay="false"
        v-bind:loop="false"
        ref="lottieBlockIntro"
      ></lottie-container>
    </div>
    <!-- .filters -->

    <div v-if="!isGeneratingIndex" class="sorts">
      <div class="center-tags">
        <div
          v-on:click="sortBy('name')"
          v-bind:class="{ 'sorts__item--is-active': sortOption === 'name' }"
          class="sorts__item sorts__item--az"
        >
          A-Z
        </div>
      </div>
      <div class="center-tags separate">
        <div
          v-on:click="sortBy('price-desc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'price-desc'
          }"
          class="sorts__item sorts__item--price-desc separate center-tags"
        >
          $ <span class="sorts__arrow sorts__arrow--down"></span>
        </div>

        <div
          v-on:click="sortBy('price-asc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'price-asc'
          }"
          class="sorts__item sorts__item--price-asc center-tags"
        >
          $ <span class="sorts__arrow sorts__arrow--up"></span>
        </div>
      </div>
      <div
        v-show="
          filteredProductsThatIncludeThcPercentage.length > 0 ||
            filteredProductsThatIncludeThcMg.length > 0
        "
        class="sorts__tags containerSortButtons separate-container"
      >
        <p class="sorts__tags tagsTitle">THC</p>
        <div
          v-show="filteredProductsThatIncludeThcPercentage.length > 0"
          v-on:click="sortBy('percentage-desc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'percentage-desc'
          }"
          class="sorts__item sorts__item--price-desc"
        >
          % <span class="sorts__arrow sorts__arrow--down"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeThcPercentage.length > 1"
          v-on:click="sortBy('percentage-asc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'percentage-asc'
          }"
          class="sorts__item sorts__item--price-asc"
        >
          % <span class="sorts__arrow sorts__arrow--up"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeThcMg.length > 0"
          v-on:click="sortBy('mg-desc')"
          v-bind:class="{ 'sorts__item--is-active': sortOption === 'mg-desc' }"
          class="sorts__item sorts__item--price-desc separate"
        >
          MG <span class="sorts__arrow sorts__arrow--down"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeThcMg.length > 1"
          v-on:click="sortBy('mg-asc')"
          v-bind:class="{ 'sorts__item--is-active': sortOption === 'mg-asc' }"
          class="sorts__item sorts__item--price-asc"
        >
          MG <span class="sorts__arrow sorts__arrow--up"></span>
        </div>
      </div>

      <div
        v-show="
          filteredProductsThatIncludeCbdPercentage.length > 0 ||
            filteredProductsThatIncludeCbdMg.length > 0
        "
        class="sorts__tags containerSortButtons separate-container"
      >
        <p class="sorts__tags tagsTitle">CBD</p>
        <div
          v-show="filteredProductsThatIncludeCbdPercentage.length > 0"
          v-on:click="sortBy('percentage-cbd-desc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'percentage-cbd-desc'
          }"
          class="sorts__item sorts__item--price-desc"
        >
          % <span class="sorts__arrow sorts__arrow--down"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeCbdPercentage.length > 1"
          v-on:click="sortBy('percentage-cbd-asc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'percentage-cbd-asc'
          }"
          class="sorts__item sorts__item--price-asc"
        >
          % <span class="sorts__arrow sorts__arrow--up"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeCbdMg.length > 0"
          v-on:click="sortBy('mg-cbd-desc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'mg-cbd-desc'
          }"
          class="sorts__item sorts__item--price-desc separate"
        >
          MG <span class="sorts__arrow sorts__arrow--down"></span>
        </div>

        <div
          v-show="filteredProductsThatIncludeCbdMg.length > 1"
          v-on:click="sortBy('mg-cbd-asc')"
          v-bind:class="{
            'sorts__item--is-active': sortOption === 'mg-cbd-asc'
          }"
          class="sorts__item sorts__item--price-asc"
        >
          MG <span class="sorts__arrow sorts__arrow--up"></span>
        </div>
      </div>
    </div>
    <!-- .sorts -->

    <div
      v-if="!isGeneratingIndex"
      ref="productsGrid"
      class="products-grid"
      :class="{ 'grid-of-four': $config.PRODUCT_UI == 'condensed' }"
    >
      <div
        v-if="selectedCategory && selectedCategory.banner"
        class="header-container"
      >
        <div class="grid-header">
          <img
            v-bind:src="selectedCategory.banner.url"
            class="grid-header__image"
          />
        </div>
        <!-- .grid-header -->
      </div>

      <div class="products">
        <product-card
          v-for="(product, index) in productPage"
          v-bind:key="product.id"
          v-bind:product="product"
          v-bind:data-index="index"
          v-bind:source="sourceCard"
          v-bind:layout="'large'"
        >
        </product-card>

        <infinite-loading @infinite="loadMore">
          <template slot="spinner">
            <TpbSpinner width="10vw" height="10vw" />
          </template>
          <template slot="no-more">
            <div></div>
          </template>
          <template slot="no-results">
            <div></div>
          </template>
        </infinite-loading>
      </div>
      <!-- .products -->

      <div v-if="filteredProducts.length === 0" class="no-results">
        <div
          v-html="
            showEmptyProduct
              ? 'These products are out of stock.'
              : noResultText.text
          "
        ></div>

        <div
          v-if="
            noResultText.category ||
              noResultText.tag ||
              noResultText.showEmptyProduct
          "
        >
          Would you like to try

          <button
            v-if="noResultText.otherCategory"
            v-on:click="redirectToCategory(noResultText.otherCategory.id)"
            class="no-results__button"
          >
            {{ noResultText.otherCategory.name }}
          </button>

          <button
            v-if="!noResultText.otherCategory"
            v-on:click="selectTag(noResultText.tag, true)"
            class="no-results__button"
          >
            {{ noResultText.tag }}
          </button>

          products instead?
        </div>
      </div>
      <!-- no-results -->
    </div>
    <!-- .products-grid -->
  </div>
</template>

<script>
import StringSimilarity from 'string-similarity'
import LottieContainer from '@/components/LottieContainer'
import ProductCard from '@/components/ProductCard'
import { TweenMax, TimelineLite, Linear, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import HasProductsPaginated from '../mixins/HasProductsPaginated'
import { GSAP_ANIMATION } from '../const/globals'
import { PRODUCTS_PAGE_SIZE, CATEGORIES_WITH_PRIORITY } from '@/const/globals'
import store from '../store/store'

export default {
  name: 'ScreenProductsPromotions',
  mixins: [HasProductsPaginated],
  components: {
    LottieContainer,
    ProductCard
  },
  props: [
    'categories',
    'isGeneratingIndex',
    'products',
    'tags',
    'tagsPerCategories'
  ],
  data() {
    return {
      new: true,
      columnFiltersStyle: 'collapsed',
      filterCategory: null,
      filterCategoryName: null,
      filtersCategoriesOpen: false,
      filterTags: [],
      filterPromotion: null,
      filtersTagsOpen: false,
      hideCategories: true,
      onlyOnSale: false,
      searchString: '',
      searchValue: '',
      sortOption: null,
      showEmptyProduct: false,
      loading: false,
      isShopify: false,
      layoutUpdated: false
    }
  },
  computed: {
    noCategories() {
      return this.filteredTags && this.filteredTags.length === 0
    },
    // returns categories with custom order
    categoriesWithOrder() {
      return this.categories
        .filter(a => a.order != null)
        .sort((a, b) => (b.order < a.order ? 1 : -1))
    },
    // returns the categories that either have  category nor piority
    categoriesWithNoOrder() {
      return this.categories
        .filter(a => a.order == null && !this.getCategoryByName(a.name))
        .sort((a, b) => (a.name > b.name ? 1 : -1))
    },
    // returns categories with priority but no customr order
    categoriesWithPriority() {
      return this.categories
        .filter(
          category =>
            this.getCategoryByName(category.name) && category.order == null
        )
        .sort((a, b) =>
          this.getCategoryByName(b.name).order <
          this.getCategoryByName(a.name).order
            ? 1
            : -1
        )
    },

    orderedCategories() {
      return [
        ...this.categoriesWithOrder,
        ...this.categoriesWithPriority,
        ...this.categoriesWithNoOrder
      ]
    },

    productsLimit() {
      return PRODUCTS_PAGE_SIZE * this.currentPage
    },
    filteredTags() {
      if (this.filterCategory === null) {
        // No category is set, show all tags
        return this.tags
      } else {
        // Category is set, show tags that belong to this category
        if (this.tagsPerCategories[this.filterCategory]) {
          return this.tagsPerCategories[this.filterCategory]
        } else {
          return []
        }
      }
      /** teste 2 */
    },
    /**
     * Products offset
     */
    productOffset: {
      get: () => {
        return localStorage.getItem('productsOffset')
      },
      set: val => {
        return localStorage.setItem('productsOffset', val)
      }
    },

    /**
     * Products filtered
     */
    filteredProducts() {
      var self = this
      if (this.showEmptyProduct) {
        return []
      }

      console.log('products list', this.products)
      var products = this.products.filter(function(product) {
        // Filter products by category
        var matchCategory =
          self.filterCategory === null ||
          product.catalog_category.id === self.filterCategory

        // Filter products by tag
        var matchTag =
          self.filterTags.length === 0 ||
          self.filterTags.every(function(tag) {
            return product.tag_list.includes(tag)
          })

        var matchPromotion = true

        if (self.filterPromotion) {
          if (product.store_product_promotions.length > 0) {
            matchPromotion =
              product.store_product_promotions[0].id === self.filterPromotion
          } else {
            matchPromotion = false
          }
        }

        return matchCategory && matchTag && matchPromotion
      })

      if (self.onlyOnSale === true) {
        products = products.filter(product => {
          return product.store_product_promotions
            ? product.store_product_promotions.length > 0
            : false
        })
      }

      // Search
      if (self.searchString) {
        products = products.filter(function(product) {
          var match = false
          if (
            product.name
              .toLowerCase()
              .indexOf(self.searchString.toLowerCase()) > -1 ||
            (product.brand !== null &&
              product.brand.name
                .toLowerCase()
                .indexOf(self.searchString.toLowerCase()) > -1)
          ) {
            match = true
          }

          if (!match) {
            var nameSimilarity = StringSimilarity.compareTwoStrings(
              product.name.toLowerCase(),
              self.searchString.toLowerCase()
            )
            if (nameSimilarity > Number(self.$config.SEARCH_SENSIBILITY)) {
              match = true
            }
          }

          if (!match && product.brand !== null) {
            var brandSimilarity = StringSimilarity.compareTwoStrings(
              product.brand ? product.brand.name : ''.toLowerCase(),
              self.searchString.toLowerCase()
            )
            if (brandSimilarity > Number(self.$config.SEARCH_SENSIBILITY)) {
              match = true
            }
          }

          return match
        })
        if (self.$gsClient) {
          self.$gsClient.track(
            'Search Product',
            {
              search_string: self.searchString,
              filter_category: self.filterCategoryName
            },
            { result_count: products.length }
          )
        }
      }

      // Sort products
      if (this.sortOption === 'name') {
        return this.sortName(products)
      }
      if (this.sortOption === 'price-asc') {
        return this.priceAsc(products)
      }
      if (this.sortOption === 'price-desc') {
        return this.priceDesc(products)
      }
      if (this.sortOption === 'percentage-desc') {
        return this.percentageDesc(products)
      }
      if (this.sortOption === 'percentage-asc') {
        return this.percentageAsc(products)
      }
      if (this.sortOption === 'mg-desc') {
        return this.mgDesc(products)
      }
      if (this.sortOption === 'mg-asc') {
        return this.mgAsc(products)
      }
      if (this.sortOption === 'percentage-cbd-desc') {
        return this.percentageCbdDesc(products)
      }
      if (this.sortOption === 'percentage-cbd-asc') {
        return this.percentageCbdAsc(products)
      }
      if (this.sortOption === 'mg-cbd-desc') {
        return this.mgCbdDesc(products)
      }
      if (this.sortOption === 'mg-cbd-asc') {
        return this.mgCbdAsc(products)
      }
      if (this.$config.SORT_FEATURED.PRODUCTS === true) {
        return this.featuredProducts(products)
      } else {
        return products
      }
    },

    /**
     * Sentence based on current filters
     */
    noResultText() {
      var self = this
      var elements = []

      // Get selected categories
      if (this.filterCategory) {
        var categoryExists = this.categories.find(function(category) {
          return category.id === self.filterCategory
        })

        if (categoryExists) {
          let productsCount = self.products.filter(function(product) {
            return product.catalog_category.id === self.filterCategory
          })

          elements.push({
            name: self.selectedCategory.name,
            count: productsCount.length
          })
        }
      }

      // Get selected tags
      var selectedTags = []
      self.filterTags.forEach(function(tag) {
        let productsCount = self.products.filter(function(product) {
          return product.tag_list.includes(tag)
        })

        selectedTags.push({
          name: tag,
          count: productsCount.length
        })
      })

      selectedTags.sort(function(a, b) {
        return b.count - a.count
      })
      elements = elements.concat(selectedTags)

      // Get search string
      if (self.searchString) {
        elements.push({
          name: self.searchString
        })
      }

      // Prepare text
      var text = 'No products match your search.'

      if (elements.length > 0) {
        text =
          'No products match your search for ' +
          elements.map(element => '<b>' + element.name + '</b>').join(' + ') +
          '.'
      }

      // Determine if navigation has categories as priority

      let mainRecomendations = this.$config.NAV.filter(nav =>
        nav.path.includes('/products/')
      ).map(nav => {
        let chunks = nav.path.split('/')
        return parseInt(chunks[chunks.length - 1])
      })

      let otherCats

      // If there is main recomendations by the navigations urls these are taken to fill other cats
      if (mainRecomendations.length >= 1) {
        otherCats = self.categories.filter(
          x => x.id !== self.filterCategory && mainRecomendations.includes(x.id)
        )
      } else {
        otherCats = self.categories.filter(x => x.id !== self.filterCategory)
      }

      let otherCategory =
        otherCats[Math.floor(Math.random() * otherCats.length)]

      let obj = {
        text: text,
        category: self.selectedCategory,
        otherCategory: otherCategory,
        tag: selectedTags.length > 0 ? selectedTags[0].name : false,
        showEmptyProduct: self.showEmptyProduct ? self.showEmptyProduct : null
      }

      return obj
    },

    /**
     * Selected category object
     */
    selectedCategory() {
      var self = this

      var selectedCategory = this.categories.find(function(category) {
        return category.id === self.filterCategory
      })

      return selectedCategory
    },

    /**
     * Source of product card
     */
    sourceCard() {
      return this.$route.params.fromEspotlight
        ? 'Product Spotlight'
        : 'Product list'
    },
    categoryId() {
      return this.$route.params ? this.$route.params.categoryId : null
    },
    filteredProductsThatIncludeThcPercentage() {
      return this.filteredProducts.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
    },
    filteredProductsThatIncludeThcMg() {
      return this.filteredProducts.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
    },
    filteredProductsThatIncludeCbdPercentage() {
      return this.filteredProducts.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
    },
    filteredProductsThatIncludeCbdMg() {
      return this.filteredProducts.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
    }
  },
  created: function() {
    // Validate the routes for the scroll transition
    this.$router.afterEach((to, from) => {
      if (
        from.path.split('/')[1] !== 'product' &&
        to.path.split('/')[1] === 'products'
      ) {
        store.commit('setDoesNotCameFromProduct', true)
      } else {
        store.commit('setDoesNotCameFromProduct', false)
      }
    })
    // Set initial data
    this.setData()
    this.setFilteredTags()

    this.isShopify = this.$config.POS_TYPE === 'shopify'

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$on('transition-leave', this.onTransitionLeave)

    if (this.filteredTags.length === 0) {
      this.filtersCategoriesOpen = true
    }
  },

  beforeDestroy() {
    // save current position of products scroll
    let currentPosition = 0
    if (this.$refs.productsGrid.scrollTop === 0) {
      currentPosition = this.$refs.productsGrid.scrollTop + 10
    } else {
      currentPosition = this.$refs.productsGrid.scrollTop
    }
    if (this.$refs.productsGrid && this.$route.path.includes('on-sale')) {
      localStorage.setItem('productsOffset', currentPosition)
    }
  },
  destroyed: function() {
    // Events
    try {
      this.$off('transition-leave', this.onTransitionLeave)
    } catch (error) {
      console.error('error in animation execution', error)
    }
  },
  mounted: function() {
    var self = this

    // Keyboard
    if (
      this.$config.PRODUCT_UI === 'condensed' ||
      (this.columnFiltersStyle === 'collapsed' && !this.isShopify)
    ) {
      $('.input').onScreenKeyboard({
        rewireReturn: 'search'
      })

      $('.input').on('keyup', function(e) {
        this.dispatchEvent(new Event('input'))
        self.searchInput(e)
      })
    } else {
      $('.input-osk').onScreenKeyboard({
        rewireReturn: 'search'
      })

      $('.input-osk').on('keyup', function(e) {
        this.dispatchEvent(new Event('input'))
        self.searchInput(e)
      })
    }

    // Hide keyboard
    $('#osk-container:visible .osk-hide').click()
    // listen click outside keyboard in order to hide it
    this.listenClick()

    // redirect to first category no category filtered
    /* if (this.filterCategory === null && this.categories.length > 0) {
      let isOnsale =
        this.$route.query.only_on_sale || this.$route.path.includes('on-sale')
      this.filterCategory = isOnsale ? null : this.categories[0].id
    } */
  },
  updated: function() {
    var self = this

    if (this.layoutUpdated) {
      if (
        this.$config.PRODUCT_UI === 'condensed' ||
        (this.columnFiltersStyle === 'collapsed' && !this.isShopify)
      ) {
        $('.input').onScreenKeyboard({
          rewireReturn: 'search'
        })

        $('.input').on('keyup', function(e) {
          this.dispatchEvent(new Event('input'))
          self.searchInput(e)
        })
      } else {
        $('.input-osk').onScreenKeyboard({
          rewireReturn: 'search'
        })

        $('.input-osk').on('keyup', function(e) {
          this.dispatchEvent(new Event('input'))
          self.searchInput(e)
        })
      }
      this.layoutUpdated = false
    }
  },
  watch: {
    filterCategory: function() {
      console.log('cambió filtro')
      this.$nextTick(() => {
        // console.log('Categories loaded', this.filterCategory)
        this.setFilteredTags()
        // this.updateData()
      })
      // this.transitionFilteredTags();
    },
    $route: function(to, from) {
      // If products category or other  change on route url update data
      if (to.path !== from.path) {
        this.updateData()
        this.layoutUpdated = true
      }
      if (Object.keys(from.query).length > Object.keys(to.query).length) {
        this.transitionProducts(function() {
          this.setData()
          this.transitionFilteredTags()
        })
      }
      console.log(
        'category change',
        to.query.category,
        this.selectedCategory.id,
        this.selectedCategory && this.selectedCategory.id !== to.query.category
      )
      if (
        this.selectedCategory &&
        this.selectedCategory.id !== to.query.category
      ) {
        this.selectCategory(to.query.category)
      }
    },
    columnFiltersStyle: function(to, from) {
      this.layoutUpdated = true
    },
    categoryId() {
      console.log('cambio la category')
    },

    categories: function() {
      // this.updateData()
    },
    products: function() {
      this.updateData()
    },
    isGeneratingIndex: function(to, from) {
      let self = this
      let tl = new TimelineLite()
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
      tl.play()
    }
  },
  methods: {
    getCategoryByName(name) {
      return CATEGORIES_WITH_PRIORITY.find(
        x => x.name.toLowerCase() === name.toLowerCase()
      )
    },
    sortName(products) {
      return products.sort(function(a, b) {
        return a.name
          .toLowerCase()
          .trim()
          .localeCompare(b.name.toLowerCase().trim())
      })
    },
    priceAsc(products) {
      return products.sort(function(a, b) {
        if (
          b.product_values[0] &&
          a.product_values[0] &&
          !Number(b.product_values[0].value) &&
          !Number(a.product_values[0].value)
        ) {
          return 0
        }
        if (!b.product_values[0] || !Number(b.product_values[0].value)) {
          return 1
        }
        if (!a.product_values[0] || !Number(a.product_values[0].value)) {
          return -1
        }
        return (
          Number(a.product_values[0].value) - Number(b.product_values[0].value)
        )
      })
    },
    priceDesc(products) {
      return products.sort(function(a, b) {
        if (
          b.product_values[0] &&
          a.product_values[0] &&
          !Number(b.product_values[0].value) &&
          !Number(a.product_values[0].value)
        ) {
          return 0
        }
        if (!b.product_values[0] || !Number(b.product_values[0].value)) {
          return -1
        }
        if (!a.product_values[0] || !Number(a.product_values[0].value)) {
          return 1
        }
        return (
          Number(b.product_values[0].value) - Number(a.product_values[0].value)
        )
      })
    },
    percentageDesc(products) {
      const newThcArrayPercentage = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayPercentageIds = newThcArrayPercentage.map(
        product => product.id
      )
      const newThcArray = products.filter(product => {
        return !newThcArrayPercentageIds.includes(product.id)
      })
      const sortArrayPercentageThc = newThcArrayPercentage.sort((a, b) => {
        const onlyValuePercentageA = a.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'THC'
          }
        )
        const onlyValuePercentageB = b.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'THC'
          }
        )
        return (
          Number(onlyValuePercentageB[0].value.split('%')[0]) -
          Number(onlyValuePercentageA[0].value.split('%')[0])
        )
      })
      return sortArrayPercentageThc.concat(newThcArray)
    },
    percentageAsc(products) {
      const newThcArrayPercentage = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayPercentageIds = newThcArrayPercentage.map(
        product => product.id
      )
      const newThcArray = products.filter(product => {
        return !newThcArrayPercentageIds.includes(product.id)
      })
      const sortArrayPercentageThc = newThcArrayPercentage.sort((a, b) => {
        const onlyValuePercentageA = a.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'THC'
          }
        )
        const onlyValuePercentageB = b.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'THC'
          }
        )
        return (
          Number(onlyValuePercentageA[0].value.split('%')[0]) -
          Number(onlyValuePercentageB[0].value.split('%')[0])
        )
      })
      return sortArrayPercentageThc.concat(newThcArray)
    },
    mgDesc(products) {
      const newThcArrayMG = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayIds = newThcArrayMG.map(product => product.id)
      const newThcArray = products.filter(product => {
        return !newThcArrayIds.includes(product.id)
      })
      const sortArrayMGThc = newThcArrayMG.sort((a, b) => {
        const onlyValueMgA = a.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'thc'
        })
        const onlyValueMgB = b.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'thc'
        })
        return (
          Number(onlyValueMgB[0].value.toLowerCase().split('mg')[0]) -
          Number(onlyValueMgA[0].value.toLowerCase().split('mg')[0])
        )
      })
      return sortArrayMGThc.concat(newThcArray)
    },
    mgAsc(products) {
      const newThcArrayMG = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'THC' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayIds = newThcArrayMG.map(product => product.id)
      const newThcArray = products.filter(product => {
        return !newThcArrayIds.includes(product.id)
      })
      const sortArrayMGThc = newThcArrayMG.sort((a, b) => {
        const onlyValueMgA = a.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'thc'
        })
        const onlyValueMgB = b.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'thc'
        })
        return (
          Number(onlyValueMgA[0].value.toLowerCase().split('mg')[0]) -
          Number(onlyValueMgB[0].value.toLowerCase().split('mg')[0])
        )
      })
      return sortArrayMGThc.concat(newThcArray)
    },
    percentageCbdDesc(products) {
      const newThcArrayPercentage = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayPercentageIds = newThcArrayPercentage.map(
        product => product.id
      )
      const newThcArray = products.filter(product => {
        return !newThcArrayPercentageIds.includes(product.id)
      })
      const sortArrayPercentageThc = newThcArrayPercentage.sort((a, b) => {
        const onlyValuePercentageA = a.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'CBD'
          }
        )
        const onlyValuePercentageB = b.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'CBD'
          }
        )
        return (
          Number(onlyValuePercentageB[0].value.split('%')[0]) -
          Number(onlyValuePercentageA[0].value.split('%')[0])
        )
      })
      return sortArrayPercentageThc.concat(newThcArray)
    },
    percentageCbdAsc(products) {
      const newThcArrayPercentage = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                attributeValue.value.includes('%') &&
                Number(attributeValue.value.split('%')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayPercentageIds = newThcArrayPercentage.map(
        product => product.id
      )
      const newThcArray = products.filter(product => {
        return !newThcArrayPercentageIds.includes(product.id)
      })
      const sortArrayPercentageThc = newThcArrayPercentage.sort((a, b) => {
        const onlyValuePercentageA = a.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'CBD'
          }
        )
        const onlyValuePercentageB = b.attribute_values.ungrouped.filter(
          thcValue => {
            return thcValue.name === 'CBD'
          }
        )
        return (
          Number(onlyValuePercentageA[0].value.split('%')[0]) -
          Number(onlyValuePercentageB[0].value.split('%')[0])
        )
      })
      return sortArrayPercentageThc.concat(newThcArray)
    },
    mgCbdDesc(products) {
      const newThcArrayMG = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayIds = newThcArrayMG.map(product => product.id)
      const newThcArray = products.filter(product => {
        return !newThcArrayIds.includes(product.id)
      })
      const sortArrayMGThc = newThcArrayMG.sort((a, b) => {
        const onlyValueMgA = a.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'cbd'
        })
        const onlyValueMgB = b.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'cbd'
        })
        return (
          Number(onlyValueMgB[0].value.toLowerCase().split('mg')[0]) -
          Number(onlyValueMgA[0].value.toLowerCase().split('mg')[0])
        )
      })
      return sortArrayMGThc.concat(newThcArray)
    },
    mgCbdAsc(products) {
      const newThcArrayMG = products.filter(product => {
        return product.attribute_values.ungrouped !== undefined
          ? product.attribute_values.ungrouped.some(attributeValue => {
            return (
              attributeValue.name === 'CBD' &&
                !attributeValue.value.includes('%') &&
                Number(attributeValue.value.toLowerCase().split('mg')[0]) >= 1
            )
          })
          : false
      })
      const newThcArrayIds = newThcArrayMG.map(product => product.id)
      const newThcArray = products.filter(product => {
        return !newThcArrayIds.includes(product.id)
      })
      const sortArrayMGThc = newThcArrayMG.sort((a, b) => {
        const onlyValueMgA = a.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'cbd'
        })
        const onlyValueMgB = b.attribute_values.ungrouped.filter(thcValue => {
          return thcValue.name.toLowerCase() === 'cbd'
        })
        return (
          Number(onlyValueMgA[0].value.toLowerCase().split('mg')[0]) -
          Number(onlyValueMgB[0].value.toLowerCase().split('mg')[0])
        )
      })
      return sortArrayMGThc.concat(newThcArray)
    },
    featuredProducts(products) {
      return products.sort(function(a, b) {
        if (a.isFeatured && !b.isFeatured) {
          return -1
        } else if (!a.isFeatured && b.isFeatured) {
          return 1
        }
        return 0
      })
    },
    listenClick() {
      $(document).on('click', e => {
        // get keyboard element
        const keyboard = $('#osk-container')

        // if the target of the click isn't the container nor a descendant of the container
        if (
          !e.target.classList.contains(
            this.$config.PRODUCT_UI === 'condensed' ||
              (this.columnFiltersStyle === 'collapsed' && !this.isShopify)
              ? 'input'
              : 'input-osk'
          ) &&
          !keyboard.is(e.target) &&
          keyboard.has(e.target).length === 0 &&
          !e.target.classList.contains('block-pointer')
        ) {
          $('#osk-container:visible .osk-hide').click()
        } else {
          this.layoutUpdated = false
        }
      })
    },
    /**
     *
     */
    removeFocus() {
      let input = $('input.input')
      input.removeClass('osk-focused')
    },
    /**
     * Screen transition enter
     */
    transitionEnter: function() {
      // Selectors
      var self = this
      var container = $(this.$el)

      this.$root.$emit('block-pointer', true)
      // if there is an product scrloo position already stored , scroll to

      if (self.productOffset && this.$refs.productsGrid) {
        // this.$refs.productsGrid.scrollTo(0, self.productOffset)
        // const doesNotCameFromProduct = store.state.doesNotCameFromProduct

        const toScroll =
          this.$route.query.only_on_sale || this.$route.path.includes('on-sale')
            ? 10
            : self.productOffset

        console.log('productsOffset', toScroll)

        this.$refs.productsGrid.scrollTo(0, toScroll)
      }

      if (container.find('.message-generating').length === 1) {
        // Animation
        let tl = new TimelineLite()
        tl.pause()

        tl.to(
          container,
          GSAP_ANIMATION.duration,
          {
            alpha: 1
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
      } else {
        var products =
          self.productOffset && self.productOffset > 0
            ? self.getVisibleProducts()
            : container.find('.product-card')

        if (container.find('.grid-header').length === 1) {
          var productsLeft = products.slice(0, 8).filter(':even')
          var productsRight = products.slice(0, 8).filter(':odd')
        } else {
          productsLeft = products.slice(0, products.length).filter(':even')
          productsRight = products.slice(0, products.length).filter(':odd')
        }

        // Before animation
        container.css({ opacity: '' })
        container.find('.filters__scroller').addClass('scroll-hidden')

        // Animation
        let tl = new TimelineLite()
        tl.pause()

        tl.call(
          function() {
            if (self.$refs.lottieBlockIntro) {
              self.$refs.lottieBlockIntro.animation.play()
            }
          },
          null,
          null,
          GSAP_ANIMATION.append
        )

        if (this.$config.HOME_LAYOUT === 'on_sale') {
          tl.from(
            container.find('.single-col-search'),
            0.5,
            {
              alpha: 0,
              x: -60,
              clearProps: 'transform',

              ease: Power3.easeOut
            },
            0.3
          )
        }

        tl.from(
          container.find('.filters__search'),
          0.5,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          0.3
        )

        tl.from(
          container.find('.on-sale-toggle'),
          0.5,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          0.3
        )

        if (!container.find('.filters').hasClass('filters--collapsed')) {
          tl.addLabel('startProducts', 0.5)

          tl.from(
            container.find('.filters__separator'),
            0.7,
            {
              scaleX: 0,
              clearProps: 'transform',
              ease: Power2.easeInOut
            },
            0.1
          )

          container.find('.filters__group').each(function(index) {
            var group = $(this)
            var items = group.find('.filters__item')
            var start = 0.5 + 0.3 * index

            items.filter('.filters__item--tag').css({ opacity: '' })
            tl.from(
              group.find('.filters__title__text'),
              0.5,
              {
                alpha: 0,
                x: -10,
                clearProps: 'transform',
                ease: Power3.easeOut
              },
              start
            )

            tl.from(
              group.find('.filters__title__line'),
              0.5,
              {
                scaleX: 0,
                clearProps: 'transform',
                ease: Power3.easeInOut
              },
              start
            )

            tl.staggerFrom(
              items.find('.filters__item__icon').slice(0, 20),
              0.6,
              {
                alpha: 0,
                scale: 0,
                clearProps: 'transform',
                ease: Power3.easeOut
              },
              0.1,
              start
            )

            tl.staggerFrom(
              items.find('.filters__item__label').slice(0, 20),
              0.5,
              {
                alpha: 0,
                x: -10,
                clearProps: 'transform',
                ease: Power3.easeOut
              },
              0.1,
              start
            )

            tl.staggerFrom(
              items.find('.filters__item__background').slice(0, 20),
              0.5,
              {
                alpha: 0,
                ease: Linear.easeNone
              },
              0.1,
              start
            )

            tl.from(
              group.find('.filters__toggle__text'),
              0.5,
              {
                alpha: 0,
                y: -10,
                clearProps: 'transform',
                ease: Power3.easeOut
              },
              start + 0.2
            )

            tl.from(
              group.find('.filters__toggle__arrow'),
              0.5,
              {
                alpha: 0,
                y: -10,
                clearProps: 'transform',
                ease: Power3.easeOut
              },
              start + 0.3
            )

            group = null
            items = null
          })
        } else {
          tl.addLabel('startProducts', 0)
          container.find('.filters').css({ opacity: 0 })
        }

        if (this.$config.HOME_LAYOUT !== 'on_sale') {
          tl.from(
            productsLeft,
            2.5,
            {
              y: productsLeft.length * -560 - 100,
              clearProps: 'transform',
              ease: Power3.easeOut
            },
            'startProducts'
          )

          tl.staggerFromTo(
            productsLeft,
            1,
            {
              alpha: 0
            },
            {
              alpha: 1,
              ease: Linear.easeNone
            },
            0.15,
            'startProducts'
          )

          tl.fromTo(
            container.find('.no-results'),
            0.5,
            {
              alpha: 0
            },
            {
              alpha: 1,
              clearProps: 'opacity',
              ease: Linear.easeNone
            },
            'startProducts+=0.25'
          )

          tl.from(
            productsRight,
            2.5,
            {
              y: productsRight.length * -560 - 100,
              clearProps: 'transform',
              ease: Power3.easeOut
            },
            'startProducts+=0.25'
          )

          tl.staggerFromTo(
            productsRight,
            1,
            {
              alpha: 0
            },
            {
              alpha: 1,
              ease: Linear.easeNone
            },
            0.15,
            'startProducts+=0.25'
          )
        } else {
          let cards = self.getVisibleProducts()
          tl.staggerFrom(
            cards,
            0.3,
            {
              y: 30,
              alpha: 0,
              clearProps: 'transform',
              ease: Power3.easeOut
            },
            0.05,
            'startProducts'
          )
        }

        tl.staggerFrom(
          container.find('.sorts__item'),
          0.6,
          {
            alpha: 0,
            clearProps: 'opacity'
          },
          0.1,
          'startProducts+=0.5'
        )

        tl.staggerFrom(
          container.find('.sorts__tags'),
          0.6,
          {
            alpha: 0,
            clearProps: 'opacity'
          },
          0.1,
          'startProducts+=0.5'
        )

        tl.call(function() {
          if (products) {
            products.css({ opacity: '' })
          }
        })

        if (container.find('.grid-header').length === 1) {
          tl.fromTo(
            container.find('.grid-header'),
            1,
            {
              alpha: 0,
              y: -100
            },
            {
              alpha: 1,
              y: 0,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            'startProducts+=1.5'
          )
        }

        tl.call(function() {
          self.$root.$emit('block-pointer', false)
        })

        tl.call(
          function() {
            if (container) {
              container.find('.filters__scroller').removeClass('scroll-hidden')
              container.find('.filters').css({ opacity: '' })
            }
          },
          null,
          null,
          GSAP_ANIMATION.append
        )

        tl.call(function() {
          tl.kill()

          tl = null
          container = null
          products = null
          productsLeft = null
          productsRight = null
        })

        tl.play()
        // localStorage.removeItem('productsOffset')
      }
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function(el, done) {
      // Selectors
      var self = this
      var container = $(el)

      if (container.find('.message-generating').length === 1) {
        // Animation
        let tl = new TimelineLite()
        tl.pause()

        tl.to(
          container,
          0.5,
          {
            alpha: 0
          },
          0
        )

        tl.call(function() {
          tl.kill()

          tl = null
          container = null

          done()
        })

        tl.play()
      } else {
        var blockAnimation = self.$refs.lottieBlockIntro.animation
        var visibleProducts = this.getVisibleProducts()
        var reversedVisibleProducts = visibleProducts.reverse()

        // Before animation
        container.find('.filters__scroller').addClass('scroll-hidden')

        // Animation
        let tl = new TimelineLite()
        tl.pause()

        tl.to(
          container.find('.filters__separator'),
          GSAP_ANIMATION.duration,
          {
            scaleX: 0,
            ease: Power2.easeIn
          },
          GSAP_ANIMATION.tween
        )

        tl.to(
          container.find('.single-col-search'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeIn,
            overwrite: 'all'
          },
          GSAP_ANIMATION.tween
        )

        tl.to(
          container.find('.filters__search'),
          0.5,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeIn,
            overwrite: 'all'
          },
          0
        )

        tl.to(
          container.find('.on-sale-toggle'),
          0.5,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeIn,
            overwrite: 'all'
          },
          0
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
          0.1
        )

        container.find('.filters__group').each(function(index) {
          var group = $(this)
          var items = group.find('.filters__item')
          var start = 0

          tl.to(
            group.find('.filters__title__text'),
            0.5,
            {
              alpha: 0,
              x: -10,
              ease: Power3.easeIn,
              overwrite: 'all'
            },
            start
          )

          tl.to(
            group.find('.filters__title__line'),
            0.5,
            {
              scaleX: 0,
              ease: Power3.easeInOut,
              overwrite: 'all'
            },
            start
          )

          tl.staggerTo(
            items.find('.filters__item__icon').slice(0, 20),
            0.6,
            {
              alpha: 0,
              scale: 0,
              ease: Power3.easeIn
            },
            0,
            start
          )

          tl.staggerTo(
            items.find('.filters__item__label').slice(0, 20),
            0.5,
            {
              alpha: 0,
              x: -10,
              ease: Power3.easeIn,
              overwrite: 'all'
            },
            0,
            start
          )

          tl.staggerTo(
            items.find('.filters__item__background').slice(0, 20),
            0.5,
            {
              alpha: 0,
              ease: Linear.easeNone
            },
            0,
            start
          )

          tl.to(
            group.find('.filters__toggle__text'),
            0.5,
            {
              alpha: 0,
              y: -10,
              ease: Power3.easeIn
            },
            start + 0.2
          )

          tl.to(
            group.find('.filters__toggle__arrow'),
            0.5,
            {
              alpha: 0,
              y: -10,
              ease: Power3.easeIn
            },
            start + 0.3
          )

          group = null
          items = null
        })

        tl.staggerTo(
          container.find('.sorts__item'),
          0.6,
          {
            alpha: 0,
            overwrite: 'all'
          },
          0.1,
          0
        )

        tl.staggerTo(
          container.find('.sorts__tags'),
          0.6,
          {
            alpha: 0,
            overwrite: 'all'
          },
          0.1,
          0
        )

        tl.to(
          container.find('.no-results'),
          0.4,
          {
            alpha: 0,
            ease: Linear.easeNone
          },
          0
        )

        if (container.find('.grid-header').length === 1) {
          tl.to(
            container.find('.grid-header'),
            0.3,
            {
              alpha: 0,
              y: 20,
              ease: Power2.easeIn
            },
            0
          )
        }

        if (TweenMax.getTweensOf(reversedVisibleProducts).length > 0) {
          tl.staggerTo(
            reversedVisibleProducts,
            0.3,
            {
              alpha: 0,
              y: 20
            },
            0.05,
            0
          )
        } else {
          tl.staggerFromTo(
            reversedVisibleProducts,
            0.3,
            {
              alpha: 1,
              y: 0
            },
            {
              alpha: 0,
              y: 20,
              ease: Power2.easeIn
            },
            0.05,
            0
          )
        }

        tl.call(
          function() {
            tl.kill()

            tl = null
            container = null
            visibleProducts = null
            reversedVisibleProducts = null

            done()
          },
          null,
          null,
          Math.max(1, tl.duration())
        )

        tl.play()
      }
      $(document).unbind()
    },

    /**
     * Categories transition enter
     */
    onCategoriesTransitionEnter: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container,
        0.5,
        {
          alpha: 0,
          height: 0,
          clearProps: 'height, opacity',
          ease: Power3.easeInOut
        },
        0
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Categories transition leave
     */
    onCategoriesTransitionLeave: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        0.5,
        {
          alpha: 0,
          height: 0,
          ease: Power3.easeInOut
        },
        0
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Products transition enter
     */
    onProductsTransitionEnter: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(container, 0.5, {
        alpha: 0
      })

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Products transition leave
     */
    onProductsTransitionLeave: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(container, 0.5, {
        alpha: 0
      })

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    onToggleTransitionEnter: function(el, done) {
      var container = $(el)
      console.log('Toggle container')
      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container,
        0.5,
        {
          alpha: 0,
          height: 0,
          clearProps: 'height, opacity',
          ease: Power3.easeInOut
        },
        0
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },
    onToggleTransitionLeave: function(el, done) {
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        0.5,
        {
          alpha: 0,
          height: 0,
          ease: Power3.easeInOut
        },
        0
      )

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },
    /**
     * Toggle categories
     */
    toggleFiltersCategories: function() {
      var self = this
      var container = $('.filters__list--categories')

      if (self.filtersCategoriesOpen) {
        // Before animation
        var fromHeight = container.height()
        var toHeight = 390

        // Animation
        var tl = new TimelineLite()
        tl.pause()

        tl.fromTo(
          container,
          0.5,
          {
            height: fromHeight
          },
          {
            height: toHeight,
            ease: Power3.easeInOut
          }
        )

        tl.call(function() {
          if (container) {
            self.filtersCategoriesOpen = false
            container.css({ height: '' })
          }
        })

        tl.call(function() {
          tl.kill()

          tl = null
          container = null
        })

        tl.play()
      } else {
        // Before animation
        fromHeight = container.height()
        container.css({ maxHeight: 'none' })
        toHeight = container.height()

        // Animation
        tl = new TimelineLite()
        tl.pause()

        tl.fromTo(
          container,
          0.5,
          {
            height: fromHeight
          },
          {
            height: toHeight,
            ease: Power3.easeInOut
          }
        )

        tl.staggerFrom(
          container.find('.filters__item__icon').slice(4),
          0.6,
          {
            alpha: 0,
            scale: 0,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          0.2
        )

        tl.staggerFrom(
          container.find('.filters__item__label').slice(4),
          0.5,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          0.2
        )

        tl.staggerFrom(
          container.find('.filters__item__background').slice(4),
          0.5,
          {
            alpha: 0,
            clearProps: 'opacity',
            ease: Linear.easeNone
          },
          0.1,
          0.2
        )

        tl.call(function() {
          if (container) {
            self.filtersCategoriesOpen = true
            container.css({ height: '', maxHeight: '' })
          }
        })

        tl.call(function() {
          tl.kill()

          tl = null
          container = null
        })

        tl.play()
      }
    },

    /**
     * Transition between two sets of products
     * @param  {Function} callback Function to call between transition leave and enter
     */
    transitionProducts: function(callback) {
      // Selectors

      var self = this
      var container = $(this.$el)
      var visibleProducts = this.getVisibleProducts()
      let offsetOfProducts = localStorage.getItem('productsOffset')

      this.$root.$emit('block-pointer', true)

      // Animations
      var tl = new TimelineLite()

      tl.pause()

      if (container.find('.grid-header').length === 1) {
        tl.to(
          container.find('.grid-header'),
          0.3,
          {
            alpha: 0,
            y: 20,
            ease: Power2.easeIn
          },
          0
        )
      }

      tl.staggerFromTo(
        visibleProducts.reverse(),
        0.3,
        {
          alpha: 1,
          y: 0
        },
        {
          alpha: 0,
          y: 20,
          ease: Power2.easeIn
        },
        0.05,
        0
      )

      tl.call(
        function() {
          if (container) {
            if (!offsetOfProducts) {
              container.find('.products-grid').scrollTop(0)
            }

            container.find('.products-grid').css({ opacity: 0 })
            callback()
            container.find('.product-card').css({ opacity: 0 })
          }
        },
        null,
        null,
        '+=0.1'
      )

      tl.call(
        function() {
          if (container) {
            var visibleProducts = self.getVisibleProducts()

            TweenMax.killTweensOf(container.find('.product-card'))

            container.find('.products-grid').css({ opacity: '' })
            visibleProducts.css({ opacity: '', transform: '' })

            var sliceProducts = 10

            if (container.find('.grid-header').length === 1) {
              sliceProducts = 8

              tl.fromTo(
                container.find('.grid-header'),
                GSAP_ANIMATION.duration,
                {
                  alpha: 0,
                  x: -20
                },
                {
                  alpha: 1,
                  x: 0,

                  y: 0,
                  clearProps: 'transform, opacity',
                  ease: Power3.easeOut
                }
              )
            }

            if (visibleProducts.length > 0) {
              /* if (self.$config.HOME_LAYOUT ==="on_sale") {
                tl.staggerFrom(
                  visibleProducts,
                  0.7,
                  {
                    alpha: 0,
                    x: -20,
                    clearProps: "transform, opacity",
                    ease: Power3.easeOut
                  },
                  0.05
                );
              } else { */
              tl.staggerFrom(
                visibleProducts.find('.product-image'),

                GSAP_ANIMATION.duration,
                {
                  alpha: 0,
                  x: -20,
                  clearProps: 'transform, opacity',
                  ease: Power3.easeOut
                },
                GSAP_ANIMATION.tween
              )
              console.log('VISIBLE PRODUCTS ARE', visibleProducts.length)
              if (self.$config.HOME_LAYOUT === 'on_sale') {
                tl.staggerFrom(
                  visibleProducts.find('.product-card__info'),
                  GSAP_ANIMATION.duration,
                  {
                    alpha: 0,
                    x: -20,
                    clearProps: 'opacity, transform',
                    ease: Power3.easeOut
                  },
                  GSAP_ANIMATION.tween,
                  GSAP_ANIMATION.append
                )
              } else {
                tl.staggerFrom(
                  visibleProducts
                    .find('.product-card__info')
                    .slice(0, sliceProducts),
                  GSAP_ANIMATION.duration,
                  {
                    alpha: 0,
                    clearProps: 'opacity',
                    ease: Linear.easeNone
                  },
                  GSAP_ANIMATION.tween,
                  GSAP_ANIMATION.append
                )
              }

              // }

              tl.call(function() {
                container
                  .find('.product-card')
                  .css('opacity', '')
                  .css('transform', '')
              })
            } else {
              tl.fromTo(
                container.find('.no-results'),
                0.5,
                {
                  alpha: 0
                },
                {
                  alpha: 1,
                  clearProps: 'opacity',
                  ease: Linear.easeNone
                }
              )
            }
          }

          tl.call(function() {
            self.$root.$emit('block-pointer', false)
          })

          tl.call(function() {
            tl.kill()

            tl = null
            container = null
            visibleProducts = null
          })
        },
        null,
        null,
        '+=0.1'
      )

      tl.call(function() {
        visibleProducts = null
      })

      tl.play()
    },

    /**
     * Get products that are inside the viewport
     * @return {DOM} elements
     */
    getVisibleProducts: function() {
      return $(this.$el)
        .find('.product-card')
        .filter(function(index, product) {
          var productStart = $(product).offset().top + 300
          var productEnd = productStart + $(product).outerHeight(true)
          var viewportStart = 0
          var viewportEnd = $(window).height() + 300

          return (
            (productStart > viewportStart && productStart < viewportEnd) ||
            (productEnd > viewportStart && productEnd < viewportEnd)
          )
        })
    },

    /**
     * Get icon for given category
     * @param  {String} category
     * @return {String} Icon URL
     */
    icon: function(category) {
      var fileName = category.toLowerCase().replace(/s$|[ -]*/gi, '')

      // Hard coded edge case
      if (fileName === 'extract') {
        fileName = 'concentrate'
      } else if (fileName === 'cartridge') {
        fileName = 'vape'
      } else if (fileName === 'beverage') {
        fileName = 'drink'
      }
      try {
        var file = require('../assets/img/category-' + fileName + '.svg')
      } catch (e) {
        file = require('../assets/img/category-default.svg')
      }

      return file
    },

    /**
     * Select given category with products transition
     * @param  {String} category
     */
    selectCategory: function(cat, only = false) {
      var self = this
      this.currentcurrentPage = 1
      localStorage.removeItem('productsOffset')

      let category = self.categories.find(ct => ct.id === cat)
      console.log('llamado', category, self.categories, cat)

      // GS event tracker
      if (self.$gsClient && this.new === false) {
        self.$gsClient.track('Category', {
          event_category: 'Selection',
          name: category.name,
          id: category.id,
          total_stock: category.total_stock
        })
      }
      // Call products transition with a callback
      this.transitionProducts(function() {
        if (only) {
          self.searchString = null
          self.searchValue = null
          self.filterTags = []
          self.filterCategory = category
          self.filterCategoryName = category.name
        } else {
          var tags = self.tagsPerCategories[category]
          var checkedTags = []

          // Set tags that belong to that category

          self.filterTags.forEach(function(tag) {
            if (tags && tags.includes(tag)) {
              checkedTags.push(tag)
            }
          })
          self.filterTags = checkedTags

          // Set new category
          if (self.filterCategory === category.id) {
            self.filterCategory = null
            self.filterCategoryName = null
          } else {
            self.filterCategory = category.id
            self.filterCategoryName = category.name
            console.log('Category name')
            console.log(self.filterCategoryName)
          }
        }

        // Update route with params
        self.updateRoute()
        self = false
      })
    },

    /**
     * Select given tag with products transition
     * @param  {String} tag
     */
    selectTag: function(tag, only = false) {
      var self = this
      localStorage.removeItem('productsOffset')

      // GS event tracker
      if (self.$gsClient) {
        self.$gsClient.track('Tag', {
          event_category: 'Selection',
          name: tag,
          value: 0
        })
      }

      // Call products transition with a callback
      this.transitionProducts(function() {
        // Set new tags list
        if (only) {
          self.filterTags = [tag]
        } else {
          if (self.filterTags.includes(tag)) {
            self.filterTags.splice(self.filterTags.indexOf(tag), 1)
          } else {
            self.filterTags.push(tag)
          }
        }

        // Update route with params
        self.updateRoute()
      })
    },
    /**
     * Expands categories toggle if categories is hidden
     */
    expandCategoriesOnSelect() {
      if (this.categories) {
        // get curren position of category
        let index = this.categories.findIndex(cat => {
          return cat.id === this.filterCategory
        })

        // if category is beyond the fourth item expand toggle
        if (index > 3) {
          let toggle = $('div.filters__toggle')[0]
          if (toggle) {
            if (!$(toggle).hasClass('filters__toggle--is-opened')) {
              this.filtersCategoriesOpen = true
            } else {
              console.log('toggle esta cerrado')
            }
          }
        }
      }
    },

    /**
     * Set data based on params
     */
    setData: function() {
      var self = this
      this.showEmptyProduct = false

      // Set category
      if (this.$route.params.categoryId) {
        console.log('Hay category en params')
        this.hideCategories = true
        this.filterCategory = Number(this.$route.params.categoryId)
      } else if (this.$route.query.category) {
        console.log('Hay category en query')

        this.hideCategories = false
        this.filterCategory = Number(this.$route.query.category)
      } else {
        this.hideCategories = false
        this.filterCategory = null
        /* this.categories && this.categories.length > 0
            ? this.categories[0].id
            : null */
      }
      self.expandCategoriesOnSelect()
      // Check if category exists
      if (this.filterCategory) {
        var categoryExists = this.categories.find(function(category) {
          return category.id === self.filterCategory
        })

        if (!categoryExists) {
          this.hideCategories = false
          this.filterCategory = null
          this.showEmptyProduct = true
        }
      }

      if (self.$gsClient && this.filterCategory) {
        if (this.$route.params.fromEspotlight) {
          self.$gsClient.track('Brand from Spotlight', {})
        }
      }
      if (self.$gsClient && this.filterCategory && this.new === false) {
        self.$gsClient.track('Category', {
          event_category: 'Selection',
          name: this.categories[0].name,
          id: this.filterCategory
        })
      }

      // Set tags
      if (this.$route.query.tags) {
        if (typeof this.$route.query.tags === 'string') {
          this.filterTags = [this.$route.query.tags]
        } else {
          this.filterTags = this.$route.query.tags
        }
      } else {
        this.filterTags = []
      }

      // Set sort
      if (this.$route.query.sort) {
        this.sortOption = this.$route.query.sort
      } else {
        this.sortOption = 'name'
      }

      // Show Only on sale
      if (
        this.$route.query.only_on_sale ||
        this.$route.path.includes('on-sale')
      ) {
        this.onlyOnSale = true
        // this.filterCategory = null
      } else {
        this.onlyOnSale = false
      }

      // setPromotions
      if (this.$route.query.promotion) {
        this.filterPromotion = this.$route.query.promotion
      } else {
        this.filterPromotion = null
      }

      this.new = false
    },

    /**
     * Update data with products transition
     */
    updateData: function() {
      var self = this

      self.setData()
    },

    /**
     * Set filtered tags with a transition
     */
    transitionFilteredTags: function() {
      var self = this

      var tl = new TimelineLite()
      tl.pause()

      tl.staggerTo(
        $(this.$el)
          .find('.filters__item--tag')
          .reverse(),
        0.2,
        {
          alpha: 0,
          y: 30,
          ease: Power2.easeIn
        },
        0.02
      )

      tl.call(
        function() {
          $(self.$el)
            .find('.filters__list--tag')
            .css({ opacity: 0 })
          self.setFilteredTags()
        },
        null,
        null,
        '+=0.1'
      )

      tl.call(
        function() {
          $(self.$el)
            .find('.filters__list--tag')
            .css({ opacity: '' })

          TweenMax.staggerFromTo(
            $(self.$el).find('.filters__item--tag'),
            0.2,
            {
              alpha: 0,
              y: 0,
              x: -10
            },
            {
              alpha: 1,
              y: 0,
              x: 0,
              ease: Power2.easeOut
            },
            0.02
          )
        },
        null,
        null,
        '+=0.2'
      )

      tl.call(function() {
        tl.kill()

        tl = null
      })

      tl.play()
    },

    /**
     * Search input
     */
    searchInput: function(e) {
      if (this.searchValue === '') {
        this.searchProducts(true)
      }
    },

    /**
     * Search producsts
     */
    searchProducts: function(hideKeyboard = false) {
      var self = this

      if (!hideKeyboard) {
        // Hide keyboard
        setTimeout(function() {
          $('#osk-container:visible .osk-hide').click()
        }, 100)
      }

      // Call products transition with a callback
      this.transitionProducts(function() {
        self.searchString = self.searchValue
      })
    },

    /**
     * Set filtered tags without transition
     */
    setFilteredTags: function() {
      // Set column style
      if (this.showEmptyProduct) {
        this.columnFiltersStyle = 'collapsed'
        return
      }
      if (this.filteredTags.length === 0 && this.hideCategories === true) {
        this.columnFiltersStyle = 'collapsed'
      } else if (this.filteredTags.length > 0 && this.hideCategories === true) {
        this.columnFiltersStyle = 'small'
      } else {
        this.columnFiltersStyle = 'default'
      }
      // this.updateData()
    },

    /**
     * Sort products with transition
     * @param  {String} option
     */
    sortBy: function(option) {
      var self = this

      // Call products transition with a callback
      this.transitionProducts(function() {
        if (self.sortOption === option) {
          self.sortOption = null
        } else {
          self.sortOption = option
        }

        self.updateRoute()
      })
    },

    /**
     * Update route with params
     */
    updateRoute: function() {
      var params = {}

      if (this.filterCategory) {
        params.category = this.filterCategory
      }

      if (this.filterTags) {
        params.tags = this.filterTags
      }

      if (this.sortOption) {
        params.sort = this.sortOption
      }

      if (this.filterPromotion) {
        params.promotion = this.filterPromotion
      }

      if (this.onlyOnSale) {
        params.only_on_sale = this.onlyOnSale
      }
      console.log('This are the params', params)

      this.$router.replace({ query: params })
    },
    /**
     * This method redirect to a category
     */
    redirectToCategory(id) {
      if (id) {
        this.$router.push(`/products/${id}`)
      }
    }
  }
}
</script>

<style scoped lang="scss">
.hidden {
  display: none;
}
.screen--products {
  display: flex;
  align-content: stretch;
  align-items: stretch;
  flex-direction: row;
  justify-content: flex-start;
}

.message-generating {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  animation: alpha-pulse 2s linear infinite;
  transform: translate3d(0, -50%, 0);

  text-align: center;
}

.containerSortButtons {
  border: 2px solid rgba(19, 38, 52, 50%);
  border-radius: 10px;
  padding: 15px 7px;
}

.tagsTitle {
  margin: 0px;
  text-align: center;
  font-size: 15px;
  font-weight: bold;
  color: rgba(255, 255, 255, 0.35);
}

.center-tags {
  border: 2px solid rgba(3, 16, 52, 0%);
  border-radius: 10px;
  padding: 0px 7px;
}

.filters {
  position: relative;
  width: 440px;
  height: 100%;

  flex-grow: 0;
  flex-shrink: 0;
  overflow: hidden;
  transition: width 0.5s cubic-bezier(0.77, 0, 0.175, 1);

  &__search {
    position: absolute;
    top: 20px;
    right: 40px;
    left: 50px;

    z-index: 2;
  }

  &__scroller {
    position: absolute;
    top: 100px;
    left: 0;
    width: 100%;
    height: 100%;

    overflow-x: hidden;
    overflow-y: scroll;
    z-index: 2;
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
    position: relative;
    width: 100%;

    overflow: hidden;
    transition: height 0.3s ease;
    z-index: 2;

    &--icon {
      .filters__inner {
        padding-top: 20px;
      }
    }

    &--is-opened {
      .filters__list {
        max-height: none;
      }
    }

    &--collapsed {
      height: 0;
    }
  }

  &__inner {
    padding: 60px 0;
    position: relative;
  }

  &__separator {
    display: block;
    position: absolute;
    bottom: 0;
    left: 30px;
    width: 480px;
    height: 1px;

    background-color: rgba($white, 0.1);
    transform-origin: 0 0;
  }

  &__title {
    display: block;
    padding: 0 0 10px;
    margin: 0 0 0 50px;
    position: relative;

    font: 16px/1 var(--font-bold);
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
    display: flex;
    margin: 0;
    padding: 0 0 0 50px;
    max-height: 390px;

    flex-direction: row;
    flex-wrap: wrap;
    list-style: none;
    overflow: hidden;
  }

  &__item {
    margin: 1.43em 2.86em 0 -2.14em;
    padding: 1.43em 2.14em 1.29em;
    position: relative;

    transition: color 0.1s linear;

    color: rgba($white, 0.5);
    font: 0.7em/1.2 var(--font-semibold);
    letter-spacing: 0.1em;
    text-align: left;
    text-transform: uppercase;

    // > span {
    //   display: inline-block;
    //   margin: 0 0 0 -30px;
    //   padding: 20px 30px;
    //   position: relative;

    //   transition: color 0.1s linear;

    //   color: inherit;
    // }

    &:after {
      display: block;
      position: absolute;
      top: 50%;
      right: 0.63em;

      content: '\00d7';
      opacity: 0;
      transform: translate3d(0.63em, -50%, 0);
      transition: opacity 0.15s linear 0s,
        transform 0.15s cubic-bezier(0.55, 0.055, 0.675, 0.19) 0s;

      line-height: 1;
      font-family: var(--font-light);
      font-size: 1.14em;
    }

    &__icon {
      display: block;
      margin: 0 auto 4px;
      width: 100px;
      height: 100px;

      z-index: 2;
    }

    &__label {
      position: relative;

      z-index: 2;
    }

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background: rgba($white, 0);
      transition: background 0.1s linear;
      border-radius: 1.93em;
      z-index: 1;
    }

    &--icon {
      margin: 20px 0 0 30px;
      padding: 20px 30px 30px;
      width: calc(50% - 15px);

      font-size: 0.7em;
      text-align: center;
      // letter-spacing: 0.05em;

      // > span {
      //   padding: 20px 30px;
      //   width: 100%;
      // }

      &:nth-child(2n + 1) {
        margin-left: -30px;
      }

      &:after {
        top: auto;
        bottom: 0px;
        left: 0.71em;

        transform: translate3d(0, calc(-50% + 0.71em), 0);

        text-align: center;
      }
    }

    &--is-active {
      color: $white;

      &:after {
        opacity: 0.35;
        transform: translate3d(0, -50%, 0);
        transition: opacity 0.15s linear 0.1s,
          transform 0.15s cubic-bezier(0.215, 0.61, 0.355, 1) 0.1s;
      }

      .filters__item__background {
        background: rgba($white, 0.1);
      }
    }
  }

  &__toggle {
    display: inline-block;
    position: absolute;
    left: 50%;
    bottom: 0.45em;
    padding: 1.82em;

    transform: translate3d(-50%, 0, 0);

    color: rgba($white, 0.5);
    font: 0.55em/1 var(--font-bold);
    letter-spacing: 0.2em;
    text-transform: uppercase;

    &--is-opened {
      .filters__toggle__arrow {
        transform: rotateZ(180deg);
      }
    }

    &__text {
      display: inline-block;
    }

    &__arrow {
      position: relative;
      display: inline-block;
      width: 9px;
      height: 8px;

      &:before,
      &:after {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 2px;
        height: 6px;

        background: rgba($white, 0.3);
        border-radius: 25%;
        content: '';
        transform-origin: 50% 100%;
      }
      &:before {
        transform: translate3d(-50%, -50%, 0) rotateZ(-40deg);
      }
      &:after {
        transform: translate3d(-50%, -50%, 0) rotateZ(40deg);
      }
    }
  }

  &--small {
    width: 320px;
  }

  &--collapsed {
    width: 0;
  }
}

.shopify-hidden {
  width: 0;
  overflow: visible;
}

.shopify-search {
  width: 320px;
}

.sorts {
  display: flex;
  margin: 0 0 0 1rem;

  position: relative;
  height: 100%;

  flex-direction: column;
  flex-grow: 0;
  flex-shrink: 0;
  justify-content: center;
  z-index: 2;

  &__item {
    margin: 0.77em 0 0;
    width: 3.38em;
    height: 3.38em;

    background: rgba($white, 0.1);
    border-radius: 5px;

    color: rgba($white, 0.35);
    font: 0.65em/3.62em var(--font-semibold);
    letter-spacing: 0.1em;
    text-align: center;

    &:first-child {
      margin-top: 0;
    }

    &--az {
      // font-size: 0.6em;
    }

    &--is-active {
      color: $white;

      .sorts__arrow {
        opacity: 1;
      }
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

.grid-header {
  width: 100% !important;

  &__image {
    display: block;
    width: 100% !important;
    margin-right: 0 !important;
  }
}

.products-grid {
  margin: 0 0 0 -74px;
  padding: 60px 170px 0;
  position: relative;
  width: 1060px;
  height: 100%;

  flex-grow: 1;
  flex-shrink: 1;
  overflow-x: hidden;
  overflow-y: scroll;
  mask-image: linear-gradient(
    to bottom,
    transparent 0%,
    rgba(0, 0, 0, 1) 10%,
    rgba(0, 0, 0, 1) 90%,
    transparent 100%
  );
  mask-origin: padding-box;

  .products {
    .product-card {
      /deep/ .product-image {
        .promotin .text,
        .promotin .min-text {
          font-weight: 900 !important;
        }
      }
    }
  }

  &.grid-of-four {
    padding: 3em 1em 2em 4em;
    .products {
      width: 100%;
      justify-content: center;
      .product-card {
        padding-bottom: 200px;
        margin-right: 0em;
        &:nth-child(4n) {
          margin-right: 0em;
        }
        /deep/ .product-image {
          width: 230px !important;
          .text {
            // margin: auto 0px;
            font-weight: 900;
            font-size: 20px;
            line-height: 1.2em;
          }
          .min-text {
            font-size: 16px;
          }
          .min-sm-text {
            font-size: 12px;
          }
        }
        /deep/ .product-card {
          &__info {
            position: absolute;
            z-index: 2;
            top: 250px;
          }
        }
        &--large {
          &:nth-child(2n) {
            top: 0px;
          }
        }
      }
    }
  }
}

.no-results {
  position: absolute;
  top: 50%;
  left: 170px;
  right: 170px;

  transform: translate3d(0, -50%, 0);

  text-align: center;

  &__button {
    margin: 0.71em 0.71em 0;
    padding: 1.43em 1.43em 1.29em;
    position: relative;

    background: rgba($white, 0.1);
    border: 0;
    border-radius: 1.93em;

    color: $white;
    font: 0.7em/1.2 var(--font-semibold);
    letter-spacing: 0.1em;
    text-align: center;
    text-transform: uppercase;
    white-space: nowrap;
  }
}

.separate {
  margin-top: 35px;
}

.separate-container {
  margin-top: 75px;
}

.products {
  display: flex;
  margin: 0 auto;
  padding: 0;
  width: 720px;

  flex-direction: row;
  justify-content: space-between;
  flex-wrap: wrap;
  list-style: none;
}

.product-card {
  padding: 0 0 260px;

  &:nth-child(2n) {
    top: 230px;
  }

  &__info {
    position: absolute;
    top: 335px;
    left: 0;
    width: 100%;
  }

  &--large {
    &:nth-child(2n) {
      top: 230px;
    }
  }
}

.search-form {
  display: flex;
  align-items: center;
  flex-direction: row;
  justify-content: center;

  input {
    display: block;
    padding: 0 20px;
    width: calc(100% - 44px);
    background: none;
    border: 3px solid rgba($white, 0.1);
    border-radius: 10px;
    color: $white;
    font: 1em/54px var(--font-light);

    &:focus {
      border-color: $white;

      & + .search-form__button:after {
        border-color: white;
      }
    }

    &::placeholder {
      opacity: 0.2;

      color: $white;
      font: 1em/60px var(--font-light);
    }
  }

  &__button {
    margin: 0 0 0 -16px;
    position: relative;
    width: 60px;
    height: 60px;

    background: none;
    border: none;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1),
      opacity 0.2s linear;

    &:after {
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      border-color: transparent;
      border-style: solid;
      border-width: 3px 3px 3px 0;
      border-radius: 0 10px 10px 0;
      box-sizing: border-box;
      content: '';
    }

    img {
      display: block;
      margin: 0 auto;
      width: 20px;
      height: 20px;
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

      background: mix($shark, white, 90%);
      border-radius: 10px;
      transform: translate3d(-50%, 0, 0);
    }
  }
}
.on-sale-toggle {
  display: flex;
  padding: 1rem;
  flex-direction: column;
  align-items: center;
  text-align: center;
  .toggle {
    height: 3rem;
    width: 3rem;
    border-radius: 50%;
    position: absolute;
    top: 0;
    left: 0;
    transition: all 0.3s ease-in-out;
    &.active {
      background: var(--main-color);
      left: calc(100% - 3rem);
    }
    &:not(.active) {
      background: #313237;
    }
    &-rail {
      margin-bottom: 1rem;
      position: relative;
      width: 50%;
      height: 3rem;
      border-radius: 160px;
      background: rgba(0, 0, 0, 0.3);
    }

    &-tag {
      font: 16px/1 var(--font-bold);
      letter-spacing: 0.1em;
      text-transform: uppercase;
    }
  }
}

.single-col-search {
  display: flex;
  position: absolute;
  top: 1rem;
  left: 80px;
  z-index: 6;
  transition: width 0.3s ease-in-out;

  form {
    display: flex;
    position: relative;
    flex-direction: row;
    transition: width 0.3s ease-in-out;
    justify-content: start;
  }

  input {
    flex-grow: 0;
    padding: 1rem 0rem 1rem 60px;
    width: 60px;
    border: 3px solid rgba(white, 0);
    border-radius: 10px;
    color: $white;
    font: 1em var(--font-light);

    background-color: $charade !important;
    background-image: url('../assets/img/icon-search.svg') !important;
    background-repeat: no-repeat !important;
    background-position: 18px center !important;
    background-size: 24px 24px !important;

    transition: width 0.3s ease-in-out, border 0.3s ease-in-out,
      background-color 0.3s ease-in-out;
    // &:focus,
    &.osk-focused {
      width: 350px;
      padding-right: 1rem;
      background-color: rgba(0, 0, 0, 0.75) !important;
      border: 3px solid rgba(white, 0.1);
    }
  }

  button {
    display: none;
  }

  /*
  }*/
}

.single-col-search-collapsed {
  left: 16px;
}

.filters {
  &--single-col {
    width: 220px;
    overflow: visible;
    &.expand {
      width: 440px;
    }

    .filters {
      &__search {
        /*.search-form {
          justify-content: flex-start;
          input {
            transition: width 0.3s linear;
            &:focus {
              width: 300px;
            }
          }
        }*/
        display: none;
      }
      &__item {
        &--tag {
          margin: 0.75rem 0px;
          text-align: center;
        }
      }
      &__list {
        max-height: none;
        &--tag {
          justify-content: center;
          padding: 2rem;
        }
      }
      &__toggle {
        display: none;
      }
      &__item {
        &__icon {
          width: 100%;
          object-fit: contain;
        }
        margin-left: 0px;
        &--icon {
          width: calc(100% - 15px);
          &:nth-child(2n + 1) {
            margin-left: 0px;
          }
        }
      }
    }
  }
}

.loading {
  width: 5vw;
  height: 5vw;
  border: 4px solid rgba(0, 0, 0, 0.2);
  border-right-color: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  position: absolute;
  top: 50%;
  margin: 0px auto;
  left: 0;
  right: 0;

  animation: loading 1s linear infinite;
}

.header-container {
  width: 100% !important;
  position: relative;
  top: -40px;
}

.is-only-filter {
  margin-bottom: 100px;
}
</style>
