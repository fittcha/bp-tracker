-- 5주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 4주차 대비 변경: @ Week 2/4 표기, 세트/렙 증가, 일부 운동 변경

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 5;

-- A. DB Bench Press 12-10-8-6 reps, Climbing *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '4', '12-10-8-6', 120, 'Climbing / Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 5;

-- B. 3 Sets: 12 Bench Press @ Week 2 (Rest 1:00) / 10 Seated DB Press (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '3', '12', 60, '@ Week 2 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '3', '10', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 5;

-- C. 3 Sets: 15 DB Lateral Raises (Rest 1:00) / 15 Behind the Neck Overhead DB Tricep Extension (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'DB Lateral Raises', '3', '15', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '15', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 5;

-- D. 3 Sets (0:30 On / 0:30 Off) Max Tricep Bench Dip
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Tricep Bench Dip', '3', 'Max', NULL, '(0:30 On / 0:30 Off)', 6 FROM weeks w WHERE w.week_number = 5;

-- E. Emom 10 minutes: 10 Toes to bar or Kipping Leg Raises / Rest as needed / 4 sets: 12/12 Side V ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '10 Toes to bar or Kipping Leg Raises', NULL, NULL, NULL, 'Emom 10 minutes / Rest as needed', 7 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Side V ups', '4', '12/12', NULL, '* Rest as needed between sets', 8 FROM weeks w WHERE w.week_number = 5;

-- F. 12:00 Row / 4:00 Rest / 8:00 Row @ Faster than 12:00 / 2:00 Rest / 4:00 Row @ Faster than 8:00
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Row', '1', '12:00', 240, '4:00 Rest', 9 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Row', '1', '8:00', 120, '@ Faster than 12:00 / 2:00 Rest', 10 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'Row', '1', '4:00', NULL, '@ Faster than 8:00', 11 FROM weeks w WHERE w.week_number = 5;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 5;

-- A. Back Squat 5x12 @ Week 1 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '5', '12', 120, '@ Week 1 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 5;

-- B. 4 Sets: 16 Alternating DB(2) Box Step ups (8 Each) (Rest 1:00) / 8 Hip Thrust (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Alternating DB(2) Box Step ups (8 Each)', '4', '16', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Hip Thrust', '4', '8', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 5;

-- C. Every 2:00 for 5 sets (10 minutes): 15~20 Goblet Squats (Quality)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Goblet Squats', '5', '15~20', NULL, 'Every 2:00 for 5 sets (10 minutes) / Quality', 4 FROM weeks w WHERE w.week_number = 5;

-- D. 4 Sets: 10/10 Single Arm Dumbbell Half Kneeling Press (Rest 30s) / 10/10 Single Arm Dumbbell Row (Rest 30s) / 20 Band Pull Aparts (Rest 90s)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Single Arm Dumbbell Half Kneeling Press', '4', '10/10', 30, 'Rest 30 Seconds', 5 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Single Arm Dumbbell Row', '4', '10/10', 30, 'Rest 30 Seconds', 6 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Band Pull Aparts', '4', '20', 90, 'Rest 90 Seconds', 7 FROM weeks w WHERE w.week_number = 5;

-- E. 3 Sets of: 5 Inchworm to Hollow Back / 20 Alternating Toe Touches / 45's Elbow Plank Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Inchworm to Hollow Back', '3', '5', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Alternating Toe Touches', '3', '20', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Elbow Plank Hold', '3', '45''s', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 5;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 5;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 5;

-- A. 5 Sets: 8 Chest Supported DB Row @ Heavier than Week 3 (Rest 1:00) / 10 Barbell Curl @ Week 3 (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '5', '8', 60, '@ Heavier than Week 3 / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '5', '10', 120, '@ Week 3 / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 5;

-- B. Banded Strict Pull ups 3x25 @ Week 1 *Rest 3:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '3', '25', 180, '@ Week 1 / Rest 3:00 b/w Sets', 3 FROM weeks w WHERE w.week_number = 5;

-- C. 4 Sets: 15 Rear Delt Fly / 20 DB Hammer Curls (Rest 1:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Rear Delt Fly', '4', '15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Hammer Curls', '4', '20', 60, 'Rest 1:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 5;

-- D. 4 Sets (0:30 On / 0:30 Off) Max Banded Hammer Curls
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Banded Hammer Curls', '4', 'Max', NULL, '(0:30 On / 0:30 Off)', 6 FROM weeks w WHERE w.week_number = 5;

-- E. Emom 24 minutes: 1 min, 10 DB Hang Power Clean + 10 DB Push Press / 2 min, 12~15 Box Jump Overs (Step Down) / 3 min, Max Target Burpees / 4 min, Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '1 min, 10 DB Hang Power Clean + 10 DB Push Press', NULL, NULL, NULL, 'Emom 24 minutes', 7 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '2 min, 12~15 Box Jump Overs (Step Down)', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '3 min, Max Target Burpees', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '4 min, Rest', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 5;

-- F. 5 sets: 10 Side V ups (Right) / 10 Side V ups (Left) / 15 Candlestick Toe Touches / 30's Full Plank Hold *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Side V ups (Right)', '5', '10', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Side V ups (Left)', '5', '10', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Candlestick Toe Touches', '5', '15', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Full Plank Hold', '5', '30''s', NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 5;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 5;

-- A. Hip Thrust 4x12 @ Week 4 *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '12', 120, '@ Week 4 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 5;

-- B. 4 Sets: 8/8 Barbell Reverse Lunges @ Week 4 (Rest 1:00) / 12 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '8/8', 60, '@ Week 4 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 5;

-- C. 3 Sets: 15 Goblet Squats / 20 Alternating Box Step up Jump (Rest 2:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Goblet Squats', '3', '15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Alternating Box Step up Jump', '3', '20', 120, 'Rest 2:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 5;

-- D. 6 Sets: 9 Deadlift, Climbing / 15 Deficit Push ups *Rest 1:30 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Deadlift', '6', '9', NULL, 'Climbing', 6 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Deficit Push ups', '6', '15', 90, '* Rest 1:30 between sets', 7 FROM weeks w WHERE w.week_number = 5;

-- E. 5 sets of: 10's Hollow Rock Hold / 10 Hollow Rock / 10 V Ups / 10's Hollow Rock Hold *Rest 1:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Hollow Rock Hold', '5', '10''s', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Hollow Rock', '5', '10', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'V Ups', '5', '10', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Hollow Rock Hold', '5', '10''s', NULL, '* Rest 1:00 b/w Sets', 11 FROM weeks w WHERE w.week_number = 5;

-- F. 5 Sets: 600m Run @ Moderated / 200m Recovery Run *Faster than Last Week
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '600m Run @ Moderated', '5', NULL, NULL, '* Faster than Last Week', 12 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '200m Recovery Run', '5', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 5;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 5;

-- A. Close Grip Bench Press 12-10-8-6 reps, Climbing *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Bench Press', '4', '12-10-8-6', 120, 'Climbing / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 5;

-- B. 4 Sets: 10 Standing DB Press *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', '10 Standing DB Press', '4', '10', 90, 'Rest 1:30 b/w sets', 2 FROM weeks w WHERE w.week_number = 5;

-- C. Superset 4 Sets: 15 DB Chest Fly / 30 Banded Tricep Pushdown *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Chest Fly', '4', '15', NULL, 'Superset', 3 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', '4', '30', 90, '* Rest 1:30 b/w sets', 4 FROM weeks w WHERE w.week_number = 5;

-- D. Superset 4 Sets: 15 Rear Delt Fly / 15 Lateral Raises *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', '4', '15', NULL, 'Superset', 5 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', '4', '15', 90, '* Rest 1:30 b/w sets', 6 FROM weeks w WHERE w.week_number = 5;

-- E. 20-18-16-14-12-10 reps: DB Bent Over Row / DB Arnold Press / Cal Any Machine
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'DB Bent Over Row', '6', NULL, NULL, '20-18-16-14-12-10 reps', 7 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'DB Arnold Press', '6', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Cal Any Machine', '6', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 5;

-- F. 3 sets: 20 Alternating Cossack Squats @ Slow (Rest 1 minute) / 40~60 seconds Full Plank Hold (Rest 2 minute)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Alternating Cossack Squats', '3', '20', 60, '@ Slow / Rest 1 minute', 10 FROM weeks w WHERE w.week_number = 5;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Full Plank Hold', '3', '40~60''s', 120, 'Rest 2 minute', 11 FROM weeks w WHERE w.week_number = 5;
