const request = require('supertest');
const path = require('path');
const fs = require('fs');
const app = require('../server');

describe('Express app', () => {
  test('GET / should return 200 and HTML content', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  test('GET /about should return 200 and HTML content', async () => {
    const res = await request(app).get('/about');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  test('GET /nonexistent should return 404 and HTML content', async () => {
    const res = await request(app).get('/nonexistent');
    expect(res.statusCode).toBe(404);
    expect(res.headers['content-type']).toContain('text/html');
  });
});
