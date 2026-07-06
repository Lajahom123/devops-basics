const { randomUUID } = require("crypto");
const { DefaultAzureCredential } = require("@azure/identity");
const { Pool } = require("pg");

const DATABASE_SSL = process.env.DATABASE_SSL === "true";
const DATABASE_SSL_REJECT_UNAUTHORIZED =
  process.env.DATABASE_SSL_REJECT_UNAUTHORIZED !== "false";

const POSTGRES_HOST = process.env.POSTGRES_HOST;
const POSTGRES_PORT = Number(process.env.POSTGRES_PORT || 5432);
const POSTGRES_DB = process.env.POSTGRES_DB;
const POSTGRES_USER = process.env.POSTGRES_USER;
const POSTGRES_PASSWORD = process.env.POSTGRES_PASSWORD;
const APP_CLIENT_ID = process.env.APP_CLIENT_ID;

const POSTGRES_AUTH_MODE = (process.env.POSTGRES_AUTH_MODE || "entra").toLowerCase();
const POSTGRES_TOKEN_SCOPE = "https://ossrdbms-aad.database.windows.net/.default";

const TOKEN_REFRESH_BUFFER_MS = 5 * 60 * 1000;

const memoryDeployments = [];

let pool = null;
let tokenExpiresAt = 0;
let poolRefreshPromise = null;
let credential = null;

function resolveAuthMode() {
  if (POSTGRES_AUTH_MODE !== "password" && POSTGRES_AUTH_MODE !== "entra") {
    throw new Error(
      `Invalid POSTGRES_AUTH_MODE "${POSTGRES_AUTH_MODE}". Expected "password" or "entra".`,
    );
  }

  return POSTGRES_AUTH_MODE;
}

function isPostgresConfigured() {
  if (!POSTGRES_HOST || !POSTGRES_DB || !POSTGRES_USER) {
    return false;
  }

  if (resolveAuthMode() === "password") {
    return Boolean(POSTGRES_PASSWORD);
  }

  return true;
}

function getCredential() {
  if (!credential) {
    const options = {};

    if (APP_CLIENT_ID) {
      options.managedIdentityClientId = APP_CLIENT_ID;
    }

    credential = new DefaultAzureCredential(options);
  }

  return credential;
}

async function resolveCredentials() {
  if (resolveAuthMode() === "password") {
    if (!POSTGRES_PASSWORD) {
      throw new Error("POSTGRES_PASSWORD is required when POSTGRES_AUTH_MODE=password");
    }

    return {
      password: POSTGRES_PASSWORD,
      expiresAt: Number.POSITIVE_INFINITY,
    };
  }

  const token = await getCredential().getToken(POSTGRES_TOKEN_SCOPE);

  if (!token?.token) {
    throw new Error("Failed to obtain PostgreSQL Entra access token");
  }

  return {
    password: token.token,
    expiresAt: token.expiresOnTimestamp ?? 0,
  };
}

function buildPoolConfig(password) {
  return {
    host: POSTGRES_HOST,
    port: POSTGRES_PORT,
    database: POSTGRES_DB,
    user: POSTGRES_USER,
    password,
    ssl: DATABASE_SSL
      ? { rejectUnauthorized: DATABASE_SSL_REJECT_UNAUTHORIZED }
      : undefined,
  };
}

function isPoolStale() {
  if (!pool) {
    return true;
  }

  if (resolveAuthMode() === "password") {
    return false;
  }

  return Date.now() >= tokenExpiresAt - TOKEN_REFRESH_BUFFER_MS;
}

async function refreshPool() {
  const oldPool = pool;
  pool = null;

  const { password, expiresAt } = await resolveCredentials();
  tokenExpiresAt = expiresAt;
  pool = new Pool(buildPoolConfig(password));

  if (oldPool) {
    oldPool.end().catch((err) => {
      console.error("failed to close stale PostgreSQL pool", err);
    });
  }

  return pool;
}

async function getPool() {
  if (!isPostgresConfigured()) {
    return null;
  }

  if (isPoolStale()) {
    if (!poolRefreshPromise) {
      poolRefreshPromise = refreshPool().finally(() => {
        poolRefreshPromise = null;
      });
    }

    await poolRefreshPromise;
  }

  return pool;
}

function mapDeployment(row) {
  return {
    id: row.id,
    service: row.service,
    version: row.version,
    environment: row.environment,
    status: row.status,
    recordedAt: row.recorded_at.toISOString(),
  };
}

async function initDatabase() {
  const db = await getPool();

  if (!db) {
    return;
  }

  await db.query("SELECT 1");
}

async function checkDatabase() {
  if (!POSTGRES_HOST || !POSTGRES_DB || !POSTGRES_USER) {
    return {
      configured: false,
      status: "not_configured",
    };
  }

  const authMode = resolveAuthMode();

  if (authMode === "password" && !POSTGRES_PASSWORD) {
    return {
      configured: false,
      authMode,
      status: "not_configured",
    };
  }

  const db = await getPool();
  await db.query("SELECT 1");

  return {
    configured: true,
    authMode,
    status: "ok",
  };
}

async function createDeployment({ service, version, environment }) {
  const record = {
    id: randomUUID(),
    service,
    version,
    environment,
    recordedAt: new Date().toISOString(),
  };

  const db = await getPool();

  if (!db) {
    memoryDeployments.push(record);
    return record;
  }

  const result = await db.query(
    `
      INSERT INTO deployments (id, service, version, environment, recorded_at, status)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, service, version, environment, recorded_at, status
    `,
    [record.id, service, version, environment, record.recordedAt, "success"],
  );

  return mapDeployment(result.rows[0]);
}

async function listDeployments() {
  const db = await getPool();

  if (!db) {
    return [...memoryDeployments];
  }

  const result = await db.query(`
    SELECT id, service, version, environment, recorded_at, status
    FROM deployments
    ORDER BY recorded_at DESC
  `);

  return result.rows.map(mapDeployment);
}

async function getDeployment(id) {
  const db = await getPool();

  if (!db) {
    return memoryDeployments.find((deployment) => deployment.id === id) ?? null;
  }

  const result = await db.query(
    `
      SELECT id, service, version, environment, recorded_at, status
      FROM deployments
      WHERE id = $1
    `,
    [id],
  );

  return result.rows[0] ? mapDeployment(result.rows[0]) : null;
}

async function getDeploymentStats() {
  const db = await getPool();

  if (!db) {
    return memoryDeployments
      .reduce((stats, deployment) => {
        const key = deployment.environment;
        const current = stats.find((item) => item.environment === key);

        if (current) {
          current.count += 1;
        } else {
          stats.push({ environment: key, count: 1 });
        }

        return stats;
      }, [])
      .sort((left, right) => left.environment.localeCompare(right.environment));
  }

  const result = await db.query(`
    SELECT environment, COUNT(*)::int AS count
    FROM deployments
    GROUP BY environment
    ORDER BY environment ASC
  `);

  return result.rows;
}

async function closeDatabase() {
  if (pool) {
    await pool.end();
    pool = null;
    tokenExpiresAt = 0;
  }
}

function resetForTests() {
  memoryDeployments.length = 0;
  pool = null;
  tokenExpiresAt = 0;
  poolRefreshPromise = null;
  credential = null;
}

module.exports = {
  checkDatabase,
  closeDatabase,
  createDeployment,
  getDeployment,
  getDeploymentStats,
  initDatabase,
  isPostgresConfigured,
  listDeployments,
  resetForTests,
  resolveAuthMode,
};