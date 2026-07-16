-- 8주 스트렝스 공용 프로그램 시드 (2026-07-06 시작, 평일 40세션).
-- 구조: 프로그램 1일 = 섹션(A~F)별 개별 공용 카드. 일뷰는 workouts 1행당 카드 1개를 렌더하므로
--       하루에 섹션마다 workouts 1행씩(같은 program_date) 발행한다.
-- 2026-07-16: bp(시즌1) 고립/보조 그룹을 매일 2~3개(등/어깨/삼두/이두 + 월수목 하체보조)
--   중간 삽입 → 기존 안정화/스킬/코어/피니셔가 뒤 레터로 밀림. bp 원본 처방 그대로 차용.
--   설계·확정안: docs/plans/2026-07-16-strength-8week-isolation-preview.md
-- 적용 전: migration-workout-program.sql 먼저. anon 키로 Supabase SQL editor 실행.
-- 데이터 원본: docs/data/season2-strength-8week-data.md (+ 위 preview 문서)

-- ===== 정리(wipe): 재적용 전 옛/잘못된 데이터 제거 (멱등) =====
-- 1) 기존 날짜기반 8주 프로그램 카드 제거 (exercises cascade, 연결 로그는 set null로 고아화)
delete from workouts where owner_user_id is null and program_label like 'Strength 8주%';
-- 2) 잘못 적용된 적 있는 default_weekday 기반 'S2 W*' 운동 제거.
--    (program_date 없이 default_weekday만 써서 같은 요일에 8주치가 전부 겹쳐 쌓이던 원인)
delete from workouts where owner_user_id is null and title like 'S2 W%';
-- 3) 위 삭제로 끊긴(고아) 프로그램/잔재 로그 정리 — 프로그램 미시작(7/6)이라 실데이터 없음.
--    범위를 6/29부터로: 잘못 쌓인 직전 평일(6/30~7/3)까지 포함. WOD/개인 로그는 유효 FK라 보존.
delete from workout_logs
  where date between '2026-06-29' and '2026-08-28'
    and workout_exercise_id is null and is_custom = false and template_id is null;
-- 4) 중복 로그 정리: (user, date, workout_exercise_id)당 1개만 남김 (WOD 중복 등 자동담기 잔재)
delete from workout_logs a using workout_logs b
  where a.user_id = b.user_id and a.date = b.date
    and a.workout_exercise_id = b.workout_exercise_id
    and a.workout_exercise_id is not null and a.id > b.id
    and a.date between '2026-06-29' and '2026-08-28';
-- 5) 옛 placeholder(어깨·가슴 등)만 archive — 데일리 WOD/박스 와드는 건드리지 않음(상태 뒤집힘 방지)

-- ============================================================
-- 1주차
-- ============================================================

-- 2026-07-06 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '5', '@ 75% 1RM · Rest 2:00', 0, 1, '6 Sets', null),
  ('A', 'Back Squat', null, 'AMRAP', '@ 50% 1RM · 2~3개 남기고', 1, 2, '백오프 · 1 Set', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Single Arm DB Row', null, '12/12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-07 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', null, '8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', null, '8~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Close-grip Push up', null, '10~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 5) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 6) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 7) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Goblet Squats', null, '15~20', 'Every 2:00 for 5 sets (10 minutes) / Quality', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 8) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 9) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Lateral Raise', null, '15~20', '번아웃 · Rest 0:45', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-08 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 7) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '5', '@ 75% 1RM · Rest 2:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 8) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 9) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 10) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 11) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-09 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 10) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', null, '8/8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 11) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull ups', null, '15', 'Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 12) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 스킬', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 13) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 코어', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 14) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-10 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 13) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '8', '@ 70% 1RM · Rest 2:00', 0, 1, '5 Sets', null),
  ('A', 'Bench Press', null, 'AMRAP', '@ 50% 1RM · 2~3개 남기고', 1, 2, '백오프 · 1 Set', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 14) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 15) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bench Fly', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'DB Bent Fly', null, '20', null, 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 16) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 17) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Frog Pump', null, '15~20', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Wall Sit Hold', null, '0:30', null, 1, 1, 'Superset · 3 Sets', null),
  ('E', 'Goblet Squats', null, '15~20', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 18) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 2주차
-- ============================================================

