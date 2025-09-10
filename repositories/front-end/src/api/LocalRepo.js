import DB from './dbconfig'

export class LocalRepo {
  // Variables
  tableName = '' // name of the table
  id = 'id' // base id use to search for item

  constructor(tableName, id) {
    this.tableName = tableName
    this.id = id
  }

  /**
   * Ge base read transction
   * @returns promise
   */
  async getReadTransaction() {
    let db = await DB()
    // console.log(db)
    return db.transaction([this.tableName], 'readwrite')
  }

  /**
   * Deletes a item from local repo
   * @param {*} item any
   * @returns promise
   */
  async delete(item) {
    return new Promise(async resolve => {
      let trans = await this.getReadTransaction()
      trans.oncomplete = () => {
        resolve()
      }

      let store = trans.objectStore(this.tableName)
      store.delete(item[this.id])
    })
  }
  /**
   * Returns list of items
   * @returns promise with a list of items
   */

  index() {
    return new Promise(async resolve => {
      let trans = await this.getReadTransaction()
      let items = []
      let store = trans.objectStore(this.tableName)
      trans.oncomplete = () => {
        resolve(items)
      }
      store.openCursor().onsuccess = e => {
        let cursor = e.target.result
        if (cursor) {
          items.push(cursor.value)
          cursor.continue()
        }
      }
    })
  }
  /**
   * Saves/Updates an item on local
   * @param {Object} item to save
   * @returns promise
   */

  save(item) {
    return new Promise(async (resolve, reject) => {
      let trans = await this.getReadTransaction()
      trans.oncomplete = () => {
        resolve()
      }
      trans.onerror = e => {
        reject(e)
      }

      let store = trans.objectStore(this.tableName)
      store.put(item)
    })
  }

  show(id) {
    return new Promise(async resolve => {
      let trans = await this.getReadTransaction()

      let store = trans.objectStore(this.tableName)
      let getProduct = store.get(id)
      getProduct.onsuccess = event => {
        resolve(getProduct.result)
      }
    })
  }
}

export default new LocalRepo()
