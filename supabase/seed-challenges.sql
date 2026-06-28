-- ⚠️ target_reps / 푸쉬업 구간은 임시 샘플. 표 이미지 수령 후 실제 값으로 교체할 것.
insert into challenge_templates (key, name, exercise, difficulty_mode, sort_order) values
  ('pullup', '풀업 챌린지',  '풀업',  'equipment', 1),
  ('pushup', '푸쉬업 챌린지', '푸쉬업', 'range',     2)
on conflict (key) do nothing;

-- 풀업: 공통 프로그램 1개 (difficulty_key = null)
with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pullup', null, '풀업 공통')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,3),(2,4),(3,4),(4,5),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10)) as d(day_no, target_reps)
on conflict (program_id, day_no) do nothing;

-- 푸쉬업: 구간별 프로그램 (니/풀 예시 2개)
with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pushup', 'knee_10_15', '니푸쉬업 (최대 10~15개)')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,5),(2,6),(3,8),(4,10),(5,12)) as d(day_no, target_reps)
on conflict (program_id, day_no) do nothing;

with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pushup', 'full_15_25', '푸쉬업 (최대 15~25개)')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,10),(2,12),(3,15),(4,18),(5,20)) as d(day_no, target_reps)
on conflict (program_id, day_no) do nothing;
