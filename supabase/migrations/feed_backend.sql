-- SAFE ADDITION: Only creates the table if it doesn't exist.
-- Does NOT change or delete any other tables.
CREATE TABLE IF NOT EXISTS public.kindora_news_updates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT,
    description TEXT,
    status TEXT DEFAULT 'ongoing'
);

-- SAFE REALTIME: Checks if already enabled before trying to add it.
-- This prevents "Duplicate Table" errors during the leader's merge.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'kindora_news_updates'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.kindora_news_updates;
    END IF;
END $$;

-- SAFE REPLICA: Ensures full data is sent for deletes without breaking other tables.
ALTER TABLE public.kindora_news_updates REPLICA IDENTITY FULL;

-- SAFE RLS: Only enables security for specific table.
ALTER TABLE public.kindora_news_updates ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'kindora_news_updates'
        AND policyname = 'Allow public read access'
    ) THEN
        CREATE POLICY "Allow public read access"
        ON public.kindora_news_updates FOR SELECT
        TO public
        USING (true);
    END IF;
END $$;