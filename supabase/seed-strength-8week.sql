-- 8주 스트렝스 공용 프로그램 시드 (2026-07-06 시작, 평일 40세션).
-- 구조: 프로그램 1일 = 섹션(A/B/C/D)별 개별 공용 카드. 일뷰는 workouts 1행당 카드 1개를 렌더하므로
--       하루에 섹션마다 workouts 1행씩(같은 program_date) 발행한다.
-- 적용 전: migration-workout-program.sql 먼저. anon 키로 Supabase SQL editor 실행.
-- 데이터 원본: docs/data/season2-strength-8week-data.md

-- 기존 8주 프로그램 카드 제거 후 재적용. exercises는 cascade 삭제.
delete from workouts where owner_user_id is null and program_label like 'Strength 8주%';
-- 정의 삭제로 끊긴(고아) 프로그램 로그 정리 — 중복 카드 방지(자동 담기 잔재 제거)
delete from workout_logs
  where date between '2026-07-06' and '2026-08-28'
    and workout_exercise_id is null and is_custom = false and template_id is null;
-- 박스 와드(요일 공용, 매일 맨 위)는 유지/복구
update workouts set archived = false where owner_user_id is null and title = '박스 와드';
-- 그 외 레거시 요일반복 공용만 archive (박스 와드 제외, 재실행 안전)
update workouts set archived = true where owner_user_id is null and program_date is null and archived = false and title <> '박스 와드';

-- ============================================================
-- 1주차 — 축적 (7/6 ~ 7/10)
-- ============================================================

-- 2026-07-06 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '5', '@ 75% 1RM · 4~5개 남기기 · Rest 2:00', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-07 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 5) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Side Plank Hip Touch', '10/10', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 6) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Toes to bar', '8', '벅차면 Knee Raises 10개', 0, 1, 'EMOM 8분')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-08 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 7) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '5', '@ 75% 1RM · 4~5개 남기기 · Rest 2:30', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 8) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 9) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:20', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-09 (목) 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 10) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', '8/8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 11) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 12) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Side V ups', '12/12', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-10 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 13) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '5', '@ 75% 1RM · 4~5개 남기기 · Rest 2:00', 0, 1, '4 Sets'),
  ('A', 'Bench Press', 'Max', '45% × Max reps · 1개 남기는 선', 1, 2, '백오프 · 1 Set')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 14) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Barbell Curl', '10', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 15) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '15', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 2주차 — 축적 (7/13 ~ 7/17)
-- ============================================================

-- 2026-07-13 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 16) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '5', '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:00', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 17) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Pendlay Row', '8', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 18) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Serratus Punch (band)', '12', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-14 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 19) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 20) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 21) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Pallof Press', '10/10', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 22) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'DB Arnold Press', null, '무게↑', 0, 1, 'Climbing 12-10-8-6')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-15 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 23) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '5', '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:30', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 24) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', '10', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 25) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:25', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-16 (목) 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 26) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5', '그 주 강도 · 3~4개 남기기 · Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 27) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 28) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', '24', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-17 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 29) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '5', '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:00', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 30) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Seated DB Curl', '12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 31) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Serratus Punch (band)', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '15', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 3주차 — 축적·볼륨 정점 (7/20 ~ 7/24)
-- ============================================================

-- 2026-07-20 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 32) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '5', '@ 80% 1RM · 2~3개 남기기 · Rest 2:00', 0, 1, '5 Sets'),
  ('A', 'Back Squat', 'Max', '45% × Max reps · 1개 남기는 선', 1, 2, '백오프 · 1 Set')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 33) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', '12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'DB Bent Over Row', '10', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 34) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Push ups', '10', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-21 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 35) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '10', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 36) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 37) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Pull Through', '24', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 38) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Toes to bar + Push ups', null, 'Rest as needed', 0, 1, '21-15-9 For time')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-22 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 39) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '5', '@ 80% 1RM · 2~3개 남기기 · Rest 2:30', 0, 1, '5 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 40) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Bent Over Row', '12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 41) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'V ups', '15', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-23 (목) 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 42) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Reverse Lunge', '10/10', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 43) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 44) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Side V ups', '12/12', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-24 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 45) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '5', '@ 80% 1RM · 2~3개 남기기 · Rest 2:00', 0, 1, '5 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 46) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', '12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Hammer Curl', '12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 47) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Push ups', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'Hollow Rock', '15', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 4주차 — 디로드 (7/27 ~ 7/31)
-- ============================================================

