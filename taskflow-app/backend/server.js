const express = require('express');
const cors = require('cors');
require('dotenv').config();

const connectDB = require('./config/database');
const taskRoutes = require('./routes/tasks');

// Initialize Express app
const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'TaskFlow backend is running' });
});

// Routes
app.use('/tasks', taskRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({ message: 'TaskFlow API Server', version: '1.0.0' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ message: 'Internal server error', error: err.message });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`TaskFlow backend running on port ${PORT}`);
  console.log(`API available at http://localhost:${PORT}`);
});
