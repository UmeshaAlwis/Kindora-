// ─── Express Server Entry Point ────────────────────────────────────────
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const routes = require("./routes");

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

// API routes
app.use("/api", routes);

// Health check
app.get("/", (req, res) => {
  res.json({
    message: "HopeSync Admin API is running",
    version: "1.0.0",
    endpoints: [
      "GET  /api/dashboard",
      "GET  /api/campaigns",
      "POST /api/campaigns",
      "PUT  /api/campaigns/:id/approve",
      "GET  /api/beneficiaries",
      "POST /api/beneficiaries",
      "PUT  /api/beneficiaries/:id/approve",
      "GET  /api/donations",
      "POST /api/donations",
      "GET  /api/merchandise",
      "POST /api/merchandise",
      "PUT  /api/merchandise/:id",
      "GET  /api/orders",
      "POST /api/orders",
      "PUT  /api/orders/:id/status",
      "GET  /api/notifications",
      "POST /api/notifications",
    ],
  });
});

app.listen(PORT, () => {
  console.log(`🚀 HopeSync Admin API running on http://localhost:${PORT}`);
});