-- 2026-07-13 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 16) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Pause Back Squat', null, '5', '하단 2-3초 정지 · @ 72.5% 1RM · Rest 2:00', 0, 1, '6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 17) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Pendlay Row', null, '8', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 18) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rolling DB Skull Crusher', null, '25', '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 19) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Front Raises', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Lateral Raises', null, '20', null, 1, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Push Press', null, '20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 20) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-14 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 19) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Bench Press', null, '8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 20) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Diamond Push up', null, '10~15', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Arnold Press', null, '10~12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 21) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '21''s (7/7/7) Barbell Curls', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('C', '15 KB Curls', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 22) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', '15/15 DB Tricep Kickback', null, null, '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 23) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Reverse Lunges', null, '15/15', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Toes up DB Romanian Deadlift', null, '15', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 24) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 25) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Arnold Press', null, null, '무게↑', 0, 1, 'Climbing 12-10-8-6', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-15 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 23) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '3', '폭발적(스피드) · @ 70% 1RM · Rest 1:30', 0, 1, '8 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 24) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', null, '10', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Band Pull Aparts', null, '20', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 25) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 26) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 27) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-16 (목) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 26) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', null, '5', '@ 77.5% 1RM · Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 27) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '15/15', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Face Pull', null, '20~30', 'Rest 2:00', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 28) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Extension', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 하체', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 29) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Walking Lunges', null, '20 Steps', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Death March', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 30) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 31) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-17 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 29) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Pause Bench Press', null, '5', '가슴 1~2초 정지 · @ 72.5% 1RM · Rest 2:00', 0, 1, '6 Sets', null),
  ('A', 'Bench Press', null, 'AMRAP', '@ 50% 1RM · 2~3개 남기고', 1, 2, '백오프 · 1 Set', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 30) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Seated DB Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 31) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Incline DB Bench Press', null, '8', 'Rest 1:30 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 32) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 33) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 34) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 3주차
-- ============================================================

-- 2026-07-20 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 32) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '7', '@ 65% 1RM', 0, 1, '4 Sets', null),
  ('A', 'Back Squat', null, '3', '@ 82.5% 1RM · Rest 2:00', 1, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 33) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Bent Over Row', null, '10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 34) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 35) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Tricep Bench Dip', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 36) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-21 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 35) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Incline DB Bench Press', null, '10', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 36) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Skull Crusher', null, '10~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Fly', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 37) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 38) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 39) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Goblet Squats', null, '15~20', 'Every 2:00 for 5 sets (10 minutes) / Quality', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 40) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 41) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'Diamond Push up + DB Lateral Raise', null, null, 'Rest as needed', 0, 1, '21-15-9 For time', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-22 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 39) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '5', '@ 80% 1RM · Rest 2:30', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 40) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Single Leg RDL', null, '8/8', '한 다리씩 · 천천히', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Rear Delt Fly', null, '15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 41) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 42) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Front Raises', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Lateral Raises', null, '20', null, 1, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Push Press', null, '20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 43) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-23 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 42) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Reverse Lunge', null, '10/10', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 43) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Wide Grip Strict Pull ups', null, '10', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Bent Over DB Row', null, '10~15', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 44) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '21''s (7/7/7) Barbell Curls', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('C', '15 KB Curls', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 스킬', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 45) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 코어', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 46) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-24 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 45) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '8', '@ 70% 1RM', 0, 1, '4 Sets', null),
  ('A', 'Bench Press', null, '3', '@ 82.5% 1RM · Rest 2:00', 1, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 46) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 47) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bench Press', null, '10', 'Climbing', 0, 1, 'Superset · 6 Sets', null),
  ('C', 'DB Bench Flys', null, '20', '* Rest 1:30 between sets', 1, 1, 'Superset · 6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 48) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 49) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Frog Pump', null, '15~20', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Wall Sit Hold', null, '0:30', null, 1, 1, 'Superset · 3 Sets', null),
  ('E', 'Goblet Squats', null, '15~20', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 50) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('F', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 4주차
-- ============================================================

-- 2026-07-27 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 48) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '5', '@ 65% 1RM · 디로드 · Rest 2:00', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 49) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', null, '8', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 50) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 51) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 52) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-28 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 51) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Floor Press', null, '10', '가볍게 · Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 52) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Bench Dips', null, '10~12', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Seated DB Shoulder Press', null, '10~12', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 53) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rolling DB Skull Crusher', null, '25', '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 54) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 55) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Reverse Lunges', null, '15/15', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Toes up DB Romanian Deadlift', null, '15', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 56) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 57) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Lateral Raise', null, '15', '디로드, 가볍게', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-29 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 55) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '5', '@ 65% 1RM · 디로드 · Rest 2:30', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 56) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 57) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 58) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', '15/15 DB Tricep Kickback', null, null, '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 59) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-30 (목) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 58) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', null, '5', '디로드, 가볍게 · Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 59) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '15/15', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Banded Lat Pulldown', null, '30', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 60) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 하체', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 61) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Walking Lunges', null, '20 Steps', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Death March', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 62) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유 (가볍게)', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 63) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', '가볍게 · Rest as needed', 0, 1, '2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-07-31 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 61) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '5', '@ 65% 1RM · 디로드 · Rest 2:00', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 62) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 63) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Chest Fly', null, '12', 'Superset', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '24', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 64) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 65) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 66) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 5주차
-- ============================================================

