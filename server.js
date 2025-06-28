const express = require('express');
const app = express();
const port = 3000;

// Import and register prom-client
const client = require('prom-client');
client.collectDefaultMetrics();

// Optional: add a custom metric
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
});

app.get('/', (req, res) => {
  httpRequestCounter.inc(); // Increment custom metric
  res.send('Welcome to the Car Showcase App!');
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

