-- Use existing merchandise table for admin product management.
-- Run this to ensure expected columns/defaults exist.
ALTER TABLE public.merchandise
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS stock_quantity INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_merchandise_category ON public.merchandise (category);
CREATE INDEX IF NOT EXISTS idx_merchandise_active ON public.merchandise (is_active);

