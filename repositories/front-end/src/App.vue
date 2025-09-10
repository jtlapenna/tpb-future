<template>
  <div v-on:click="clickHandler" v-on:touchstart="onTouchStart" v-on:touchend="onTouchEnd" v-touch:swipe="swipeHandler"
    v-bind:class="[
      { 'hide-cursor': hideCursor },
      'app--' + $config.KIOSK_MODE,
      'app--' + $config.SCREEN_TYPE
    ]" id="app" class="app">
    <CoolLightBox :items="images" :index="indexImg" :effect="'fade'" :gallery="false" :slideshow="false"
      :enableScrollLock="true" @close="indexImg = null">
    </CoolLightBox>

    <div v-if="overlayMaskReady" class="app-background">
      <video v-if="$config.BACKGROUND.indexOf('.mp4') !== -1" v-bind:src="$config.BACKGROUND"
        class="app-background__media" autoplay loop></video>

      <img v-if="$config.BACKGROUND.indexOf('.mp4') === -1" v-bind:src="$config.BACKGROUND"
        class="app-background__media" />
    </div>
    <!-- .app-background -->

    <div v-if="overlayMaskReady" v-bind:class="{
        'view-container--with-mask': showBackgroundMask(),
        'view-container--with-backgroun-on-top': isBackGroundvisible,
        'disabled-overlay': isMaskDisabled
      }" class="view-container">
      <the-sidebar v-bind:cart="cart" v-bind:cartTotal="cartTotal" v-if="sidebarShow" />

      <the-brand-slideshow v-if="$config.KIOSK_MODE === 'brand' && $route.name !== 'home'"
        ref="brandSlideshow"></the-brand-slideshow>

      <div v-if="$config.LICENSE_NUMBER" class="license-number">
        License number:
        {{ $config.LICENSE_NUMBER }}
      </div>

      <div ng-click v-bind:class="{ 'is-offline': isOffline, glowing: isGeneratingIndex }" class="copyright">
        Powered by
        <img v-on:touchstart="logoHold" v-on:touchend="logoRelease" src="/static/img/logo-tpb.png"
          class="copyright__logo" />
      </div>

      <transition v-on:enter="onTransitionEnter" v-on:leave="onTransitionLeave" v-bind:css="false" mode="out-in">
        <router-view v-bind:cart="cart" v-bind:cartTotal="cartTotal" v-bind:categories="categories"
          v-bind:featuredProductsModal="featuredProductsModal" v-bind:isOffline="isOffline"
          v-bind:isGeneratingIndex="isGeneratingIndex" v-bind:products="products" v-bind:brands="brands"
          v-bind:tags="tags" v-bind:featuredTags="featuredTags" v-bind:featuredProductsList="featuredProductsList"
          v-bind:articles="articles" v-bind:tagsPerCategories="tagsPerCategories"
          v-bind:spotlightSelected="spotlightSelected" :discountCode="discountCode" @codeChange="discountCode = $event"
          ref="routerView" />
      </transition>
    </div>
    <!-- .view-container -->

    <portal to="modal-container" v-if="showIdleModal">
      <modal-template class="modal--hide-close modal--small" key="idle-modal">
        <div class="idle-modal">
          <h2 class="idle-modal__title">Your session has timed out.</h2>

          <div class="idle-modal__actions">
            <div v-on:click="this.restartSession" class="idle-modal__button">
              <div class="idle-modal__button__text">Start over</div>
              <div class="idle-modal__button__background"></div>
            </div>
            <!-- .idle-modal__button -->

            <div v-on:click="this.toggleIdleModal" class="idle-modal__button">
              <div class="idle-modal__button__text">Continue session</div>
              <div class="idle-modal__button__background"></div>
            </div>
            <!-- .idle-modal__button -->
          </div>
          <!-- .idle-modal__actions -->

          <div class="idle-modal__timer">
            Session will automatically restart in
            <b>{{ restartTimer }}</b> seconds
          </div>
          <!-- .idle-modal__timer -->
        </div>
        <!-- .idle-modal -->
      </modal-template>
    </portal>

    <portal to="modal-container" v-if="showOosModal">
      <modal-template class="modal--hide-close modal--small" key="oos-modal">
        <div class="oos-modal">
          <h2 class="oos-modal__title">{{ brandAndCategoryMessageHeader ? brandAndCategoryMessageHeader : 'This product is out of stock.' }}</h2>

          <div class="oos-modal__text">
            {{ brandAndCategoryMessageDescription ? brandAndCategoryMessageDescription : 'Please hand it to a staff member so they can swap it out.' }}
          </div>
          <!-- .oos-modal__text -->

          <div class="oos-modal__actions">
            <div v-on:click="this.toggleOosModal" class="oos-modal__button">
              <div class="oos-modal__button__text">Ok</div>
              <div class="oos-modal__button__background"></div>
            </div>
            <!-- .oos-modal__button -->
          </div>
          <!-- .oos-modal__actions -->
        </div>
        <!-- .oos-modal -->
      </modal-template>
    </portal>

    <portal to="modal-container" v-if="showLsModal">
      <modal-template class="modal--hide-close modal--small" key="oos-modal">
        <div class="ls-modal">
          <h2 class="ls-modal__title">Sorry</h2>

          <div class="ls-modal__text">
            You can't add this quantity to cart, only {{ maxStockQty }} in
            stock.
          </div>
          <!-- .ls-modal__text -->

          <div class="ls-modal__actions">
            <div v-on:click="this.toggleLsModal" class="ls-modal__button">
              <div class="ls-modal__button__text">Ok</div>
              <div class="ls-modal__button__background"></div>
            </div>
            <!-- .ls-modal__button -->
          </div>
          <!-- .ls-modal__actions -->
        </div>
        <!-- .ls-modal -->
      </modal-template>
    </portal>

    <portal-target name="modal-container" ref="portalTarget" :transition="{ name: 'modal' }" :transition-events="{
        enter: onModalTransitionEnter,
        leave: onModalTransitionLeave
      }"></portal-target>

    <div class="touch-feedback"></div>

    <div v-if="isOffline" class="link-offline">Offline</div>

    <div v-if="pointerBlocked" class="block-pointer"></div>

<!--    <button style="position: absolute; top: 0; right: 0; z-index: 1000; background: red; color: white; padding: 10px; font-size: 20px; border-radius: 5px;" @click="triggerTagPutEvent">RFID 1</button>-->
<!--    <button style="position: absolute; top: 0; left: 0; z-index: 1000; background: red; color: white; padding: 10px; font-size: 20px; border-radius: 5px;" @click="triggerTagPutEvent2">RFID 2</button>-->
  </div>
</template>

<script>
import Pusher from 'pusher-js'
import * as Sentry from '@sentry/vue'
import ArticlesRepo from '@/api/articles/ArticlesRepo'
import BrandsRepo from '@/api/brands/BrandsRepo'
import FeatureTagsTepo from '@/api/feature-tags/FeatureTagsRepo'
import { getOrders } from '@/api/messaging'
import ProductsRepo from '@/api/products/ProductsRepo'
import RFIDRepo from '@/api/rfid/RFIDRepo'
import ModalTemplate from '@/components/ModalTemplate'
import TheBrandSlideshow from '@/components/TheBrandSlideshow'
import TheSidebar from '@/components/TheSidebar'
import { GSAP_ANIMATION } from '@/const/globals.js'
import { Linear, Power2, Power3, TimelineLite, TweenMax } from 'gsap/all'
import $ from 'jquery'
import { Portal, PortalTarget } from 'portal-vue'
import CoolLightBox from 'vue-cool-lightbox'
import 'vue-cool-lightbox/dist/vue-cool-lightbox.min.css'
import api from './api/api'
import CategoriesRepo from './api/categories/CategoriesRepo'
import db from './api/db'
import {
  CATEGORIES_WITH_PRIORITY,
  RETRY_COOLDOWN,
  WAIT_TIME,
  WAIT_TIME_VERIFY_EXPIRED
} from './const/globals'
import { mapActions, mapMutations, mapGetters } from 'vuex'
require('./assets/css/normalize.css')
require('./assets/css/onScreenKeyboard.css')
require('./assets/css/onScreenKeyboardNumber.css')
require('./assets/scss/global.scss')
require('./assets/js/utils.js')
require('../node_modules/@fancyapps/fancybox/dist/jquery.fancybox.min.css')

