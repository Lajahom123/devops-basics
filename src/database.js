const { randomUUID } = require("crypto");
const { Pool } = require("pg");

const DATABASE_URL = process.env.DATABASE_URL;
const DATABASE_SSL = process.env.DATABASE_SSL === "true";
const DATABASE_SSL_REJECT_UNAUTHORIZED =
  process.env.DATABASE_SSL_REJECT_UNAUTHORIZED !== "false";

const memoryDeployments = [];

const pool = DATABASE_URL
  ? new Pool({
      connectionString: DATABASE_URL,
      ssl: DATABASE_SSL
        ? { rejectUnauthorized: DATABASE_SSL_REJECT_UNAUTHORIZED }
        : undefined,
    })
  : null;

function mapDeployment(row) {
  return {
    id: row.id,
    service: row.service,
    version: row.version,
    environment: row.environment,
    recordedAt: row.recorded_at.toISOString(),
  };
}

async function initDatabase() {
  if (!pool) {
    return;
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS deployments (
      id UUID PRIMARY KEY,
      service TEXT NOT NULL,
      version TEXT NOT NULL,
      environment TEXT NOT NULL,
      recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )
  `);
}

async function checkDatabase() {
  if (!pool) {
    return {
      configured: false,
      status: "not_configured",
    };
  }

  await pool.query("SELECT 1");
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

  if (!pool) {
    memoryDeployments.push(record);
    return record;
  }

  const result = await pool.query(
    `
      INSERT INTO deployments (id, service, version, environment, recorded_at)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, service, version, environment, recorded_at
    `,
    [record.id, service, version, environment, record.recordedAt],
  );

  return mapDeployment(result.rows[0]);
}

async function listDeployments() {
  if (!pool) {
    return [...memoryDeployments];
  }

  const result = await pool.query(`
    SELECT id, service, version, environment, recorded_at
    FROM deployments
    ORDER BY recorded_at DESC
  `);

  return result.rows.map(mapDeployment);
}

async function getDeployment(id) {
  if (!pool) {
    return memoryDeployments.find((deployment) => deployment.id === id) ?? null;
  }

  const result = await pool.query(
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
  if (!pool) {
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

  const result = await pool.query(`
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
