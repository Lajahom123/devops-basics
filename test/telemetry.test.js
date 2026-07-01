const { test, mock } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const os = require("os");
const path = require("path");
const {
  initApplicationInsights,
} = require("../src/telemetry/applicationInsights");

test("initApplicationInsights warns and returns when file does not exist", () => {
  const warnings = [];
  const originalWarn = console.warn;
  console.warn = (...args) => warnings.push(args.join(" "));

  try {
    initApplicationInsights("/nonexistent/path/connection-string");
    assert.ok(
      warnings.some((w) => w.includes("not found")),
      "expected a 'not found' warning"
    );
  } finally {
    console.warn = originalWarn;
  }
});

test("initApplicationInsights warns and returns when file is empty", () => {
  const tmpFile = path.join(os.tmpdir(), `ai-test-empty-${Date.now()}`);
  fs.writeFileSync(tmpFile, "   \n");

  const warnings = [];
  const originalWarn = console.warn;
  console.warn = (...args) => warnings.push(args.join(" "));

  try {
    initApplicationInsights(tmpFile);
    assert.ok(
      warnings.some((w) => w.includes("empty")),
      "expected an 'empty' warning"
    );
  } finally {
    console.warn = originalWarn;
    fs.unlinkSync(tmpFile);
  }
});

test("initApplicationInsights does not throw when initialization fails", () => {
  const tmpFile = path.join(os.tmpdir(), `ai-test-invalid-${Date.now()}`);
  fs.writeFileSync(tmpFile, "InstrumentationKey=not-a-real-key");

  const warnings = [];
  const originalWarn = console.warn;
  console.warn = (...args) => warnings.push(args.join(" "));

  try {
    assert.doesNotThrow(() => initApplicationInsights(tmpFile));
  } finally {
    console.warn = originalWarn;
    fs.unlinkSync(tmpFile);
  }
});
