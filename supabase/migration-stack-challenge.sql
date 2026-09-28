-- 쌓기 챌린지: 종목을 직접 정해 누적 개수만 세는 챌린지.
-- 설계: docs/superpowers/specs/2026-09-28-stack-challenge-design.md
--
-- 기존 challenge_* 테이블은 건드리지 않는다 — 처방(challenge_program_days)·훈련 요일·
-- 성공/실패(challenge_attempts)가 전부 무의미해서, 재사용하면 derive.ts의 스트릭·일차
-- 판정까지 흔들린다.
--
-- 누적 = sum(delta), 버튼 한 번이 행 하나다. 총합 컬럼 하나로 두면 PostgREST가
-- `total = total + 1`을 표현하지 못해 read-modify-write가 되고 연타 시 카운트가 유실된다.
-- anon 키로 Supabase SQL editor 실행.

create table if not exists stack_challenges (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  title      text not null,                    -- 종목명 = 제목 ('푸쉬업')
  goal_count int,                              -- null = 목표 없음(무한 누적)
  started_at date not null default current_date,
  status     text not null default 'active' check (status in ('active','archived')),
  created_at timestamptz not null default now()
);

create table if not exists stack_entries (
  id                 uuid primary key default gen_random_uuid(),
  stack_challenge_id uuid not null references stack_challenges(id) on delete cascade,
  delta              int  not null,            -- +1/+5/+10/-1/-5/-10
  done_date          date not null default current_date,
  created_at         timestamptz not null default now()
);

create index if not exists idx_stack_challenges_user on stack_challenges(user_id, status);
create index if not exists idx_stack_entries_challenge on stack_entries(stack_challenge_id);

-- RLS — 기존 테이블과 동일하게 전체 허용 (anon/authenticated)
alter table stack_challenges enable row level security;
alter table stack_entries enable row level security;

drop policy if exists "stack_challenges_all" on stack_challenges;
create policy "stack_challenges_all" on stack_challenges
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "stack_entries_all" on stack_entries;
create policy "stack_entries_all" on stack_entries
  for all to anon, authenticated using (true) with check (true);

-- 확인
select 'stack_challenges' as t, count(*) from stack_challenges
union all
select 'stack_entries', count(*) from stack_entries;
