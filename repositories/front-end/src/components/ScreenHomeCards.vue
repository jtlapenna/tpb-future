<template>
  <div id="screen-home-cards" class="screen screen--home" style="opacity: 0;" v-bind:class="{
                  'shared-screen':
                    sharedScreenConfig === true,
                }" >
    <div v-if="isGeneratingIndex" class="message-generating">Index is being generated, please wait.</div>
    <div
      v-if="!isGeneratingIndex"
      v-bind:class="listClass"
      @scroll="handleScroll"
    >
      <div class="products">
        <component
          v-for="(product, index) in cardProducts"
          v-bind:key="index"
          v-bind:indexOrder="index + 1"
          v-bind:is="(product.status === 'outOfStock' ? componentBlank : componentCard)"
          v-bind:product="product"
          v-bind:layout="'full'"
          v-bind:sharedScreenConfig="sharedScreenConfig"
        ></component>
      </div>
      <!-- .products -->
    </div>
    <!-- .products-grid -->

    <ul class="links">
      <li
        v-for="(link, index) in $config.NAV"
        v-if="(!link.order || link.order > 0) && (link.path.indexOf('/products') > -1)"
        v-bind:key="index"
        class="link"
      >
        <router-link :to="{ path: link.path }" class="btn">
          <span class="btn__text">All {{ link.label }}</span>
          <span class="btn__background"></span>
        </router-link>
      </li>
    </ul>
    <div v-if="isActiveCartFeatureActivated" class="active-button-container">
      <active-cart-button v-bind:size="'small'"></active-cart-button>
    </div>
  </div>
</template>

