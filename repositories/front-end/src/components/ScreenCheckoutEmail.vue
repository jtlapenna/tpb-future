<template>
  <div id="screen-checkout-email">
      <form class="checkout__form">
        <div class="checkout__field  checkout__field--half">
          <input v-model="firstname" placeholder="Firstname" data-osk-options="disableReturn" class="input-osk" />
        </div><!-- .checkout__field -->

        <div class="checkout__field  checkout__field--half">
          <input v-model="lastname" placeholder="Lastname" data-osk-options="disableReturn" class="input-osk" />
        </div><!-- .checkout__field -->

        <div class="checkout__field  checkout__field--full">
          <input
            v-model="email"
            v-bind:placeholder="$config.CUSTOMER_NOTIFICATION ? 'Email' : 'Email (optional)'"
            data-osk-options="disableReturn"
            class="input-osk" />
        </div><!-- .checkout__field -->

     <button
          v-on:click="proceedCheckout"
          v-bind:class="{ 'checkout__button--sending': isSending , 'checkout__button--offline':connected == false}"
          type="button"
          :disabled="connected == false"
          class="checkout__button"
          >
          <span class="checkout__button__text">
            {{connected === false? 'OFFLINE': 'Confirm order'}}
          </span><!-- .checkout__button__text -->
          <span class="checkout__button__background"></span>
        </button>
      </form>
  </div>
</template>

<script>
import OFFLINE from '../mixins/offlineMixin'
export default {
  name: 'ScreenCheckoutTreez',
  props: [
    'cart'
  ],
  mixins: [OFFLINE],
  data () {
    return {
      firstname: null,
      email: null,
      isSending: false,
      lastname: null
    }
  },
  methods: {
    /**
     * Proceed checkout
     */
    proceedCheckout: function () {
      var self = this

      if (this.isSending) {
        return
      }

      if (!this.firstname ||
          !this.lastname ||
          (this.$config.CUSTOMER_NOTIFICATION && !this.email)) {
        this.$emit('error', 'Please fill in the fields.')
        return
      } else if (this.email && !this.validEmail(this.email)) {
        this.$emit('error', 'Please use a valid email address.')
        return
      }

      this.isSending = true

      // Things to check ?

      // Send order
      self.sendOrder()
    },

    /**
     * Send order to API
     */
    sendOrder: function () {
      var self = this

      // Format order
      var items = []
      self.cart.forEach(function (line) {
        var item = {
          product_id: line.product.id,
          product_value_id: line.price.id,
          quantity: line.qty
        }

        items.push(item)
      })

      var order = {
        customer_name: self.firstname + ' ' + self.lastname,
        customer_email: self.email,
        items: items
      }

      // Post order
      console.log('Sending order', order)

      self.$http.post('/orders', {
        order: order
      })
        .then(function (response) {
          console.log(response)
          self.isSending = false
          let message = self.$config.CHECKOUT_MESSAGE && self.$config.CHECKOUT_MESSAGE.trim() !== '' ? self.$config.CHECKOUT_MESSAGE : 'Please pick up your order at the designated register.'
          self.$emit('success', message)
          if (self.$gsClient) {
            self.$gsClient.track('Proceed checkout', { order: order }, { status: 'success' })
          }
        })
        .catch(function (error) {
          // Order creation error
          console.log(error.response.data.message, error.response)
          self.isSending = false
          self.$emit('error', 'An error occured during the order creation. Please ask a staff member to help you.')
          if (self.$gsClient) {
            self.$gsClient.track('Proceed checkout', { order: order }, { status: 'error', error: error.response })
          }
        })
    },

    /**
     * Validate email
     * @param {String} email
     */
    validEmail: function (email) {
      // eslint-disable-next-line
      var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      return re.test(email)
    }
  }
}
</script>

<style scoped lang="scss">
</style>
