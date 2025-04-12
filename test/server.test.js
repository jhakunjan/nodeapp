const request = require('supertest');
const app = require('../server');

describe('Simple Web App Routes', () => {
  it('GET / should return index.html', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  it('GET /about should return about.html', async () => {
    const res = await request(app).get('/about');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  it('GET /non-existent should return 404.html', async () => {
    const res = await request(app).get('/non-existent');
    expect(res.statusCode).toBe(404);
    expect(res.headers['content-type']).toContain('text/html');
  });
});
