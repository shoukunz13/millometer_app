// addmill.js is to add a mill into the mill collection
// when the millID does not exist in the mill collection, this file will create a record for the new millID

const { MongoClient, ObjectID } = require('mongodb');
const express = require('express');
const router = express.Router();
const connectionString = require("../dbconfig");

// uri is the connection string of the mongoDB
const uri = connectionString;
const client = new MongoClient(uri);

// POST request
router.post('/', async (req, res) => {
    try {
        await client.connect();

        // connect to the MillProject database and access the mills and mill_users collections
        const database = client.db('MillProject');
        const mills = database.collection('mills');
        const mill_users = database.collection('mill_users');
        //   const newUser = database.collection('newUser');

        console.log(req.body);

        const PiID = req.body.PiID;
        const name = req.body.name;
        const status = req.body.status;
        const parameters = req.body.parameters;
        const stream = req.body.stream;
        const unit = req.body.parameters_unit;
        const thresholds = req.body.thresholds;

        // Check if required fields are present and having values
        if (!PiID || !status || !parameters || !stream || !unit || !thresholds) {

            // error status if the required fields does not have values
            res.status(400).json({ error: 'Please specify all the required parameters' });
            return;
        }

        const document = await mills.findOne({ PiID: PiID });

        // if the piID does not exist, it will create a new piID record in the mills collection
        if (document == null) {
            const result = await mills.insertOne({
                PiID: PiID,
                name: name,
                status: status,
                parameters: parameters,
                stream: stream,
                parameters_unit: unit,
                thresholds: thresholds
            });

            // create a record of new piID in mill_users collection 
            const result2 = await mill_users.insertOne({ PiID: PiID, users: [] });
            //   const result3 = await newUser.insertOne({ PiID: PiID, users: [] });

            if (result.acknowledged && result2.acknowledged) {
                res.status(200).json({ success: `The device with the following ID : ${PiID} was successfully registered!` });
            }
        } else {
            res.status(200).json({ warning: `The device with the following ID :  ${PiID} is already registered` });
        }
    } catch (error) {
        res.status(500).json({ error: 'An error occurred while processing the request' });
        console.error('Error inserting data:', error);
    }
});


module.exports = router;

