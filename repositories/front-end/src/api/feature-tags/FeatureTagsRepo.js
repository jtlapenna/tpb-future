import { Repo } from '../repo'
import { FeatureTagsLocal } from './FeatureTagsLocal'
import { FeaturesTagsRemote } from './FeatureTagsRemote'

export class FeaturesTagRepo extends Repo {
  constructor () {
    super(new FeaturesTagsRemote(), new FeatureTagsLocal(), 'tags')
  }
}

export default new FeaturesTagRepo()
