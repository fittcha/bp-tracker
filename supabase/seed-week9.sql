-- 9주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 9;

-- A. DB Bench Press 5 x 12 reps, Climbing (Heavier than Last Week) *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '5', '12', 120, 'Climbing / @ Heavier than Last Week / * Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 9;

-- B. 4 Sets: 8~12 Deficit Push ups or Hand-release Push ups (Rest 1:00) / 15~20 Seated DB Lateral Raises (Rest 1:00) / 8~12 Seated DB Press (Rest 1:00) / 15~20 Seated DB Front Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Deficit Push ups or Hand-release Push ups', '4', '8~12', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Lateral Raises', '4', '15~20', 60, 'Rest 1:00', 3 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '4', '8~12', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Front Raises', '4', '15~20', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 9;

-- C. 4 Sets: 25 Rolling DB Skull Crusher *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Rolling DB Skull Crusher', '4', '25', NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 9;

-- D. 5 sets: 15/12 Cal Ski-erg @ Sprint *Rest 1:30 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '15/12 Cal Ski-erg @ Sprint', '5', NULL, 90, '* Rest 1:30 between sets', 7 FROM weeks w WHERE w.week_number = 9;

-- E. 5 sets of: 15 Hollow Rock / 20 Alternating Toe Touches / 10/10 DB Side Bend *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock', '5', '15', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Alternating Toe Touches', '5', '20', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'DB Side Bend', '5', '10/10', NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 9;

-- F. 10 Sets: 500m @ 5k Pace Rest 0:50 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '500m @ 5k Pace', '10', NULL, 50, 'Rest 0:50 between sets', 11 FROM weeks w WHERE w.week_number = 9;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 9;

-- A. Back Squat 4 x 12, Climbing (Heavier than Last Week) *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '12', 120, 'Climbing / @ Heavier than Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 9;

-- B. 3 Sets: 10/10 DB Reverse Lunges / 10 Toes up DB Romanian Deadlift - Heavier than Last Week - *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Reverse Lunges', '3', '10/10', NULL, '@ Heavier than Last Week', 2 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Toes up DB Romanian Deadlift', '3', '10', 90, '@ Heavier than Last Week / * Rest 1:30 b/w sets', 3 FROM weeks w WHERE w.week_number = 9;

-- C. 4 sets of: 20 WB Bear Hug Jumping Squat / 20 Alternating Box Step up Jump *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'WB Bear Hug Jumping Squat', '4', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Alternating Box Step up Jump', '4', '20', NULL, '* Rest as needed between sets', 5 FROM weeks w WHERE w.week_number = 9;

-- D. 5 sets of: 10 Right Arm DB Hang Snatch / 10 Left Arm DB Hang Snatch *Rest as needed between sets *DB: Climbing
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Right Arm DB Hang Snatch', '5', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Left Arm DB Hang Snatch', '5', '10', NULL, '* Rest as needed between sets / * DB : Climbing', 7 FROM weeks w WHERE w.week_number = 9;

-- E. 3 sets: 30 Russian Twist / 15~20 V ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Russian Twist', '3', '30', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups', '3', '15~20', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 9;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 9;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 9;

