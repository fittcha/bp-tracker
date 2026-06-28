-- 챌린지 v2: 하루 = 세트/라운드 묶음(sets_text) + 주차 구조. target_reps(단일 정수) 폐기.
-- v1(migration-challenges.sql) 적용 이후에 실행한다.
-- 설계: docs/superpowers/specs/2026-06-28-challenge-tab-design.md (§v2)

-- 1) 프로그램 정렬 순서 (난이도 선택 UI 노출 순서)
alter table challenge_programs
  add column if not exists sort_order int not null default 0;

-- 2) program_days: 주차 구조 + 세트 구성 텍스트 + 세트간 휴식
alter table challenge_program_days
  add column if not exists week_no     int,
  add column if not exists day_in_week int,
  add column if not exists sets_text   text,
  add column if not exists rest_seconds int;

-- 3) 단일 정수 목표 폐기 (세트 구성으로 대체)
alter table challenge_program_days
  drop column if exists target_reps;
