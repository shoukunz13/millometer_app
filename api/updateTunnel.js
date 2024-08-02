//this end point is to update the user label given to the specific mill ,
//POST request : 
//PiID is the id of the mcu
//reversedport is the port used for reversed tunnel on the cloud
//remoteport is the target port on the mcu for reversed tunnel
//proxy need to be specified redis
//mode 1 is reversed tunnel, mode 0 is direct connection

const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.post('/', async (req, res) => {
  const PiID = req.body.PiID;
  const tunnelport = req.body.tunnelport;
  const proxyport = req.body.proxyport;
  const mode = req.body.mode;

  try {
      await client.connect();
      const database = client.db('MillProject');
      const millsCollection = database.collection('mills');

      // Check if the document with the given PiID exists
      const existingDocument = await millsCollection.findOne({ 'PiID': PiID });

      if (existingDocument) {
          // Document with PiID exists, check if the values are different before updating
          if (
              existingDocument.tunnelport !== tunnelport ||
              existingDocument.proxyport !== proxyport ||
              existingDocument.mode !== mode
          ) {
              // Update the reversedport, remoteport, and mode fields in the matched mill document
              const filter = { 'PiID': PiID };
              const update = {
                  $set: {
                      'tunnelport': tunnelport,
                      'proxyport': proxyport,
                      'mode': mode,
                  }
              };

              // Perform the update operation
              const result = await millsCollection.updateOne(filter, update);

              if (result.modifiedCount === 1) {
                  // Document updated successfully
                  res.status(200).json({ message: 'tunnel updated successfully' });
              } else {
                  // Something went wrong with the update
                  res.status(500).json({ error: 'Internal server error during update' });
              }
          } else {
              // Values are the same, no need to update
              res.status(200).json({ message: 'Values are the same, no update needed' });
          }
      } else {
          // No matching document found
          res.status(404).json({ message: 'PiID not found, please makesure it is registered first' });
      }
  } catch (error) {
      // Handle any errors that may occur during the update
      console.error('Error updating tunnel:', error);
      res.status(500).json({ error: 'Internal server error' });
  }
});


module.exports = router;
