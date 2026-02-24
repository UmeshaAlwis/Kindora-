// ─── Seed script – populates the database with sample data ─────────────
require("dotenv").config();
const db = require("./database");

console.log("Seeding database...");

// Clear existing data
db.exec(`
  DELETE FROM notifications;
  DELETE FROM messages;
  DELETE FROM orders;
  DELETE FROM donations;
  DELETE FROM beneficiaries;
  DELETE FROM merchandise;
  DELETE FROM campaigns;
`);

// ── Campaigns ──
const campaigns = [
  { name: "Clean Water for All", description: "Providing clean drinking water to rural communities in East Africa", goal: 50000, raised: 32500, status: "approved" },
  { name: "Education Fund 2026", description: "Scholarships for underprivileged students to access quality education", goal: 100000, raised: 67000, status: "approved" },
  { name: "Disaster Relief Fund", description: "Emergency supplies and shelter for natural disaster victims", goal: 75000, raised: 45200, status: "approved" },
  { name: "Healthcare for Children", description: "Medical camps and free treatments for children in underserved areas", goal: 60000, raised: 12000, status: "pending" },
  { name: "Animal Shelter Support", description: "Building new shelters and providing food for stray animals", goal: 30000, raised: 8500, status: "pending" },
  { name: "Tech for Youth", description: "Providing laptops and coding bootcamps for youth in developing countries", goal: 40000, raised: 0, status: "pending" },
];

const insertCampaign = db.prepare(
  "INSERT INTO campaigns (name, description, goal_amount, raised, status, created_at) VALUES (?, ?, ?, ?, ?, datetime('now', ?))"
);

const campaignIds = [];
campaigns.forEach((c, i) => {
  const result = insertCampaign.run(c.name, c.description, c.goal, c.raised, c.status, `-${(campaigns.length - i) * 5} days`);
  campaignIds.push(result.lastInsertRowid);
});

// ── Beneficiaries ──
const beneficiaries = [
  { name: "Amara Osei", email: "amara@example.com", phone: "+254712345678", desc: "Single mother of three, needs water access", campaign: 0, status: "approved" },
  { name: "Raj Patel", email: "raj@example.com", phone: "+919876543210", desc: "Bright student unable to afford college tuition", campaign: 1, status: "approved" },
  { name: "Maria Santos", email: "maria@example.com", phone: "+639171234567", desc: "Family displaced by typhoon, needs shelter", campaign: 2, status: "approved" },
  { name: "Yuki Tanaka", email: "yuki@example.com", phone: "+819012345678", desc: "Child needing heart surgery", campaign: 3, status: "pending" },
  { name: "Fatima Al-Rashid", email: "fatima@example.com", phone: "+971501234567", desc: "Orphan seeking educational sponsorship", campaign: 1, status: "pending" },
  { name: "James Mwangi", email: "james@example.com", phone: "+254723456789", desc: "Elderly man needing medical support", campaign: 3, status: "pending" },
  { name: "Sophie Chen", email: "sophie@example.com", phone: "+861351234567", desc: "Young coder from underserved community", campaign: 5, status: "pending" },
];

const insertBeneficiary = db.prepare(
  "INSERT INTO beneficiaries (name, email, phone, description, campaign_id, status, created_at) VALUES (?, ?, ?, ?, ?, ?, datetime('now', ?))"
);

beneficiaries.forEach((b, i) => {
  insertBeneficiary.run(b.name, b.email, b.phone, b.desc, campaignIds[b.campaign], b.status, `-${(beneficiaries.length - i) * 3} days`);
});

// ── Donations ──
const donors = [
  { name: "John Smith", email: "john@example.com" },
  { name: "Sarah Williams", email: "sarah@example.com" },
  { name: "Michael Brown", email: "michael@example.com" },
  { name: "Emily Davis", email: "emily@example.com" },
  { name: "David Wilson", email: "david@example.com" },
  { name: "Jessica Taylor", email: "jessica@example.com" },
  { name: "Robert Anderson", email: "robert@example.com" },
  { name: "Lauren Martinez", email: "lauren@example.com" },
  { name: "Chris Johnson", email: "chris@example.com" },
  { name: "Amanda White", email: "amanda@example.com" },
];

const insertDonation = db.prepare(
  "INSERT INTO donations (donor_name, donor_email, amount, campaign_id, payment_status, created_at) VALUES (?, ?, ?, ?, ?, datetime('now', ?))"
);

const amounts = [500, 1000, 250, 5000, 100, 2500, 750, 3000, 150, 10000, 200, 600, 1500, 50, 800];
const statuses = ["completed", "completed", "completed", "completed", "pending", "completed", "completed", "failed", "completed", "completed"];

for (let i = 0; i < 20; i++) {
  const donor = donors[i % donors.length];
  const cIdx = i % 3; // spread across first 3 approved campaigns
  insertDonation.run(
    donor.name,
    donor.email,
    amounts[i % amounts.length],
    campaignIds[cIdx],
    statuses[i % statuses.length],
    `-${20 - i} days`
  );
}

// ── Merchandise ──
const merchandise = [
  { name: "HopeSync T-Shirt", desc: "Premium cotton T-shirt with HopeSync logo", price: 25.00, stock: 150, img: "https://placehold.co/200x200/0c0c79/fff?text=T-Shirt" },
  { name: "Charity Wristband", desc: "Silicone wristband – proceeds go to clean water campaign", price: 5.00, stock: 500, img: "https://placehold.co/200x200/ff751f/fff?text=Wristband" },
  { name: "Tote Bag", desc: "Eco-friendly tote bag with inspirational quote", price: 15.00, stock: 200, img: "https://placehold.co/200x200/0c0c79/fff?text=Tote+Bag" },
  { name: "Coffee Mug", desc: "Ceramic mug – \"Together We Can\" edition", price: 12.00, stock: 100, img: "https://placehold.co/200x200/ff751f/fff?text=Mug" },
  { name: "Hoodie", desc: "Warm hoodie with embroidered HopeSync logo", price: 45.00, stock: 75, img: "https://placehold.co/200x200/0c0c79/fff?text=Hoodie" },
];

