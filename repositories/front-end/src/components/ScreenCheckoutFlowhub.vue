<template>
  <div id="screen-checkout-flowhub">
      <form class="checkout__form">
        <div class="checkout__field">
          <input v-model="phoneNumber" placeholder="Phone Number" data-osk-options="disableReturn" class="input-phone" />
        </div><!-- .checkout__field -->

          <button
          v-on:click="proceedCheckout"
          v-bind:class="{ 'checkout__button--sending': isSending , 'checkout__button--offline':connected == false}"
          type="button"
          :disabled="connected == false"
          class="checkout__button">
          <span class="checkout__button__text">
            {{connected === false? 'OFFLINE': 'Confirm order'}}
          </span><!-- .checkout__button__text -->
          <span class="checkout__button__background"></span>
        </button>
      </form>
  </div>
</template>

<script>
import { parsePhoneNumberFromString } from 'libphonenumber-js'
import OFFLINE from '../mixins/offlineMixin'
import * as Sentry from '@sentry/vue'
import ScreenKeyboardEvents from '../mixins/keyboardEvents'

export default {
  name: 'ScreenCheckoutFlowhub',
  props: [
    'cart'
  ],
  mixins: [OFFLINE, ScreenKeyboardEvents],
  data () {
    return {
      isSending: false,
      phoneNumber: null
    }
  },
  computed: {
    formattedPhone: function () {
      return parsePhoneNumberFromString(this.phoneNumber, 'US')
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

      console.log(this.formattedPhone, this.formattedPhone.isValid())

      if (!this.phoneNumber) {
        this.$emit('error', 'Please fill in the field.')
        return
      } else if (!this.formattedPhone || !this.formattedPhone.isValid()) {
        this.$emit('error', 'Please use a valid phone number.')
        return
      }
      this.isSending = true

      // Search customer
      this.$http.get('/customers', {
        params: {
          phone: self.formattedPhone.formatNational()
        }
      })
        .then(function (response) {
          // Check response
          var customers = response.data.customers

          if (!customers || customers.length === 0) {
            throw new Error('no_customer_found')
          } else if (customers.length > 1) {
            throw new Error('many_customers_found')
          } else if (customers.length === 1) {
            self.customerId = customers[0].customer_id
            self.firstname = customers[0].first_name
            self.lastname = customers[0].last_name
            self.email = customers[0].email
          }

          // Customer still not found, call a staff member
          if (self.customerId === null) {
            throw new Error('staff_needed')
          } else {
            self.sendOrder()
          }
        })
        .catch(function (error) {
          console.log(error)
          Sentry.captureException(error)

          self.isSending = false

          if (self.$gsClient) {
            self.$gsClient.track('Proceed checkout', {
              phone: self.formattedPhone.formatNational()
            }, {
              error: error.message
            })
          }

          if (error.message === 'many_customers_found') {
            self.$emit('error', 'We found several customers with  that phone number ' + self.formattedPhone.formatNational() + '. Please ask a staff member to help you by checking your account.')
          } else if (error.message === 'staff_needed') {
            self.$emit('error', 'We can\'t find you. Please ask a staff member to help you by checking your account.')
          } else {
            // Could find the customer
            self.$emit('error', 'We couldn\'t find you with  that phone number ' + self.formattedPhone.formatNational() + '. Did you enter your info correctly?')
          }
        })
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
        customer_id: self.customerId,
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
          Sentry.captureException(error)
          console.log(error.response.data.message, error.response)
          self.isSending = false
          const regex = /error:(.+)/i
          const match = regex.exec(error.response.data.message)

          if (match && match.length > 1) {
            const errorMessage = match[1].trim()
            if (errorMessage === 'order for customer with phone or medId already exists') {
              self.$emit('error', 'There is already an open order under this customer. Please complete the existing order to place a new one.')
            } else {
              self.$emit('error', 'An error occured during the order creation. Please ask a staff member to help you.')
            }
          }
          if (self.$gsClient) {
            self.$gsClient.track('Proceed checkout', { order: order }, { status: 'error', error: error.response })
          }
        })
    }
  }
}
</script>

<style scoped lang="scss">
</style>
