// ─── Database Setup (SQLite) ───────────────────────────────────────────
const Database = require("better-sqlite3");
const path = require("path");

const DB_PATH = path.join(__dirname, "hopesync.db");
const db = new Database(DB_PATH);

// Enable WAL mode for better concurrency
db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

// ─── Schema ────────────────────────────────────────────────────────────
db.exec(`
  CREATE TABLE IF NOT EXISTS campaigns (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    description TEXT,
    goal_amount REAL    DEFAULT 0,
    raised      REAL    DEFAULT 0,
    status      TEXT    DEFAULT 'pending',   -- pending | approved | rejected
    created_at  TEXT    DEFAULT (datetime('now')),
    updated_at  TEXT    DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS beneficiaries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    email       TEXT,
    phone       TEXT,
    description TEXT,
    campaign_id INTEGER,
    status      TEXT    DEFAULT 'pending',   -- pending | approved | rejected
    created_at  TEXT    DEFAULT (datetime('now')),
    updated_at  TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id)
  );

  CREATE TABLE IF NOT EXISTS donations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    donor_name      TEXT    NOT NULL,
    donor_email     TEXT,
    amount          REAL    NOT NULL,
    campaign_id     INTEGER,
    payment_status  TEXT    DEFAULT 'completed',  -- completed | pending | failed
    created_at      TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id)
  );

  CREATE TABLE IF NOT EXISTS merchandise (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    description TEXT,
    price       REAL    NOT NULL,
    stock       INTEGER DEFAULT 0,
    image_url   TEXT,
    created_at  TEXT    DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS orders (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name   TEXT    NOT NULL,
    customer_email  TEXT,
    merchandise_id  INTEGER,
    quantity        INTEGER DEFAULT 1,
    total_price     REAL,
    status          TEXT    DEFAULT 'pending', -- pending | shipped | delivered | cancelled
    created_at      TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (merchandise_id) REFERENCES merchandise(id)
  );

  CREATE TABLE IF NOT EXISTS notifications (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT    NOT NULL,
    message     TEXT    NOT NULL,
    type        TEXT    DEFAULT 'info',  -- info | alert | success | warning
    recipients  TEXT,
    sent        INTEGER DEFAULT 0,
    created_at  TEXT    DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS messages (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_name TEXT    NOT NULL,
    sender_email TEXT,
    subject     TEXT    NOT NULL,
    body        TEXT    NOT NULL,
    status      TEXT    DEFAULT 'pending',  -- pending | read | replied | archived
    priority    TEXT    DEFAULT 'normal',   -- low | normal | high | urgent
    created_at  TEXT    DEFAULT (datetime('now'))
  );
`);

module.exports = db;
