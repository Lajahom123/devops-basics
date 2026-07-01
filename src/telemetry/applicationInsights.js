const fs = require("fs");

const DEFAULT_CONNECTION_STRING_PATH =
  "/mnt/secrets-store/applicationinsights-connection-string";

function initApplicationInsights(
  connectionStringPath = DEFAULT_CONNECTION_STRING_PATH
) {
  try {
    if (!fs.existsSync(connectionStringPath)) {
      console.warn(
        "Application Insights connection string file not found. Telemetry disabled."
      );
      return;
    }

    const connectionString = fs
      .readFileSync(connectionStringPath, "utf8")
      .trim();

    if (!connectionString) {
      console.warn(
        "Application Insights connection string file is empty. Telemetry disabled."
      );
      return;
    }

    const appInsights = require("applicationinsights");

    appInsights
      .setup(connectionString)
      .setAutoCollectRequests(true)
      .setAutoCollectPerformance(true, true)
      .setAutoCollectExceptions(true)
      .setAutoCollectDependencies(true)
      .setAutoCollectConsole(true)
      .start();

    console.log("Application Insights telemetry initialized.");
  } catch (error) {
    console.warn(
      "Application Insights telemetry initialization failed. Continuing without telemetry."
    );
  }
}

module.exports = { initApplicationInsights };
