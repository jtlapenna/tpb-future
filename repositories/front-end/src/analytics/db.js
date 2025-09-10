const DB_NAME = 'analitics_Events'
const DB_VERSION = 1
let instance
const DB = async function getDb () {
  return new Promise((resolve, reject) => {
    if (instance) { return resolve(instance) }
    console.log('OPENING EVENTS DB')
    let request = window.indexedDB.open(DB_NAME, DB_VERSION)

    request.onerror = e => {
      console.log('Error opening db', e)
      reject(new Error('Error opening db'))
    }

    request.onsuccess = e => {
      instance = e.target.result
      resolve(instance)
    }

    request.onupgradeneeded = e => {
      console.log('onupgradeneeded')
      let db = e.target.result
      db.createObjectStore('events', { autoIncrement: !0, keyPath: 'id'
      })
    }
  })
}

export default DB
