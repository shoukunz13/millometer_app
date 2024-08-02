//This endpoint is used by Pi Server only
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
    const status = "active";
    const documents = await mills.find({ status: status }).project({ _id: 0, PiID: 1, stream: 1 }).toArray();
    res.json(documents);
} catch (error) {
    console.error('Error:', error);
}
});

module.exports = router;
