-- Adds volunteer requirement flag for donor campaigns.
-- Used by Start Campaign form checkbox.
ALTER TABLE campaigns
ADD COLUMN IF NOT EXISTS needs_volunteers BOOLEAN NOT NULL DEFAULT FALSE;

