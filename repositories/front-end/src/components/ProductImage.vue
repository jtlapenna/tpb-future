<template>
  <div :class="{ 'product-image--is-loaded': isLoaded }" class="product-image">
    <div
      v-if="promo != null && $config.ON_SALE_BADGES_ENABLED"
      :class="{ promotion: !isSmallLayout, 'promotion-small': isSmallLayout }"
    >
      <div
        class="text"
        :class="{
          'min-text': productPromo.length > 6 && productPromo.length < 10,
          'min-sm-text': productPromo.length > 10
        }"
      >
        {{ productPromo }}
      </div>
    </div>
    <!-- .promotion -->

    <div
      v-if="isMedicalOnly"
      :class="{
        'medical-only-condensed': isCondensedLayout && !isProductDetail,
        'medical-only-regular': !isCondensedLayout && !isProductDetail,
        'medical-only-detail': isProductDetail,
        'medical-only-size-small': isSmallLayout
      }"
    >
      <div class="text">
        MED ONLY
      </div>
    </div>

    <div class="product-image__inner">
      <img
        :src="image.url"
        @load="isLoaded = true"
        v-if="image"
        class="product-image__element product-image__element--img"
      />

      <div
        v-if="!image"
        :class="[
          'product-image__element--category-' + icon,
          'product-image__element--size-' + size
        ]"
        class="product-image__element product-image__element--blank"
      ></div>
    </div>
    <!-- .product-image__inner -->

    <div v-if="isFeatured" class="product-image__waves">
      <div class="product-image__wave"></div>
      <div class="product-image__wave"></div>
      <div class="product-image__wave"></div>
    </div>
    <!-- .product-image__waves -->
  </div>
  <!-- .product-image -->
</template>

<script>
export default {
  name: 'ProductImage',
  props: [
    'category',
    'promo',
    'image',
    'isFeatured',
    'size',
    'isMedicalOnly',
    'isProductDetail'
  ],
  data() {
    return {
      isLoaded: false,
      lazyImg: false
    }
  },
  computed: {
    icon() {
      if (this.category) {
        var icon = this.category.toLowerCase().replace(/s$|[ -]*/gi, '')

        // Hard coded edge case
        if (
          this.$config.SHOW_ALTERNATIVE_FLOWER_ICON &&
          this.category.toLowerCase() === 'flower'
        ) {
          return 'alternative-flower'
        } else if (icon === 'extract') {
          icon = 'concentrate'
        } else if (icon === 'cartridge') {
          icon = 'vape'
        }
        return icon
      } else {
        return false
      }
    },
    productPromo() {
      return this.promo.trim()
    },
    isMedical() {
      return this.isMedicalOnly
    },
    isCondensedLayout() {
      return this.$config.PRODUCT_UI === 'condensed'
    },
    isSmallLayout() {
      return this.size === 'small'
    }
  },
  created: function() {
    this.checkLoading()
  },
  methods: {
    checkLoading: function() {
      if (this.image) {
        if (!this.isLoaded) {
          var self = this

          if (this.image && this.isImageLoaded()) {
            this.isLoaded = true
          } else {
            setTimeout(function() {
              self.checkLoading()
            }, 100)
          }
        }
      } else {
        this.isLoaded = true
      }
    },
    isImageLoaded: function() {
      if (!this.lazyImg) {
        this.lazyImg = new Image()
        this.lazyImg.src = this.image.url
      }

      if (!this.lazyImg.complete) {
        return false
      }

      if (
        typeof this.lazyImg.naturalWidth !== 'undefined' &&
        this.lazyImg.naturalWidth === 0
      ) {
        return false
      }

      this.lazyImg = false

      return true
    }
  }
}
</script>

