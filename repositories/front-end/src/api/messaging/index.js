import { getToken, onMessage } from 'firebase/messaging'
import { SERVER_KEY, VAPID_KEY } from '../../const/globals'
import { fbMessaging, firebaseDB } from './fb'
import { doc, collection, onSnapshot } from 'firebase/firestore'

export class MessagesService {
  oneMessage (payloadFn = (payload) => { console.log(payload) }) {
    onMessage(fbMessaging, payloadFn)
  }
}

export const getFMCToken = (setTokenFound) => {
  return getToken(fbMessaging)
}

export const getOrders = (kioskId, callback = (changes) => { console.log(changes) }) => {
  const ref = collection(firebaseDB, `kiosk/${kioskId}/orders`)
  return onSnapshot(ref, (snapshot) => {
    callback(snapshot.docChanges())
  }, error => {
    console.error(error)
  })
}

export const getOrderChanges = ({kioskId, orderId, env}, callback = (changes) => { console.log(changes) }) => {
  const ref = doc(firebaseDB, `${env ? `/envs/${env}/` : ''}kiosk/${kioskId}/orders/${orderId}`)
  return onSnapshot(ref, (snapshot) => {
    console.log(snapshot)
    callback(snapshot.data())
  }, error => {
    console.error(error)
  })
}

export const getAeropayOrderChanges = (uuid, callback = (changes) => { console.log(changes) }) => {
  const ref = doc(firebaseDB, `aeropayOrders/${uuid}`)
  return onSnapshot(ref, (snapshot) => {
    console.log(snapshot)
    callback(snapshot.data())
  }, error => {
    console.error(error)
  })
}

export const subscribeToTopic = (topicName, handler = (payload) => { console.log('payload', payload) }) =>
  getToken(fbMessaging, {vapidKey: VAPID_KEY}).then((currentToken) => {
    if (currentToken) {
      const topicURL = `https://iid.googleapis.com/iid/v1/${VAPID_KEY}/rel/topics/`
      return fetch({
        url: topicURL,
        method: 'POST',
        headers: {
          Authorization: `key=${SERVER_KEY}`
        }
      })
        .then((response) => {
          onMessage(fbMessaging,
            (payload) => {
              handler(payload)
            },
            (error) => {
              console.log(error)
            }
          )
        })
        .catch(() => {
          console.error(`Can't subscribe to ${topicName} topic`)
        })
    }
  })
export default new MessagesService()
