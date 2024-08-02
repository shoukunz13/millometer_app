const { MongoClient } = require('mongodb');
const express = require('express');
const { DateTime } = require('luxon');
const redis = require('redis');

const router = express.Router();

// Mongo DB Connection String
const uri =
  'mongodb://127.0.0.1:27017/MillProject';

const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

// Connect to MongoDB on application startup
client.connect().then(() => {
  console.log('Connected to MongoDB');
});

// POST request
router.post('/', async (req, res) => {
  try {

    // query and body of the api 
    const data = req.body.data;
    const PiID = req.query.PiID;

    // if there is no data, error handling will take place
    if (!data) {
      return res.status(400).json({
        success: false,
        error: 'Data is missing in the request body',
      });
    }

    // to check the timestamp is in correct format
    const isValidISOFormat = data.every(entry => {
      return DateTime.fromISO(entry.timestamp, { zone: 'utc', setZone: true }).isValid;
    });

    // if the timestamp is not in correct format, the error handling will take place
    if (!isValidISOFormat) {
      return res.status(400).json({
        success: false,
        error: 'Timestamp in the data should be in ISO format',
      });
    }

    // connect to MillProject database and access the mills collection
    const millProjectDB = client.db('MillProject');
    const mills = millProjectDB.collection('mills');

    // to find the particular piid
    const piExist = await mills.findOne({ PiID: PiID });

    // check if the piID exists
    if (piExist) {
      // connect to BatchData database and access the related PiID collection
      const database = client.db('BatchData');
      const collection = database.collection(PiID);
      
      // connect to MinuteData database and access the related PiID collection
      const minuteDatabase = client.db('MinuteData');
      const minuteCollection = minuteDatabase.collection(PiID);

      // write the data into the batch database
      const bulkWriteResult = await collection.bulkWrite(
        data.map((document) => ({
          insertOne: {
            document: {
              ...document,
              timestamp: new Date(document.timestamp), // Convert to Date object
            }
          },
        }))
      );

      await calculateMinuteAverages(PiID, data, minuteCollection);

      await aggregateAndInsertHourData(PiID);

      await aggregateAndInsertDayData(PiID);
      
      // if all the data is aggregated and written into the database, the success message will be displayed
      res.status(201).json({
        success: true,
        insertedCount: bulkWriteResult.insertedCount,
      });

      console.log('Inserted', bulkWriteResult.insertedCount, 'records to PiID', PiID)
    } else {          // if piid does not exist

      // error handling will take place
      res.status(400).json({
        success: false,
        error: 'Please specify PiID query in your link and make sure the mill with that PiID exists',
      });
    }
  } catch (error) {           // if there is an exception happens, the catch block will display the error
    console.error('Error inserting documents:', error);
    res.status(500).json({ success: false, error: 'Error inserting documents' });
  }
});

