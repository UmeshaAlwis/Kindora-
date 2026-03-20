-- Adds support for recurring wallet-based beneficiary donations.
--
-- This does NOT modify the existing `donations` table. Instead, it stores
-- recurrence schedules in `beneficiary_recurring_donations`, and the backend
-- scheduler will create one-time donation installments at runtime.

-- Recurring schedule table
CREATE TABLE IF NOT EXISTS beneficiary_recurring_donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  beneficiary_campaign_id UUID NOT NULL REFERENCES beneficiary_campaigns(id) ON DELETE CASCADE,
  amount DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'LKR',

  -- Scheduling
  recurring_frequency VARCHAR(20) NOT NULL,
  recurring_end_date TIMESTAMPTZ,
  next_payment_at TIMESTAMPTZ NOT NULL,
  occurrences_done INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',

  -- Donor info needed to process future installments
  donor_name VARCHAR(255) NOT NULL,
  donor_email VARCHAR(255) NOT NULL,
  donor_phone VARCHAR(20),

  -- Metadata (optional)
  message TEXT,
  is_anonymous BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_beneficiary_recurring_user_id
  ON beneficiary_recurring_donations(user_id);
CREATE INDEX IF NOT EXISTS idx_beneficiary_recurring_next_payment
  ON beneficiary_recurring_donations(next_payment_at);
CREATE INDEX IF NOT EXISTS idx_beneficiary_recurring_campaign_id
  ON beneficiary_recurring_donations(beneficiary_campaign_id);

-- updated_at trigger
CREATE OR REPLACE FUNCTION update_beneficiary_recurring_donations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW() AT TIME ZONE 'UTC';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_beneficiary_recurring_donations_updated_at
  ON beneficiary_recurring_donations;

CREATE TRIGGER trigger_update_beneficiary_recurring_donations_updated_at
BEFORE UPDATE ON beneficiary_recurring_donations
FOR EACH ROW
EXECUTE FUNCTION update_beneficiary_recurring_donations_updated_at();

