-- 제서(ZEST SURVIVOR) 예선 반영 — Strength 8주 프로그램 2주 시프트 (1회성).
-- 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md
--
-- 예선이 7/27(월)~8/5(수)로 진행돼 그 기간 추가운동을 아무도 하지 못했다.
-- 7/27~8/5 = 'ZEST SURVIVOR 예선' 카드 1장, 8/6~8/7 = 스페셜(내용 후속 확정, 여기선 비움),
-- 4~8주차 = 8/10부터 재개(+14일). 라벨은 콘텐츠에 붙어 함께 이동하므로 재작성하지 않는다.
--
-- !!! 멱등하지 않다 — 절대 두 번 실행하지 말 것 !!!
--   2)를 두 번 돌리면 4주가 밀리고, 1)은 시프트 후 정상 로그를 지우고, 3)은 카드를 중복 생성한다.
-- 시드(seed-strength-8week.sql)를 처음부터 새로 돌리는 경우엔 이 파일이 필요 없다(시드에 이미 반영됨).
-- anon 키로 Supabase SQL editor 실행.

-- ===== 0) 사전 점검: 이미 적용됐는지 확인. 0이어야 미적용 =====
select count(*) as already_applied
from workouts
where owner_user_id is null
  and program_label = 'Strength 8주 · 8주차'
  and program_date > '2026-09-01';

-- ===== 1) 껍데기 로그 정리 (기대: 236행) =====
-- 시프트로 전부 stale이 되는 7/27 이후 프로그램 로그. 전량 미완료임을 사전 확인했고,
-- completed = false 조건으로 실제 기록은 절대 지우지 않는다.
-- 이걸 먼저 하지 않으면: 8/24 로그가 9/7로 옮겨간 8주차 카드를 가리킨 채 8/24에 그대로
-- 렌더돼, 새로 담기는 6주차와 겹쳐 보인다.
delete from workout_logs wl
using workout_exercises we, workouts w
where wl.workout_exercise_id = we.id
  and we.workout_id = w.id
  and w.owner_user_id is null
  and w.program_label like 'Strength 8주%'
  and wl.date >= '2026-07-27'
  and wl.completed = false;

-- ===== 2) 4~8주차 2주 시프트 (기대: 143행) =====
update workouts
set program_date = program_date + 14
where owner_user_id is null
  and program_label like 'Strength 8주%'
  and program_date >= '2026-07-27';

-- ===== 3) 예선 카드 8일치 삽입 (평일 8일 · 날짜당 카드 1장 · 동작 1행) =====
-- program_label = null → getCurrentProgram이 라벨 있는 행만 프로그램 범위로 보므로
-- 헤더 배너의 시작/종료/주차 계산에 영향 없음.
with d(program_date) as (values
  ('2026-07-27'::date), ('2026-07-28'), ('2026-07-29'), ('2026-07-30'),
  ('2026-07-31'), ('2026-08-03'), ('2026-08-04'), ('2026-08-05')
), w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  select 'ZEST SURVIVOR 예선', null, null, '측정', d.program_date, null, 0 from d
  returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;

-- ===== 4) 사후 검증 =====
-- (a) stale 로그 0건이어야 한다
select count(*) as stale_logs
from workout_logs wl
join workout_exercises we on we.id = wl.workout_exercise_id
join workouts w on w.id = we.workout_id
where w.program_label like 'Strength 8주%' and wl.date >= '2026-07-27';

-- (b) 날짜별 카드 수/라벨. 7/27~8/5=예선(label null), 8/6~8/7=없음,
--     8/10~8/14=4주차 … 9/7~9/11=8주차
select program_date, coalesce(program_label, title) as label, count(*) as cards
from workouts
where owner_user_id is null and program_date >= '2026-07-20'
group by 1, 2
order by 1;
