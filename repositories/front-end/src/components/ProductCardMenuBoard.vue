<template>
  <div class="card-container">
    <div class="card-container__top">
      <div>
        <p
          class="card-name "
          v-if="product.name !== null"
        >
          {{ trimTitle(product.name, this.maxCharactersProduct) }}
        </p>
      </div>
      <div class="card-container__categories">
        <p class="product-category" v-if="product.brand && product.brand.name !== null">{{trimBrand(product.brand.name, this.maxCharactersCategory) }}</p>
        <p class="product-category" v-for="(category, index) in types" :key="index">{{ category.value.length > productsPerPage ? `${category.value.slice(0, productsPerPage)}...` : category.value }}</p>
      </div>
    </div>

    <div class="card-container__middle">
      <product-image
        v-bind:image="product.thumb_image"
        :promo="
          product.store_product_promotions.length > 0
            ? product.store_product_promotions[0].promotion
            : null
        "
        v-bind:category="product.catalog_category.name"
        v-bind:size="'layout'"
        class="margin-0"
      />
    </div>

    <div class="card-container__bottom">
     <div class="card-container__thc">
       <p>{{ thc }}</p>
     </div>

      <p class="card-container__from">
        {{ productPrice ? 'FROM' : '' }}
      </p>

      <div class="card-container__price"
      >
        {{ productPrice.includes('.00') ? productPrice.slice(0, productPrice.indexOf('.00')) : productPrice }}
      </div>
    </div>
  </div>
</template>

<script>
import ProductImage from '@/components/ProductImage'
// We don't use Vue2 mixin because we don't know the side-effects of that, we just use the functionality directly.
import {addPercentage} from '../mixins/isCardWithAttributes'

export default {
  components: {
    ProductImage
  },
  props: {
    product: {
      type: Object,
      default: () => null
    }
  },
  computed: {
    types: function () {
      return 'ungrouped' in this.product.attribute_values ? this.product.attribute_values.ungrouped.filter(attributeValue => attributeValue.name === 'TYPE') : []
    },
    thc: function() {
      let thc = 'ungrouped' in this.product.attribute_values ? this.product.attribute_values.ungrouped.find(attributeValue => attributeValue.name === 'THC') : undefined
      const thcValue = addPercentage(thc.value)
      return thc && thc.value !== '0.0' ? `THC : ${thcValue}` : ''
    },
    productPrice: function() {
      return !this.product.product_values[0] ? '' : `$${Number(this.product.product_values[0].value).toFixed(2)}`
    }
  },
  methods: {
    trimTitle: function(text, maxCharacters) {
      let biggerThanQuantity
      text.length > maxCharacters ? biggerThanQuantity = true : biggerThanQuantity = false
      let trimText = text.split(' ')
      let sum = 0
      let finalString = []
      trimText.map((word) => {
        sum += word.length
        if (sum <= maxCharacters) {
          finalString.push(word)
        }
      })
      let previewText = finalString

      if (previewText[previewText.length - 1] === '') {
        finalString.pop()
        previewText.pop()
      }
      if (!/\w/.test(previewText[previewText.length - 1]) || previewText[previewText.length - 1] === '_') {
        finalString.pop()
      }

      if (biggerThanQuantity === true) {
        if (trimText.length === 1) {
          return `${trimText.join(' ').slice(0, maxCharacters)}...`
        } else if (finalString.join(' ') === text) {
          return finalString.join(' ')
        } else {
          return `${finalString.join(' ')}...`
        }
      } else {
        return finalString.join(' ')
      }
    },
    trimBrand: function(text, maxCharacters) {
      if (text.length >= maxCharacters) {
        let trimBrand = text.split(' ')
        return `${trimBrand.join(' ').slice(0, maxCharacters)}...`
      } else {
        return text
      }
    }
  },
  data: () => {
    return {
      maxProductLength: 5,
      productsPerPage: 18,
      maxCharactersProduct: 31,
      maxCharactersCategory: 18
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

.card {
  &-container {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 40px;
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 1.5rem 2rem;

    &__top {
      display: flex;
      flex-direction: column;
      gap: 10px;
      height: 118px;
    }

    &__middle {
      display: flex;
      align-items: center;
      justify-content: center;
      flex-grow: 1;

      .margin-0 {
        margin-top: 0;
      }
    }

    &__bottom  {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: flex-end;
      text-align: center;
      gap: 15px;
      height: 118px;
    }

    &__categories {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 5px;
    }

    &__thc {
      color: var(--main-color);
      font: 24px var(--font-bold);
      height: 24px;
    }

    &__from {
      letter-spacing: 5px;
      margin: 0 -5px 0 0;
      font: 18px var(--font-regular);
      color: rgba($white, 0.4);
      height: 18px;
    }

    &__price {
      font: 32px var(--font-regular);
      height: 32px;
    }
  }
  &-name {
    color: $white;
    text-transform: uppercase;
    font: 20px var(--font-bold);
    text-align: center;
    word-break: break-word;
  }
}
p {
  margin: 0;
}

.product {
  &-category {
    border-left: 4px solid var(--main-color);
    text-align: center;
    padding: 5px 10px;
    text-transform: uppercase;
    font: 14px var(--font-bold);
    letter-spacing: 4px;
  }
}

.product-image {
  width: 50%;
  margin-top: 0;
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

@media screen and (min-width: 2560px) {
  .card {
    &-container {
      border-radius: 80px;
      padding: 3rem 4rem;

      &__top {
        gap: 20px;
        height: 236px;
      }

      &__bottom {
        gap: 30px;
        height: 236px;
      }

      &__categories {
        gap: 10px;
      }

      &__thc {
        font: 48px var(--font-bold);
        height: 48px;
      }

      &__from {
        letter-spacing: 10px;
        margin: 0 -10px 0 0;
        font: 36px var(--font-regular);
        height: 36px
      }

      &__price {
        font: 64px var(--font-regular);
        height: 64px;
      }
    }
    &-name {
      font: 40px var(--font-bold);
    }
  }
  .product {
    &-category {
      border-left: 4px solid var(--main-color);
      padding: 10px 20px;
      font: 28px var(--font-bold);
    }
  }
}

</style>
