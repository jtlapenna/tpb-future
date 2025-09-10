import { LocalRepo } from '../LocalRepo'

export class FeatureTagsLocal extends LocalRepo {
  constructor () {
    super('tags', 'id')
  }
}
