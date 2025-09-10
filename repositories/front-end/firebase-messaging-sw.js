// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
// eslint-disable-next-line
importScripts("https://www.gstatic.com/firebasejs/8.6.7/firebase-app.js");
// eslint-disable-next-line
importScripts("https://www.gstatic.com/firebasejs/8.6.7/firebase-messaging.js");

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
// eslint-disable-next-line
firebase.initializeApp( {
  apiKey: 'AIzaSyDD-bDnGXYawIfiyUjjKgFEzJxsuksmnDs',
  authDomain: 'tpb-kiosk-fe-vue.firebaseapp.com',
  databaseURL: 'https://tpb-kiosk-fe-vue.firebaseio.com',
  projectId: 'tpb-kiosk-fe-vue',
  storageBucket: 'tpb-kiosk-fe-vue.appspot.com',
  messagingSenderId: '363009717442',
  appId: '1:363009717442:web:2f451c22612f687e08f75b',
  measurementId: 'G-9FGF22C995'
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
// eslint-disable-next-line
const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  return self.showNotification(
    message.notification.title,
    message.notification
  );
});