-- เปิดใช้ Supabase Authentication > Email แล้วสร้างผู้ใช้จาก Dashboard
-- อนุญาตเฉพาะผู้ใช้ที่ผู้ดูแลเพิ่ม uid ไว้ใน registry_members
create extension if not exists pgcrypto;
create table if not exists public.registry_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'staff' check(role in ('staff','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.anesthesia_cases (
 id uuid primary key default gen_random_uuid(),
 service_date date not null,
 hn text not null,
 patient_name text not null,
 age integer check(age between 0 and 120),
 sex text, unit text not null,
 location text, surgeon text, asa text, procedure text, diagnosis text,
 technique text, device text,technical_notes text,anesthetic_agent text,anesthetic_team text,medication_notes text,
 start_time time not null,end_time time,
 bypass_pacu boolean not null default false,
 pacu_in time,pacu_out time,destination text,notes text,
 created_by uuid not null default auth.uid() references auth.users(id),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint pass_destination check(not bypass_pacu or (destination is not null and length(trim(destination))>0))
);
create index if not exists anesthesia_cases_date_idx on public.anesthesia_cases(service_date);
create index if not exists anesthesia_cases_unit_date_idx on public.anesthesia_cases(unit,service_date);
alter table public.registry_members enable row level security;
alter table public.anesthesia_cases enable row level security;
revoke all on public.registry_members from anon,authenticated;
grant select on public.registry_members to authenticated;
create policy "member sees own membership" on public.registry_members for select to authenticated using (user_id=(select auth.uid()));
revoke all on public.anesthesia_cases from anon;
grant select,insert,update,delete on public.anesthesia_cases to authenticated;
-- No client permissions to add or read registry membership.
-- Supabase SQL editor with privileged role must be used to add members.
create policy "authorized members read cases" on public.anesthesia_cases for select to authenticated using
(exists(select 1 from public.registry_members m where m.user_id=(select auth.uid())));
create policy "authorized members insert cases" on public.anesthesia_cases for insert to authenticated with check
(created_by=(select auth.uid()) and exists(select 1 from public.registry_members m where m.user_id=(select auth.uid())));
create policy "authorized members update cases" on public.anesthesia_cases for update to authenticated using
(exists(select 1 from public.registry_members m where m.user_id=(select auth.uid()))) with check
(exists(select 1 from public.registry_members m where m.user_id=(select auth.uid())));
create policy "authorized members delete cases" on public.anesthesia_cases for delete to authenticated using
(exists(select 1 from public.registry_members m where m.user_id=(select auth.uid())));
-- หลังสร้างผู้ใช้ด้วย Supabase Dashboard: Authentication > Users,
-- ผู้ดูแลรันคำสั่งตัวอย่างด้านล่าง โดยแทน UUID เป็น uid ของผู้ใช้จริง:
-- insert into public.registry_members(user_id,role) values ('UUID-OF-USER','staff');
-- ก่อนใช้งานจริง: ตรวจสอบนโยบายเก็บรักษาข้อมูล, สำรองข้อมูล, audit logs, สิทธิ์แก้ไข/ลบ
-- และกฎหมาย/แนวทาง PDPA ของโรงพยาบาล; รุ่นเริ่มต้นนี้ไม่มี audit trail.

-- ใช้เมื่อเคยติดตั้ง schema รุ่นเริ่มต้นแล้ว: เติมคอลัมน์โดยไม่ลบข้อมูลเดิม
alter table public.anesthesia_cases add column if not exists surgeon text;
alter table public.anesthesia_cases add column if not exists asa text;
alter table public.anesthesia_cases add column if not exists anesthetic_agent text;
alter table public.anesthesia_cases add column if not exists anesthetic_team text;
