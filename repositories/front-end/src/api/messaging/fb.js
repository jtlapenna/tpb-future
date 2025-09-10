import { initializeApp } from 'firebase/app'
import { getMessaging } from 'firebase/messaging/sw'
import {getFirestore} from 'firebase/firestore'
import { firebaseConfig } from '../../const/globals'

export const app = initializeApp(
  firebaseConfig
)
export const firebaseDB = getFirestore(app)
export const fbMessaging = getMessaging(app)

// export const subscribeToTopic = (topicName, handler = () => {}) =>
//   fMessaging.getToken().then((currentToken) => {
//     if (currentToken) {
//       // Subscribe to the topic
//       const topicURL = `https://iid.googleapis.com/iid/v1/${currentToken}/rel/topics/`
//       return fetch({
//         url: topicURL,
//         method: 'POST',
//         headers: {
//           Authorization: `key=${firebaseConfig}`
//         }
//       })
//         .then((response) => {
//           fMessaging.onMessage(
//             (payload) => {
//               handler(payload)
//             },
//             (error) => {
//               console.log(error)
//             }
//           )
//         })
//         .catch(() => {
//           console.error(`Can't subscribe to ${topicName} topic`)
//         })
//     }
//   })
