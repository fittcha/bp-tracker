-- 7주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 6주차 대비 변경: @ Heavier than Week 6, @ Week 6, 세트/렙 변경

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 7;

-- A. DB Bench Press 5 x 6 reps @ Heavier than Week 6 *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '5', '6', 120, '@ Heavier than Week 6 / Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 7;

-- B. 4 Sets: 12 Bench Press (Rest 1:00) / 6 Seated DB Press @ Heavier than Week 6 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '4', '12', 60, '@ Heavier than Week 6 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '4', '6', 120, '@ Heavier than Week 6 / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 7;

-- C. 3 Sets: 12 DB Lateral Raises @ Heavier than Week 6 (Rest 1:00) / 12 Behind the Neck Overhead DB Tricep Extension @ Heavier than Week 6 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'DB Lateral Raises', '3', '12', 60, '@ Heavier than Week 6 / Rest 1:00', 4 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '12', 120, '@ Heavier than Week 6 / Rest 2:00', 5 FROM weeks w WHERE w.week_number = 7;

-- D. For time of: 10-9-8-7-6-5-4-3-2-1 reps, DB Curl to Press / * 0:45 Assault Bike between rounds
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'DB Curl to Press', NULL, NULL, NULL, 'For time of : 10-9-8-7-6-5-4-3-2-1 reps, / * 0:45 Assault Bike between rounds', 6 FROM weeks w WHERE w.week_number = 7;

-- E. 5 sets of: 10 Hollow Rock / 10's Hollow Rock Hold / 10 Tuck ups / 30 Scissor Kicks (15 Each) *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock', '5', '10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock Hold', '5', '10''s', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Tuck ups', '5', '10', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Scissor Kicks (15 Each)', '5', '30', NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 7;

-- F. 10 Sets: 500m @ 5k Pace (From Last Week) *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '500m @ 5k Pace (From Last Week)', '10', NULL, 60, '* Rest 1:00 b/w sets', 11 FROM weeks w WHERE w.week_number = 7;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 7;

-- A. Back Squat 4 x 6 @ Heavier than Week 6 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '6', 120, '@ Heavier than Week 6 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 7;

-- B. Emom 10 minutes: Odd, 12 DB Reverse Lunges / Even, 30's Wall Sit Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Odd, 12 DB Reverse Lunges', NULL, NULL, NULL, 'Emom 10 minutes', 2 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Even, 30''s Wall Sit Hold', NULL, NULL, NULL, NULL, 3 FROM weeks w WHERE w.week_number = 7;

-- C. 6 sets of: 10/10 Bulgarian Split Squat / 10 Good Morning w/ Barbell / 10 Box Jump & Step Down *Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Bulgarian Split Squat', '6', '10/10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Good Morning w/ Barbell', '6', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Box Jump & Step Down', '6', '10', NULL, '* Rest as needed b/w sets', 6 FROM weeks w WHERE w.week_number = 7;

-- D. 4 sets of: 12 Reverse DB Fly / 8/8 Single Arm DB Row / 12 DB Romanian Deadlift *Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Reverse DB Fly', '4', '12', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Single Arm DB Row', '4', '8/8', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'DB Romanian Deadlift', '4', '12', NULL, '* Rest as needed b/w sets', 9 FROM weeks w WHERE w.week_number = 7;

-- E. 3 sets: 10~15 Hollow Rock / 20~30 Russian Twist w/ WB / 10~15 V ups or Tuck ups / 20~30 Alter DB Side Bend *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Rock', '3', '10~15', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Russian Twist w/ WB', '3', '20~30', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups or Tuck ups', '3', '10~15', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Alter DB Side Bend', '3', '20~30', NULL, '* Rest as needed between sets', 13 FROM weeks w WHERE w.week_number = 7;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 7;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 7;

-- A. 5 Sets: 8 Chest Supported DB Row @ Week 6 (Rest 1:00) / 8 Barbell Curl @ Week 6 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '5', '8', 60, '@ Week 6 / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '5', '8', 120, '@ Week 6 / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 7;

-- B. Banded Strict Pull ups 1 x 25 @ Week 6
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '1', '25', NULL, '@ Week 6', 3 FROM weeks w WHERE w.week_number = 7;

-- C. 4 Sets: 15/15 Single Arm DB Row @ Week 6 / 30 Alter Single Arm DB Crossbody Hammer Curl @ Week 6 *Rest 0:30 b/w Movement *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Single Arm DB Row', '4', '15/15', NULL, '@ Week 6', 4 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter Single Arm DB Crossbody Hammer Curl', '4', '30', 120, '@ Week 6 / * Rest 0:30 b/w Movement / * Rest 2:00 b/w Sets', 5 FROM weeks w WHERE w.week_number = 7;

