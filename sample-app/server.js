const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to EKS Demo Application!',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    hostname: require('os').hostname()
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'eks-demo-app',
    author: 'Kartheepan',
    description: 'Sample CI/CD pipeline with GitHub Actions and Flux',
    tech_stack: ['Node.js', 'Express', 'Docker', 'Kubernetes', 'EKS', 'Flux', 'GitHub Actions']
  });
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = { app, server };
console.log('Build triggered');


// Build trigger
