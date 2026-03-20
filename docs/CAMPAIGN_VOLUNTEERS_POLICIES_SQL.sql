-- RLS policies for campaign_volunteers (volunteer joins)
ALTER TABLE campaign_volunteers ENABLE ROW LEVEL SECURITY;

-- Volunteers can view their own joined rows
CREATE POLICY "campaign_volunteers_view_own" ON campaign_volunteers
FOR SELECT USING (auth.uid() = user_id);

-- Volunteers can insert their own join row
CREATE POLICY "campaign_volunteers_insert_own" ON campaign_volunteers
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Volunteers can delete their own join row
CREATE POLICY "campaign_volunteers_delete_own" ON campaign_volunteers
FOR DELETE USING (auth.uid() = user_id);