-- 2026-07-27 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 48) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '5', '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:00', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 49) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest to bar', '8', 'Rest as needed', 0, 1, 'Superset · 2 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 50) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-28 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 51) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '10', '가볍게 · Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 52) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '10', 'Rest as needed', 0, 1, 'Superset · 2 Sets'),
  ('B', 'Close-grip Push up', '12', 'Rest as needed', 1, 1, 'Superset · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 53) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'DB Side Bend', '12/12', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 54) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'DB Lateral Raise', '15', '디로드, 가볍게', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-29 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 55) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '5', '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:30', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 56) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 0, 1, 'Superset · 2 Sets'),
  ('B', 'Band Pull Aparts', '20', 'Rest as needed', 1, 1, 'Superset · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 57) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:20', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-30 (목) 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 58) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5', '디로드, 가볍게 · 6개+ 남기기 · Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 59) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유 (가볍게)', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-07-31 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 60) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '5', '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:00', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 61) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 2 Sets'),
  ('B', 'Barbell Curl', '10', 'Rest as needed', 1, 1, 'Superset · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 62) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'DB Pullover', '12', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '12', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 5주차 — 강화 (8/3 ~ 8/7)
-- ============================================================

-- 2026-08-03 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 63) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '3', '@ 85% 1RM · 2개 남기기 · Rest 2:00', 0, 1, '5 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 64) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'KB Gorilla Row', '10/10', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 65) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-04 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 66) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 67) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 68) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Single Arm Waiter Hold', '0:30/0:30', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 69) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'DB Bent Row + DB Arnold Press', null, 'Rest as needed', 0, 1, '20-18-16-14-12-10')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-05 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 70) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '3', '@ 85% 1RM · 2개 남기기 · Rest 2:30', 0, 1, '5 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 71) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Pendlay Row', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 72) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:25', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-06 (목) 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 73) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Barbell Back Rack Lunge', '8/8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 74) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 75) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', '24', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-07 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 76) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '3', '@ 85% 1RM · 2개 남기기 · Rest 2:00', 0, 1, '5 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 77) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', '10', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Seated DB Curl', '12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 78) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '15', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 6주차 — 강화 (8/10 ~ 8/14)
-- ============================================================

-- 2026-08-10 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 79) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '3', '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:00', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 80) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Lat Pulldown', '12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 81) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Serratus Punch (band)', '12', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-11 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 82) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', 'Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 83) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 84) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Bird Dog', '10/10', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 85) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Burpee', '100', '도전 주간', 0, 1, '100 reps For time')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-12 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 86) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '3', '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:30', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 87) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'KB Gorilla Row', '10/10', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Band Pull Aparts', '20', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 88) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'V ups', '15', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-13 (목) 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 89) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '3', '그 주 강도 · 1~2개 남기기 · Rest as needed', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 90) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 91) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Side V ups', '12/12', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-14 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 92) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '3', '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:00', 0, 1, '4 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 93) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 3 Sets'),
  ('B', 'Hammer Curl', '12', 'Rest as needed', 1, 1, 'Superset · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 94) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Serratus Punch (band)', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'Hollow Rock', '15', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 7주차 — 강화·피킹 (8/17 ~ 8/21)
-- ============================================================

-- 2026-08-17 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 95) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '2', '@ 90% 1RM · 1개 남기기 · Rest 2:00', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 96) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Pendlay Row', '8', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 97) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Push ups', '10', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-18 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 98) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 99) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '8~12', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Close-grip Push up', '10~15', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 100) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Band Wood Chop', '12/12', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 101) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'DB Bent Row', null, '무게↑', 0, 1, 'Climbing 10-8-6-4-2')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-19 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 102) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '2', '@ 90% 1RM · 1개 남기기 · Rest 2:30', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 103) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'DB Bent Over Row', '10', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Banded Face Pull', '20', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 104) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:20', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-20 (목) 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 105) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', '8/8', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 106) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 코어', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 107) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', '24', 'Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-21 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 108) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '2', '@ 90% 1RM · 1개 남기기 · Rest 2:00', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 109) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Pendlay Row', '8', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Barbell Curl', '10', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 110) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Feet Elevated Push ups', '0:30', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '12', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 8주차 — 실현 / Find Heavy (8/24 ~ 8/28)
-- ============================================================

-- 2026-08-24 (월) 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 111) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Back Squat', '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 112) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Banded Lat Pulldown', '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 113) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', '0:30', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-25 (화) 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 114) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'DB Hex Press', '8', '가볍게 · Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 115) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Bar/Box Dips', '10', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Close-grip Push up', '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 116) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Side Plank Hip Touch', '10/10', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 피니셔', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 117) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('D', 'Toes to bar + Sit ups', null, 'T2B 8개 + Sit ups 15개 번갈아', 0, 1, 'EMOM 8분')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-26 (수) 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 118) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Deadlift', '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 119) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Single Arm DB Row', '12/12', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Band Pull Aparts', '20', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 120) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Hollow Rock Hold', '0:20', 'Rest as needed', 0, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-27 (목) 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 121) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5', '가볍게, 기술 위주 (금 벤치 1RM 보호) · Rest as needed', 0, 1, '3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 스킬', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 122) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'Skill Practice', null, '역도·짐네스틱 자유 (자유 복습)', 0, 1, null)
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- 2026-08-28 (금) 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 123) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('A', 'Bench Press', '1', 'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'Find Heavy Single')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 124) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull up', '8', 'Rest as needed', 0, 1, 'Superset · 2~3 Sets'),
  ('B', 'Hammer Curl', '12', 'Rest as needed', 1, 1, 'Superset · 2~3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 125) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.* from w, (values
  ('C', 'DB Pullover', '12', 'Rest as needed', 0, 1, '2 Sets'),
  ('C', 'V ups', '12', 'Rest as needed', 1, 1, '2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);
