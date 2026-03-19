-- Add campaign deadline fields used by "Urgent Donations"
-- Run in Supabase SQL editor. Safe: uses IF NOT EXISTS.

alter table public.campaigns
  add column if not exists start_date timestamptz not null default now();

alter table public.campaigns
  add column if not exists end_date timestamptz;

-- Helpful index for sorting by deadline
create index if not exists idx_campaigns_end_date on public.campaigns(end_date asc);

