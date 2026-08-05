-- 8주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~3: 박스 와드, Day 4~5: FET (CLOSED)

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 8;

-- A. DB Bench Press 5 x 15 reps, Climbing *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '5', '15', 120, 'Climbing / * Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 8;

-- B. 4 Sets: 8~12 Deficit Push ups or Hand-release Push ups (Rest 1:00) / 15~20 Seated DB Lateral Raises (Rest 1:00) / 8~12 Seated DB Press (Rest 1:00) / 15~20 Seated DB Front Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Deficit Push ups or Hand-release Push ups', '4', '8~12', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Lateral Raises', '4', '15~20', 60, 'Rest 1:00', 3 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '4', '8~12', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Front Raises', '4', '15~20', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 8;

-- C. 3 Sets: 20/15 Cal Ski-erg Tricep Extension *Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '20/15 Cal Ski-erg Tricep Extension', '3', NULL, NULL, '* Rest as needed b/w sets', 6 FROM weeks w WHERE w.week_number = 8;

-- D. 5 sets: 10 Hammer Curls / 10 DB Hang Power Clean / 10 DB Bent Row *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Hammer Curls', '5', '10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'DB Hang Power Clean', '5', '10', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'DB Bent Row', '5', '10', NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 8;

-- E. 3 sets of: 20's Hollow Rock Hold / 10~15 Strict Leg Raises / 20 Plank Bird Dog / 10~15 Hollow Rock *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock Hold', '3', '20''s', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Strict Leg Raises', '3', '10~15', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Plank Bird Dog', '3', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Hollow Rock', '3', '10~15', NULL, '* Rest as needed between sets', 13 FROM weeks w WHERE w.week_number = 8;

-- F. 5 Sets: 1,000m @ 5k Pace Rest 2:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '1,000m @ 5k Pace', '5', NULL, 120, 'Rest 2:00 between sets', 14 FROM weeks w WHERE w.week_number = 8;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 8;

-- A. Back Squat 4 x 15, Climbing Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '15', 120, 'Climbing / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 8;

-- B. 3 Sets: 15/15 DB Reverse Lunges / 15 Toes up DB Romanian Deadlift *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Reverse Lunges', '3', '15/15', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Toes up DB Romanian Deadlift', '3', '15', 90, '* Rest 1:30 b/w sets', 3 FROM weeks w WHERE w.week_number = 8;

-- C. 4 sets of: 20 DB(2) Squats / 10 Box Jumps / 8 DB Burpees *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB(2) Squats', '4', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Box Jumps', '4', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Burpees', '4', '8', NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 8;

-- D. 3 sets of: 20 Banded Face Pull / 20 Banded Arm Pulldown
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Banded Face Pull', '3', '20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Banded Arm Pulldown', '3', '20', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 8;

-- E. 3 sets: 0:15 Hollow Rock Hold / 10~15 V ups / 0:10 Hollow Rock Hold *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Rock Hold', '3', '0:15', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups', '3', '10~15', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Rock Hold', '3', '0:10', 120, '* Rest 2:00 b/w sets', 11 FROM weeks w WHERE w.week_number = 8;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 8;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 8;

