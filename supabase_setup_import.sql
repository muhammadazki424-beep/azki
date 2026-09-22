-- CETAKDONG TEAM AZKI - SETUP + IMPORT DATA EXCEL
-- Jalankan file ini SEKALI di Supabase > SQL Editor.
-- Data editable: Potential, Database Customer, Lost Leads, Complaint.
-- PO Received dan Forecast: READ-ONLY untuk BD.
-- Semua BD yang login dapat melihat dan mengedit/menghapus data editable.

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
drop policy if exists "profiles_select_all_auth" on public.profiles;
create policy "profiles_select_all_auth"
on public.profiles for select to authenticated
using (true);

drop policy if exists "profiles_update_admin" on public.profiles;
create policy "profiles_update_admin"
on public.profiles for update to authenticated
using (public.is_admin())
with check (public.is_admin());

create table if not exists public.potential_leads (
  id uuid primary key default gen_random_uuid(),
  bd text not null default '',
  customer text not null,
  value numeric not null default 0,
  month text not null default '',
  notes text default '',
  created_at timestamptz default now()
);

create table if not exists public.customer_database (
  id uuid primary key default gen_random_uuid(),
  bd text default '',
  customer text not null,
  area text default '',
  month text default '',
  value numeric not null default 0,
  notes text default '',
  created_at timestamptz default now()
);

create table if not exists public.lost_leads (
  id uuid primary key default gen_random_uuid(),
  company text not null,
  pic text default '',
  packaging text default '',
  product text default '',
  production_system text default '',
  quantity_expected numeric default 0,
  amount_expected numeric default 0,
  why_lost text default '',
  closing_month text default '',
  bd text default '',
  description text default '',
  created_at timestamptz default now()
);

create table if not exists public.customer_complaints (
  id uuid primary key default gen_random_uuid(),
  company text not null,
  pic text default '',
  packaging text default '',
  product text default '',
  article text default '',
  production_system text default '',
  quantity_order numeric default 0,
  quantity_complain numeric default 0,
  why_complain text default '',
  bd text default '',
  description text default '',
  created_at timestamptz default now()
);

create table if not exists public.po_received (
  id uuid primary key default gen_random_uuid(),
  bd text not null default '',
  customer text not null,
  value numeric not null default 0,
  month text not null default '',
  notes text default '',
  created_at timestamptz default now()
);

create table if not exists public.forecast_targets (
  id uuid primary key default gen_random_uuid(),
  bd text not null unique,
  forecast numeric not null default 0,
  target numeric not null default 0,
  achievement_flexo numeric not null default 0,
  achievement_roto numeric not null default 0,
  total numeric not null default 0,
  percentage numeric default 0,
  commission_flexo numeric default 0,
  commission_roto numeric default 0,
  created_at timestamptz default now()
);

alter table public.potential_leads enable row level security;
alter table public.customer_database enable row level security;
alter table public.lost_leads enable row level security;
alter table public.customer_complaints enable row level security;
alter table public.po_received enable row level security;
alter table public.forecast_targets enable row level security;

-- Semua user login boleh lihat semua data.
drop policy if exists "potential_select" on public.potential_leads;
create policy "potential_select" on public.potential_leads for select to authenticated using (true);
drop policy if exists "potential_insert" on public.potential_leads;
create policy "potential_insert" on public.potential_leads for insert to authenticated with check (true);
drop policy if exists "potential_update" on public.potential_leads;
create policy "potential_update" on public.potential_leads for update to authenticated using (true) with check (true);
drop policy if exists "potential_delete" on public.potential_leads;
create policy "potential_delete" on public.potential_leads for delete to authenticated using (true);

drop policy if exists "customer_select" on public.customer_database;
create policy "customer_select" on public.customer_database for select to authenticated using (true);
drop policy if exists "customer_insert" on public.customer_database;
create policy "customer_insert" on public.customer_database for insert to authenticated with check (true);
drop policy if exists "customer_update" on public.customer_database;
create policy "customer_update" on public.customer_database for update to authenticated using (true) with check (true);
drop policy if exists "customer_delete" on public.customer_database;
create policy "customer_delete" on public.customer_database for delete to authenticated using (true);

drop policy if exists "lost_select" on public.lost_leads;
create policy "lost_select" on public.lost_leads for select to authenticated using (true);
drop policy if exists "lost_insert" on public.lost_leads;
create policy "lost_insert" on public.lost_leads for insert to authenticated with check (true);
drop policy if exists "lost_update" on public.lost_leads;
create policy "lost_update" on public.lost_leads for update to authenticated using (true) with check (true);
drop policy if exists "lost_delete" on public.lost_leads;
create policy "lost_delete" on public.lost_leads for delete to authenticated using (true);

