-- 1주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 1;

-- A. Incline DB Bench Press 4x8 *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Incline DB Bench Press', 4, '8', 90, 'Rest 1:30 b/w sets', 1 FROM weeks w WHERE w.week_number = 1;

-- B. 3 Sets: 10 Bench Press (Rest 1:00) / 20 DB Lateral Raise (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', 3, '10', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raise', 3, '20', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 1;

-- C. Behind the Neck Overhead DB Tricep Extension 3x12 Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', 3, '12', 60, 'Rest 1:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 1;

-- D. 3 sets: 10 Hip Thrust / 20~30s Weighted Elbow Plank Hold / 15~20 V ups *Rest as needed
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Hip Thrust', 3, '10', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Weighted Elbow Plank Hold', 3, '20~30s', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'V ups', 3, '15~20', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 1;

-- E. 10 sets 500m Row *Rest 1:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '500m Row', 10, '1', 60, '* Rest 1:00 between sets', 8 FROM weeks w WHERE w.week_number = 1;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 1;

-- A. Back Squat 4x8 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', 4, '8', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 1;

-- B. Barbell Back Rack Lunges 3x12 (Alternating) Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Back Rack Lunges', 3, '12 (Alternating)', 120, 'Rest 2:00 b/w sets', 2 FROM weeks w WHERE w.week_number = 1;

-- C. DB Romanian Deadlift 3x10 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Romanian Deadlift', 3, '10', 120, 'Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 1;

-- D. Superset 3 Sets: 12 Alter Goblet Lunge / 12 WB Bearhug Jumping Squats Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Alter Goblet Lunge', 3, '12', NULL, 'Superset', 4 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'WB Bearhug Jumping Squats', 3, '12', 60, 'Rest 1:00 b/w sets', 5 FROM weeks w WHERE w.week_number = 1;

-- E. 5 sets of: 30 Russian Twist / 20s Hollow Rock Hold / 10 Hanging Knee Raises (No Kipping)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Russian Twist', 5, '30', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hollow Rock Hold', 5, '20s', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', 'Hanging Knee Raises (No Kipping)', 5, '10', NULL, '* Rest as needed between sets', 8 FROM weeks w WHERE w.week_number = 1;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', 1, '1', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 1;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 1;

-- A. Banded Strict Pull ups 4x15 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Strict Pull ups', 4, '15', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 1;

-- B. 3 Sets: 10 Chest Supported DB Row (Rest 1:00) / 10 Barbell Curl (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Chest Supported DB Row', 3, '10', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Barbell Curl', 3, '10', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 1;

-- C. 3 Sets: 15 Pause Push ups or 15 Box Pause Push ups (Rest 1:00) / 20 Alter Seated DB Curl (Rest 2:00)
-- * Pause: 팔이 펴진 상태에서 1초 버티기
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Pause Push ups or Box Pause Push ups', 3, '15', 60, 'Rest 1:00', 4 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Alter Seated DB Curl', 3, '20', 120, 'Rest 2:00 / * Pause: 팔이 펴진 상태에서 1초 버티기', 5 FROM weeks w WHERE w.week_number = 1;

-- D. 5 Sets: 20 Banded Tricep Push Down / 20 DB Farmers Hold Box Step ups *Rest as needed
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Banded Tricep Push Down', 5, '20', NULL, NULL, 6 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'DB Farmers Hold Box Step ups', 5, '20', NULL, '* Rest as needed between sets', 7 FROM weeks w WHERE w.week_number = 1;

-- E. EMOM 20 mins (5 sets)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '1분: 30~60 Double Unders or Single Unders', 5, '1', NULL, 'EMOM 20 mins', 8 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '2분: 10~15 Push ups + 10~15 Squats', 5, '1', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '3분: 10~15 Box Jump Overs (Step Down)', 5, '1', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '4분: 10~15 Toes to bar or Knee Raises', 5, '1', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 1;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 1;

-- A. Front Squat 3x8 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Front Squat', 3, '8', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 1;

-- B. 3 Sets: 8 Bench Press (Rest 1:00) / 12 Bent Over Barbell Row (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bench Press', 3, '8', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bent Over Barbell Row', 3, '12', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 1;

-- C. Seated DB Arnold Press 3x12 Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Seated DB Arnold Press', 3, '12', 90, 'Rest 1:30 b/w sets', 4 FROM weeks w WHERE w.week_number = 1;

-- D. 3 Sets: 15/15 Side Plank Hip Touch / 20 Slow Knee Tucks Rest b/w 1:00
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Side Plank Hip Touch', 3, '15/15', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Slow Knee Tucks', 3, '20', 60, 'Rest b/w 1:00', 6 FROM weeks w WHERE w.week_number = 1;

-- E. 3 Sets: 6:00 Run @ Moderate / 2:00 Easy Jog
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', 'Run @ Moderate', 3, '6:00', NULL, '2:00 Easy Jog between sets', 7 FROM weeks w WHERE w.week_number = 1;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 1;

-- A. 6 Sets: 6 Deadlift, Climbing / 12 Feet Elevated Push ups *Rest 1:30 between sets
-- * Strict Push up 안되시는 분들은 Box Push up or Hand-release Push up 으로 진행하세요.
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Deadlift, Climbing', 6, '6', 90, '* Rest 1:30 between sets', 1 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Feet Elevated Push ups', 6, '12', 90, '* Strict Push up 안되시는 분들은 Box Push up or Hand-release Push up 으로 진행하세요.', 2 FROM weeks w WHERE w.week_number = 1;

-- B. Superset 3 Sets: 15 DB Curls / 15 DB Skull Crusher *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Curls', 3, '15', NULL, 'Superset', 3 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'DB Skull Crusher', 3, '15', 60, '* Rest 1:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 1;

-- C. Superset 3 Sets: 20 Banded Tricep Pushdown / 20 Alter DB Hammer Curls *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Banded Tricep Pushdown', 3, '20', NULL, 'Superset', 5 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'Alter DB Hammer Curls', 3, '20', 60, '* Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 1;

-- D. Superset 3 Sets: 15 Rear Delt Fly / 15 Lateral Raises *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Rear Delt Fly', 3, '15', NULL, 'Superset', 7 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Lateral Raises', 3, '15', 60, '* Rest 1:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 1;

-- E. AMRAP 10~20: 250m Row / 10 Ring Row / 250m Row / 10 Push ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '250m Row', NULL, NULL, NULL, 'AMRAP 10~20', 9 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '10 Ring Row', NULL, NULL, NULL, NULL, 10 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '250m Row', NULL, NULL, NULL, NULL, 11 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '10 Push ups', NULL, NULL, NULL, NULL, 12 FROM weeks w WHERE w.week_number = 1;

-- F. EMOM 10: Odd 0:30 Full Plank Shoulder Taps / Even 10~20 V ups
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Odd: 0:30 Full Plank Shoulder Taps', NULL, NULL, NULL, 'EMOM 10', 13 FROM weeks w WHERE w.week_number = 1;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', 'Even: 10~20 V ups', NULL, NULL, NULL, NULL, 14 FROM weeks w WHERE w.week_number = 1;