-- A. 3 Sets: 15 Chest Supported DB Row, Climbing (Rest 1:00) / 15 Barbell Curl @ Light (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '3', '15', 60, 'Climbing / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Barbell Curl', '3', '15', 120, '@ Light / Rest 2:00', 2 FROM weeks w WHERE w.week_number = 8;

-- B. 3 Sets: 15/15 Single Arm DB Row (Rest 1:00) / 15~20 Banded Strict Pull ups (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Single Arm DB Row', '3', '15/15', 60, 'Rest 1:00', 3 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '3', '15~20', 120, 'Rest 2:00', 4 FROM weeks w WHERE w.week_number = 8;

-- C. 3 Sets: 12 Seated DB Curls / 24 Alter DB Hammer Curls Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Seated DB Curls', '3', '12', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter DB Hammer Curls', '3', '24', 120, 'Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 8;

-- D. 3 Sets: 8~10 Feet Elevated Ring Row / 0:30 Max Banded Curls Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Feet Elevated Ring Row', '3', '8~10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '0:30 Max Banded Curls', '3', NULL, 120, 'Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 8;

-- E. EMOM 28 (7 Sets): 1 Min, 10~15 Cal Row / 2 Min, 10~15 Burpees / 3 Min, 10~15 Toes to bar or 15~25 Anchored Sit ups / 4 Min, Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '1 Min, 10~15 Cal Row', NULL, NULL, NULL, 'EMOM 28 (7 Sets)', 9 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '2 Min, 10~15 Burpees', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '3 Min, 10~15 Toes to bar or 15~25 Anchored Sit ups', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '4 Min, Rest', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 8;


-- ============ Day 4 ============
-- FET (CLOSED) — WOD 섹션 없음

-- A. 5 rounds (30's On / 30's Off): Elbow Plank Hold / Max Push ups / Wall Sit Hold / Max Push ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Elbow Plank Hold', '5', NULL, NULL, '(30''s On / 30''s Off)', 1 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Max Push ups', '5', NULL, NULL, NULL, 2 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Wall Sit Hold', '5', NULL, NULL, NULL, 3 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Max Push ups', '5', NULL, NULL, NULL, 4 FROM weeks w WHERE w.week_number = 8;

-- B. Every 1:30 for 10 sets: Odd, 30 steps Walking Lunges w/ Anything / Even, 45's Hanging Hold or Handstand Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Odd, 30 steps Walking Lunges w/ Anything', NULL, NULL, NULL, 'Every 1:30 for 10 sets', 5 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Even, 45''s Hanging Hold or Handstand Hold', NULL, NULL, NULL, NULL, 6 FROM weeks w WHERE w.week_number = 8;

-- C. EMOM 9: 0:30 Max V ups / 0:30 Max Alter Toes Touches / 0:30 Max Russian Twist
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '0:30 Max V ups', NULL, NULL, NULL, 'EMOM 9', 7 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '0:30 Max Alter Toes Touches', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '0:30 Max Russian Twist', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 8;

-- D. Every 6 minutes for 3 sets: 40~60 Mountain Climbers / 20~30 Squats / 10~15 Burpees
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Mountain Climbers', '3', '40~60', NULL, 'Every 6 minutes for 3 sets', 10 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Squats', '3', '20~30', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Burpees', '3', '10~15', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 8;

-- E. 4~5 sets: 600m Run @ Moderate / 200m Run @ Hard / 200m Run @ Recovery Run or Walk No Rest between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '600m Run @ Moderate', '4~5', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '200m Run @ Hard', '4~5', NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '200m Run @ Recovery Run or Walk', '4~5', NULL, NULL, 'No Rest between sets', 15 FROM weeks w WHERE w.week_number = 8;


-- ============ Day 5 ============
-- FET (CLOSED) — WOD 섹션 없음

-- A. Tabata V ups (Rest 1 minute) / Tabata Push ups (Rest 1 minute) / Tabata Squats (Rest 1 minute) / Tabata Step Burpees * Tabata = 8 rounds (20's On / 10's Off)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Tabata V ups', NULL, NULL, 60, 'Tabata = 8 rounds (20''s On / 10''s Off) / Rest 1 minute', 1 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Tabata Push ups', NULL, NULL, 60, 'Rest 1 minute', 2 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Tabata Squats', NULL, NULL, 60, 'Rest 1 minute', 3 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Tabata Step Burpees', NULL, NULL, NULL, NULL, 4 FROM weeks w WHERE w.week_number = 8;

-- B. 3 sets of: 24 Plank Pull Through / 12/12 Side V ups / 24's Flutter Kick w/ Hollow Rock Hold / 12 V ups or Tuck ups *Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Plank Pull Through', '3', '24', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Side V ups', '3', '12/12', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Flutter Kick w/ Hollow Rock Hold', '3', '24''s', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'V ups or Tuck ups', '3', '12', NULL, '* Rest as needed b/w sets', 8 FROM weeks w WHERE w.week_number = 8;

-- C. "Loredo" 6 rounds for time of: 24 Air Squat / 24 Push ups / 24 Walking Lunge / Run 400m
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Air Squat', NULL, '24', NULL, '"Loredo" / 6 rounds for time of :', 9 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Push ups', NULL, '24', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Walking Lunge', NULL, '24', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 8;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Run 400m', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 8;
