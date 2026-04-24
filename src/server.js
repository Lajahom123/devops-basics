const { randomUUID } = require("crypto");
const express = require("express");

const PORT = Number(process.env.PORT) || 3000;
const APP_VERSION = process.env.APP_VERSION || "0.0.0";
const NODE_ENV = process.env.NODE_ENV || "development";

/** @type {Array<{ id: string, service: string, version: string, environment: string, recordedAt: string }>} */
const deployments = [];

const app = express();
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
  });
});

app.get("/version", (_req, res) => {
  res.json({
    version: APP_VERSION,
    environment: NODE_ENV,
  });
});

app.post("/deployments", (req, res) => {
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

  const record = {
    id: randomUUID(),
    service: service.trim(),
    version: version.trim(),
    environment: environment.trim(),
    recordedAt: new Date().toISOString(),
  };
  deployments.push(record);
  res.status(201).json(record);
});

app.get("/deployments", (_req, res) => {
  res.json([...deployments]);
});

app.listen(PORT, () => {
  console.log(`devops-tracker listening on port ${PORT} (${NODE_ENV})`);
});
