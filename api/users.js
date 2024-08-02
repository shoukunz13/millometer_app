//retrieve user in users collection by specifying phoneNum, used by Auth
// Used by Flutter

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
    const users = database.collection('users');

    const phoneNum = req.query.phoneNum;
    const documents = await users.find(
      { phoneNum : phoneNum }// Use projection object
    ).toArray();

    res.json(documents);
    // console.log("Documents retrieved:", documents);
  } catch (error) {
    console.error("Error retrieving documents:", error);
    res.status(500).json({ error: "An error occurred while retrieving documents." });
  } 
});

module.exports = router;