-- 2026-08-03 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 64) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '3', '웨이브 · @ 76% 1RM', 0, 1, '2 Sets', null),
  ('A', 'Back Squat', null, '2', '웨이브 · @ 82% 1RM', 1, 2, '2 Sets', null),
  ('A', 'Back Squat', null, '1', '웨이브 · @ 88% 1RM · Rest 2:30', 2, 3, '2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 65) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'KB Gorilla Row', null, '10/10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 66) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Extension', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 67) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Front Raises', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Lateral Raises', null, '20', null, 1, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Push Press', null, '20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 68) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-04 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 67) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Standing DB Push Press', null, '8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 68) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Overhead Tricep Extension', null, '10~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Lateral Raise', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 69) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '21''s (7/7/7) Barbell Curls', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('C', '15 KB Curls', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 70) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Tricep Bench Dip', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 71) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Goblet Squats', null, '15~20', 'Every 2:00 for 5 sets (10 minutes) / Quality', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 72) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 73) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Lateral Raise + DB Arnold Press', null, null, 'Rest as needed', 0, 1, '20-18-16-14-12-10', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-05 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 71) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '3', '웨이브 · @ 70% 1RM', 0, 1, '2 Sets', null),
  ('A', 'Deadlift', null, '2', '웨이브 · @ 78% 1RM', 1, 2, '2 Sets', null),
  ('A', 'Deadlift', null, '2', '웨이브 · @ 85% 1RM · Rest 2:30', 2, 3, '2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 72) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Lat Pulldown', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 73) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 74) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 75) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-06 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 74) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Back Rack Lunge', null, '8/8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 75) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Chest Supported DB Row', null, '10', '@ Heaviest Weight of Last Week / Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 76) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 스킬', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 77) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 코어', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 78) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-07 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 77) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '3', '웨이브 · @ 76% 1RM', 0, 1, '2 Sets', null),
  ('A', 'Bench Press', null, '2', '웨이브 · @ 82% 1RM', 1, 2, '2 Sets', null),
  ('A', 'Bench Press', null, '1', '웨이브 · @ 88% 1RM · Rest 2:00', 2, 3, '2 Sets', null),
  ('A', 'Bench Press', null, 'AMRAP', '백오프 · @ 65% 1RM · 2~3개 남기고', 3, 4, '백오프 · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 78) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', null, '10', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Seated DB Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 79) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bench Fly', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'DB Bent Fly', null, '20', null, 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 80) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 81) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Frog Pump', null, '15~20', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Wall Sit Hold', null, '0:30', null, 1, 1, 'Superset · 3 Sets', null),
  ('E', 'Goblet Squats', null, '15~20', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 82) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 6주차
-- ============================================================

