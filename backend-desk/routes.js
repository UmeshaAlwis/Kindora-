// ─── API Routes ────────────────────────────────────────────────────────
const express = require("express");
const router = express.Router();
const db = require("./database");
const {
  sendBeneficiaryApprovalEmail,
  sendCampaignStatusEmail,
  sendCustomNotification,
} = require("./emailService");

// ════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════════
router.get("/dashboard", (req, res) => {
  const totalDonations =
    db.prepare("SELECT COALESCE(SUM(amount),0) as total FROM donations").get()
      .total;
  const activeCampaigns =
    db.prepare("SELECT COUNT(*) as count FROM campaigns WHERE status='approved'").get()
      .count;
  const pendingApprovals =
    db.prepare(
      "SELECT (SELECT COUNT(*) FROM campaigns WHERE status='pending') + (SELECT COUNT(*) FROM beneficiaries WHERE status='pending') as count"
    ).get().count;
  const totalBeneficiaries =
    db.prepare("SELECT COUNT(*) as count FROM beneficiaries").get().count;
  const totalOrders =
    db.prepare("SELECT COUNT(*) as count FROM orders").get().count;
  const pendingOrders =
    db.prepare("SELECT COUNT(*) as count FROM orders WHERE status='pending'").get()
      .count;
  const pendingMessages =
    db.prepare("SELECT COUNT(*) as count FROM messages WHERE status='pending'").get()
      .count;
  const merchandiseOrders =
    db.prepare("SELECT COUNT(*) as count FROM orders").get().count;

  // Recent donations (last 5)
  const recentDonations = db
    .prepare(
      `SELECT d.*, c.name as campaign_name 
       FROM donations d 
       LEFT JOIN campaigns c ON d.campaign_id = c.id 
       ORDER BY d.created_at DESC LIMIT 5`
    )
    .all();

  // Monthly donation trend (last 6 months)
  const monthlyTrend = db
    .prepare(
      `SELECT strftime('%Y-%m', created_at) as month, SUM(amount) as total
       FROM donations
       WHERE created_at >= date('now', '-6 months')
       GROUP BY month
       ORDER BY month`
    )
    .all();

  res.json({
    totalDonations,
    activeCampaigns,
    pendingApprovals,
    totalBeneficiaries,
    totalOrders,
    pendingOrders,
    pendingMessages,
    merchandiseOrders,
    recentDonations,
    monthlyTrend,
  });
});

// ════════════════════════════════════════════════════════════════════════
// CAMPAIGNS
// ════════════════════════════════════════════════════════════════════════
router.get("/campaigns", (req, res) => {
  const { status } = req.query;
  let campaigns;
  if (status) {
    campaigns = db
      .prepare("SELECT * FROM campaigns WHERE status = ? ORDER BY created_at DESC")
      .all(status);
  } else {
    campaigns = db.prepare("SELECT * FROM campaigns ORDER BY created_at DESC").all();
  }
  res.json(campaigns);
});

router.get("/campaigns/:id", (req, res) => {
  const campaign = db.prepare("SELECT * FROM campaigns WHERE id = ?").get(req.params.id);
  if (!campaign) return res.status(404).json({ error: "Campaign not found" });
  res.json(campaign);
});

router.post("/campaigns", (req, res) => {
  const { name, description, goal_amount } = req.body;
  const result = db
    .prepare("INSERT INTO campaigns (name, description, goal_amount) VALUES (?, ?, ?)")
    .run(name, description, goal_amount || 0);
  res.status(201).json({ id: result.lastInsertRowid, name, description, goal_amount });
});

router.put("/campaigns/:id/approve", async (req, res) => {
  const { approved } = req.body; // true or false
  const status = approved ? "approved" : "rejected";
  db.prepare("UPDATE campaigns SET status = ?, updated_at = datetime('now') WHERE id = ?").run(
    status,
    req.params.id
  );
  const campaign = db.prepare("SELECT * FROM campaigns WHERE id = ?").get(req.params.id);
  // Send email notification
  await sendCampaignStatusEmail(campaign, approved);
  res.json(campaign);
});

router.delete("/campaigns/:id", (req, res) => {
  db.prepare("DELETE FROM campaigns WHERE id = ?").run(req.params.id);
  res.json({ message: "Campaign deleted" });
});

