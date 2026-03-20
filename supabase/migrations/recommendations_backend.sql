-- 1. Create the Recommendations Table safely
-- Using 'kindora_' prefix so it never clashes with others
CREATE TABLE IF NOT EXISTS public.kindora_recommendations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,          -- e.g., 'Sustainability', 'Local Needs'
    impact_score INT4 DEFAULT 95,
    match_reason TEXT,      -- e.g., 'Matches your interest in Sustainability'
    icon_name TEXT          -- e.g., 'water_drop', 'restaurant'
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.kindora_recommendations ENABLE ROW LEVEL SECURITY;

-- 3. Create Security Policy safely
-- This prevents "Policy already exists" errors during a merge
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'kindora_recommendations'
        AND policyname = 'Allow public read access'
    ) THEN
        CREATE POLICY "Allow public read access"
        ON public.kindora_recommendations FOR SELECT
        TO public
        USING (true);
    END IF;
END $$;

-- 4. Enable Realtime safely
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime'
        AND tablename = 'kindora_recommendations'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.kindora_recommendations;
    END IF;
END $$;