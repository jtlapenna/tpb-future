const DB_NAME = 'kioskDB'
const DB_VERSION = 1
let DB

export default {
  async getDb() {
    return new Promise((resolve, reject) => {
      if (DB) {
        return resolve(DB)
      }
      let request = window.indexedDB.open(DB_NAME, DB_VERSION)

      request.onerror = e => {
        console.log('Error opening db', e)
        reject(new Error('Error opening db'))
      }

      request.onsuccess = e => {
        DB = e.target.result
        resolve(DB)
      }

      request.onupgradeneeded = e => {
        console.log('onupgradeneeded')
        let db = e.target.result
        db.createObjectStore('products', { autoIncrement: true, keyPath: 'id' })
        db.createObjectStore('brands', { autoIncrement: true, keyPath: 'id' })
        db.createObjectStore('articles', { autoIncrement: true, keyPath: 'id' })
        db.createObjectStore('rfids', { autoIncrement: true, keyPath: 'id' })
        db.createObjectStore('tags', { autoIncrement: true, keyPath: 'id' })
      }
    })
  },

  async deleteProduct(product) {
    let db = await this.getDb()

    return new Promise(resolve => {
      let trans = db.transaction(['products'], 'readwrite')
      trans.oncomplete = () => {
        resolve()
      }

      let store = trans.objectStore('products')
      store.delete(product.id)
    })
  },
  async getProducts() {
    let db = await this.getDb()

    return new Promise(resolve => {
      let trans = db.transaction(['products'], 'readonly')
      trans.oncomplete = () => {
        resolve(products)
      }

      let store = trans.objectStore('products')
      let products = []

      store.openCursor().onsuccess = e => {
        let cursor = e.target.result
        if (cursor) {
          products.push(cursor.value)
          cursor.continue()
        }
      }
    })
  },
  async getProduct(productId) {
    let db = await this.getDb()
    return new Promise(async (resolve, reject) => {
      let trans = db.transaction(['products'], 'readwrite')
      let store = trans.objectStore('products')
      let getProduct = store.get(productId)
      getProduct.onsuccess = event => {
        resolve(getProduct.result)
      }
    })
  },

  async saveProducts(cat) {
    let db = await this.getDb()

    return new Promise(resolve => {
      let trans = db.transaction(['products'], 'readwrite')
      trans.oncomplete = () => {
        resolve()
      }
      trans.onerror = e => {
        console.error(e)
      }

      let store = trans.objectStore('products')
      store.put(cat)
    })
  },

  async saveProduct(product) {
    let db = await this.getDb()

    return new Promise((resolve, reject) => {
      let trans = db.transaction(['products'], 'readwrite')
      trans.oncomplete = () => {
        resolve()
      }
      trans.onerror = e => {
        console.error('Transaction error:', e)
        reject(e)
      }

      let store = trans.objectStore('products')

      if (product.status === 'published' && product.stock > 0) {
        let request = store.put(product)
        request.onsuccess = () => {
          resolve()
        }
        request.onerror = e => {
          reject(e)
        }
      } else {
        let request = store.delete(product.id)
        request.onsuccess = () => {
          resolve()
        }
        request.onerror = e => {
          reject(e)
        }
      }
    })
  }
}
