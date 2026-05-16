-- 10주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 10;

-- A. DB Bench Press 5 x 12 reps (Heaviest Weight of Last Week) *Rest 2:00 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '5', '12', 120, '@ Heaviest Weight of Last Week / * Rest 2:00 b/w Sets', 1 FROM weeks w WHERE w.week_number = 10;

-- B. 4 Sets: 8~12 Deficit Push ups or Hand-release Push ups (Rest 1:00) / 15~20 Seated DB Lateral Raises (Rest 1:00) / 8~12 Seated DB Press (Rest 1:00) / 15~20 Seated DB Front Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Deficit Push ups or Hand-release Push ups', '4', '8~12', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Lateral Raises', '4', '15~20', 60, 'Rest 1:00', 3 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Press', '4', '8~12', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Front Raises', '4', '15~20', 120, 'Rest 2:00', 5 FROM weeks w WHERE w.week_number = 10;

-- C. 4 Sets: 15/15 DB Tricep Kickback *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '15/15 DB Tricep Kickback', '4', NULL, NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 10;

-- D. EMOM 10: 0:30 Sprint Ski-erg / 0:30 Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Sprint Ski-erg', NULL, NULL, NULL, 'EMOM 10', 7 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Rest', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 10;

-- E. For time of: Row 5,000m *Every 3:00, Perform 10~20 Toes to bar or V-ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', 'Row 5,000m', NULL, NULL, NULL, 'For time of : / * Every 3:00, Perform 10~20 Toes to bar or V-ups', 9 FROM weeks w WHERE w.week_number = 10;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 10;

-- A. Back Squat 4 x 12 reps (Heaviest Weight of Last Week) *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '12', 120, '@ Heaviest Weight of Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 10;

-- B. 3 Sets: 20 Steps, Walking Lunges / 20 DB Death March Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Walking Lunges', '3', '20 Steps', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Death March', '3', '20', 60, 'Rest 1:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 10;

-- C. 3 Sets: 15~20 DB Frog Pump / 0:30 Wall Sit Hold / 15~20 Goblet Squats Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Frog Pump', '3', '15~20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Wall Sit Hold', '3', '0:30', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Goblet Squats', '3', '15~20', 60, 'Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 10;

-- D. EMOM 10~20 (5~10 Sets): Odd, 10 DB Hang Power Clean / Even, 10 DB Push press
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Odd, 10 DB Hang Power Clean', NULL, NULL, NULL, 'EMOM 10~20 (5~10 Sets)', 7 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Even, 10 DB Push press', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 10;

-- E. 3 Sets: 10~15 V ups / 0:20~30 Hollow Rock Hold Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'V ups', '3', '10~15', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Rock Hold', '3', '0:20~30', NULL, 'Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 10;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 10;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 10;

