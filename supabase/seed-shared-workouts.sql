-- 공용 기본운동 시드 (owner_user_id = null). default_weekday: 1=월 .. 5=금.
-- chacha가 운동별로 아래 블록을 복제해 채운다.

-- 예시: 월요일 "어깨·가슴" (공용 category는 선택 — 팝업엔 안 나오므로 표시용)
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, sort_order)
  values ('어깨·가슴', null, 1, '가슴', 0)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order)
select w.id, v.section, v.exercise_name, v.sets, v.reps, v.notes, v.sort_order
from w, (values
  ('A', '바벨 숄더프레스', '4 sets', '8-10', null, 0),
  ('A', '인클라인 덤벨프레스', '4 sets', '10-12', null, 1)
) as v(section, exercise_name, sets, reps, notes, sort_order);
