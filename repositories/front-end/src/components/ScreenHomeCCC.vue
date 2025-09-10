<template>
  <div class="screen-home-cc">
    <div class="logo">
      <img :src="storeLogo" v-if="storeLogo" alt="" />

      <button class="btn" v-on:click="redirect('Products', '/products')">
        <span class="text">
          All Products
        </span>
      </button>
    </div>
    <div class="product-sales">
      <h3>{{homeScreenTitle}}</h3>
      <div class="processing"  v-if="isGeneratingIndex" style="width:100%; height:100%">
          <div class="message-generating">
            Index is being generated, please wait.
          </div>
      </div>
      <div class="products-grid "  v-bind:class="{ 'wrap':  currentProductsPage.length> 4, 'wrap-on-2' : currentProductsPage.length == 4 }">
        <div
          class="product-card-container "
          v-for="(product, index) in currentProductsPage"
          :style="{height: currentProductsPage.length == 4 ? '100%':  '50%', width: currentProductsPage.length == 4 ? '' :  '33%' }"
          v-bind:key="product.id"
        >
          <product-card-sale v-bind:product="product" v-bind:data-index="index">
          </product-card-sale>
        </div>

      </div>

        <div class="products-grid__pages" v-if="pages > 1">
          <div v-for=" index in pages "  @click="goToPage(index)" :key='index' class="page_selector" :class="{'active': page+1==index}" >
          </div>
        </div>
    </div>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import ProductCardSale from '@/components/ProductCardSale'
