const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
const app = admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// function to trigger cloud menssage 
exports.sendMessage =  functions.https.onRequest(async (req, res) => {
  // const catalogId = req.query.catalog_id;
  // const orderId = req.query.order_id;
  const body =  req.body;
  console.log("BODY", body)
  // create a new message on firebastore
  const result = await admin.firestore().collection(`kiosk/${body.catalog_id}/orders`).add({...body});


  res.json({
    message: 'Message sent',
    result: result.get()
  })
})
