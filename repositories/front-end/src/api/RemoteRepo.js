import HTTP from './http'
export class RemoteRepo {
  endpoint = null
  constructor (endpoint) {
    this.endpoint = endpoint
  }

  index (pageconfig = {page: 1, per_page: 9999, sort_by: 'name'}) {
    return HTTP.get(this.endpoint, {
      params: pageconfig
    })
  }
}
