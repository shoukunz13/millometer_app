// Function : To send notification using phone number of user, one notification to a single user at a time (supports multiple devices notification on devices the user is logged in)
// Required parameters :-
//    query : phoneNum

//Collections involved : users
const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

var admin = require("firebase-admin");
var serviceAccount = require("../privateServiceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

router.post('/', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('MillProject');
    const users = database.collection('users');

    const phoneNum = req.query.phoneNum;
    const documents = await users.findOne(
      { phoneNum: phoneNum },
      { projection: { _id: 0, devices: 1 } }
    );

    const responses = [];
    const expiredTokens = [];
    if (documents && documents.devices) {
      const registeredTokens = documents.devices;
      
      for (let i = 0; i < registeredTokens.length; i++) {
        const registrationToken = registeredTokens[i];
        console.log(registrationToken);
        const message = {
          notification: {
            title: req.body.title,
            body: req.body.message,
          },
          token: registrationToken,
          android: {
            priority: "high",
            "direct_boot_ok": true,
          },
        };

        try {
          const response = await admin.messaging().send(message);
          console.log('Successfully sent message:', response);
          responses.push(`Notification successfully sent to user ${registrationToken}`);
        } catch (error) {
          expiredTokens.push(registrationToken);
          // Handle errors
          console.error('Error sending notification: (delete this token)');
        }
      }
    } else {
      responses.push("No user with the specified phone number found.");
    }

    // Send a single response with all the collected responses
    if(expiredTokens.length > 0){
      await users.updateOne(
        { phoneNum: phoneNum },
        { $pull: { devices: { $in: expiredTokens } } }
      );
      console.log('Expired tokens removed:', expiredTokens);
      res.json(responses);
    }else{
      res.json(responses);
    }
    
  } catch (error) {
    console.error("Error retrieving documents:", error);
    res.status(500).json({ error: "An error occurred while retrieving documents." });
  }
});


module.exports = router;
