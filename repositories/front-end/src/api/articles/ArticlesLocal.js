import { LocalRepo } from '../LocalRepo'

export class ArticlesLocal extends LocalRepo {
  constructor () {
    super('articles', 'id')
  }
}
