// updateThreshold.js
const express = require('express');
const { MongoClient } = require('mongodb');
const connectionString = require("../dbconfig");

const router = express.Router();

const uri = connectionString;
const client = new MongoClient(uri);

router.post('/', async (req, res) => {
    const PiID = req.query.PiID;
    const phoneNum = req.query.phoneNum;
    const steam_pressure = req.body.steam_pressure;
    const steam_flow = req.body.steam_flow;
    const water_level = req.body.water_level;
    const turbine_frequency = req.body.turbine_frequency;

    console.log(`Received PiID: ${PiID}, phoneNum: ${phoneNum}`);

    try {
        await client.connect();
        console.log('Connected to MongoDB');
        const database = client.db('Millometer');
        const usersCollection = database.collection('users');
        const millsCollection = database.collection('mills');

        const userQuery = { phoneNum: phoneNum };
        console.log(`User query: ${JSON.stringify(userQuery)}`);
        const user = await usersCollection.findOne(userQuery);

        console.log(`User query result: ${JSON.stringify(user)}`);

        if (!user) {
            res.status(404).json({ message: 'User not found' });
            return;
        }

        const millIndex = user.mills.findIndex(mill => mill.PiID === PiID);
        if (millIndex === -1) {
            res.status(404).json({ message: 'Mill not found' });
            return;
        }

        const updatedThresholds = [
            { parameter: "Steam Pressure", value: steam_pressure },
            { parameter: "Steam Flow", value: steam_flow },
            { parameter: "Water Level", value: water_level },
            { parameter: "Power Frequency", value: turbine_frequency }
        ];

        const updateResult = await usersCollection.updateOne(
            { phoneNum: phoneNum, "mills.PiID": PiID },
            {
                $set: {
                    "mills.$.thresholds": updatedThresholds
                }
            }
        );

        console.log(`Update result: ${JSON.stringify(updateResult)}`);

        res.status(200).json({ message: 'Thresholds updated successfully' });
    } catch (error) {
        console.error(`Error: ${error}`);
        res.status(500).json({ message: 'Internal server error' });
    } finally {
        await client.close();
    }
});

module.exports = router;
