-- 챌린지 시드 v2 (제공 챌린지: 푸쉬업 6주 / 풀업 4주)
-- migration-challenges.sql + migration-challenges-2.sql 적용 이후 실행.
-- 재실행 안전: 아래 wipe로 기존 프로그램/일 데이터를 비우고 재시드한다.
--   ⚠️ user_challenges(진행 인스턴스)와 그 attempts(이력)도 함께 삭제된다(QA 데이터 초기화).
--      실사용 데이터가 쌓인 뒤에는 wipe 블록을 빼고 신중히 갱신할 것.

-- ── 0) 기존 데이터 wipe (QA 초기화) ─────────────────────────────
delete from user_challenges;  -- challenge_attempts는 FK cascade로 함께 삭제
delete from challenge_programs where template_key in ('pushup', 'pullup');  -- program_days FK cascade

-- ── 1) 템플릿 ────────────────────────────────────────────────
insert into challenge_templates (key, name, exercise, difficulty_mode, sort_order) values
  ('pullup', '풀업 챌린지',  '풀업',  'range', 1),
  ('pushup', '푸쉬업 챌린지', '푸쉬업', 'range', 2)
on conflict (key) do update
  set name = excluded.name, exercise = excluded.exercise,
      difficulty_mode = excluded.difficulty_mode, sort_order = excluded.sort_order;

-- ── 2) 푸쉬업: 최대가능개수 3트랙 (시작 시 1회 선택, 6주 고정) ──
insert into challenge_programs (template_key, difficulty_key, label, sort_order) values
  ('pushup', 'le5',    '5개 이하',  1),
  ('pushup', '6to10',  '6~10개',   2),
  ('pushup', '11to20', '11~20개',  3);

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
  (7,3,1,'10·12·7·7·9+',60),
  (8,3,2,'10·12·8·8·12+',90),
  (9,3,3,'11·13·9·9·13+',120),
  (10,4,1,'12·14·11·10·16+',60),
  (11,4,2,'14·16·12·12·18+',90),
  (12,4,3,'16·18·13·13·20+',120),
  (13,5,1,'17·19·15·15·20+',60),
  (14,5,2,'10·10·13·13·10·10·9·25+',45),
  (15,5,3,'13·13·15·15·12·12·10·30+',45),
  (16,6,1,'25·30·20·15·40+',60),
  (17,6,2,'14·14·15·15·14·14·10·10·44+',45),
  (18,6,3,'13·13·17·17·16·16·14·14·50+',45)
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
  (7,3,1,'12·17·13·13·17+',60),
  (8,3,2,'14·19·14·14·19+',90),
  (9,3,3,'16·21·15·15·21+',120),
  (10,4,1,'18·22·16·16·25+',60),
  (11,4,2,'20·25·20·20·28+',90),
  (12,4,3,'23·28·23·23·33+',120),
  (13,5,1,'28·35·25·22·35+',60),
  (14,5,2,'18·18·20·20·14·14·16·40+',45),
  (15,5,3,'18·18·20·20·17·17·20·45+',45),
  (16,6,1,'40·50·25·25·50+',60),
  (17,6,2,'20·20·23·23·20·20·18·18·53+',45),
  (18,6,3,'22·22·30·30·25·25·18·18·55+',45)
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
  (7,3,1,'14·18·14·14·20+',60),
  (8,3,2,'20·25·15·15·25+',90),
  (9,3,3,'22·30·20·20·28+',120),
  (10,4,1,'21·25·21·21·32+',60),
  (11,4,2,'25·29·25·25·36+',90),
  (12,4,3,'29·33·29·29·40+',120),
  (13,5,1,'36·40·30·24·40+',60),
  (14,5,2,'19·19·22·22·18·18·22·45+',45),
  (15,5,3,'20·20·24·24·20·20·22·50+',45),
  (16,6,1,'45·55·35·30·55+',60),
  (17,6,2,'22·22·30·30·24·24·18·18·58+',45),
  (18,6,3,'26·26·33·33·26·26·22·22·60+',45)
) as v(day_no, week_no, diw, sets, rest)
where p.template_key = 'pushup' and p.difficulty_key = '11to20';

-- ── 3) 풀업: 변형 4단계 (횟수 동일, 변형만 다름. 시작 시 택1, 상향은 새 인스턴스) ──
insert into challenge_programs (template_key, difficulty_key, label, sort_order) values
  ('pullup', 'banded',   '밴디드 스트릭 풀업',     1),
  ('pullup', 'strict',   '스트릭 풀업',           2),
  ('pullup', 'c2b',      '스트릭 체스트 투 바',    3),
  ('pullup', 'weighted', '웨이티드 스트릭 풀업',   4);

-- 풀업 day 데이터(4주×5일, R1~R5). 4개 변형 프로그램에 동일 복제(cross join). 휴식 표기 없음(null).
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
  (20,4,5,'8·7·7·6·6')
) as v(day_no, week_no, diw, sets)
where p.template_key = 'pullup';
