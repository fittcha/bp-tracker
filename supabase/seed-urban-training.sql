-- urban 훈련 라이브러리 시드 (운동 탭 '+ urban 훈련' 목록).
-- 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md
--
-- 구조: 훈련 1개 = workouts 1행 + workout_exercises N행.
--   owner_user_id / default_weekday / program_date 가 모두 null 이어야 한다 —
--   이 조합이라야 요일·날짜 자동담기에 안 걸리고 목록으로만 쓰인다.
--   category 는 반드시 'urban' (목록 마커).
--   sort_order = 목록에 보이는 순서.
--   세트 수는 set_info 가 운반한다(sets 컬럼은 null). 같은 set_group + 같은 set_info 가 한 묶음.
--
-- 아래 두 개는 형식을 보여주는 예시다. 실제 훈련으로 바꾸거나 지우고 채워 넣으면 된다.
-- anon 키로 Supabase SQL editor 실행.

-- ===== 다시 넣기 전 정리(멱등) =====
-- 주의: 이미 사용자가 담아서 기록한 로그가 있으면 workout_exercise_id 가 끊긴다(on delete set null).
-- 목록을 통째로 갈아엎을 때만 쓸 것.
-- delete from workouts
-- where owner_user_id is null and default_weekday is null and program_date is null and category = 'urban';

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('Sandbag Carry', null, null, 'urban', null, null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Sandbag Front Carry', null, '50m', null, 0, 1, '3 Rounds · Circuit', null),
  (null, 'Burpee', null, '10', 'Rest 90s b/w rounds', 1, 1, '3 Rounds · Circuit', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('Sled Push / Pull', null, null, 'urban', null, null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Sled Push', null, '20m', null, 0, 1, '5 Sets', null),
  (null, 'Sled Pull', null, '20m', 'Rest 2:00 b/w sets', 1, 1, '5 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 확인
select w.sort_order, w.title, count(e.id) as 동작수
from workouts w left join workout_exercises e on e.workout_id = w.id
where w.owner_user_id is null and w.default_weekday is null and w.program_date is null and w.category = 'urban'
group by 1, 2 order by 1;
