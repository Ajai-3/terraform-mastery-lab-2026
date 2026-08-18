import express from "express";
import path from "node:path";
import os from "node:os";
import { fileURLToPath } from "node:url";

const app = express();
const PORT = Number(process.env.PORT) || 3000;

const VERSION = process.env.APP_VERSION || "1.0";
const ENVIRONMENT = process.env.APP_ENVIRONMENT || "blue";
const STATUS = process.env.APP_STATUS || "production";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    version: VERSION,
    environment: ENVIRONMENT,
    timestamp: new Date().toISOString(),
  });
});

// Main page
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

// Application information
app.get("/api/info", (req, res) => {
  res.json({
    version: VERSION,
    environment: ENVIRONMENT,
    status: STATUS,
    timestamp: new Date().toISOString(),
    hostname: os.hostname(),
    platform: process.platform,
    nodeVersion: process.version,
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(
    `Application v${VERSION} (${ENVIRONMENT}) running on port ${PORT}`,
  );
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received. Closing server...");

  server.close(() => {
    console.log("Blue server closed.");
  });
});