// ════════════════════════════════════════════════════════════════════════
// BENEFICIARIES
// ════════════════════════════════════════════════════════════════════════
router.get("/beneficiaries", (req, res) => {
  const { status } = req.query;
  let sql = `SELECT b.*, c.name as campaign_name 
             FROM beneficiaries b 
             LEFT JOIN campaigns c ON b.campaign_id = c.id`;
  const params = [];
  if (status) {
    sql += " WHERE b.status = ?";
    params.push(status);
  }
  sql += " ORDER BY b.created_at DESC";
  const beneficiaries = db.prepare(sql).all(...params);
  res.json(beneficiaries);
});

router.post("/beneficiaries", (req, res) => {
  const { name, email, phone, description, campaign_id } = req.body;
  const result = db
    .prepare(
      "INSERT INTO beneficiaries (name, email, phone, description, campaign_id) VALUES (?, ?, ?, ?, ?)"
    )
    .run(name, email, phone, description, campaign_id);
  res.status(201).json({ id: result.lastInsertRowid });
});

router.put("/beneficiaries/:id/approve", async (req, res) => {
  const { approved } = req.body;
  const status = approved ? "approved" : "rejected";
  db.prepare(
    "UPDATE beneficiaries SET status = ?, updated_at = datetime('now') WHERE id = ?"
  ).run(status, req.params.id);
  const beneficiary = db
    .prepare(
      `SELECT b.*, c.name as campaign_name 
       FROM beneficiaries b 
       LEFT JOIN campaigns c ON b.campaign_id = c.id 
       WHERE b.id = ?`
    )
    .get(req.params.id);
  // Send email
  if (beneficiary.email) {
    await sendBeneficiaryApprovalEmail(beneficiary, approved);
  }
  res.json(beneficiary);
});

// ════════════════════════════════════════════════════════════════════════
// DONATIONS
// ════════════════════════════════════════════════════════════════════════
router.get("/donations", (req, res) => {
  const donations = db
    .prepare(
      `SELECT d.*, c.name as campaign_name 
       FROM donations d 
       LEFT JOIN campaigns c ON d.campaign_id = c.id 
       ORDER BY d.created_at DESC`
    )
    .all();
  res.json(donations);
});

router.post("/donations", (req, res) => {
  const { donor_name, donor_email, amount, campaign_id, payment_status } = req.body;
  const result = db
    .prepare(
      "INSERT INTO donations (donor_name, donor_email, amount, campaign_id, payment_status) VALUES (?, ?, ?, ?, ?)"
    )
    .run(donor_name, donor_email, amount, campaign_id, payment_status || "completed");
  // Update campaign raised amount
  if (campaign_id) {
    db.prepare("UPDATE campaigns SET raised = raised + ? WHERE id = ?").run(
      amount,
      campaign_id
    );
  }
  res.status(201).json({ id: result.lastInsertRowid });
});

// ════════════════════════════════════════════════════════════════════════
// MERCHANDISE
// ════════════════════════════════════════════════════════════════════════
router.get("/merchandise", (req, res) => {
  const items = db.prepare("SELECT * FROM merchandise ORDER BY created_at DESC").all();
  res.json(items);
});

router.post("/merchandise", (req, res) => {
  const { name, description, price, stock, image_url } = req.body;
  const result = db
    .prepare(
      "INSERT INTO merchandise (name, description, price, stock, image_url) VALUES (?, ?, ?, ?, ?)"
    )
    .run(name, description, price, stock || 0, image_url);
  res.status(201).json({ id: result.lastInsertRowid });
});

router.put("/merchandise/:id", (req, res) => {
  const { name, description, price, stock, image_url } = req.body;
  db.prepare(
    "UPDATE merchandise SET name=?, description=?, price=?, stock=?, image_url=? WHERE id=?"
  ).run(name, description, price, stock, image_url, req.params.id);
  const item = db.prepare("SELECT * FROM merchandise WHERE id = ?").get(req.params.id);
  res.json(item);
});

router.delete("/merchandise/:id", (req, res) => {
  db.prepare("DELETE FROM merchandise WHERE id = ?").run(req.params.id);
  res.json({ message: "Item deleted" });
});

