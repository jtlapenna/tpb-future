<template>
  <div class="container">
    <div class="inner-container">
      <div class="button-container">
        <div class="keep-shopping">
          <active-cart-keep-shopping-button  @click="keepShopping"></active-cart-keep-shopping-button>
        </div>
        <div class="finalize-order">
          <active-cart-finalize-order-button @click="proceedCheckout"></active-cart-finalize-order-button>
        </div>
      </div>
    </div>
  </div>

</template>

<script>


import ActiveCartKeepShoppingButton from './ActiveCartKeepShoppingButton.vue'
import ActiveCartFinalizeOrderButton from './ActiveCartFinalizeOrderButton.vue'
import ActiveCartButton from './ActiveCartButton.vue'
import dayjs from 'dayjs'
import * as Sentry from '@sentry/vue'
import api from '../api/api'
import { mapGetters, mapMutations } from 'vuex'
import $ from 'jquery'

export default {
  name: 'ActiveCartKeepShoppingFinalizeOrderFooter',
  components: { ActiveCartButton, ActiveCartFinalizeOrderButton, ActiveCartKeepShoppingButton },
  props: [
    'keepShopping',
  ],
  data () {
    return {
      isSending: false,
      customerId: null,
      email: null,
    }
  },
  computed: {
    ...mapGetters('cart', ['phoneNumber', 'getGlobalCart', 'getCart']),
    directCheckoutEnabled () {
      return this.$config.DIRECT_CHECKOUT
    },

    cart() {
      return this.getGlobalCart
    }

  },
  watch: {},
  filters: {},
  created: function () {},
  mounted: function () {},
  beforeDestroy() {},
  methods: {
    ...mapMutations('cart', ['resetActiveCartSession', ]),
    proceedCheckout: async function () {
      var self = this

      if (this.isSending) {
        return
      }
      // if (this.storeCustomerId) {
      //   this.directCheckout()
      //   return
      // }
      // TODO: validate phone number.

      this.isSending = true

      // Search customer
      this.$http
        .get('/customers', {
          params: {
            phone: self.phoneNumber
          }
        })
        .then(async response => {
          // Check response
          var customers = response.data.customers

          if (!customers || customers.length === 0) {
            await self.handleNotFound(response)
          } else if (customers.length > 0) {
            self.customerId = customers[0].customer_id
            self.email = customers[0].email

          }
          // Customer still not found, call a staff member
          if (self.customerId === null) {
            const created = await self.handleNotFound()
            if (created) {
              self.sendOrder()
            }
          } else {
            self.sendOrder()
          }
        })
        .catch(function (error) {
          console.error(error)
          Sentry.captureException(error)

          self.isSending = false

          if (self.$gsClient) {
            self.$gsClient.track(
              'Proceed checkout',
              {
                first_name: self.firstname,
                last_name: self.lastname
              },
              {
                error: error.message
              }
            )
          }

          var mess = ''

          switch (error.message) {
            case 'phone_needed':
            case 'phoneNumber_needed':
              self.showPhoneNumber = true
              self.showBirthday = true
              mess = 'Please confirm your identity by providing your phone number.'
              return self.$emit('error', mess)

            case 'staff_needed':
              mess = 'We can\'t find you. Please ask a staff member to help you by checking your account.'
              return self.$emit('error', mess)

            case 'underage':
              mess = 'You must be 21 or older to continue.'
              return self.$emit('error', mess)

            case 'server_offline':
              mess = 'We couldn\'t process your order. We can\'t connect to the point of sale system.'
              return self.$emit('error', mess)

            case 'server_internal':
              mess = 'We couldn\'t process your order. We can\'t connect to the point of sale system.'
              return self.$emit('error', mess)

            default:
              var serverStatus = parseInt(error.response.status)
              switch (serverStatus) {
                case 400:
                case 404:
                case 419:
                  mess = 'We couldn\'t find you at this time. We can\'t connect to the point of sale system.'
                  return self.$emit('error', mess)

                case 500:
                case 502:
                  let str = error.response.data.message
                  let findText = 'error:'
                  let res = str.split(findText)
                  let keyword = res[1].trim()

                  switch (keyword) {
                    case 'Unauthorized':
                      mess = 'We couldn\'t validate your identity. The point of sale is offline. Please try again later.'
                      break

                    case 'No Customer Found':
                      mess = 'We couldn\'t find you. You may need to create an account please ask a Staff member to help you.'
                      break

                    default:
                      mess = 'We couldn\'t find you. We can\'t connect to the point of sale system. Please ask a staff member to help you by checking your account.'
                      break
                  }
                  return self.$emit('error', mess)
                case 503:
                case 504:
                case 511:
                  mess = 'We couldn\'t find you at this time. The point of sale is offline. Please try again later.'
                  return self.$emit('error', mess)

                default:
                  mess = 'We couldn\'t find you. Did you enter your info correctly?'
                  return self.$emit('error', mess)
              }
          }
        })
    },

    async handleNotFound () {
      const self = this
      if (this.directCheckoutEnabled) {

        // TODO: This is wrong, the endpoint that finds the customer should just create the customer in dutchie if
        // it doesn't exist and return that, no need for the frontend to handle this.
        try {
          const customer = await api.createCustomers({
            phone: self.phoneNumber,
          })
          console.log('RESPONSE FROM CREATING CUSTOMER', customer)
          self.customerId = customer.customer_id
          self.isSending = false
          return true
        } catch (error) {
          Sentry.captureException(error)
          let serverStatus = parseInt(error.response.status)

          switch (serverStatus) {
            case 400:
            case 404:
            case 419:
            case 422:
              throw new Error('server_offline')

            case 500:
            case 502:
            case 503:
              throw new Error('server_internal')

            default:
              throw new Error('staff_needed')
          }
        }
      } else {
        throw new Error('staff_needed')
      }
    },

    sendOrder: function (isDirect = false) {
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
        items
      }

      // Post order
      console.log('Sending order', order)
      self.$http
        .post('/orders', {
          order: {...order, cart_id: self.getCart && self.getCart.id},
        })
        .then(function (response) {
          console.log(response)
          self.isSending = false
          let message = self.$config.CHECKOUT_MESSAGE && self.$config.CHECKOUT_MESSAGE.trim() !== ''
            ? self.$config.CHECKOUT_MESSAGE
            : 'Please pick up your order at the designated register.'
          self.successHandler(message)
          if (self.$gsClient) {
            self.$gsClient.track(
              'Proceed checkout',
              { order: order },
              { status: 'success' }
            )
          }
          // Retry sending printer request on failure
          const sendPrinterRequest = function (receipt) {
            if (self.retryAttemptsPrinter <= 0) {
              console.log('Max retry attempts reached. Printer request failed.')
              return
            }

            self.$httpPrinter.post('', {
              receipt: receipt
            }).then(function (response) {
              const splitOrderId = receipt.order_id.split('-')
              const orderId = parseInt(splitOrderId[1])

              const currentDate = new Date()
              const formattedDate = currentDate.getFullYear() + '-' +
                ('0' + (currentDate.getMonth() + 1)).slice(-2) + '-' +
                ('0' + currentDate.getDate()).slice(-2) + ' ' +
                ('0' + currentDate.getHours()).slice(-2) + ':' +
                ('0' + currentDate.getMinutes()).slice(-2) + ':' +
                ('0' + currentDate.getSeconds()).slice(-2)
              self.$http
                .put(`/orders/${orderId}`, {
                  printed_id: response.data.PRINTID,
                  printed_date: formattedDate
                }).then(function (response) {
                console.log(response)
              }).catch(function (error) {
                console.log(error)
              })
            }).catch(function (error) {
              console.log(error)
              console.log(`Printer request failed. Retrying in 5 seconds... Attempts remaining: ${self.retryAttemptsPrinter}`)
              self.retryAttemptsPrinter--
              if (self.retryAttemptsPrinter > 0) {
                setTimeout(function () {
                  sendPrinterRequest(receipt)
                }, 5000)
              }
            })
          }

          if (response.data.order.data != null) {
            sendPrinterRequest(response.data.order.data.receipt)
          }
        })
        .catch(function (error) {
          // Order creation error
          Sentry.captureException(error)
          console.log(error.response.data.message, error.response)
          self.isSending = false

          if (self.$gsClient) {
            self.$gsClient.track(
              'Proceed checkout',
              { order: order },
              { status: 'error', error: error.response }
            )
          }

          var serverStatus = parseInt(error.response.status)
          var mess = ''

          switch (serverStatus) {
            case 400:
            case 403:
            case 404:
            case 419:
            case 420:
            case 500:
            case 502:
            case 503:
              mess = 'We couldn\'t process your order. We can\'t connect to the point of sale system.'
              return self.$emit('error', mess)

            default:
              mess = 'An error occured during the order creation. Please ask a staff member to help you.'
              return self.$emit('error', mess)
          }
        })
    },

    // TODO: I had to duplicate this code from ScreenCheckout because there's no way to reuse through a Vuex
    // And doing the refactor will take too much time.
    successHandler: function(message) {
      this.result = message

      // Track checkout on HEAP
      if (this.$config.HEAP_ID) {
        /* eslint-disable */
        var cartSize = 0;
        let productsAnalytics = [];
        this.cart.forEach(function (product) {
          cartSize += product.qty;
          // heap.track('Cart Products', { item: product.product.name, quantity: product.qty })
          productsAnalytics.push({
            id: product.product.sku,
            name: product.product.name,
            brand: product.product.brand ? product.product.brand.name : "",
            category: product.product.catalog_category.name,
            quantity: product.qty,
            price: +product.price.value
          });
        });

        if (this.$gsClient) {
          this.$gsClient.track("Purchase", {
            event_category: "Sales",
            total_spend: this.cartTotal,
            cart_size: cartSize,
            currency: "USD",
            items: productsAnalytics
          });
        }
        // heap.track('Cart Products', {Cart_Products: this.cart})
        /* eslint-enable */
      }

      // Hide keyboard
      $('#osk-container:visible .osk-hide').click()

      // Reset session
      this.$root.$emit('reset-session')
      this.resetActiveCartSession()
      this.$router.push({name: 'thank-you'})
    }
  }
}
</script>

<style scoped lang="scss">
.container {
  width: 100%;
  height: 100%;
  margin: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.inner-container {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
}

.small-text {

  font: 1.3em/1 var(--font-extralight);

  &.second {
    margin-bottom: 3rem;
  }
}

.button-container {
  display: flex;
}

.keep-shopping {
  margin-right: 0.8rem;
}

.finalize-order {
  margin-left: 0.8rem;
}

</style>
