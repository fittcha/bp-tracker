-- 11주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 11;

-- A. DB Bench Press 4 x 0:45 Max reps * Rest 1:30 b/w Sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'DB Bench Press', '4', '0:45 Max reps', 90, '* Rest 1:30 b/w Sets', 1 FROM weeks w WHERE w.week_number = 11;

-- B. 6 Sets: 6 Seated DB Strict Press (Rest 0:30) / 9 Barbell Curls (Rest 0:30) / 12 DB Lateral Raises (Rest 0:30) / 9 DB Skull Crusher (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Seated DB Strict Press', '6', '6', NULL, NULL, 2 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Barbell Curls', '6', '9', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raises', '6', '12', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Skull Crusher', '6', '9', 120, '* Rest 0:30 b/w Movement / * Rest 2:00 b/w Sets', 5 FROM weeks w WHERE w.week_number = 11;

-- C. 3 Sets: 8/8 DB Bulgarian Split Squats / 0:45 KB(2) Front Rack Hold / 20 Banded Tricep Pushdown / 5/5 SA Turkish Sit ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '8/8 DB Bulgarian Split Squats', '3', NULL, NULL, NULL, 6 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '0:45 KB(2) Front Rack Hold', '3', NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '20 Banded Tricep Pushdown', '3', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', '5/5 SA Turkish Sit ups', '3', NULL, NULL, '* Rest as needed between sets', 9 FROM weeks w WHERE w.week_number = 11;

-- D. EMOM 10: Odd, 12 DB Reverse Lunges / Even, 30's Wall Sit Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Odd, 12 DB Reverse Lunges', NULL, NULL, NULL, 'EMOM 10', 10 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Even, 30''s Wall Sit Hold', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 11;

-- E. 3 sets: 8:00 Row @ 2k Pace + 10's Rest 3:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '8:00 Row @ 2k Pace + 10''s', '3', NULL, 180, '* Rest 3:00 between sets / * 남자 2:20 Under / 여자 2:40 Under / * Target : 2k Pace가 있으시면, 2k + 10''s', 12 FROM weeks w WHERE w.week_number = 11;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 11;

-- A. Back Squat 3 x 20 reps @ Light Weight * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '3', '20', 120, '@ Light Weight / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 11;

-- B. 3 Sets: 8/8 DB Front Foot Elevated Split Lunges / 12 Barbell Bent Over Row / 15 Barbell Curls / 15 DB Floor Press Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', '8/8 DB Front Foot Elevated Split Lunges', '3', NULL, NULL, NULL, 2 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Bent Over Row', '3', '12', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Curls', '3', '15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Floor Press', '3', '15', NULL, '* Rest as needed between sets', 5 FROM weeks w WHERE w.week_number = 11;

-- C. 3 Sets: 20 Steps, Walking Lunges / 20 DB Death March Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Walking Lunges', '3', '20 Steps', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Death March', '3', '20', 60, 'Rest 1:00 b/w sets', 7 FROM weeks w WHERE w.week_number = 11;

-- D. 4 sets of: 15~25 Incline Reverse Grip Push ups / 15~20 (GHD) Sit ups / 15 DB Lateral Raises / 10~15 Toes to bar * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '15~25 Incline Reverse Grip Push ups', '4', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '15~20 (GHD) Sit ups', '4', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '15 DB Lateral Raises', '4', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '10~15 Toes to bar', '4', NULL, NULL, '* Rest as needed between sets', 11 FROM weeks w WHERE w.week_number = 11;

-- E. 3 sets of: 24 Plank Pull Through / 12/12 Side V ups / 24's Flutter Kick w/ Hollow Rock Hold / 12 V ups or Tuck ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '24 Plank Pull Through', '3', NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '12/12 Side V ups', '3', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '24''s Flutter Kick w/ Hollow Rock Hold', '3', NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '12 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed between sets', 15 FROM weeks w WHERE w.week_number = 11;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 16 FROM weeks w WHERE w.week_number = 11;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 11;

-- A. 3 Sets: 10 Chest Supported DB Row (Heaviest Weight of Last Week) Rest 1:00 / 20 Banded Face Pull Rest 2:00
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Chest Supported DB Row', '3', '10', 60, '@ Heaviest Weight of Last Week / Rest 1:00', 1 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Face Pull', '3', '20', 120, 'Rest 2:00', 2 FROM weeks w WHERE w.week_number = 11;

-- B. 3 Sets: 10 Banded Wide Grip Strict Pull ups / 10~15 Bent Over DB Row Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Banded Wide Grip Strict Pull ups', '3', '10', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Bent Over DB Row', '3', '10~15', 120, 'Rest 2:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 11;

-- C. 3 Sets: 10 Seated DB Curls @ Last Week / 20 Alter DB Hammer Curls @ Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Seated DB Curls', '3', '10', NULL, '@ Last Week', 5 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter DB Hammer Curls', '3', '20', 120, '@ Last Week / Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 11;

-- D. 3 Sets: 8~10 Barbell Curls @ Heavier than Last Week / 0:30 Max Empty Bar Reverse Curls Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Barbell Curls', '3', '8~10', NULL, '@ Heavier than Last Week', 7 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', '0:30 Max Empty Bar Reverse Curls', '3', NULL, 120, 'Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 11;

-- E. 4~6 sets: 12 DB Reverse Bent Fly / 6~10 Bar Dips (Banded) / 8 Feet Elevated Push ups * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Reverse Bent Fly', '4~6', '12', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'Bar Dips (Banded)', '4~6', '6~10', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'Feet Elevated Push ups', '4~6', '8', NULL, '* Rest as needed b/w sets', 11 FROM weeks w WHERE w.week_number = 11;

-- F. Every 2:00 for 10 sets: 15~30's Hollow Rock Hold / 10 Toes to bar (Knee Raises)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Hollow Rock Hold', NULL, '15~30''s', NULL, 'Every 2:00 for 10 sets', 12 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Toes to bar (Knee Raises)', NULL, '10', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 11;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 11;

-- A. Hip Thrust 4 x 8 (Heaviest Weight of Last Week) * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '4', '8', 120, '@ Heaviest Weight of Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 11;

-- B. 3 Sets: 15 Goblet Squat w/ Pause (Rest 1:00) / 15 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Goblet Squat w/ Pause', '3', '15', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '3', '15', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 11;

-- C. 5 sets: 10 Hammer Curls / 10 DB Hang Power Clean / 10 DB Bent Row * Rest as needed between sets
-- C. 3 sets: 20 Steps DB(2) Overhead Walk / 40 Box Step Ups / 20 Steps DB(2) Front Rack Walk / 40 Steps, Lunges * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Hammer Curls', '5', '10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'DB Hang Power Clean', '5', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'DB Bent Row', '5', '10', NULL, '* Rest as needed between sets', 6 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '20 Steps DB(2) Overhead Walk', '3', NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '40 Box Step Ups', '3', NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '20 Steps DB(2) Front Rack Walk', '3', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', '40 Steps, Lunges', '3', NULL, NULL, '* Rest as needed between sets', 10 FROM weeks w WHERE w.week_number = 11;

-- D. EMOM 16~20: Odd min, 8~12 Knee to Elbow or Toes to bar or Knee Raises / Even min, 10~15 Hollow Rock
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Odd min, 8~12 Knee to Elbow or Toes to bar or Knee Raises', NULL, NULL, NULL, 'EMOM 16~20', 11 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Even min, 10~15 Hollow Rock', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 11;

-- F. 10 Sets: 400m Run @ Faster than Moderated / 400m Run @ Zone 2 * No Rest b/w sets (E 섹션 없음)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '400m Run @ Faster than Moderated', '10', NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '400m Run @ Zone 2', '10', NULL, NULL, '* No Rest b/w sets', 14 FROM weeks w WHERE w.week_number = 11;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 11;

-- A. EMOM 10: Odd, 30's Max Standing Arnold Press / Even, 8 DB Lateral Raises + 8 DB Front Raises
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Odd, 30''s Max Standing Arnold Press', NULL, NULL, NULL, 'EMOM 10', 1 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Even, 8 DB Lateral Raises + 8 DB Front Raises', NULL, NULL, NULL, NULL, 2 FROM weeks w WHERE w.week_number = 11;

-- B. Every 3:00 for 5 sets: 10 DB Bicep Curls / 15 Banded Face Pulls / 20 Banded Tricep Pushdown
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Bicep Curls', NULL, '10', NULL, 'Every 3:00 for 5 sets', 3 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Banded Face Pulls', NULL, '15', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Banded Tricep Pushdown', NULL, '20', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 11;

-- C. EMOM 20: 1 min, 12 DB Bent Row / 2 min, 12 DB Hang Power Clean / 3 min, 12 DB High Pull / 4 min, 6 Devil Press
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '1 min, 12 DB Bent Row', NULL, NULL, NULL, 'EMOM 20', 6 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '2 min, 12 DB Hang Power Clean', NULL, NULL, NULL, NULL, 7 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '3 min, 12 DB High Pull', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', '4 min, 6 Devil Press', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 11;

-- D. 3~rounds for time of: 500/400m Row / 10~15 Line Facing Burpees / 500/400m Row / 10 Burpee Pull ups or Target Burpees
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '500/400m Row', NULL, NULL, NULL, '3~rounds for time of :', 10 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '10~15 Line Facing Burpees', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '500/400m Row', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', '10 Burpee Pull ups or Target Burpees', NULL, NULL, NULL, NULL, 13 FROM weeks w WHERE w.week_number = 11;

-- E. EMOM 6: 12 Alternating Reverse Lunges w/ Hold DB(2) → Followed by → E2MOM x 5 sets: 10 Alternating Jumping Lunges / 8 Box Jumps / 20's DB Overhead Hold
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '12 Alternating Reverse Lunges w/ Hold DB(2)', NULL, NULL, NULL, 'EMOM 6', 14 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', 'Followed by', NULL, NULL, NULL, '__sep__', 15 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '10 Alternating Jumping Lunges', NULL, NULL, NULL, 'E2MOM x 5 sets', 16 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '8 Box Jumps', NULL, NULL, NULL, NULL, 17 FROM weeks w WHERE w.week_number = 11;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '20''s DB Overhead Hold', NULL, NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 11;
