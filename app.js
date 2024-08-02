const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const apiKeyMiddleware = require('./apiKey');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3004;

app.use(cors());

app.use(express.json());
app.use(bodyParser.json({ limit: '10mb' }));

// Custom JSON parsing error handler middleware
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    res.status(400).json({ error: 'Invalid JSON format' });
  } else {
    next();
  }
});

app.use((req, res, next) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);
  console.log('Request headers:', req.headers);
  console.log('Request body:', req.body);
  next();
});

app.use('/api/mills', apiKeyMiddleware, require('./api/mills'));
app.use('/api/users', apiKeyMiddleware, require('./api/users'));
app.use('/api/threshold', apiKeyMiddleware, require('./api/threshold'));
app.use('/api/insertToken', apiKeyMiddleware, require('./api/insertToken'));
app.use('/api/fcm-server', apiKeyMiddleware, require('./api/fcm-server'));
app.use('/api/updateThreshold', apiKeyMiddleware, require('./api/updateThreshold'));
app.use('/api/updateLabel', apiKeyMiddleware, require('./api/updateLabel'));
app.use('/api/streams', apiKeyMiddleware, require('./api/streams'));
app.use('/api/addUser', apiKeyMiddleware, require('./api/addUser'));
app.use('/api/userList', apiKeyMiddleware, require('./api/userList'));
app.use('/api/getMill', apiKeyMiddleware, require('./api/getmills'));
app.use('/api/getLatestData', apiKeyMiddleware, require('./api/getLatestData'));

//Pi & VM server only
app.use('/api/getallmills', apiKeyMiddleware, require('./api/getallmills'));
app.use('/api/addmill', apiKeyMiddleware, require('./api/addmill'));
app.use('/api/data/batch', apiKeyMiddleware, require('./api/data/batch'));
app.use('/api/data/deletebatch', apiKeyMiddleware, require('./api/data/deletebatch'));
app.use('/api/updateTunnel', apiKeyMiddleware, require('./api/updateTunnel'));
app.use('/api/data/minuteData', apiKeyMiddleware, require('./api/data/minuteData'));
app.use('/api/data/hourData', apiKeyMiddleware, require('./api/data/hourData'));
app.use('/api/data/dayData', apiKeyMiddleware, require('./api/data/dayData'));
app.use('/api/getAdmin', apiKeyMiddleware, require('./api/getAdmin'));

// Create HTTP server
const server = http.createServer(app);

// Create Socket.io server
const io = socketIo(server, {
  cors: {
    origin: "*",
  },
});

io.on('connection', (socket) => {
  console.log('Socket.io connection established');

  socket.on('message', (message) => {
    console.log('Received message:', message);
    // Handle WebSocket messages here
  });

  socket.on('disconnect', () => {
    console.log('Socket.io connection closed');
  });

  // Example of sending periodic data
  const sendData = () => {
    const sampleData = {
      timestamp: new Date(),
      value: Math.random() * 100
    };
    socket.emit('data', sampleData);
  };

  const intervalId = setInterval(sendData, 5000); // Send data every 5 seconds

  socket.on('disconnect', () => {
    clearInterval(intervalId);
  });
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