async function calculateMinuteAverages(PiID, data, minuteCollection) {

  // ORDER OF THIS OBJECT FIELDS MATTERS
  // initialise the field for sum, max and min value, and will be changed by assigning the real data from the database
  let fieldSums = {
    'power_load': 0,
    'steam_pressure': 0,
    'steam_flow': 0,
    'water_level': 0,
    'power_frequency': 0,
  };

  let fieldMax = {
    'max_power_load': Number.NEGATIVE_INFINITY,
    'max_steam_pressure': Number.NEGATIVE_INFINITY,
    'max_steam_flow': Number.NEGATIVE_INFINITY,
    'max_water_level': Number.NEGATIVE_INFINITY,
    'max_power_frequency': Number.NEGATIVE_INFINITY,
  }

  let fieldMin = {
    'max_power_load': Number.MAX_VALUE,
    'max_steam_pressure': Number.MAX_VALUE,
    'max_steam_flow': Number.MAX_VALUE,
    'max_water_level': Number.MAX_VALUE,
    'max_power_frequency': Number.MAX_VALUE,
  }
  
  // get the first timestamp of the data
  let startTimestamp = DateTime.fromJSDate(new Date(data[0].timestamp), { zone: 'UTC' });
  let endTimestamp;
  let averageCount = 0;

  // get the minute of the first and last timestamp of the data
  let firstMinute = DateTime.fromJSDate(new Date(data[0].timestamp), { zone: 'UTC' }).minute;
  let lastMinute = DateTime.fromJSDate(new Date(data[data.length - 1].timestamp), { zone: 'UTC' }).minute;


  let aggregatedFirst = [];
  let aggregatedLast = [];

  console.log(firstMinute, lastMinute);

  data.forEach((entry) => {
    endTimestamp = DateTime.fromJSDate(new Date(entry.timestamp), { zone: 'UTC' });

    // to ensure the minute of endtimestamp is not the minute of first and last data
    if (endTimestamp.minute !== firstMinute && endTimestamp.minute !== lastMinute) {
      if (endTimestamp.diff(startTimestamp).as('milliseconds') < 60000) {       // 60000 milliseconds = 60 seconds
        averageCount++;

        // loop for every record in the fieldSums initialised, assign the value from the real data to the fieldSums field
        // to get the total value of the data
        // used to count the average value of the data
        Object.keys(fieldSums).forEach((field) => {
          fieldSums[field] += entry[field];
        });

        // loop for every record from data variable, assign the value from the real data into fieldMax and fieldMin 
        // to compare and get the max and min data
        // the initial data for min and max is infinite negative and positive
        Object.keys(entry).forEach((field) => {
          if (field !== 'timestamp') {
            const CURRENTVALUE = entry[field];
            const MAXFIELDVALUE = fieldMax['max_' + field];
            const MINFIELDVALUE = fieldMin['min_' + field]
        
            fieldMax['max_' + field] = Math.max(MAXFIELDVALUE, CURRENTVALUE);
            fieldMin['min_' + field] = Math.min(MINFIELDVALUE, CURRENTVALUE);
          }
        });        
      } else {

        // +1000 is correction factor
        // 1000 is in milliseconds which is 1 second 
        let averageMinMaxValues = {
          'timestamp': new Date(startTimestamp.toJSDate().getTime()+1000),
        };
        
        // assign the avg to averageminmaxvalue list
        Object.keys(fieldSums).forEach((field) => {
          averageMinMaxValues['avg_'+field] = fieldSums[field] / averageCount;
        });

        // assign the max to averageminmaxvalue list
        Object.keys(fieldMax).forEach((field)=>{
          averageMinMaxValues[field] = fieldMax[field]
        })
        
        // assign the min to averageminmaxvalue list
        Object.keys(fieldMin).forEach((field)=>{
          averageMinMaxValues[field] = fieldMin[field]
        })

        // let insertValues = {}

        // Object.keys(averageMinMaxValues).forEach((field)=>{
        //   insertValues[field] = averageMinMaxValues[field]
        // })
        
        // Insert average, min and max to Mongo
        minuteCollection.insertOne(averageMinMaxValues);

        //Reset values
        averageCount = 1;
        startTimestamp = endTimestamp;

        // reassign the value of sum, max and min to process the next timestamp
        fieldSums = {
          'power_load': entry['power_load'],
          'steam_pressure': entry['steam_pressure'],
          'steam_flow': entry['steam_flow'],
          'water_level': entry['water_level'],
          'power_frequency': entry['power_frequency'],
        };
        fieldMax = {
          'max_power_load': Number.NEGATIVE_INFINITY,
          'max_steam_pressure': Number.NEGATIVE_INFINITY,
          'max_steam_flow': Number.NEGATIVE_INFINITY,
          'max_water_level': Number.NEGATIVE_INFINITY,
          'max_power_frequency': Number.NEGATIVE_INFINITY,
        }
        fieldMin = {
          'min_power_load': Number.MAX_VALUE,
          'min_steam_pressure': Number.MAX_VALUE,
          'min_steam_flow': Number.MAX_VALUE,
          'min_water_level': Number.MAX_VALUE,
          'min_power_frequency': Number.MAX_VALUE,
        }
      }
    } else {                  // if the endtimestamp is either the same with minute of first data or last data
      startTimestamp = DateTime.fromJSDate(new Date(entry.timestamp), { zone: 'UTC' });
      
      //reset for max and min
      fieldMax = {
        'max_power_load': Number.NEGATIVE_INFINITY,
        'max_steam_pressure': Number.NEGATIVE_INFINITY,
        'max_steam_flow': Number.NEGATIVE_INFINITY,
        'max_water_level': Number.NEGATIVE_INFINITY,
        'max_power_frequency': Number.NEGATIVE_INFINITY,
      }
      fieldMin = {
        'min_power_load': Number.MAX_VALUE,
        'min_steam_pressure': Number.MAX_VALUE,
        'min_steam_flow': Number.MAX_VALUE,
        'min_water_level': Number.MAX_VALUE,
        'min_power_frequency': Number.MAX_VALUE,
      }

      if (endTimestamp.minute === firstMinute) {
        aggregatedFirst.push(entry);
      } else {
        aggregatedLast.push(entry);
      }
    }
  });

  let headValue = processData(aggregatedFirst)[0];
  let tailValue = processData(aggregatedLast)[0];

  console.log(headValue.timestamp, tailValue.timestamp);
  
  // Update or insert the document with the timestamp from headValue
  minuteCollection.updateOne(
    { timestamp: headValue.timestamp },
    { $set: headValue },
    { upsert: true }
  );
  
  // Update or insert the document with the timestamp from tailValue
  minuteCollection.updateOne(
    { timestamp: tailValue.timestamp },
    { $set: tailValue },
    { upsert: true }
  );
  

  // Required to push to redis in future update for a better precision average values for head and tails
  // await pushToRedis(PiID, aggregatedFirst, head);
  // await pushToRedis(PiID, aggregatedLast, tail);
  
}

