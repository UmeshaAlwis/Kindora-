-- 1. Create the News Feed Table with UUIDs
CREATE TABLE IF NOT EXISTS public.kindora_news_updates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT,
    description TEXT,
    status TEXT DEFAULT 'ongoing'
);

-- 2. Enable REPLICA IDENTITY FULL
-- This ensures that when a row is deleted or updated, the full data is sent to Flutter.
-- This prevents "null" errors in your stream [Ref: image_d42ee8.png].
ALTER TABLE public.kindora_news_updates REPLICA IDENTITY FULL;

-- 3. Enable Realtime for the Feed
-- This allows the UI to update instantly without refreshing [Ref: image_d4a781.png].
ALTER PUBLICATION supabase_realtime ADD TABLE public.kindora_news_updates;

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.kindora_news_updates ENABLE ROW LEVEL SECURITY;

-- 5. Create Security Policies
-- Policy: Allow anyone (even non-logged-in users) to view the news.
CREATE POLICY "Allow public read access"
ON public.kindora_news_updates FOR SELECT
TO public
USING (true);

-- Policy: Allow authenticated users to insert/delete (Optional: adjust as needed)
CREATE POLICY "Allow authenticated inserts"
ON public.kindora_news_updates FOR INSERT
TO authenticated
WITH CHECK (true);