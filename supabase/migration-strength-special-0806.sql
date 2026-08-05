-- 8/6(목)·8/7(금) 스페셜 세션 삽입 (1회성).
-- 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md §5
-- 제서 예선 직후 이틀 — 벤치마크(8/6 Baseline · 8/7 Annie) + 어깨·전거근·코어 보조.
-- program_label = null → 헤더 프로그램 배너 미포함(예선 카드와 동일).
-- !!! 멱등하지 않다 — 두 번 실행하면 카드가 중복 생성된다 !!!
-- 시드(seed-strength-8week.sql)를 처음부터 새로 돌리는 경우엔 이 파일이 필요 없다.
-- anon 키로 Supabase SQL editor 실행.

-- 사전 점검: 0이어야 미적용
select count(*) as already_applied from workouts
where owner_user_id is null and program_date in ('2026-08-06', '2026-08-07');

-- ===== 8/6 (목) =====
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · Baseline', null, null, '측정', '2026-08-06', null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Row (Erg)', null, '500m', '단일 라운드, 쉬지 않고 이어서', 0, 1, 'For Time · 1 Round', null),
  ('A', 'Air Squat', null, '40', null, 1, 1, 'For Time · 1 Round', null),
  ('A', 'Sit ups', null, '30', null, 2, 1, 'For Time · 1 Round', null),
  ('A', 'Push up', null, '20', null, 3, 1, 'For Time · 1 Round', null),
  ('A', 'Pull up', null, '10', '밴드·점핑 대사 가능', 4, 1, 'For Time · 1 Round', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 어깨·전거근', null, null, '측정', '2026-08-06', null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Serratus Punch (band)', null, '15', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 코어', null, null, '측정', '2026-08-06', null, 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Dead Bug', null, '10/10', null, 0, 1, '3 Sets', null),
  ('C', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ===== 8/7 (금) =====
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · Annie', null, null, '측정', '2026-08-07', null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Double Under', null, '50-40-30-20-10', '미숙하면 Single Under ×2로 대사', 0, 1, 'For Time', null),
  ('A', 'Sit ups', null, '50-40-30-20-10', null, 1, 1, 'For Time', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 어깨·전거근', null, null, '측정', '2026-08-07', null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Serratus Punch (band)', null, '15', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Rear Delt Fly', null, '15', null, 1, 1, 'Superset · 3 Sets', null),
  ('B', 'Lateral Raises', null, '15', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '측정', '2026-08-07', null, 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 사후 검증: 8/6·8/7 각 3장, 동작 8/6=9행 · 8/7=6행
select w.program_date, w.sort_order, w.title, count(e.id) as ex
from workouts w left join workout_exercises e on e.workout_id = w.id
where w.owner_user_id is null and w.program_date in ('2026-08-06', '2026-08-07')
group by 1, 2, 3 order by 1, 2;
