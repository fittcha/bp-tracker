-- 풀업 챌린지 5주차(W5) 추가 — 라이브 DB용 surgical patch
-- 기존 규칙 그대로 연장(최상단 세트 9, 하루 총볼륨 35→39).
-- 4개 변형(banded/strict/c2b/weighted)에 동일 복제.
--
-- ✅ 안전: user_challenges / challenge_attempts 를 건드리지 않는다(순수 추가).
-- ✅ 재실행 안전: unique(program_id, day_no) 기준 on conflict do nothing.
-- Supabase SQL 에디터에서 1회 실행. (seed-challenges.sql 은 wipe 블록이 있으니 라이브에서 통째 재실행 금지)

insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, null
from challenge_programs p, (values
  (21,5,1,'9·8·7·6·5'),
  (22,5,2,'9·8·7·6·6'),
  (23,5,3,'9·8·7·7·6'),
  (24,5,4,'9·8·8·7·6'),
  (25,5,5,'9·8·8·7·7')
) as v(day_no, week_no, diw, sets)
where p.template_key = 'pullup'
on conflict (program_id, day_no) do nothing;
