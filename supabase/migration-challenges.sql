-- 챌린지 (제공 챌린지 Phase 2a). 기존 테이블은 건드리지 않는다.
-- 설계: docs/superpowers/specs/2026-06-28-challenge-tab-design.md

-- 1) 챌린지 종류 (시드, 읽기 전용)
create table if not exists challenge_templates (
  key             text primary key,                 -- 'pullup' | 'pushup'
  name            text not null,                    -- '풀업 챌린지'
  exercise        text not null,                    -- '풀업'
  difficulty_mode text not null check (difficulty_mode in ('equipment','range')),
  sort_order      int  not null default 0,
  created_at      timestamptz not null default now()
);

-- 2) day별 목표 횟수표 (난이도 구간별 1개)
create table if not exists challenge_programs (
  id            uuid primary key default gen_random_uuid(),
  template_key  text not null references challenge_templates(key) on delete cascade,
  difficulty_key text,                              -- 풀업=NULL / 푸쉬업='knee_10_15' 등
  label         text,                               -- 표시용
  created_at    timestamptz not null default now(),
  unique (template_key, difficulty_key)
);

create table if not exists challenge_program_days (
  id          uuid primary key default gen_random_uuid(),
  program_id  uuid not null references challenge_programs(id) on delete cascade,
  day_no      int  not null,
  target_reps int  not null,
  unique (program_id, day_no)
);

-- 3) 도전 인스턴스
create table if not exists user_challenges (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references users(id) on delete cascade,
  template_key     text not null references challenge_templates(key),
  program_id       uuid not null references challenge_programs(id),
  difficulty       jsonb not null default '{}'::jsonb,
  training_weekdays int[] not null default '{1,2,3,4,5}',   -- 1=월 .. 7=일
  started_at       date not null default current_date,
  status           text not null default 'active' check (status in ('active','archived')),
  created_at       timestamptz not null default now()
);

-- 4) 도전 시도 이력 (append-only)
create table if not exists challenge_attempts (
  id                uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no            int  not null,
  result            text not null check (result in ('success','fail')),
  done_date         date not null default current_date,
  created_at        timestamptz not null default now()
);

-- 5) 인덱스
create index if not exists idx_user_challenges_user on user_challenges(user_id, status);
create index if not exists idx_challenge_attempts_uc on challenge_attempts(user_challenge_id, day_no);
create index if not exists idx_challenge_attempts_date on challenge_attempts(user_challenge_id, done_date);