-- A. 3 Sets: 12 Chest Supported DB Row (Heaviest Weight of Last Week) (Rest 1:00) / 20~30 Banded Tricep Push Down (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '3', '12', 60, '@ Heaviest Weight of Last Week / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Tricep Push Down', '3', '20~30', 120, 'Rest 2:00', 2 FROM weeks w WHERE w.week_number = 10;

-- B. 3 Sets: 15~20 Banded Strict Pull ups / 10~15 Bent Over DB Row Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Strict Pull ups', '3', '15~20', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Bent Over DB Row', '3', '10~15', 120, 'Rest 2:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 10;

-- C. 3 Sets: 8 Seated DB Curls / 16 Alter DB Hammer Curls - Heavier than Last Week - Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Seated DB Curls', '3', '8', NULL, '@ Heavier than Last Week', 5 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter DB Hammer Curls', '3', '16', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 10;

-- D. 3 Sets: 8~10 Barbell Curls / 0:30 Max Empty Bar Reverse Curls Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Barbell Curls', '3', '8~10', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '0:30 Max Empty Bar Reverse Curls', '3', NULL, 120, 'Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 10;

-- E. 5 sets: 20 DB Reverse Lunges / 10 DB Hang Squat Clean *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Reverse Lunges', '5', '20', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Hang Squat Clean', '5', '10', NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 10;

-- F. 4 sets of: 1:00 DB Overhead Hold / 30 Alternating DB Side Bend (15/15) *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '1:00 DB Overhead Hold', '4', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '30 Alternating DB Side Bend (15/15)', '4', NULL, NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 10;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 10;

-- A. Hip Thrust 4 x 10 (Heaviest Weight of Last Week) *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '10', 120, '@ Heaviest Weight of Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 10;

-- B. 5 sets: 15 Pause Push ups or 15 Box Pause Push ups / 0:30 Wall Sit Hold / 10~15 GHD Sit ups or AB Sit ups / 30 DB(1) Box Step ups *Rest as needed / *Pause note
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', '15 Pause Push ups or 15 Box Pause Push ups', '5', NULL, NULL, '* Pause : 팔이 펴진 상태에서 1초 버티기', 2 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Wall Sit Hold', '5', '0:30', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', '10~15 GHD Sit ups or AB Sit ups', '5', NULL, NULL, NULL, 4 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', '30 DB(1) Box Step ups', '5', NULL, NULL, '* Rest as needed between sets', 5 FROM weeks w WHERE w.week_number = 10;

-- C. 6 sets of: 10/10 Seated SA DB Press, Climbing / 45's Waiter Hold (Each) *Rest 2:00 b/w sets → Rest as needed → EMOM 6~9: 15 DB Hang Power Clean & Press
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Seated SA DB Press', '6', '10/10', NULL, 'Climbing', 6 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Waiter Hold (Each)', '6', '45''s', 120, '* Rest 2:00 b/w sets', 7 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Rest as needed', NULL, NULL, NULL, '__sep__', 8 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '15 DB Hang Power Clean & Press', NULL, NULL, NULL, 'EMOM 6~9', 9 FROM weeks w WHERE w.week_number = 10;

-- D. EMOM 9~15 (3~5 sets): 0:30 Russian Twist / 0:30 Side Plank (Left) / 0:30 Side Plank (Right)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '0:30 Russian Twist', NULL, NULL, NULL, 'EMOM 9~15 (3~5 sets)', 10 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '0:30 Side Plank (Left)', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '0:30 Side Plank (Right)', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 10;

-- F. 5~8 Sets: 600m Run @ Faster than Moderated / 400m Run @ Zone 2 *No Rest b/w sets (E 섹션 없음)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '600m Run @ Faster than Moderated', '5~8', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '400m Run @ Zone 2', '5~8', NULL, NULL, '* No Rest b/w sets', 14 FROM weeks w WHERE w.week_number = 10;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 10;

-- A. 3 sets of: 8/8 SA DB Row / 6~12 Push up on DB / 10 Barbell Curls / 9~15 Close Grip Push ups *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'SA DB Row', '3', '8/8', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Push up on DB', '3', '6~12', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Barbell Curls', '3', '10', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Close Grip Push ups', '3', '9~15', NULL, '* Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 10;

-- B. Every 2:00 for 7 sets: 7 Pendlay Row @ Heavy / 7/7 Single Arm DB Snatch (Each)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Pendlay Row', NULL, '7', NULL, 'Every 2:00 for 7 sets / @ Heavy', 5 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Single Arm DB Snatch (Each)', NULL, '7/7', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 10;

-- C. 5 sets (Super Set / Unbroken): 10 DB Bicep Curls / 20 DB Row → Rest as needed → 5 sets (Super Set / Unbroken): 20 Banded Face Pull / 20 Banded Lat Pull downs
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Bicep Curls', '5', '10', NULL, 'Super Set / Unbroken', 7 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Row', '5', '20', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Rest as needed', '5', NULL, NULL, '__sep__', 9 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Face Pull', '5', '20', NULL, 'Super Set / Unbroken', 10 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Lat Pull downs', '5', '20', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 10;

-- D. Every 2:00 for 20 sets: 250/200m Row / 9~15 Burpees
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '250/200m Row', NULL, NULL, NULL, 'Every 2:00 for 20 sets', 12 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Burpees', NULL, '9~15', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 10;

-- E. 5 sets: 10's Hollow Rock Hold / 10 Hollow Rock / 10 V ups or Tuck ups / 10 Hollow Rock / 10's Hollow Rock Hold *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock Hold', '5', '10''s', NULL, NULL, 14 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock', '5', '10', NULL, NULL, 15 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'V ups or Tuck ups', '5', '10', NULL, NULL, 16 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock', '5', '10', NULL, NULL, 17 FROM weeks w WHERE w.week_number = 10;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Hollow Rock Hold', '5', '10''s', NULL, '* Rest as needed between sets', 18 FROM weeks w WHERE w.week_number = 10;
