<template>
  <div id="screen-checkout-leaflogix">
    <form class="checkout__form">
      <!-- fields if auto checkout it's set  -->

      <!-- .checkout__field -->
      <!-- fields if auto checkout it's NOT set  -->

      <div class="checkout__form__fields" style="width: 100%;">
           <div v-show="showName" class="checkout__field checkout__field--half">
        <input
          v-model="firstname"
          placeholder="Firstname"
          data-osk-options="disableReturn"
          class="input-osk"
        />
      </div>
      <!-- .checkout__field -->

      <div v-show="showLastName" class="checkout__field checkout__field--half">
        <input
          v-model="lastname"
          placeholder="Lastname"
          data-osk-options="disableReturn"
          class="input-osk"
        />
      </div>
        <div
        v-if="isEmail|| showEmail"
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
      <div v-if="isPhone" class="checkout__field checkout__field--half">
        <input
          v-model="phoneNumber"
          placeholder="Phone Number"
          data-osk-options="disableReturn"
          class="input-phone"
        />
      </div>

        <div
          v-show="showBirthday"
          class="checkout__field checkout__field--half inputs-container"
        >
          <input
            v-model="birthdayMonth"
            v-on:input="inputBirthday"
            placeholder="MM"
            size="2"
            maxlength="2"
            data-osk-options="disableReturn"
            class="input-osk inputs-container__input"
          />
          <div class="inputs-container__separator"></div>
          <input
            v-model="birthdayDay"
            v-on:input="inputBirthday"
            placeholder="DD"
            size="2"
            maxlength="2"
            data-osk-options="disableReturn"
            class="input-osk inputs-container__input"
          />
          <div class="inputs-container__separator"></div>
          <input
            v-model="birthdayYear"
            v-on:input="inputBirthday"
            placeholder="YYYY"
            size="4"
            maxlength="4"
            data-osk-options="disableReturn"
            class="input-osk inputs-container__input"
          />
        </div>
        <!-- .checkout__field -->

        <div
          v-show="showPhoneNumber && !isPhone"
          class="checkout__field checkout__field--half"
        >
          <input
            v-model="phoneNumber"
            placeholder="Phone Number"
            data-osk-options="disableReturn"
            class="input-osk"
          />
        </div>
        <!-- .checkout__field -->
      </div>

      <button
        v-on:click="proceedCheckout"
        v-bind:class="{
          'checkout__button--sending': isSending,
          'checkout__button--offline': connected == false
        }"
        type="button"
        :disabled="connected == false"
        class="checkout__button"
      >
        <span class="checkout__button__text">{{
          connected === false ? "OFFLINE" : "Confirm order"
        }}</span>
        <!-- .checkout__button__text -->
        <span class="checkout__button__background"></span>
      </button>
    </form>
  </div>
</template>
<script>
import $ from 'jquery'
import api from '../api/api'
import OFFLINE from '../mixins/offlineMixin'
import dayjs from 'dayjs'
import * as Sentry from '@sentry/vue'
import ScreenKeyboardEvents from '../mixins/keyboardEvents'

