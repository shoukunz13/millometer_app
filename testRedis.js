// Replace these values with your Redis server information
const redis = require('redis');

const selectedDB = 1;
async function tryRedis(){
  // Create a Redis client
  
const client = await redis.createClient({
  url: 'redis://:N@nda123@35.185.176.148:6379',
  // password: redisPassword,
})
client.on('error', (err) => console.error('Redis Client Error', err));

await client.connect()
client.select()

await client.set('key', 'nanda testing');
const value = await client.get('key');
console.log(value);
await client.disconnect();

}

tryRedis();

