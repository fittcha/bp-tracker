-- 6주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 5주차 대비 변경: @ Week 3, @ Heavier than Week 5, 세트/렙 변경

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 6;

-- A. DB Bench Press 5 x 8 reps @ Week 3 *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '5', '8', 120, '@ Week 3 / Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 6;

-- B. 4 Sets: 15 Bench Press @ Week 1 (Rest 1:00) / 12 Seated DB Press @ Week 5 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '4', '15', 60, '@ Week 1 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '4', '12', 120, '@ Week 5 / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 6;

-- C. 3 Sets: 15 DB Lateral Raises (Rest 1:00) / 15 Behind the Neck Overhead DB Tricep Extension (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'DB Lateral Raises', '3', '15', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '15', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 6;

-- D. 8 Sets(0:20 On / 0:10 Off) Max DB Z-Press
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'DB Z-Press', '8', 'Max', NULL, '(0:20 On / 0:10 Off)', 6 FROM weeks w WHERE w.week_number = 6;

-- E. 5 sets of: 15 Hollow Rock / 10~20 Alternating Toe Touches / 10/10 DB Side Bend *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock', '5', '15', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Alternating Toe Touches', '5', '10~20', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'DB Side Bend', '5', '10/10', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 6;

-- F. For time of: Row 5,000m
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Row 5,000m', NULL, NULL, NULL, 'For time of', 10 FROM weeks w WHERE w.week_number = 6;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 6;

-- A. Back Squat 4 x 8 @ Week 2 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '8', 120, '@ Week 2 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 6;

-- B. 6 sets of: 10 Right Leg Split Squat / 10 Left Leg Split Squat / 10 DB or Barbell Bent Row @ Heavy *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Right Leg Split Squat', '6', '10', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Left Leg Split Squat', '6', '10', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB or Barbell Bent Row @ Heavy', '6', '10', NULL, '* Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 6;

-- C. 5 sets: 20 DB Reverse Lunges / 10 DB Burpees / 10 DB Hang Squat Clean *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Reverse Lunges', '5', '20', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Burpees', '5', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Hang Squat Clean', '5', '10', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 6;

-- D. 3 sets of: 10 Seated Arnold Press / 10/10 SA DB Row *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Seated Arnold Press', '3', '10', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'SA DB Row', '3', '10/10', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 6;

-- E. 3 Sets: 10~15 V ups / 15/15 Side Plank Rotations *Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups', '3', '10~15', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Side Plank Rotations', '3', '15/15', NULL, '* Rest as needed b/w sets', 11 FROM weeks w WHERE w.week_number = 6;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 6;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 6;

-- A. 5 Sets: 6 Chest Supported DB Row @ Heavier than Week 5 (Rest 1:00) / 8 Barbell Curl @ Heavier than Week 5 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '5', '6', 60, '@ Heavier than Week 5 / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '5', '8', 120, '@ Heavier than Week 5 / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 6;

-- B. Banded Strict Pull ups 1 x 20 @ Lighter than Week 5
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '1', '20', NULL, '@ Lighter than Week 5', 3 FROM weeks w WHERE w.week_number = 6;

-- C. 4 Sets: 12/12 Single Arm DB Row / 20/20 Single Arm DB Crossbody Hammer Curl *Rest 0:30 b/w Movement *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Single Arm DB Row', '4', '12/12', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Single Arm DB Crossbody Hammer Curl', '4', '20/20', 120, '* Rest 0:30 b/w Movement / * Rest 2:00 b/w Sets', 5 FROM weeks w WHERE w.week_number = 6;

-- D. Row Machine Curls 1 x 30 reps
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Row Machine Curls', '1', '30', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 6;

-- E. For time of: 50 DB Bench Fly / 50 DB Bench Press / 50 DB Reverse Bent Fly / 100 Alternating DB Curls / 50 Burpees
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '50 DB Bench Fly', NULL, NULL, NULL, 'For time of', 7 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '50 DB Bench Press', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '50 DB Reverse Bent Fly', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '100 Alternating DB Curls', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '50 Burpees', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 6;

-- F. 5 sets of: 30 Russian Twist / 10 Hanging Knee Raises (No Kipping) *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Russian Twist', '5', '30', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Hanging Knee Raises (No Kipping)', '5', '10', NULL, '* Rest as needed between sets', 13 FROM weeks w WHERE w.week_number = 6;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 6;

-- A. Hip Thrust 4 x 10 @ Heavier than Week 5 *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '10', 120, '@ Heavier than Week 5 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 6;

-- B. 4 Sets: 8/8 Barbell Reverse Lunges @ Heavier than Week 5 (Rest 1:00) / 8 DB Romanian Deadlift @ Heavier than Week 5 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '8/8', 60, '@ Heavier than Week 5 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '8', 120, '@ Heavier than Week 5 / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 6;

-- C. 4 Sets: 25 Banded Hamstring Curls *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Banded Hamstring Curls', '4', '25', 120, '* Rest 2:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 6;

-- D. 5 sets of: 10 DB Row / 10 DB Bench Press / 10 steps, DB Front Rack Lunges / 10 DB Box Step ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'DB Row', '5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'DB Bench Press', '5', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'DB Front Rack Lunges', '5', '10 steps', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'DB Box Step ups', '5', '10', NULL, '* Rest as needed between sets', 8 FROM weeks w WHERE w.week_number = 6;

-- E. 3 sets of: 20 Plank Pull Through / 10/10 Side V ups / 20's Flutte Kick w/ Hollow Rock Hold / 10 V ups or Tuck ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Plank Pull Through', '3', '20', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Side V ups', '3', '10/10', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Flutter Kick w/ Hollow Rock Hold', '3', '20''s', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'V ups or Tuck ups', '3', '10', NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 6;

-- F. 8 sets (32:00): 1:00 Run @ Moderate / 1:00 Run @ Fast / 2:00 Recovery Run / No Rest between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '1:00 Run @ Moderate', '8', NULL, NULL, '(32:00) / No Rest between sets', 13 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '1:00 Run @ Fast', '8', NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '2:00 Recovery Run', '8', NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 6;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 6;

-- A. Close Grip Bench Press 4 x 6 @ The Heaviest Weight of Last Week / 1 x Max reps @ Light (No More than 30 reps) *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '4', '6', 120, '@ The Heaviest Weight of Last Week / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '1', 'Max reps @ Light', NULL, 'No More than 30 reps', 2 FROM weeks w WHERE w.week_number = 6;

-- B. 4 Sets: 8 Standing DB Press @ Heavier than Week 5 *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Standing DB Press', '4', '8', 90, '@ Heavier than Week 5 / Rest 1:30 b/w sets', 3 FROM weeks w WHERE w.week_number = 6;

-- C. Superset 4 Sets: 12 DB Chest Fly @ Heavier than Week 5 / 30 Banded Tricep Pushdown *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Chest Fly', '4', '12', NULL, 'Superset / @ Heavier than Week 5', 4 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', '4', '30', 90, '* Rest 1:30 b/w sets', 5 FROM weeks w WHERE w.week_number = 6;

-- D. Superset 4 Sets: 12 Rear Delt Fly @ Heavier than Week 5 / 12 Lateral Raises @ Heavier than Week 5 *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', '4', '12', NULL, 'Superset / @ Heavier than Week 5', 6 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', '4', '12', 90, '@ Heavier than Week 5 / * Rest 1:30 b/w sets', 7 FROM weeks w WHERE w.week_number = 6;

-- E. 5 rounds (25:00) (30's On / 30's Off): Hollow Rock Hold / Max Push ups / Hollow Rock Hold / Max Push ups / Rest 1:00 *Record: Total reps of Push ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock Hold', '5', '30''s', NULL, '(25:00) / (30''s On / 30''s Off)', 8 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Max Push ups', '5', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock Hold', '5', '30''s', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Max Push ups', '5', NULL, 60, 'Rest 1:00 / * Record: Total reps of Push ups', 11 FROM weeks w WHERE w.week_number = 6;

-- F. 3 sets: 20 Banded Good Mornings / 20~30's Weighted Elbow Plank Hold / 10~15 V ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Banded Good Mornings', '3', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Weighted Elbow Plank Hold', '3', '20~30''s', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 6;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'V ups', '3', '10~15', NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 6;
