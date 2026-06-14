-- 15주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조) — Make Up phase, 06.15~06.20 (촬영 06.20)
-- Day 1~4: 박스 와드 / Day 5: 휴식 또는 ZONE 2 (rest day, 박스 와드 없음 — 이미지 충실)
-- 규칙: feedback_bp_workout_data.md #1~#14 적용
--  - 강도/클린 reps 그룹은 reps 추출, time/distance/cal 혼합 그룹은 numbers를 exercise_name 유지+reps=NULL
--  - EMOM / Every X / For time of / N rounds for time of → 첫 운동 notes에 setInfo 라벨
--  - 같은 섹션 내 서브블록(Followed by / Rest as needed / Rest 3 mins)은 __sep__ 구분자 행
--  - "Super Set / Unbroken"은 그대로 유지 → 앱에서 "N Sets · Super Set / Unbroken" 라벨로 표시
--  - Day1 E "Flutte"는 오타 → 13/14주차 표기 따라 "Flutter"로 정정

-- ============ Day 1 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 15;

-- A. Bench Press 3 x 10, @ 105% of Last Week * Rest 3:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Bench Press', '3', '10', 180, '@ 105% of Last Week / * Rest 3:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 15;

-- B. 3 Sets: 15 DB Hex Press, @ 105% of Last Week (Rest 1:00) / 10~15 DB Lateral Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Hex Press', '3', '15', 60, '@ 105% of Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raises', '3', '10~15', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 15;

-- C. 5 sets of : 10 Right Arm Seated DB Press / 10 Left Arm Seated DB Press / 45's Right Arm Waiter Hold / 45's Left Arm Waiter Hold / 15/15 SA Lateral Raises
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '10 Right Arm Seated DB Press', '5', NULL, NULL, NULL, 4 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '10 Left Arm Seated DB Press', '5', NULL, NULL, NULL, 5 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '45''s Right Arm Waiter Hold', '5', NULL, NULL, NULL, 6 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '45''s Left Arm Waiter Hold', '5', NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '15/15 SA Lateral Raises', '5', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 15;

-- D. EMOM 12~20: Odd, 10~16 Cal Row / Even, 8~12 Burpee over the Rower
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Odd, 10~16 Cal Row', NULL, NULL, NULL, 'EMOM 12~20', 9 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Even, 8~12 Burpee over the Rower', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 15;

-- E. 3 sets of : 26 Plank Pull Through / 14/14 Side V ups / 26's Flutter Kick w/ Hollow Rock Hold / 14 V ups or Tuck ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '26 Plank Pull Through', '3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '14/14 Side V ups', '3', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '26''s Flutter Kick w/ Hollow Rock Hold', '3', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '14 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 15;

-- F. Zone 2 - 40 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 40 minutes', 15 FROM weeks w WHERE w.week_number = 15;


-- ============ Day 2 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 15;

-- A. Back Squat 3 x 8 @ 105% of Last Week * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '3', '8', 120, '@ 105% of Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 15;

