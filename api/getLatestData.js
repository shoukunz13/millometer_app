const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

router.get('/', async (req, res) => {
    try {
        await client.connect();

        const database = client.db('MinuteData'); // Assuming 'MinuteData' is your database name
        const millID = req.query.millID; // Get the millID from query parameters

        // Get the collection based on millID
        const collection = database.collection(millID);

        // Find the latest 60 records
        const latestRecords = await collection.find({})
            .sort({ timestamp: -1 })
            .limit(60)
            .toArray();

        if (!latestRecords || latestRecords.length === 0) {
            return res.status(404).json({ error: 'No records found for the provided millID' });
        }

        // Reverse the order of the array (from latest to oldest to oldest to latest)
        const reversedRecords = latestRecords.reverse();

        // Send the reversed array without a label
        res.json(reversedRecords);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    } finally {
        await client.close();
    }
});

module.exports = router;
