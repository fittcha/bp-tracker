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
update workouts set archived = true
where owner_user_id is null and program_date is null and archived = false and title not in ('WOD', '박스 와드');


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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Single Arm DB Row', null, '12/12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Chest Supported DB Row', null, '10', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Barbell Curl', null, '10', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 런지', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Barbell Reverse Lunges', null, '6/6', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('E', 'DB Romanian Deadlift', null, '12', 'Rest 2:00', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 5) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', null, '8~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Close-grip Push up', null, '10~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 5) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Strict Pull ups', null, '15', 'Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 6) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 7) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 8) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Lateral Raise', null, '15~20', '번아웃 · Rest 0:45', 0, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 8) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 9) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 10) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 힌지', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 11) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 12) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', 'Feet Elevated Ring Row', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', '0:30 Max Banded Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 12) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Pushdown', null, '20', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Alter DB Hammer Curls', null, '20', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 캐리', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 13) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Farmer Hold', null, '45''s', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Curls', null, '15', null, 1, 1, 'Superset · 4 Sets', null),
  ('D', 'Strict Pull Ups (Banded)', null, '8', '* Rest 1 minutes between sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 14) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 15) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 14) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 15) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Curls', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'DB Skull Crusher', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 16) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 17) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 17) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Pendlay Row', null, '8', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 18) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bicep Curls', null, '10', 'Super Set / Unbroken', 0, 1, 'Superset · 5 Sets', null),
  ('C', 'DB Row', null, '20', null, 1, 1, 'Superset · 5 Sets', null),
  ('C', 'Rest as needed', null, null, '__sep__', 2, 1, 'Superset · 5 Sets', null),
  ('C', 'Banded Face Pull', null, '20', 'Super Set / Unbroken', 3, 1, 'Superset · 5 Sets', null),
  ('C', 'Banded Lat Pull downs', null, '20', null, 4, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 19) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Hammer Curls', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 플라이오', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 20) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'WB Bear Hug Jumping Squat', null, '20', null, 0, 1, 'Superset · 4 Sets', null),
  ('E', 'Alternating Box Step up Jump', null, '20', '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 21) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 20) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Diamond Push up', null, '10~15', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Arnold Press', null, '10~12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 21) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Single Arm DB Row', null, '15/15', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Banded Face Pull', null, '20~30', 'Rest 2:00', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 22) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 23) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 24) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Arnold Press', null, null, '무게↑', 0, 1, 'Climbing 12-10-8-6', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 24) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', null, '10', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Band Pull Aparts', null, '20', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 25) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 26) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Z-Press', null, 'Max', '(0:20 On / 0:10 Off)', 0, 1, '8 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 런지', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 27) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Barbell Back Rack Lunges', null, '12 (Alternating)', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 28) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', '250m Row', null, null, 'AMRAP 10~20', 0, 1, null, null),
  ('B', '10 Ring Row', null, null, null, 1, 1, null, null),
  ('B', '250m Row', null, null, null, 2, 1, null, null),
  ('B', '10 Push ups', null, null, null, 3, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 28) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Push Down', null, '20', null, 0, 1, 'Superset · 5 Sets', null),
  ('C', 'DB Farmers Hold Box Step ups', null, '20', '* Rest as needed between sets', 1, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 힌지', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 29) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Romanian Deadlift', null, '10', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 30) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Seated DB Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 31) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', 'Rest 0:45', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bent Over Barbell Row', null, '10~15', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 32) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated Arnold Press', null, '10', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'SA DB Row', null, '10/10', '* Rest as needed between sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 33) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 33) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Bent Over Row', null, '10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 34) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '6 Strict Pull ups', null, '6', 'Every 1:30 for 5~8 Sets', 0, 1, null, null),
  ('C', '9 Push Ups', null, '9', null, 1, 1, null, null),
  ('C', '12 DB Bent Row', null, '12', null, 2, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 35) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Reverse DB Fly', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Single Arm DB Row', null, '8/8', null, 1, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Romanian Deadlift', null, '12', '* Rest as needed b/w sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 캐리', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 36) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', '1:00 DB Overhead Hold', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('E', '30 Alternating DB Side Bend (15/15)', null, null, '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 37) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 36) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Skull Crusher', null, '10~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Fly', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 37) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '(Feet Elevated) Ring Row', null, '10', null, 0, 1, 'Superset · 5 Sets', null),
  ('C', 'Alternating DB Curls', null, '20', '* Rest 1:30 between sets', 1, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 38) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Empty Barbell Curls