-- B. 4 Sets: 12/12 Weighted Lunges (Rest 1:00) / 20 steps, DB Farmers Lunges (* Rest 0:30 b/w Legs, * Rest 2:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Weighted Lunges', '4', '12/12', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Farmers Lunges', '4', '20 steps', 120, '* Rest 0:30 b/w Legs / * Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 15;

-- C. 6~10 sets: 10 DB Bench Press / 10 DB Bent Row / 10 Target Burpees * Rest No More than 1:30 between sets * TEAM 2 - Alternating Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Bench Press', '6~10', '10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Bent Row', '6~10', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Target Burpees', '6~10', '10', NULL, '* Rest No More than 1:30 between sets / * TEAM 2 - Alternating Sets', 6 FROM weeks w WHERE w.week_number = 15;

-- D. 3 sets: 20~35 Barbell Curls (Empty) / 35 Banded Tricep Extensions / 10~20 Dips (Ring or Box) * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Barbell Curls (Empty)', '3', '20~35', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Banded Tricep Extensions', '3', '35', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Dips (Ring or Box)', '3', '10~20', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 15;

-- E. 3 sets: 20 Banded Face Pull / 20 Banded Tricep Pushdown
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Banded Face Pull', '3', '20', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Banded Tricep Pushdown', '3', '20', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 15;

-- F. 3 sets: 20 GHD or AB Sit ups / 15 V ups / 10 Plate Overhead Sit ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', 'GHD or AB Sit ups', '3', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', 'V ups', '3', '15', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', 'Plate Overhead Sit ups', '3', '10', NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 15;

-- G. Zone 2 - 40 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'G', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 40 minutes', 15 FROM weeks w WHERE w.week_number = 15;


-- ============ Day 3 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 15;

-- A. 5 sets of : 10 Right Arm DB Hang Snatch / 10 Left Arm DB Hang Snatch * Rest as needed between sets * DB : Climbing
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Right Arm DB Hang Snatch', '5', '10', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Left Arm DB Hang Snatch', '5', '10', NULL, '* Rest as needed between sets / * DB : Climbing', 2 FROM weeks w WHERE w.week_number = 15;

-- B. Every 1:30 for 6~10 sets: 12 DB Front Rack Box Step ups → Followed by → Emom 5 minutes: 12~15 DB Front Squats
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', '12 DB Front Rack Box Step ups', NULL, NULL, NULL, 'Every 1:30 for 6~10 sets', 3 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Followed by', NULL, NULL, NULL, '__sep__', 4 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', '12~15 DB Front Squats', NULL, NULL, NULL, 'Emom 5 minutes', 5 FROM weeks w WHERE w.week_number = 15;

-- C. 5 sets (Super Set / Unbroken): 10 DB Bicep Curls / 20 DB Row → Rest as needed → 5 sets (Super Set / Unbroken): 20 Banded Face Pull / 20 Banded Lat Pull downs
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Bicep Curls', '5', '10', NULL, 'Super Set / Unbroken', 6 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Row', '5', '20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Rest as needed', NULL, NULL, NULL, '__sep__', 8 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Banded Face Pull', '5', '20', NULL, 'Super Set / Unbroken', 9 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Banded Lat Pull downs', '5', '20', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 15;

-- D. 10 rounds for time of : 250m Row / 15 Side V ups (Right) / 250m Row / 15 Side V ups (Left)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '250m Row', NULL, NULL, NULL, '10 rounds for time of :', 11 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '15 Side V ups (Right)', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '250m Row', NULL, NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '15 Side V ups (Left)', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 15;


-- ============ Day 4 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 15;

-- A. Emom 10 mins: Odd, 10~15 DB Hex Press / Even, 10~16 Alter KB Gorilla Row → Rest 3 mins → Emom 7 mins: 10 DB Push Press / 5~10 DB Push Ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Odd, 10~15 DB Hex Press', NULL, NULL, NULL, 'Emom 10 mins', 1 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Even, 10~16 Alter KB Gorilla Row', NULL, NULL, NULL, NULL, 2 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Rest 3 mins', NULL, NULL, NULL, '__sep__', 3 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', '10 DB Push Press', NULL, NULL, NULL, 'Emom 7 mins', 4 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', '5~10 DB Push Ups', NULL, NULL, NULL, NULL, 5 FROM weeks w WHERE w.week_number = 15;

-- B. 3 sets: 15 Barbell Reverse Grip Row / 12 DB Lateral Raises / 9 DB Hammer Curl to Press
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Grip Row', '3', '15', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Lateral Raises', '3', '12', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 15;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Hammer Curl to Press', '3', '9', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 15;

-- C. Zone 2 - 60 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 60 minutes', 9 FROM weeks w WHERE w.week_number = 15;


-- ============ Day 5 (휴식 또는 ZONE 2 60~90 MINS — rest day) ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', '휴식 또는 ZONE 2', NULL, NULL, NULL, '60~90 MINS', 1 FROM weeks w WHERE w.week_number = 15;
