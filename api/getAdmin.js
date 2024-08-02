const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

router.get('/', async (req, res) => {
  try {
    await client.connect();

    const database = client.db('MillProject');
    const collection = database.collection('users');

    // Find all documents with role "admin"
    const adminUsers = await collection.find({ "role": "admin" }).toArray();

    // Send the adminUsers as the response with a success status code (200)
    res.status(200).json(adminUsers);
  } catch (error) {
    // Handle errors and send an error response with an appropriate status code (e.g., 500 for internal server error)
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  } finally {
    await client.close();
  }
});

module.exports = router;
