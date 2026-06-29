-- 8주 스트렝스 공용 프로그램 시드 (2026-07-06 시작, 평일 40세션).
-- 적용 전: migration-workout-program.sql 먼저. anon 키로 Supabase SQL editor 실행.
-- 매핑 규칙: docs/superpowers/plans/2026-06-28-public-workout-date-program.md (Task 5)
-- 데이터 원본: docs/data/season2-strength-8week-data.md

-- 0) 레거시 요일반복 공용(program_date 없는 공용)은 날짜기반 전환으로 미사용 → archive.
update workouts set archived = true
  where owner_user_id is null and program_date is null and archived = false;

-- ============================================================
-- 1주차 — 축적 (7/6 ~ 7/10)
-- ============================================================

-- W1 · 2026-07-06 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 0)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',                  '5',     '@ 75% 1RM · 4~5개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Banded Strict Chest to bar',  '8',     '이중 점진',                            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Single Arm DB Row',           '12/12', '이중 점진',                            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Shoulder Taps',         '0:30',  '전거근',                               3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W1 · 2026-07-07 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 1)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',         '8',     '이중 점진',                              0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',         '8~12',  null,                                     1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',   '10~15', null,                                     2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Side Plank Hip Touch', '10/10', '항회전 코어',                            3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'Toes to bar',          '8',     '벅차면 Knee Raises 10개 · 오늘의 피니셔',   4, 4, 'D. 피니셔 · EMOM 8분')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W1 · 2026-07-08 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-07-08', 'Strength 8주 · 1주차', 2)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',            '5',     '@ 75% 1RM · 4~5개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Single Arm DB Row',   '12/12', '이중 점진',                            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Banded Face Pull',    '20',    '이중 점진',                            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Hollow Rock Hold',    '0:20',  '코어',                                 3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W1 · 2026-07-09 (목) · 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('단측 하체', null, null, '하체(단측)', '2026-07-09', 'Strength 8주 · 1주차', 3)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bulgarian Split Squat', '8/8',   '이중 점진',                  0, 1, 'A. 메인 · 4 Sets'),
  ('C', 'Skill Practice',        '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Side V ups',            '12/12', '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W1 · 2026-07-10 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-07-10', 'Strength 8주 · 1주차', 4)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',           '5',   '@ 75% 1RM · 4~5개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('A', 'Bench Press (백오프)',   'Max', '45% × Max reps · 1개 남기는 선',       1, 2, 'A. 백오프 · 1 Set'),
  ('B', 'Banded Strict Pull up', '8',   '이중 점진',                            2, 3, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Barbell Curl',          '10',  '이중 점진',                            3, 3, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Shoulder Taps',   '0:30','전거근',                               4, 4, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',                 '15',  '코어',                                 5, 4, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 2주차 — 축적 (7/13 ~ 7/17)
-- ============================================================

-- W2 · 2026-07-13 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-07-13', 'Strength 8주 · 2주차', 5)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',            '5',  '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Banded Strict Pull up', '8',  '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Pendlay Row',           '8',  '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Serratus Punch (band)', '12', '전거근',                                3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W2 · 2026-07-14 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-07-14', 'Strength 8주 · 2주차', 6)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',                            '8',     '이중 점진',                          0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',                            '8~12',  null,                                 1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',                      '10~15', null,                                 2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Pallof Press',                            '10/10', '항회전 코어',                        3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'DB Arnold Press (Climbing 12-10-8-6)',    null,    '무게↑ · 오늘의 피니셔',               4, 4, 'D. 피니셔 · Climbing 12-10-8-6')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W2 · 2026-07-15 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-07-15', 'Strength 8주 · 2주차', 7)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '5',  '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'DB Bent Over Row',  '10', '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Banded Face Pull',  '20', '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Hollow Rock Hold',  '0:25', '코어',                                 3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W2 · 2026-07-16 (목) · 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('오버헤드 프레스', null, null, '상체(오버헤드)', '2026-07-16', 'Strength 8주 · 2주차', 8)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5',     '그 주 강도 · 3~4개 남기기',  0, 1, 'A. 메인 · 4 Sets'),
  ('C', 'Skill Practice',                    '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Russian Twist',                     '24',    '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W2 · 2026-07-17 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-07-17', 'Strength 8주 · 2주차', 9)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',           '5',     '@ 77.5% 1RM · 3~4개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Single Arm DB Row',     '12/12', '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Seated DB Curl',        '12',    '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Serratus Punch (band)', '0:30',  '전거근',                                3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',                 '15',    '코어',                                   4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 3주차 — 축적·볼륨 정점 (7/20 ~ 7/24)