<style scoped lang="scss">
.product-image {
  position: relative;
  height: auto;

  background-image: url('~@/assets/img/image-loader.gif');
  background-position: center;
  background-repeat: no-repeat;
  background-size: 16px 16px;
  border-radius: 50%;
  flex-shrink: 0;

  &:before {
    display: block;
    padding-top: 100%;
    content: '';
  }

  &__inner {
    display: block;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    border-radius: 50%;
    opacity: 0;
    overflow: hidden;
    transition: opacity 0.2s ease;

    &:before {
      display: block;
      position: absolute;
      top: 1px;
      right: 1px;
      bottom: 1px;
      left: 1px;

      background: $white;
      border-radius: inherit;
      content: '';
    }
  }

  &__element {
    display: block;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    z-index: 2;

    &--blank {
      background-color: $charade;

      transform: rotateY(0.01deg);

      &:after {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 120px;
        height: 120px;

        background-image: url('~@/assets/img/category-default.svg');
        background-position: center;
        background-repeat: no-repeat;
        background-size: contain;
        content: '';
        opacity: 0.2;
        transform: translate3d(-50%, -50%, 0);
      }
    }

    &--size-small:after {
      width: 80px;
      height: 80px;
    }

    &--category-capsule:after {
      background-image: url('~@/assets/img/category-capsule.svg');
    }
    &--category-clone:after {
      background-image: url('~@/assets/img/category-clone.svg');
    }
    &--category-concentrate:after,
    &--category-extract:after {
      background-image: url('~@/assets/img/category-concentrate.svg');
    }
    &--category-drink:after {
      background-image: url('~@/assets/img/category-drink.svg');
    }
    &--category-edible:after {
      background-image: url('~@/assets/img/category-edible.svg');
    }
    &--category-flower:after {
      background-image: url('~@/assets/img/category-flower.svg');
    }
    &--category-merch:after {
      background-image: url('~@/assets/img/category-merch.svg');
    }
    &--category-other:after {
      background-image: url('~@/assets/img/category-other.svg');
    }
    &--category-plant:after {
      background-image: url('~@/assets/img/category-plant.svg');
    }
    &--category-preroll:after {
      background-image: url('~@/assets/img/category-preroll.svg');
    }
    &--category-seed:after {
      background-image: url('~@/assets/img/category-seed.svg');
    }
    &--category-tincture:after {
      background-image: url('~@/assets/img/category-tincture.svg');
    }
    &--category-topical:after {
      background-image: url('~@/assets/img/category-topical.svg');
    }
    &--category-vape:after,
    &--category-cartridge:after {
      background-image: url('~@/assets/img/category-vape.svg');
    }
    &--category-alternative-flower:after {
      background-image: url('~@/assets/img/category-alternativeflower.svg');
    }

    &--img {
      top: -3.2%;
      left: -3.2%;
      width: 106.4%;
      height: 106.4%;

      object-fit: cover;
    }
  }

  &__waves {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 150%;
    height: 150%;

    transform: translate3d(-50%, -50%, 0);
    z-index: 1;
  }

  &__wave {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    background: rgba($white, 0.1);
    border-radius: 50%;
    animation: wave-pulse 5s linear 0s infinite normal none;
    transform: scale(0);

    &:nth-child(1) {
      animation-delay: 1.5s;
    }
    &:nth-child(2) {
      animation-delay: 2.1s;
    }
    &:nth-child(3) {
      animation-delay: 2.7s;
    }
  }

  &--is-loaded {
    background-image: none;

    .product-image__inner {
      opacity: 1;
    }
  }
}

.promotion {
  width: 43.43%;
  height: 43.43%;

  min-width: 100px;
  min-height: 100px;

  padding: 0.6em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;

  font-family: var(--font-regular);
  color: #fff;
  left: -26px;
  top: -1px;
  z-index: 200;
  background-color: var(--main-color);
  word-break: break-word;
  text-align: center;

  .text {
    // margin: auto 0px;
    font-weight: 900;
    font-size: 24px;
    line-height: 1.2em;
  }
  .min-text {
    font-size: 17px;
  }
  .min-sm-text {
    font-size: 14px;
  }
}

.medical-only-condensed {
  width: 23.43%;
  height: 23.43%;

  min-width: 75px;
  min-height: 75px;

  padding: 0.6em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;

  font-family: var(--font-regular);
  color: #fff;
  left: -37px;
  top: 78px;
  z-index: 200;
  background-color: var(--secondary-color);
  word-break: break-word;
  text-align: center;

  .text {
    font-weight: 900;
    font-size: 18px !important;
    line-height: 1.2em;
  }
}

.medical-only-regular {
  width: 28.43%;
  height: 28.43%;

  min-width: 90px;
  min-height: 90px;

  padding: 0.6em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;

  font-family: var(--font-regular);
  color: #fff;
  left: -45px;
  top: 98px;
  z-index: 200;
  background-color: var(--secondary-color);
  word-break: break-word;
  text-align: center;

  .text {
    font-weight: 900;
    font-size: 20px;
    line-height: 1.2em;
  }
}

.medical-only-detail {
  width: 28.43%;
  height: 28.43%;

  min-width: 90px;
  min-height: 90px;

  padding: 0.6em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;

  font-family: var(--font-regular);
  color: #fff;
  left: -50px;
  top: 130px;
  z-index: 200;
  background-color: var(--secondary-color);
  word-break: break-word;
  text-align: center;

  .text {
    font-weight: 900;
    font-size: 20px;
    line-height: 1.2em;
  }
}

.medical-only-size-small {
  width: 18.43%;
  height: 18.43%;

  min-width: 60px;
  min-height: 60px;

  left: -30px;
  top: 35px;

  .text {
    font-weight: 900;
    font-size: 13px !important;
  }
}

.promotion-small {
  width: 43.43%;
  height: 43.43%;

  min-width: 70px;
  min-height: 70px;

  padding: 0.6em;
  border-radius: 50%;
  position: absolute;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;

  font-family: var(--font-regular);
  color: #fff;
  left: -15px;
  top: -20px;
  z-index: 200;
  background-color: var(--main-color);
  word-break: break-word;
  text-align: center;

  .text {
    // margin: auto 0px;
    font-weight: 900;
    font-size: 24px;
    line-height: 1.2em;
  }
  .min-text {
    font-size: 17px;
  }
  .min-sm-text {
    font-size: 14px;
  }
}
</style>
