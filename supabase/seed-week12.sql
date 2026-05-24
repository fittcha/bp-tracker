-- 12주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드

-- ============ Day 1 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 12;

-- A. Bench Press 5 x 10, Find Heavy * Rest 3:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Bench Press', '5', '10', 180, 'Find Heavy / * Rest 3:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 12;

-- B. 4 Sets: 15 DB Hex Press, Climbing (Rest 1:00) / 10~15 DB Lateral Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Hex Press', '4', '15', 60, 'Climbing / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raises', '4', '10~15', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 12;

-- C. 3 Sets: 9~12 Bar Dips (Banded) / 9~12 Bench Dips / 18~24 Banded Tricep Pushdown * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bar Dips (Banded)', '3', '9~12', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bench Dips', '3', '9~12', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Banded Tricep Pushdown', '3', '18~24', 120, '* Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 12;

-- D. 5 Sets (이미지 두번째 C→D): 0:30 Ski-erg @ Sprint / 0:30 Rest / 0:30 Row @ Sprint / 0:30 Rest
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Ski-erg @ Sprint', '5', NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Rest', '5', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Row @ Sprint', '5', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Rest', '5', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 12;

-- E. 5 Sets (이미지 D→E): 20~30 Alter Toe Touches / 30~45's Full Plank Hold * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '20~30 Alter Toe Touches', '5', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '30~45''s Full Plank Hold', '5', NULL, NULL, '* Rest as needed b/w sets', 12 FROM weeks w WHERE w.week_number = 12;

-- F. 30~45 MINS ZONE 2 Run (이미지 E→F)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '30~45 MINS ZONE 2 Run', NULL, NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 12;


-- ============ Day 2 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 12;

-- A. Back Squat 4 x 8 @ Week 7 * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '8', 120, '@ Week 7 / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 12;

-- B. 4 Sets: 20 Steps, Weighted Lunges / 20 DB Death March * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Weighted Lunges', '4', '20 Steps', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Death March', '4', '20', 120, '* Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 12;

-- C. 5 Sets: 10 DB Shoulder Press / 10 DB Front Squat / 10 DB Thruster * Unbroken Sets * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Shoulder Press', '5', '10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Front Squat', '5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Thruster', '5', '10', 120, '* Unbroken Sets / * Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 12;

