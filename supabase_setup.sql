-- Run this once in Supabase SQL Editor:
-- https://app.supabase.com/project/bwjuxeqzqyeimrqxfamw/sql/new

-- 1. Create the table
create table if not exists public.app_downloads (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  user_agent text,
  referrer text,
  ip_address text,
  created_at timestamptz not null default now()
);

-- Index for quick lookup by email
create index if not exists app_downloads_email_idx on public.app_downloads (email);
create index if not exists app_downloads_created_at_idx on public.app_downloads (created_at desc);

-- 2. Enable Row Level Security
alter table public.app_downloads enable row level security;

-- 3. Allow anyone (anon role) to INSERT only
-- No SELECT/UPDATE/DELETE for anon — only the service role / authenticated admin can read.
drop policy if exists "anon_insert_app_downloads" on public.app_downloads;
create policy "anon_insert_app_downloads"
  on public.app_downloads
  for insert
  to anon
  with check (true);

-- 4. (Optional) allow your authenticated admin user to read the list
-- Replace with a policy matching your admin auth setup, or just query via the service role.
