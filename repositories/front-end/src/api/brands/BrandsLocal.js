import { LocalRepo } from '../LocalRepo'

export class BrandsLocal extends LocalRepo {
  constructor () {
    super('brands', 'id')
  }
}
