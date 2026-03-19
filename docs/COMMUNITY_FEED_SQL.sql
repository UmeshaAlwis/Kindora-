-- Kindora Community Feed schema
-- Run in Supabase SQL editor

create table if not exists public.feed_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  content text default '',
  media_url text,
  media_type text not null default 'none' check (media_type in ('none', 'image', 'video')),
  likes_count integer not null default 0,
  comments_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_feed_posts_created_at on public.feed_posts(created_at desc);
create index if not exists idx_feed_posts_user_id on public.feed_posts(user_id);

create table if not exists public.feed_post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.feed_posts(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

create index if not exists idx_feed_post_likes_post_id on public.feed_post_likes(post_id);
create index if not exists idx_feed_post_likes_user_id on public.feed_post_likes(user_id);

-- Optional helper trigger to keep updated_at fresh
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_feed_posts_updated_at on public.feed_posts;
create trigger trg_feed_posts_updated_at
before update on public.feed_posts
for each row execute procedure public.set_updated_at();

-- Recommended RLS policies if you access these tables from client directly.
-- Not required for current backend-service-role API approach.
