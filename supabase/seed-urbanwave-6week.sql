-- Urban Wave + CrossFit 6주 추가운동 공용 프로그램 시드 (2026-09-14 시작, 평일 30세션).
-- 원본: '6주 운동 프로그램 짜기/Urban_Wave_6Week_Workout_Program.docx' 를 그대로 옮긴 것(내용 무수정).
-- 구조: 하루 = 카드 4장(A 메인 / B 보조 A / C 보조 B / D 안정화), 같은 program_date.
--   박스 WOD(요일 공용, default_weekday)는 일뷰가 [요일공용 → 날짜프로그램] 순으로 정렬하므로
--   항상 첫 카드로 먼저 나온다 — 별도 처리 불필요.
-- 세트 수는 set_info가 운반(sets 컬럼은 null). 보조/안정화의 Rest는 그룹 마지막 행 notes에.
-- 적용 전: migration-workout-program.sql 먼저. anon 키로 Supabase SQL editor 실행.

-- ===== 정리(wipe): 재적용 전 기존 Urban Wave 카드 제거 (멱등) =====
delete from workouts where owner_user_id is null and program_label like 'Urban Wave 6주%';

-- ==========================================================
-- 1주차
-- ==========================================================

-- 2026-09-14 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-09-14', 'Urban Wave 6주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '5', '@ 70% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-09-14', 'Urban Wave 6주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest-to-Bar', null, '8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'Single-arm DB Row', null, '10/10', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-09-14', 'Urban Wave 6주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Seated DB Curl', null, '10', null, 2, 1, '3 Sets · Circuit', null),
  ('C', 'Alternating DB Hammer Curl', null, '10/10', 'Rest 90s b/w sets', 3, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-09-14', 'Urban Wave 6주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-15 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-09-15', 'Urban Wave 6주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'OHP', null, '6', '@ 65~70% 1RM · Rest 2:00', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-09-15', 'Urban Wave 6주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Arnold Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-09-15', 'Urban Wave 6주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Hammer Curl', null, '10/10', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 60s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-09-15', 'Urban Wave 6주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Arm Bar', null, '6~8/side', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Halo', null, '10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-16 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-09-16', 'Urban Wave 6주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Bench Press', null, '5', '@ 70% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-09-16', 'Urban Wave 6주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Barbell Row', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Hammer Curl', null, '10/10', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-09-16', 'Urban Wave 6주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Overhead Triceps Extension', null, '12', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 75s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-09-16', 'Urban Wave 6주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Pallof Press', null, '10/10', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Hollow Rock', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank', null, '30s/side', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-17 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-09-17', 'Urban Wave 6주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Lunge', null, '8/8', '@ RPE 7 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-09-17', 'Urban Wave 6주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Box Step-up', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Arnold Press', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-09-17', 'Urban Wave 6주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-09-17', 'Urban Wave 6주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '40s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank Rotation', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-18 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-09-18', 'Urban Wave 6주 · 1주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '5', '@ 70% 1RM · Rest 2:00', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-09-18', 'Urban Wave 6주 · 1주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Shoulder Press', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-09-18', 'Urban Wave 6주 · 1주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Hang Clean', null, '8', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '12~15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Curl', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-09-18', 'Urban Wave 6주 · 1주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', null, '16', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Plank Pull-Through', null, '10/10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Suitcase Hold', null, '30s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- ==========================================================
-- 2주차
-- ==========================================================

-- 2026-09-21 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-09-21', 'Urban Wave 6주 · 2주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Front Squat', null, '5', '@ 70% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-09-21', 'Urban Wave 6주 · 2주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull-up', null, '6~8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'Pendlay Row', null, '8', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-09-21', 'Urban Wave 6주 · 2주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Barbell Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-09-21', 'Urban Wave 6주 · 2주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-22 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-09-22', 'Urban Wave 6주 · 2주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Snatch-grip Pull', null, '3', '@ 65~70%', 0, 1, '4 Sets', null),
  ('A', 'Snatch Balance', null, '2', null, 1, 1, '4 Sets', null),
  ('A', 'OHS', null, '2', 'Rest 2:00~2:30', 2, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-09-22', 'Urban Wave 6주 · 2주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Shoulder Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Pull-apart', null, '20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-09-22', 'Urban Wave 6주 · 2주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Skull Crusher', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Curl', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-09-22', 'Urban Wave 6주 · 2주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Turkish Get-up', null, '1/1', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Pallof Press', null, '10/10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank Rotation', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-23 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-09-23', 'Urban Wave 6주 · 2주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Bench Press', null, '8', '@ RPE 7 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-09-23', 'Urban Wave 6주 · 2주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Triceps Pushdown', null, '15~20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-09-23', 'Urban Wave 6주 · 2주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Barbell Curl', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Face Pull', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-09-23', 'Urban Wave 6주 · 2주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Arm Bar', null, '6/6', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Plank Pull-Through', null, '10/10', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-24 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-09-24', 'Urban Wave 6주 · 2주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', null, '8/8', '@ RPE 7 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-09-24', 'Urban Wave 6주 · 2주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Shoulder Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Hammer Curl', null, '10/10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-09-24', 'Urban Wave 6주 · 2주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Curl', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-09-24', 'Urban Wave 6주 · 2주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '40s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Suitcase Hold', null, '30s/side', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Windmill', null, '6/6', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-25 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-09-25', 'Urban Wave 6주 · 2주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '4', '@ 72.5% 1RM · Rest 2:00', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-09-25', 'Urban Wave 6주 · 2주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'KB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-09-25', 'Urban Wave 6주 · 2주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Hang Clean & Press', null, '8', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Band Face Pull', null, '15', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-09-25', 'Urban Wave 6주 · 2주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', null, '16', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank', null, '30s/side', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- ==========================================================
-- 3주차
-- ==========================================================

-- 2026-09-28 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-09-28', 'Urban Wave 6주 · 3주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '4', '@ 75% 1RM', 0, 1, '4 Sets', null),
  ('A', 'Front Squat', null, '5', '@ 65% 1RM · Rest 2:00', 1, 2, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-09-28', 'Urban Wave 6주 · 3주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Strict Pull-up', null, '5~8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'Single-arm DB Row', null, '10/10', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-09-28', 'Urban Wave 6주 · 3주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Hammer Curl', null, '10/10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-09-28', 'Urban Wave 6주 · 3주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-29 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-09-29', 'Urban Wave 6주 · 3주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Push Press', null, '3', '@ 65~70%', 0, 1, '4 Sets', null),
  ('A', 'Push Jerk', null, '2', null, 1, 1, '4 Sets', null),
  ('A', 'Split Jerk', null, '1', 'Rest 2:00', 2, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-09-29', 'Urban Wave 6주 · 3주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Z Press', null, '8~10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'DB Lateral Raise', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-09-29', 'Urban Wave 6주 · 3주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Overhead Triceps Extension', null, '12', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Hammer Curl', null, '10/10', 'Rest 60s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-09-29', 'Urban Wave 6주 · 3주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Windmill', null, '6/6', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Bottom-up Hold', null, '20~30s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-09-30 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-09-30', 'Urban Wave 6주 · 3주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Bench Press', null, '4', '@ 75% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-09-30', 'Urban Wave 6주 · 3주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Pendlay Row', null, '8', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Lateral Raise', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Curl', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-09-30', 'Urban Wave 6주 · 3주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Skull Crusher', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Pull-apart', null, '20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-09-30', 'Urban Wave 6주 · 3주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Hollow Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank Rotation', null, '8/8', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-01 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-10-01', 'Urban Wave 6주 · 3주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Reverse Lunge', null, '10/10', '@ RPE 7 · Rest 1:30', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-10-01', 'Urban Wave 6주 · 3주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-leg DB RDL', null, '8/8', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Barbell Row', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-10-01', 'Urban Wave 6주 · 3주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Shoulder Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'DB Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-10-01', 'Urban Wave 6주 · 3주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '45s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-02 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-10-02', 'Urban Wave 6주 · 3주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '3', '@ 77.5% 1RM · Rest 2:30', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-10-02', 'Urban Wave 6주 · 3주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Arnold Press', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-10-02', 'Urban Wave 6주 · 3주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Close-grip Push-up', null, '10~15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Hammer Curl', null, '10/10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'DB Rear Delt Fly', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-10-02', 'Urban Wave 6주 · 3주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Pallof Press', null, '10/10', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Hollow Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Suitcase Hold', null, '30s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- ==========================================================
-- 4주차
-- ==========================================================

-- 2026-10-05 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-10-05', 'Urban Wave 6주 · 4주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '4', '@ 75% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-10-05', 'Urban Wave 6주 · 4주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Pull-up', null, '6~8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'Barbell Row', null, '10', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-10-05', 'Urban Wave 6주 · 4주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Lateral Raise', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Pull-apart', null, '20', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Seated DB Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-10-05', 'Urban Wave 6주 · 4주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-06 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-10-06', 'Urban Wave 6주 · 4주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'OHP', null, '5', '@ 70~75% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-10-06', 'Urban Wave 6주 · 4주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Arnold Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Pull-apart', null, '20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-10-06', 'Urban Wave 6주 · 4주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Band Triceps Pushdown', null, '15~20', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Barbell Curl', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-10-06', 'Urban Wave 6주 · 4주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Arm Bar', null, '6~8/side', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Halo', null, '10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-07 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-10-07', 'Urban Wave 6주 · 4주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Bench Press', null, '8', '@ RPE 7~8 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-10-07', 'Urban Wave 6주 · 4주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'KB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-10-07', 'Urban Wave 6주 · 4주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Band Triceps Pushdown', null, '15~20', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Curl', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'DB Rear Delt Fly', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-10-07', 'Urban Wave 6주 · 4주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Halo', null, '10', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Pallof Press', null, '10/10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank', null, '30s/side', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-08 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-10-08', 'Urban Wave 6주 · 4주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Lunge', null, '8/8', '@ RPE 7.5 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-10-08', 'Urban Wave 6주 · 4주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Box Step-up', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Z Press', null, '8~10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Pull-apart', null, '20', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-10-08', 'Urban Wave 6주 · 4주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-10-08', 'Urban Wave 6주 · 4주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '45s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank Rotation', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-09 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-10-09', 'Urban Wave 6주 · 4주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '4', '@ 75% 1RM · Rest 2:00', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-10-09', 'Urban Wave 6주 · 4주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'KB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Z Press', null, '8~10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Pull-apart', null, '20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-10-09', 'Urban Wave 6주 · 4주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Hang Clean', null, '8', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '12~15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-10-09', 'Urban Wave 6주 · 4주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', null, '16', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Plank Pull-Through', null, '10/10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- ==========================================================
-- 5주차
-- ==========================================================

-- 2026-10-12 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-10-12', 'Urban Wave 6주 · 5주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Front Squat', null, '4', '@ 75% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-10-12', 'Urban Wave 6주 · 5주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Banded Strict Chest-to-Bar', null, '8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'KB Row', null, '10/10', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-10-12', 'Urban Wave 6주 · 5주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Hammer Curl', null, '10/10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-10-12', 'Urban Wave 6주 · 5주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-13 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-10-13', 'Urban Wave 6주 · 5주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Snatch-grip Pull', null, '2', '@ 70~75%', 0, 1, '5 Sets', null),
  ('A', 'Snatch Balance', null, '2', null, 1, 1, '5 Sets', null),
  ('A', 'OHS', null, '2', 'Rest 2:30', 2, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-10-13', 'Urban Wave 6주 · 5주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Shoulder Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-10-13', 'Urban Wave 6주 · 5주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Skull Crusher', null, '12', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Hammer Curl', null, '10/10', 'Rest 60s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-10-13', 'Urban Wave 6주 · 5주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Turkish Get-up', null, '1/1', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Pallof Press', null, '10/10', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank Rotation', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-14 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-10-14', 'Urban Wave 6주 · 5주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Barbell Bench Press', null, '3', '@ 80% 1RM · Rest 2:00', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-10-14', 'Urban Wave 6주 · 5주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Barbell Row', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Pull-apart', null, '20', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Hammer Curl', null, '10/10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-10-14', 'Urban Wave 6주 · 5주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Floor Press', null, '10~12', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 75s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-10-14', 'Urban Wave 6주 · 5주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Hollow Rock', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank', null, '30s/side', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-15 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-10-15', 'Urban Wave 6주 · 5주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Bulgarian Split Squat', null, '8/8', '@ RPE 7.5~8 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-10-15', 'Urban Wave 6주 · 5주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Goblet Squat', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'DB Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-10-15', 'Urban Wave 6주 · 5주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Shoulder Press', null, '10', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Hammer Curl', null, '10/10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-10-15', 'Urban Wave 6주 · 5주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '45s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Suitcase Hold', null, '30s/side', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Windmill', null, '6/6', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-16 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-10-16', 'Urban Wave 6주 · 5주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '3', '@ 80% 1RM · Rest 2:30', 0, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-10-16', 'Urban Wave 6주 · 5주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Lat Pulldown', null, '12', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-10-16', 'Urban Wave 6주 · 5주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Hang Clean & Press', null, '8', null, 0, 1, '3 Sets · Superset', null),
  ('C', 'Band Pull-apart', null, '20', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-10-16', 'Urban Wave 6주 · 5주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Pallof Press', null, '10/10', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Hollow Rock', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Suitcase Hold', null, '30s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- ==========================================================
-- 6주차
-- ==========================================================

-- 2026-10-19 (월) 하체(스쿼트)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(스쿼트)', '2026-10-19', 'Urban Wave 6주 · 6주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Back Squat', null, '3', '@ 80% 1RM', 0, 1, '4 Sets', null),
  ('A', 'Front Squat', null, '4', '@ 67.5% 1RM · Rest 2:00', 1, 2, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(스쿼트)', '2026-10-19', 'Urban Wave 6주 · 6주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Strict Pull-up', null, '5~8', null, 0, 1, '3 Sets · Superset', null),
  ('B', 'Single-arm DB Row', null, '10/10', 'Rest 90s b/w sets', 1, 1, '3 Sets · Superset', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(스쿼트)', '2026-10-19', 'Urban Wave 6주 · 6주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'DB Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(스쿼트)', '2026-10-19', 'Urban Wave 6주 · 6주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'GHD Back Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('D', 'Hollow Rock', null, '30~40s', null, 1, 1, '3 Sets · Circuit', null),
  ('D', 'Side Plank', null, '30~40s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-20 (화) 상체(오버헤드)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(오버헤드)', '2026-10-20', 'Urban Wave 6주 · 6주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Push Press', null, '2', '@ 70~75%', 0, 1, '5 Sets', null),
  ('A', 'Push Jerk', null, '2', null, 1, 1, '5 Sets', null),
  ('A', 'Split Jerk', null, '1', 'Rest 2:30', 2, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(오버헤드)', '2026-10-20', 'Urban Wave 6주 · 6주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Z Press', null, '8~10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Rear Delt Fly', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(오버헤드)', '2026-10-20', 'Urban Wave 6주 · 6주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Overhead Triceps Extension', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Curl', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(오버헤드)', '2026-10-20', 'Urban Wave 6주 · 6주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Windmill', null, '6/6', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Bottom-up Hold', null, '20~30s/side', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-21 (수) 상체(벤치)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '상체(벤치)', '2026-10-21', 'Urban Wave 6주 · 6주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'DB Bench Press', null, '6~8', '@ RPE 8 · Rest 1:30', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '상체(벤치)', '2026-10-21', 'Urban Wave 6주 · 6주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'DB Curl', null, '10', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '상체(벤치)', '2026-10-21', 'Urban Wave 6주 · 6주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Skull Crusher', null, '12', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Hammer Curl', null, '10/10', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Close-grip Push-up', null, '8~15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '상체(벤치)', '2026-10-21', 'Urban Wave 6주 · 6주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'KB Arm Bar', null, '6/6', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Plank Pull-Through', null, '10/10', 'Rest 60s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-22 (목) 하체(단측)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(단측)', '2026-10-22', 'Urban Wave 6주 · 6주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Reverse Lunge', null, '8/8', '@ RPE 8 · Rest 1:30', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(단측)', '2026-10-22', 'Urban Wave 6주 · 6주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-leg DB RDL', null, '8/8', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Shoulder Press', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(단측)', '2026-10-22', 'Urban Wave 6주 · 6주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Rear Delt Fly', null, '15', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'Band Lat Pulldown', null, '12', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Triceps Pushdown', null, '15~20', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(단측)', '2026-10-22', 'Urban Wave 6주 · 6주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Wall Sit', null, '45s', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'Dead Bug', null, '8/8', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
-- 2026-10-23 (금) 하체(힌지)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · 메인', null, null, '하체(힌지)', '2026-10-23', 'Urban Wave 6주 · 6주차', 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Deadlift', null, '2', '@ 82.5% 1RM · Rest 2:30~3:00', 0, 1, '4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 보조 A', null, null, '하체(힌지)', '2026-10-23', 'Urban Wave 6주 · 6주차', 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Single-arm DB Row', null, '10/10', null, 0, 1, '3 Sets · Circuit', null),
  ('B', 'DB Shoulder Press', null, '10', null, 1, 1, '3 Sets · Circuit', null),
  ('B', 'Band Face Pull', null, '15', 'Rest 75s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 보조 B', null, null, '하체(힌지)', '2026-10-23', 'Urban Wave 6주 · 6주차', 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'DB Hang Clean', null, '8', null, 0, 1, '3 Sets · Circuit', null),
  ('C', 'DB Lateral Raise', null, '12~15', null, 1, 1, '3 Sets · Circuit', null),
  ('C', 'Band Curl', null, '15', 'Rest 90s b/w sets', 2, 1, '3 Sets · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('D · 안정화', null, null, '하체(힌지)', '2026-10-23', 'Urban Wave 6주 · 6주차', 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('D', 'Russian Twist', null, '16', null, 0, 1, '3 Rounds · Circuit', null),
  ('D', 'Side Plank', null, '30s/side', null, 1, 1, '3 Rounds · Circuit', null),
  ('D', 'KB Front Rack Hold', null, '30s', 'Rest 60~75s b/w sets', 2, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
