-- ROAD TO FITTER: PR 탭(ddodun 이식)용 테이블 (public 스키마). user_1rm은 기존 재사용.
create table if not exists user_nrm (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  exercise_name text not null,
  rep_max int not null check (rep_max between 2 and 10),
  weight decimal,
  weight_unit text default 'lb',
  updated_at timestamptz default now(),
  unique(user_id, exercise_name, rep_max)
);
create table if not exists user_pace_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  equipment text not null,
  distance text not null,
  time_seconds int,
  updated_at timestamptz default now(),
  unique(user_id, equipment, distance)
);
create table if not exists wod_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  wod_type text not null check (wod_type in ('named','open')),
  wod_name text not null,
  score_type text not null check (score_type in ('time','amrap','reps')),
  time_seconds int,
  rounds int,
  extra_reps int,
  reps int,
  memo text,
  recorded_at date not null default current_date,
  created_at timestamptz not null default now()
);
alter table user_nrm enable row level security;
alter table user_pace_records enable row level security;
alter table wod_records enable row level security;
drop policy if exists "pr_user_nrm_all" on user_nrm;
create policy "pr_user_nrm_all" on user_nrm for all to anon, authenticated using (true) with check (true);
drop policy if exists "pr_user_pace_all" on user_pace_records;
create policy "pr_user_pace_all" on user_pace_records for all to anon, authenticated using (true) with check (true);
drop policy if exists "pr_wod_records_all" on wod_records;
create policy "pr_wod_records_all" on wod_records for all to anon, authenticated using (true) with check (true);
create index if not exists idx_user_nrm_user on user_nrm(user_id);
create index if not exists idx_user_pace_user on user_pace_records(user_id);
create index if not exists idx_wod_records_user on wod_records(user_id);
