import { Repo } from '../repo'
import { RFIDLocal } from './RFIDLocal'
import { RFIDRemote } from './RFIDRemote'

export class RFIDRepo extends Repo {
  constructor() {
    super(new RFIDRemote(), new RFIDLocal(), 'rfids')
  }

  list() {
    return new Promise(async (resolve, reject) => {
      let items = []
      try {
        // fetch from remote first
        items = await this.remote
          .index()
          .then(response => response.data[this.dataName])
        // update localItems
        await this.updateLocalItems(items)
        // resolve items
        resolve(items)
      } catch (e) {
        console.error('ERROR FETCH REMOTE, SHOWING LOCAL INSTEAD', e)
        // if error fetch local and resolve
        items = await this.local.index()
        items.sort((a, b) => (a.id > b.id ? 1 : -1))
        resolve(items)
      }
    })
  }

  updateLocalItems(items) {
    return super.updateLocalItems(
      items.map((items, index) => ({
        id: index,
        ...items
      }))
    )
  }
}

export default new RFIDRepo()
