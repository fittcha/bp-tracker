-- meal_slot_configs: 식단 슬롯 설정 이력
create table if not exists meal_slot_configs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  effective_date date not null,
  slot_count int not null default 4,
  created_at timestamptz default now(),
  unique(user_id, effective_date)
);

-- daily_logs에 식단 컬럼 추가
alter table daily_logs add column if not exists meal_completed int;
alter table daily_logs add column if not exists meal_total int;

-- cardio_logs: 저강도 유산소 기록
create table if not exists cardio_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  date date not null,
  completed boolean default false,
  memo text,
  created_at timestamptz default now(),
  unique(user_id, date)
);

-- RLS 정책
alter table meal_slot_configs enable row level security;
create policy "meal_slot_configs_all" on meal_slot_configs for all using (true);

alter table cardio_logs enable row level security;
create policy "cardio_logs_all" on cardio_logs for all using (true);
