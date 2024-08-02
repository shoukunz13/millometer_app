//Return the mill record in the mill collections (All the fields will be returned)
//Returns in json form
// Required Query : PiID

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
        const PiID = req.query.PiID;

        const milldocumentsCursor = await mills.find({ PiID: PiID });
        const milldocumentsArray = await milldocumentsCursor.toArray();

        res.json(milldocumentsArray);
    } catch (error) {
        return res.status(404).json({ error: "Mill with the PiID not found" });
    }
});

module.exports = router;