-- ============================================================

-- W3 · 2026-07-20 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-07-20', 'Strength 8주 · 3주차', 10)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',            '5',   '@ 80% 1RM · 2~3개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 5 Sets'),
  ('A', 'Back Squat (백오프)',    'Max', '45% × Max reps · 1개 남기는 선',       1, 2, 'A. 백오프 · 1 Set'),
  ('B', 'Banded Lat Pulldown',   '12',  '이중 점진',                            2, 3, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'DB Bent Over Row',      '10',  '이중 점진',                            3, 3, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Feet Elevated Push ups','10',  '전거근',                               4, 4, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W3 · 2026-07-21 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-07-21', 'Strength 8주 · 3주차', 11)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',                            '10',    '이중 점진',     0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',                            '8~12',  null,            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',                      '10~15', null,            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Pull Through',                      '24',    '항회전 코어',   3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'Toes to bar + Push ups (21-15-9 For time)', null,  '오늘의 피니셔', 4, 4, 'D. 피니셔 · For time')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W3 · 2026-07-22 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-07-22', 'Strength 8주 · 3주차', 12)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',              '5',  '@ 80% 1RM · 2~3개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 5 Sets'),
  ('B', 'Banded Bent Over Row',  '12', '이중 점진',                            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Banded Face Pull',      '20', '이중 점진',                            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'V ups',                 '15', '코어',                                 3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W3 · 2026-07-23 (목) · 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('단측 하체', null, null, '하체(단측)', '2026-07-23', 'Strength 8주 · 3주차', 13)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Reverse Lunge', '10/10', '이중 점진',                  0, 1, 'A. 메인 · 4 Sets'),
  ('C', 'Skill Practice',   '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Side V ups',       '12/12', '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W3 · 2026-07-24 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-07-24', 'Strength 8주 · 3주차', 14)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',         '5',  '@ 80% 1RM · 2~3개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 5 Sets'),
  ('B', 'Banded Lat Pulldown', '12', '이중 점진',                            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Hammer Curl',         '12', '이중 점진',                            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Feet Elevated Push ups', '0:30', '전거근',                          3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'Hollow Rock',         '15', '코어',                                 4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 4주차 — 디로드 (7/27 ~ 7/31)
-- ============================================================

-- W4 · 2026-07-27 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-07-27', 'Strength 8주 · 4주차', 15)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',                 '5',    '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Banded Strict Chest to bar', '8',    '이중 점진',                                   1, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('B', 'Banded Face Pull',           '20',   '이중 점진',                                   2, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('C', 'Plank Shoulder Taps',        '0:30', '전거근',                                      3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W4 · 2026-07-28 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-07-28', 'Strength 8주 · 4주차', 16)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',         '10',    '가볍게 · 이중 점진',          0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Bar/Box Dips',         '10',    null,                          1, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('B', 'Close-grip Push up',   '12',    null,                          2, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('C', 'DB Side Bend',         '12/12', '항회전 코어',                 3, 3, 'C. 안정화 · 2 Sets'),
  ('D', 'DB Lateral Raise (3 sets)', '15', '디로드, 가볍게 · 오늘의 피니셔', 4, 4, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W4 · 2026-07-29 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-07-29', 'Strength 8주 · 4주차', 17)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '5',     '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Single Arm DB Row', '12/12', '이중 점진',                                   1, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('B', 'Band Pull Aparts',  '20',    '이중 점진',                                   2, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('C', 'Hollow Rock Hold',  '0:20',  '코어',                                        3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W4 · 2026-07-30 (목) · 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('오버헤드 프레스', null, null, '상체(오버헤드)', '2026-07-30', 'Strength 8주 · 4주차', 18)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5',     '디로드, 가볍게 · 6개+ 남기기',     0, 1, 'A. 메인 · 3 Sets'),
  ('C', 'Skill Practice',                    '~10분', '역도·짐네스틱 자유 (~10분, 가볍게)', 1, 2, 'C. 스킬')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W4 · 2026-07-31 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-07-31', 'Strength 8주 · 4주차', 19)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',           '5',  '@ 65% 1RM · 디로드, 6개+ 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Banded Strict Pull up', '8',  '이중 점진',                                   1, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('B', 'Barbell Curl',          '10', '이중 점진',                                   2, 2, 'B. 슈퍼셋 · 2 Sets'),
  ('C', 'DB Pullover',           '12', '전거근',                                      3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',                 '12', '코어',                                        4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 5주차 — 강화 (8/3 ~ 8/7)
-- ============================================================

-- W5 · 2026-08-03 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-08-03', 'Strength 8주 · 5주차', 20)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',            '3',     '@ 85% 1RM · 2개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 5 Sets'),
  ('B', 'Banded Strict Pull up', '8',     '이중 점진',                          1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'KB Gorilla Row',        '10/10', '이중 점진',                          2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Shoulder Taps',   '0:30',  '전거근',                             3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W5 · 2026-08-04 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-08-04', 'Strength 8주 · 5주차', 21)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',            '8',         '이중 점진',     0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',            '8~12',      null,            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',      '10~15',     null,            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Single Arm Waiter Hold',  '0:30/0:30', '항회전 코어',   3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'DB Bent Row + DB Arnold Press (20-18-16-14-12-10)', null, '오늘의 피니셔', 4, 4, 'D. 피니셔 · 20-18-16-14-12-10')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W5 · 2026-08-05 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-08-05', 'Strength 8주 · 5주차', 22)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '3',    '@ 85% 1RM · 2개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 5 Sets'),
  ('B', 'Pendlay Row',       '8',    '이중 점진',                          1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Banded Face Pull',  '20',   '이중 점진',                          2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Hollow Rock Hold',  '0:25', '코어',                               3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W5 · 2026-08-06 (목) · 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('단측 하체', null, null, '하체(단측)', '2026-08-06', 'Strength 8주 · 5주차', 23)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Barbell Back Rack Lunge', '8/8',   '이중 점진',                  0, 1, 'A. 메인 · 4 Sets'),
  ('C', 'Skill Practice',          '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Russian Twist',           '24',    '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W5 · 2026-08-07 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-08-07', 'Strength 8주 · 5주차', 24)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',         '3',     '@ 85% 1RM · 2개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 5 Sets'),
  ('B', 'DB Bent Over Row',    '10',    '이중 점진',                          1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Seated DB Curl',      '12',    '이중 점진',                          2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Shoulder Taps', '0:30',  '전거근',                             3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',               '15',    '코어',                               4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 6주차 — 강화 (8/10 ~ 8/14)
-- ============================================================

-- W6 · 2026-08-10 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-08-10', 'Strength 8주 · 6주차', 25)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',            '3',     '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Banded Lat Pulldown',   '12',    '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Single Arm DB Row',     '12/12', '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Serratus Punch (band)', '12',    '전거근',                                 3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W6 · 2026-08-11 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-08-11', 'Strength 8주 · 6주차', 26)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',                  '8',     '이중 점진',                  0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',                  '8~12',  null,                         1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',            '10~15', null,                         2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Bird Dog',                '10/10', '항회전 코어',                3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'Burpee (100 reps For time)',    '100',   '도전 주간 · 오늘의 피니셔',  4, 4, 'D. 피니셔 · For time')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W6 · 2026-08-12 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-08-12', 'Strength 8주 · 6주차', 27)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '3',     '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'KB Gorilla Row',    '10/10', '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Band Pull Aparts',  '20',    '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'V ups',             '15',    '코어',                                   3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W6 · 2026-08-13 (목) · 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('오버헤드 프레스', null, null, '상체(오버헤드)', '2026-08-13', 'Strength 8주 · 6주차', 28)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '3',     '그 주 강도 · 1~2개 남기기',  0, 1, 'A. 메인 · 4 Sets'),
  ('C', 'Skill Practice',                    '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Side V ups',                        '12/12', '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W6 · 2026-08-14 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-08-14', 'Strength 8주 · 6주차', 29)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',           '3',  '@ 87.5% 1RM · 1~2개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Banded Strict Pull up', '8',  '이중 점진',                              1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Hammer Curl',           '12', '이중 점진',                              2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Serratus Punch (band)', '0:30', '전거근',                               3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'Hollow Rock',           '15', '코어',                                   4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 7주차 — 강화·피킹 (8/17 ~ 8/21)
-- ============================================================

-- W7 · 2026-08-17 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-08-17', 'Strength 8주 · 7주차', 30)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',             '2', '@ 90% 1RM · 1개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Banded Strict Pull up',  '8', '이중 점진',                          1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Pendlay Row',            '8', '이중 점진',                          2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Feet Elevated Push ups', '10', '전거근',                            3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W7 · 2026-08-18 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-08-18', 'Strength 8주 · 7주차', 31)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',                       '8',     '이중 점진',     0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Bar/Box Dips',                       '8~12',  null,            1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Close-grip Push up',                 '10~15', null,            2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Band Wood Chop',                     '12/12', '항회전 코어',   3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'DB Bent Row (Climbing 10-8-6-4-2)',  null,    '무게↑ · 오늘의 피니셔', 4, 4, 'D. 피니셔 · Climbing 10-8-6-4-2')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W7 · 2026-08-19 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-08-19', 'Strength 8주 · 7주차', 32)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '2',  '@ 90% 1RM · 1개 남기기 · Rest 2:30', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'DB Bent Over Row',  '10', '이중 점진',                          1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Banded Face Pull',  '20', '이중 점진',                          2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Hollow Rock Hold',  '0:20', '코어',                             3, 3, 'C. 안정화 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W7 · 2026-08-20 (목) · 단측 하체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('단측 하체', null, null, '하체(단측)', '2026-08-20', 'Strength 8주 · 7주차', 33)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bulgarian Split Squat', '8/8',   '이중 점진',                  0, 1, 'A. 메인 · 3 Sets'),
  ('C', 'Skill Practice',        '~10분', '역도·짐네스틱 자유 (~10분)', 1, 2, 'C. 스킬'),
  ('D', 'Russian Twist',         '24',    '코어',                       2, 3, 'D. 피니셔 · 3 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W7 · 2026-08-21 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-08-21', 'Strength 8주 · 7주차', 34)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',            '2',  '@ 90% 1RM · 1개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Pendlay Row',            '8',  '이중 점진',                          1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Barbell Curl',           '10', '이중 점진',                          2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Feet Elevated Push ups', '0:30', '전거근',                           3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',                  '12', '코어',                               4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- ============================================================
