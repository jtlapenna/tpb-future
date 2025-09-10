<template>
  <div class="screen-menu-board">
    <div class="product-sales">
      <div class="product-sales-header">
        <h3 class="product-sales-title">{{ categoriesKeys[currentCategory] }}</h3>
      </div>
      <div class="product-sales-content">
        <div class="processing" v-if="isGeneratingIndex" style="width: 100%; height: 100%">
          <div class="message-generating">
            Index is being generated, please wait.
          </div>
        </div>
        <div v-else :class="currentProductsPage.first.length + currentProductsPage.second.length <= 3 ? 'products-grid-max' : 'products-grid'">
          <div class="top">
            <product-card-menu-board
              v-bind:product="product"
              v-bind:data-index="index"
              v-for="(product, index) in currentProductsPage.first"
              v-bind:key="product.id"
              class="product-card-container"
            >
            </product-card-menu-board>
          </div>
          <div class="bottom">
            <product-card-menu-board
              v-bind:product="product"
              v-bind:data-index="index"
              v-for="(product, index) in currentProductsPage.second"
              v-bind:key="product.id"
              class="product-card-container"
            >
            </product-card-menu-board>
          </div>
        </div>
      </div>
      <div class="product-sales-footer">
        <div class="products-grid__pages" >
          <div v-for=" index in pages "  :key='index' class="page_selector" :class="{ 'active': page + 1 == index }">
          </div>
        </div>
      </div>
    </div>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>
