<template>
  <div v-bind:class="{ 'slider-container-brand': useBrandSpotlight, 'slider-container': !useBrandSpotlight }">
    <hooper
      v-if="useBrandSpotlight"
      :autoPlay="true"
      :playSpeed="speed"
      :transition="500"
      :infiniteScroll="false"
    >
      <slide
        v-for="(brand, index) in brandWithImages"
        :key="index"
      >
        <div
          class="image-container-brand"
          v-bind:class="{'image-container-witout-cards': useNoCardsConfig }"
          v-if="url_Brand_Image && !url_Brand_Video"
          :style="{'background-image': 'url(' + url_Brand_Image + ')'}"
          @click="redirectBrand(brand)"
        >
        </div>
        <div
          class="video-container-brand" v-bind:class="{'complete-width': useNoCardsConfig }"
          v-if="url_Brand_Video"
          @click="redirectBrand(brand)"
        >
          <video
            :id="'video' + index"
            class="video"
            autoplay loop muted
            :name="'video' + index"
            width="99%"
            height="100%"
            disablepictureinpicture
          >
            <source :src="url_Brand_Video">
          </video>
        </div>
      </slide>
    </hooper>
    <hooper
      v-if="!useBrandSpotlight"
      :autoPlay="true"
      :playSpeed="speed"
      :transition="500"
      :infiniteScroll="false"
    >
      <slide v-for="(currentProduct, index) in productsWithImagesOrVideos" :key="index"            @click="redirectProduct(currentProduct)"
>
          <product-image
                    @click="redirectProduct(currentProduct)"

            v-bind:image="currentProduct.thumb_image"
            :promo="
              currentProduct.store_product_promotions.length > 0
                ? currentProduct.store_product_promotions[0].promotion
                : null
            "
            v-bind:category="currentProduct.catalog_category.name"
          />

        <div
                  @click="redirectProduct(currentProduct)"
          class="slide-product-info"
        >
          <div class="product-brand">{{ currentProduct.brand ? currentProduct.brand.name : '' }}</div>

          <div class="product-name">{{ currentProduct.name }}</div>

            <div
              v-if="currentProduct.product_values && currentProduct.product_values[0]"
              class="product-price"
            >
              <small>From</small> {{ currentProduct.product_values[0].value | formatPrice }}
            </div>
      </div>
    </slide>
  </hooper>
  <div v-if="useBrandSpotlight" class="slidder-buttons-products"  v-bind:class="{ 'top-144': !useNoCardsConfig, 'top-58': useNoCardsConfig }" >
    <button class="slider-button" @click="redirectBrand(brandWithImages[0])" >View Products</button>
  </div>
  <div v-if="!useBrandSpotlight" v-bind:class="[{'slidder-buttons-products-cards' : fixed_button === true, 'slidder-buttons-products': fixed_button !== true, 'margin-top-product': fixed_button !== true }]" >
    <button class="slider-button" @click="redirectProduct({id: productsWithImagesOrVideos[0].id})" v-bind:class="[{'padding-button-cards' : fixed_button === true }]">View Product</button>
  </div>
  </div>
</template>

<script>
// eslint-disable-next-line no-unused-vars
/* eslint-disable no-unused-vars */

import {
  Hooper,
  Slide,
  Navigation as HooperNavigation,
  Pagination as HooperPagination
} from 'hooper'
import 'hooper/dist/hooper.css'
import productImage from '@/components/ProductImage'
export default {
  name: 'Slider',
  components: {
    Hooper,
    Slide,
    HooperPagination,
    productImage
  },
  props: ['useBrandSpotlight', 'products', 'brands', 'product_Id', 'brand_Id', 'url_Brand_Video', 'url_Brand_Image', 'fixed_button', 'useNoCardsConfig', 'isGeneratingIndex'],
  data () {
    return {
      speed: 30000,
      currentSlide: null,
      currentBrandUrl: null
    }
  },
  mounted: function () {
    this.currentSlide = 0
  },
  methods: {
    redirectProduct: function (product) {
      if (this.isGeneratingIndex) {
        return 0
      }
      this.$root.$emit('spotlight-selected')
      if (product.stock === 0) {
        this.$root.$emit('setOOSModal', true)
      }
      this.$root._router.push({
        name: 'product',
        params: { id: product.id, fromEspotlight: true }
      })
    },
    redirectBrand (brand) {
      if (this.isGeneratingIndex) {
        return 0
      }
      this.$root.$emit('spotlight-selected')
      this.$root._router.push({
        name: 'brands',
        query: { brand: brand.id },
        params: { fromEspotlight: true }
      })
    },
    redirectAllProducts () {
      this.$root.$emit('spotlight-selected')
      this.$root._router.push({ name: 'products', params: { fromEspotlight: true } })
    },
    invalidUrl (url) {
      let chunkArray = url.split('.')
      if (chunkArray.length > 0) {
        if (
          chunkArray[chunkArray.length - 1] === 'mp4' ||
          chunkArray[chunkArray.length - 1] === 'webm' ||
          chunkArray[chunkArray.length - 1] === 'ogg'
        ) {
          return false
        }
        return true
      }
      return true
    }
  },
  computed: {
    productsWithImagesOrVideos: function () {
      let products = this.products
        .filter((p) => p.id === this.product_Id)
      // Sort each value from less to greather
      products.forEach((element) => {
        element.product_values = element.product_values.sort((a, b) => {
          return Number(a.value) - Number(b.value)
        })
      })
      return products
    },
    brandWithImages: function () {
      if (this.brands) {
        let brands = this.brands
          .filter((b) => b.id === this.brand_Id)
        this.$emit('onUpdateBrandLogo', brands[0] && brands[0].logo && brands[0].logo.url ? brands[0].logo.url : null)
        return brands
      } else {
        return [{
          id: this.brand_Id
        }]
      }
    }
  },
  watch: {
    currentSlide (newVal, oldVal) {
      setTimeout(() => {
        this.currentBrandUrl = this.brandWithImages[newVal] && this.brandWithImages[newVal].logo ? this.brandWithImages[newVal].logo.url : null
        this.$emit('onUpdateBrandLogo', this.currentBrandUrl)
      }, 1000)
    }
  },
  filters: {
    formatPrice: function (price) {
      let numPrice = Number(price).toFixed(2)
      numPrice = numPrice.includes('.00') ? numPrice.slice(0, numPrice.indexOf('.00')) : numPrice
      return '$' + numPrice
    }
  }
}
</script>