-- 8주차 — 실현 / Find Heavy (8/24 ~ 8/28)
-- ============================================================

-- W8 · 2026-08-24 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-08-24', 'Strength 8주 · 8주차', 35)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',          '1',     'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'A. 메인 · Find Heavy Single'),
  ('B', 'Single Arm DB Row',   '12/12', '이중 점진',                                                 1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Banded Lat Pulldown', '12',    '이중 점진',                                                 2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Plank Shoulder Taps', '0:30',  '전거근',                                                    3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W8 · 2026-08-25 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-08-25', 'Strength 8주 · 8주차', 36)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',         '8',     '가볍게 · 이중 점진',          0, 1, 'A. 메인 · 3 Sets'),
  ('B', 'Bar/Box Dips',         '10',    null,                          1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Close-grip Push up',   '12',    null,                          2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Side Plank Hip Touch', '10/10', '항회전 코어',                 3, 3, 'C. 안정화 · 2 Sets'),
  ('D', 'Toes to bar + Sit ups (EMOM 8분)', null, 'T2B 8개 + Sit ups 15개 번갈아 · 오늘의 피니셔', 4, 4, 'D. 피니셔 · EMOM 8분')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W8 · 2026-08-26 (수) · 데드리프트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('데드리프트', null, null, '하체(힌지)', '2026-08-26', 'Strength 8주 · 8주차', 37)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Deadlift',          '1',     'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'A. 메인 · Find Heavy Single'),
  ('B', 'Single Arm DB Row', '12/12', '이중 점진',                                                 1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Band Pull Aparts',  '20',    '이중 점진',                                                 2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'Hollow Rock Hold',  '0:20',  '코어',                                                      3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W8 · 2026-08-27 (목) · 오버헤드 프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('오버헤드 프레스', null, null, '상체(오버헤드)', '2026-08-27', 'Strength 8주 · 8주차', 38)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Barbell Overhead Press (밀리터리)', '5',     '가볍게, 기술 위주 (금 벤치 1RM 보호)',  0, 1, 'A. 메인 · 3 Sets'),
  ('C', 'Skill Practice',                    '~10분', '역도·짐네스틱 자유 (~10분, 자유 복습)', 1, 2, 'C. 스킬')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);

-- W8 · 2026-08-28 (금) · 벤치프레스
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('벤치프레스', null, null, '상체(벤치)', '2026-08-28', 'Strength 8주 · 8주차', 39)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Bench Press',           '1',  'Find Heavy Single · 워밍업 후 점진적으로 1RM · Rest 3:00+', 0, 1, 'A. 메인 · Find Heavy Single'),
  ('B', 'Banded Strict Pull up', '8',  '이중 점진',                                                 1, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('B', 'Hammer Curl',           '12', '이중 점진',                                                 2, 2, 'B. 슈퍼셋 · 2~3 Sets'),
  ('C', 'DB Pullover',           '12', '전거근',                                                    3, 3, 'C. 안정화 · 2 Sets'),
  ('C', 'V ups',                 '12', '코어',                                                      4, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);