//-------TEMPORARY FUNCTIONS FOR HANDLING HEAD AND TAIL-----
function processData(data) {
  // Group data by timestamp
  const groupedData = data.reduce((acc, obj) => {
    const timestamp = obj.timestamp.slice(0, 16) + ":00Z"; // Round down to the minute
    if (!acc[timestamp]) {
      acc[timestamp] = [];
    }
    acc[timestamp].push(obj);
    return acc;
  }, {});

  // Calculate averages, max, and min for each field
  const result = [];
  for (const timestamp in groupedData) {
    const dataForTimestamp = groupedData[timestamp];
    const avgData = {
      timestamp:  new Date(timestamp),
    };

    const fields = [
      "power_frequency",
      "power_load",
      "steam_flow",
      "steam_pressure",
      "water_level",
    ];

    fields.forEach((field) => {
      const values = dataForTimestamp.map((entry) => entry[field]);
      avgData[`avg_${field}`] = calculateAverage(values);
      avgData[`max_${field}`] = Math.max(...values);
      avgData[`min_${field}`] = Math.min(...values);
    });

    result.push(avgData);
  }

  return result;
}

function calculateAverage(values) {
  const sum = values.reduce((acc, val) => acc + val, 0);
  return sum / values.length;
}
// -----------------------------------------

async function pushToRedis(PiID, aggregatedList, indicator) {
  const client = redis.createClient({
    url: 'redis://:N@nda123@35.185.176.148:6379/1',
  });

  client.on('error', (err) => console.error('Redis Client Error', err));

  await client.connect();

  const minuteMap = {};

  for (const entry of aggregatedList) {
    const timestamp = DateTime.fromJSDate(new Date(entry.timestamp), { zone: 'UTC' });
    // Set seconds and milliseconds to 00 and 000
    const adjustedTimestamp = timestamp.set({ second: 0, millisecond: 0 });

    // Format the adjusted timestamp to ISO format
    const minuteKey = adjustedTimestamp.toISO();

    if (!minuteMap[minuteKey]) {
      minuteMap[minuteKey] = [];
    }
    minuteMap[minuteKey].push(entry);
  }

  for (const minuteKey in minuteMap) {
    let key = PiID + '_' + minuteKey;
    let minuteData = JSON.stringify(minuteMap[minuteKey]);

    if (indicator === 'head') {
      let parsedData = {};
      if(await client.exists(key) ){
        let existingData = await client.get(key);
        parsedData = JSON.parse(existingData);
        minuteMap[minuteKey].forEach((element) => {
          parsedData.push(element);
        });
      }else{
        parsedData = minuteMap[minuteKey]
      }
      for(let i=0 ; i < parsedData.length ; i++){
        // parsedData[i]
      }
      key = key + '_COMPLETE';
      await client.set(key, minuteData);
    } else {
      await client.set(key, minuteData);
    }
  }

  client.disconnect();
}