<style lang="scss">
.product-brand {
  color: rgba(255, 255, 255, 0.3);
  font-size: 25px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  text-align: center;
}

.product-name {
  margin: 0.1em 0;
  color: #ffffff;
  font-size: 35px;
  text-align: center;
}

.slide-product-info {
  color: white;
  position: absolute;
  width: 100%;
  z-index: 1000;
  bottom: 0px;
  font-family: muliextralight;
}

.product-price {
  color: rgba(255, 255, 255, 0.5);
  font-size: 30px;
  text-align: center;
  text-transform: uppercase;
}

.hooper {
  height: 52vh !important;
  position: relative;
}

.slider-image {
  max-width: 100%;
  height: auto;
}

.video-container {
  display: flex;
  align-items: center;
  justify-items: center;
  background-repeat: no-repeat;
  background-size: contain;
  background-position: center;
  height: 43vh;
  display: none;
}

.video-container{
  height: 100%;
  width: 100%;
}

.image-container{
  width: 350px !important;
  height: 350px !important;
}

.image-container-no-cards{
  width: 34vh !important;
  height: 34vh !important;
}

.image-container-no-cards > .promotion {
  left: 150px !important;
}

.is-active > .image-container,
.video-container,
.image-container-brand,
.video-container-brand {
  display: block;
}

.image-container-brand,
.video-container-brand {
  display: flex;
  align-items: center;
  justify-items: center;
  height: 400px;
  width: 550px;
  background-repeat: no-repeat;
  background-size: contain;
  background-position: center;
}

.image-container-witout-cards{
  width: 100% !important;
  height: 462px !important;
}

.image-container{
  border-radius: 50%;
  background-color: white;
}

.hooper-slide{
  display: flex;
  justify-content: center;

}

.slider-container {
  height: 26vh;
  position: relative;
}

.slider-container-brand {
  position: relative;
}

.slidder-buttons-products {
  display: flex;
  justify-content: center;
  position: relative;
  top: -97px;
  font: 1em/4em var(--font-extrabold);
}

.slidder-buttons-products-cards{
  position: fixed !important ;
  bottom: 211px;
  left: 142px;
  font: 1em/4em var(--font-extrabold);
}

.slider-button {
  border: none;
  background-color: var(--main-color);
  border-radius: 2em;
  display: inline-block;
  cursor: pointer;
  color: #fcfaf7;
  padding: 0px 40px 0px 40px;
  font-weight: bold;
  text-decoration: none;
  line-height: 1.5;
  font-size: 20px !important;
  text-transform: uppercase;
  padding-top: 15px;
  padding-bottom: 15px;
}

.slider-button:active {
  position: relative;
  top: 1px;
}

.promotion {
  width: 150px;
  height: 150px;
  padding: 1em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
  left: 0px;
  top:10px;
  font-family: var(--font-regular);
  font-size: 18px;
  color: #fff;
  z-index: 200;
  background-color: var(--main-color);
  word-break: break-word;
  text-align: center;

}

.med-text{
  font-size: 32px;
}

.min-text {
  font-size: 17px;
}

.container-promotion{
  width: 400px;
  height: 400px;
  margin-top: 3vh;
}

.top-brand-button{
  top:-127px;
}

.margin-top-product{
  margin-top:1.3em;
}

.padding-button-cards{
  padding-top: 15px !important;
  padding-bottom: 15px !important;
}

.top-144{
  top: -144px;
}

.top-58{
  top: -58px;
}

.product-image{
  width: 100%;
  height: 100%;
  margin-top: 1rem;
  max-width: 350px;
  max-height: 350px;
}

.complete-width{
  width: 100% !important;
}
</style>
