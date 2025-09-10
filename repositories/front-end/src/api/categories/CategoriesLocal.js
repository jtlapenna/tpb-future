import { LocalRepo } from '../LocalRepo'

export class CategoriesLocal extends LocalRepo {
  constructor () {
    super('categories', 'id')
  }
}
