const { MongoClient } = require('mongodb');
const express = require('express');
const connectionString = require("../../dbconfig");

const router = express.Router();

// Mongo DB Connection String
const uri = connectionString;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

router.post('/', async (req, res) => {
    try {
        // Connect to the MongoDB server
        await client.connect(); 
        
        // connect to database named BatchData
        const database = client.db('BatchData');
        const PiID = req.query.PiID;

        // Check if the collection exists before attempting to delete records
        const collectionExists = await database.listCollections({ name: PiID }).hasNext();
        if (collectionExists) {
            const collection = database.collection(PiID);

            // Delete all records in the collection
            const deleteResult = await collection.deleteMany({});

            // Check the delete result if needed
            console.log(`${deleteResult.deletedCount} records deleted from collection ${PiID}`);

            // Respond with success message or any other appropriate response
            res.status(200).json({ message: `${deleteResult.deletedCount} records deleted from collection ${PiID}` });
        } else {
            // Respond with an appropriate message if the collection doesn't exist
            res.status(404).json({ message: `Collection ${PiID} not found in the BatchData database` });
        }

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

module.exports = router;
