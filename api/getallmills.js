//returns all the active mills in array of JSON objects
//this endpoint currently used by VM

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
        const mills = database.collection('mills');
        const status = 'active';

        const milldocumentsCursor = await mills.find({ status: status});
        const milldocumentsArray = await milldocumentsCursor.toArray();

        res.json(milldocumentsArray);
    } catch (error) {
        return res.status(404).json({ error: "Mill with the PiID not found" });
    }
});

module.exports = router;