-- 2026-08-10 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 80) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '1·1·1', '클러스터 · @ 87.5% 1RM · 렙 사이 15~20초 · Rest 2:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 81) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Single Arm DB Row', null, '12/12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 82) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 83) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 84) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-11 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 83) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', null, '8', 'Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 84) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Ring Push up', null, '8~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Front Raise', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 85) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 86) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 87) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Reverse Lunges', null, '15/15', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Toes up DB Romanian Deadlift', null, '15', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 88) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 89) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'Burpee', null, '100', '도전 주간', 0, 1, '100 reps For time', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-12 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 87) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '1·1·1', '클러스터 · @ 87.5% 1RM · 렙 사이 15~20초 · Rest 2:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 88) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'KB Gorilla Row', null, '10/10', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Band Pull Aparts', null, '20', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 89) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rolling DB Skull Crusher', null, '25', '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 90) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Front Raises', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Lateral Raises', null, '20', null, 1, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Push Press', null, '20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 91) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-13 (목) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 90) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', null, '3', '@ 87.5% 1RM · Rest as needed', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 91) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull ups', null, '15', 'Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 92) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '21''s (7/7/7) Barbell Curls', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('C', '15 KB Curls', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 하체', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 93) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Walking Lunges', null, '20 Steps', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Death March', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 94) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 95) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-14 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 93) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '8', '@ 70% 1RM', 0, 1, '5 Sets', null),
  ('A', 'Bench Press', null, '3', '@ 87.5% 1RM · Rest 2:00', 1, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 94) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 95) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Incline DB Bench Press', null, '8', 'Rest 1:30 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 96) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', '15/15 DB Tricep Kickback', null, null, '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 97) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 98) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 7주차
-- ============================================================

-- 2026-08-17 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 96) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '2', '@ 90% 1RM · Rest 2:00', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 97) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Pendlay Row', null, '8', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 98) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 99) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 100) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-18 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 99) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Bench Press', null, '8', 'Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 100) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Tricep Pushdown', null, '15~20', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Deficit Push up', null, '8~12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 101) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Extension', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 102) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 103) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Goblet Squats', null, '15~20', 'Every 2:00 for 5 sets (10 minutes) / Quality', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 104) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 105) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Overhead Tricep Extension', null, null, '무게↑', 0, 1, 'Climbing 10-8-6-4-2', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-19 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 103) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '2', '@ 90% 1RM · Rest 2:30', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 104) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'DB Rear Delt Fly', null, '15', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 105) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 106) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Tricep Bench Dip', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 107) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-20 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 106) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', null, '8/8', 'Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 107) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '15/15', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Face Pull', null, '20~30', 'Rest 2:00', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 108) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 스킬', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 109) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 코어', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 110) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-21 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 109) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '2', '@ 90% 1RM · Rest 2:00', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 110) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Pendlay Row', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 111) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bench Press', null, '10', 'Climbing', 0, 1, 'Superset · 6 Sets', null),
  ('C', 'DB Bench Flys', null, '20', '* Rest 1:30 between sets', 1, 1, 'Superset · 6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 112) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 113) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Frog Pump', null, '15~20', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Wall Sit Hold', null, '0:30', null, 1, 1, 'Superset · 3 Sets', null),
  ('E', 'Goblet Squats', null, '15~20', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 114) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ============================================================
-- 8주차
-- ============================================================

-- 2026-08-24 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 112) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 113) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Banded Lat Pulldown', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 114) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 115) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Front Raises', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Lateral Raises', null, '20', null, 1, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Push Press', null, '20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 116) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-25 (화) 상체(밀기)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 115) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Incline DB Bench Press', null, '8', '가볍게 · Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 삼두', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 116) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Incline Push up', null, '12~15', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Feet Elevated Push up', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 117) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '21''s (7/7/7) Barbell Curls', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('C', '15 KB Curls', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 삼두', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 118) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 119) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Reverse Lunges', null, '15/15', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Toes up DB Romanian Deadlift', null, '15', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 120) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('G · 피니셔', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 121) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('G', 'DB Lateral Raise', null, '12~15', '가볍게 (테스트주)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-26 (수) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 119) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 후면', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 120) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Chest-Supported DB Row', null, '10', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 어깨', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 121) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 122) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 123) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-27 (목) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 122) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', null, '5', '가볍게, 기술 위주 (금 벤치 1RM 보호) · Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 123) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Wide Grip Strict Pull ups', null, '10', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Bent Over DB Row', null, '10~15', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 124) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rolling DB Skull Crusher', null, '25', '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 하체', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 125) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Walking Lunges', null, '20 Steps', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Death March', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 126) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유 (자유 복습)', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 127) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', '가볍게 · Rest as needed', 0, 1, '2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 2026-08-28 (금) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 125) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bench Press', null, '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 등이두', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 126) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 가슴', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 127) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Chest Fly', null, '12', 'Superset', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '24', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 128) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 하체', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 129) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 130) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
