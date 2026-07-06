const { afterEach, beforeEach, test } = require("node:test");
const assert = require("node:assert/strict");

const ORIGINAL_ENV = { ...process.env };

function loadDatabaseModule() {
  delete require.cache[require.resolve("../src/database")];
  return require("../src/database");
}

beforeEach(() => {
  process.env = { ...ORIGINAL_ENV };
  delete process.env.POSTGRES_HOST;
  delete process.env.POSTGRES_DB;
  delete process.env.POSTGRES_USER;
  delete process.env.POSTGRES_PASSWORD;
  delete process.env.POSTGRES_AUTH_MODE;
  delete process.env.APP_CLIENT_ID;
});

afterEach(() => {
  process.env = { ...ORIGINAL_ENV };
});

test("resolveAuthMode defaults to entra", () => {
  const { resolveAuthMode } = loadDatabaseModule();
  assert.equal(resolveAuthMode(), "entra");
});

test("resolveAuthMode accepts entra", () => {
  process.env.POSTGRES_AUTH_MODE = "entra";
  const { resolveAuthMode } = loadDatabaseModule();
  assert.equal(resolveAuthMode(), "entra");
});

test("resolveAuthMode rejects unknown modes", () => {
  process.env.POSTGRES_AUTH_MODE = "oauth";
  const { resolveAuthMode } = loadDatabaseModule();
  assert.throws(() => resolveAuthMode(), /Invalid POSTGRES_AUTH_MODE/);
});

test("isPostgresConfigured requires password in password mode", () => {
  process.env.POSTGRES_AUTH_MODE = "password";
  process.env.POSTGRES_HOST = "db.example.com";
  process.env.POSTGRES_DB = "app";
  process.env.POSTGRES_USER = "app-user";

  const { isPostgresConfigured } = loadDatabaseModule();
  assert.equal(isPostgresConfigured(), false);

  process.env.POSTGRES_PASSWORD = "secret";
  const configured = loadDatabaseModule();
  assert.equal(configured.isPostgresConfigured(), true);
});

test("isPostgresConfigured does not require password in entra mode", () => {
  process.env.POSTGRES_AUTH_MODE = "entra";
  process.env.POSTGRES_HOST = "db.example.com";
  process.env.POSTGRES_DB = "app";
  process.env.POSTGRES_USER = "id-app-workload";

  const { isPostgresConfigured } = loadDatabaseModule();
  assert.equal(isPostgresConfigured(), true);
});

test("checkDatabase reports not_configured when password mode lacks password", async () => {
  process.env.POSTGRES_AUTH_MODE = "password";
  process.env.POSTGRES_HOST = "db.example.com";
  process.env.POSTGRES_DB = "app";
  process.env.POSTGRES_USER = "app-user";

  const { checkDatabase } = loadDatabaseModule();
  const result = await checkDatabase();

  assert.deepEqual(result, {
    configured: false,
    authMode: "password",
    status: "not_configured",
  });
});
