const { test } = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const { app } = require("../src/server");

test("GET /health responds with ok status", async () => {
  const res = await request(app).get("/health").expect(200);
  assert.equal(res.body.status, "ok");
  assert.match(res.body.timestamp, /^\d{4}-\d{2}-\d{2}T/);
});

test("POST /deployments rejects empty body", async () => {
  const res = await request(app).post("/deployments").send({}).expect(400);
  assert.ok(typeof res.body.error === "string");
});
