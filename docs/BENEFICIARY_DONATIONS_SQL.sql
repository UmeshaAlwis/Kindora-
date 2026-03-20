-- Adds beneficiary campaign support to the `donations` table.
-- Required for beneficiary donations (including wallet payments).

-- 1) Add column if missing
ALTER TABLE donations
ADD COLUMN IF NOT EXISTS beneficiary_campaign_id UUID;

-- 2) Add foreign key constraint if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_donations_beneficiary_campaign_id'
  ) THEN
    ALTER TABLE donations
    ADD CONSTRAINT fk_donations_beneficiary_campaign_id
    FOREIGN KEY (beneficiary_campaign_id)
    REFERENCES beneficiary_campaigns(id)
    ON DELETE SET NULL;
  END IF;
END $$;

-- 3) Performance index
CREATE INDEX IF NOT EXISTS idx_donations_beneficiary_campaign_id
ON donations(beneficiary_campaign_id);

