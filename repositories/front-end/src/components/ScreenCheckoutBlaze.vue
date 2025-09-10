<template>
  <div id="screen-checkout-blaze">
      <form class="checkout__form">
        <div class="checkout__field  checkout__field--half">
          <input v-if="showName" v-model="firstname" placeholder="First name" data-osk-options="disableReturn" class="input-osk" />
        </div><!-- .checkout__field -->

        <div class="checkout__field  checkout__field--half">
          <input v-if="showName" v-model="lastname" placeholder="Last name" data-osk-options="disableReturn" class="input-osk" />
        </div><!-- .checkout__field -->

        <div
          v-if="isEmail || showEmail"
          class="checkout__field checkout__field--half"
        >
          <input
            v-model="email"
            type="email"
            placeholder="Email"
            data-osk-options="disableReturn"
            class="input-osk"
          />
        </div>

        <div v-show="showBirthday" class="checkout__field  checkout__field--half inputs-container">
          <input v-model="birthdayMonth" v-on:input="inputBirthday" placeholder="MM" size="2" maxlength="2" data-osk-options="disableReturn" class="input-osk inputs-container__input" />
          <div class="inputs-container__separator"></div>
          <input v-model="birthdayDay" v-on:input="inputBirthday" placeholder="DD" size="2" maxlength="2" data-osk-options="disableReturn" class="input-osk inputs-container__input" />
          <div class="inputs-container__separator"></div>
          <input v-model="birthdayYear" v-on:input="inputBirthday" placeholder="YYYY" size="4" maxlength="4" data-osk-options="disableReturn" class="input-osk inputs-container__input" />
        </div><!-- .checkout__field -->

        <div v-show="showPhoneNumber || isPhone" class="checkout__field  checkout__field--half">
          <input v-model="phoneNumber" placeholder="Phone Number" data-osk-options="disableReturn" class="input-phone" />
        </div><!-- .checkout__field -->

        <div class="checkout-container" v-bind:class="{'checkout-container--qr-mode' : aeropayPermalink }" >
          <template v-if="$config.PAYMENT_GATEWAY.NAME === 'Aeropay' && $config.ENABLE_REQUEST_TAXES">
            <div class="checkout__button aeropay--qr--chekout" v-if="aeropayPermalink">
            <div class="aeropay--qr--chekout-section-a">
              COMPLETE CHECKOUT ON
              YOUR MOBILE DEVICE
            </div>
            <div class="aeropay--qr--chekout-section-b" >
              <div class="container-qr-background" >
                <qrcode-vue margin="0" class="qr-code" :value="aeropayPermalink" size="120"></qrcode-vue>
              </div>
            </div>
            <div class="aeropay__background_qr"></div>
          </div>
          <button v-if="!aeropayPermalink"
          v-on:click="proceedCheckout(true)"
          v-bind:class="{ 'checkout__button--sending': creatingOrder , 'checkout__button--offline':connected == false}"
          type="button"
          :disabled="connected == false"
          class="checkout__button"
          >
            <span class="checkout__button__text">
              {{connected === false? 'OFFLINE': 'Pay with Aeropay'}}
            </span>
            <span class="checkout__button__background" v-bind:class="{ 'checkout__button--left':connected == true }" ></span>
          </button>

          </template>
        <button
          v-on:click="proceedCheckout(false)"
          v-bind:class="{ 'checkout__button--sending': isSending , 'checkout__button--offline':connected == false}"
          type="button"
          :disabled="connected == false"
          class="checkout__button checkout__button--right"
          >
          <span class="checkout__button__text">
            {{connected === false? 'OFFLINE': 'Confirm order'}}
          </span>
          <span class="checkout__button__background"></span>
        </button>
        </div>
      </form>
  </div>
</template>

