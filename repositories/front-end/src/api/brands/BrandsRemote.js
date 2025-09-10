import HTTP from '../http'

export class BrandsRemote {
  index (pageconfig = {page: 1, per_page: 9999, sort_by: 'name'}) {
    return HTTP.get('brands', {
      params: pageconfig
    })
  }
}
