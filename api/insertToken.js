//when token is created on flutter side, this endpoint will be used to update in the mongoDB.
// the token will be updated in the 'devices' field of user record in users collection

// when token updated ,  'mill_users' collection is the collection that will be referenced by the Pi , that will also be updated

// technically 'mill_users' are referencing to users that have successfully activated their account completely (meaning they have opened and OTP succesfully into app at least once).

//TODO : need to modify the part where it update 'mill_users' collection, avoid adding when already existed.

const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.post('/', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('MillProject');
    const users = database.collection('users');
    const mill_users = database.collection('mill_users');
    const phoneNum = req.query.phoneNum;

    const status = "active";

    const token = req.body.fcmToken;
    // Update the "devices" array for the user with the specified phoneNum
    const result = await users.updateOne(
      { phoneNum: phoneNum },
      { $push: { devices: token } }
    );

    const userDocument = await users.findOne(
      { status: status, phoneNum: phoneNum },
      { projection: { _id: 1, mills: 1 } }
    );

    if (!userDocument || !userDocument.mills) {
      return res.status(404).json({ error: "User not found or no mills attached." });
    }

    const accessibleMills = userDocument.mills.map(mill => mill.PiID);

    // Update the mill_users collection with user references using $addToSet
    const millUserUpdateResult = await mill_users.updateMany(
      { PiID: { $in: accessibleMills } },
      { $addToSet: { users: userDocument._id } }
    );

    if (result.modifiedCount > 0 && millUserUpdateResult.modifiedCount > 0) {
      res.status(200).json({ message: "Token and mill users updated successfully." });
    } else {
      res.status(404).json({ error: "User not found or mill user update failed." });
    }
  } catch (error) {
    console.error("Error updating token:", error);
    res.status(500).json({ error: "An error occurred while updating token." });
  } 
});

module.exports = router;
