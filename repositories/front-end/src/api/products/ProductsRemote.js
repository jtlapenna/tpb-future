import HTTP from '../http'

export class ProductsRemote {
  index(pageconfig = { page: 1, per_page: 9999, sort_by: 'name' }) {
    return HTTP.get('products', {
      params: pageconfig
    })
  }
  show(productId) {
    return HTTP.get('products/' + productId)
  }
}
