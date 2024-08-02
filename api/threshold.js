//only Pi server requests to this api endpoint response
//to retrieve threshold value of a specific mill with PiID
const { MongoClient } = require('mongodb');
const { ObjectId } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.get('/', async (req, res) => {
    const PiID = req.query.PiID;

    try {
        await client.connect();
        const database = client.db('MillProject');
        const millUsersCollection = database.collection('mill_users');
        const usersCollection = database.collection('users');

        // Find the mill_users record for the given PiID
        const millUsersRecord = await millUsersCollection.findOne({ PiID });
        if (!millUsersRecord) {
            res.status(404).json({ error: 'No mill users record found for the provided PiID.' });
            return;
        }

        // Convert the array of user IDs from strings to ObjectIds
        const userIDs = millUsersRecord.users.map(userId => new ObjectId(userId));
        
        // Find the users with the converted IDs
        const users = await usersCollection.find({ _id: { $in: userIDs } }).toArray();
        
        const responseData = users.map(user => {
            const matchingMill = user.mills.find(mill => mill.PiID === PiID);
            return {
                phoneNum: user.phoneNum,
                thresholds: matchingMill ? matchingMill.thresholds : []
            };
        });
        
        res.json(responseData);

    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'An error occurred while processing the request.' });
    }
});
module.exports = router;