-- 3주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 2주차 대비 변경: @ Week 2 표기, 세트/렙 조정, 일부 운동 변경

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 3;

-- A. Incline DB Bench Press 5x6 @ Week 2 *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Incline DB Bench Press', '5', '6', 90, '@ Week 2 / Rest 1:30 b/w sets', 1 FROM weeks w WHERE w.week_number = 3;

-- B. 3 Sets: 10 Bench Press @ Week 2 (Rest 1:00) / 12 DB Lateral Raise @ Heavier than Last Week (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '3', '10', 60, '@ Week 2 / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raise', '3', '12', 120, '@ Heavier than Last Week / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 3;

-- C. Behind the Neck Overhead DB Tricep Extension 3x15 Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '15', 60, 'Rest 1:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 3;

-- D. 8 Sets (20's On / 10's Off) Max reps Push ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Push ups', '8', 'Max', NULL, '(20''s On / 10''s Off)', 5 FROM weeks w WHERE w.week_number = 3;

-- E. 5 Sets: 12/12 Side V up / 24 Russian Twist *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Side V up', '5', '12/12', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Russian Twist', '5', '24', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 3;

-- F. 4 Sets 6:00 Row 2:00 Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '6:00 Row', '4', '6:00', 120, '2:00 Rest', 8 FROM weeks w WHERE w.week_number = 3;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 3;

-- A. Back Squat 5x6 @ Week 2 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '5', '6', 120, '@ Week 2 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 3;

-- B. Barbell Back Rack Lunges 3x10 (Alternating) @ Heavier than Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Back Rack Lunges', '3', '10 (Alternating)', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 2 FROM weeks w WHERE w.week_number = 3;

-- C. DB Romanian Deadlift 3x8 @ Heavier than Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Romanian Deadlift', '3', '8', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 3;

-- D. 4 sets of: 12 DB Goblet Squats / 10 Box Jumps & Step Down / 8 Burpee Over DB *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'DB Goblet Squats', '4', '12', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Box Jumps & Step Down', '4', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Burpee Over DB', '4', '8', NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 3;

-- E. 8 Sets (20's On / 10's Off) Max reps Squats
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Squats', '8', 'Max', NULL, '(20''s On / 10''s Off)', 7 FROM weeks w WHERE w.week_number = 3;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 3;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 3;

-- A. Banded Strict Chest to bar 4x10 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Strict Chest to bar', '4', '10', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 3;

-- B. 3 Sets: 8 Chest Supported DB Row @ Heavier than Last Week (Rest 1:00) / 6 Barbell Curl @ Heavier than Last Week (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Chest Supported DB Row', '3', '8', 60, '@ Heavier than Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Barbell Curl', '3', '6', 120, '@ Heavier than Last Week / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 3;

-- C. 3~5 sets (Supersets): 10 DB Bench Press / 10 DB Bent Row / 10 DB Burpees *Rest 2 minute between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Bench Press', '3~5', '10', NULL, 'Supersets', 4 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Bent Row', '3~5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Burpees', '3~5', '10', 120, '* Rest 2 minute between sets', 6 FROM weeks w WHERE w.week_number = 3;

-- D. 5 sets: 5 Renegaded Row or 10 Hand-release Push ups / 20's L-Sit Hold or Hollow Rock Hold / 10~15 GHD Sit ups or AB Sit ups
-- * Renegade Row = 1 Push ups + 1 Right Row + 1 Left Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '5 Renegaded Row or 10 Hand-release Push ups', '5', NULL, NULL, '* Renegade Row = 1 Push ups + 1 Right Row + 1 Left Row', 7 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'L-Sit Hold or Hollow Rock Hold', '5', '20''s', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'GHD Sit ups or AB Sit ups', '5', '10~15', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 3;

-- E. EMOM 20: 1 Min 6~10 Good Morning w/ Barbell / 2 Min 10~15 Hip Thrust w/ Weighted / 3 Min 12~20 Alternating Reverse Lunges w/ DB / 4 Min 0:30 Max Reps Empty Barbell Curls
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '1 Min, 6~10 Good Morning w/ Barbell', NULL, '1', NULL, 'EMOM 20', 10 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '2 Min, 10~15 Hip Thrust w/ Weighted', NULL, '1', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '3 Min, 12~20 Alternating Reverse Lunges w/ DB', NULL, '1', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '4 Min, 0:30 Max Reps Empty Barbell Curls', NULL, '1', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 3;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 3;

-- A. Front Squat 4x6 @ Week 2 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Front Squat', '4', '6', 120, '@ Week 2 / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 3;

-- B. 3 Sets: 8 Bench Press @ Heavier than Last Week (Rest 1:00) / 8 Bent Over Barbell Row @ Heavier than Last Week (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bench Press', '3', '8', 60, '@ Heavier than Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bent Over Barbell Row', '3', '8', 120, '@ Heavier than Last Week / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 3;

-- C. Seated DB Arnold Press 3x15 @ Week 2 Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Seated DB Arnold Press', '3', '15', 90, '@ Week 2 / Rest 1:30 b/w sets', 4 FROM weeks w WHERE w.week_number = 3;

-- D. 5 sets: 10 (Feet Elevated) Ring Row / 20 Alternating DB Curls *Rest 1:30 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '(Feet Elevated) Ring Row', '5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Alternating DB Curls', '5', '20', 90, '* Rest 1:30 between sets', 6 FROM weeks w WHERE w.week_number = 3;

-- E. 3 Sets: 10/10 Side Hip Touches / 20 Alternating Toe Touches Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Side Hip Touches', '3', '10/10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Alternating Toe Touches', '3', '20', 60, 'Rest 1:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 3;

-- F. 5 Sets: 400m Run @ Moderate (Faster) / 200m Recovery Run *Faster than Last Week
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '400m Run @ Moderate (Faster)', '5', NULL, NULL, '* Faster than Last Week', 9 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '200m Recovery Run', '5', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 3;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 3;

-- A. 4 sets: 30's Wall Sit / 8/8 Bulgarian Split Squats / 16 Weighted Alternating DB Lunges *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Wall Sit', '4', '30''s', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bulgarian Split Squats', '4', '8/8', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Weighted Alternating DB Lunges', '4', '16', NULL, '* Rest as needed between sets', 3 FROM weeks w WHERE w.week_number = 3;

-- B. Superset 3 Sets: 10 DB Curls / 20 DB Skull Crusher *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Curls', '3', '10', NULL, 'Superset', 4 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Skull Crusher', '3', '20', 60, '* Rest 1:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 3;

-- C. Superset 3 Sets: 15 Banded Tricep Pushdown / 30 Alter DB Hammer Curls *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', '3', '15', NULL, 'Superset', 6 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Alter DB Hammer Curls', '3', '30', 60, '* Rest 1:00 b/w sets', 7 FROM weeks w WHERE w.week_number = 3;

-- D. Superset 3 Sets: 10 Rear Delt Fly / 15 Lateral Raises *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', '3', '10', NULL, 'Superset', 8 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', '3', '15', 60, '* Rest 1:00 b/w sets', 9 FROM weeks w WHERE w.week_number = 3;

-- E. EMOM 15 (5 Sets): 0:30 Max DB Bench Press / 0:30 Max Bent Over DB Row / 0:30 Max Cal Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max DB Bench Press', '5', '0:30', NULL, 'EMOM 15 (5 Sets)', 10 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max Bent Over DB Row', '5', '0:30', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max Cal Row', '5', '0:30', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 3;

-- F. 5 sets of: 10 Hollow Rock / 10's Hollow Rock Hold / 10/10 DB Side Bend *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Hollow Rock', '5', '10', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Hollow Rock Hold', '5', '10''s', NULL, NULL, 14 FROM weeks w WHERE w.week_number = 3;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'DB Side Bend', '5', '10/10', NULL, '* Rest as needed between sets', 15 FROM weeks w WHERE w.week_number = 3;
