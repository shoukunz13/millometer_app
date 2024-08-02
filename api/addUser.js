//Function : To add user to users collection or update user record in the users collection where when they are added or assigned to another mill. 
//           If the user is completely new (not an existing user), they will be inserted into the users collection.
//           If the user is already exist but being added/assigned to a different mill, their record will be update ('mills' array attribute in their user record will be updated)

// Required param/query/body :-
// query : commitNum
// body : role , phoneNum, PiID, name
const { MongoClient, ObjectID } = require('mongodb');
const express = require('express');
const connectionString = require("../dbconfig");

const router = express.Router();

// connection string of mongo DB
const uri = connectionString;
const client = new MongoClient(uri);

router.post('/', async (req, res) => {
    try {
        await client.connect();

        // connect to database named MillProject
        const database = client.db('MillProject');

        // access to users and mills collections
        const users = database.collection('users');
        const mill = database.collection('mills');

        //params & body
        //this is the phone number of the person who added the user, for engineer record use
        const commitNum = req.query.commitNum;
        const role = req.body.role;
        const phoneNum = req.body.phoneNum;
        const PiID = req.body.PiID;
        const name = req.body.name;
        const status = 'active';

        // Check if the user already exists, 
        // if exist just push new mill to their record
        const existingUser = await users.findOne({ phoneNum: phoneNum });
        const millThreshold = await mill.findOne({ PiID: PiID });
        if (!millThreshold) {       // mill does not exist
            res.json({ error: 'The specified PiID does not exist. Makesure the mill is registered!' })
        } else {        // mill does exist
            if (existingUser) {
                const millExists = existingUser.mills.some(mill => mill.PiID === PiID);

                if (millExists) {
                    res.json(`User was already added to this mill with PiID of ${PiID}.`);
                    return;  // Exit the function early if the mill already exists for this user
                }

                const parameters = millThreshold.parameters; // array of parameters (in sequence with threshold index)
                const thresholds = millThreshold.thresholds; // array of thresholds 
                const thresholdObjectPair = [];

                for (let i = 0; i < parameters.length; i++) {
                    thresholdObjectPair.push({ parameter: parameters[i], value: thresholds[i] })
                }

                const newMill = {
                    PiID: PiID,
                    thresholds: thresholdObjectPair, // Use millThreshold.thresholds if available
                    label: null, // Default label is null
                };

                existingUser.mills.push(newMill);

                const result = await users.updateOne(
                    { phoneNum: phoneNum },
                    { $set: existingUser }
                );

                if (result.modifiedCount === 1) {
                    res.json(`User record updated successfully by ${commitNum}`);
                } else {
                    res.json(`User record update failed by  ${commitNum} `);
                }
            }
            else {          // user does not exists , so new user will be created and added to the users collection
                let newUser = {}
                if (role == 'owner') {
                    newUser =
                    {
                        phoneNum: phoneNum,
                        role: role, // Set the role as provided
                        devices: [], // Initialize with an empty array
                        mills: [], // Initialize with an empty array
                        status: status,
                        name: name,
                        state: 0, // Set the status as 'active'
                    };
                } else if (role == 'engineer') {
                    newUser =
                    {
                        phoneNum: phoneNum,
                        ownerNum: commitNum,
                        role: role, // Set the role as provided
                        devices: [], // Initialize with an empty array
                        mills: [], // Initialize with an empty array
                        status: status,
                        name: name,
                        state: 0, // Set the status as 'active'
                    };
                }
                const parameters = millThreshold.parameters; // array of parameters (in sequence with threshold index)
                const thresholds = millThreshold.thresholds; // array of thresholds 
                const thresholdObjectPair = [];
                for (let i = 0; i < parameters.length; i++) {
                    thresholdObjectPair.push({ parameter: parameters[i], value: thresholds[i] })
                }

                const newMill = {
                    PiID: PiID,
                    thresholds:
                        thresholdObjectPair, // Use millThreshold.thresholds if available
                    label: null, // Default label is null
                };

                newUser.mills.push(newMill);
                const result = await users.insertOne(newUser); // inserts the newUser to the users collection

                if (result.acknowledged) {
                    console.log(`New user record created successfully created by ${commitNum}`);
                    res.json(`New user record created successfully created by ${commitNum} `);
                } else {
                    console.log("User record creation failed");
                    res.json('User record creation failed');
                }
            }
        }

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'An error occurred while processing the request' });
    }
});

module.exports = router;