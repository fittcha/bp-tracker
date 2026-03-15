-- 2주차 운동 템플릿 시드 데이터 (이미지 기준 정확 대조)
-- 모든 Day에 "박스 와드"를 WOD 항목으로 포함
-- 1주차 대비 변경: Heavier than Last Week 표기, 세트/렙 조정
-- rest_seconds 필드가 있는 경우 notes에 휴식 정보 중복 표기하지 않음

-- ============ Day 1 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 2;

-- A. Incline DB Bench Press 4x6 @ Heavier than Last Week *Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'A', 'Incline DB Bench Press', '4', '6', 90, '@ Heavier than Last Week / Rest 1:30 b/w sets', 1 FROM weeks w WHERE w.week_number = 2;

-- B. 3 Sets: 8 Bench Press @ Heavier than Last Week (Rest 1:00) / 16 DB Lateral Raise (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'Bench Press', '3', '8', 60, '@ Heavier than Last Week / Rest 1:00', 2 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'B', 'DB Lateral Raise', '3', '16', 120, 'Rest 2:00', 3 FROM weeks w WHERE w.week_number = 2;

-- C. Behind the Neck Overhead DB Tricep Extension 3x12 Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'C', 'Behind the Neck Overhead DB Tricep Extension', '3', '12', 60, 'Rest 1:00 b/w sets', 4 FROM weeks w WHERE w.week_number = 2;

-- D. 5 Sets: 20~30 Alternating Toe Touches / 0:30 Full Plank Hold *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Alternating Toe Touches', '5', '20~30', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'D', 'Full Plank Hold', '5', '0:30', 60, '* Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 2;

-- E. 3~5 sets 1,000m Row *Rest 2:00 between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 1, 'E', '1,000m Row', '3~5', '1', 120, '* Rest 2:00 between sets', 7 FROM weeks w WHERE w.week_number = 2;


-- ============ Day 2 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 2;

-- A. Back Squat 4x6 @ Heavier than Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'A', 'Back Squat', '4', '6', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 2;

-- B. Barbell Back Rack Lunges 3x12 (Alternating) Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'B', 'Barbell Back Rack Lunges', '3', '12 (Alternating)', 120, 'Rest 2:00 b/w sets', 2 FROM weeks w WHERE w.week_number = 2;

-- C. DB Romanian Deadlift 3x8 @ Heavier than Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'C', 'DB Romanian Deadlift', '3', '8', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 3 FROM weeks w WHERE w.week_number = 2;

-- D. Superset 3 Sets: 12 Goblet Squats / 12 3/4 Air Squats Rest 1:00 b/w sets
-- * 3/4 Air Squats -> 스쿼트 후에 3/4만 일어나기 (하체 긴장감 주기)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', 'Goblet Squats', '3', '12', NULL, 'Superset', 4 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'D', '3/4 Air Squats', '3', '12', 60, 'Rest 1:00 b/w sets / * 스쿼트 후에 3/4만 일어나기 (하체 긴장감 주기)', 5 FROM weeks w WHERE w.week_number = 2;

-- E. Every 1:30 for 5~8 Sets: 6 Strict Pull ups / 9 Push Ups / 12 DB Bent Row
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '6 Strict Pull ups', NULL, '6', NULL, 'Every 1:30 for 5~8 Sets', 6 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '9 Push Ups', NULL, '9', NULL, NULL, 7 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'E', '12 DB Bent Row', NULL, '12', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 2;

-- F. 15~45 Minute Easy Run
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 2, 'F', '15~45 Minute Easy Run', NULL, NULL, NULL, NULL, 9 FROM weeks w WHERE w.week_number = 2;


-- ============ Day 3 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 2;

-- A. Banded Strict Pull ups 4x20 Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'A', 'Banded Strict Pull ups', '4', '20', 120, 'Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 2;

-- B. 3 Sets: 10 Chest Supported DB Row (Rest 1:00) / 8 Barbell Curl @ Heavier than Last Week (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Chest Supported DB Row', '3', '10', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'B', 'Barbell Curl', '3', '8', 120, '@ Heavier than Last Week / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 2;

-- C. AMRAP 12: 4-6-8-10... reps Bench Tricep Dips / DB Hammer Curls Rest 3:00
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'Bench Tricep Dips', NULL, '4-6-8-10...', NULL, 'AMRAP 12 · 4-6-8-10... reps', 4 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', 'DB Hammer Curls', NULL, '4-6-8-10...', NULL, 'AMRAP 12 / Rest 3:00 after AMRAP', 5 FROM weeks w WHERE w.week_number = 2;

-- Superset 3 sets: 20 DB Bench Fly / 20 DB Bent Fly *Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', '20 DB Bench Fly', '3', '20', NULL, 'Superset', 6 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'C', '20 DB Bent Fly', '3', '20', 120, '* Rest 2:00 b/w sets', 7 FROM weeks w WHERE w.week_number = 2;

-- D. 5 sets of: 10 Right Arm Seated DB Press / 10 Left Arm Seated DB Press / 45's Right Arm Waiter Hold / 45's Left Arm Waiter Hold / 15/15 SA Lateral Raises
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Right Arm Seated DB Press', '5', '10', NULL, NULL, 8 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Left Arm Seated DB Press', '5', '10', NULL, NULL, 9 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Right Arm Waiter Hold', '5', '45''s', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'Left Arm Waiter Hold', '5', '45''s', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'D', 'SA Lateral Raises', '5', '15/15', NULL, NULL, 12 FROM weeks w WHERE w.week_number = 2;

-- E. EMOM 16 or 20 (16분은 휴식 없이 진행, 20분은 1분 휴식 후 이어가기)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '1 MIN, 12~16 DB Front Rack Reverse Lunges (Alternating)', NULL, '1', NULL, 'EMOM 16 or 20', 13 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '2 MIN, 8~10 DB Burpee', NULL, '1', NULL, NULL, 14 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '3 MIN, 10~12 DB Hang Power Clean', NULL, '1', NULL, NULL, 15 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 3, 'E', '4 MIN, 10~15 DB Push ups', NULL, '1', NULL, '* 5 MIN, REST * / 16분은 휴식 없이 진행 / 20분은 1분 휴식 후 이어가기', 16 FROM weeks w WHERE w.week_number = 2;


-- ============ Day 4 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 2;

-- A. Front Squat 3x6 @ Heavier than Last Week Rest 2:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'A', 'Front Squat', '3', '6', 120, '@ Heavier than Last Week / Rest 2:00 b/w sets', 1 FROM weeks w WHERE w.week_number = 2;

-- B. 3 Sets: 8 Bench Press (Rest 1:00) / 10 Bent Over Barbell Row @ Heavier than Last Week (Rest 2:00)
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bench Press', '3', '8', 60, 'Rest 1:00', 2 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'B', 'Bent Over Barbell Row', '3', '10', 120, '@ Heavier than Last Week / Rest 2:00', 3 FROM weeks w WHERE w.week_number = 2;

-- C. Seated DB Arnold Press 3x12 Rest 1:30 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'C', 'Seated DB Arnold Press', '3', '12', 90, 'Rest 1:30 b/w sets', 4 FROM weeks w WHERE w.week_number = 2;

-- D. 3 Sets: 30 Russian Twist / 20 Slow Knee Tucks Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Russian Twist', '3', '30', NULL, NULL, 5 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'D', 'Slow Knee Tucks', '3', '20', 60, 'Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 2;

-- E. 4 Sets: 5:00 Run @ Moderate (Faster) / 1:30 Recovery Jog * Faster than Last Week
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 4, 'E', '5:00 Run @ Moderate (Faster)', '4', '5:00', NULL, '1:30 Recovery Jog / * Faster than Last Week', 7 FROM weeks w WHERE w.week_number = 2;


-- ============ Day 5 ============
-- 박스 와드
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'WOD', '박스 와드', NULL, NULL, NULL, NULL, 0 FROM weeks w WHERE w.week_number = 2;

-- A. 6 sets of: 10/10 Bulgarian Split Squat / 10 Good Morning w/ Barbell *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Bulgarian Split Squat', '6', '10/10', NULL, NULL, 1 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'A', 'Good Morning w/ Barbell', '6', '10', NULL, '* Rest as needed between sets', 2 FROM weeks w WHERE w.week_number = 2;

-- B. 4 sets: 30's Wall Sit / 16 Weighted Alternating DB Lunges *Rest as needed between sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Wall Sit', '4', '30''s', NULL, NULL, 3 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'B', 'Weighted Alternating DB Lunges', '4', '16', NULL, '* Rest as needed between sets', 4 FROM weeks w WHERE w.week_number = 2;

-- C. Superset 3 Sets: 15 DB Curls / 15 DB Skull Crusher *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Curls', '3', '15', NULL, 'Superset', 5 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'C', 'DB Skull Crusher', '3', '15', 60, '* Rest 1:00 b/w sets', 6 FROM weeks w WHERE w.week_number = 2;

-- D. Superset 3 Sets: 20 Banded Tricep Pushdown / 20 Alter DB Hammer Curls *Rest 1:00 b/w sets
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Banded Tricep Pushdown', '3', '20', NULL, 'Superset', 7 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'D', 'Alter DB Hammer Curls', '3', '20', 60, '* Rest 1:00 b/w sets', 8 FROM weeks w WHERE w.week_number = 2;

-- E. EMOM 15 (5 Sets): 0:30 Max Cal Ski-erg / 0:30 Max Bent Over Plate Row / 0:30 Max DB Lateral Raises
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max Cal Ski-erg', '5', '0:30', NULL, 'EMOM 15 (5 Sets)', 9 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max Bent Over Plate Row', '5', '0:30', NULL, NULL, 10 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'E', '0:30 Max DB Lateral Raises', '5', '0:30', NULL, NULL, 11 FROM weeks w WHERE w.week_number = 2;

-- F. EMOM 10 (5 Sets): 0:20 Hollow Rock Hold / 10/10 Side Plank Hip Touch
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', '0:20 Hollow Rock Hold', '5', '0:20', NULL, 'EMOM 10 (5 Sets)', 12 FROM weeks w WHERE w.week_number = 2;
INSERT INTO workout_templates (week_id, day_number, section, exercise_name, sets, reps, rest_seconds, notes, sort_order)
SELECT w.id, 5, 'F', '10/10 Side Plank Hip Touch', '5', '10/10', NULL, NULL, 13 FROM weeks w WHERE w.week_number = 2;