- 7 Full reps
- 7 Bottom to Half reps
- 7 Half to Top reps', null, null, '* Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 39) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 40) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Diamond Push up + DB Lateral Raise', null, null, 'Rest as needed', 0, 1, '21-15-9 For time', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 40) returning id
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
  ('C', 'Banded Tricep Extension', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 42) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Face Pull', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Banded Arm Pulldown', null, '20', null, 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 플라이오', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 43) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Odd, 6 Box Jumps + 6 Box Step ups w/ DB(2) Holds', null, null, 'EMOM 12~20 (6~10 Sets)', 0, 1, null, null),
  ('E', 'Even, 24 Russian Twist w/ DB or WB', null, null, null, 1, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 44) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', '0:30 Max DB Bench Press', null, '0:30', 'EMOM 15 (5 Sets)', 0, 1, 'Superset · 5 Sets', null),
  ('B', '0:30 Max Bent Over DB Row', null, '0:30', null, 1, 1, 'Superset · 5 Sets', null),
  ('B', '0:30 Max Cal Row', null, '0:30', null, 2, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 44) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Tricep Bench Dip', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 런지', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 45) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Weighted Lunges', null, '8/8', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Farmers Lunges', null, '20 steps', '* Rest 0:30 b/w Legs / * Rest 2:00 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 46) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 47) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 46) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 47) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 48) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Reverse Bent Fly', null, '12', null, 0, 1, 'Superset · 4~6 Sets', null),
  ('D', 'Bar Dips (Banded)', null, '6~10', null, 1, 1, 'Superset · 4~6 Sets', null),
  ('D', 'Feet Elevated Push ups', null, '8', '* Rest as needed b/w sets', 2, 1, 'Superset · 4~6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 49) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('E', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 49) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', null, '8', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 50) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bent Over Row', null, null, '20-18-16-14-12-10 reps', 0, 1, 'Superset · 6 Sets', null),
  ('C', 'DB Arnold Press', null, null, null, 1, 1, 'Superset · 6 Sets', null),
  ('C', 'Cal Any Machine', null, null, null, 2, 1, 'Superset · 6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 51) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 힌지', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 52) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', '1 Min, 6~10 Good Morning w/ Barbell', null, '1', 'EMOM 20', 0, 1, null, null),
  ('E', '2 Min, 10~15 Hip Thrust w/ Weighted', null, '1', null, 1, 1, null, null),
  ('E', '3 Min, 12~20 Alternating Reverse Lunges w/ DB', null, '1', null, 2, 1, null, null),
  ('E', '4 Min, 0:30 Max Reps Empty Barbell Curls', null, '1', null, 3, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 53) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 52) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Bench Dips', null, '10~12', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Seated DB Shoulder Press', null, '10~12', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 53) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Chest Supported DB Row', null, '10', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Barbell Curl', null, '10', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 54) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Row Machine Curls', null, '30', null, 0, 1, '1 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 55) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 56) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Lateral Raise', null, '15', '디로드, 가볍게', 0, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 56) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 57) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rolling DB Skull Crusher', null, '25', '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 58) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Lateral Raises', null, '12', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 캐리', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 59) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', '20 Steps DB(2) Overhead Walk', null, null, null, 0, 1, 'Superset · 3 Sets', null),
  ('E', '40 Box Step Ups', null, null, null, 1, 1, 'Superset · 3 Sets', null),
  ('E', '20 Steps DB(2) Front Rack Walk', null, null, null, 2, 1, 'Superset · 3 Sets', null),
  ('E', '40 Steps, Lunges', null, null, '* Rest as needed between sets', 3, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 60) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', 'Banded Strict Pull ups', null, '15', 'Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 60) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '15/15 DB Tricep Kickback', null, null, '* Rest as needed between sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 플라이오', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 61) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'WB Bear Hug Jumping Squat', null, '20', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Alternating Box Step up Jump', null, '20', '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 62) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 2 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 63) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Hamstring Curls', null, '25', '* Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 64) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 65) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 65) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'KB Gorilla Row', null, '10/10', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 66) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Ring Row', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Banded Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 67) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 런지', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 68) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Bulgarian Split Squat', null, '10/10', null, 0, 1, 'Superset · 6 Sets', null),
  ('E', 'Good Morning w/ Barbell', null, '10', '* Rest as needed between sets', 1, 1, 'Superset · 6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 69) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 68) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Overhead Tricep Extension', null, '10~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Lateral Raise', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 69) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bicep Curls', null, '10', 'Super Set / Unbroken', 0, 1, 'Superset · 5 Sets', null),
  ('C', 'DB Row', null, '20', null, 1, 1, 'Superset · 5 Sets', null),
  ('C', 'Rest as needed', null, null, '__sep__', 2, 1, 'Superset · 5 Sets', null),
  ('C', 'Banded Face Pull', null, '20', 'Super Set / Unbroken', 3, 1, 'Superset · 5 Sets', null),
  ('C', 'Banded Lat Pull downs', null, '20', null, 4, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 70) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Curl to Press', null, null, 'For time of : 10-9-8-7-6-5-4-3-2-1 reps, / * 0:45 Assault Bike between rounds', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 71) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 72) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Lateral Raise + DB Arnold Press', null, null, 'Rest as needed', 0, 1, '20-18-16-14-12-10', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 72) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Lat Pulldown', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 73) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Strict Pull ups (Banded)', null, '10', null, 0, 1, 'Superset · 4 Sets', null),
  ('C', 'Alter DB Curls', null, '20', null, 1, 1, 'Superset · 4 Sets', null),
  ('C', 'Skull Crushers', null, '10', null, 2, 1, 'Superset · 4 Sets', null),
  ('C', 'Bar dips (Banded) or Deficit Push ups', null, '10', '* Rest as needed between sets', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 74) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Hammer Curls', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 힌지', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 75) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Frog Pump', null, '15~20', null, 0, 1, 'Superset · 3 Sets', null),
  ('E', 'Wall Sit Hold', null, '0:30', null, 1, 1, 'Superset · 3 Sets', null),
  ('E', 'Goblet Squats', null, '15~20', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 76) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', 'Single Arm DB Row', null, '15/15', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Banded Face Pull', null, '20~30', 'Rest 2:00', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 76) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls (Empty)', null, '20~35', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Extensions', null, '35', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Dips', null, '10~20', '* Rest as needed between sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 캐리', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 77) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', '1:00 DB Overhead Hold', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('D', '30 Alternating DB Side Bend (15/15)', null, null, null, 1, 1, 'Superset · 4 Sets', null),
  ('D', '15 DB Curls', null, null, '* Rest as needed b/w sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 78) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 79) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 78) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', null, '10', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Seated DB Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 79) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Seated DB Curls', null, '12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Alter DB Hammer Curls', null, '24', 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 80) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Z-Press', null, 'Max', '(0:20 On / 0:10 Off)', 0, 1, '8 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 81) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 81) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Single Arm DB Row', null, '12/12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 82) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '250m Row', null, null, 'AMRAP 10~20', 0, 1, null, null),
  ('C', '10 Ring Row', null, null, null, 1, 1, null, null),
  ('C', '250m Row', null, null, null, 2, 1, null, null),
  ('C', '10 Push ups', null, null, null, 3, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 83) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated Arnold Press', null, '10', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'SA DB Row', null, '10/10', '* Rest as needed between sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 플라이오', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 84) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Odd, 6 Box Jumps + 6 Box Step ups w/ DB(2) Holds', null, null, 'EMOM 12~20 (6~10 Sets)', 0, 1, null, null),
  ('E', 'Even, 24 Russian Twist w/ DB or WB', null, null, null, 1, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 85) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Russian Twist', null, '30', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 84) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Ring Push up', null, '8~12', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'DB Front Raise', null, '12~15', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 85) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '6 Strict Pull ups', null, '6', 'Every 1:30 for 5~8 Sets', 0, 1, null, null),
  ('C', '9 Push Ups', null, '9', null, 1, 1, null, null),
  ('C', '12 DB Bent Row', null, '12', null, 2, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 86) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Curls', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'DB Skull Crusher', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 87) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 88) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Burpee', null, '100', '도전 주간', 0, 1, '100 reps For time', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 88) returning id
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
  ('C', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 1:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 90) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Reverse DB Fly', null, '12', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Single Arm DB Row', null, '8/8', null, 1, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Romanian Deadlift', null, '12', '* Rest as needed b/w sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 런지', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 91) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Odd, 12 DB Reverse Lunges', null, null, 'Emom 10 minutes', 0, 1, null, null),
  ('E', 'Even, 30''s Wall Sit Hold', null, null, null, 1, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 92) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', '(Feet Elevated) Ring Row', null, '10', null, 0, 1, 'Superset · 5 Sets', null),
  ('B', 'Alternating DB Curls', null, '20', '* Rest 1:30 between sets', 1, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 92) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Pushdown', null, '20', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Alter DB Hammer Curls', null, '20', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 힌지', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 93) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Hip Thrust', null, '12', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 94) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 4 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 95) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Barbell Curls', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Empty Bar Reverse Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 96) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Banded Face Pull', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Banded Arm Pulldown', null, '20', null, 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 97) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 97) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Pendlay Row', null, '8', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 98) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', '0:30 Max DB Bench Press', null, '0:30', 'EMOM 15 (5 Sets)', 0, 1, 'Superset · 5 Sets', null),
  ('C', '0:30 Max Bent Over DB Row', null, '0:30', null, 1, 1, 'Superset · 5 Sets', null),
  ('C', '0:30 Max Cal Row', null, '0:30', null, 2, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 99) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Reverse Bent Fly', null, '12', null, 0, 1, 'Superset · 4~6 Sets', null),
  ('D', 'Bar Dips (Banded)', null, '6~10', null, 1, 1, 'Superset · 4~6 Sets', null),
  ('D', 'Feet Elevated Push ups', null, '8', '* Rest as needed b/w sets', 2, 1, 'Superset · 4~6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 캐리', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 100) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', '45''s Farmer Hold (50/35# DB in each hand)', null, null, null, 0, 1, 'Superset · 4 Sets', null),
  ('E', '15 DB Curls', null, null, null, 1, 1, 'Superset · 4 Sets', null),
  ('E', '8 Strict Pull Ups (Banded)', null, null, '* Rest 1 minutes between sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 101) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Hollow Rock Hold', null, '0:40', null, 0, 1, '3 Sets', null),
  ('F', 'Plank Pull Through', null, '26', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 100) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Tricep Pushdown', null, '15~20', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Deficit Push up', null, '8~12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 101) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Bent Over Row', null, null, '20-18-16-14-12-10 reps', 0, 1, 'Superset · 6 Sets', null),
  ('C', 'DB Arnold Press', null, null, null, 1, 1, 'Superset · 6 Sets', null),
  ('C', 'Cal Any Machine', null, null, null, 2, 1, 'Superset · 6 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 102) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Barbell Curls', null, '8~10', 'Rest 0:45', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Bent Over Barbell Row', null, '10~15', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 103) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('E', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 104) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Overhead Tricep Extension', null, null, '무게↑', 0, 1, 'Climbing 10-8-6-4-2', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 104) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Romanian Deadlift', null, '10', '햄스트링 늘리며 천천히', 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'DB Rear Delt Fly', null, '15', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 105) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Bar Dips (Banded)', null, '9~12', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Bench Dips', null, '9~12', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'Banded Tricep Pushdown', null, '18~24', '* Rest 2:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 106) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', 'Superset', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Lateral Raises', null, '15', '* Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 플라이오', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 107) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'WB Bear Hug Jumping Squat', null, '20', null, 0, 1, 'Superset · 4 Sets', null),
  ('E', 'Alternating Box Step up Jump', null, '20', '* Rest as needed between sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 108) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Single Arm Waiter Hold', null, '0:40/0:40', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', 'Chest Supported DB Row', null, '10', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 108) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Push Down', null, '20', null, 0, 1, 'Superset · 5 Sets', null),
  ('C', 'DB Farmers Hold Box Step ups', null, '20', '* Rest as needed between sets', 1, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 런지', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 109) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Reverse Lunges', null, '15/15', null, 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Toes up DB Romanian Deadlift', null, '15', '* Rest 1:30 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 스킬', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 110) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Skill Practice', null, null, '역도·짐네스틱 자유', 0, 1, null, null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 코어', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 111) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('F', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 110) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Pendlay Row', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Barbell Curl', null, '10', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 111) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Alternating DB Curls', null, '20', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', 'Feet Elevated Ring Row', null, '10', null, 1, 1, 'Superset · 3 Sets', null),
  ('C', 'DB Pullovers', null, '10', null, 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 112) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'DB Lateral Raises', null, '12', 'Rest 1:00', 0, 1, 'Superset · 3 Sets', null),
  ('D', 'Behind the Neck Overhead DB Tricep Extension', null, '12', 'Rest 2:00', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 113) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 113) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', null, '12/12', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Banded Lat Pulldown', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 114) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Strict Pull ups', null, '15', 'Rest 2:00 b/w sets', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 115) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Seated DB Arnold Press', null, '12', 'Rest 1:30 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 힌지', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 116) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'DB Romanian Deadlift', null, '10', 'Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 117) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'V ups', null, '18', null, 0, 1, '3 Sets', null),
  ('F', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 116) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Incline Push up', null, '12~15', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Feet Elevated Push up', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 등', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 117) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Ring Row', null, '8~10', null, 0, 1, 'Superset · 3 Sets', null),
  ('C', '0:30 Max Banded Curls', null, null, 'Rest 2:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 이두', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 118) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Empty Barbell Curls