export default {
  name: 'App',
  components: {
    ModalTemplate,
    Portal,
    PortalTarget,
    TheBrandSlideshow,
    TheSidebar,
    CoolLightBox
  },
  data() {
    return {
      idOfProductsWithStockBackend: [],
      productsToRemoveInFrontend: [],
      hardReloadProducts: false,
      lasExecutionHardReload: null,
      numMaxOfExecutionHardReload: 2,
      countExecutionHardReload: 0,
      quantityOfProductsBackend: 0,
      quantityOfProductsFrontend: 0,
      timeOut: null,
      iconTaps: 0,
      discountCode: null,
      cart: [],
      categories: [],
      pagesToRetry: [],
      featuredTags: [],
      featuredProductsModal: false,
      idleTimeout: null,
      isGeneratingIndex: true,
      isOffline: !navigator.onLine,
      isTouched: false,
      fetchedProducts: {},
      maxStockQty: 0,
      articles: [],
      pointerBlocked: false,
      products: [],
      fetchingProducts: false,
      page: {
        total: 0,
        totalPages: 0,
        page: 1,
        per_page: 10
      },
      refreshTimeout: null,
      restartInterval: null,
      restartTimer: 0,
      rfidProducts: {},
      showIdleModal: false,
      showLsModal: false,
      showOosModal: false,
      sidebarShow: false,
      swStarted: false,
      tags: [],
      tagsPerCategories: {},
      transitionFrom: this.$route.matched[0].components.default,
      transitionTo: this.$route.matched[0].components.default,
      hideCursor: true,
      videoPlaying: 0,
      featuredProdutcsFromSpotlight: null,
      product_Id: null,
      brand_Id: null,
      useBrandSpotlight: null,
      brands: [],
      spotlightSelected: false,
      productsToRemove: [],
      retriesConunter: 0,
      totalPages: 1,
      images: [],
      indexImg: null,
      subscription: null,
      featuredProductsList: [],
      animationSpeed: GSAP_ANIMATION,
      overlayMaskReady: false,
      isMaskDisabled: false,
      brandAndCategoryMessageHeader: null,
      brandAndCategoryMessageDescription: null
    }
  },
  computed: {
    isBackGroundvisible() {
      return this.$config.BACKGROUND_IMAGE_TOP
    },

    cartTotal: function() {
      var total = 0

      this.cart.forEach(function(line) {
        var lineTotal =
          Number(line.priceDiscount || line.price.basePrice) * Number(line.qty)

        total += lineTotal
      })

      return total
    }
  },
  created: function() {
    var self = this

    document.addEventListener('index_triggered', this.handleIndexTriggered)
    document.addEventListener('rfid_triggered', this.handleRfidTriggered)

    // seeting spotlight configuration
    this.product_Id = this.$config.PRODUCT_ID
    this.brand_Id = this.$config.BRAND_ID
    this.useBrandSpotlight = this.$config.USE_BRAND_SPOTLIGHT

    clearInterval(window.appRestartInterval)

    // Global CSS vars
    const root = document.documentElement
    root.style.setProperty('--main-color', this.$config.MAIN_COLOR)
    root.style.setProperty('--secondary-color', this.$config.SECONDARY_COLOR)
    root.style.setProperty(
      '--buttons-color',
      this.$config.BUTTONS_COLOR
        ? this.$config.BUTTONS_COLOR
        : this.$config.MAIN_COLOR
    )
    root.style.setProperty(
      '--navs-color',
      this.$config.NAVS_COLOR
        ? this.$config.NAVS_COLOR
        : this.$config.MAIN_COLOR
    )

    root.style.setProperty(
      '--kiosk-background',
      'url(' + this.$config.BACKGROUND + ')'
    )

    this.$gsClient.uploadEvents(60 * 5 * 1e3)

    // Events
    this.$root.$on('fetch-data', this.fetchData)
    this.$root.$on('spotlight-selected', this.selectSpotlight)
    this.$root.$on('reset-session', this.resetSession)
    this.$root.$on('restart-session', this.restartSession)
    this.$root.$on('add-to-cart', this.onAddToCart)
    this.$root.$on('delete-from-cart', this.onDeleteFromCart)
    this.$root.$on('featured-products-modal', this.onFeaturedProductsModal)
    this.$root.$on('video-play', this.onVideoPlay)
    this.$root.$on('video-pause', this.onVideoPause)
    this.$root.$on('start-hard-refresh', this.startHardRefreshCountdown)
    this.$root.$on('stop-hard-refresh', this.stopHardRefreshCountdown)
    this.$root.$on('block-pointer', this.blockPointer)
    this.$root.$on('open-gallery', this.openGallery)

    // US event
    this.$root.$on('sensor-uncovered', function(portNumber) {
      if (self.rfidProducts[portNumber]) {
        let product = self.rfidProducts[portNumber]

        // Hide idle modal on tag put
        if (self.showIdleModal === true) {
          self.toggleIdleModal()
        }

        this.$router.push({
          name: 'product',
          params: { id: product.id, source: 'Sensor' }
        })
        if (self.$gsClient) {
          self.$gsClient.track('RFID or Sensor Event', {
            id: product.id,
            source: 'Sensor'
          })
        }
        self.idleHandler()
      }
    })

    // RFID event
    this.$root.$on('tag-put', function(data) {
      data = data.toUpperCase()
      let changeConfigurationRFID = this.$config.RFID_POP_UP_BEHAVIOR
      // console.log("TAG EVENT", "Ipprovements");
      if (self.rfidProducts.hasOwnProperty(data)) {
        let rfid = self.rfidProducts[data]

        let productId = self.rfidProducts[data].rfidEntityID
        if (rfid.rfidEntityType) {
          switch (rfid.rfidEntityType) {
            case 'KioskProduct': {
              let product = self.products.find(
                product => product.id === productId
              )
              if (
                !navigator.onLine &&
                this.$config.RFID_POP_UP_BEHAVIOR === 1
              ) {
                changeConfigurationRFID = 0
              }
              if (!product || product.stock === 0) {
                switch (changeConfigurationRFID) {
                  case 0:
                    console.log('Kiosk configuration: Do nothing')
                    break
                  case 1:
                    console.log(
                      'Kiosk configuration: Send the user to the detail screen'
                    )
                    // At this point we want to show the product detail but disable the add to cart option
                    self.showOosModal = false
                    // Hide idle modal on tag put
                    if (self.showIdleModal === true) {
                      self.toggleIdleModal()
                    }

                    if (self.$config.HOME_LAYOUT === 'video_image_background') {
                      if (self.$route.name !== 'product' || self.$route.params.id !== product.id) {
                        self.$root.$emit('animate-full-screen-background')
                        setTimeout(() => {
                          self.$router.push({
                            name: 'product',
                            params: { id: product.id, source: 'RFID' }
                          })
                        }, 1000)
                      }
                    } else {
                      if (self.$route.name !== 'product' || self.$route.params.id !== product.id) {
                          self.$router.push({
                            name: 'product',
                            params: { id: product.id, source: 'RFID' }
                          })
                      }
                    }
                    if (self.$gsClient) {
                      self.$gsClient.track('RFID or Sensor Event', {
                        id: productId,
                        source: 'RFID',
                        category: 'KioskProduct'
                      })
                    }

                    break
                  case 2:
                    console.log('Kiosk configuration: Show out of stock pop up')
                    if (self.showOosModal === true) {
                      self.showOosModal = false
                      setTimeout(function() {
                        self.showOosModal = true
                      }, 500)
                    } else {
                      self.showOosModal = true
                    }
                    if (self.$gsClient) {
                      self.$gsClient.track('RFID or Sensor Event', {
                        error: 'out of stock',
                        source: 'RFID',
                        category: 'KioskProduct'
                      })
                    }
                    break
                  default:
                    console.log(
                      'Kiosk configuration NOT FOUND, fallingback to "Do nothing"'
                    )
                    break
                }
              } else {
                self.showOosModal = false
                // Hide idle modal on tag put
                if (self.showIdleModal === true) {
                  self.toggleIdleModal()
                }
                if (self.$config.HOME_LAYOUT === 'video_image_background') {
                  if (self.$route.name !== 'product' || self.$route.params.id !== product.id) {
                    self.$root.$emit('animate-full-screen-background')
                    setTimeout(() => {
                      self.$router.push({
                        name: 'product',
                        params: { id: product.id, source: 'RFID' }
                      })
                    }, 1000)
                  }
                } else {
                  if (self.$route.name !== 'product' || self.$route.params.id !== product.id) {
                      self.$router.push({
                        name: 'product',
                        params: { id: product.id, source: 'RFID' }
                      })
                  }
                }

                if (self.$gsClient) {
                  self.$gsClient.track('RFID or Sensor Event', {
                    id: product.id,
                    source: 'RFID',
                    category: 'KioskProduct'
                  })
                }
              }
              break
            }
            case 'Brand': {
              this.$router.replace({
                name: 'brands',
                query: {
                  brand: rfid.rfidEntityID
                }
              })
              if (self.$gsClient) {
                self.$gsClient.track('RFID or Sensor Event', {
                  id: rfid.rfidEntityID,
                  source: 'RFID',
                  category: 'Brand'
                })
              }
              break
            }
            case 'StoreCategory': {
              this.$router.push({
                name: 'products',
                query: {
                  category: rfid.rfidEntityID
                }
              })
              if (self.$gsClient) {
                self.$gsClient.track('RFID or Sensor Event', {
                  id: rfid.rfidEntityID,
                  source: 'RFID',
                  category: 'StoreCategory'
                })
              }
              break
            }
            case 'BrandAndStoreCategory': {
              let brandId = self.rfidProducts[data].rfidEntityID
              let brand = self.brands.find(brand => brand.id === brandId)
              let brandHasProducts = brand ? brand.hasProducts : false
              let categoryId = self.rfidProducts[data].rfidSubEntityID
              let category = self.categories.find(category => category.id === categoryId)
              let productsWithSameCategory = category ? self.products.filter(product => product.catalog_category && product.catalog_category.id === categoryId) : false
              let categoryHasProducts = productsWithSameCategory ? productsWithSameCategory.length > 0 : false
              let brandAndStoreCategoryHasProducts = self.products.filter(product => product.catalog_category && product.catalog_category.id === categoryId && product.brand && product.brand.id === brandId).length > 0

              if (!brandHasProducts && categoryHasProducts) {
                switch (changeConfigurationRFID) {
                  case 2:
                    console.log('Kiosk configuration: Show out of stock pop up')
                    self.brandAndCategoryMessageHeader = `${rfid.brandName.toUpperCase()} has no products in stock`
                    self.brandAndCategoryMessageDescription = `Check products in ${rfid.categoryName.toUpperCase()} from other brands.`

                    if (self.showOosModal) {
                      self.showOosModal = false
                      setTimeout(function () {
                        self.showOosModal = true
                      }, 500)
                    } else {
                      self.showOosModal = true
                    }

                    this.$router.push({
                      name: 'products',
                      query: {
                        category: rfid.rfidSubEntityID
                      }
                    })

                    if (self.$gsClient) {
                      self.$gsClient.track('RFID or Sensor Event', {
                        id: rfid.rfidEntityID,
                        categoryId: rfid.rfidSubEntityID,
                        source: 'RFID',
                        category: 'BrandAndStoreCategory'
                      })
                    }
                    break

                  default:
                    console.log('Kiosk configuration NOT FOUND, falling back to "Do nothing"')
                    break
                }
              } else if (brandHasProducts && !brandAndStoreCategoryHasProducts) {
                switch (changeConfigurationRFID) {
                  case 2:
                    console.log('Kiosk configuration: Show out of stock pop up')
                    self.brandAndCategoryMessageHeader = `There are no products from ${rfid.categoryName.toUpperCase()} by ${brand.name.toUpperCase()} in stock.`
                    self.brandAndCategoryMessageDescription = `Check out the other products of this ${brand.name.toUpperCase()}.`

                    if (self.showOosModal) {
                      self.showOosModal = false
                      setTimeout(function () {
                        self.showOosModal = true
                      }, 500)
                    } else {
                      self.showOosModal = true
                    }

                    this.$router.replace({
                      name: 'brands',
                      query: {
                        brand: rfid.rfidEntityID
                      }
                    })

                    if (self.$gsClient) {
                      self.$gsClient.track('RFID or Sensor Event', {
                        id: rfid.rfidEntityID,
                        categoryId: rfid.rfidSubEntityID,
                        source: 'RFID',
                        category: 'BrandAndStoreCategory'
                      })
                    }
                    break

                  default:
                    console.log('Kiosk configuration NOT FOUND, falling back to "Do nothing"')
                    break
                }
              } else if (!brandHasProducts && !categoryHasProducts) {
                switch (changeConfigurationRFID) {
                  case 2:
                    console.log('Kiosk configuration: Show out of stock pop up')
                    self.brandAndCategoryMessageHeader = `${rfid.brandName.toUpperCase()} and ${rfid.categoryName.toUpperCase()} has no products in stock`
                    self.brandAndCategoryMessageDescription = `Check out the other brands' products.`

                    if (self.showOosModal) {
                      self.showOosModal = false
                      setTimeout(function () {
                        self.showOosModal = true
                      }, 500)
                    } else {
                      self.showOosModal = true
                    }

                    this.$router.replace({
                      name: 'brands'
                    })

                    if (self.$gsClient) {
                      self.$gsClient.track('RFID or Sensor Event', {
                        id: rfid.rfidEntityID,
                        categoryId: rfid.rfidSubEntityID,
                        source: 'RFID',
                        category: 'BrandAndStoreCategory'
                      })
                    }
                    break

                  default:
                    console.log('Kiosk configuration NOT FOUND, falling back to "Do nothing"')
                    break
                }
              } else {
                self.showOosModal = false
                self.brandAndCategoryMessageHeader = null
                self.brandAndCategoryMessageDescription = null

                // Hide idle modal on tag put
                if (self.showIdleModal) {
                  self.toggleIdleModal()
                }

                const currentRoute = this.$route
                const newRoute = {
                  name: 'brands',
                  query: {
                    source: 'ScreenBrands',
                    brand: rfid.rfidEntityID,
                    category: rfid.rfidSubEntityID
                  }
                }

                if (currentRoute.name !== newRoute.name || JSON.stringify(currentRoute.query) !== JSON.stringify(newRoute.query)) {
                  this.$router.replace(newRoute)
                    .catch(err => {
                      if (err.name !== 'NavigationDuplicated') {
                        console.log(err) // Handle other errors if necessary
                      }
                    })
                }

                if (self.$gsClient) {
                  self.$gsClient.track('RFID or Sensor Event', {
                    id: rfid.rfidEntityID,
                    categoryId: rfid.rfidSubEntityID,
                    source: 'RFID',
                    category: 'BrandAndStoreCategory'
                  })
                }
              }
              break
            }
          }
        }
        self.idleHandler()
      }
    })

    // Set modal Out of stock
    this.$root.$on('setOOSModal', function(data) {
      self.showOosModal = data
    })

    // Online/offline mode
    window.addEventListener('online', this.checkConnection)
    window.addEventListener('offline', this.checkConnection)

    // Hide sidebar on home
    this.sidebarShow = this.getSidebarVisibility()

    // Check if cursor should be hidden or not
    this.setCursor()

    // Fancybox
    $().fancybox({
      selector: '[data-fancybox]',
      loop: true,
      buttons: [
        // 'zoom',
        // 'share',
        // 'slideShow',
        // 'fullScreen',
        // 'download',
        // 'thumbs',
        'close'
      ],
      hash: false,
      video: {
        tpl:
          '<video class="fancybox-video" controls controlsList="nodownload nofullscreen" poster="{{poster}}">' +
          '<source src="{{src}}" type="{{format}}" />' +
          'Sorry, your browser doesn\'t support embedded videos, <a href="{{src}}">download</a> and watch with your favorite video player!' +
          '</video>',
        format: '', // custom video format
        autoStart: true
      },
      afterShow: function(instance, slide) {
        if (slide.type === 'video') {
          // Block idle timeout
          self.$root.$emit('video-play')

          // Close modal on video end
          let video = slide.$slide.find('video')
          video.on('ended', function() {
            instance.close()
          })
        }
      },
      afterClose: function(instance, slide) {
        // Unblock idle timeout
        if (slide.type === 'video') {
          self.$root.$emit('video-pause')
        }
      }
    })
    if (self.$config.POS_TYPE === 'shopify') {
      self.listenForOrders()
    }
  },
  mounted: function() {
    window.addEventListener('keypress', this.onKeyPress)

    let pusher

    const connectPusher = () => {
      try {
        pusher = new Pusher(self.kioskConfig.PUSHER_APP_KEY, {
          cluster: self.kioskConfig.PUSHER_APP_CLUSTER
        })

        pusher.connection.bind('error', function(error) {
          console.log('Pusher error', error)
        })

        pusher.connection.bind('connected', function() {
          console.log('Pusher connected to server')
          connectProductWebSocket()
          connectProductDestroyedWebSocket()
        })
      } catch (error) {
        Sentry.captureException(error)
        console.log('Error connecting to Pusher', error)
      }
    }

    const connectProductWebSocket = () => {
      const configData = JSON.parse(localStorage.getItem('config_data'))

      if (!configData) {
      }

      try {
        const channel = pusher.subscribe(
          `store_products_${configData.store.id}`
        )

        console.log('Connected to Pusher', channel)

        channel.bind('product_updated', data => {
          const product = data.product

          const expiredDate = new Date()
          expiredDate.setDate(expiredDate.getDate() + 1)
          product.expired_at = expiredDate.toISOString()

          db.getProduct(product.id).then(localProduct => {
            if (!localProduct) {
              if (product.stock > 0 && product.status === 'published') {
                db.saveProduct(product)
                this.fetchedProducts[product.id] = product

                this.parseProducts()
              }
            } else {
              Object.assign(localProduct, product)
              db.saveProduct(localProduct)

              this.products.forEach(p => {
                if (p.id === product.id) {
                  this.fetchedProducts[product.id] = localProduct
                }
              })

              this.parseProducts()
            }
          })
        })
      } catch (error) {
        Sentry.captureException(error)
        console.log('Error connecting to Pusher', error)
      }
    }

    const connectProductDestroyedWebSocket = () => {
      const configData = JSON.parse(localStorage.getItem('config_data'))

      try {
        const channel = pusher.subscribe(
          `store_products_${configData.store.id}`
        )

        console.log('Connected to Pusher destroyed', channel)

        channel.bind('product_destroyed', data => {
          const product = data.product

          this.productsToRemove.push(product)

          for (const product of this.productsToRemove) {
            delete this.fetchedProducts[product.id]
            // remove from local db
            if (this.$config.STORE_LOCALLY) {
              db.deleteProduct(product).then(
                () => {
                  console.log(`${product.id} ${product.name} removed`)
                  console.log('product removed', product)
                  console.error(`${product.id} removed`)
                },
                error => {
                  console.error(error)
                }
              )
            }
          }
        })
      } catch (error) {
        Sentry.captureException(error)
        console.log('Error connecting to Pusher', error)
      }
    }

    connectPusher()
    this.fetchProductsExpiration()
    this.setGlobalCart(this.cart)
    // listen to CTRL + E to trigger tag emulation
  },
  watch: {
    $route(to, from) {
      this.transitionFrom = from
      this.transitionTo = to

      // Hide keyboard
      $('#osk-container:visible .osk-hide').click()
      $('#osk-container-number:visible .osk-hide').click()
    },

    // watch if the products list in the indexedDB has changed and update the products list
    products: {
      handler: function(val, oldVal) {
        if (val.length !== oldVal.length) {
          this.products = val
          this.setProducts(val)
        }
      }
    }
  },
  methods: {
    ...mapMutations('cart', ['setGlobalCart', 'resetActiveCartSession']),
    ...mapMutations('products',['setProducts', 'getIsFullScreenProduct', 'setIsFullScreenProduct']),
    ...mapActions('cart', ['addProductToActiveCart']),
    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },

    // TODO: Leaving this here for testing purposes for now, we will remove it later.
    triggerTagPutEvent(e) {
      console.log(e)
        try {
          console.log('TAG PUT EVENT TO TRIGGER')
          console.log(this.$root.$emit('tag-put', '04A15E82B01990'))
          console.log('TAG PUT EVENT TRIGGERED')
        } catch (e) {
          console.log(e)
        }
      // TODO: this is the emulation of a tag event, but we need to see the product being pulled of after this event.
    },

    triggerTagPutEvent2(e) {
      console.log(e)

        try {
          console.log('TAG PUT EVENT TO TRIGGER')
          console.log(this.$root.$emit('tag-put', '04A87182B01990'))
          console.log('TAG PUT EVENT TRIGGERED')
        } catch(e){
          console.log(e)
        }
      // TODO: this is the emulation of a tag event, but we need to see the product being pulled of after this event.
    },
    // Debounce function
    debounce(func, wait) {
      let timeout

      return function() {
        const context = this
        const args = arguments

        clearTimeout(timeout)
        timeout = setTimeout(() => {
          func.apply(context, args)
        }, wait)
      }
    },

    // Actual logic to be debounced
    handleIndexTriggeredLogic: async function() {
      await this.fetchProducts()
    },

    handleRfidTriggeredLogic: async function() {
      await this.fetchRFID()
    },

    // Original method connected to some trigger event (e.g., button click)
    handleIndexTriggered: function() {
      this.debounce(this.handleIndexTriggeredLogic, 10000)() // Adjust the debounce interval as needed
    },

    handleRfidTriggered: function() {
      this.debounce(this.handleRfidTriggeredLogic, 10000)() // Adjust the debounce interval as needed
    },

    listenForOrders() {
      const self = this
      const kioskID = self.$config.API.CATALOG_ID
      self.subscription = getOrders(kioskID, changes => {
        changes.forEach(change => {
          if (change.type === 'added') {
            if (self.$route.name === 'cart') {
              self.$router.push({ name: 'checkout' })
            }
          }
        })
      })
    },

    goToEvents() {
      if (this.timeOut != null) {
        clearTimeout(this.timeOut)
      }
      this.iconTaps++
      if (this.iconTaps >= 5) {
        console.log(' REDIRECT TO EVENTS')
        this.$router.push({ name: 'analytics' })
        this.iconTaps = 0
      } else {
        this.timeOut = setTimeout(() => {
          this.iconTaps = 0
        }, 1000)
      }
    },

    /**
     * Router view transition enter
     */
    onTransitionEnter: function(el, done) {
      if (this.transitionFrom.name === 'home') {
        this.sidebarShow = this.getSidebarVisibility()
      }
      done()
    },

    /**
     * Router view transition leave
     */
    onTransitionLeave: function(el, done) {
      var self = this

      if (this.$refs.routerView.hasOwnProperty('onTransitionLeave')) {
        this.blockPointer(true)

        // If current screen has a transition leave methods, trigger it
        this.$refs.routerView.$emit('transition-leave', el, function() {
          self.blockPointer(false)
          TweenMax.killAll(true)
          done()
        })
      } else if (
        this.transitionFrom.name === 'blank' &&
        this.transitionTo.name === 'home'
      ) {
        this.blockPointer(true)

        setTimeout(function() {
          self.blockPointer(false)
          TweenMax.killAll(false)
          done()
        }, 1500)
      } else if (
        this.transitionFrom.name === 'blank' &&
        this.$refs.hasOwnProperty('brandSlideshow')
      ) {
        done()
      } else {
        TweenMax.killAll(true)
        done()
      }

      // Hide sidebar on home
      if (this.transitionTo.name === 'home') {
        this.sidebarShow = this.getSidebarVisibility()
      }
    },

    /**
     * Modal transition enter
     */
    onModalTransitionEnter: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container.find('.modal__background'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.modal__container'),
        GSAP_ANIMATION.duration,
        {
          height: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      if (container.find('.add-to-cart-modal').length === 1) {
        tl.staggerFrom(
          container.find('.product-image, .add-to-cart-modal__form > *'),
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
      } else if (container.find('.topic-modal').length === 1) {
        tl.from(
          container.find('.topic-modal__aside__background'),
          GSAP_ANIMATION.duration,
          {
            width: 0,
            clearProps: 'width',
            ease: Power3.easeInOut
          },
          GSAP_ANIMATION.tween
        )

        tl.from(
          container.find('.modal__close-text__background'),
          GSAP_ANIMATION.duration,
          {
            width: 0,
            clearProps: 'width',
            ease: Power2.easeInOut
          },
          GSAP_ANIMATION.tween
        )

        tl.from(
          container.find('.modal__close-text__icon'),
          GSAP_ANIMATION.duration,
          {
            scale: 0,
            clearProps: 'transform',
            ease: Power2.easeOut
          },
          GSAP_ANIMATION.tween
        )

        tl.from(
          container.find('.modal__close-text__text'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            clearProps: ' opacity',
            ease: Linear.easeNone
          },
          GSAP_ANIMATION.tween
        )

        tl.staggerFrom(
          container.find('.topic-modal__header > *, .topic-modal__body'),
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

        tl.from(
          container.find('.topic-modal__aside__title__text'),
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
          container.find('.topic-modal__aside__title__line'),
          GSAP_ANIMATION.duration,
          {
            scaleX: 0,
            clearProps: 'transform',
            ease: Power3.easeInOut
          },
          GSAP_ANIMATION.tween
        )

        tl.staggerFrom(
          container.find('.product-image'),
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
          container.find('.product-card__info'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            clearProps: 'opacity',
            ease: Linear.easeNone
          },
          GSAP_ANIMATION.tween,
          GSAP_ANIMATION.append
        )

        tl.from(
          container.find('.topic-modal__aside__button__background'),
          GSAP_ANIMATION.duration,
          {
            width: 0,
            clearProps: 'width',
            ease: Power2.easeInOut
          },
          GSAP_ANIMATION.tween
        )

        tl.from(
          container.find('.topic-modal__aside__button__text'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 20,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          GSAP_ANIMATION.tween
        )
      } else {
        tl.from(
          container.find('.modal__inner'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 30,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          GSAP_ANIMATION.tween
        )
      }

      tl.call(function() {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Modal transition leave
     */
    onModalTransitionLeave: function(el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.modal__inner'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.modal__container'),
        GSAP_ANIMATION.duration,
        {
          boxShadow: '0px 0px 0px 0px rgba(0, 0, 0, 0)',
          height: 0,
          y: 30,
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.to(
        container.find('.modal__background'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          ease: Linear.easeNone
        },
        GSAP_ANIMATION.tween
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
     * Add to cart event
     * @param  {Object} product
     */
    onAddToCart: function(product) {
      let totalQty = product.qty

      let cartProductIndex = this.cart.findIndex(
        element =>
          element.product.id === product.product.id &&
          element.price.id === product.price.id
      )

      if (cartProductIndex >= 0) {
        totalQty += this.cart[cartProductIndex].qty
      }

      let catalogProduct = this.products.find(
        element => element.id === product.product.id
      )

      if (totalQty > catalogProduct.stock) {
        this.maxStockQty = catalogProduct.stock
        this.showLsModal = true

        this.$root.$emit('product-not-added', product)
      } else {
        if (cartProductIndex >= 0) {
          this.cart[cartProductIndex].qty = totalQty
        } else {
          this.cart.push(product)
        }
        if (self.$gsClient) {
          self.$gsClient.track(
            'Add to Cart',
            {
              name: product.product.name,
              brand: product.product.brand ? product.product.brand.name : '',
              category: product.product.catalog_category.name,
              quantity: product.qty,
              price: product.price.value,
              base_price: product.price.basePrice,
              category_taxes: product.product.category_taxes,
              store_taxes: product.product.store_taxes,
              tag_list: product.product.tag_list,
              id: product.product.sku,
              product_id: product.product.id
            },
            { total_qty: totalQty }
          )
        }

        if (this.isActiveCartFeatureActivated) {
          this.addProductToActiveCart({
            product: product.product,
            price: product.price,
            qty: product.qty,
            priceDiscount: product.priceDiscount
          })
        } else {
          console.log('Active cart feature is not activated. onAddToCart')
        }
        this.$root.$emit('product-added', product)
      }
    },

    /**
     * Delete from cart event
     * @param  {Integer} index
     */
    onDeleteFromCart: function(index) {
      var newCart = []
      let dis = this
      this.cart.forEach(function(line, loopIndex) {
        if (loopIndex !== index) {
          newCart.push(line)
        } else {
          console.log('Prod removed from cart', line)

          if (dis.$gsClient) {
            dis.$gsClient.track('Delete from cart', { item: line })
          }
        }
      })

      this.cart = newCart
      this.setGlobalCart(this.cart)
    },

    /**
     * Show featured products modal only once
     */
    onFeaturedProductsModal: function() {
      this.featuredProductsModal = true
    },

    /**
     * Keyboard event
     */
    onKeyPress: function(e) {
      if (e.charCode === 178) {
        // Open debug
        this.$router.push({ name: 'debug-cache' })
      }
    },

    /**
     * Save touch status
     */
    onTouchStart: function() {
      this.isTouched = true
      this.idleHandler()
    },

    /**
     * Save touch status
     */
    onTouchEnd: function() {
      this.isTouched = false
      this.idleHandler()
    },

    /**
     * Save video status
     */
    onVideoPlay: function() {
      this.videoPlaying += 1
      this.idleHandler()
    },

    /**
     * Save video status
     */
    onVideoPause: function() {
      this.videoPlaying -= 1
      this.idleHandler()
    },

    /**
     * Block pointer
     */
    blockPointer: function(status = false) {
      this.pointerBlocked = status
    },

    /**
     * Open Gallery
     */
    openGallery: function(eventInfo) {
      this.images = eventInfo.images
      this.indexImg = eventInfo.index
    },

    /**
     * Check if app is offline
     */
    checkConnection: function() {
      this.isOffline = !navigator.onLine
    },

    /**
     * Global click event
     */
    clickHandler: function(event) {
      this.idleHandler()
      this.touchFeedback(event)
    },

    /**
     * Function use to sleep
     */
    sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms))
    },
    async updateProducts(options) {
      let self = this
      // if times of retry its more or equal to retuurn page

      return new Promise(async (resolve, reject) => {
        try {
          // send request from api and save products
          let response = await api.getProductsMinimalForDate(options)

          const products = response.products

          products.forEach(product => {
            self.fetchedProducts[product.id] = product
          })
          // return date
          resolve(response.meta.total_pages)
        } catch (e) {
          Sentry.captureException(e)
          reject(e)
          // of operation fails wait 25 seconds and retry
        }
      })
    },
    /**
     * Fetch products one by one
     * @param {Array} productsToRemove Products to remove
     */
    fetchFeaturedProducts: async function() {
      let pageConfig = {
        page: 1,
        per_page: 100,
        featured_product: true,
        exclude_zero: 1
      }
      try {
        let resp = await api.getProducts(pageConfig)
        this.featuredProductsList = resp.data.products
      } catch (e) {
        Sentry.captureException(e)
        console.error('ERROR FETCHING FEATURED PRODUCTS', e)
      }
    },
    fetchProducts: async function(productsToRemove = []) {
      var self = this
      if (self.fetchingProducts === true) {
        return
      }

      self.fetchingProducts = true
      console.log('%c FETCHING PRODUCT', 'background-color:#000;color:#ffff;')
      let page = 0
      let failedPages = 0
      var startTime = performance.now()
      while (true) {
        ++page

        try {
          let response = await self.fetchPage(page)
          self.totalPages = response.data.meta.total_pages
          console.log(`PAGE  ${page} OF ${self.totalPages}  FETCHED`)
        } catch (e) {
          // add page to the retries
          console.log(`ALL RETRIES FAIL ADDING PAGE ${page} TO RETRY LIST  `)
          ++failedPages
        }

        if (self.totalPages === page || self.totalPages === 0) {
          break
        }
      }
      var endTime = performance.now()
      console.log(
        `%c FETCH ALL PRODUCTS took ${endTime - startTime} milliseconds`,
        'background-color:green,color:light-blue;'
      )
      // if (self.$config.STORE_LOCALLY === 1 && localStorage.getItem('update_date')) {
      //   lastUpdate = localStorage.getItem('update_date')
      // }

      self.removeNotStockProducts(self.productsToRemove)
      // localStorage.setItem('update_date',)
      // Remove products

      self.parseProducts()
      const lastProduct = self.getLastProduct()
      console.log('FAILED PAGES', failedPages, failedPages === 0)
      if (failedPages === 0) {
        localStorage.setItem('update_date', lastProduct.updated_at)
      } else {
        console.log('PAGES FAILED KEEPING OLD DATE')
      }

      self.productsToRemove = []
      self.fetchingProducts = false
    },
    /**
     * Fetch a single page and store it locally
     * @param {*} page
     */
    async fetchPage(page) {
      const self = this
      let response = null
      let tries = 0
      let totalPages = 0
      // trye fo fetch page at least 5 times
      while (tries < 5) {
        try {
          let times = `FOR ${tries + 1} TIME`
          console.log(`TRYING TO FETCH PAGE ${page} ${tries > 0 ? times : ''}`)
          response = await api.getProductsMinimal(page, this.hardReloadProducts)
          if (response.data.meta.idOfProductsWithStockBackend) {
            this.idOfProductsWithStockBackend = response.data.meta.idOfProductsWithStockBackend
              .map(id => parseInt(id))
              .sort((a, b) => a - b)
          }

          totalPages = response.data.meta.total_pages
          this.quantityOfProductsBackend =
            response.data.meta.quantityOfProductsWithStockBackend

          response.data.products.forEach(product => {
            if (product.stock <= 0 || product.status === 'unpublished') {
              console.log('product ws with stock 0', product)

              this.productsToRemove.push(product)
            } else {
              this.fetchedProducts[product.id] = product
            }
          })
          await ProductsRepo.indexLocal(response.data.products)

          let products = await db.getProducts()
          this.quantityOfProductsFrontend = products.filter(
            product => product.stock > 0
          ).length
          this.productsToRemoveInFrontend = products
            .filter(
              product => !this.idOfProductsWithStockBackend.includes(product.id)
            )
            .sort((a, b) => a - b)

          if (page === totalPages) {
            this.hardReloadProducts = this.executeHardReloadProducts()
            if (this.hardReloadProducts) {
              if (this.productsToRemoveInFrontend.length > 0) {
                this.productsToRemoveInFrontend.forEach(product => {
                  this.productsToRemove.push(product)
                })
                this.productsToRemoveInFrontend = []
              }
            }
          }
          // if response it's succesfully return response and exit loop
          return response
        } catch (e) {
          // if and error occur wait a cooldown time and trye again
          console.log('#T-01-error', e)
          await self.sleep(RETRY_COOLDOWN)
          tries++
        }
      }
    },

    async removeNotStockProducts(productsToRemove) {
      const self = this
      if (productsToRemove && productsToRemove.length > 0) {
        for (const product of productsToRemove) {
          delete self.fetchedProducts[product.id]
          // remove from local db
          if (self.$config.STORE_LOCALLY) {
            db.deleteProduct(product).then(
              () => {
                console.log(`${product.id} ${product.name} removed`)
                console.log('product removed', product)
                console.error(`${product.id} removed`)
              },
              error => {
                console.error(error)
              }
            )
          }
        }
      }
    },

    async retryUpdate(options) {
      try {
        await this.updateProducts(options)
        this.parseProducts()
      } catch (e) {
        Sentry.captureException(e)
        console.log('Error for retrie ', e)
        setTimeout(() => {
          this.retryUpdate(options)
        }, 2 * 60 * 1000)
      }
    },
    /**
     * Retrie pages
     */
    async retryPages() {
      // mark sync as incomplete
      // await Promise.all(self.pagesToRetry.map(async (options, index) => {
      //   return api.getProductsMinimalForDate(options).then(async (response) => {
      //     response.data.products.forEach((product) => {
      //       if (product.stock <= 0 || product.status === 'unpublished') {
      //         this.productsToRemove.push(product)
      //       } else {
      //         this.fetchedProducts[product.id] = product
      //       }
      //     })
      //     await ProductsRepo.indexLocal(response.data.products)
      //     self.pagesToRetry.splice(index, 1)
      //     return true
      //   }).catch((e) => {
      //     console.error(e)
      //     return false
      //   })
      // }))
      // this.parseProducts()
    },

    /*
     * Fetch data
     */
    fetchData: async function() {
      var self = this

      if (!navigator.onLine) {
        self.fetchingProducts = false
        setTimeout(self.fetchData, WAIT_TIME)
        return
      }
      await self.fetchSettings()

      let fast = self.$config.FAST_ANIMATION
      if (fast) {
        GSAP_ANIMATION.duration = 0.3
        GSAP_ANIMATION.tween = 0
        GSAP_ANIMATION.append = 0
      }

      this.isMaskDisabled = self.$config.DISABLE_OVERLAY
      this.overlayMaskReady = true

      // await self.retryPages()
      // get products from local indexed db if there are some store localy
      if (self.$config.STORE_LOCALLY === 1) {
        var products = await db.getProducts()
        self.brands = await BrandsRepo.local.index()
        self.parseBrands()

        if (products.length > 0) {
          products.forEach(p => {
            self.fetchedProducts[p.id] = p
          })

          this.parseProducts()
          self.isGeneratingIndex = false
        }
      }
      // get products from online
      // get featured categories
      await self.fetchCategories()

      // Update index
      await self.fetchProducts()
      await self.deleteProductsWhenNoExist()

      // Fetch featured products
      await self.fetchFeaturedProducts()
      // Get rfids
      await self.fetchRFID()
      // get brands
      await self.fetchBrands()
      // get articles
      await self.fetchArticles()
      // get featured tags
      await self.fetchFeaturedTags()

      self.isGeneratingIndex = false
      // update again after certain time
      setTimeout(self.fetchData, WAIT_TIME)
    },

    /**
     * Fetch products expiration
     */
    async fetchProductsExpiration() {
      let self = this

      if (!navigator.onLine) {
        setTimeout(self.fetchProductsExpiration, WAIT_TIME_VERIFY_EXPIRED)
        return
      }

      const configData = JSON.parse(localStorage.getItem('config_data'))
      let productsDB = await db.getProducts()

      const filteredProducts = productsDB.filter(product => {
        const currentTime = new Date()
        const expiredAt = new Date(product.expired_at)

        return currentTime.getTime() > expiredAt.getTime()
      })

      filteredProducts.sort(
        (a, b) => new Date(a.expired_at) - new Date(b.expired_at)
      )

      const pages = Math.ceil(filteredProducts.length / 100)

      for (let i = 0; i < pages; i++) {
        const batch = filteredProducts.slice(i * 100, (i + 1) * 100)

        let attempts = 0
        let success = false

        while (attempts < 3 && !success) {
          try {
            const response = await api.verifyProductsExpiration(
              configData.store.id,
              batch
            )

            response.data.forEach(product => {
              const localProduct = productsDB.find(p => p.id === product.id)

              if (product.status === 'published' && product.stock > 0) {
                const expiredDate = new Date()
                expiredDate.setDate(expiredDate.getDate() + 1)
                product.expired_at = expiredDate.toISOString()

                Object.assign(localProduct, product)
                db.saveProduct(localProduct)

                self.products.forEach(p => {
                  if (p.id === product.id) {
                    self.fetchedProducts[product.id] = localProduct
                  }
                })
              }

              if (
                product.stock <= 0 ||
                product.status === 'unpublished' ||
                product.status === 'deleted'
              ) {
                self.productsToRemove.push(product)
                delete self.fetchedProducts[product.id]

                if (self.$config.STORE_LOCALLY) {
                  self.deleteProduct(product)
                }
              }
            })

            this.parseProducts()
            console.log(`PRODUCTS EXPIRED - Page ${i + 1}`, response)
            success = true
          } catch (error) {
            attempts++
            console.error(
              `Error processing batch - Page ${i + 1}, Attempt ${attempts}`,
              error
            )

            if (attempts < 3) {
              console.log(`Retrying in 5 seconds...`)
              await new Promise(resolve => setTimeout(resolve, 5000))
            } else {
              console.error(
                `Failed to process batch - Page ${i + 1} after 3 attempts`
              )
              Sentry.captureMessage(
                `Failed to process batch - Page ${i + 1} after 3 attempts`,
                'warning'
              )
              break
            }
          }
        }
      }

      setTimeout(self.fetchProductsExpiration, WAIT_TIME_VERIFY_EXPIRED)
    },

    /**
     * Fetch Categories From api
     */
    async fetchCategories() {
      try {
        const response = await CategoriesRepo.index()
        console.log('CATEGORIES', response)
      } catch (e) {
        Sentry.captureException(e)
        console.error('Error fetching categories', e)
      }
    },
    /**
     *
     * Fetch API
     */
    async fetchSettings() {
      console.log('fetching settings')
      try {
        const response = await api.getSettings()
        this.mergeConfig(response)
      } catch (e) {
        Sentry.captureException(e)
        console.error('ERROR FETCHING SETTINGS', e)
      }
    },
    /**
     * Merge config
     */
    async deleteProductsWhenNoExist() {
      const configData = JSON.parse(localStorage.getItem('config_data'))
      try {
        const products = await api.getProductsWhenNoExist(configData.store.id)
        this.productsToRemove.push(...products.data)

        this.productsToRemove.forEach(product => {
          delete this.fetchedProducts[product.id]

          if (this.$config.STORE_LOCALLY) {
            db.getProduct(Number(product.id)).then(localProduct => {
              if (localProduct) {
                self.deleteProduct(localProduct)
              }
            })
          }

          this.parseProducts()
        })
      } catch (e) {
        Sentry.captureException(e)
        console.error('ERROR DELETING PRODUCTS', e)
      }
      this.productsToRemove = []
    },
    /**
     * Delete product
     */
    deleteProduct(product) {
      db.deleteProduct(product).then(
        () => {
          console.log(`${product.id} ${product.name} removed`)
          console.log('PRODUCTS TO DELETE', product)
          console.error(`${product.id} removed`)
        },
        error => {
          console.error(error)
        }
      )
    },
    /**
     * Fetch RFID from
     */
    async fetchRFID() {
      let self = this

      console.log('FETCHING RFIDS')
      return new Promise((resolve, reject) => {
        RFIDRepo.list().then(
          rfids => {
            self.setRfids(rfids)
            resolve(rfids)
          },
          error => {
            Sentry.captureException(error)
            console.error('ERROR ON RFIDS', error)
            resolve([])
          }
        )
      })
    },
    /**
     * Fetch featured tags
     */
    fetchFeaturedTags: async function() {
      let self = this
      FeatureTagsTepo.index().subscribe(
        tags => {
          tags
            .map(tag => tag.tag)
            .forEach(tagName => {
              var tag = {
                name: tagName,
                products: self.filteredProducts(tagName)
              }
              if (tag.products.length > 0) {
                let exists = self.featuredTags.find(tag => tag.name === tagName)
                if (exists) {
                  return false
                } else {
                  self.featuredTags.push(tag)
                }
              }
            })
        },
        error => {
          Sentry.captureException(error)
          console.log(error)
        }
      )
      /* this.$http.get('tags?featured_tags=true').then(response => {
        response.data.tags.forEach(function (tagName) {
          var tag = {
            name: tagName,
            products: self.filteredProducts(tagName)
          }

          if (tag.products.length > 0) {
            self.featuredTags.push(tag)
          }
          FeatureTagsTepo.updateLocalItems(self.featuredTags)
        })
        // Fetch is done, call transition on next tick
      }).catch(async (e) => {
        console.log(e)
        // if request fails use local repo
        try {
          this.featuredTags = await FeatureTagsTepo.local.index()
        } catch (e) {
          console.log(e)
        }
        console.log('feature tags from local')
      }) */
    },
    filteredProducts: function(tag) {
      // Get products that have this tag
      var products = this.products.filter(function(product) {
        return product.tag_list.includes(tag)
      })

      // If option is enabled, put featured products on top
      return products
    },

    /**
     * Fetch store articles
     */
    fetchArticles: async function() {
      let self = this
      return new Promise((resolve, reject) => {
        ArticlesRepo.index().subscribe(
          articles => {
            self.articles = articles
            resolve(articles)
          },
          error => {
            Sentry.captureException(error)
            resolve([])
            console.error(error)
          }
        )
      })
    },

    parseBrands() {
      let self = this
      self.brands.forEach(function(brand) {
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

        if (brand.id === self.brand_Id) {
          products.forEach(p => {
            p.isFeatured = true
          })
        }

        // Check if brand has some featured products
        brand.isFeatured = products.some(function(product) {
          return product.isFeatured
        })
      })
    },

    /**
     * Get Brands
     */
    fetchBrands: async function() {
      let self = this

      return new Promise((resolve, reject) => {
        BrandsRepo.index().subscribe(
          brands => {
            self.brands = brands

            self.brands.forEach(function(brand) {
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

              if (brand.id === self.brand_Id) {
                products.forEach(p => {
                  p.isFeatured = true
                })
              }

              // Check if brand has some featured products
              brand.isFeatured = products.some(function(product) {
                return product.isFeatured
              })
            })
            resolve(brands)
          },
          error => {
            Sentry.captureException(error)
            console.error(error)
            resolve([])
          }
        )
      })

      /* api.getBrands({per_page: 9999}).then(response => {
        self.brands = response.data.brands
      }) */
    },

    /**
     * Get sidebar visibility
     */
    getSidebarVisibility: function() {
      if (
        this.$route.name !== 'home' ||
        this.$config.KIOSK_MODE === 'limited'
      ) {
        return true
      }

      return false
    },

    /**
     * Hold logo
     */
    logoHold: function() {
      this.startSoftRefreshCountdown()
    },

    /**
     * Release logo
     */
    logoRelease: function() {
      this.stopSoftRefreshCountdown()
    },

    /**
     * Parse fetched products
     * @param {Array} fetchedProducts Fetched products
     */
    parseProducts: function() {
      var self = this

      // Set default
      var usedCategories = []
      var products = []
      var tags = []
      var tagsPerCategories = {}

      // if product

      products = Object.values(
        this.fetchedProducts
      ) /* .filter(function (product) {
        // Remove out of stock products
        return product.stock > 0
      }) */

      products.forEach(function(product, index) {
        // New category, create tags array
        if (tagsPerCategories[product.catalog_category.id] === undefined) {
          tagsPerCategories[product.catalog_category.id] = []
        }

        product.tag_list.forEach(function(tag) {
          // Retrieve catalog tags from products list

          if (!tags.includes(tag)) {
            tags.push(tag)
          }

          // Associate tags with categories
          if (!tagsPerCategories[product.catalog_category.id].includes(tag)) {
            tagsPerCategories[product.catalog_category.id].push(tag)
          }
        })

        // Set product as featured
        if (product.featured !== undefined) {
          product.isFeatured = product.featured
        } else {
          // Backward compatibility
          product.isFeatured =
            (product.rfids !== undefined && product.rfids.length > 0) ||
            (product.rfid !== undefined && product.rfid !== null) ||
            product.tag_list.includes('featured')
        }

        // Save category id
        const catIndex = usedCategories.findIndex(
          cat => cat.id === product.catalog_category.id
        )
        if (catIndex === -1) {
          const { catalog_category: catalogCategory } = product
          // const defaultCategory = self.defaultPriority(catalogCategory.name)
          usedCategories.push({
            ...catalogCategory
            // order: catalogCategory.order ? catalogCategory.order : (defaultCategory ? defaultCategory.order : null)
          })
        }
      })

      /* api.getCategories().then(response => {
        this.categories = response.data.categories.filter(category => usedCategories.includes(category.id))
      }) */

      // Update values

      this.products = products.filter(function(product) {
        return product.stock > 0 && product.status === 'published'
      })

      // this.updateCurrentProduct()

      this.tags = tags
      this.tagsPerCategories = tagsPerCategories
      this.categories = usedCategories.sort((a, b) => {
        if (a.order != null) {
          return a.order > b.order ? 1 : -1
        }
        if (a.name > b.name) {
          return 1
        }
        if (a.name < b.name) {
          return -1
        }
      })
      // Set last update date
      if (products.length > 0) {
        // let orderedProducts = products.sort((a, b) => {
        //   if (a.updated_at < b.updated_at) {
        //     return -1
        //   }
        //   if (a.updated_at > b.updated_at) {
        //     return 1
        //   }
        //   return 0
        // })
        // localStorage.setItem('update_date', orderedProducts[ orderedProducts.length - 1 ].updated_at)
        self.sortById()
      }

      self.isGeneratingIndex = false
    },
    defaultPriority(name) {
      return CATEGORIES_WITH_PRIORITY.find(
        x => x.name.toLowerCase() === name.toLowerCase()
      )
    },

    getLastProduct() {
      const self = this
      const sortedProducts = self.products.sort((productA, productB) => {
        return productA.updated_at > productB.updated_at ? -1 : 1
      })
      return sortedProducts[0]
    },
    /**
     * Sorts products by id
     */
    sortById: function() {
      let self = this
      self.products.sort((productA, productB) => {
        if (productA.id < productB.id) {
          return -1
        }
        if (productA.id > productB.id) {
          return 1
        }
        return 0
      })
    },

    /**
     * Set RFIDS
     */
    setRfids: function(rfids) {
      var self = this

      rfids.forEach(function(rfid) {
        self.rfidProducts[rfid.code] = {
          id: rfid.id,
          stock: rfid.stock,
          rfidEntityType: rfid.rfid_entity_type,
          rfidEntityID:
            rfid.rfid_entity_type === 'KioskProduct'
              ? rfid.product_id
              : rfid.rfid_entity_id,
          rfidSubEntityID: rfid.rfid_sub_entity_id,
          categoryName: rfid.category_name,
          brandName: rfid.brand_name
        }
      })
    },

    /**
     * Start hard refresh countdown
     */
    startHardRefreshCountdown: function() {
      console.log('Start hard refresh countdown')

      this.reloadTimeout = setTimeout(function() {
        console.log('App hard refresh by user')
        caches.delete('kiosk-api-cache')
        location.reload(true)
        if (self.$gsClient) {
          self.$gsClient.track('App hard refresh by user')
        }
      }, 5000)
    },

    /**
     * Stop hard refresh countdown
     */
    stopHardRefreshCountdown: function() {
      console.log('Stop hard refresh countdown')

      clearTimeout(this.reloadTimeout)
    },

    /**
     * Start soft refresh countdown
     */
    startSoftRefreshCountdown: function() {
      console.log('Start soft refresh countdown')

      this.reloadTimeout = setTimeout(function() {
        console.log('App soft refresh by user')
        location.reload(true)
        if (self.$gsClient) {
          self.$gsClient.track('App soft refresh by user')
        }
      }, 5000)
    },

    /**
     * Stop soft refresh countdown
     */
    stopSoftRefreshCountdown: function() {
      console.log('Stop soft refresh countdown')

      clearTimeout(this.reloadTimeout)
    },

    /**
     * Global swipe event
     */
    swipeHandler: function(event) {
      if (this.$route.name === 'home') {
        this.$root.$emit('app-swipe', event)
      }
    },

    /**
     * Reset idle timeout when an action is made
     */
    idleHandler: function(resetRefresh = true) {
      clearTimeout(this.idleTimeout)

      let ms = 1000
      if (this.$config.PAYMENT_GATEWAY.NAME === 'Aeropay') {
        ms = 5000
      }

      this.idleTimeout = setTimeout(
        this.toggleIdleModal,
        this.$config.IDLE_DELAY * ms
      )

      if (resetRefresh) {
        clearTimeout(this.refreshTimeout)
        this.refreshTimeout = setTimeout(function() {
          console.log('App soft refresh after delay')
          if (self.$gsClient) {
            self.$gsClient.track('Session ended', {
              reason: 'App soft refresh after delay.'
            })
          }
          location.reload(true)
        }, this.$config.REFRESH_DELAY * 1000)
      }
    },

    /**
     * Reset session
     */
    resetSession: function() {
      clearInterval(this.restartInterval)

      this.blockPointer(false)
      this.featuredProductsModal = false
      this.showIdleModal = false
      this.showOosModal = false
      this.cart = []
      this.setGlobalCart(this.cart)
      this.spotlightSelected = false
    },

    /**
     * Restart session
     */
    restartSession: function() {
      if (this.showIdleModal === true) {
        // Session is ended due to inactivity
        if (self.$gsClient) {
          self.$gsClient.track('Session ended', {
            reason: 'Session started over'
          })
        }
      }

      // Reset session values
      this.resetSession()
      this.resetActiveCartSession()

      // Go back to home
      this.$router.push({ name: 'home' })
    },
    /**
     * execute hard reload products
     */
    executeHardReloadProducts: function() {
      const today = new Date().toLocaleDateString()
      if (this.lasExecutionHardReload !== today) {
        this.countExecutionHardReload = 0
      }
      if (this.countExecutionHardReload === this.numMaxOfExecutionHardReload) {
        return false
      }
      if (
        this.quantityOfProductsFrontend === 0 &&
        this.quantityOfProductsBackend === 0
      ) {
        return false
      }
      if (!this.quantityOfProductsFrontend || !this.quantityOfProductsBackend) {
        return false
      }
      if (this.quantityOfProductsFrontend === this.quantityOfProductsBackend) {
        return false
      }
      this.countExecutionHardReload++
      this.lasExecutionHardReload = new Date().toLocaleDateString()
      return true
    },
    /**
     * Show/hide cursor
     */
    setCursor: function() {
      if (
        window.location.href.indexOf('.com') > -1 ||
        window.location.href.indexOf('.app') > -1 ||
        window.location.href.indexOf('.nicarao.dev') > -1 ||
        window.location.href.indexOf(':8080') > -1
      ) {
        this.hideCursor = false
      }
    },

    /**
     * Show/hide background mask
     */
    showBackgroundMask: function() {
      return this.$config.KIOSK_MODE !== 'brand'
    },

    /**
     * Toggle idle modal after inactivity
     */
    toggleIdleModal: function() {
      if (this.getIsFullScreenProduct()) {
        console.log('Modal is disabled in full screen mode')
        return
      }
      console.log(
        'CHECKING IF KIOSK IS IDLE',
        this.isTouched ||
          this.videoPlaying > 0 ||
          (this.$route.name === 'home' && this.cart.length === 0)
      )
      if (
        this.isTouched ||
        this.videoPlaying > 0 ||
        (this.$route.name === 'home' && this.cart.length === 0)
      ) {
        // If screen is touched, do no show modal
        this.idleHandler(false)
      } else {
        this.showIdleModal = !this.showIdleModal

        if (this.showIdleModal === true) {
          var self = this

          self.showOosModal = false

          // Reset restart timer
          this.restartTimer = Number(this.$config.RESTART_DELAY)

          // Restart timer count down
          this.restartInterval = setInterval(function() {
            self.restartTimer--

            // Restart session when timer finishes
            if (self.restartTimer <= 0) {
              if (self.$gsClient) {
                self.$gsClient.track('Session ended', {
                  reason: 'Idle Session timeout'
                })
              }
              self.restartSession()
            }
          }, 1000)

          // GS event tracker
          if (self.$gsClient) {
            self.$gsClient.track('Show Idle Modal')
          }
        } else {
          clearInterval(this.restartInterval)
        }
      }
    },

    /**
     * Toggle ls modal
     */
    toggleLsModal: function() {
      this.showLsModal = !this.showLsModal
    },

    /**
     * Toggle oos modal
     */
    toggleOosModal: function() {
      this.showOosModal = !this.showOosModal
    },

    /**
     * Show a visual feedback when a click is made
     */
    touchFeedback: function(event) {
      var feedback = $('.touch-feedback')

      // Get touch coordinates
      var x = event.pageX
      var y = event.pageY

      feedback.css({ top: y, left: x })

      // Animate
      var tl = new TimelineLite()
      tl.pause()

      tl.fromTo(
        feedback,
        0.4,
        {
          scale: 0
        },
        {
          scale: 1
        },
        0
      )

      tl.fromTo(
        feedback,
        0.2,
        {
          alpha: 1
        },
        {
          alpha: 0
        },
        0.2
      )

      tl.call(function() {
        tl.kill()

        tl = null
        feedback = null
      })

      tl.play()
    },

    /**
     * Update the current product to show
     */
    updateCurrentProduct: function() {
      let self = this
      let productString = localStorage.getItem('currentProduct')
      let currentProduct = JSON.parse(productString)
      let indexProduct = this.products.findIndex(p => p.id === this.product_Id)
      if (indexProduct >= 0) {
        this.products[indexProduct].isFeatured = true
        localStorage.setItem(
          'currentProduct',
          JSON.stringify(this.products[indexProduct])
        )
        return
      }
      if (currentProduct) {
        if (currentProduct.id !== this.product_Id) {
          try {
            this.$http.get(`products/${this.product_Id}`).then(response => {
              let remoteProduct = response.data.product
              remoteProduct.isFeatured = true
              self.products.push(remoteProduct)
              localStorage.setItem(
                'currentProduct',
                JSON.stringify(remoteProduct)
              )
            })
          } catch (error) {
            Sentry.captureException(error)
          }
        } else {
          currentProduct.isFeatured = true
          self.products.push(currentProduct)
        }
      } else {
        try {
          this.$http.get(`products/${this.product_Id}`).then(response => {
            currentProduct = response.data.product
            currentProduct.isFeatured = true
            self.products.push(currentProduct)
            localStorage.setItem(
              'currentProduct',
              JSON.stringify(currentProduct)
            )
          })
        } catch (error) {
          Sentry.captureException(error)
        }
      }
    },

    /**
     * Fetch brands
     */
    fetchBrandsOnline: function() {
      try {
        // Fetch brands
        this.$http.get('brands?per_page=9999').then(response => {
          this.brands = response.data.brands
        })
      } catch (error) {
        Sentry.captureException(error)
      }
    },

    /**
     * Method to activate the source from Spotlight
     */
    selectSpotlight() {
      this.spotlightSelected = true
    }
  },
  beforeDestroy() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }

    document.removeEventListener('index_triggered', this.handleIndexTriggered)
    document.removeEventListener('rfid_triggered', this.handleRfidTriggered)
  }
}
</script>

<style scoped lang="scss">
.app {
  position: relative;
  width: 100%;
  height: 100%;

  &.hide-cursor * {
    cursor: url('~@/assets/img/cursor.png'), none !important;
  }

  &--tablet {
    font-size: 24px;
  }
}

.app-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  z-index: 1;

  &__media {
    display: block;
    position: relative;
    width: 100%;
    height: 100%;

    object-fit: cover;
    z-index: 1;
  }
}

.view-container {
  position: relative;
  width: 100%;
  height: 100%;
  background: rgba($bluecharcoal, 0.5);
  z-index: 2;

  &--with-backgroun-on-top {
    background: rgba(0, 0, 0, 0);
  }

  &--with-mask {
    background: rgba($bluecharcoal, 0.95);
  }

  &.disabled-overlay {
    background: transparent;
  }
}

.idle-modal {
  text-align: center;

  &__title {
    margin: 0;

    font: 2.5em/1 var(--font-extralight);
  }

  &__actions {
    display: flex;
    margin: 2em 0 1em;
    position: relative;

    flex-direction: row;
    justify-content: center;

    @at-root .app--tablet & {
      font-size: 1.2em;
    }
  }

  &__button {
    margin: 0 0 0 1.67em;
    position: relative;
    width: 16.67em;
    height: 4.17em;

    background: none;
    border: none;
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

      background: var(--main-color);
      border-radius: 2.08em;
      transform: translate3d(-50%, 0, 0);
    }

    &:first-child {
      margin-left: 0;
    }
  }

  &__timer {
    color: rgba($white, 0.3);
    font-size: 0.6em;
    text-transform: uppercase;
    letter-spacing: 0.15em;

    @at-root .app--tablet & {
      font-family: var(--font-bold);
      font-size: 0.8em;
    }

    b {
      color: $white;
      font-weight: normal;
    }
  }
}

/deep/ .idle-modal .modal-container {
  width: 600px;
}

.oos-modal,
.ls-modal {
  text-align: center;

  &__title {
    margin: 0;

    font: 2.5em/1 var(--font-extralight);
  }

  &__text {
    margin: 20px 0;
  }

  &__actions {
    display: flex;
    margin: 2em 0 0;
    position: relative;

    flex-direction: row;
    justify-content: center;

    @at-root .app--tablet & {
      font-size: 1.2em;
    }
  }

  &__button {
    margin: 0 0 0 1.67em;
    position: relative;
    width: 16.67em;
    height: 4.17em;

    background: none;
    border: none;
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

      background: var(--main-color);
      border-radius: 2.08em;
      transform: translate3d(-50%, 0, 0);
    }

    &:first-child {
      margin-left: 0;
    }
  }
}

/deep/ .oos-modal .modal-container,
/deep/ .ls-modal .modal-container {
  width: 600px;
}

.touch-feedback {
  position: fixed;
  top: -80px;
  left: -80px;

  pointer-events: none;
  z-index: 9999;

  &:before {
    display: block;
    margin: -40px 0 0 -40px;
    position: absolute;
    top: 50%;
    left: 50%;
    width: 80px;
    height: 80px;

    background: rgba($white, 0.2);
    border-radius: 50%;
    content: '';
  }
}

.link-offline {
  overflow: hidden;
  position: fixed;
  bottom: 20px;
  right: 20px;
  width: 24px;
  height: 24px;

  background-image: url('~@/assets/img/icon-offline.svg');
  background-position: center;
  background-repeat: no-repeat;
  background-size: contain;
  border-radius: 50%;
  z-index: 20;

  text-indent: -999em;
}

.license-number {
  position: fixed;
  bottom: 15px;
  left: 30px;

  opacity: 0.4;
  z-index: 4;

  font-size: 11px;
  letter-spacing: 0.05em;
  line-height: 1;
  text-transform: uppercase;
}

.copyright {
  position: fixed;
  bottom: 5px;
  right: 10px;

  opacity: 0.4;
  z-index: 4;

  font-size: 11px;
  letter-spacing: 0.05em;
  line-height: 1;
  text-transform: uppercase;

  @at-root .app--tablet & {
    bottom: 15px;
    right: 20px;

    font-size: 13px;
  }

  &__logo {
    display: inline-block;
    margin: -28px 0 0 5px;
    width: 60px;
    height: auto;

    cursor: pointer;
    vertical-align: top;

    @at-root .app--tablet & {
      margin-top: -38px;
      width: 80px;
    }
  }

  &.is-offline {
    right: 60px;
  }
}

.block-pointer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  background: red;
  opacity: 0;
  z-index: 99999;
}

.copyright {
  &.glowing {
    animation: glow 1s linear infinite;
  }
}

@keyframes glow {
  0% {
    opacity: 100%;
  }

  50% {
    opacity: 50%;
  }

  100% {
    opacity: 100%;
  }
}
</style>
