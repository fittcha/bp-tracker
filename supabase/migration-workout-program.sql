-- 공용 운동 날짜 기반 프로그램: workouts에 program_date/program_label, 동작/로그에 set_lead(그룹 연결자).
-- 기존 컬럼(default_weekday 등)은 호환 위해 유지. 설계:
-- docs/superpowers/specs/2026-06-28-public-workout-date-program-design.md
alter table workouts
  add column if not exists program_date  date,   -- 공용 프로그램 세션 날짜(null=비프로그램)
  add column if not exists program_label text;    -- 프로그램 태그 eyebrow (예: 'Strength 8주 · 1주차')

alter table workout_exercises
  add column if not exists set_lead text;         -- 그룹 위 연결자: 'into' | 자유텍스트 | null

alter table workout_logs
  add column if not exists set_lead text;

create index if not exists idx_workouts_program_date
  on workouts(program_date) where owner_user_id is null;