- 7 Full reps
- 7 Bottom to Half reps
- 7 Half to Top reps', null, null, '* Rest 2:00 b/w sets', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 119) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Flutter Kick w/ Hollow Rock Hold', null, '0:30', null, 0, 1, '3 Sets', null),
  ('E', 'Dead Bug', null, '10/10', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 피니셔', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 120) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'DB Lateral Raise', null, '12~15', '가볍게 (테스트주)', 0, 1, '3 Sets', null)
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
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 120) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Chest-Supported DB Row', null, '10', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 121) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Tricep Extension', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 122) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Deficit Push ups or Hand-release Push ups', null, '8~12', 'Rest 1:00', 0, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Lateral Raises', null, '15~20', 'Rest 1:00', 1, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Press', null, '8~12', 'Rest 1:00', 2, 1, 'Superset · 4 Sets', null),
  ('D', 'Seated DB Front Raises', null, '15~20', 'Rest 2:00', 3, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 캐리', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 123) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'Farmer Hold', null, '45''s', null, 0, 1, 'Superset · 4 Sets', null),
  ('E', 'DB Curls', null, '15', null, 1, 1, 'Superset · 4 Sets', null),
  ('E', 'Strict Pull Ups (Banded)', null, '8', '* Rest 1 minutes between sets', 2, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('F · 안정화', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 124) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('F', 'Side V ups', null, '15/15', null, 0, 1, '3 Sets', null),
  ('F', 'Serratus Punch (band)', null, '15', 'Rest as needed', 1, 1, '3 Sets', null)
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
  ('B', 'DB Bicep Curls', null, '10', 'Super Set / Unbroken', 0, 1, 'Superset · 5 Sets', null),
  ('B', 'DB Row', null, '20', null, 1, 1, 'Superset · 5 Sets', null),
  ('B', 'Rest as needed', null, null, '__sep__', 2, 1, 'Superset · 5 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Super Set / Unbroken', 3, 1, 'Superset · 5 Sets', null),
  ('B', 'Banded Lat Pull downs', null, '20', null, 4, 1, 'Superset · 5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 삼두', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 124) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Tricep Bench Dip', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 플라이오', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 125) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Odd, 6 Box Jumps + 6 Box Step ups w/ DB(2) Holds', null, null, 'EMOM 12~20 (6~10 Sets)', 0, 1, null, null),
  ('D', 'Even, 24 Russian Twist w/ DB or WB', null, null, null, 1, 1, null, null)
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
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 126) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', null, '8', null, 0, 1, 'Superset · 2~3 Sets', null),
  ('B', 'Hammer Curl', null, '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 이두', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 127) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Banded Hammer Curls', null, 'Max', '(0:30 On / 0:30 Off)', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 어깨', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 128) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Rear Delt Fly', null, '15', null, 0, 1, 'Superset · 4 Sets', null),
  ('D', 'DB Hammer Curls', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('E · 안정화', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 129) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('E', 'GHD or AB Sit ups', null, '20', null, 0, 1, '3 Sets', null),
  ('E', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
