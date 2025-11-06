const request = require('supertest');
const { app, server } = require('./server');

describe('Express Server Tests', () => {
  afterAll((done) => {
    server.close(done);
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('message');
    expect(response.body.message).toContain('Welcome to EKS Demo Application');
  });

  test('GET /health should return healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
    expect(response.body).toHaveProperty('timestamp');
  });

  test('GET /api/info should return application info', async () => {
    const response = await request(app).get('/api/info');
    expect(response.status).toBe(200);
    expect(response.body.app).toBe('eks-demo-app');
    expect(response.body).toHaveProperty('tech_stack');
    expect(Array.isArray(response.body.tech_stack)).toBe(true);
  });
});
