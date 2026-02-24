// ─── Email / Notification Service ──────────────────────────────────────
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT) || 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
  },
});

/**
 * Send an email notification.
 * Falls back gracefully if SMTP is not configured.
 */
async function sendEmail({ to, subject, html }) {
  // If SMTP is not configured, log and skip
  if (!process.env.SMTP_USER || process.env.SMTP_USER === "your-email@gmail.com") {
    console.log(`[EmailService] SMTP not configured – skipping email to ${to}`);
    console.log(`  Subject: ${subject}`);
    return { skipped: true };
  }

  try {
    const info = await transporter.sendMail({
      from: process.env.SMTP_FROM || "noreply@hopesync.org",
      to,
      subject,
      html,
    });
    console.log(`[EmailService] Sent to ${to}: ${info.messageId}`);
    return { success: true, messageId: info.messageId };
  } catch (err) {
    console.error(`[EmailService] Failed to send to ${to}:`, err.message);
    return { success: false, error: err.message };
  }
}

/**
 * Send approval notification for a beneficiary.
 */
async function sendBeneficiaryApprovalEmail(beneficiary, approved) {
  const status = approved ? "approved" : "rejected";
  return sendEmail({
    to: beneficiary.email,
    subject: `HopeSync – Your application has been ${status}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:auto">
        <div style="background:#0c0c79;padding:20px;text-align:center">
          <h1 style="color:#fff;margin:0">HopeSync</h1>
        </div>
        <div style="padding:30px;background:#f9f9f9">
          <h2>Hello ${beneficiary.name},</h2>
          <p>Your beneficiary application has been <strong style="color:${approved ? "#4caf50" : "#f44336"}">${status}</strong>.</p>
          ${approved ? "<p>You will now start receiving support through our platform.</p>" : "<p>If you believe this was in error, please contact us.</p>"}
        </div>
        <div style="background:#ff751f;padding:10px;text-align:center">
          <small style="color:#fff">© 2026 HopeSync Charity Platform</small>
        </div>
      </div>
    `,
  });
}

/**
 * Send campaign status update email.
 */
async function sendCampaignStatusEmail(campaign, approved) {
  const status = approved ? "approved" : "rejected";
  return sendEmail({
    to: "admin@hopesync.org",
    subject: `HopeSync – Campaign "${campaign.name}" has been ${status}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:auto">
        <div style="background:#0c0c79;padding:20px;text-align:center">
          <h1 style="color:#fff;margin:0">HopeSync</h1>
        </div>
        <div style="padding:30px;background:#f9f9f9">
          <h2>Campaign Update</h2>
          <p>The campaign <strong>"${campaign.name}"</strong> has been <strong style="color:${approved ? "#4caf50" : "#f44336"}">${status}</strong>.</p>
          <p>Goal: $${campaign.goal_amount?.toLocaleString()}</p>
        </div>
        <div style="background:#ff751f;padding:10px;text-align:center">
          <small style="color:#fff">© 2026 HopeSync Charity Platform</small>
        </div>
      </div>
    `,
  });
}

/**
 * Send a custom notification email.
 */
async function sendCustomNotification({ title, message, recipients }) {
  const recipientList = recipients
    ? recipients.split(",").map((r) => r.trim())
    : [];

  const results = [];
  for (const to of recipientList) {
    const result = await sendEmail({
      to,
      subject: `HopeSync – ${title}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:auto">
          <div style="background:#0c0c79;padding:20px;text-align:center">
            <h1 style="color:#fff;margin:0">HopeSync</h1>
          </div>
          <div style="padding:30px;background:#f9f9f9">
            <h2>${title}</h2>
            <p>${message}</p>
          </div>
          <div style="background:#ff751f;padding:10px;text-align:center">
            <small style="color:#fff">© 2026 HopeSync Charity Platform</small>
          </div>
        </div>
      `,
    });
    results.push({ to, ...result });
  }
  return results;
}

module.exports = {
  sendEmail,
  sendBeneficiaryApprovalEmail,
  sendCampaignStatusEmail,
  sendCustomNotification,
};
