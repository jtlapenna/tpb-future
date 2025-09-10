import { mapState } from 'vuex'
import { firebaseConfig } from '../const/globals'
import { getAeropayOrderChanges } from '../api/messaging/index'

export const AeropayEvent = {
  data: function () {
    return {
      aeropayPermalink: null,
      creatingOrder: false
    }
  },
  computed: {
    ...mapState(['totalCart'])
  },
  methods: {
    /**
     * Method to redirect to a link and triking the event
     */
    createOrderAeropay: function () {
      this.creatingOrder = true
      let items = []

      this.cart.forEach(function (line) {
        var item = {
          quantity: line.qty,
          product_id: line.product.id,
          product_value_id: line.price.id
        }
        items.push(item)
      })
      if (this.firstname && this.lastname && items.length > 0 && this.totalCart !== null) {
        let order = {
          order: {
            customer_id: this.customerId,
            customer_name: `${this.firstname} ${this.lastname}`,
            customer_email: this.email,
            items: items
          }
        }
        this.$http.post('/orders', order).then(res => {
          let urlLink =
          this.$config.PAYMENT_GATEWAY.PAYMENT_PROVIDER_FIELDS.AEROPAY_URL +
          '?m=' + this.$config.PAYMENT_GATEWAY.PAYMENT_PROVIDER_FIELDS.MERCHANT_LOCATION_UU_ID +
          '&t=' + res.data.order.amount +
          '&u=' + res.data.order.id
          let body = {
            dynamicLinkInfo: {
              domainUriPrefix: 'https://url.aimservices.tech',
              link: urlLink
            }
          }
          this.$httpEmpty.post(`https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${firebaseConfig.apiKey}`, body)
            .then(response => {
              this.aeropayPermalink = response.data.shortLink
              getAeropayOrderChanges(res.data.order.id, (order) => {
                if (order.topic === 'transaction_completed') {
                  let message = this.$config.CHECKOUT_MESSAGE ? this.$config.CHECKOUT_MESSAGE : 'Please pick up your order at the designated register.'
                  this.$emit('success', message)
                }
              })
            }).catch(() => {
              throw new Error('There was an error creating the link')
            })
        // eslint-disable-next-line handle-callback-err
        }).catch((error) => {
          throw new Error('There was an error creating the link')
        })
          .finally(() => {
            this.creatingOrder = false
          })
      } else {
        this.creatingOrder = false
        throw new Error('There is not the information needed to trigger the request')
      }
    }
  }
}

export default AeropayEvent
