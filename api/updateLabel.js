//this end point is to update the user label given to the specific mill ,
//GET request : PiID and phoneNum is specified and the Label is specified as well

const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);


router.get('/', async (req, res) => {
    const PiID = req.query.PiID;
    const phoneNum = req.query.phoneNum;
    const label = req.query.label;
  
    try {
      await client.connect();
      const database = client.db('MillProject');
      const usersCollection = database.collection('users');
  
      // Find the user document based on phoneNum and PiID
      const filter = {
        phoneNum: phoneNum,
        'mills.PiID': PiID
      };
  
      // Update the 'label' field in the matched mill document
      const update = {
        $set: {
          'mills.$.label': label
        }
      };
  
      // Perform the update operation
      const result = await usersCollection.updateOne(filter, update);
  
      if (result.modifiedCount === 1) {
        // Document updated successfully
        res.status(200).json({ message: 'Label updated successfully' });
      } else {
        // No matching document found
        res.status(404).json({ message: 'User not found or PiID not matched' });
      }
    } catch (error) {
      // Handle any errors that may occur during the update
      console.error('Error updating label:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

module.exports = router;