export default {
  name: 'ScreenCheckoutLeaflogix',
  props: ['cart'],
  mixins: [OFFLINE, ScreenKeyboardEvents],
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
      showName: false,
      showEmail: false,
      showLastName: false,
      showPhoneNumber: false,
      countCustomerDuplicatePhoneNumber: 0,
      retryAttemptsPrinter: 5
    }
  },
  created () {
    if (this.isName) {
      this.showBirthday = true
      this.showLastName = true
      this.showName = true
    } else if (this.isPhone) {
      self.showBirthday = false
      self.showName = false
      self.showLastName = false
      self.showPhoneNumber = true
    } else if (this.isEmail) {
      self.showBirthday = false
      self.showEmail = true
      self.showName = false
      self.showLastName = false
      self.showPhoneNumber = false
    }
  },
  mounted () {
    if (this.isPhone) {
      self.showBirthday = false
      self.showName = false
      self.showLastName = false
      self.showPhoneNumber = true
    }
  },
  computed: {

    isBirthDayUnderage   () {
      const llegallyDate = dayjs().subtract(21, 'year')
      const birthDate = dayjs(this.birthday, 'YYYY-MM-DD')
      return llegallyDate.isBefore(birthDate)
    },
    birthday: function () {
      if (!this.birthdayYear || !this.birthdayMonth || !this.birthdayDay) {
        return null
      }

      return (
        this.birthdayYear +
        '-' +
        this.birthdayMonth.padStart(2, '0') +
        '-' +
        this.birthdayDay.padStart(2, '0')
      )
    },
    genericName: function () {
      if (this.isEmail) {
        return `${this.email}`
      }
      if (this.isPhone) {
        return `${this.phoneNumber}`
      }
    },
    directCheckoutEnabled () {
      return this.$config.DIRECT_CHECKOUT
    },

    storeCustomerId () {
      return this.$config.STORE_CUSTOMER_ID
    },
    checkoutType () {
      return this.$config.STORE_CHECKOUT_TYPE
    },
    isEmail () {
      return this.checkoutType === 'email'
    },
    isName () {
      return this.checkoutType === 'name'
    },
    isPhone () {
      return this.checkoutType === 'phone'
    },
    fullName () {
      if (this.firstname && this.lastname) {
        return `${this.firstname} ${this.lastname}`
      } else {
        return false
      }
    },
    checkoutValue () {
      switch (this.checkoutType) {
        case 'email':
          return this.email
        case 'phone':
          return this.phoneNumber
        case 'name':
          return `${this.firstname} ${this.lastname}`
      }
    }
  },
  watch: {
    birthdayDay: function () {
      this.birthdayDay = this.birthdayDay
        .replace(/[^0-9]*/gi, '')
        .substring(0, 2)
    },
    birthdayMonth: function () {
      this.birthdayMonth = this.birthdayMonth
        .replace(/[^0-9]*/gi, '')
        .substring(0, 2)
    },
    birthdayYear: function () {
      this.birthdayYear = this.birthdayYear
        .replace(/[^0-9]*/gi, '')
        .substring(0, 4)
    },
    phoneNumber: function () {
      this.phoneNumber = this.phoneNumber
        .replace(/[^0-9]*/gi, '')
        .substring(0, 10)
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

    validateData () {
      console.log(this.isEmail, this.isName, this.isPhone)

      if (this.showBirthday && this.isBirthDayUnderage) {
        console.error('error on birthday')
        this.$emit('error', 'Please provide a valid birthday.')
        return false
      }

      if (this.isEmail && !this.email) {
        console.error('error on email')
        this.$emit('error', 'Please fill in the fields.')
        return false
      }
      if (this.isPhone && !this.phoneNumber) {
        console.error('error on phone')
        this.$emit('error', 'Please fill in the fields.')
        return false
      }
      if (this.isName && (!this.firstname || !this.lastname)) {
        console.error('error on all')
        this.$emit('error', 'Please fill in the fields.')
        this.showPhoneNumber = false
        this.showBirthday = false
        return false
      }
      if (this.isPhone && this.phoneNumber) {
        if (this.phoneNumber.length < 10 || this.phoneNumber.length > 10) {
          var mess = 'Incorrect phone number added, please correct the number and try again.'
          this.$emit('error', mess)
          return false
        }
      }
      return true
    },

    async handleNotFound () {
      const self = this
      if (this.directCheckoutEnabled) {
        if (!self.birthday && self.isName) {
          throw new Error('birthday_needed')
        }

        // TODO: This is wrong, the endpoint that finds the customer should just create the customer in dutchie if
        // it doesn't exist and return that, no need for the frontend to handle this.
        try {
          const customer = await api.createCustomers({
            first_name: self.firstname ? self.firstname : null,
            last_name: self.lastname,
            email: self.email ? self.email : null,
            phone: self.phoneNumber,
            birthday: self.birthday ? self.birthday : null
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
    /**
     * Proceed checkout
     */
    proceedCheckout: async function () {
      var self = this

      if (this.isSending) {
        return
      }
      // if (this.storeCustomerId) {
      //   this.directCheckout()
      //   return
      // }
      if (this.validateData() === false) {
        console.error('ERROR ON VALIDATION')
        return
      }

      this.isSending = true

      // Search customer
      this.$http
        .get('/customers', {
          params: {
            first_name: self.firstname,
            last_name: self.lastname,
            email: self.email,
            birthday: self.birthday,
            phone: self.phoneNumber
          }
        })
        .then(async response => {
          // Check response
          var customers = response.data.customers

          if (!customers || customers.length === 0) {
            await self.handleNotFound(response)
          } else if (customers.length > 1) {
            const matchedCustomer = self.getMatchedCustomer(customers)

            if (matchedCustomer.length >= 1) {
              self.customerId = matchedCustomer[0].customer_id
              self.email = matchedCustomer[0].email
            } else if (matchedCustomer.length > 1) {
              self.customerId = matchedCustomer[0].customer_id
              self.email = matchedCustomer[0].email
            }

            // if (!self.birthday) {
            //   this.handleDOBNeeded()
            // } else {
            //   if (self.isBirthDayUnderage) {
            //     throw new Error('underage')
            //   }

            //   // Check if one customer match the birthday

            //   console.log('birthday', self.birthday)
            //   console.log('birthday', dayjs(customers[0].birthday).format('YYYY-MM-DD').toString())
            //   matchedCustomer = customers.filter(function (customer) {
            //     return dayjs(customer.birthday).format('YYYY-MM-DD').toString() === self.birthday
            //   })

            //   console.log('Matched customers', matchedCustomer)

            //   // Found only one customer
            //   if (matchedCustomer.length === 1) {
            //     self.customerId = matchedCustomer[0].customer_id
            //     self.email = matchedCustomer[0].email
            //   }
            // }

            // // If customer not found, check phone number
            // if (self.customerId === null) {
            //   if (!self.phoneNumber) {
            //     throw new Error('phone_needed')
            //   } else if (
            //     self.phoneNumber !== false &&
            //     self.phoneNumber !== null &&
            //     self.phoneNumber !== ''
            //   ) {
            //     // Check if one customer match the phone number id
            //     matchedCustomer = customers.filter(function (customer) {
            //       return customer.phone === self.phoneNumber
            //     })

            //     // Found only one customer
            //     if (matchedCustomer.length === 1) {
            //       self.customerId = matchedCustomer[0].customer_id
            //       self.email = matchedCustomer[0].email
            //     }
            //   }
            // }
            // //  If customer not found, check name and lastname
            // if (self.customerId === null) {
            //   self.findCustomerBy(customers, 'fullName', (x) => `${x.first_name} ${x.last_name}`)
            // }
          } else if (customers.length === 1) {
            if (self.isName && (self.birthday !== dayjs(customers[0].birthday).format('YYYY-MM-DD'))) {
              await self.handleNotFound()
            }

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
            case 'birthday_needed':
              self.showPhoneNumber = false
              self.showBirthday = true
              mess = 'Please confirm your identity by providing your birth date.'
              return self.$emit('error', mess)

            case 'email_needed':
              self.showEmail = true
              mess = 'Please write  your email.'
              return self.$emit('error', mess)

            case 'email_duplicate_needed':
              self.showEmail = true
              mess = 'Duplicate profiles found, enter your email.'
              return self.$emit('error', mess)

            case 'fullName_needed':
              self.showName = true
              self.showLastName = true
              mess = 'Please write  your name and last name.'
              return self.$emit('error', mess)

            case 'fullName_duplicate_needed':
              self.showName = true
              self.showLastName = true
              mess = 'Duplicate profiles found, enter your name and lastname.'
              return self.$emit('error', mess)

            case 'found_duplicate_profile_needed':
              mess = 'Found duplicate profiles, ask a staff member for help.'
              return self.$emit('error', mess)

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
    getMatchedCustomer (customers) {
      const self = this
      const matches = customers

      let searches = [
        {
          prop: 'birthday',
          filterFn: (customer, self) => dayjs(customer.birthday).format('YYYY-MM-DD').toString() === self.birthday
        }
      ]

      const phoneSearch = {
        prop: 'phoneNumber',
        validationRule: self.phoneNumber !== false &&
                self.phoneNumber !== null &&
                self.phoneNumber !== '',
        filterFn: (x, y) => x.phone === y.phoneNumber
      }
      const emailSearch = {
        prop: this.checkoutType !== 'phone' ? 'email' : (this.countCustomerDuplicatePhoneNumber > 1 ? 'found_duplicate_profile' : 'email_duplicate'),
        validationRule: self.email,
        filterFn: (x, y) => x.email === y.email
      }
      const fullNameSearch = {
        prop: this.checkoutType !== 'phone' ? 'fullName' : (this.countCustomerDuplicatePhoneNumber > 1 ? 'found_duplicate_profile' : 'fullName_duplicate'),
        validationRule: self.first_name !== '' && self.last_name !== '',
        filterFn: (x, y) => `${x.first_name.toLowerCase()} ${x.last_name.toLowerCase()}` === y.fullName.toLowerCase
      }

      const verifyNameAndLastNameEmpty = matches.filter(item => item.first_name && item.last_name)

      switch (this.checkoutType) {
        case 'name':
          searches = [...searches, phoneSearch, emailSearch]
          break
        case 'phone':
          if (verifyNameAndLastNameEmpty.length >= 1) {
            searches = [...searches, fullNameSearch]
            this.countCustomerDuplicatePhoneNumber++
          } else {
            searches = [...searches, emailSearch]
          }
          break
        case 'email':
          searches = [...searches, phoneSearch, fullNameSearch]
          break
      }

      for (const search of searches) {
        if (!self[search.prop]) {
          throw new Error(search.prop + '_needed')
        }

        const matched = matches.filter(
          customer => search.filterFn(customer, self)
        )
        if (matched.length === 1) {
          return matched
        }
      }

      return matches
    },

    handleDOBNeeded () {
      throw new Error('birthday_needed')
    },
    findCustomerBy (customers, prop, mapProp = (x) => x[prop]) {
      const self = this
      if (!self[prop]) {
        throw new Error(prop + '_needed')
      }
      const matched = customers.filter(
        customer => mapProp(customer) === self[prop]
      )

      if (matched.length === 1) {
        self.customerId = matched[0].customerId
        self.email = customers[0].email
        return true
      }

      return false
    },

    directCheckout: function () {
      //  validates

      this.isSending = true
      this.sendOrder(true)
    },

    /**
     * Send order to API
     */
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
          order: order
        })
        .then(function (response) {
          console.log(response)
          self.isSending = false
          let message = self.$config.CHECKOUT_MESSAGE && self.$config.CHECKOUT_MESSAGE.trim() !== ''
            ? self.$config.CHECKOUT_MESSAGE
            : 'Please pick up your order at the designated register.'
          self.$emit('success', message)
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
    }
  }
}
</script>

<style scoped lang="scss"></style>
