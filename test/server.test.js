const request = require('supertest');
const app = require('../app'); // This runs app.listen, so we can't use it directly
const http = require('http');

let server;

beforeAll((done) => {
  // Manually create server from app
  server = http.createServer(app);
  server.listen(() => done());
});

afterAll((done) => {
  server.close(done);
});

describe('Express app', () => {
  test('GET / should return 200 and HTML content', async () => {
    const res = await request(server).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  test('GET /about should return 200 and HTML content', async () => {
    const res = await request(server).get('/about');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/html');
  });

  test('GET /nonexistent should return 404 and HTML content', async () => {
    const res = await request(server).get('/nonexistent');
    expect(res.statusCode).toBe(404);
    expect(res.headers['content-type']).toContain('text/html');
  });
});
