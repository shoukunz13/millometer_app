const API_KEY = '1b50e01f728f56b50a66c92261b746c0aa8277251de247df713d72f5a8a65b04'; // Replace with your actual API key

const apiKeyMiddleware = (req, res, next) => {
  const providedKey = req.headers['api-key'];

  if (!providedKey || providedKey !== API_KEY) {
    return res.status(403).json({ error: 'Unauthorized. Invalid API key.' });
  }

  next();
};

module.exports = apiKeyMiddleware