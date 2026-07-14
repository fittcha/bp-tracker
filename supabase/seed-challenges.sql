-- 챌린지 시드 v2 (제공 챌린지: 푸쉬업 6주 / 풀업 5주)
-- migration-challenges.sql + migration-challenges-2.sql 적용 이후 실행.
-- 재실행 안전: 아래 wipe로 기존 프로그램/일 데이터를 비우고 재시드한다.
--   ⚠️ user_challenges(진행 인스턴스)와 그 attempts(이력)도 함께 삭제된다(QA 데이터 초기화).
--      실사용 데이터가 쌓인 뒤에는 wipe 블록을 빼고 신중히 갱신할 것.

-- ── 0) 기존 데이터 wipe (QA 초기화) ─────────────────────────────
delete from user_challenges;  -- challenge_attempts는 FK cascade로 함께 삭제
delete from challenge_programs where template_key in ('pushup', 'pullup');  -- program_days FK cascade

-- ── 1) 템플릿 ────────────────────────────────────────────────
insert into challenge_templates (key, name, exercise, difficulty_mode, sort_order) values
  ('pullup', 'Pull-up',  'Pull-up',  'range', 1),
  ('pushup', 'Push-up',  'Push-up',  'range', 2)
on conflict (key) do update
  set name = excluded.name, exercise = excluded.exercise,
      difficulty_mode = excluded.difficulty_mode, sort_order = excluded.sort_order;

-- ── 2) 푸쉬업: 최대가능개수 4단계 (시작 시 1회 선택, 6주 고정). 원본 pushup_challenge_6weeks.xlsx 기준 ──
insert into challenge_programs (template_key, difficulty_key, label, sort_order) values
  ('pushup', 'le5',    'Max ≤5',    1),
  ('pushup', '6to10',  'Max 6–10',  2),
  ('pushup', '11to20', 'Max 11–20', 3),
  ('pushup', '21to30', 'Max 21–30', 4);

-- 푸쉬업 day 데이터 (day_no, week_no, day_in_week, sets_text, rest_seconds)
-- 트랙 LEFT (le5)
insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, v.rest
from challenge_programs p, (values
  (1,1,1,'2·3·2·2·3+',60),
  (2,1,2,'3·4·2·3·4+',60),
  (3,1,3,'4·5·4·4·5+',60),
  (4,2,1,'4·6·4·4·6+',60),
  (5,2,2,'5·6·4·4·7+',90),
  (6,2,3,'5·7·5·5·8+',120),
  (7,3,1,'4·7·4·4·7+',60),
  (8,3,2,'6·7·4·4·8+',90),
  (9,3,3,'6·8·6·6·9+',120),
  (10,4,1,'5·7·5·5·7+',60),
  (11,4,2,'6·7·5·5·8+',90),
  (12,4,3,'6·8·6·6·10+',120),
  (13,5,1,'5·8·5·5·8+',60),
  (14,5,2,'7·8·5·5·9+',90),
  (15,5,3,'7·9·7·7·10+',120),
  (16,6,1,'6·8·6·6·8+',60),
  (17,6,2,'7·8·6·6·10+',90),
  (18,6,3,'7·10·7·7·11+',120)
) as v(day_no, week_no, diw, sets, rest)
where p.template_key = 'pushup' and p.difficulty_key = 'le5';

-- 트랙 MID (6to10)
insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, v.rest
from challenge_programs p, (values
  (1,1,1,'6·6·4·4·5+',60),
  (2,1,2,'6·8·6·6·7+',60),
  (3,1,3,'8·10·7·7·10+',60),
  (4,2,1,'9·11·8·8·11+',60),
  (5,2,2,'10·12·9·9·13+',90),
  (6,2,3,'12·13·10·10·15+',120),
  (7,3,1,'10·12·9·9·12+',60),
  (8,3,2,'11·13·10·10·14+',90),
  (9,3,3,'13·14·11·11·17+',120),
  (10,4,1,'11·13·10·10·13+',60),
  (11,4,2,'12·14·11·11·16+',90),
  (12,4,3,'14·16·12·12·18+',120),
  (13,5,1,'12·14·10·10·14+',60),
  (14,5,2,'13·16·12·12·17+',90),
  (15,5,3,'16·17·13·13·20+',120),
  (16,6,1,'13·15·11·11·15+',60),
  (17,6,2,'14·17·13·13·18+',90),
  (18,6,3,'17·18·14·14·21+',120)
) as v(day_no, week_no, diw, sets, rest)
where p.template_key = 'pushup' and p.difficulty_key = '6to10';