import RedirectEvent from '../mixins/redirectEvent'
import { TimelineLite, Power2, Power3 } from 'gsap/all'
import $ from 'jquery'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  components: {
    ActiveCartButton,
    ProductCardSale
  },
  props: ['products', 'promotions', 'isGeneratingIndex', 'isActiveCartFeatureActivated'],
  mixins: [RedirectEvent],
  data: () => {
    return {
      page: 0,
      interval: null,
      storeLogo: null,
      hide: false,
      homeScreenTitle: null
    }
  },

  created () {
    this.storeLogo =
      this.$config.STORE_LOGO === '/static/img/default-store-logo.png'
        ? '/static/img/default-store-logo-800-800.png'
        : this.$config.STORE_LOGO
    this.homeScreenTitle = this.$config.HOME_SCREEN_TITLE
    console.log(this.$config.ON_SALE_CATEGORY_ID)
    this.$nextTick(this.transitionEnter)
    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  watch: {
    isGeneratingIndex: function (val) {
      let self = this
      if (!self.isGeneratingIndex && this.interval == null) {
        self.setPaginationInterval()
      }
    },
    hide: function (val) {
      /* console.log("hiding ?", val ? "yes" : "NO");
      let el = this;
      if (val) {
        console.log("animate out");
      } else {
        console.log("animate out");
      } */
    },
    currentProductsPage: function (value) {
      this.$nextTick(function () {
        let cards = $('.product-card-container')
        // console.log(cards)
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
    }
  },

  destroyed: function () {
    // Events
    clearInterval(this.interval)
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    setPaginationInterval () {
      if (this.$config.PAGINATION_TIME && this.$config.PAGINATION_TIME > 0) {
        if (this.totalProducts > 6) {
          this.interval = setInterval(() => {
            // console.log('ANIMATING OUT')
            this.animateCardsOut()
            setTimeout(() => {
              this.paginatePromotions()
            }, 1000)
          }, this.$config.PAGINATION_TIME * 1000)
        }
      }
    },

    goToPage (page) {
      console.log(this.page, page - 1)
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
    paginatePromotions () {
      // console.table(this.productsWithSales());
      if (this.page < this.pages - 1) {
        this.page++
      } else {
        this.page = 0
      }
    },
    transitionEnter () {
      this.animateLayout()
      if (!this.isGeneratingIndex) {
        setTimeout(() => {
          this.setPaginationInterval()
        }, 700)
      }
    },
    animateLayout () {
      let container = $('.screen-home-cc')
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

      tl.from(
        container.find('.active-button-container'),
        0.5,
        {
          alpha: 0
        },
        0
      )

      tl.from(title, 0.5, {
        y: 30,
        opacity: 0,
        clearProps: 'transform, opacity',
        ease: Power3.easeOut
      })

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
    onTransitionLeave (el, done) {
      let container = $('.screen-home-cc')
      let logo = $('.logo *')
      let title = $('h3')
      let cards = $('.card-container')
      // let cards = $(".card");
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
      } else {
        console.log('ITS NOT GENRATING INDEX')
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

    animateCard (type, tl) {
      tl.pause()
      if (type === 'in') {
      } else {
      }
    },

    animateCardsOut () {
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
    animateCardsIn () {
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

      /* tl.staggerTo(
        cards,
        0.5,
        {
          transform: "rotateY(-10deg)",
          ease: "ease-in-out",
          clearProps: "transform, opacity",
          yoyo: true,
          repeat: 1
        },
        0.05
      ); */
    },

    productsWithSales () {
      let p = []
      if (this.$config && this.$config.ON_SALE_CATEGORY_ID !== null) {
        p = this.products.filter(
          x =>
            x.catalog_category.id === this.$config.ON_SALE_CATEGORY_ID &&
            x.store_product_promotions.length > 0
        )
      } else {
        p = this.products.filter(x => x.store_product_promotions.length > 0)
      }

      return p
    }
  },
  computed: {
    currentProductsPage () {
      let d = this.productsWithSales()
      return d.splice(this.page * 6, 6)
    },

    pages () {
      return Math.ceil(this.productsWithSales().length / 6)
    },
    totalProducts () {
      return this.productsWithSales().length
    }
  }
}
</script>

<style lang="scss" scoped>
@keyframes fadeIn {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}

.screen-home-cc {
  width: 100vw;
  display: flex;
  flex-direction: row;
  justify-content: center;
  height: 100vh;

  background: rgba($bluecharcoal, 0.5);

  .product-sales {
    width: 60%;
    height: 100%;
    position: relative;
    padding: 3em 2em 3rem;
    display: flex;
    flex-direction: column;
    h3 {
      text-align: center;
      margin-top: 0px;
      padding-bottom: 1rem;
      margin-bottom: 0px;
      font: 2em var(--font-light);
    }
  }

  .logo {
    width: 40%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;

    img {
      width: 50%;
      margin-bottom: 3rem;
    }
  }

  .btn {
    border-radius: 100px;
    padding: 20px 30px;
    font: 1em var(--font-bold);
    color: white;
    background-color: var(--main-color);
    letter-spacing: 0.1em;

    //font-size: em;
  }

  .products {
    &-grid {
      position: relative;
      display: flex;
      flex-direction: row;
      flex-wrap: nowrap;
      align-items: center;
      justify-content: center;
      height: 100%;
      width: 100%;
      transition: all 0.3s ease-in-out;
      &.wrap {
        flex-wrap: wrap;
      }
      &.wrap-on-2 {
        display: grid;
        grid-template-columns: 33% 33%;
        /*&div::nth-child(2n) {
          flex-basis: 100%;
        }*/
      }
      &.hidden {
        opacity: 0;
      }
      &__pages {
        position: absolute;
        display: flex;
        width: 100%;
        left: 0px;
        justify-content: center;
        align-items: center;
        padding: 1rem 1.5rem;
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
          margin-bottom: auto;
          margin-right: 0.5rem;
          border-radius: 50%;
          background: rgba($black, 0.1);

          transition: all 0.3s ease-in-out;
          &.active {
            background: rgba($white, 0.1);
          }
          &:last-child {
            margin-right: 0rem;
          }
        }
      }
      //flex: 1;
      //flex-grow: 0;
      .product-card-container {
        // width: 33%;
        height: 49.99%;
        padding: 1rem;

        /*&:nth-child(3n){
                    padding-right: 0rem !important;
                }*/
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
    widows: 100%;
    margin: auto 0px;
    animation: alpha-pulse 2s linear infinite;
    text-align: center;
  }
}

.flipCard {
  animation: flip 0.3s ease-in-out;
}

@keyframes flip {
  0% {
    transform: none;
  }
  50% {
    transform: perspective(100em) rotateY(-10deg);
  }
  100% {
    transform: none;
  }
}

.active-button-container {
  position: absolute;
  bottom: 1.5rem;
  left: 1.5rem;
}

</style>
