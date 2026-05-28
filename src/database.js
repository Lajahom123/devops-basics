const { randomUUID } = require("crypto");
const { DefaultAzureCredential, ManagedIdentityCredential } = require("@azure/identity");
const { Pool } = require("pg");

const DATABASE_SSL = process.env.DATABASE_SSL === "true";
const DATABASE_SSL_REJECT_UNAUTHORIZED =
  process.env.DATABASE_SSL_REJECT_UNAUTHORIZED !== "false";

const POSTGRES_HOST = process.env.POSTGRES_HOST;
const POSTGRES_PORT = Number(process.env.POSTGRES_PORT || 5432);
const POSTGRES_DB = process.env.POSTGRES_DB;
const POSTGRES_USER = process.env.POSTGRES_USER;
const APP_CLIENT_ID = process.env.APP_CLIENT_ID;

const POSTGRES_TOKEN_SCOPE = "https://ossrdbms-aad.database.windows.net/.default";

const memoryDeployments = [];

let pool = null;

function isPostgresConfigured() {
  return Boolean(POSTGRES_HOST && POSTGRES_DB && POSTGRES_USER);
}

function createCredential() {
  if (APP_CLIENT_ID) {
    return new ManagedIdentityCredential(APP_CLIENT_ID);
  }

  return new DefaultAzureCredential();
}

async function getPostgresAccessToken() {
  const credential = createCredential();

  const token = await credential.getToken(POSTGRES_TOKEN_SCOPE);

  if (!token?.token) {
    throw new Error("Failed to obtain PostgreSQL Entra access token");
  }

  return token.token;
}

async function getPool() {
  if (pool) {
    return pool;
  }

  if (!isPostgresConfigured()) {
    return null;
  }

  const password = await getPostgresAccessToken();

  pool = new Pool({
    host: POSTGRES_HOST,
    port: POSTGRES_PORT,
    database: POSTGRES_DB,
    user: POSTGRES_USER,
    password,
    ssl: DATABASE_SSL
      ? { rejectUnauthorized: DATABASE_SSL_REJECT_UNAUTHORIZED }
      : undefined,
  });

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
  const db = await getPool();

  if (!db) {
    return {
      configured: false,
      status: "not_configured",
    };
  }

  await db.query("SELECT 1");

  return {
    configured: true,
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
    SELECT id, service, version, environment, recorded_at
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
      SELECT id, service, version, environment, recorded_at
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
  }
}

function resetForTests() {
  memoryDeployments.length = 0;
}

module.exports = {
  checkDatabase,
  closeDatabase,
  createDeployment,
  getDeployment,
  getDeploymentStats,
  initDatabase,
  listDeployments,
  resetForTests,
};