<script>
import ProductCard from '@/components/ProductCard'
import ProductCardBlank from '@/components/ProductCardBlank'
import RedirectEvent from '../mixins/redirectEvent'
import { TimelineLite, Linear, Power2, Power3 } from 'gsap/all'
import ProductsRepo from '@/api/products/ProductsRepo'
import RFIDRepo from '@/api/rfid/RFIDRepo'
import $ from 'jquery'
import OfflineMixin from '@/mixins/offlineMixin'
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ScreenHomeCards',
  components: {
    ActiveCartButton,
    ProductCard,
    ProductCardBlank
  },
  mixins: [OfflineMixin, RedirectEvent],
  props: ['isGeneratingIndex', 'products', 'sharedScreenConfig', 'isActiveCartFeatureActivated'],
  computed: {
    listClass: function () {
      if (this.cardProducts.length < 7) {
        return 'products-no-fade'
      }
      if (this.reachedEndOfScroll) {
        return 'products-grid-start-fade'
      }
      return this.isScrolled ? 'products-grid-fade' : 'products-grid'
    },
    cardProducts: function () {
      var self = this
      let tempProducts = this.rfidProducts.map(function (productId) {
        if (productId) {
          let product = self.products.find(function (product) {
            return product.id === productId
          })

          if (product) {
            return product
          } else {
            let product = {}
            product.status = 'outOfStock'
            return product
          }
        } else {
          let product = {}
          product.status = 'outOfStock'
          return product
        }
      })
      return tempProducts
    }
  },
  data () {
    return {
      componentBlank: ProductCardBlank,
      componentCard: ProductCard,
      rfidProducts: [],
      isScrolled: false,
      reachedEndOfScroll: false
    }
  },
  watch: {
    isGeneratingIndex (oldval, newVal) {
      this.$nextTick(() => {
        this.fetchData()
      })
    }
  },
  created: function () {
    if (!this.isGeneratingIndex) {
      this.fetchData()
    }

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  destroyed: function () {
    // Events
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    handleScroll: function (e) {
      console.log(e)
      console.log(e.target.scrollWidth + ' - ' + e.target.scrollLeft + ' = ' + (e.target.scrollWidth - e.target.scrollLeft))
      console.log((e.target.scrollWidth - e.target.scrollLeft) + '===' + e.target.clientWidth)
      this.isScrolled = e.target.scrollLeft > 0
      this.reachedEndOfScroll = (e.target.scrollWidth - e.target.scrollLeft) === e.target.clientWidth
    },
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Selectors
      var self = this
      var container = $(this.$el)
      var products = container.find('.product-card')
      var btns = container.find('.btn')

      // Before animation
      container.css({ opacity: '' })

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

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

      tl.from(
        container.find('.active-button-container'),
        0.5,
        {
          alpha: 0
        },
        0
      )

      var start = 0.3
      products.each(function () {
        var product = $(this)

        tl.from(
          product.add(product.find('.product-image')),
          0.8,
          {
            alpha: 0,
            scale: 0.8,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          start
        )

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
          start + 0.4
        )

        start += 0.1

        product = null
      })

      start = 0.7
      btns.each(function () {
        var btn = $(this)

        tl.from(
          btn.find('.btn__background'),
          0.5,
          {
            width: 0,
            clearProps: 'width',
            ease: Power2.easeInOut
          },
          start
        )

        tl.fromTo(
          btn.find('.btn__text'),
          0.5,
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
          start + 0.3
        )

        btn += 0.1

        btn = null
      })

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

        tl.kill()

        tl = null
        container = null
        products = null
        btns = null
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

      // Before animation
      container.find('.btn').css({ transition: 'none' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

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

      tl.staggerTo(
        container.find('.btn').reverse(),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn,
          overwrite: 'all'
        },
        0.1,
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

      tl.call(function () {
        tl.kill()

        tl = null
        container = null
        products = null

        done()
      })

      tl.play()
    },

    /**
     * Fetch data
     */
    fetchData: function () {
      var self = this
      // Get rfids products
      RFIDRepo.list().then(async (rfids) => {
        console.log('REFID FROM REPO', rfids)
        rfids.filter((rfidEntity) => rfidEntity.rfid_entity_type === 'KioskProduct').forEach(async function (rfidProduct) {
          self.rfidProducts.push(rfidProduct.product_id)
        })
      })
    },
    async updateRfidProducts () {
      // let self =  this
      await Promise.all(this.rfidProducts.map(async (rfid) => {
        return new Promise(async (resolve, reject) => {
          try {
            let product = await ProductsRepo.remote.show(rfid).then((response) => (response.data.product))
            if (product.stock > 0) {
              await ProductsRepo.local.save(product)
              console.log(`RFID PRODUCT: ${rfid} UPDATED`)
            } else {
              await ProductsRepo.local.delete(product)
              console.log(`RFID PRODUCT: ${rfid} REMOVED`)
            }
            resolve(product)
          } catch (e) {
            resolve(null)
            console.error(e)
          }
        })
      }))
    },

    /**
   * Updaes RFID product to id,
   */
    updateProduct (id) {
      return new Promise((resolve, reject) => {
        ProductsRepo.show(id).subscribe(product => {
          if (product) {
            resolve(product)
          }
        })
      })
    }
  }
}
</script>

<style scoped lang="scss">
  .screen--home {
    left: 0;

    background: transparent !important;
  }

  .shared-screen{
    position: static !important;
    width: 100%;
    height: 100%;
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

  .products {
    display: flex;
    padding: 0px 40px 0px 40px ;
    flex-direction: row;
    flex-wrap: nowrap;
    justify-content: start;
    height: 90%;
    width: 100%;
    &:before,&:after {
      display: block;
      width: 0px;
      height: 460px;
      content: "";
      -ms-flex-positive: 0;
      flex-grow: 0;
      -ms-flex-negative: 0;
      flex-shrink: 0;
    }
    &:after {
      width:40px;
    }
    &-grid{
        mask-image: linear-gradient(to right, transparent 0%, rgba(0, 0, 0, 1.0) 0%, rgba(0, 0, 0, 1.0) 90%, transparent 100%);
        padding:40px 0px calc(85px + 2em);
        overflow-x: scroll;
        overflow-y: hidden;
        height: 100%;
        display: flex;
        justify-content:start;
        align-items: center;
    }

      &-no-fade{
        mask-image: linear-gradient(to right, transparent 0%, rgba(0, 0, 0, 1.0) 0%, rgba(0, 0, 0, 1.0) 100%, transparent 100%);
        padding:40px 0px calc(85px + 2em);
        overflow-x: scroll;
        overflow-y: hidden;
        height: 100%;
        display: flex;
        justify-content:right;
        align-items: center;
    }

     &-grid-fade{
        mask-image: linear-gradient(to right, transparent 0%, rgba(0, 0, 0, 1.0) 10%, rgba(0, 0, 0, 1.0) 90%, transparent 100%);
        padding:40px 0px calc(85px + 2em);
        overflow-x: scroll;
        overflow-y: hidden;
        height: 100%;
        display: flex;
        justify-content:start;
        align-items: center;
    }

    &-grid-start-fade{
       mask-image: linear-gradient(to right, transparent 0%, rgba(0, 0, 0, 1.0) 10%, rgba(0, 0, 0, 1.0) 100%, transparent 100%);
        padding:40px 0px calc(85px + 2em);
        overflow-x: scroll;
        overflow-y: hidden;
        height: 100%;
        display: flex;
        justify-content:start;
        align-items: center;
    }
  }

  .product-card {
    margin: 0 40px 0 0;
    display:flex;
    flex-grow: 1;
    flex: 1 1 0px;
    width:100%;
    min-width: calc(15.38% - 40px );
    animation: card-flip 6s ease-in-out infinite;

    /deep/  .product-image{
        width: 100% !important;
        max-width: 170px!important;
        min-width: 100px!important;
        .promotion{
          .text{
            font-size: 16px;
          }
          .min-sm-text{
            font-size: 14px;
          }
           .min-xs-text{
            font-size: 12px;
          }
        }
    }
    /deep/  .product-card__name{
      margin-top: 35px;
      max-height: 2.2em;
      overflow: hidden;
      font-size: 1.2vw !important;
      line-height: 1.1;
      text-align: center;
    }

    /deep/ .graph--circle--1{
      width: 100% !important;
      min-width: 4.5em !important;
    }

    @for $i from 1 through 10 {
      &:nth-child(#{$i}) {
        animation-delay: $i * 0.2s;
      }
    }

    &:last-child{
      margin-right:0px!important;
    }
    /*&:after {
      display: block;
      position: relative;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      backface-visibility: hidden;
      background: $ebonyclay;
      border-radius: inherit;
      content: '';
      opacity: 1;
      transform: rotateY(180deg);
      z-index: 4;
    }*/

    &--blank {
      animation: none;
    }
  }

  .links {
    display: flex;
    margin: 0;
    padding: 0;
    position: absolute;
    right: 320px;
    bottom: calc( 85px - 1em );
    left: 320px;

    align-items: center;
    flex-direction: row;
    justify-content: center;
    list-style-type: none;

    @at-root .app--tablet & {
      // bottom: 50px;
    }
  }

  .link {
    margin: 0 1em;
    padding: 0;
  }

  .btn {
    display: inline-block;
    padding: 0 2em;
    position: relative;
    min-width: 12.5em;
    height: 4em;

    background: transparent;
    border: none;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1), opacity 0.2s linear;

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
  }

  /deep/ .product-image__waves {
    display: none;
  }

  .shared-screen{
  .products-grid{
    .products{
      padding-left: 20px;
      padding-right: 20px;
      }
    }

  }
  .active-button-container {
    position: absolute;
    bottom: 1.5rem;
    left: 1.5rem;
  }

</style>