// ════════════════════════════════════════════════════════════════════════
// ORDERS
// ════════════════════════════════════════════════════════════════════════
router.get("/orders", (req, res) => {
  const orders = db
    .prepare(
      `SELECT o.*, m.name as merchandise_name 
       FROM orders o 
       LEFT JOIN merchandise m ON o.merchandise_id = m.id 
       ORDER BY o.created_at DESC`
    )
    .all();
  res.json(orders);
});

router.post("/orders", (req, res) => {
  const { customer_name, customer_email, merchandise_id, quantity } = req.body;
  const item = db.prepare("SELECT * FROM merchandise WHERE id = ?").get(merchandise_id);
  if (!item) return res.status(404).json({ error: "Merchandise not found" });
  if (item.stock < quantity)
    return res.status(400).json({ error: "Insufficient stock" });

  const total_price = item.price * quantity;
  const result = db
    .prepare(
      "INSERT INTO orders (customer_name, customer_email, merchandise_id, quantity, total_price) VALUES (?, ?, ?, ?, ?)"
    )
    .run(customer_name, customer_email, merchandise_id, quantity, total_price);
  // Reduce stock
  db.prepare("UPDATE merchandise SET stock = stock - ? WHERE id = ?").run(
    quantity,
    merchandise_id
  );
  res.status(201).json({ id: result.lastInsertRowid, total_price });
});

router.put("/orders/:id/status", (req, res) => {
  const { status } = req.body;
  db.prepare("UPDATE orders SET status = ? WHERE id = ?").run(status, req.params.id);
  const order = db
    .prepare(
      `SELECT o.*, m.name as merchandise_name 
       FROM orders o 
       LEFT JOIN merchandise m ON o.merchandise_id = m.id 
       WHERE o.id = ?`
    )
    .get(req.params.id);
  res.json(order);
});

// ════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ════════════════════════════════════════════════════════════════════════
router.get("/notifications", (req, res) => {
  const notifications = db
    .prepare("SELECT * FROM notifications ORDER BY created_at DESC")
    .all();
  res.json(notifications);
});

router.post("/notifications", async (req, res) => {
  const { title, message, type, recipients } = req.body;
  const result = db
    .prepare(
      "INSERT INTO notifications (title, message, type, recipients) VALUES (?, ?, ?, ?)"
    )
    .run(title, message, type || "info", recipients || "");

  // Attempt to send emails
  let emailResults = [];
  if (recipients) {
    emailResults = await sendCustomNotification({ title, message, recipients });
    db.prepare("UPDATE notifications SET sent = 1 WHERE id = ?").run(
      result.lastInsertRowid
    );
  }

  res.status(201).json({
    id: result.lastInsertRowid,
    emailResults,
  });
});

// ════════════════════════════════════════════════════════════════════════
// MESSAGES
// ════════════════════════════════════════════════════════════════════════
router.get("/messages", (req, res) => {
  const { status } = req.query;
  let messages;
  if (status) {
    messages = db
      .prepare("SELECT * FROM messages WHERE status = ? ORDER BY created_at DESC")
      .all(status);
  } else {
    messages = db.prepare("SELECT * FROM messages ORDER BY created_at DESC").all();
  }
  res.json(messages);
});

router.get("/messages/:id", (req, res) => {
  const message = db.prepare("SELECT * FROM messages WHERE id = ?").get(req.params.id);
  if (!message) return res.status(404).json({ error: "Message not found" });
  res.json(message);
});

router.post("/messages", (req, res) => {
  const { sender_name, sender_email, subject, body, priority } = req.body;
  const result = db
    .prepare(
      "INSERT INTO messages (sender_name, sender_email, subject, body, priority) VALUES (?, ?, ?, ?, ?)"
    )
    .run(sender_name, sender_email, subject, body, priority || "normal");
  res.status(201).json({ id: result.lastInsertRowid });
});

router.put("/messages/:id/status", (req, res) => {
  const { status } = req.body;
  db.prepare("UPDATE messages SET status = ? WHERE id = ?").run(status, req.params.id);
  const message = db.prepare("SELECT * FROM messages WHERE id = ?").get(req.params.id);
  res.json(message);
});

router.delete("/messages/:id", (req, res) => {
  db.prepare("DELETE FROM messages WHERE id = ?").run(req.params.id);
  res.json({ message: "Message deleted" });
});

module.exports = router;