-- D. 5 Sets: 20 Barbell Reverse Curls *Rest as needed b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Barbell Reverse Curls', '5', '20', NULL, '* Rest as needed b/w Sets', 6 FROM weeks w WHERE w.week_number = 7;

-- E. AMRAP 20: 15~25 Cal (Any Machine) / 15~25 V ups or Tuck ups / 10~15 Cal (Any Machine) / 10~15 V ups or Tuck ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '15~25 Cal (Any Machine)', NULL, NULL, NULL, 'AMRAP 20', 7 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '15~25 V ups or Tuck ups', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '10~15 Cal (Any Machine)', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '10~15 V ups or Tuck ups', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 7;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 7;

-- A. Hip Thrust 4 x 8 @ Week 6 *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '8', 120, '@ Week 6 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 7;

-- B. 4 Sets: 10/10 Barbell Reverse Lunges @ Week 6 (Rest 1:00) / 10 DB Romanian Deadlift @ Week 6 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '10/10', 60, '@ Week 6 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '10', 120, '@ Week 6 / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 7;

-- C. 8 sets (0:20 On / 0:10 Off): Max Goblet Heels Elevated Squats
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Goblet Heels Elevated Squats', '8', 'Max', NULL, '(0:20 On / 0:10 Off)', 4 FROM weeks w WHERE w.week_number = 7;

-- D. 4 Sets: 45's Farmer Hold / 15 DB Curls / 8 Strict Pull Ups (Banded) *Rest 1 minutes between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Farmer Hold', '4', '45''s', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'DB Curls', '4', '15', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Strict Pull Ups (Banded)', '4', '8', 60, '* Rest 1 minutes between sets', 7 FROM weeks w WHERE w.week_number = 7;

-- E. 4 sets of: 15~25 Incline Reverse Grip Push ups / 15~20 (GHD) Sit ups / 15 DB Lateral Raises / 10~15 Toes to bar *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Incline Reverse Grip Push ups', '4', '15~25', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '(GHD) Sit ups', '4', '15~20', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'DB Lateral Raises', '4', '15', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Toes to bar', '4', '10~15', NULL, '* Rest as needed between sets', 11 FROM weeks w WHERE w.week_number = 7;

-- F. 4~5 sets: 800m Run @ Moderate / 200m Recovery Run or Walk / No Rest between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '800m Run @ Moderate', '4~5', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '200m Recovery Run or Walk', '4~5', NULL, NULL, 'No Rest between sets', 13 FROM weeks w WHERE w.week_number = 7;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 7;

-- A. Close Grip Bench Press 4 x 8 @ Week 6 / 1 x Max reps @ Heavier than Week 6* No More than 30 reps *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '4', '8', 120, '@ Week 6 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '1', 'Max reps @ Heavier than Week 6', NULL, 'No More than 30 reps', 2 FROM weeks w WHERE w.week_number = 7;

-- B. 4 Sets: 10 Standing DB Press @ Week 6 *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Standing DB Press', '4', '10', 90, '@ Week 6 / Rest 1:30 b/w sets', 3 FROM weeks w WHERE w.week_number = 7;

-- C. Superset 4 Sets: 15 DB Chest Fly @ Week 6 / 30 Banded Tricep Pushdown *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Chest Fly', '4', '15', NULL, 'Superset / @ Week 6', 4 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', '4', '30', 120, '* Rest 2:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 7;

-- D. Superset 4 Sets: 15 Rear Delt Fly @ Week 6 / 15 Lateral Raises @ Week 6 *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', '4', '15', NULL, 'Superset / @ Week 6', 6 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', '4', '15', 120, '@ Week 6 / * Rest 2:00 b/w sets', 7 FROM weeks w WHERE w.week_number = 7;

-- E. E2MOM x 10: 10~15 Push ups / 6~12 V ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Push ups', NULL, '10~15', NULL, 'E2MOM x 10', 8 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'V ups', NULL, '6~12', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 7;

-- F. 4 sets: 30's Weighted Wall Sit Hold / 8/8 Bulgarian Split Squats / 16 Weighted Box Step Ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Weighted Wall Sit Hold', '4', '30''s', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Bulgarian Split Squats', '4', '8/8', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 7;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Weighted Box Step Ups', '4', '16', NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 7;