-- D. EMOM 12~20 (3~5 Sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '1 MIN, 30~60 Double Unders or Single Unders', NULL, NULL, NULL, 'EMOM 12~20 (3~5 Sets)', 7 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '2 MIN, 10~15 Push ups +10~15 Squats', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '3 MIN, 10~15 Box Jump Overs (Step Down)', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '4 MIN, 10~15 Toes to bar or Knee Raises', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 12;

-- E. 5~10 rounds: 250/200m Row / 15 Side V ups (Right) / 250/200m Row / 15 Side V ups (Left)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '250/200m Row', NULL, NULL, NULL, '5~10 rounds', 11 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '15 Side V ups (Right)', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '250/200m Row', NULL, NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '15 Side V ups (Left)', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 12;


-- ============ Day 3 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 12;

-- A. 4 Sets: 15/15 Single Arm DB Row (Rest 1:00) / 20~30 Banded Face Pull (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Single Arm DB Row', '4', '15/15', 60, 'Rest 1:00', 1 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Face Pull', '4', '20~30', 120, 'Rest 2:00', 2 FROM weeks w WHERE w.week_number = 12;

-- B. 3 Sets: 8~10 Barbell Curls (Rest 0:45) / 10~15 Bent Over Barbell Row (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Barbell Curls', '3', '8~10', 45, 'Rest 0:45', 3 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Bent Over Barbell Row', '3', '10~15', 120, 'Rest 2:00', 4 FROM weeks w WHERE w.week_number = 12;

-- C. 3 Sets: 10 Banded Wide Grip Strict Pull ups / 20 Alter Hammer Curls Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Banded Wide Grip Strict Pull ups', '3', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter Hammer Curls', '3', '20', NULL, 'Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 12;

-- D. Accumulate 50 reps in as few sets as possible: 50 Banded Curls * Rest no more than 0:30 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '50 Banded Curls', NULL, NULL, NULL, 'Accumulate 50 reps in as few sets as possible / * Rest no more than 0:30 between sets', 7 FROM weeks w WHERE w.week_number = 12;

-- E. 6~8 sets of: 12 steps, DB(2) Front Rack Step ups / 24 steps, DB Lunges (Holding DB in each Hand) * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '12 steps, DB(2) Front Rack Step ups', '6~8', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '24 steps, DB Lunges (Holding DB in each Hand)', '6~8', NULL, NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 12;

-- F. EMOM 12~15: 1 MIN / 2 MIN / 3 MIN
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '1 MIN, 30~40''s Full Plank Hold', NULL, NULL, NULL, 'EMOM 12~15', 10 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '2 MIN, 10 V ups or Tuck ups + 10''s Hollow Rock Hold', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', '3 MIN, 12~20 Russian Twist', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 12;


-- ============ Day 4 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 12;

-- A. Hip Thrust 5 x 6 (Heavier than Last Week) * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '5', '6', 120, '@ Heavier than Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 12;

-- B. 4 Sets: 8/8 Barbell Reverse Lunges (* Rest 0:30 b/w Legs, Rest 1:00) / 12 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '8/8', 60, '* Rest 0:30 b/w Legs / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 12;

-- C. 5 Sets of: 10 DB Seated Z Press / 10/10 SA DB Row / 10 Tempo Hammer Curls * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'DB Seated Z Press', '5', '10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'SA DB Row', '5', '10/10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Tempo Hammer Curls', '5', '10', NULL, '* Rest as needed b/w sets', 6 FROM weeks w WHERE w.week_number = 12;

-- D. 3 sets (이미지 두번째 C→D): 20 Steps DB(2) Overhead Walk / 40 Box Step Ups / 20 Steps DB(2) Front Rack Walk / 40 Steps, Lunges
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '20 Steps DB(2) Overhead Walk', '3', NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '40 Box Step Ups', '3', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '20 Steps DB(2) Front Rack Walk', '3', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', '40 Steps, Lunges', '3', NULL, NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 12;

-- E. 3 Sets of (이미지 D→E): 10 Hollow Rock / 20 Alternating Toe Touches / 30's Elbow Plank Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Hollow Rock', '3', '10', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Alternating Toe Touches', '3', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '30''s Elbow Plank Hold', '3', NULL, NULL, '* Rest as needed b/w sets', 13 FROM weeks w WHERE w.week_number = 12;

-- F. 30~60 MINS Zone 2 Run (이미지 F→F)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '30~60 MINS Zone 2 Run', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 12;


-- ============ Day 5 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 12;

-- A. Bench Press 12-10-8-6, Climbing * Rest 1:30 b/w sets → and then → 1 x Max reps → into → 3 sets DB Bench/Bent Fly → into → 3 sets Reverse Bent Fly / Chainsaw Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bench Press', '4', '12-10-8-6, Climbing', 90, '* Rest 1:30 b/w sets', 1 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bench Press', '1', 'Max reps @ 40~50% of Last 6', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'into', NULL, NULL, NULL, '__sep__', 3 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Bench Fly', '3', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Bent Fly', '3', '20', 120, '* Rest 2:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'into', NULL, NULL, NULL, '__sep__', 6 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Reverse Bent Fly', '3', '20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', '15/15 DB Chainsaw Row', '3', NULL, 120, '* Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 12;

-- B. Every 2:00 for 6~10 sets: 12~18 DB(2) Box Step ups / 3~9 Strict (Banded) Pull ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB(2) Box Step ups', NULL, '12~18', NULL, 'Every 2:00 for 6~10 sets', 9 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Strict (Banded) Pull ups', NULL, '3~9', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 12;

-- C. 5 Sets of: 10~15 Negative Barbell Curls / 20 Straight Arm Banded Lat Pull down / 10 DB Pullover * Negative : Fast up / 3's Down
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Negative Barbell Curls', '5', '10~15', NULL, '* Negative : Fast up / 3''s Down', 11 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Straight Arm Banded Lat Pull down', '5', '20', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Pullover', '5', '10', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 12;

-- D. EMOM 15~25 (3~5 Sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '1 MIN, 12~16 DB Front Rack Reverse Lunges (Alternating)', NULL, NULL, NULL, 'EMOM 15~25 (3~5 Sets)', 14 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '2 MIN, 8~10 DB Burpee', NULL, NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '3 MIN, 10~12 DB Hang Power Clean', NULL, NULL, NULL, NULL, 16 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '4 MIN, 10~15 DB Push ups', NULL, NULL, NULL, NULL, 17 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '5 MIN, REST', NULL, NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 12;

-- E. 3 Sets of: 26 Plank Pull Through / 14/14 Side V ups / 26's Flutter Kick w/ Hollow Rock Hold / 14 V ups or Tuck ups * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '26 Plank Pull Through', '3', NULL, NULL, NULL, 19 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '14/14 Side V ups', '3', NULL, NULL, NULL, 20 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '26''s Flutter Kick w/ Hollow Rock Hold', '3', NULL, NULL, NULL, 21 FROM weeks w WHERE w.week_number = 12;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '14 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed b/w sets', 22 FROM weeks w WHERE w.week_number = 12;
