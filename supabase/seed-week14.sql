-- 14주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드, 라벨 A~F(Day2는 A~G)로 깔끔 (중복 라벨 없음)
-- 참고:
--  - sets 컬럼은 text → 범위값('3~5','2~3') 저장 (11주차 '4~6' 선례)
--  - 강도/클린 reps 그룹(A~C류)은 reps 추출, time/distance/cal 혼합 그룹은 numbers를 exercise_name에 유지하고 reps=NULL (13주차 Day1 E 선례)
--  - EMOM / Every X / For time of : 등 setInfo는 첫 운동 notes에 그룹 라벨로 기입
--  - Day4 E "Flutte"는 명백한 오타 → 13주차 표기 따라 "Flutter"로 정정

-- ============ Day 1 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 14;

-- A. Bench Press 3 x 15, @ 80% of Last Week * Rest 3:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Bench Press', '3', '15', 180, '@ 80% of Last Week / * Rest 3:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 14;

-- B. 3 Sets: 20 DB Hex Press, @ 80% of Last Week (Rest 1:00) / 10~15 DB Lateral Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Hex Press', '3', '20', 60, '@ 80% of Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raises', '3', '10~15', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 14;

-- C. 3 Sets: 12~15 Bar Dips (Banded) / 12~15 Bench Dips / 20~30 Banded Tricep Pushdown * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bar Dips (Banded)', '3', '12~15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bench Dips', '3', '12~15', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Banded Tricep Pushdown', '3', '20~30', 120, '* Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 14;

-- D. Every 2:30 for 4 Sets: 4~8 Cal Ski-erg Face Pull / 4~8 Cal Ski-erg Tricep Kickback
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '4~8 Cal Ski-erg Face Pull', NULL, NULL, NULL, 'Every 2:30 for 4 Sets', 7 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '4~8 Cal Ski-erg Tricep Kickback', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 14;

-- E. 3 Sets: 20 Heels Over KB / 15 V ups / 0:30 Hollow Rock Hold / 15 Reverse Hypers or GHD Back Extensions * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '20 Heels Over KB', '3', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '15 V ups', '3', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '0:30 Hollow Rock Hold', '3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '15 Reverse Hypers or GHD Back Extensions', '3', NULL, NULL, '* Rest as needed b/w sets', 12 FROM weeks w WHERE w.week_number = 14;

-- F. Every 4:00 x 3: 1:00 Easy Run / 2:00 Moderate Run / 0:30 Hard Run / 0:30 Rest → and then → 3~5 sets: 600m Run @ RPE 7~8 / 2:00 Zone 2 Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '1:00 Easy Run', NULL, NULL, NULL, 'Every 4:00 x 3', 13 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '2:00 Moderate Run', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '0:30 Hard Run', NULL, NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '0:30 Rest', NULL, NULL, NULL, NULL, 16 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'and then,', NULL, NULL, NULL, '__sep__', 17 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '600m Run @ RPE 7~8', '3~5', NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '2:00 Zone 2 Run', '3~5', NULL, NULL, NULL, 19 FROM weeks w WHERE w.week_number = 14;


-- ============ Day 2 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 14;

-- A. Back Squat 3 x 10 @ 80% of Last Week * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '3', '10', 120, '@ 80% of Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 14;

