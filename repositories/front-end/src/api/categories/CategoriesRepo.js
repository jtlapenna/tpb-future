import { CategoriesRemote } from './CategoriesRemote'
import { CategoriesLocal } from './CategoriesLocal'
import { Repo } from '../repo'

export class CategoriesRepo extends Repo {
  constructor() {
    super(new CategoriesRemote(), new CategoriesLocal(), 'brands')
  }
}
export default new CategoriesRepo()
