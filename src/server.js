const express = require("express");
const {
  checkDatabase,
  createDeployment,
  getDeployment,
  getDeploymentStats,
  initDatabase,
  listDeployments,
} = require("./database");

const PORT = Number(process.env.PORT) || 3000;
const APP_VERSION = process.env.APP_VERSION || "0.0.0";
const NODE_ENV = process.env.NODE_ENV || "development";

const app = express();
app.use(express.json());

app.get("/health", async (_req, res) => {
  let database;
  try {
    database = await checkDatabase();
  } catch (err) {
    database = {
      configured: true,
      error: err.message,
      status: "error",
    };
  }

  const status =
    database.configured && database.status !== "ok" ? "degraded" : "ok";

  res.status(status === "ok" ? 200 : 503).json({
    database,
    status,
    timestamp: new Date().toISOString(),
  });
});

app.get("/version", (_req, res) => {
  res.json({
    version: APP_VERSION,
    environment: NODE_ENV,
  });
});

app.post("/deployments", async (req, res) => {
  const { service, version, environment } = req.body ?? {};
  if (
    typeof service !== "string" ||
    typeof version !== "string" ||
    typeof environment !== "string" ||
    !service.trim() ||
    !version.trim() ||
    !environment.trim()
  ) {
    return res.status(400).json({
      error:
        "Body must include non-empty string fields: service, version, environment",
    });
  }

  const record = await createDeployment({
    service: service.trim(),
    version: version.trim(),
    environment: environment.trim(),
  });
  res.status(201).json(record);
});

app.get("/deployments", async (_req, res) => {
  res.json(await listDeployments());
});

app.get("/deployments/stats", async (_req, res) => {
  res.json(await getDeploymentStats());
});

app.get("/deployments/:id", async (req, res) => {
  const record = await getDeployment(req.params.id);
  if (!record) {
    return res.status(404).json({ error: "Deployment not found" });
  }

  res.json(record);
});

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
});

async function start() {
  await initDatabase();
  return app.listen(PORT, () => {
    console.log(`devops-tracker listening on port ${PORT} (${NODE_ENV})`);
  });
}

if (require.main === module) {
  start().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}

module.exports = { app, start };