<script>
import ProductCardMenuBoard from '@/components/ProductCardMenuBoard'
import RedirectEvent from '../mixins/redirectEvent'
import { TimelineLite, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'
export default {
  components: {
    ActiveCartButton,
    ProductCardMenuBoard
  },
  props: ['products', 'promotions', 'isGeneratingIndex', 'isActiveCartFeatureActivated'],
  mixins: [RedirectEvent],
  data: () => {
    return {
      page: 0,
      currentCategory: 0,
      interval: null,
      hide: false,
      homeScreenTitle: null,
      productsPerPage: 10,
      productsLoaded: [],
      orderCategories: [],
      currentPaginationTime: 0
    }
  },
  created() {
    this.homeScreenTitle = this.$config.HOME_SCREEN_TITLE
    this.$nextTick(this.transitionEnter)
    this.$parent.$on('transition-leave', this.onTransitionLeave)
    this.setSelectedCategories()
  },
  watch: {
    isGeneratingIndex: function(val) {
      let self = this
      if (!self.isGeneratingIndex && this.interval == null) {
        self.setPaginationInterval()
      }
    },
    categoryAndPage: function() {
      this.$nextTick(function () {
        let cards = $('.product-card-container')
        let tl = new TimelineLite()
        tl.staggerFrom(
          cards,
          0.3,
          {
            y: -20,
            alpha: 0,
            clearProps: 'transform, opacity',
            ease: Power2.easeIn
          },
          0.05
        )
        tl.play()
        tl = null
      })
    },
    products: function(value) {
      if (value.length !== this.productsLoaded.length) {
        this.productsLoaded = value.sort((prevProduct, nextProduct) => {
          return prevProduct.id - nextProduct.id
        })
      }
    },
    totalCategories: function() {
      let self = this
      if (!self.isGeneratingIndex && this.interval == null) {
        self.setPaginationInterval()
      }
    }
  },
  destroyed: function () {
    // Events
    clearInterval(this.interval)
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    setPaginationInterval(newPaginationTime = 0) {
      if ((this.$config.PAGINATION_TIME && this.$config.PAGINATION_TIME > 0) || newPaginationTime > 0) {
        if (this.totalProducts > 10 || this.totalCategories > 1) {
          this.interval = setInterval(() => {
            this.animateCardsOut()
            setTimeout(() => {
              this.paginateProducts()
            }, 1000)
          }, (newPaginationTime > 0 ? newPaginationTime : this.$config.PAGINATION_TIME) * 1000)
        }
      }
    },
    goToPage(page) {
      if (this.page !== page - 1) {
        clearInterval(this.interval)
        this.animateCardsOut()
        this.hide = page - 1 !== this.page
        setTimeout(() => {
          this.page = page - 1
          this.hide = false
          this.setPaginationInterval()
        }, 500)
      }
    },
    paginateProducts() {
      const nextPage = this.page + 1
      if (nextPage < this.pages) {
        this.page++
      } else {
        const nextCategory = this.currentCategory + 1
        if (nextCategory < this.totalCategories) {
          this.currentCategory++
        } else {
          this.currentCategory = 0
        }
        this.page = 0
      }
    },
    transitionEnter() {
      this.animateLayout()
      if (!this.isGeneratingIndex) {
        setTimeout(() => {
          this.setPaginationInterval()
        }, 700)
      }
    },
    animateLayout() {
      let container = $('.screen-menu-board')
      let title = $('h3')
      let cards = $('.product-card-container')
      let tl = new TimelineLite()
      tl.pause()
      if (container.find('.message-generating').length === 1) {
        tl.from(
          $('.processing'),
          0.5,
          {
            alpha: 0
          },
          0
        )
      }
      tl.from(title, 0.5, {
        y: 30,
        opacity: 0,
        clearProps: 'transform, opacity',
        ease: Power3.easeOut
      })
      tl.from(
        container.find('.active-button-container'),
        0.5,
        {
          alpha: 0
        },
        0
      )
      tl.from(
        $('.logo img'),
        0.5,
        {
          y: 30,
          opacity: 0,
          ease: Power3.easeOut
        },
        0.1,
        0.5
      )
      tl.staggerFrom(
        cards,
        0.3,
        {
          y: -20,
          alpha: 0,
          clearProps: 'transform, opacity',
          ease: Power2.easeIn
        },
        0.1,
        0.25
      )
      tl.staggerTo(
        cards,
        0.5,
        {
          transform: 'rotateY(-10deg)',
          ease: 'ease-in-out',
          yoyo: true,
          repeat: 1
        },
        0.1
      )
      tl.from(
        $('.logo .btn .text'),
        0.5,
        {
          alpha: 0,
          ease: Power2.easeInOut
        },
        0,
        1.5
      )
      tl.from(
        $('.logo .btn'),
        0.5,
        {
          scaleX: 0,
          ease: Power2.easeInOut
        },
        0,
        1.5
      )
      tl.play()
    },
    onTransitionLeave(el, done) {
      let container = $('.screen-menu-board')
      let logo = $('.logo *')
      let title = $('h3')
      let cards = $('.card-container')
      this.$root.$emit('block-pointer', false)
      let tl = new TimelineLite()
      if (container.find('.message-generating').length === 1) {
        tl.to(
          $('.processing'),
          0.5,
          {
            alpha: 0
          },
          0
        )
      }
      tl.staggerTo(
        logo,
        0.5,
        {
          y: 30,
          alpha: 0,
          ease: Power3.easeOut
        },
        0,
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
        title,
        0.5,
        {
          y: 20,
          opacity: 0,
          ease: Power3.easeOut
        },
        0,
        0
      )
      if ($('.products-grid__pages')) {
        tl.to(
          '.products-grid__pages',
          0.5,
          {
            y: 20,
            opacity: 0,
            ease: Power3.easeOut
          },
          0.15,
          0
        )
      }
      tl.staggerTo(
        cards,
        0.5,
        {
          alpha: 0,
          y: 20
        },
        -0.05,
        0
      )
      tl.call(function () {
        tl.kill()
        tl = null
        done()
      })
      tl.play()
    },
    animateCard(type, tl) {
      tl.pause()
      if (type === 'in') {
      } else {
      }
    },
    animateCardsOut() {
      let cards = $('.product-card-container')
      let tl = new TimelineLite()
      tl.staggerTo(
        cards,
        0.3,
        {
          y: -20,
          alpha: 0,
          ease: Power2.easeIn
        },
        0.05
      )
      tl.call(function () {
        tl.kill()
        tl = null
        cards = null
      })
      tl.play()
    },
    animateCardsIn() {
      let cards = $('.product-card-container')
      let tl = new TimelineLite()
      tl.staggerFrom(
        cards,
        1,
        {
          y: -20,
          alpha: 0,
          ease: Power2.easeIn
        },
        1.5
      )
      tl.call(function () {
        tl.kill()
        tl = null
        cards = null
      })
      tl.play()
    },
    matchedProducts() {
      let p = []
      if (this.$config && this.orderCategories !== null && this.orderCategories.length > 0) {
        const categoriesId = this.orderCategories.map(categories => {
          return categories.id
        })
        p = this.products.filter(x => categoriesId.includes(x.catalog_category.id))
      } else {
        p = this.products
      }
      return p
    },
    setSelectedCategories() {
      try {
        const kioskConfigFromLocalStorage = JSON.parse(localStorage.getItem('kiosk_config'))
        this.orderCategories = kioskConfigFromLocalStorage.MENU_BOARDS_CATEGORY_ID.sort((a, b) => a.order - b.order)
        if (this.currentPaginationTime !== kioskConfigFromLocalStorage.PAGINATION_TIME) {
          clearInterval(this.interval)
          this.setPaginationInterval(kioskConfigFromLocalStorage.PAGINATION_TIME)
        }
      } catch (error) {
        console.log(error)
      }
      setTimeout(() => {
        this.setSelectedCategories()
      }, (60 * 1000) * 3)
    }
  },
  computed: {
    currentProductsPage() {
      if (Object.keys(this.productsGroupedByCategory).length === 0) {
        return []
      }
      let d = [...this.productsGroupedByCategory[this.categoriesKeys[this.currentCategory]].products]
      const products = d.splice(this.page * 10, 10)
      const currentFirstRow = []
      const currentSecondRow = []
      products.forEach((item, index) => {
        if (products.length > 3 && products.length % 2 === 0) {
          if (index < products.length / 2) {
            currentFirstRow.push(item)
          } else {
            currentSecondRow.push(item)
          }
        } else if (products.length > 3 && products.length % 2 !== 0) {
          if (index < Math.ceil(products.length / 2)) {
            currentFirstRow.push(item)
          } else {
            currentSecondRow.push(item)
          }
        } else {
          currentFirstRow.push(item)
        }
      })
      const arrayNew = {
        first: [...currentFirstRow],
        second: [...currentSecondRow]
      }
      return arrayNew
    },
    pages () {
      if (Object.keys(this.productsGroupedByCategory).length === 0 || !this.productsGroupedByCategory[this.categoriesKeys[this.currentCategory]]) {
        return 0
      }
      return Math.ceil(this.productsGroupedByCategory[this.categoriesKeys[this.currentCategory]].products.length / 10)
    },
    totalCategories () {
      return this.categoriesKeys.length
    },
    totalProducts () {
      return this.matchedProducts().length
    },
    selectedCategories() {
      let categories = []
      if (this.$config && this.orderCategories !== null && this.orderCategories.length > 0) {
        categories = this.orderCategories
      } else {
        categories = this.productsLoaded.reduce((categories, product) => {
          if (categories.findIndex((category) => category.id === product.catalog_category.id) === -1) {
            categories.push(product.catalog_category)
          }
          return categories
        }, [])
      }
      return categories
    },
    productsGroupedByCategory() {
      return this.selectedCategories.reduce((categories, category) => {
        categories[category.name] = { products: [], pages: 0 }
        categories[category.name].products = this.productsLoaded.filter(product => product.catalog_category.id === category.id)
        categories[category.name].pages = Math.ceil(categories[category.name].products.length / 10)
        return categories
      }, {})
    },
    categoriesKeys() {
      return Object.keys(this.productsGroupedByCategory)
    },
    categoryAndPage() {
      return `${this.currentCategory}|${this.page}`
    }
  }
}
</script>
<style scoped lang="scss">
@keyframes fadeIn {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}
.screen-menu-board {
  width: 100vw;
  display: flex;
  flex-direction: row;
  justify-content: center;
  height: 100vh;
  background: rgba($bluecharcoal, 0.5);
  .product-sales {
    width: 100vw;
    height: 100vh;
    position: relative;
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: auto 1fr auto;
    h3 {
      text-align: center;
      text-transform: uppercase;
      margin-top: 0;
      margin-bottom: 0;
      font: 52px var(--font-light);
      padding: 8px 0;
    }
    .product-sales-content {
      display: flex;
      justify-content: center;
      height: 100%;
      width: 100vw;
      padding: 0 1rem;
    }
  }
  .btn {
    border-radius: 100px;
    padding: 20px 30px;
    font: 1em var(--font-bold);
    color: white;
    background-color: var(--main-color);
    letter-spacing: 0.1em;
  }
  .products {
    &-grid {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-rows: repeat(auto-fit, 1fr);
      gap: 1rem;
      height: 100%;
      width: 100%;
      transition: all 0.3s ease-in-out;
      &__pages {
        display: flex;
        width: 100%;
        left: 0px;
        justify-content: center;
        align-items: center;
        z-index: 200;
        width: 100%;
        bottom: 0px;
        margin: 0px auto;
        top: 0px;
        padding: 16px 0;
        .page_selector {
          border: 1px solid rgba($white, 0.1);
          display: inline-block;
          height: 24px;
          width: 24px;
          margin-right: 0.5rem;
          border-radius: 50%;
          background: rgba($black, 0.1);
          transition: all 0.3s ease-in-out;
          &.active {
            background-color: rgba($white, 0.1);
          }
          &:last-child {
            margin-right: 0rem;
          }
        }
      }
      .top,
      .bottom {
        display: grid;
        grid-template-rows: 1fr;
        grid-template-columns: repeat(auto-fit, 364.8px);
        gap: 1rem;
        justify-content: center;
      }
    }
    &-grid-max {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-rows: repeat(1, 433px);
      width: 100%;
      height: 100%;
      align-content: center;
      .top {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(364.8px, 364.8px));
        justify-content: center;
        gap: 1rem;
      }
      .bottom {
        display: none;
      }
      &__pages {
        display: flex;
        width: 100%;
        left: 0px;
        justify-content: center;
        align-items: center;
        z-index: 200;
        width: 100%;
        bottom: 0px;
        margin: 0px auto;
        .page_selector {
          border: 1px solid rgba($white, 0.1);
          display: inline-block;
          height: 24px;
          width: 24px;
          margin-top: auto;
          margin-right: 0.5rem;
          border-radius: 50%;
          background: rgba($black, 0.1);
          transition: all 0.3s ease-in-out;
          &.active {
            background-color: rgba($white, 0.1);
          }
          &:last-child {
            margin-right: 0rem;
          }
        }
      }
    }
  }
  .processing {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .message-generating {
    windows: 100%;
    margin: auto 0px;
    animation: alpha-pulse 2s linear infinite;
    text-align: center;
  }
}
@media screen and (min-width: 2560px) {
  .screen-menu-board {
    .product-sales {
      h3 {
        font-size: 104px;
        padding: 16px 0;
      }
    }
    .products {
      &-grid {
        gap: 2rem;
        .top,
        .bottom {
          grid-template-columns: repeat(auto-fit, 729.6px);
          gap: 2rem;
        }
        &__pages {
          padding: 2rem 0;
          .page_selector {
            height: 48px;
            width: 48px;
          }
        }
      }
      &-grid-max {
        grid-template-rows: repeat(1, 912px);
        .top {
          grid-template-columns: repeat(auto-fit, 729.6px);
          gap: 2rem;
        }
      }
    }
    .message-generating {
      font: 40px var(--font-light);
    }
  }
}
.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}
</style>