-- A. 3 Sets: 12 Chest Supported DB Row, Climbing (Rest 1:00) / 12 Barbell Curl @ Light - Heavier than Last Week - (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '3', '12', 60, 'Climbing / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '3', '12', 120, '@ Light / @ Heavier than Last Week / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 9;

-- B. 3 Sets: 15/15 Single Arm DB Row (Rest 1:00) / 30 Banded Lat Pulldown (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Single Arm DB Row', '3', '15/15', 60, 'Rest 1:00', 3 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Lat Pulldown', '3', '30', 120, 'Rest 2:00', 4 FROM weeks w WHERE w.week_number = 9;

-- C. 3 Sets: 12 Seated DB Curls / 24 Alter DB Hammer Curls - Heavier than Last Week - Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Seated DB Curls', '3', '12', NULL, '@ Heavier than Last Week', 5 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter DB Hammer Curls', '3', '24', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 9;

-- D. 3 Sets: 8~10 Feet Elevated Ring Row / 0:30 Max Banded Curls Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Feet Elevated Ring Row', '3', '8~10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '0:30 Max Banded Curls', '3', NULL, 120, 'Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 9;

-- E. For time of: 15-12-9-6-3 DB Curl to Press / V up → - Rest 2:00 - → 4 sets of: 16 Alt DB Raises (같은 E 섹션, __sep__ 구분자로 분리)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Curl to Press', NULL, NULL, NULL, 'For time of : 15-12-9-6-3', 9 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'V up', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '- Rest 2:00 -', NULL, NULL, NULL, '__sep__', 11 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '16 Alternating DB Front Raises (8 Each)', '4', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '16 Alternating DB Lateral Raises (8 Each)', '4', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '16 Alternating DB Shoulder Press (8 Each)', '4', NULL, 90, '* Rest 1:30 between sets', 14 FROM weeks w WHERE w.week_number = 9;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 9;

-- A. Hip Thrust 4 x 10, Climbing *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '10', 120, 'Climbing / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 9;

-- B. 6 sets: 12 DB Front Rack Lunges (Alternating) (6 Each) / 6 High Box Jumps / 45's Weighted Wall Sit Hold *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', '12 DB Front Rack Lunges (Alternating) (6 Each)', '6', NULL, NULL, NULL, 2 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'High Box Jumps', '6', '6', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Weighted Wall Sit Hold', '6', '45''s', NULL, '* Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 9;

-- C. 4 sets: 15 Russian Kettlebell Swings / 15 Goblet Squats / 15 KB Romanian Deadlift *Rest 2:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Russian Kettlebell Swings', '4', '15', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Goblet Squats', '4', '15', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'KB Romanian Deadlift', '4', '15', 120, '* Rest 2:00 between sets', 7 FROM weeks w WHERE w.week_number = 9;

-- D. EMOM 20 (5 Sets): 1 min, 12~24 GHD Sit ups or AB Sit ups / 2 min, 40~80 Double Unders or 60~100 Single Unders / 3 min, 12~20 Cal Row / 4 min, Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '1 min, 12~24 GHD Sit ups or AB Sit ups', NULL, NULL, NULL, 'EMOM 20 (5 Sets)', 8 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '2 min, 40~80 Double Unders or 60~100 Single Unders', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '3 min, 12~20 Cal Row', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '4 min, Rest', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 9;

-- F. For time of: Run 3~5k (E 섹션 없음, 이미지에서 F로 표기)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', 'Run 3~5k', NULL, NULL, NULL, 'For time of :', 12 FROM weeks w WHERE w.week_number = 9;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 9;

-- A. 8 sets of: 5~8 Strict Chest to bar (Pull ups) / 12 DB Push Press *Rest 90 seconds between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Strict Chest to bar (Pull ups)', '8', '5~8', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Push Press', '8', '12', 90, '* Rest 90 seconds between sets', 2 FROM weeks w WHERE w.week_number = 9;

-- B. 5 sets: 20 Alternating DB Curls / 10 Pendlay Row → into → 15 DB Bench Flys / 10 Skull Crushers (같은 B 섹션, into 구분자로 분리)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Alternating DB Curls', '5', '20', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Pendlay Row', '5', '10', NULL, '* Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'into', '5', NULL, NULL, '__sep__', 5 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Bench Flys', '5', '15', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Skull Crushers', '5', '10', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 9;

-- C. 5 sets: 15 Seated DB Press / 15 Seated DB Lateral Raises *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Seated DB Press', '5', '15', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Seated DB Lateral Raises', '5', '15', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 9;

-- D. EMOM 12: 1 min, 30's Hollow Hold / 2 min, 15 V ups / 3 min, 40's Elbow Plank / 4 min, 30 Weighted Russian Twists
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '1 min, 30''s Hollow Hold', NULL, NULL, NULL, 'EMOM 12', 10 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '2 min, 15 V ups', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '3 min, 40''s Elbow Plank', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 9;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '4 min, 30 Weighted Russian Twists', NULL, NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 9;