<script>
import * as Sentry from '@sentry/vue'
import $ from 'jquery'
import OFFLINE from '../mixins/offlineMixin'
import AeropayEvent from '../mixins/aeropayEvent'
import ScreenKeyboardEvents from '../mixins/keyboardEvents'
import QrcodeVue from 'qrcode.vue'
export default {
  name: 'ScreenCheckoutBlaze',
  components: {
    QrcodeVue
  },
  props: [
    'cart'
  ],
  mixins: [OFFLINE, AeropayEvent, ScreenKeyboardEvents],
  data () {
    return {
      birthdayDay: null,
      birthdayMonth: null,
      birthdayYear: null,
      customerId: null,
      email: null,
      firstname: null,
      isSending: false,
      lastname: null,
      phoneNumber: null,
      showBirthday: false,
      showPhoneNumber: false,
      showEmail: false,
      showName: false,
      verificationPhoneAndEmail: false,
      verifyBirthday: false,
      listCustomers: []
    }
  },
  computed: {
    birthday: function () {
      if (!this.birthdayYear || !this.birthdayMonth || !this.birthdayDay) {
        return false
      }

      return this.birthdayYear + '-' + this.birthdayMonth.padStart(2, '0') + '-' + this.birthdayDay.padStart(2, '0')
    },
    checkoutType () {
      return this.$config.STORE_CHECKOUT_TYPE
    },
    isEmail () {
      return this.checkoutType === 'email'
    },
    isPhone () {
      return this.checkoutType === 'phone' || (this.checkoutType !== 'email')
    }
  },
  watch: {
    birthdayDay: function () {
      this.birthdayDay = this.birthdayDay.replace(/[^0-9]*/gi, '').substring(0, 2)
    },
    birthdayMonth: function () {
      this.birthdayMonth = this.birthdayMonth.replace(/[^0-9]*/gi, '').substring(0, 2)
    },
    birthdayYear: function () {
      this.birthdayYear = this.birthdayYear.replace(/[^0-9]*/gi, '').substring(0, 4)
    },
    phoneNumber: function () {
      this.phoneNumber = this.phoneNumber.replace(/[^0-9]*/gi, '').substring(0, 10)
    }
  },
  methods: {
    /**
     * Input birth day
     */
    inputBirthday: function (e) {
      var target = e.srcElement || e.target

      var maxLength = parseInt(target.attributes['maxlength'].value, 10)
      var myLength = target.value.length

      if (myLength >= maxLength) {
        var next = target.nextElementSibling

        while (next) {
          if (next === null) {
            break
          }

          if (next.tagName.toLowerCase() === 'input') {
            $(next).click()
            break
          }

          next = next.nextElementSibling
        }
      } else if (myLength === 0) {
        var previous = target.previousElementSibling

        while (previous) {
          if (previous == null) {
            break
          }

          if (previous.tagName.toLowerCase() === 'input') {
            $(previous).click()
            break
          }

          previous = previous.previousElementSibling
        }
      }
    },

    /**
     * Proceed checkout
     */
    proceedCheckout: function (useAeropay) {
      var self = this

      if (this.isSending || this.creatingOrder) {
        return
      }

      if (self.showName && (!this.firstname || !this.lastname)) {
        this.$emit('error', 'Please fill in the fields.')
        this.showBirthday = true
        return
      }

      if (this.isEmail && (!this.email)) {
        this.$emit('error', 'Please fill in the fields.')
        this.showPhoneNumber = false
        this.showBirthday = false
        return
      }
      if (this.isPhone && (!this.phoneNumber)) {
        this.$emit('error', 'Please fill in the fields.')
        this.showPhoneNumber = false
        this.showBirthday = false
        return
      }
      if (useAeropay) {
        this.creatingOrder = true
      } else {
        this.isSending = true
      }

      // Search customer
      this.$http.get('/customers', {
        params: {
          email: self.email,
          phone: self.phoneNumber
        }
      })
        .then(function (response) {
          // Check response
          var customers = response.data.customers
          var matchedCustomer = null

          if (!customers || customers.length === 0) {
            throw new Error('no_customer_found')
          } else if (customers.length > 1) {
            if (self.isPhone && !self.verificationPhoneAndEmail) {
              self.listCustomers = customers
              self.verificationPhoneAndEmail = true
              throw new Error('birthday_needed')
            } else if (self.isEmail) {
              throw new Error('staff_needed')
            } else if (!self.birthday) {
              throw new Error('birthday_needed')
            } else if (!self.verifyBirthday) {
              // Check if one customer match the birthday
              matchedCustomer = self.listCustomers.filter(function (customer) {
                return customer.birthday === self.birthday
              })

              if (matchedCustomer.length === 0 && self.isPhone) {
                self.verifyBirthday = true
                throw new Error('birthday_not_found_needed')
              }

              if (matchedCustomer.length > 1 && self.isPhone) {
                self.verifyBirthday = true
                throw new Error('name_needed')
              }

              // Found only one customer
              if (matchedCustomer.length === 1) {
                self.customerId = matchedCustomer[0].customer_id
                self.email = matchedCustomer[0].email
              }
            }

            // If customer not found, check phone number
            if (self.customerId === null) {
              if (!self.phoneNumber) {
                throw new Error('phone_needed')
              } else if (!self.showName && (self.phoneNumber !== false && self.phoneNumber !== null && self.phoneNumber !== '')) {
                // Check if one customer match the phone number id
                matchedCustomer = customers.filter(function (customer) {
                  return customer.phone === self.phoneNumber
                })

                // Found only one customer
                if (matchedCustomer.length === 1) {
                  self.customerId = matchedCustomer[0].customer_id
                  self.email = matchedCustomer[0].email
                }
              } else if (self.showName) {
                // Check if one customer match the name and lastname id
                matchedCustomer = self.listCustomers.filter(function (customer) {
                  return customer.first_name === self.firstname && customer.last_name === self.lastname
                })

                if (matchedCustomer.length === 0) {
                  throw new Error('staff_needed')
                }

                if (matchedCustomer.length > 1) {
                  throw new Error('staff_needed_duplicate')
                }

                // Found only one customer
                if (matchedCustomer.length === 1) {
                  self.customerId = matchedCustomer[0].customer_id
                  self.email = matchedCustomer[0].email
                }
              }
            }
            self.verificationPhoneAndEmail = false
          } else if (customers.length === 1) {
            self.customerId = customers[0].customer_id
            self.email = customers[0].email
          }

          // Customer still not found, call a staff member
          if (self.customerId === null) {
            throw new Error('staff_needed')
          } else {
            if (useAeropay) {
              self.createOrderAeropay()
            } else {
              self.sendOrder()
            }
          }
        })
        .catch(function (error) {
          console.log(error)
          Sentry.captureException(error)

          self.isSending = false
          self.creatingOrder = false

          if (self.$gsClient && self.isName) {
            self.$gsClient.track('Proceed checkout', {
              first_name: self.firstname.trim(),
              last_name: self.lastname.trim()
            }, {
              error: error.message
            })
          }

          var mess = ''
          switch (error.message) {
            case 'no_customer_found':
              mess = 'We couldn\'t find you. Did you enter your info correctly?'
              return self.$emit('error', mess)

            case 'birthday_needed':
              mess = 'Please confirm your identity by providing your birth date.'
              self.showPhoneNumber = false
              self.showBirthday = true
              return self.$emit('error', mess)

            case 'phone_needed':
              mess = 'Please confirm your identity by providing your phone number.'
              self.showPhoneNumber = true
              self.showBirthday = true
              return self.$emit('error', mess)

            case 'email_needed':
              mess = 'Please confirm your identity by providing your email.'
              self.showPhoneNumber = true
              self.showBirthday = true
              self.showEmail = true
              return self.$emit('error', mess)

            case 'name_needed':
              mess = 'Duplicate profiles found, enter your name and lastname.'
              self.showPhoneNumber = false
              self.showBirthday = true
              self.showName = true
              return self.$emit('error', mess)

            case 'birthday_not_found_needed':
              mess = 'We couldn\'t find you, Please confirm your identity by providing your name and lastname.'
              self.showPhoneNumber = false
              self.showBirthday = true
              self.showName = true
              return self.$emit('error', mess)

            case 'staff_needed':
              mess = 'We can\'t find you. Please ask a staff member to help you by checking your account.'
              if (self.isName) {
                self.showPhoneNumber = true
                self.showBirthday = true
              }
              return self.$emit('error', mess)

            case 'staff_needed_duplicate':
              mess = 'Found duplicate profiles, ask a staff member for help.'
              return self.$emit('error', mess)

            default:
              var serverStatus = parseInt(error.response.status)
              switch (serverStatus) {
                case 400:
                case 404:
                case 419:
                  mess = 'We couldn\'t process your order. We can\'t connect to the point of sale system.'
                  return self.$emit('error', mess)

                case 500:
                case 503:
                case 504:
                case 511:
                  mess = 'We couldn\'t process your order. Please try again later. Internal server error.'
                  return self.$emit('error', mess)

                default:
                  mess = 'Sorry, we couldn\'t process the request at this time.'
                  return self.$emit('error', mess)
              }
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
        customer_email: self.email,
        items: items
      }

      console.log(self.$config.CHECKOUT_MESSAGE ? self.$config.CHECKOUT_MESSAGE : 'Please pick up your order at the designated register.')
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

          if (self.$gsClient) {
            self.$gsClient.track('Proceed checkout',
              {order: order},
              {status: 'error', error: error.response})
          }

          var serverStatus = parseInt(error.response.status)
          var mess = ''

          switch (serverStatus) {
            case 400:
            case 404:
              mess = 'Couldn\'t process your order. The service is offline. Please ask a staff member to help you.'
              return self.$emit('error', mess)

            case 500:
            case 502:
              var str = error.response.data.message
              var findText = 'error:'
              var res = str.split(findText)
              var keyword = res[1].trim()

              switch (keyword) {
                case 'CUSTOMER_NOT_FOUND':
                  mess = 'We couldn\'t process your order. Customer not found.'
                  break

                case 'INSUFFICIENT_SELLABLE_QUANTITY':
                  mess = 'Order items quantity not available in stock. Please remove some items from your order.'
                  break

                default:
                  mess = 'An error occurred processing the order. Please ask a staff member to help you.'
                  break
              }

              return self.$emit('error', mess)

            case 422:
              var errors = error.response.data.errors
              mess = 'We couldn\'t process your order. '
              for (error in errors) {
                switch (error) {
                  case 'customer_id':
                    mess += 'Customer not found. '
                    break

                  case 'items.product_id':
                    mess += 'Product not found. '
                }
              }
              return self.$emit('error', mess)

            default:
              mess = 'An error occurred during the order creation. Please ask a staff member to help you.'
              return self.$emit('error', mess)
          }
        })
    }
  }
}
</script>

