// import { Observable } from 'rxjs'
import { BrandsLocal } from './BrandsLocal'
import { BrandsRemote } from './BrandsRemote'
import { Repo } from '../repo'
export class BrandsRepo extends Repo {
  constructor () {
    super(new BrandsRemote(), new BrandsLocal(), 'brands')
  }
}

export default new BrandsRepo()