drop policy if exists "complaint_select" on public.customer_complaints;
create policy "complaint_select" on public.customer_complaints for select to authenticated using (true);
drop policy if exists "complaint_insert" on public.customer_complaints;
create policy "complaint_insert" on public.customer_complaints for insert to authenticated with check (true);
drop policy if exists "complaint_update" on public.customer_complaints;
create policy "complaint_update" on public.customer_complaints for update to authenticated using (true) with check (true);
drop policy if exists "complaint_delete" on public.customer_complaints;
create policy "complaint_delete" on public.customer_complaints for delete to authenticated using (true);

-- PO dan Forecast: BD hanya SELECT. Admin boleh CRUD.
drop policy if exists "po_select" on public.po_received;
create policy "po_select" on public.po_received for select to authenticated using (true);
drop policy if exists "po_admin_insert" on public.po_received;
create policy "po_admin_insert" on public.po_received for insert to authenticated with check (public.is_admin());
drop policy if exists "po_admin_update" on public.po_received;
create policy "po_admin_update" on public.po_received for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "po_admin_delete" on public.po_received;
create policy "po_admin_delete" on public.po_received for delete to authenticated using (public.is_admin());

drop policy if exists "forecast_select" on public.forecast_targets;
create policy "forecast_select" on public.forecast_targets for select to authenticated using (true);
drop policy if exists "forecast_admin_insert" on public.forecast_targets;
create policy "forecast_admin_insert" on public.forecast_targets for insert to authenticated with check (public.is_admin());
drop policy if exists "forecast_admin_update" on public.forecast_targets;
create policy "forecast_admin_update" on public.forecast_targets for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "forecast_admin_delete" on public.forecast_targets;
create policy "forecast_admin_delete" on public.forecast_targets for delete to authenticated using (public.is_admin());


grant select, insert, update, delete on public.potential_leads to authenticated;
grant select, insert, update, delete on public.customer_database to authenticated;
grant select, insert, update, delete on public.lost_leads to authenticated;
grant select, insert, update, delete on public.customer_complaints to authenticated;
grant select, insert, update, delete on public.po_received to authenticated;
grant select, insert, update, delete on public.forecast_targets to authenticated;
grant select on public.profiles to authenticated;


-- Aktifkan realtime untuk tabel baru (aman jika sudah terdaftar).
do $$
begin
  begin alter publication supabase_realtime add table public.potential_leads; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.customer_database; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.lost_leads; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.customer_complaints; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.po_received; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.forecast_targets; exception when duplicate_object then null; end;
end $$;

-- Replace initial imported data.
truncate table public.potential_leads, public.customer_database, public.lost_leads,
  public.customer_complaints, public.po_received, public.forecast_targets;

insert into public.potential_leads (bd, customer, value, month, notes) values
('Anggri','PT Citra Rasa Kuliner ( Roto)',425000000.0,'March (W1)','Imported from Excel'),
('Anggri','PT Sambal Bakar Indonesia(roto)',336000000.0,'March (W1)','Imported from Excel'),
('Anggri','PT Refli Kosmedika Lab',14700000.0,'March (W1)','Imported from Excel'),
('Nicolas','*CV Bin Suef',0.0,'March (W1)','Imported from Excel'),
('Nicolas','*PT Raja Jeva Nisi',0.0,'March (W1)','Imported from Excel'),
('Nicolas','PT Berkat Kreasi Sosial',0.0,'March (W1)','Imported from Excel'),
('Nicolas','PT Cakrawala Semesta Estetika',0.0,'March (W1)','Imported from Excel'),
('Nicolas','*PT Funbox Manufacture Indonesia',15000000.0,'March (W1)','Imported from Excel'),
('Nicolas','PT Koki Sehat Sejahtera',14250000.0,'March (W1)','Imported from Excel'),
('Nicolas','PT Krisma Abadi Perkasa',44000000.0,'March (W1)','Imported from Excel'),
('Nicolas','PT Mulia Indah Cosmetindo',29400000.0,'March (W1)','Imported from Excel'),
('Johnsen','*IGO Indonesia (Roto)',0.0,'March (W1)','Imported from Excel'),
('Johnsen','*Kopi Bubuk 666',0.0,'March (W1)','Imported from Excel'),
('Johnsen','Herbal Rock Sugar',0.0,'March (W1)','Imported from Excel'),
('Johnsen','Perseorangan - Pak Bambang',0.0,'March (W1)','Imported from Excel'),
('Johnsen','Perseorangan - Pak Yudha',58951200.0,'March (W1)','Imported from Excel'),
('Johnsen','INACO (PT Niramas Utama)',35800000.0,'March (W1)','Imported from Excel'),
('Johnsen','INACO (PT Niramas Utama)',19000000.0,'March (W1)','Imported from Excel'),
('Nirina','PT Sanlex Malindo',21228000.0,'March (W1)','Imported from Excel'),
('Nirina','PT Sumber Nelayan Indonesia',297342000.0,'March (W1)','Imported from Excel'),
('Nirina','PT Sumber Nelayan Indonesia',271550000.0,'March (W1)','Imported from Excel');

