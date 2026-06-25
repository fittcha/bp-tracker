-- ROAD TO FITTER 시즌2: 운동 라이브러리(공용+개인) + workout_logs 연결 컬럼
-- 시즌1 테이블은 건드리지 않는다.

-- 1) 운동 라이브러리
create table if not exists workouts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  owner_user_id uuid references users(id) on delete cascade,   -- null = 공용
  default_weekday int check (default_weekday between 1 and 5), -- 공용 요일(1=월..5=금)
  category text,                                              -- 신체 부위/종류 (개인 분류용)
  notes text,
  archived boolean not null default false,
  sort_order int not null default 0,
  created_by uuid references users(id),
  created_at timestamptz not null default now()
);

-- 2) 운동 안의 동작들
create table if not exists workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references workouts(id) on delete cascade,
  section text,
  exercise_name text not null,
  sets text,
  reps text,
  notes text,
  sort_order int not null default 0
);

-- 3) 결과 로그 ↔ 동작 연결 (시즌1 template_id와 공존, 둘 다 nullable)
alter table workout_logs
  add column if not exists workout_exercise_id uuid references workout_exercises(id) on delete set null;

-- 4) 조회 인덱스
create index if not exists idx_workouts_owner on workouts(owner_user_id);
create index if not exists idx_workouts_weekday on workouts(default_weekday) where owner_user_id is null;
create index if not exists idx_workout_exercises_workout on workout_exercises(workout_id);
create index if not exists idx_workout_logs_we on workout_logs(workout_exercise_id);

-- 5) RLS — 기존 테이블과 동일하게 전체 허용 (anon/authenticated)
alter table workouts enable row level security;
alter table workout_exercises enable row level security;

drop policy if exists "rtf_workouts_all" on workouts;
create policy "rtf_workouts_all" on workouts
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "rtf_workout_exercises_all" on workout_exercises;
create policy "rtf_workout_exercises_all" on workout_exercises
  for all to anon, authenticated using (true) with check (true);
