const DB_NAME = 'kioskDB'
const DB_VERSION = 1
let instance
const DB = async function getDb () {
  return new Promise((resolve, reject) => {
    if (instance) { return resolve(instance) }
    console.log('OPENING DB')
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
      db.createObjectStore('products', { autoIncrement: true, keyPath: 'id' })
      db.createObjectStore('brands', { autoIncrement: true, keyPath: 'id' })
      db.createObjectStore('articles', { autoIncrement: true, keyPath: 'id' })
      db.createObjectStore('rfids', { autoIncrement: true, keyPath: 'code' })
      db.createObjectStore('tags', { autoIncrement: true, keyPath: 'id' })
    }
  })
}

export default DB
