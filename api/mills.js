// Used by flutter client only , for retrieving mills linked to user (using their phoneNum)
//returns the set of mills from mills collection, where it only sends the mill that is linked to the user's list of mills

const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.get('/', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('MillProject');
    
    const mills = database.collection('mills');
    const users = database.collection('users');
    const status = "active";

    const phoneNum = req.query.phoneNum;
    const userDocument = await users.findOne(
      { status: status, phoneNum: phoneNum },
      { projection: { _id: 0, mills: 1 } }
    );

    if (!userDocument || !userDocument.mills) {
      return res.status(404).json({ error: "User not found or no mills attached." });
    }

    const accessibleMills = userDocument.mills.map(mill => mill.PiID);

    const documents2 = await mills.find(
      { status: status, PiID: { $in: accessibleMills } },
      { projection: { _id: 0, PiID: 1, name: 1, parameters: 1, parameters_unit: 1, "thresholds.value": 1 } }
    ).toArray();

    const documentsWithThresholds = documents2.map(doc => {
      const millThresholds = userDocument.mills.find(mill => mill.PiID === doc.PiID);
      const thresholds = millThresholds ? millThresholds.thresholds.map(threshold => parseFloat(threshold.value)) : [];
      return { ...doc, thresholds: thresholds, label: millThresholds.label };
    });
    

    console.log(documentsWithThresholds);
    res.json(documentsWithThresholds);
    
  } catch (error) {
    console.error("Error retrieving documents:", error);
    res.status(500).json({ error: "An error occurred while retrieving documents." });
  }
});

module.exports = router;