<style scoped lang="scss">
  .checkout-container{
    position: fixed;
    display: flex;
    align-items: flex-end;
    right: 45px;
    bottom: 45px;

    &--qr-mode{
      flex-direction: column;
      align-items: center;
    }
  }
  .checkout__button{
    position: relative !important;
    right: 0;
    bottom: 0;

    &--right{
      margin-left: 40px;
    }

    &--left{
      background: $ebonyclay;
    }
  }
  .aeropay-qr{
    display: inline-block;
    background: #ffffff;
  }
  .aeropay--qr--chekout{
      width: 100%;
      min-height: 170px;
      display: flex;
      justify-content: space-between;
      height: auto;
      padding: 20px 0px 20px 20px;
      position: relative;
      margin-bottom: 32px;

      &-section-a{
        width: 80% !important;
        line-height: 30px;
        display: flex !important;
        align-items: center;
      }
      &-section-b{
        width: 20% !important;
        margin-right: 32px;
      }
  }

  .checkout__button{
    min-width: 300px;
  }

  .aeropay__background_qr{
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1;
    background: #fff;
    color: #fff;
    opacity: .3;
    border-radius: 2em;
  }

  .qr-code{
    width: 125px;
    height: 125px;
    padding: 2px;
    background: #fff;
  }
</style>
