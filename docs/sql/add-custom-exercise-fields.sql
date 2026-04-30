-- 개인 운동 추가 기능 개선: 세트/렙 필드 추가
ALTER TABLE workout_logs
  ADD COLUMN custom_sets text,
  ADD COLUMN custom_reps text;
