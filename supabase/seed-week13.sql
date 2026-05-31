-- 13주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- Day 1~5: 박스 와드
-- 참고: 이미지의 중복 라벨(Day1 C 2개)은 순차 재라벨링(A~F), Day5는 이미지에 박스 와드 라벨이
--       없으나 12주차 관례(매일 박스 와드) 따라 WOD row 추가.

-- ============ Day 1 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 13;

-- A. Bench Press 5 x 12, @ 80~85% of Last Week * Rest 3:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Bench Press', '5', '12', 180, '@ 80~85% of Last Week / * Rest 3:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 13;

-- B. 4 Sets: 15 DB Hex Press, @ Heaviest Weight of Last Week (Rest 1:00) / 10~15 DB Lateral Raises (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Hex Press', '4', '15', 60, '@ Heaviest Weight of Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raises', '4', '10~15', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 13;

-- C. 4 Sets: 9~12 Bar Dips (Banded) / 9~12 Bench Dips / 18~24 Banded Tricep Pushdown * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bar Dips (Banded)', '4', '9~12', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Bench Dips', '4', '9~12', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Banded Tricep Pushdown', '4', '18~24', 120, '* Rest 2:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 13;

-- D. Every 2:00 for 6 Sets (이미지 두번째 C→D): 10/8 Cal Ski-erg @ Sprint / 0:30 Max Push ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '10/8 Cal Ski-erg @ Sprint', NULL, NULL, NULL, 'Every 2:00 for 6 Sets', 7 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', '0:30 Max Push ups', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 13;

-- E. 3 Sets (이미지 D→E): 20 Heels Over KB / 15 V ups / 0:30 Hollow Rock Hold / 15 Reverse Hypers or GHD Back Extensions * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '20 Heels Over KB', '3', NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '15 V ups', '3', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '0:30 Hollow Rock Hold', '3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '15 Reverse Hypers or GHD Back Extensions', '3', NULL, NULL, '* Rest as needed b/w sets', 12 FROM weeks w WHERE w.week_number = 13;

-- F. Every 4:00 x 3 (이미지 E→F): 1:00 Easy Run / 2:00 Moderate Run / 0:30 Hard Run / 0:30 Rest → and then → 5 sets: 400m Run @ RPE 7~8 / 2:00 Recovery Walk
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '1:00 Easy Run', NULL, NULL, NULL, 'Every 4:00 x 3', 13 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '2:00 Moderate Run', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '0:30 Hard Run', NULL, NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '0:30 Rest', NULL, NULL, NULL, NULL, 16 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', 'and then,', NULL, NULL, NULL, '__sep__', 17 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '400m Run @ RPE 7~8', '5', NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'F', '2:00 Recovery Walk', '5', NULL, NULL, NULL, 19 FROM weeks w WHERE w.week_number = 13;


-- ============ Day 2 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 13;

-- A. Back Squat 4 x 8 @ Heavier than Last Week * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '8', 120, '@ Heavier than Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 13;

-- B. 4 Sets: 8/8 Weighted Lunges (Rest 1:00) / 20 steps, DB Farmers Lunges (* Rest 0:30 b/w Legs, * Rest 2:00 b/w sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Weighted Lunges', '4', '8/8', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'DB Farmers Lunges', '4', '20 steps', 120, '* Rest 0:30 b/w Legs / * Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 13;

-- C. 4 Sets: 10 Strict Pull ups (Banded) / 20 Alter DB Curls / 10 Skull Crushers / 10 Bar dips (Banded) or Deficit Push ups * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Strict Pull ups (Banded)', '4', '10', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Alter DB Curls', '4', '20', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Skull Crushers', '4', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'Bar dips (Banded) or Deficit Push ups', '4', '10', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 13;

-- D. EMOM 12~16: Odd, Row 10~15 Cal / Even, 8~12 Burpee Over the Rower
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Odd, Row 10~15 Cal', NULL, NULL, NULL, 'EMOM 12~16', 8 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Even, 8~12 Burpee Over the Rower', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 13;

-- E. 3 Sets: 16 Landmine Bar Twist (8 Each) / 8 Weighted Hanging Knee Raises (No Kipping) / 30 Cross Mountain Climber * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '16 Landmine Bar Twist (8 Each)', '3', NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '8 Weighted Hanging Knee Raises (No Kipping)', '3', NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '30 Cross Mountain Climber', '3', NULL, NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 13;

-- F. Zone 2 - 40 minutes: Run or Bike or Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', 'Run or Bike or Row', NULL, NULL, NULL, 'Zone 2 - 40 minutes', 13 FROM weeks w WHERE w.week_number = 13;


-- ============ Day 3 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 13;

-- A. 4 Sets: 15/15 Single Arm DB Row (Rest 1:00) / 20~30 Banded Face Pull (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Single Arm DB Row', '4', '15/15', 60, 'Rest 1:00', 1 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Face Pull', '4', '20~30', 120, 'Rest 2:00', 2 FROM weeks w WHERE w.week_number = 13;

-- B. 3 Sets: 8~10 Barbell Curls (Rest 0:45) / 10~15 Bent Over Barbell Row (Rest 0:30 b/w Movement, Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Barbell Curls', '3', '8~10', 45, 'Rest 0:45', 3 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Bent Over Barbell Row', '3', '10~15', 120, 'Rest 0:30 b/w Movement / Rest 2:00', 4 FROM weeks w WHERE w.week_number = 13;

-- C. 3 Sets: 10 Banded Wide Grip Strict Pull ups (Rest 1:00) / 20 Alter Hammer Curls / 6 Heavy Barbell Curls Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Banded Wide Grip Strict Pull ups', '3', '10', 60, 'Rest 1:00', 5 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter Hammer Curls', '3', '20', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Heavy Barbell Curls', '3', '6', NULL, 'Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 13;

-- D. 6 sets of: 10 DB Bench Press, Climbing / 20 DB Bench Flys * Rest 1:30 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'DB Bench Press', '6', '10', NULL, 'Climbing', 8 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'DB Bench Flys', '6', '20', 90, '* Rest 1:30 between sets', 9 FROM weeks w WHERE w.week_number = 13;

-- E. 3 sets: 20 DB Front Raises / 20 DB Lateral Raises / 20 DB Push Press * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Front Raises', '3', '20', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Lateral Raises', '3', '20', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', 'DB Push Press', '3', '20', NULL, '* Rest as needed between sets', 12 FROM weeks w WHERE w.week_number = 13;

-- F. EMOM 12~20 (6~10 Sets): Odd, 6 Box Jumps + 6 Box Step ups w/ DB(2) Holds / Even, 24 Russian Twist w/ DB or WB
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Odd, 6 Box Jumps + 6 Box Step ups w/ DB(2) Holds', NULL, NULL, NULL, 'EMOM 12~20 (6~10 Sets)', 13 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'F', 'Even, 24 Russian Twist w/ DB or WB', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 13;


-- ============ Day 4 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 13;

-- A. Hip Thrust 5 x 6 (Heavier than Last Week) * Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Hip Thrust', '5', '6', 120, '@ Heavier than Last Week / * Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 13;

-- B. 4 Sets: 8/8 Barbell Reverse Lunges (* Rest 0:30 b/w Legs, Rest 1:00) / 12 DB Romanian Deadlift (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Barbell Reverse Lunges', '4', '8/8', 60, '* Rest 0:30 b/w Legs / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'DB Romanian Deadlift', '4', '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 13;

-- C. 3 Sets: 20 Alternating DB Curls / 10 Feet Elevated Ring Row / 10 DB Pullovers
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Alternating DB Curls', '3', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Feet Elevated Ring Row', '3', '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'DB Pullovers', '3', '10', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 13;

-- D. EMOM 10: Odd, 10~12 Alternating DB Curls / Even, 9~15 DB Close Grip Push ups or DB Wave Push ups → Followed by → EMOM 10: Odd, 10~14 Alternating Seated Arnold Press / Even, 9~15 Ring Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Odd, 10~12 Alternating DB Curls', NULL, NULL, NULL, 'EMOM 10', 7 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Even, 9~15 DB Close Grip Push ups or DB Wave Push ups', NULL, NULL, NULL, NULL, 8 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Followed by', NULL, NULL, NULL, '__sep__', 9 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Odd, 10~14 Alternating Seated Arnold Press', NULL, NULL, NULL, 'EMOM 10', 10 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Even, 9~15 Ring Row', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 13;

-- E. 3 Sets: 30 Russian Twist / 20 Slow Knee Tuck ups Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Russian Twist', '3', '30', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Slow Knee Tuck ups', '3', '20', NULL, 'Rest as needed b/w sets', 13 FROM weeks w WHERE w.week_number = 13;

-- F. 3~5 rounds time of: 500~1,000m Run / 15~25 Push Ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '500~1,000m Run', NULL, NULL, NULL, '3~5 rounds time of :', 14 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'F', '15~25 Push Ups', NULL, NULL, NULL, NULL, 15 FROM weeks w WHERE w.week_number = 13;


-- ============ Day 5 ============
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 13;

-- A. Bench Press 12-10-8-6, @ Heavier than Last Week * Rest 1:30 b/w sets → and then → 1 x Max reps → into → 3 sets DB Bench/Bent Fly → into → 3 sets Reverse Bent Fly / Chainsaw Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bench Press', '4', NULL, 90, '@ 12-10-8-6, Heavier than Last Week / * Rest 1:30 b/w sets', 1 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bench Press', '1', NULL, NULL, '@ Max reps @ 40~50% of Last 6', 2 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'into', NULL, NULL, NULL, '__sep__', 3 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Bench Fly', '3', '20', NULL, NULL, 4 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Bent Fly', '3', '20', 120, '* Rest 2:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'into', NULL, NULL, NULL, '__sep__', 6 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'DB Reverse Bent Fly', '3', '20', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', '15/15 DB Chainsaw Row', '3', NULL, 120, '* Rest 2:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 13;

-- B. 5 sets: 15 Russian Kettlebell Swings / 12 Pendlay Row / 9 DB Curls to Press Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Russian Kettlebell Swings', '5', '15', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Pendlay Row', '5', '12', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Curls to Press', '5', '9', NULL, 'Rest as needed between sets', 11 FROM weeks w WHERE w.week_number = 13;

-- C. 3 Sets: 20~35 Barbell Curls (Empty) / 35 Banded Tricep Extensions / 10~20 Dips * Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Barbell Curls (Empty)', '3', '20~35', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Extensions', '3', '35', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Dips', '3', '10~20', NULL, '* Rest as needed between sets', 14 FROM weeks w WHERE w.week_number = 13;

-- D. 6 sets: 10 Deadlift @ 50~60% / 10 Bar Facing or Lateral Burpee * Work : Rest = 1:1
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Deadlift', '6', '10', NULL, '@ 50~60%', 15 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Bar Facing or Lateral Burpee', '6', '10', NULL, '* Work : Rest = 1:1', 16 FROM weeks w WHERE w.week_number = 13;

-- E. 3 Sets of: 30 Plank Pull Through / 15/15 Side V ups / 30's Flutter Kick w/ Hollow Rock Hold / 15 V ups or Tuck ups * Rest as needed b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '30 Plank Pull Through', '3', NULL, NULL, NULL, 17 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '15/15 Side V ups', '3', NULL, NULL, NULL, 18 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '30''s Flutter Kick w/ Hollow Rock Hold', '3', NULL, NULL, NULL, 19 FROM weeks w WHERE w.week_number = 13;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '15 V ups or Tuck ups', '3', NULL, NULL, '* Rest as needed b/w sets', 20 FROM weeks w WHERE w.week_number = 13;