const insertMerch = db.prepare(
  "INSERT INTO merchandise (name, description, price, stock, image_url) VALUES (?, ?, ?, ?, ?)"
);

const merchIds = [];
merchandise.forEach((m) => {
  const result = insertMerch.run(m.name, m.desc, m.price, m.stock, m.img);
  merchIds.push(result.lastInsertRowid);
});

// ── Orders ──
const insertOrder = db.prepare(
  "INSERT INTO orders (customer_name, customer_email, merchandise_id, quantity, total_price, status, created_at) VALUES (?, ?, ?, ?, ?, ?, datetime('now', ?))"
);

const orderStatuses = ["pending", "shipped", "delivered", "pending", "shipped"];
for (let i = 0; i < 10; i++) {
  const donor = donors[i % donors.length];
  const merch = merchandise[i % merchIds.length];
  const qty = (i % 3) + 1;
  insertOrder.run(
    donor.name,
    donor.email,
    merchIds[i % merchIds.length],
    qty,
    merch.price * qty,
    orderStatuses[i % orderStatuses.length],
    `-${10 - i} days`
  );
}

// ── Notifications ──
const insertNotif = db.prepare(
  "INSERT INTO notifications (title, message, type, sent, created_at) VALUES (?, ?, ?, ?, datetime('now', ?))"
);

const notifs = [
  { title: "New Campaign Submitted", message: "Healthcare for Children campaign has been submitted for review.", type: "info", sent: 1 },
  { title: "Donation Milestone", message: "Clean Water for All has reached 65% of its goal!", type: "success", sent: 1 },
  { title: "Urgent: Disaster Response", message: "Emergency relief needed – Disaster Relief Fund activated.", type: "alert", sent: 1 },
  { title: "Monthly Report Ready", message: "February 2026 donation report is now available for review.", type: "info", sent: 0 },
  { title: "Low Stock Alert", message: "Charity Wristband stock is running low (< 50 units).", type: "warning", sent: 0 },
];

notifs.forEach((n, i) => {
  insertNotif.run(n.title, n.message, n.type, n.sent, `-${(notifs.length - i) * 2} days`);
});

// ── Messages ──
const insertMessage = db.prepare(
  "INSERT INTO messages (sender_name, sender_email, subject, body, status, priority, created_at) VALUES (?, ?, ?, ?, ?, ?, datetime('now', ?))"
);

const messages = [
  { sender: "Alice Johnson", email: "alice@example.com", subject: "Question about Clean Water campaign", body: "Hi, I would like to know more about how the funds are being distributed for the Clean Water for All campaign. Can you share a breakdown?", status: "pending", priority: "normal" },
  { sender: "Tom Richards", email: "tom@example.com", subject: "Volunteer Opportunity Inquiry", body: "I'm interested in volunteering for HopeSync. What positions are currently available and how can I sign up?", status: "pending", priority: "high" },
  { sender: "Priya Sharma", email: "priya@example.com", subject: "Donation receipt request", body: "I made a donation last week but haven't received my tax receipt yet. Could you resend it please?", status: "read", priority: "normal" },
  { sender: "Carlos Mendez", email: "carlos@example.com", subject: "Partnership Proposal", body: "Our organization would like to partner with HopeSync for an upcoming fundraiser event. Please let me know the best way to proceed.", status: "pending", priority: "high" },
  { sender: "Linda Park", email: "linda@example.com", subject: "Merchandise bulk order", body: "We'd like to place a bulk order of 200 T-shirts and 500 wristbands for our charity run. Is there a bulk discount available?", status: "pending", priority: "urgent" },
  { sender: "James Carter", email: "james@example.com", subject: "Campaign update request", body: "Can you provide an update on the Education Fund 2026 campaign progress? Our donors are asking for details.", status: "replied", priority: "normal" },
  { sender: "Sarah Kim", email: "sarah.k@example.com", subject: "Issue with donation page", body: "I've been trying to donate through the website but keep getting an error on the payment page. Can someone look into this?", status: "pending", priority: "urgent" },
  { sender: "David Mueller", email: "david.m@example.com", subject: "Thank you!", body: "Just wanted to say thank you for the amazing work HopeSync does. Keep it up!", status: "archived", priority: "low" },
  { sender: "Fatima Al-Rashid", email: "fatima@example.com", subject: "Beneficiary application status", body: "Hi, I submitted my beneficiary application two weeks ago but haven't heard back. Could you check the status?", status: "pending", priority: "high" },
  { sender: "Mike O'Brien", email: "mike@example.com", subject: "Sponsorship for tech camp", body: "I'd like to sponsor 5 students for the Tech for Youth coding bootcamp. How do I go about it?", status: "pending", priority: "normal" },
];

messages.forEach((m, i) => {
  insertMessage.run(m.sender, m.email, m.subject, m.body, m.status, m.priority, `-${(messages.length - i) * 1} days`);
});

console.log("✅ Database seeded successfully!");
console.log(`   Campaigns:      ${campaigns.length}`);
console.log(`   Beneficiaries:  ${beneficiaries.length}`);
console.log(`   Donations:      20`);
console.log(`   Merchandise:    ${merchandise.length}`);
console.log(`   Orders:         10`);
console.log(`   Notifications:  ${notifs.length}`);
console.log(`   Messages:       ${messages.length}`);