-- 트랙 RIGHT (11to20)
insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, v.rest
from challenge_programs p, (values
  (1,1,1,'10·12·7·7·9+',60),
  (2,1,2,'10·12·8·8·12+',60),
  (3,1,3,'11·15·9·9·13+',60),
  (4,2,1,'14·14·10·10·15+',60),
  (5,2,2,'14·16·12·12·17+',90),
  (6,2,3,'16·17·14·14·20+',120),
  (7,3,1,'15·15·11·11·17+',60),
  (8,3,2,'15·18·13·13·19+',90),
  (9,3,3,'18·19·15·15·22+',120),
  (10,4,1,'17·17·12·12·18+',60),
  (11,4,2,'17·19·14·14·20+',90),
  (12,4,3,'19·20·17·17·24+',120),
  (13,5,1,'18·18·13·13·20+',60),
  (14,5,2,'18·21·16·16·22+',90),
  (15,5,3,'21·22·18·18·26+',120),
  (16,6,1,'20·20·14·14·21+',60),
  (17,6,2,'20·22·17·17·24+',90),
  (18,6,3,'22·24·20·20·28+',120)
) as v(day_no, week_no, diw, sets, rest)
where p.template_key = 'pushup' and p.difficulty_key = '11to20';

-- 트랙 Lv.4 (21to30)
insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, v.rest
from challenge_programs p, (values
  (1,1,1,'15·18·11·11·14+',60),
  (2,1,2,'15·18·12·12·18+',60),
  (3,1,3,'17·23·14·14·20+',60),
  (4,2,1,'21·21·15·15·23+',60),
  (5,2,2,'21·24·18·18·26+',90),
  (6,2,3,'24·26·21·21·30+',120),
  (7,3,1,'23·23·17·17·25+',60),
  (8,3,2,'23·26·20·20·29+',90),
  (9,3,3,'26·29·23·23·33+',120),
  (10,4,1,'25·25·18·18·28+',60),
  (11,4,2,'25·29·22·22·31+',90),
  (12,4,3,'29·31·25·25·36+',120),
  (13,5,1,'27·27·20·20·30+',60),
  (14,5,2,'27·31·23·23·34+',90),
  (15,5,3,'31·34·27·27·39+',120),
  (16,6,1,'29·29·21·21·32+',60),
  (17,6,2,'29·34·25·25·36+',90),
  (18,6,3,'34·36·29·29·42+',120)
) as v(day_no, week_no, diw, sets, rest)
where p.template_key = 'pushup' and p.difficulty_key = '21to30';

-- ── 3) 풀업: 변형 4단계 (횟수 동일, 변형만 다름. 시작 시 택1, 상향은 새 인스턴스) ──
insert into challenge_programs (template_key, difficulty_key, label, sort_order) values
  ('pullup', 'banded',   'Banded Pull-up',   1),
  ('pullup', 'strict',   'Pull-up',          2),
  ('pullup', 'c2b',      'Chest-to-Bar',     3),
  ('pullup', 'weighted', 'Weighted Pull-up', 4);

-- 풀업 day 데이터(5주×5일, R1~R5). 4개 변형 프로그램에 동일 복제(cross join). 휴식 표기 없음(null).
insert into challenge_program_days (program_id, day_no, week_no, day_in_week, sets_text, rest_seconds)
select p.id, v.day_no, v.week_no, v.diw, v.sets, null
from challenge_programs p, (values
  (1,1,1,'5·4·3·2·1'),
  (2,1,2,'5·4·3·2·2'),
  (3,1,3,'5·4·3·3·2'),
  (4,1,4,'5·4·4·3·2'),
  (5,1,5,'5·4·4·3·3'),
  (6,2,1,'6·5·4·3·2'),
  (7,2,2,'6·5·4·3·3'),
  (8,2,3,'6·5·4·4·3'),
  (9,2,4,'6·5·5·4·3'),
  (10,2,5,'6·5·5·4·4'),
  (11,3,1,'7·6·5·4·3'),
  (12,3,2,'7·6·5·4·4'),
  (13,3,3,'7·6·5·5·4'),
  (14,3,4,'7·6·6·5·4'),
  (15,3,5,'7·6·6·5·5'),
  (16,4,1,'8·7·6·5·4'),
  (17,4,2,'8·7·6·5·5'),
  (18,4,3,'8·7·6·6·5'),
  (19,4,4,'8·7·7·6·5'),
  (20,4,5,'8·7·7·6·6'),
  (21,5,1,'9·8·7·6·5'),
  (22,5,2,'9·8·7·6·6'),
  (23,5,3,'9·8·7·7·6'),
  (24,5,4,'9·8·8·7·6'),
  (25,5,5,'9·8·8·7·7')
) as v(day_no, week_no, diw, sets)
where p.template_key = 'pullup';
