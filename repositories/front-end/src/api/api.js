import axios from 'axios'
import { ORDERS_PREVIEW } from './urls'

const TPB_API_URL = process.env.TPB_API_URL
  ? process.env.TPB_API_URL
  : self.kioskConfig.API.URL
const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID
  ? process.env.TPB_CATALOG_ID
  : self.kioskConfig.API.CATALOG_ID
const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN
  ? process.env.TPB_STORE_TOKEN
  : self.kioskConfig.API.TOKEN

class API {
  http
  constructor() {
    this.http = axios.create({
      baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
      params: {
        token: TPB_STORE_TOKEN
      },
      headers: {
        'Cache-Control': 'no-cache',
        Pragma: 'no-cache',
        Expires: '0'
      }
    })
  }
  /**
   * Returns the product that belongs to the current kiosk
   * @param {page,per_page} pageconfig
   */
  getProducts(pageconfig = { page: 1, per_page: 25, sort_by: 'created_at' }) {
    return this.http.get('products', {
      params: pageconfig
    })
  }
  /**
   *  Returns a product base on its id
   * @param {*} productId Id of a product
   */
  getProduct(productId) {
    return this.http.get('products/' + productId)
  }
  /**
   * Returns a list of brands
   * @param {*} pageconfig  pagination sortby
   */
  getBrands(pageconfig = { page: 1, per_page: 9999, sort_by: 'name' }) {
    return this.http.get('brands', {
      params: pageconfig
    })
  }

  getProductsMinimal(page = null, hardReloadProducts = false) {
    let updatedAt = new Date(
      localStorage.getItem('update_date') || '2019-10-31'
    )
    // This is to bring redundant data because in some cases de api have an delay with
    // the product updatedAt and this make some products get away from the sync
    // eslint-disable-next-line no-unused-expressions
    if (localStorage.getItem('update_date')) {
      updatedAt.setMinutes(updatedAt.getMinutes() - 1)
    }
    if (hardReloadProducts) {
      updatedAt = new Date('2019-10-31')
    }
    const maxDate = updatedAt.toISOString()
    const excludeZero = localStorage.getItem('update_date') ? 0 : 1
    return this.http.get(
      'products/maximal?max_date=' +
        maxDate +
        '&page=' +
        page +
        '&per_page=350&exclude_zero=' +
        excludeZero
    )
  }

  getProductsMinimalForDate({ page, updatedAt }) {
    const maxDate = updatedAt.toISOString()
    const excludeZero = localStorage.getItem('update_date') ? 0 : 1

    return this.http.get(
      'products/maximal?max_date=' +
        maxDate +
        '&page=' +
        page +
        '&per_page=350&exclude_zero=' +
        excludeZero
    )
  }
  /**
   * Returns store categories
   */
  getCategories(params = {}) {
    return this.http.get('categories', { params: params })
  }
  /**
   * Returns store articles
   * @param {minimal:boolean} params of the request
   */
  getArticles(params = { minimal: true }) {
    return this.http.get('articles', { params: params })
  }
  /**
   * Return tags
   * @param {*} params
   */
  getTags(params = { featured_tags: true }) {
    return this.http.get('tags', { params: params })
  }

  /**
   * Returns the taxes for and order
   * @param {*} params
   */
  getTaxes(params) {
    return this.http.post(ORDERS_PREVIEW, params)
  }
  /*
   * Create a customer
   */
  createCustomers(customer) {
    return this.http
      .post('customers', { customer })
      .then(response => response.data.customer)
  }
  /**
   * Returns remote kiosk settings
   */
  getSettings() {
    return this.http.get('settings').then(response => response.data)
  }
  /**
   * Returns remove products
   */
  getProductsWhenNoExist(storeId) {
    return this.http
      .get(`products/check_products_availability?store_id=${storeId}`)
      .then(response => response.data)
  }
  /**
   * Send verify products if expired
   */
  verifyProductsExpiration(storeId, products) {
    const productsParse = products.map(product => {
      return {
        id: product.id,
        expired_at: product.expired_at,
        last_updated_at: product.updated_at
      }
    })

    const data = {
      store_id: storeId,
      products: productsParse,
      kiosk_id: TPB_CATALOG_ID
    }
    return this.http
      .post(`products/check_products_expired_status`, { ...data })
      .then(response => response.data)
  }
}

export default new API()
