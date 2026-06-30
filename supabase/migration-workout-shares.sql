-- 개인운동 공유 대기 테이블. 행 존재 = pending. 수락/거부/취소 시 행 삭제.
create table if not exists workout_shares (
  id                uuid primary key default gen_random_uuid(),
  from_user_id      uuid not null references users(id),
  to_user_id        uuid not null references users(id),
  source_workout_id uuid,            -- 보낸 쪽 참조용(취소·대기목록). 원본 삭제돼도 payload로 수락 가능 → FK 미설정
  payload           jsonb not null,  -- 공유 시점 스냅샷 { title, category, exercises:[...] }
  created_at        timestamptz not null default now()
);
create index if not exists idx_workout_shares_to on workout_shares (to_user_id);
create index if not exists idx_workout_shares_from_src on workout_shares (from_user_id, source_workout_id);

-- RLS: 앱 기존 방식(anon 전체 허용)
alter table workout_shares enable row level security;
drop policy if exists workout_shares_all on workout_shares;
create policy workout_shares_all on workout_shares for all using (true) with check (true);
