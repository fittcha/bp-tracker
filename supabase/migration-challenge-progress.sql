-- 챌린지 세트별 진행 + 완료/스트릭 보호
-- anon 키로 불가 → Supabase SQL 에디터에서 1회 실행(재실행 안전).

-- Part A: day별 완료 세트 진행
create table if not exists challenge_day_progress (
  id uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no int not null,
  done_sets jsonb not null default '[]',
  updated_at timestamptz not null default now(),
  unique (user_challenge_id, day_no)
);
alter table challenge_day_progress enable row level security;
drop policy if exists "cdp all" on challenge_day_progress;
create policy "cdp all" on challenge_day_progress for all using (true) with check (true);

-- Part B: 완료/스트릭 보호 컬럼
alter table user_challenges add column if not exists completed_at timestamptz;
alter table user_challenges add column if not exists carried_streak int not null default 0;
alter table user_challenges add column if not exists final_streak int not null default 0;
