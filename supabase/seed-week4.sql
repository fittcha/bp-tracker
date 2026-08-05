-- 4주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 3주차 대비 변경: @ Week 1/3 표기, 세트/렙 조정, 일부 운동 변경

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 4;

-- A. DB Bench Press 12-10-8-6 reps, Climbing *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '4', '12-10-8-6', 120, 'Climbing / Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 4;

-- B. 3 Sets: 12 Bench Press @ Week 1 (Rest 1:00) / 10 Seated DB Press (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '3', '12', 60, '@ Week 1 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '3', '10', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 4;

-- C. 3 Sets: 12 DB Lateral Raises (Rest 1:00) / 12 Behind the Neck Overhead DB Tricep Extension (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'DB Lateral Raises', '3', '12', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '12', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 4;

-- D. 3 Sets (0:30 On / 0:30 Off) Max Banded Tricep Extension
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Banded Tricep Extension', '3', 'Max', NULL, '(0:30 On / 0:30 Off)', 6 FROM weeks w WHERE w.week_number = 4;

-- E. 5 sets of: 12~20 Hollow Rock / 12~15 / 12~15 DB Side Bend *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock', '5', '12~20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'DB Side Bend', '5', '12~15 / 12~15', NULL, '* Rest as needed between sets', 8 FROM weeks w WHERE w.week_number = 4;

-- F. 3 Sets: 8:00 Row / 3:00 Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Row', '3', '8:00', 180, '3:00 Rest', 9 FROM weeks w WHERE w.week_number = 4;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 4;

-- A. Back Squat 5x10 @ Week 1 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '5', '10', 120, '@ Week 1 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 4;

-- B. 4 Sets: 10 Barbell Back Rack Lunges (Alternating) @ Week 3 (Rest 1:00) / 10 Hip Thrust (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Back Rack Lunges', '4', '10 (Alternating)', 60, '@ Week 3 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Hip Thrust', '4', '10', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 4;

-- C. 4 sets of: 10~15 Incline Reverse Grip Push ups / 10~15 DB Romanian Deadlift / 20~30 Band Pull Apart *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Incline Reverse Grip Push ups', '4', '10~15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Romanian Deadlift', '4', '10~15', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Band Pull Apart', '4', '20~30', NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 4;

-- D. 6 sets of: 10/10 Bulgarian Split Squat / 10 Good Morning w/ Barbell *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Bulgarian Split Squat', '6', '10/10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Good Morning w/ Barbell', '6', '10', NULL, '* Rest as needed between sets', 8 FROM weeks w WHERE w.week_number = 4;

-- E. 3 Sets: 10~15 V ups / 0:20~0:30 Hollow Hold / 10/10 Side Plank Hip Touch
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups', '3', '10~15', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Hold', '3', '0:20~0:30', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Side Plank Hip Touch', '3', '10/10', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 4;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 4;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 4;

-- A. 5 Sets: 8 Chest Supported DB Row @ Week 3 (Rest 1:00) / 8 Barbell Curl @ Week 3 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '5', '8', 60, '@ Week 3 / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '5', '8', 120, '@ Week 3 / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 4;

-- B. Banded Strict Pull ups 3x20 @ Week 1 *Rest 3:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '3', '20', 180, '@ Week 1 / Rest 3:00 b/w Sets', 3 FROM weeks w WHERE w.week_number = 4;

-- C. 4 Sets: 15 Rear Delt Fly / 20 DB Hammer Curls (Rest 1:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Rear Delt Fly', '4', '15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Hammer Curls', '4', '20', 60, 'Rest 1:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 4;

-- D. 3 Sets: Empty Barbell Curls - 7 Full reps / 7 Bottom to Half reps / 7 Half to Top reps *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Empty Barbell Curls - Full reps', '3', '7', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Empty Barbell Curls - Bottom to Half reps', '3', '7', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Empty Barbell Curls - Half to Top reps', '3', '7', 120, '* Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 4;

-- E. 4 sets: 8 Sumo Deadlift High Pulls / 16 Alternating DB(2) Lunges (Holding DB in Each Hand) / 12 Target Burpees *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'Sumo Deadlift High Pulls', '4', '8', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'Alternating DB(2) Lunges (Holding DB in Each Hand)', '4', '16', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'Target Burpees', '4', '12', NULL, '* Rest as needed between sets', 11 FROM weeks w WHERE w.week_number = 4;

-- F. 3 sets of: 20 Plank Pull Through / 10/10 Side V ups / 20's Flutter Kick w/ Hollow Rock Hold / 10 V ups or Tuck ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Plank Pull Through', '3', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Side V ups', '3', '10/10', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Flutter Kick w/ Hollow Rock Hold', '3', '20''s', NULL, NULL, 14 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '10 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed between sets', 15 FROM weeks w WHERE w.week_number = 4;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 4;

-- A. Hip Thrust 3x12 *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '3', '12', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 4;

-- B. 4 Sets: 6/6 Barbell Reverse Lunges (Rest 1:00) / 12 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '6/6', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 4;

-- C. 8 sets (0:20 On / 0:10 Off) Air Squats
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Air Squats', '8', 'Max', NULL, '(0:20 On / 0:10 Off)', 4 FROM weeks w WHERE w.week_number = 4;

-- D. Every 3 minutes for 6 sets: 10/10 Bulgarian Split Squats / 6~10 Strict Pull Ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Bulgarian Split Squats', '6', '10/10', NULL, 'Every 3 minutes for 6 sets', 5 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Strict Pull Ups', '6', '6~10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 4;

-- E. 5 sets of: 20's Hollow Rock Hold / 10/10 Side V ups / 5~10 Toes to bar / 10/10 DB Side Bent *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Hollow Rock Hold', '5', '20''s', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Side V ups', '5', '10/10', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Toes to bar', '5', '5~10', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'DB Side Bent', '5', '10/10', NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 4;

-- F. 5 Sets: 200m Run @ Fast / 400m Recovery Run *Faster than Last Week
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '200m Run @ Fast', '5', NULL, NULL, '* Faster than Last Week', 11 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '400m Recovery Run', '5', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 4;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 4;

-- A. Close Grip Bench Press 12-10-8-6 reps, Climbing *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '4', '12-10-8-6', 120, 'Climbing / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 4;

-- B. 4 Sets: 8 Standing DB Press *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', '8 Standing DB Press', '4', NULL, 90, 'Rest 1:30 b/w sets', 2 FROM weeks w WHERE w.week_number = 4;

-- C. Superset 4 Sets: 12 DB Chest Fly / 24 Banded Tricep Pushdown *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Chest Fly', '4', '12', NULL, 'Superset', 3 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', '4', '24', 90, '* Rest 1:30 b/w sets', 4 FROM weeks w WHERE w.week_number = 4;

-- D. Superset 4 Sets: 12 Rear Delt Fly / 12 Lateral Raises *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', '4', '12', NULL, 'Superset', 5 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', '4', '12', 60, '* Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 4;

-- E. 5~8 sets: 12 DB Bench Press / 12 DB Bent Row / 12 DB Burpees *No Rest between movement *Rest 2:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'DB Bench Press', '5~8', '12', NULL, 'No Rest between movement', 7 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'DB Bent Row', '5~8', '12', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'DB Burpees', '5~8', '12', 120, '* Rest 2:00 between sets', 9 FROM weeks w WHERE w.week_number = 4;

-- F. 5 sets of: 30 Russian Twist / 20's Hollow Rock Hold / 10 Weighted Hanging Knee Raises (No Kipping) *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Russian Twist', '5', '30', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Hollow Rock Hold', '5', '20''s', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 4;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Weighted Hanging Knee Raises (No Kipping)', '5', '10', NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 4;
