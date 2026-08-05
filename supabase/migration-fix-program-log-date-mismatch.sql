-- 날짜기반 공용 프로그램 로그의 날짜 불일치 정리 + 점검.
-- 불변식: 공용 프로그램 카드에 연결된 로그는 wl.date = w.program_date 여야 한다.
--
-- 왜 깨졌나 (2026-08-05):
--   제서 예선 2주 시프트로 카드가 8/11·8/14로 옮겨간 뒤, localStorage SWR 백업 캐시
--   (src/lib/swr/provider.ts)에 남아 있던 시프트 이전 dayDefaults(7/28·7/31)로 자동담기가
--   실행돼 옛 카드가 과거 날짜에 다시 담겼다(11행, 전부 미완료).
--   코드 쪽 재발 방지는 src/lib/workout/pick-missing.ts — 카드의 program_date가 그 날짜와
--   다르면 담지 않는다. 이 파일은 이미 생긴 오염을 지운다.
--
-- 상수(기준일·라벨)가 없어 언제든 다시 돌려도 되는 점검/정리 쿼리다.
-- anon 키로 Supabase SQL editor 실행.

-- ===== 1) 점검: 어긋난 로그 목록 =====
select wl.date as log_date, w.program_date as card_date, w.title,
       wl.exercise_name, wl.completed, wl.created_at, wl.user_id
from workout_logs wl
join workout_exercises we on we.id = wl.workout_exercise_id
join workouts w on w.id = we.workout_id
where w.owner_user_id is null
  and w.program_date is not null
  and wl.date <> w.program_date
order by wl.date, w.program_date;

-- ===== 2) 정리: 미완료만 삭제 =====
-- completed = true는 남긴다 — 실제로 수행한 기록이면 사람이 판단할 문제다.
-- (2026-08-05 시점 대상 11행, 완료 0행)
delete from workout_logs wl
using workout_exercises we, workouts w
where wl.workout_exercise_id = we.id
  and we.workout_id = w.id
  and w.owner_user_id is null
  and w.program_date is not null
  and wl.date <> w.program_date
  and wl.completed = false;

-- ===== 3) 사후 검증: 0이어야 한다(완료 로그가 남아 있으면 그 수만큼 나온다) =====
select count(*) as mismatched_remaining
from workout_logs wl
join workout_exercises we on we.id = wl.workout_exercise_id
join workouts w on w.id = we.workout_id
where w.owner_user_id is null
  and w.program_date is not null
  and wl.date <> w.program_date;
