-- 개인 운동 "세트 그룹" 구조: workout_exercises / workout_logs 에 그룹 컬럼 추가.
-- 기존 컬럼(section/sets 등)은 공용·시즌1 호환 위해 유지. 개인운동만 set_group/set_info 사용.
-- 설계: docs/superpowers/specs/2026-06-28-personal-workout-set-group-builder-design.md

alter table workout_exercises
  add column if not exists set_group int,    -- 그룹 순서(1-based). 개인운동만
  add column if not exists set_info  text;   -- 그룹 헤더(예: '3 Sets'). null 가능

alter table workout_logs
  add column if not exists set_group int,
  add column if not exists set_info  text;
