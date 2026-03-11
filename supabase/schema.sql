-- BP Tracker Database Schema
-- Run this in Supabase SQL Editor

-- weeks: 15주 프로그램 주차 정보
create table weeks (
  id uuid default gen_random_uuid() primary key,
  week_number int not null unique check (week_number between 1 and 15),
  phase text not null,
  start_date date not null,
  end_date date not null
);

-- workout_templates: 코치가 제시한 주차별 운동
create table workout_templates (
  id uuid default gen_random_uuid() primary key,
  week_id uuid references weeks(id) on delete cascade,
  day_number int not null check (day_number between 1 and 7),
  section text not null,
  exercise_name text not null,
  sets int,
  reps text,
  rest_seconds int,
  notes text,
  sort_order int not null default 0
);

-- workout_logs: 일일 운동 기록
create table workout_logs (
  id uuid default gen_random_uuid() primary key,
  date date not null,
  template_id uuid references workout_templates(id) on delete set null,
  is_custom boolean not null default false,
  exercise_name text not null,
  section text,
  completed boolean not null default false,
  weight_lb decimal,
  weight_unit text not null default 'lb',
  memo text,
  created_at timestamp with time zone default now()
);

-- daily_logs: 일일 컨디션 기록
create table daily_logs (
  id uuid default gen_random_uuid() primary key,
  date date not null unique,
  weight_kg decimal,
  sleep_time time,
  wake_time time,
  sleep_hours decimal,
  workout_done boolean default false,
  sugar_processed text default 'X',
  total_calories int,
  carbs_g decimal,
  protein_g decimal,
  fat_g decimal,
  food_image_url text,
  supplements text,
  water_liters decimal,
  memo text,
  created_at timestamp with time zone default now()
);

-- weeks 시드 데이터
insert into weeks (week_number, phase, start_date, end_date) values
  (1, 'Reset Block', '2026-03-09', '2026-03-15'),
  (2, 'Reset Block', '2026-03-16', '2026-03-22'),
  (3, 'Adaptation Cut', '2026-03-23', '2026-03-29'),
  (4, 'Adaptation Cut', '2026-03-30', '2026-04-05'),
  (5, 'Acceleration', '2026-04-06', '2026-04-12'),
  (6, 'Acceleration', '2026-04-13', '2026-04-19'),
  (7, 'Acceleration', '2026-04-20', '2026-04-26'),
  (8, 'Acceleration', '2026-04-27', '2026-05-03'),
  (9, 'Cutting Peak', '2026-05-04', '2026-05-10'),
  (10, 'Cutting Peak', '2026-05-11', '2026-05-17'),
  (11, 'Cutting Peak', '2026-05-18', '2026-05-24'),
  (12, 'Cutting Peak', '2026-05-25', '2026-05-31'),
  (13, 'Cutting Peak', '2026-06-01', '2026-06-07'),
  (14, 'Cutting Peak', '2026-06-08', '2026-06-14'),
  (15, 'Make Up', '2026-06-15', '2026-06-20');