async function aggregateAndInsertHourData(PiID) {
  try {
      
      const minuteCollection = client.db('MinuteData').collection(PiID);

      // Get a sample document to dynamically determine fields
      const sampleDocument = await minuteCollection.findOne();

      // Dynamically determine fields for aggregation
      const fields = Object.keys(sampleDocument).filter(field => field.startsWith('avg_') || field.startsWith('min_') || field.startsWith('max_'));

      // Build accumulator object for the $group stage dynamically
      const accumulatorObject = {};
      fields.forEach(field => {
        accumulatorObject[`avg_${field.substring(4)}`] = { $avg: `$avg_${field.substring(4)}` };
        accumulatorObject[`max_${field.substring(4)}`] = { $max: `$max_${field.substring(4)}` }; // Fix max field
        accumulatorObject[`min_${field.substring(4)}`] = { $min: `$min_${field.substring(4)}` }; // Fix min field
    });

      // Aggregate data for each hour
      const aggregationPipeline = [
          {
              $group: {
                  _id: {
                      year: { $year: "$timestamp" },
                      month: { $month: "$timestamp" },
                      day: { $dayOfMonth: "$timestamp" },
                      hour: { $hour: "$timestamp" }
                  },
                  ...accumulatorObject  // Spread the accumulator object here
              }
          },
          {
              $addFields: {
                  timestamp: {
                      $dateFromParts: {
                          year: "$_id.year",
                          month: "$_id.month",
                          day: "$_id.day",
                          hour: "$_id.hour",
                          minute: 0,
                          second: 0,
                          millisecond: 0
                      }
                  }
              }
          }
      ];

      const aggregatedData = await minuteCollection.aggregate(aggregationPipeline).toArray();

      // Insert or update aggregated data in HourData database
      const hourCollection = client.db('HourData').collection(PiID);

      for (const aggregatedDoc of aggregatedData) {
          const filter = { timestamp: aggregatedDoc.timestamp };
          const update = { $set: aggregatedDoc };
          const options = { upsert: true };

          await hourCollection.updateOne(filter, update, options);
      }

      console.log("Data aggregated and inserted/upserted successfully.");
  } catch (error) {
      console.error(error);
  }
}


async function aggregateAndInsertDayData(PiID) {
  try {
      
      const hourCollection = client.db('HourData').collection(PiID);

      // Get a sample document to dynamically determine fields
      const sampleDocument = await hourCollection.findOne();

      // Dynamically determine fields for aggregation
      const fields = Object.keys(sampleDocument).filter(field => field.startsWith('avg_') || field.startsWith('min_') || field.startsWith('max_'));

      // Build accumulator object for the $group stage dynamically
      const accumulatorObject = {};
      fields.forEach(field => {
        accumulatorObject[`avg_${field.substring(4)}`] = { $avg: `$avg_${field.substring(4)}` };
        accumulatorObject[`max_${field.substring(4)}`] = { $max: `$max_${field.substring(4)}` }; // Fix max field
        accumulatorObject[`min_${field.substring(4)}`] = { $min: `$min_${field.substring(4)}` }; // Fix min field
    });

      // Aggregate data for each hour
      const aggregationPipeline = [
          {
              $group: {
                  _id: {
                      year: { $year: "$timestamp" },
                      month: { $month: "$timestamp" },
                      day: { $dayOfMonth: "$timestamp" }
                  },
                  ...accumulatorObject  // Spread the accumulator object here
              }
          },
          {
              $addFields: {
                  timestamp: {
                      $dateFromParts: {
                          year: "$_id.year",
                          month: "$_id.month",
                          day: "$_id.day",
                          hour: 0,
                          minute: 0,
                          second: 0,
                          millisecond: 0
                      }
                  }
              }
          }
      ];

      const aggregatedData = await hourCollection.aggregate(aggregationPipeline).toArray();

      // Insert or update aggregated data in HourData database
      const dayCollection = client.db('DayData').collection(PiID);

      for (const aggregatedDoc of aggregatedData) {
          const filter = { timestamp: aggregatedDoc.timestamp };
          const update = { $set: aggregatedDoc };
          const options = { upsert: true };

          await dayCollection.updateOne(filter, update, options);
      }

      console.log("Data aggregated and inserted/upserted successfully.");
  } catch (error) {
      console.error(error);
  }
}


module.exports = router;
