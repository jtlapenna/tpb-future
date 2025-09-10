import { ArticlesLocal } from './ArticlesLocal'
import { ArticlesRemote } from './ArticlesRemote'
import { Repo } from '../repo'

export class ArticlesRepo extends Repo {
  constructor() {
    super(new ArticlesRemote(), new ArticlesLocal(), 'articles')
  }
}

export default new ArticlesRepo()
