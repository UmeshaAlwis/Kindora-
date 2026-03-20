-- Volunteer join table for campaigns.
-- Volunteers can join campaigns that require volunteer support.
CREATE TABLE IF NOT EXISTS campaign_volunteers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (campaign_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_campaign_volunteers_campaign_id
  ON campaign_volunteers (campaign_id);

CREATE INDEX IF NOT EXISTS idx_campaign_volunteers_user_id
  ON campaign_volunteers (user_id);

