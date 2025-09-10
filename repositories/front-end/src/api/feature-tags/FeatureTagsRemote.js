import HTTP from '../http'

export class FeaturesTagsRemote {
  index (pageconfig = {featured_tags: true}) {
    return HTTP.get('tags', {
      params: pageconfig
    }).then(response => {
      return {
        data: {
          tags: response.data.tags.map((tag, index) => ({
            tag: tag,
            id: index
          }))
        }
      }
    })
  }
}
