-- This creates a brand new table specifically for  feed
CREATE TABLE kindora_news_updates (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  title text,
  description text,
  status text DEFAULT 'ongoing'
);

-- IMPORTANT: Enable Realtime for ONLY this new table
alter publication supabase_realtime add table kindora_news_updates;