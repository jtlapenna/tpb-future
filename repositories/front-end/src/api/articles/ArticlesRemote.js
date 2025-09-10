import HTTP from '../http'

export class ArticlesRemote {
  /**
   * Returns store articles
   * @param {minimal:boolean} params of the request
   */
  index (params = {minimal: true}) {
    return HTTP.get('articles', {params: params})
  }
}
