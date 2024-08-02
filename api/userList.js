const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.get('/', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('Millometer');
    const users = database.collection('users');

    const role = req.query.role;
    const phoneNum = req.query.phoneNum;
    const PiID = req.query.PiID;

    let projection = { _id: 0, phoneNum: 1, name: 1, state: 1 }; // Only retrieve these fields

    let query = {}; // Initial query to fetch all documents

    // If role is 'admin', exclude the user with the provided phoneNum
    if (role === 'admin' && phoneNum) {
      query.role = { $ne: 'admin' };
    }

    // If role is 'owner', include only users with role 'engineer' where ownerNum matches the provided phoneNum
    if (role === 'owner' && phoneNum) {
      query.role = 'engineer';
      query.ownerNum = phoneNum;
    }

    if (role === 'engineer' && phoneNum) {
      query.role = 'engineer';
    }

    // Check if PiID is provided in the query
    if (PiID) {
      query['mills.PiID'] = PiID;
    }

    const documents = await users.find(query).project(projection).toArray();

    res.json(documents);
  } catch (error) {
    console.error("Error retrieving documents:", error);
    res.status(500).json({ error: "An error occurred while retrieving documents." });
  } finally {
    // Close the connection after processing the request
    await client.close();
  }
});

module.exports = router;