-- B. 4 Sets: 10/10 Weighted Lunges (Rest 1:00) / 20 steps, DB Farmers Lunges (* Rest 0:30 b/w Legs, * Rest 2:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Weighted Lunges', '4', '10/10', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Farmers Lunges', '4', '20 steps', 120, '* Rest 0:30 b/w Legs / * Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 14;

-- C. 4 Sets: 21's (7/7/7) Barbell Curls / 15 KB Curls * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', '21''s (7/7/7) Barbell Curls', '4', NULL, NULL, NULL, 4 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', '15 KB Curls', '4', NULL, NULL, '* Rest as needed between sets', 5 FROM weeks w WHERE w.week_number = 14;

-- D. 3 Sets: 20 Row Machine Curls / 20 Alter Crossbody DB Hammer Curls * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Row Machine Curls', '3', '20', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Alter Crossbody DB Hammer Curls', '3', '20', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 14;

-- E. EMOM 20: 4~6 Cal Assault Bike + 4~6 Burpee to Plate / 20~30 DU or SU + 5~10 Toes to bar ( or Knee Raises)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '4~6 Cal Assault Bike + 4~6 Burpee to Plate', NULL, NULL, NULL, 'EMOM 20', 8 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '20~30 DU or SU + 5~10 Toes to bar ( or Knee Raises)', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 14;

-- F. 5 sets of : 20~30 Alternating Toe Touches / 30's Full Plank Hold * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '20~30 Alternating Toe Touches', '5', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '30''s Full Plank Hold', '5', NULL, NULL, '* Rest as needed between sets', 11 FROM weeks w WHERE w.week_number = 14;

-- G. Zone 2 - 40 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'G', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 40 minutes', 12 FROM weeks w WHERE w.week_number = 14;


-- ============ Day 3 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 14;

-- A. 4 Sets: 10 Behind Neck Press (Rest 1:00) / 10/10 SA DB Row (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Behind Neck Press', '4', '10', 60, 'Rest 1:00', 1 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'SA DB Row', '4', '10/10', 120, 'Rest 2:00', 2 FROM weeks w WHERE w.week_number = 14;

-- B. 3 Sets: 15 Incline Close Grip Bench Press / 20 Reverse Grip Bent Row (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Incline Close Grip Bench Press', '3', '15', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Reverse Grip Bent Row', '3', '20', 120, 'Rest 2:00', 4 FROM weeks w WHERE w.week_number = 14;

-- C. 3 Sets: 10 Banded Wide Grip Strict Pull ups (Rest 1:00) / 20 Alter Chest Supported Seesaw Row Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Banded Wide Grip Strict Pull ups', '3', '10', 60, 'Rest 1:00', 5 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter Chest Supported Seesaw Row', '3', '20', NULL, 'Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 14;

-- D. 3 sets: 20 DB Bench Fly / 20 DB Bent Fly
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'DB Bench Fly', '3', '20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'DB Bent Fly', '3', '20', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 14;

-- E. 4 sets: 30's Wall Sit / 16 Weighted Alternating DB Lunges * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '30''s Wall Sit', '4', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '16 Weighted Alternating DB Lunges', '4', NULL, NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 14;

-- F. 2~3 sets: 1,200m Run @ Moderate / 300m Walk No Rest between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '1,200m Run @ Moderate', '2~3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '300m Walk', '2~3', NULL, NULL, 'No Rest between sets', 12 FROM weeks w WHERE w.week_number = 14;


-- ============ Day 4 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 14;

-- A. Hip Thrust 3 x 9 (80% of Last Week) * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '3', '9', 120, '(80% of Last Week) / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 14;

-- B. 4 Sets: 10/10 Barbell Reverse Lunges (* Rest 0:30 b/w Legs, Rest 1:00) / 12 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '10/10', 60, '* Rest 0:30 b/w Legs / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 14;

-- C. 3 Sets: 20 Alternating DB Curls / 10 Feet Elevated Ring Row / 10 DB Pullovers
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Alternating DB Curls', '3', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Feet Elevated Ring Row', '3', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'DB Pullovers', '3', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 14;

-- D. EMOM 20: 1 Min, 200~300m Row / 2 Min, 10~15 Hand-release Push ups / 3 Min, 10~15 Toes to bar / 4 Min, Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '1 Min, 200~300m Row', NULL, NULL, NULL, 'EMOM 20', 7 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '2 Min, 10~15 Hand-release Push ups', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '3 Min, 10~15 Toes to bar', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '4 Min, Rest', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 14;

-- E. 3 sets of : 30 Plank Pull Through / 15/15 Side V ups / 30's Flutter Kick w/ Hollow Rock Hold / 15 V ups or Tuck ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '30 Plank Pull Through', '3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '15/15 Side V ups', '3', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '30''s Flutter Kick w/ Hollow Rock Hold', '3', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '15 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 14;

-- F. Zone 2 - 40 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 40 minutes', 15 FROM weeks w WHERE w.week_number = 14;


-- ============ Day 5 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 14;

-- A. 3~5 Sets: 10 Push Press, Climbing / 10 Heavy Curls (barbell or DB) / 10 Heavy DB Shrugs / 10 DB Kickbacks * Push Press Climbing * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Push Press, Climbing', '3~5', '10', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Heavy Curls (barbell or DB)', '3~5', '10', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Heavy DB Shrugs', '3~5', '10', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Kickbacks', '3~5', '10', NULL, '* Push Press Climbing / * Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 14;

-- B. 5 sets: 10 Pendlay Row / 20 Alternating DB Curls * Rest as needed
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Pendlay Row', '5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Alternating DB Curls', '5', '20', NULL, '* Rest as needed', 6 FROM weeks w WHERE w.week_number = 14;

-- C. For time of : 100 Shoulder Press / 100 Push Press / 100 Bent Row / 100 Hang Power Clean * w/ 45/35lb or 더 가볍게
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '100 Shoulder Press', NULL, NULL, NULL, 'For time of :', 7 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '100 Push Press', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '100 Bent Row', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '100 Hang Power Clean', NULL, NULL, NULL, '* w/ 45/35lb or 더 가볍게', 10 FROM weeks w WHERE w.week_number = 14;

-- D. 4 Sets: 45's Farmer Hold (50/35# DB in each hand) / 15 DB Curls / 8 Strict Pull Ups (Banded) * Rest 1 minutes between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '45''s Farmer Hold (50/35# DB in each hand)', '4', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '15 DB Curls', '4', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '8 Strict Pull Ups (Banded)', '4', NULL, NULL, '* Rest 1 minutes between sets', 13 FROM weeks w WHERE w.week_number = 14;

-- E. 4 sets of : 15 DB Curls / 15 Skull Crushers / 45's DB Overhead Hold * Rest 2 minutes between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '15 DB Curls', '4', NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '15 Skull Crushers', '4', NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '45''s DB Overhead Hold', '4', NULL, NULL, '* Rest 2 minutes between sets', 16 FROM weeks w WHERE w.week_number = 14;

-- F. Every 2:00 for 10 sets: 15~30's Hollow Rock Hold / 10 Toes to bar ( Knee Raises)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', '15~30''s Hollow Rock Hold', NULL, NULL, NULL, 'Every 2:00 for 10 sets', 17 FROM weeks w WHERE w.week_number = 14;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', '10 Toes to bar ( Knee Raises)', NULL, NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 14;
