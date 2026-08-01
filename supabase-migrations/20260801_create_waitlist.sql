-- App Store launch waitlist — insert-only for the public anon key.
-- Applied to project smogomdqivzomyggxlur on 2026-08-01.
create table if not exists public.waitlist (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  source text default 'website',
  created_at timestamptz not null default now()
);
create unique index if not exists waitlist_email_unique on public.waitlist (lower(email));
alter table public.waitlist enable row level security;
drop policy if exists "waitlist anon insert" on public.waitlist;
create policy "waitlist anon insert"
  on public.waitlist for insert to anon, authenticated
  with check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' and length(email) <= 254);
grant insert on public.waitlist to anon, authenticated;
