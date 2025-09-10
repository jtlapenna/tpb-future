import {Observable} from 'rxjs'

export class Repo {
  remote
  local
  dataName = ''

  constructor (remote, local, dataName) {
    this.remote = remote
    this.local = local
    this.dataName = dataName
  }

  /**
   * List the current items
   * @returns <Observable>
   */

  index (options = {page: 1, per_page: 9999, sort_by: 'created_at'}) {
    return new Observable(async (subscriber) => {
      let items = []

      try {
        // get items from remote

        items = await this.remote.index(options).then((response) => (response.data[this.dataName]))
        // send items to subscirber
        subscriber.next(items)
        // update local items
        items = await this.updateLocalItems(items)
        // send items to subscriber
        subscriber.next(items)
        subscriber.complete()
      } catch (e) {
        console.error(e)
        items = await this.local.index()
        items.sort((a, b) => (a.id > b.id ? 1 : -1))
        subscriber.next(items)
      }
      // returns remote
    })
  }

  /**
   * Updates local items in bd
   */
  updateLocalItems (remoteItems) {
    return new Promise(async (resolve) => {
      let localItems = await this.local.index()
      let toDelete = []
      // delete items not found in remote
      if (remoteItems && remoteItems.length > 0) {
        localItems.forEach(item => {
          const exist = remoteItems.find(b => b.id === item.id)
          if (exist === undefined) {
            toDelete.push(item)
          }
        })
        // updates all remote to current
        remoteItems.forEach(async (item) => {
        // console.log(item)
          await this.local.save(item)
        })
      }

      // delete all not found items
      toDelete.forEach(item => {
        this.local.delete(item)
      })
      // returns local items
      let items = await this.local.index()
      resolve(items)
    })
  }

  async list (options = {page: 1, per_page: 9999, sort_by: 'created_at'}) {
    try {
      const response = await this.remote.index(options)
      const {products} = response.data

      await Promise.all(products.map(async (product) => {
        await this.local.save(product)
      }))

      return null
    } catch (e) {
      console.log(e)
    }
  }
}
