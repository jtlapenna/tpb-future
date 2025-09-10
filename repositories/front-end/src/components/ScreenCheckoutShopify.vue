<template lang="">
  <div id="screen-checkout-shopify">
    <div  class="cart__qr_code__container">
      <span class="cart__qr_code__container__label">
        Scan the following QR code to proceed with the checkout
      </span>
      <div class="cart__qr_code">
        <qrcode-vue :value="permaLink" size="350"></qrcode-vue>
      </div>

    </div>
  </div>
</template>
<script>
import QrcodeVue from 'qrcode.vue'
import {
  getOrderChanges
} from '@/api/messaging'

export default {
  name: 'ScreenCheckoutShopify',
  components: {
    QrcodeVue
  },
  data: () => ({
    orderCode: null,
    unsubscribeFromOrder: null
  }),
  props: ['cart', 'discountCode'],
  computed: {
    isShopify () {
      return this.$config.POS_TYPE === 'shopify'
    },
    attributes () {
      return this.orderCode && this.kioskId ? `attributes[order_id]=${this.orderCode}&attributes[catalog_id]=${this.kioskId}` : ''
    },
    discount () {
      return this.attributes !== '' && this.discountCode != null ? `&discount=${this.discountCode}` : ''
    },
    kioskId () {
      return this.$config.API.CATALOG_ID
    },
    shopUrl () {
      return this.$config.STORE_URL
    },
    permaLink () {
      if (this.$config.STORE_URL) {
        let baseURl = this.$config.STORE_URL
        baseURl = baseURl.startsWith('https://') ? baseURl : `https://${baseURl}`
        this.cart.forEach((cartItem, index) => {
          const {product, qty} = cartItem
          baseURl = `${baseURl}${index === 0 ? '/cart/' : ','}${product.sku}:${qty}`
        })
        if (this.attributes) {
          baseURl = `${baseURl}?${this.attributes}`
        }
        if (this.discount) {
          baseURl = `${baseURl}${this.discount}`
        }
        return baseURl
      }
      return ''
    }
  },
  created () {
    // this.$emit('success', 'Your order has been completed')
    this.orderCode = this.generateCode()
    this.listeForOrderUpdate()
  },
  beforeDestroy () {
    if (this.unsubscribeFromOrder != null) {
      this.unsubscribeFromOrder()
    }
  },

  methods: {
    generateCode (length = 20) {
      let result = ''
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
      for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length))
      }
      return result
    },
    listeForOrderUpdate () {
      let self = this
      const env = self.currentEnv.name !== 'prod' ? self.currentEnv.name : null
      this.unsubscribeFromOrder = getOrderChanges({
        kioskId: this.kioskId,
        orderId: this.orderCode,
        env}, (data) => {
        console.log(data)
        if (data) {
          let message = self.$config.CHECKOUT_MESSAGE && self.$config.CHECKOUT_MESSAGE.trim() !== '' ? self.$config.CHECKOUT_MESSAGE : 'Please pick up your order at the designated register.'
          this.$emit('success', message)
        }
      })
    }

  }
}
</script>
<style lang="scss">
  .cart{
  &__qr_code__container{
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding: 1em;
      &__label{
        text-align: center;
        margin-bottom: 16px;
        font-size: 16px;
      }
    }
  }
  .cart__qr_code{
    background: white;
    padding: 1em;
  }
  </style>
