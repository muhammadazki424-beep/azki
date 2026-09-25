-- CETAKDONG TEAM AZKI
-- SUPABASE SETUP / RESTORE SQL
-- IMPORTANT:
-- File ini untuk membuat struktur tabel + RLS.
-- Tidak menghapus Auth Users, profiles, atau sales_entries.
-- Tidak melakukan TRUNCATE.
-- Jalankan di Supabase > SQL Editor hanya jika memang diperlukan.

create table if not exists public.potential_leads (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  customer_name text,
  value numeric default 0,
  month text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.customer_database (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  customer_name text,
  company text,
  month text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.lost_leads (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  customer_name text,
  value numeric default 0,
  month text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.customer_complaints (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  customer_name text,
  value numeric default 0,
  month text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.po_received (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  customer_name text,
  value numeric default 0,
  month text,
  po_number text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.forecast_targets (
  id uuid primary key default gen_random_uuid(),
  bd_name text,
  target numeric default 0,
  month text,
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.potential_leads enable row level security;
alter table public.customer_database enable row level security;
alter table public.lost_leads enable row level security;
alter table public.customer_complaints enable row level security;
alter table public.po_received enable row level security;
alter table public.forecast_targets enable row level security;

-- Remove old policies with these names if they exist
drop policy if exists "potential_select_all" on public.potential_leads;
drop policy if exists "potential_insert_all" on public.potential_leads;
drop policy if exists "potential_update_all" on public.potential_leads;
drop policy if exists "potential_delete_all" on public.potential_leads;

drop policy if exists "customer_select_all" on public.customer_database;
drop policy if exists "customer_insert_all" on public.customer_database;
drop policy if exists "customer_update_all" on public.customer_database;
drop policy if exists "customer_delete_all" on public.customer_database;

drop policy if exists "lost_select_all" on public.lost_leads;
drop policy if exists "lost_insert_all" on public.lost_leads;
drop policy if exists "lost_update_all" on public.lost_leads;
drop policy if exists "lost_delete_all" on public.lost_leads;

drop policy if exists "complaint_select_all" on public.customer_complaints;
drop policy if exists "complaint_insert_all" on public.customer_complaints;
drop policy if exists "complaint_update_all" on public.customer_complaints;
drop policy if exists "complaint_delete_all" on public.customer_complaints;

drop policy if exists "po_select_all" on public.po_received;
drop policy if exists "po_insert_admin" on public.po_received;
drop policy if exists "po_update_admin" on public.po_received;
drop policy if exists "po_delete_admin" on public.po_received;

drop policy if exists "forecast_select_all" on public.forecast_targets;
drop policy if exists "forecast_insert_admin" on public.forecast_targets;
drop policy if exists "forecast_update_admin" on public.forecast_targets;
drop policy if exists "forecast_delete_admin" on public.forecast_targets;

-- Editable data: every logged-in BD can view/add/edit/delete
create policy "potential_select_all"
on public.potential_leads for select to authenticated
using (true);

create policy "potential_insert_all"
on public.potential_leads for insert to authenticated
with check (true);

create policy "potential_update_all"
on public.potential_leads for update to authenticated
using (true) with check (true);

create policy "potential_delete_all"
on public.potential_leads for delete to authenticated
using (true);

create policy "customer_select_all"
on public.customer_database for select to authenticated
using (true);

create policy "customer_insert_all"
on public.customer_database for insert to authenticated
with check (true);

create policy "customer_update_all"
on public.customer_database for update to authenticated
using (true) with check (true);

create policy "customer_delete_all"
on public.customer_database for delete to authenticated
using (true);

create policy "lost_select_all"
on public.lost_leads for select to authenticated
using (true);

create policy "lost_insert_all"
on public.lost_leads for insert to authenticated
with check (true);

create policy "lost_update_all"
on public.lost_leads for update to authenticated
using (true) with check (true);

create policy "lost_delete_all"
on public.lost_leads for delete to authenticated
using (true);

create policy "complaint_select_all"
on public.customer_complaints for select to authenticated
using (true);

create policy "complaint_insert_all"
on public.customer_complaints for insert to authenticated
with check (true);

create policy "complaint_update_all"
on public.customer_complaints for update to authenticated
using (true) with check (true);

create policy "complaint_delete_all"
on public.customer_complaints for delete to authenticated
using (true);

-- PO Received: all BD can view, admin only can modify
create policy "po_select_all"
on public.po_received for select to authenticated
using (true);

create policy "po_insert_admin"
on public.po_received for insert to authenticated
with check (public.is_admin());

create policy "po_update_admin"
on public.po_received for update to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "po_delete_admin"
on public.po_received for delete to authenticated
using (public.is_admin());

-- Forecast / Target: all BD can view, admin only can modify
create policy "forecast_select_all"
on public.forecast_targets for select to authenticated
using (true);

create policy "forecast_insert_admin"
on public.forecast_targets for insert to authenticated
with check (public.is_admin());

create policy "forecast_update_admin"
on public.forecast_targets for update to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "forecast_delete_admin"
on public.forecast_targets for delete to authenticated
using (public.is_admin());

-- Grants
grant select, insert, update, delete on public.potential_leads to authenticated;
grant select, insert, update, delete on public.customer_database to authenticated;
grant select, insert, update, delete on public.lost_leads to authenticated;
grant select, insert, update, delete on public.customer_complaints to authenticated;
grant select on public.po_received to authenticated;
grant select on public.forecast_targets to authenticated;

grant insert, update, delete on public.po_received to authenticated;
grant insert, update, delete on public.forecast_targets to authenticated;

-- Realtime
do $$
begin
  begin
    alter publication supabase_realtime add table public.potential_leads;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.customer_database;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.lost_leads;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.customer_complaints;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.po_received;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.forecast_targets;
  exception when duplicate_object then null;
  end;
end $$;

-- END
