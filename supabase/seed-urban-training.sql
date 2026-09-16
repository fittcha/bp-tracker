-- urban 훈련 라이브러리 시드 (운동 탭 '+ urban 훈련' 목록).
-- 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md
-- 출처: urbanwave.global 스토리(D-33·35·37·40) + CrossFit ZEST / @dooyoung_zest_lee 게시물.
--
-- 규칙(반드시 지킬 것):
--   owner_user_id / default_weekday / program_date 가 모두 null  → 요일·날짜 자동담기에서 제외
--   category = 'urban'                                          → 목록 마커
--   sort_order                                                  → 목록 순서(오름차순)
--   세트 수는 set_info 가 운반(sets 컬럼은 null). 같은 set_group + set_info 가 한 묶음.
-- anon 키로 Supabase SQL editor 실행.

-- ===== 다시 넣기 전 정리(멱등) =====
-- 주의: 이미 담아서 기록한 로그가 있으면 workout_exercise_id 가 끊긴다(on delete set null).
-- 목록을 통째로 갈아엎을 때만 쓸 것.
-- delete from workouts
-- where owner_user_id is null and default_weekday is null and program_date is null and category = 'urban';

-- [0] 로우·스키 인터벌 + 코어 (D-33)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('로우·스키 인터벌 + 코어 (D-33)', null, null, 'urban', null, null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Row (Erg)', null, '2:00', null, 0, 1, '3~5 Sets · 2분 on / 1분 off', null),
  (null, 'Ski Erg', null, '2:00', '어반레이스 페이스 · 1분 휴식 · 가급적 5라운드', 1, 1, '3~5 Sets · 2분 on / 1분 off', null),
  (null, 'Crunch', null, '12~15', null, 2, 2, '3~4 Sets', null),
  (null, 'Side Hip Raise', null, '12~15', 'Rest 1 min b/w sets', 3, 2, '3~4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [1] 4스테이션 E5MM 40분 (D-35)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('4스테이션 E5MM 40분 (D-35)', null, null, 'urban', null, null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Row (Erg)', null, '400m', 'Every 5:00 × 8 Sets (40분) · 스테이션 2바퀴', 0, 1, 'Station 1', null),
  (null, 'DB Snatch', null, '20', null, 1, 1, 'Station 1', null),
  (null, 'DB(2) Lunge', null, '20 Steps', null, 2, 1, 'Station 1', null),
  (null, 'Box Jump Over', null, '20', null, 3, 2, 'Station 2', null),
  (null, 'Wallball', null, '40', null, 4, 2, 'Station 2', null),
  (null, 'WB Box Step Over', null, '20', null, 5, 2, 'Station 2', null),
  (null, 'KB Farmers Carry', null, '50m', '5m × 10 reps', 6, 3, 'Station 3 · 3 Rounds', null),
  (null, 'Double Under', null, '50', '또는 Single Under 100', 7, 3, 'Station 3 · 3 Rounds', null),
  (null, 'Ski Erg', null, '400m', null, 8, 4, 'Station 4', null),
  (null, 'Burpee Over the DB', null, '20', 'Facing', 9, 4, 'Station 4', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [2] 슬레드 + 고블릿·고릴라 (D-37)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('슬레드 + 고블릿·고릴라 (D-37)', null, null, 'urban', null, null, 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Run', null, '400m', '또는 아무 머신 2분', 0, 1, 'A · 2 Sets', null),
  (null, 'Sled Pull', null, '50m', null, 1, 1, 'A · 2 Sets', null),
  (null, 'Goblet Squat', null, '20', 'Rest 2:00 b/w sets', 2, 1, 'A · 2 Sets', null),
  (null, 'Run', null, '400m', '또는 아무 머신 2분', 3, 2, 'B · 2 Sets', null),
  (null, 'Sled Push', null, '50m', null, 4, 2, 'B · 2 Sets', null),
  (null, 'KB(2) Gorilla Row', null, '20', 'Rest 2:00 b/w sets', 5, 2, 'B · 2 Sets', null),
  (null, 'Run', null, '400m', '또는 아무 머신 2분', 6, 3, '슬레드 없을 때 · 4 Sets', null),
  (null, 'KB(2) Gorilla Row', null, '20', null, 7, 3, '슬레드 없을 때 · 4 Sets', null),
  (null, 'KB(1) Goblet Squat', null, '20', 'Rest 2:00 b/w sets', 8, 3, '슬레드 없을 때 · 4 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [3] 머신 저강도 + 버드독 (D-40)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('머신 저강도 + 버드독 (D-40)', null, null, 'urban', null, null, 3) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Row (Erg)', null, '500m', null, 0, 1, 'A · 3~5 Sets', null),
  (null, 'Ski Erg', null, '500m', null, 1, 1, 'A · 3~5 Sets', null),
  (null, 'Bike Erg', null, '1,000m', 'Effort 60~70% · 고강도 아님', 2, 1, 'A · 3~5 Sets', null),
  (null, 'Bird Dog (alternating)', null, '12~20', 'Rest 1 min b/w sets', 3, 2, 'B · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [4] 스키 인터벌 + 링딥·풀업
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스키 인터벌 + 링딥·풀업', null, null, 'urban', null, null, 4) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Ski Erg', null, '300m', null, 0, 1, '3 Sets', null),
  (null, 'Strict Ring Dips', null, '5', 'Unbroken', 1, 1, '3 Sets', null),
  (null, 'Ski Erg', null, '200m', null, 2, 1, '3 Sets', null),
  (null, '(Banded) Strict Pull ups', null, '10', 'Unbroken', 3, 1, '3 Sets', null),
  (null, 'Ski Erg', null, '100m', null, 4, 1, '3 Sets', null),
  (null, 'Alter DB Renegade Row', null, '10', '1 REP = Right Row + Left Row + Push up', 5, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [5] 머신 EMOM 30분 (Row·Bike·Ski)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('머신 EMOM 30분 (Row·Bike·Ski)', null, null, 'urban', null, null, 5) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Row (Erg)', null, '12 cal', '1분씩 순환 · 10라운드', 0, 1, 'EMOM × 30', null),
  (null, 'Assault Bike', null, '8 cal', null, 1, 1, 'EMOM × 30', null),
  (null, 'Ski Erg', null, '10 cal', null, 2, 1, 'EMOM × 30', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- [6] 머신 인터벌 AMRAP 6 × 3
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('머신 인터벌 AMRAP 6 × 3', null, null, 'urban', null, null, 6) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  (null, 'Run', null, '400m', null, 0, 1, 'AMRAP 6 · ①', null),
  (null, 'Assault Bike', null, '1,200m', null, 1, 1, 'AMRAP 6 · ①', null),
  (null, 'Ski Erg', null, 'Max Meter', 'Rest 2:00', 2, 1, 'AMRAP 6 · ①', null),
  (null, 'Assault Bike', null, '1,200m', null, 3, 2, 'AMRAP 6 · ②', null),
  (null, 'Ski Erg', null, '400m', null, 4, 2, 'AMRAP 6 · ②', null),
  (null, 'Run', null, 'Max Meter', 'Rest 2:00', 5, 2, 'AMRAP 6 · ②', null),
  (null, 'Ski Erg', null, '400m', null, 6, 3, 'AMRAP 6 · ③', null),
  (null, 'Run', null, '400m', null, 7, 3, 'AMRAP 6 · ③', null),
  (null, 'Assault Bike', null, 'Max Meter', 'Rest 2:00', 8, 3, 'AMRAP 6 · ③', null),
  (null, 'Run', null, '{Max 기록}m', null, 9, 4, 'For Time · Time Cap 8:00', null),
  (null, 'Assault Bike', null, '{Max 기록}m', null, 10, 4, 'For Time · Time Cap 8:00', null),
  (null, 'Ski Erg', null, '{Max 기록}m', '앞 3세트에서 나온 본인 Max 기록 거리로', 11, 4, 'For Time · Time Cap 8:00', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 확인
select w.sort_order, w.title, count(e.id) as 동작수
from workouts w left join workout_exercises e on e.workout_id = w.id
where w.owner_user_id is null and w.default_weekday is null and w.program_date is null and w.category = 'urban'
group by 1, 2 order by 1;
