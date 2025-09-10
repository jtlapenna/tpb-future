import { LocalRepo } from '../LocalRepo'

export class ProductsLocal extends LocalRepo {
  constructor () {
    super('products', 'id')
  }
}
