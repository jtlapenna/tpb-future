<template>
  <div id="screen-checkout-active-cart">
    <form class="checkout__form">
      <!-- fields if auto checkout it's set  -->

      <!-- .checkout__field -->
      <!-- fields if auto checkout it's NOT set  -->
      <div class="checkout__form__fields" style="width: 100%;">
        <div class="checkout__field checkout__field--half">
          <input
            v-model="phoneNumber"
            placeholder="Phone Number"
            data-osk-options="disableReturn"
            class="input-phone"
          />
        </div>

      <button
        v-on:click="submit"
        v-bind:class="{
          'checkout__button--sending': isSending,
          'checkout__button--offline': connected == false
        }"
        type="button"
        :disabled="connected == false"
        class="checkout__button"
      >
        <span class="checkout__button__text">{{
            connected === false ? "OFFLINE" : "Submit"
          }}</span>
        <!-- .checkout__button__text -->
        <span class="checkout__button__background"></span>
      </button>
      </div>
    </form>
  </div>
</template>
<script>

import $ from 'jquery'
import { mapActions, mapGetters, mapMutations } from 'vuex'
import * as Sentry from '@sentry/vue'
import api from '../api/api'

export default {
  name: 'ScreenCheckoutActiveCartCreator',
  props: ['cart'],
  data () {
    return {
      isSending: false,
      phoneNumber: null,
    }
  },
  computed: {
    ...mapGetters('cart', ['isFromActiveCartActivation', 'getCart', 'getGlobalCart', 'isCartActivated', 'wasCartCreated', 'isFromCheckout', 'isFromSaveCart']),
    ...mapGetters('products', ['getFrozenPrices']),
    ...mapGetters('products', ['products']),
    isActiveCartFeatureActivated: function() {
      return this.$config.ENABLED_CONTINUOUS_CART
    },

    cart: function() {
      return this.getGlobalCart
    }
  },
  watch: {
    phoneNumber: function () {
      this.phoneNumber = this.phoneNumber
        .replace(/[^0-9]*/gi, '')
        .substring(0, 10)
    }
  },
  filters: {},
  created: function () {
  },
  mounted: function () {
    console.log(this.products)
  },
  destroyed() {
    this.hideKeyboard()
    this.setIsFromActiveCartActivation(false);
  },
  methods: {
    ...mapMutations('cart', ['setCart', 'setPhoneNumber', 'setIsActiveCartNotFound', 'setIsFromActiveCartActivation', 'setIsCartActivated', 'resetActiveCartSession', 'setIsAddingItemsFromRetrievedCart']),
    ...mapActions('cart', ['fetchActiveCart', 'createOrMergeActiveCart', 'cartExists']),
    submit() {
      this.hideKeyboard()
      if (!this.isActiveCartFeatureActivated) {
        console.log('Active cart feature is not activated. User should not be in this view.')
        return
      }

      if (this.isFromCheckout) {
        this.checkoutOrShowCartWithItems()
        return
      }

      if (this.isFromActiveCartActivation) {
        this.retrieveCart()
        return
      }

      if (this.isFromSaveCart) {
        this.createOrMergeCart()
      }
    },

    hideKeyboard() {
      $('#osk-container-number:visible .osk-hide').click()
      $('#osk-container-number').css('visibility', 'hidden').hide()
    },

    checkoutOrShowCartWithItems() {
      this.cartExists(this.phoneNumber).then( (exists) => {
        if (exists) {
          this.createOrMergeActiveCart({phoneNumber: this.phoneNumber, cart: this.getGlobalCart}).then(() => {
            this.addItemsToCart()
            this.$router.push({name: 'cart'})
          })
        } else {
          this.proceedCheckout()
        }
      })
    },

    createOrMergeCart() {
      this.createOrMergeActiveCart({phoneNumber: this.phoneNumber, cart: this.getGlobalCart}).then(() => {
        if (this.wasCartCreated) {
           this.$router.push({name: 'keep-shopping'})
        } else {
          this.addItemsToCart()
          this.$router.push({name: 'cart'})
        }
      }).catch((error) => {
        console.log(error)
        this.$router.push({
          name: 'cart',
        })
      })
    },

    retrieveCart() {
      let self = this
      this.fetchActiveCart(this.phoneNumber).then(() => {
        this.addItemsToCart()
        this.$router.push({
          name: 'cart',
        })
      }).catch((error) => {
        this.$router.push({
          name: 'cart',
        })
      })
    },

    addItemsToCart() {
      const self = this
      this.$root.$emit('reset-session')
      let activeCartProducts = self.getCart.cart_items
      this.products.forEach((product) => {
        let matchingCartItem = activeCartProducts.find(cartItem => cartItem.product_id === product.id)

        if (matchingCartItem) {
          const frozenPrice = self.getFrozenPrices(product)
          this.$root.$emit('add-to-cart', {
            product: product,
            price: frozenPrice.frozenPrice,
            discountPrice: frozenPrice.discountPrice,
            qty: matchingCartItem.quantity
          })
        }
      })
      this.setIsAddingItemsFromRetrievedCart(false)


    },

    // TODO: I had to duplicate this code from ScreenCheckout because there's no way to reuse through a Vuex
    // And doing the refactor will take too much time.
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

    async handleNotFound() {
      const self = this

      // TODO: This is wrong, the endpoint that finds the customer should just create the customer in dutchie if
      // it doesn't exist and return that, no need for the frontend to handle this.
      try {
        const customer = await api.createCustomers({
          phone: self.phoneNumber
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
