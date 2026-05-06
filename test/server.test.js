const { beforeEach, test } = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const { app } = require("../src/server");
const { resetForTests } = require("../src/database");

beforeEach(() => {
  resetForTests();
});

test("GET /health responds with ok status", async () => {
  const res = await request(app).get("/health").expect(200);
  assert.equal(res.body.status, "ok");
  assert.equal(res.body.database.status, "not_configured");
  assert.match(res.body.timestamp, /^\d{4}-\d{2}-\d{2}T/);
});

test("POST /deployments rejects empty body", async () => {
  const res = await request(app).post("/deployments").send({}).expect(400);
  assert.ok(typeof res.body.error === "string");
});

test("POST /deployments stores and returns a deployment", async () => {
  const createRes = await request(app)
    .post("/deployments")
    .send({ service: "api", version: "2.1.0", environment: "staging" })
    .expect(201);

  assert.equal(createRes.body.service, "api");
  assert.equal(createRes.body.version, "2.1.0");
  assert.equal(createRes.body.environment, "staging");
  assert.match(createRes.body.id, /^[0-9a-f-]{36}$/);

  const listRes = await request(app).get("/deployments").expect(200);
  assert.equal(listRes.body.length, 1);
  assert.equal(listRes.body[0].id, createRes.body.id);

  const getRes = await request(app)
    .get(`/deployments/${createRes.body.id}`)
    .expect(200);
  assert.equal(getRes.body.id, createRes.body.id);
});

test("GET /deployments/stats groups deployments by environment", async () => {
  await request(app)
    .post("/deployments")
    .send({ service: "api", version: "2.1.0", environment: "staging" })
    .expect(201);
  await request(app)
    .post("/deployments")
    .send({ service: "worker", version: "1.4.0", environment: "staging" })
    .expect(201);

  const res = await request(app).get("/deployments/stats").expect(200);
  assert.deepEqual(res.body, [{ environment: "staging", count: 2 }]);
});
