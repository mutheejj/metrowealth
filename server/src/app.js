require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mpesaRoutes = require('./routes/mpesa');
const app = express();
const port = process.env.PORT || 3000;
const errorHandler = require('./middleware/errorHandler');

app.use(cors());
app.use(express.json());

// Mount M-Pesa routes
app.use('/api/mpesa', mpesaRoutes);

// Basic route for testing
app.get('/', (req, res) => {
  res.json({ message: 'M-Pesa API Server is running' });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Error handling middleware
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});