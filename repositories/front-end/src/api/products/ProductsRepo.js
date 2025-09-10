import { Observable } from 'rxjs'
import { Repo } from '../repo'
import { ProductsLocal } from './ProductsLocal'
import { ProductsRemote } from './ProductsRemote'

export class ProductsRepo extends Repo {
  constructor() {
    super(new ProductsRemote(), new ProductsLocal(), 'products')
  }

  show(productId) {
    return new Observable(async subscriber => {
      // get local product and show it
      try {
        let product = await this.local.show(productId)

        if (product) {
          subscriber.next(product)
          return
        }
        // get remote product and show
        product = await this.remote.show(productId).then(response => {
          return response.data.product
        })

        subscriber.next(product)

        this.local.save(product)
      } catch (e) {
        console.error(e)
        subscriber.error(e)
      }
    })
  }
  // List products and save on local
  async index(options) {
    return new Promise(async (resolve, reject) => {
      this.$root.$emit('custom_event_name')
      try {
        const response = await this.remote.index(options)
        const products = response.data.products
        if (self.kioskConfig.STORE_LOCALLY === 1) {
          await Promise.all(
            products.map(async product => {
              await this.local.save(product)
            })
          )
        }
        resolve({ products, meta: response.data.meta })
      } catch (e) {
        reject(e)
      }
    })
  }

  async indexLocal(products) {
    return new Promise(async (resolve, reject) => {
      try {
        if (self.kioskConfig.STORE_LOCALLY === 1) {
          await Promise.all(
            products
              .filter(p => p.stock > 0)
              .map(async product => {
                const expiredDate = new Date()
                expiredDate.setDate(expiredDate.getDate() + 1)
                product.expired_at = expiredDate.toISOString()
                await this.local.save(product)
              })
          )

          await Promise.all(
            products
              .filter(p => p.stock === 0)
              .map(async product => {
                await this.local.delete(product)
              })
          )
        }
        resolve(true)
      } catch (e) {
        reject(e)
      }
    })
  }
}

export default new ProductsRepo()
