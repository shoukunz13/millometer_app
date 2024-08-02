// dayData.js is used to get the hour data of a particular mill ID within a period
// the period is between two timestamps
// the data queried will be arranged in ascending order - which is from oldest to latest

const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../../dbconfig");
const router = express.Router();

// the connection string of the mongo DB
const uri = connectionString;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

router.get('/', async (req, res) => {
    try {
        await client.connect();
        const PiID = req.query.PiID;

        // Format start and end timestamps using Luxon
        const start = new Date(req.query.start);
        const end = new Date(req.query.end);
        console.log('Formatted Start:', start);
        console.log('Formatted End:', end);

        // connect to the database name HourData
        const database = client.db('HourData');

        // Check if the collection exists
        const collections = await database.listCollections({ name: PiID }).toArray();

        if (collections.length === 0) {
            // Collection does not exist, return a response
            return res.status(404).send('Hour collection does not exist. The mill was just installed. Please wait.');
        }

        // access to the collection of the related piID
        const hourCollection = database.collection(PiID);

        // Assuming your timestamp field in the collection is named 'timestamp'
        // $gte stands for greater than or equal to
        // $lte stands for less than or equal to
        // the query will take the data between two timestamps
        const query = {
            timestamp: {
            $gte: new Date(req.query.start),
            $lte: new Date(req.query.end),
            },
        };

        // ascending order of sorting
        const result = await hourCollection.find(query).sort({ timestamp: 1 }).toArray();
    
        res.json(result);
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
});

module.exports = router;