insert into public.customer_database (bd, customer, area, month, value, notes) values
('AZKI','PT. MULTIRASA NUSANTARA','Bekasi','December 2024',70200000.0,'Imported from Excel'),
('AZKI','PT. MULTIRASA NUSANTARA','Bekasi','May 2025',65000000.0,'Imported from Excel'),
('AZKI','PT. MULTIRASA NUSANTARA','Bekasi','SEPTEMBER',145000000.0,'Imported from Excel'),
('AZKI','PT. MULTIRASA NUSANTARA','Bekasi','December 2025',259840000.0,'Imported from Excel'),
('AZKI','PT. RUMAH DIGITAL NUSANTARA','Jakarta','December 2024',43290000.0,'Imported from Excel'),
('AZKI','PT. RUMAH DIGITAL NUSANTARA','Jakarta','January 2025',36000000.0,'Imported from Excel'),
('AZKI','PT. RUMAH DIGITAL NUSANTARA','Jakarta','February 2025',25600000.0,'Imported from Excel'),
('AZKI','SISTER BROTH','Jakarta','December 2024',49680000.0,'Imported from Excel'),
('AZKI','Yayasan Muhajir','Jakarta','December 2024',26250000.0,'Imported from Excel'),
('AZKI','PT. RAY PUTRA BORNEO','Kalimantan','January 2025',38400000.0,'Imported from Excel'),
('AZKI','SARI INDO RASA','Jakarta','January 2025',114800000.0,'Imported from Excel'),
('AZKI','SARI INDO RASA','Jakarta','May 2025',55250000.0,'Imported from Excel'),
('AZKI','SARI INDO RASA','Jakarta','October 2025',50500000.0,'Imported from Excel'),
('AZKI','SARI INDO RASA','Jakarta','December 2025',52400000.0,'Imported from Excel'),
('AZKI','PT. PELANGI DAUN SRI REJEKI','Jakarta','February 2025',30155070.0,'Imported from Excel'),
('AZKI','PT. PELANGI DAUN SRI REJEKI','Jakarta','NOVEMBER',32720000.0,'Imported from Excel'),
('AZKI','ROCKY N CO','Jakarta','March 2025',34758000.0,'Imported from Excel'),
('AZKI','NATURAL POULTRY','Jakarta','March 2025',37500000.0,'Imported from Excel'),
('AZKI','NATURAL POULTRY','Jakarta','August 2025',37500000.0,'Imported from Excel'),
('AZKI','DEDEN RUSTANDI','Sukabumi','APRIL',21405000.0,'Imported from Excel'),
('AZKI','DEDEN RUSTANDI','Sukabumi','NOVEMBER',31530540.0,'Imported from Excel'),
('AZKI','PT. INOVASI SUKSES GLOBAL','BOGOR','May 2025',50925000.0,'Imported from Excel'),
('AZKI','DADIO FISH','Jakarta','May 2025',11260000.0,'Imported from Excel'),
('AZKI','PT. GITA FOOD','sukoharjo','July 2025',36140000.0,'Imported from Excel'),
('AZKI','PT. GITA FOOD','sukoharjo','August 2025',50370000.0,'Imported from Excel'),
('AZKI','PT. GITA FOOD','sukoharjo','October 2025',104433800.0,'Imported from Excel'),
('AZKI','PT. BINTANG AGROKIMIA UTAMA','Medan','August 2025',87820000.0,'Imported from Excel'),
('AZKI','PT. BINTANG AGROKIMIA UTAMA','Medan','October 2025',78386685.0,'Imported from Excel'),
('AZKI','PT. FOODLAB INDONESIA RAYA','Tangerang','August 2025',38900000.0,'Imported from Excel'),
('AZKI','PT. PALASINDO AZKIATAMA','Jakarta','August 2025',27181500.0,'Imported from Excel'),
('AZKI','PT. PALASINDO AZKIATAMA','Jakarta','December 2025',125496000.0,'Imported from Excel'),
('AZKI','PT. CIPTA RASA FOOD','Tangerang','June 2025',7939890.0,'Imported from Excel'),
('AZKI','PT. GENERASI SEHAT CERDAS','Jakarta','October 2025',380160000.0,'Imported from Excel'),
('AZKI','Total','','December 2024',189420000.0,'Imported from Excel'),
('AZKI','Total','','January 2025',189200000.0,'Imported from Excel'),
('AZKI','Total','','February 2025',55755070.0,'Imported from Excel'),
('AZKI','Total','','March 2025',72258000.0,'Imported from Excel'),
('AZKI','Total','','APRIL',21405000.0,'Imported from Excel'),
('AZKI','Total','','May 2025',182435000.0,'Imported from Excel'),
('AZKI','Total','','June 2025',7939890.0,'Imported from Excel'),
('AZKI','Total','','July 2025',36140000.0,'Imported from Excel'),
('AZKI','Total','','August 2025',241771500.0,'Imported from Excel'),
('AZKI','Total','','SEPTEMBER',145000000.0,'Imported from Excel'),
('AZKI','Total','','October 2025',613480485.0,'Imported from Excel'),
('AZKI','Total','','NOVEMBER',64250540.0,'Imported from Excel'),
('AZKI','Total','','December 2025',437736000.0,'Imported from Excel'),
('MARKETING','CUSTOMER','','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','August 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','SEPTEMBER',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','October 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','NOVEMBER',0,'Imported from Excel'),
('AZKI','PT. SARI INDO RASA','Jakarta','December 2024',51000000.0,'Imported from Excel'),
('AZKI','PT. SARI INDO RASA','Jakarta','February 2025',52400000.0,'Imported from Excel'),
('AZKI','PT. SARI INDO RASA','Jakarta','May 2025',154700000.0,'Imported from Excel'),
('AZKI','NATURAL POULTRY','Jakarta','December 2024',37800000.0,'Imported from Excel'),
('AZKI','CV ARSA PANGAN MULIA','Gresik','December 2024',56700000.0,'Imported from Excel'),
('AZKI','CV ARSA PANGAN MULIA','Gresik','February 2025',77500000.0,'Imported from Excel'),
('AZKI','CV ARSA PANGAN MULIA','Gresik','APRIL',116880000.0,'Imported from Excel'),
('AZKI','DEDEN RUSTANDI','Sukabumi','December 2024',57000000.0,'Imported from Excel'),
('AZKI','DEDEN RUSTANDI','Sukabumi','June 2025',64828000.0,'Imported from Excel'),
('AZKI','PT. BINTANG AGROKIMIA UTAMA','Medan','January 2025',330965124.0,'Imported from Excel'),
('AZKI','PT. BINTANG AGROKIMIA UTAMA','Medan','February 2025',56700000.0,'Imported from Excel'),
('AZKI','PT FOODLAB INDONESIA RAYA','Tangerang','January 2025',38146000.0,'Imported from Excel'),
('AZKI','PT FOODLAB INDONESIA RAYA','Tangerang','March 2025',100720000.0,'Imported from Excel'),
('AZKI','PT FOODLAB INDONESIA RAYA','Tangerang','May 2025',37095000.0,'Imported from Excel'),
('AZKI','PT FOODLAB INDONESIA RAYA','Tangerang','July 2025',72200000.0,'Imported from Excel'),
('AZKI','ROCKY N CO','Jakarta','February 2025',18180000.0,'Imported from Excel'),
('AZKI','PT. PERMATA OMBAK ARUNIKA','BALI','February 2025',26857124.0,'Imported from Excel'),
('AZKI','PT. PELANGI DAUN SRI REJEKI','Jakarta','March 2025',59683080.0,'Imported from Excel'),
('AZKI','PT. PELANGI DAUN SRI REJEKI','Jakarta','May 2025',134430738.0,'Imported from Excel'),
('AZKI','PT. MAINDO INTERBUMI','Tangerang','March 2025',43120000.0,'Imported from Excel'),
('AZKI','PT. NATURA INDOLAND','Tangerang','March 2025',107910000.0,'Imported from Excel'),
('AZKI','CV INDOCOCO','Banyumas','March 2025',330249800.0,'Imported from Excel'),
('AZKI','PT. GENERASI SEHAT CERDAS','Jakarta','APRIL',91950000.0,'Imported from Excel'),
('AZKI','PT. SEDARI ALAM NUSANTARA','BOGOR','May 2025',14600650.0,'Imported from Excel'),
('AZKI','PT. BERKAH ABADI PANGAN','BOGOR','May 2025',94700000.0,'Imported from Excel'),
('AZKI','PT. BERKAH ABADI PANGAN','BOGOR','July 2025',454740000.0,'Imported from Excel'),
('AZKI','PT. BERKAH ABADI PANGAN','BOGOR','August 2025',118200000.0,'Imported from Excel'),
('AZKI','MULTIRASA NUSANTARA','Bekasi','June 2025',476000000.0,'Imported from Excel'),
('AZKI','RAMU ANUGRAH CEMERLANG','Jakarta','June 2025',42000000.0,'Imported from Excel'),
('AZKI','PT. GITA FOOD','sukoharjo','June 2025',19730000.0,'Imported from Excel'),
('AZKI','PT. GITA FOOD','sukoharjo','August 2025',19730000.0,'Imported from Excel'),
('AZKI','Total','','December 2024',202500000.0,'Imported from Excel'),
('AZKI','Total','','January 2025',369111124.0,'Imported from Excel'),
('AZKI','Total','','February 2025',231637124.0,'Imported from Excel'),
('AZKI','Total','','March 2025',641682880.0,'Imported from Excel'),
('AZKI','Total','','APRIL',208830000.0,'Imported from Excel'),
('AZKI','Total','','May 2025',435526388.0,'Imported from Excel'),
('AZKI','Total','','June 2025',602558000.0,'Imported from Excel'),
('AZKI','Total','','July 2025',526940000.0,'Imported from Excel'),
('AZKI','Total','','August 2025',137930000.0,'Imported from Excel'),
('AZKI','Total','','SEPTEMBER',0.0,'Imported from Excel'),
('AZKI','Total','','October 2025',0.0,'Imported from Excel'),
('AZKI','Total','','NOVEMBER',0.0,'Imported from Excel'),
('MARKETING','CUSTOMER','','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','August 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','SEPTEMBER',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','October 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','NOVEMBER',0,'Imported from Excel'),
('NICOLAS','PT FARMINDO ANN CHEMICAL','Probolinggo, Jawa Timur','December 2024',19900000.0,'Imported from Excel'),
('NICOLAS','PT BERKAT KREASI SOSIAL','Jakarta','January 2025',24391098.0,'Imported from Excel'),
('NICOLAS','PT SINERGI CHEM INDONESIA','Serpong, Tangerang','February 2025',89000000.0,'Imported from Excel'),
('NICOLAS','PT SINERGI CHEM INDONESIA','Serpong, Tangerang','March 2025',32000000.0,'Imported from Excel'),
('NICOLAS','PT SINERGI CHEM INDONESIA','Serpong, Tangerang','October 2025',31400000.0,'Imported from Excel'),
('NICOLAS','PT MULIA INDAH COSMETINDO','Gunung Putri, Bogor','March 2025',54000000.0,'Imported from Excel'),
('NICOLAS','PT SANJAYA CAHAYA PERKASA','Tangerang','APRIL',127650000.0,'Imported from Excel'),
('NICOLAS','CV DUTA MANDASARI','Padang','APRIL',16500000.0,'Imported from Excel'),
('NICOLAS','CHARITY FOOD','Surabaya','May 2025',18530000.0,'Imported from Excel'),
('NICOLAS','CHARITY FOOD','Surabaya','October 2025',23200000.0,'Imported from Excel'),
('NICOLAS','PT PRATAMA PUTRA SATRIA','Bekasi','May 2025',32000000.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','June 2025',144339748.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','SEPTEMBER',149431960.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','NOVEMBER',149431960.0,'Imported from Excel'),
('NICOLAS','PT KHARIS AGUNG PUTRA JAYA','Gn Putri, Bogor','July 2025',28000000.0,'Imported from Excel'),
('NICOLAS','PT KHARIS AGUNG PUTRA JAYA','Gn Putri, Bogor','SEPTEMBER',42660000.0,'Imported from Excel'),
('NICOLAS','CV AMAL BERKAH DANGDER','Tangerang','August 2025',55000000.0,'Imported from Excel'),
('NICOLAS','Total','','December 2024',19900000.0,'Imported from Excel'),
('NICOLAS','Total','','January 2025',24391098.0,'Imported from Excel'),
('NICOLAS','Total','','February 2025',89000000.0,'Imported from Excel'),
('NICOLAS','Total','','March 2025',32000000.0,'Imported from Excel'),
('NICOLAS','Total','','APRIL',144150000.0,'Imported from Excel'),
('NICOLAS','Total','','May 2025',50530000.0,'Imported from Excel'),
('NICOLAS','Total','','June 2025',144339748.0,'Imported from Excel'),
('NICOLAS','Total','','July 2025',28000000.0,'Imported from Excel'),
('NICOLAS','Total','','August 2025',55000000.0,'Imported from Excel'),
('NICOLAS','Total','','SEPTEMBER',192091960.0,'Imported from Excel'),
('NICOLAS','Total','','October 2025',31400000.0,'Imported from Excel'),
('NICOLAS','Total','','NOVEMBER',149431960.0,'Imported from Excel'),
('MARKETING','CUSTOMER','','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','August 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','SEPTEMBER',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','October 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','','NOVEMBER',0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','December 2024',149431960.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','January 2025',157296800.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','March 2025',280560000.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','APRIL',246000000.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','May 2025',193000000.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','June 2025',220000000.0,'Imported from Excel'),
('NICOLAS','CV BIN SUEF','Sukabumi','August 2025',240000000.0,'Imported from Excel'),
('NICOLAS','PT SAFEEKO BIO INDONESIA','Tangerang','December 2024',57540000.0,'Imported from Excel'),
('NICOLAS','PT SINERGI CHEM INDONESIA','Tangerang','December 2024',25800000.0,'Imported from Excel'),
('NICOLAS','PT DAE IN TECH','Cikarang','December 2024',21500000.0,'Imported from Excel'),
('NICOLAS','PT KHARIS AGUNG PUTRA JAYA','Gunung Putri, Bogor','January 2025',40500000.0,'Imported from Excel'),
('NICOLAS','PT KHARIS AGUNG PUTRA JAYA','Gunung Putri, Bogor','February 2025',31520000.0,'Imported from Excel'),
('NICOLAS','PT KHARIS AGUNG PUTRA JAYA','Gunung Putri, Bogor','APRIL',62195000.0,'Imported from Excel'),
('NICOLAS','PT RAJA JEVA NISI','Bekasi','February 2025',38362500.0,'Imported from Excel'),
('NICOLAS','PT RAJA JEVA NISI','Bekasi','APRIL',172500000.0,'Imported from Excel'),
('NICOLAS','PT RAJA JEVA NISI','Bekasi','June 2025',175500000.0,'Imported from Excel'),
('NICOLAS','PT RAJA JEVA NISI','Bekasi','August 2025',175500000.0,'Imported from Excel'),
('NICOLAS','PT BUYUNG POETRA SEMBADA','Jakarta Barat','February 2025',47630000.0,'Imported from Excel'),
('NICOLAS','PT RAJAWALI HIYOTO','Bandung','May 2025',32350000.0,'Imported from Excel'),
('NICOLAS','PT FUNBOX MANUFACTURE INDONESIA','Cikarang','May 2025',94242000.0,'Imported from Excel'),
('NICOLAS','PT FUNBOX MANUFACTURE INDONESIA','Cikarang','June 2025',6360000.0,'Imported from Excel'),
('NICOLAS','CV DEWA AGRO INDONESIA','Bekasi','June 2025',18300000.0,'Imported from Excel'),
('NICOLAS','PT CAKRAWALA SEMESTA ESTETIKA','Bogor','June 2025',17100000.0,'Imported from Excel'),
('NICOLAS','PT CAKRAWALA SEMESTA ESTETIKA','Bogor','August 2025',18900000.0,'Imported from Excel'),
('NICOLAS','CHARITY FOOD','Mataram','July 2025',23740000.0,'Imported from Excel'),
('NICOLAS','PT KOKI SEHAT SEJAHTERA','Boyolali','August 2025',14250000.0,'Imported from Excel'),
('NICOLAS','PT BERKAT KREASI SOSIAL','Tangerang','August 2025',66720000.0,'Imported from Excel'),
('NICOLAS','Total','','December 2024',254271960.0,'Imported from Excel'),
('NICOLAS','Total','','January 2025',197796800.0,'Imported from Excel'),
('NICOLAS','Total','','February 2025',117512500.0,'Imported from Excel'),
('NICOLAS','Total','','March 2025',280560000.0,'Imported from Excel'),
('NICOLAS','Total','','APRIL',480695000.0,'Imported from Excel'),
('NICOLAS','Total','','May 2025',319592000.0,'Imported from Excel'),
('NICOLAS','Total','','June 2025',437260000.0,'Imported from Excel'),
('NICOLAS','Total','','July 2025',23740000.0,'Imported from Excel'),
('NICOLAS','Total','','August 2025',515370000.0,'Imported from Excel'),
('NICOLAS','Total','','SEPTEMBER',0.0,'Imported from Excel'),
('NICOLAS','Total','','October 2025',0.0,'Imported from Excel'),
('NICOLAS','Total','','NOVEMBER',0.0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','August 2025',0,'Imported from Excel'),
('Anggri','PT JAVELO TERA LESTARI','BANYUMAS','March 2025',77785000.0,'Imported from Excel'),
('Anggri','PT MULTI STAR RUKUN ABADI','BANDUNG','APRIL',410000000.0,'Imported from Excel'),
('Anggri','PT SENDANG MITRA PESONA','TANGGERANG','APRIL',31000000.0,'Imported from Excel'),
('Anggri','PT MAHAKARYA APPAREL INDONESIA','JAKARTA','APRIL',31800000.0,'Imported from Excel'),
('Anggri','Total','','March 2025',77785000.0,'Imported from Excel'),
('Anggri','Total','','APRIL',472800000.0,'Imported from Excel'),
('Anggri','Total','','May 2025',0.0,'Imported from Excel'),
('Anggri','Total','','June 2025',0.0,'Imported from Excel'),
('Anggri','Total','','July 2025',0.0,'Imported from Excel'),
('Anggri','Total','','August 2025',0.0,'Imported from Excel'),
('Anggri','Total','','SEPTEMBER',0.0,'Imported from Excel'),
('Anggri','Total','','October 2025',0.0,'Imported from Excel'),
('Anggri','Total','','NOVEMBER',0.0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','August 2025',0,'Imported from Excel'),
('Nirina','Rocky N Co','Jakarta','May 2025',22850000.0,'Imported from Excel'),
('Nirina','Total','','March 2025',0.0,'Imported from Excel'),
('Nirina','Total','','APRIL',0.0,'Imported from Excel'),
('Nirina','Total','','May 2025',22850000.0,'Imported from Excel'),
('Nirina','Total','','June 2025',0.0,'Imported from Excel'),
('Nirina','Total','','July 2025',0.0,'Imported from Excel'),
('Nirina','Total','','August 2025',0.0,'Imported from Excel'),
('Nirina','Total','','SEPTEMBER',0.0,'Imported from Excel'),
('Nirina','Total','','October 2025',0.0,'Imported from Excel'),
('Nirina','Total','','NOVEMBER',0.0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','December 2024',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','January 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','February 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','March 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','APRIL',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','May 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','June 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','July 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','August 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','SEPTEMBER',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','October 2025',0,'Imported from Excel'),
('MARKETING','CUSTOMER','AREA','NOVEMBER',0,'Imported from Excel'),
('Johnsen','PT Chemipack Tambang Indonesia','Jakarta','December 2024',59200000.0,'Imported from Excel'),
('Johnsen','YPC Sembako','Palembang','February 2025',22720960.0,'Imported from Excel'),
('Johnsen','YPC Sembako','Palembang','May 2025',28860750.0,'Imported from Excel'),
('Johnsen','IGO Indonesia','Jakarta','March 2025',48180000.0,'Imported from Excel'),
('Johnsen','IGO Indonesia','Jakarta','July 2025',46800000.0,'Imported from Excel'),
('Johnsen','PT Junny Boleh Dicoba','Jakarta','March 2025',68435000.0,'Imported from Excel'),
('Johnsen','PT Junny Boleh Dicoba','Jakarta','APRIL',179025750.0,'Imported from Excel'),
('Johnsen','PT Junny Boleh Dicoba','Jakarta','May 2025',36250000.0,'Imported from Excel'),
('Johnsen','PT Junny Boleh Dicoba','Jakarta','June 2025',184550000.0,'Imported from Excel'),
('Johnsen','PT Junny Boleh Dicoba','Jakarta','July 2025',19600000.0,'Imported from Excel'),
('Johnsen','PT Smada Solusi Indonesia','Jakarta','May 2025',17412000.0,'Imported from Excel'),
('Johnsen','Herbal Rock Sugar','','August 2025',11347350.0,'Imported from Excel'),
('Johnsen','Roll Kopi Herman','','August 2025',68400000.0,'Imported from Excel'),
('Johnsen','Total','','March 2025',116615000.0,'Imported from Excel'),
('Johnsen','Total','','APRIL',179025750.0,'Imported from Excel'),
('Johnsen','Total','','May 2025',82522750.0,'Imported from Excel'),
('Johnsen','Total','','June 2025',184550000.0,'Imported from Excel'),
('Johnsen','Total','','July 2025',66400000.0,'Imported from Excel'),
('Johnsen','Total','','August 2025',79747350.0,'Imported from Excel'),
('Johnsen','Total','','SEPTEMBER',0.0,'Imported from Excel'),
('Johnsen','Total','','October 2025',0.0,'Imported from Excel'),
('Johnsen','Total','','NOVEMBER',0.0,'Imported from Excel');

insert into public.lost_leads (company,pic,packaging,product,production_system,quantity_expected,amount_expected,why_lost,closing_month,bd,description) values
('Chicken''s Rizz','Fariz Munziri','Roll Lid Cup PET12/LLDPE40 ukuran 130mm x 500meter','Minuman','Rotogravure',350.0,95540308.0,'harga tidak sesuai, perbandingan dengan order sebelumnya di 156.045 per 1200 meter','September','Nala',NULL);

insert into public.customer_complaints (company,pic,packaging,product,article,production_system,quantity_order,quantity_complain,why_complain,bd,description) values
('PT Cakrawala Semesta Estetika - LANU','Anggit','Sachet 3SS','Skincare serum','LANU',' Flexo',60000.0,16600.0,'Hasil Print Tidak Sesuai','Nicolas','Ada garis putih, dan banyak bintik bintik'),
('PT. Berkah abadi Pangan (Bunda Elia)','Andri','STP ','Kaldu ','Kaldu bumbu bunda',' Flexo',180000.0,94700000.0,'Hasil Print Tidak Sesuai',' Azki','Gradasi dan warna masih tidak sesuai');

insert into public.po_received (bd,customer,value,month,notes) values
('Nicolas','PT. Cakrawala semesta estetika',18900000.0,'September','Imported from Excel'),
('Nicolas','PT. Berkat Kreasi Sosial',66720000.0,'September','Imported from Excel'),
('Nicolas','Cv. Bin Suef',240000000.0,'September','Imported from Excel'),
('Nicolas','PT. Raja Jeva Nisi',175500000.0,'September','Imported from Excel'),
('Nicolas','PT. Koki Sehat Sejahtera',14250000.0,'September','Imported from Excel'),
('Johnsen','Herbal Rock Sugar (FLEXO)',11347350.0,'September','Imported from Excel'),
('Johnsen','Roll Kopi Herman (ROTO)',68400000.0,'September','Imported from Excel'),
('Johnsen','Igo Indonesia',85800000.0,'September','Imported from Excel'),
('Johnsen','Pak Bambang',18000000.0,'September','Imported from Excel'),
('Johnsen','Igo Indonesia',81750000.0,'September','Imported from Excel'),
('Johnsen','PT. Junny Boleh dicoba',24000000.0,'September','Imported from Excel'),
('Nirina','Rocky N Co',22850000.0,'September','Imported from Excel'),
('Others','Gita Food',19730000.0,'September','Imported from Excel'),
('Others','PT. Berkah Mega Trading',118200000.0,'September','Imported from Excel'),
('Others','Gita Food',13975000.0,'September','Imported from Excel'),
('Others','Flavorlab',110955000.0,'September','Imported from Excel'),
('Others','Flavorlab',25050000.0,'September','Imported from Excel');

insert into public.forecast_targets (bd,forecast,target,achievement_flexo,achievement_roto,total,percentage,commission_flexo,commission_roto) values
('Anggri',0.0,375000000.0,0.0,0.0,0,0,0,0),
('Nicolas',0.0,375000000.0,33150000.0,482220000.0,515370000,1.37432,397800,964440),
('Johnsen',0.0,250000000.0,53347350.0,235950000.0,289297350,1.1571894,480126.15,471900),
('Nirina',0.0,250000000.0,22850000.0,0.0,22850000,0.0914,0,0),
('Others',0.0,0.0,287910000.0,0.0,262860000.0,0,0,0);

-- Synchronize profile targets with the Excel target sheet where names match.
update public.profiles p
set target = f.target
from public.forecast_targets f
where lower(trim(p.full_name)) = lower(trim(f.bd))
  and f.bd in ('Anggri','Nicolas','Johnsen','Nirina');

-- END SETUP + IMPORT
