-- 공용 기본운동 시드 (owner_user_id = null). default_weekday: 1=월 .. 5=금.
-- chacha가 운동별로 아래 블록을 복제해 채운다.
-- ※ 아래 내용은 2026-06-26 anon REST로 이미 라이브 DB에 적용됨. 새 DB 셋업 시에만 실행.

-- 박스 와드: 월~금 공용 기본운동, 최상단(sort_order 0). 동작 1개(완료 체크용).
insert into workouts (title, owner_user_id, default_weekday, category, sort_order)
select '박스 와드', null, wd, null, 0
from generate_series(1, 5) as wd;

insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order)
select id, null, '박스 와드', null, null, null, 0
from workouts
where owner_user_id is null and title = '박스 와드';

-- 예시: 월요일 "어깨·가슴" (sort_order 1 = 박스 와드 아래). 공용 category는 표시용.
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, sort_order)
  values ('어깨·가슴', null, 1, '가슴', 1)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order)
select w.id, v.section, v.exercise_name, v.sets, v.reps, v.notes, v.sort_order
from w, (values
  ('A', '바벨 숄더프레스', '4 sets', '8-10', null, 0),
  ('A', '인클라인 덤벨프레스', '4 sets', '10-12', null, 1)
) as v(section, exercise_name, sets, reps, notes, sort_order);
