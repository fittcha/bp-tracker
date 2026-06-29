import { supabase } from '@/lib/supabase'

export interface Workout {
  id: string
  title: string
  owner_user_id: string | null
  default_weekday: number | null
  category: string | null
  notes: string | null
  archived: boolean
  sort_order: number
  created_by: string | null
  program_date?: string | null   // 공용 프로그램 세션 날짜(YYYY-MM-DD)
  program_label?: string | null  // 프로그램 태그 eyebrow
  created_at?: string
}

export interface WorkoutExercise {
  id: string
  workout_id: string
  section: string | null
  exercise_name: string
  sets: string | null
  reps: string | null
  notes: string | null
  sort_order: number
  set_group?: number | null  // 개인운동 세트 그룹 순서(1-based)
  set_info?: string | null   // 그룹 헤더(예: '3 Sets')
  set_lead?: string | null   // 그룹 위 연결자('into'|자유텍스트|null)
}

// 추가 팝업용: 본인 개인 운동만(공용 제외). 카테고리→sort_order 순. 공용은 요일 자동 제공이라 여기 없음.
export async function getPersonalWorkouts(userId: string): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .eq('owner_user_id', userId)
    .eq('archived', false)
    .order('category', { ascending: true, nullsFirst: false })
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

// 그 요일에 매핑된 공용 기본운동
export async function getDefaultWorkoutsForWeekday(weekday: number): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .is('owner_user_id', null)
    .eq('default_weekday', weekday)
    .eq('archived', false)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

// 그 날짜에 배정된 공용 프로그램 세션 (날짜 기반). owner=공용, sort_order 순.
export async function getWorkoutsForDate(date: string): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .is('owner_user_id', null)
    .eq('program_date', date)
    .eq('archived', false)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

export interface CurrentProgram {
  label: string // 'Strength 8주 · 1주차'
  currentWeek: number | null
  totalWeeks: number | null
}

// 홈 배너용: 현재(또는 다가오는) 주차의 공용 프로그램. 오늘 이후 첫 세션 기준,
// 없으면(종료) 마지막, 프로그램 자체가 없으면 null. 라벨에서 '8주'(전체)·'1주차'(현재) 파싱.
export async function getCurrentProgram(today: string): Promise<CurrentProgram | null> {
  const { data, error } = await supabase
    .from('workouts')
    .select('program_date, program_label')
    .is('owner_user_id', null)
    .not('program_date', 'is', null)
    .not('program_label', 'is', null)
    .eq('archived', false)
    .order('program_date', { ascending: true })
  if (error) throw error
  const rows = (data ?? []) as { program_date: string; program_label: string }[]
  if (rows.length === 0) return null
  const label = (rows.find((r) => r.program_date >= today) ?? rows[rows.length - 1]).program_label
  const m = label.match(/(\d+)\s*주\s*·\s*(\d+)\s*주차/)
  return { label, totalWeeks: m ? Number(m[1]) : null, currentWeek: m ? Number(m[2]) : null }
}

export async function getWorkoutExercises(workoutId: string): Promise<WorkoutExercise[]> {
  const { data, error } = await supabase
    .from('workout_exercises')
    .select('*')
    .eq('workout_id', workoutId)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as WorkoutExercise[]
}

export async function createPersonalWorkout(
  userId: string,
  title: string,
  category: string | null,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<Workout> {
  const { data: w, error: we } = await supabase
    .from('workouts')
    .insert({ title, owner_user_id: userId, created_by: userId, default_weekday: null, category })
    .select()
    .single()
  if (we) throw we
  const workout = w as Workout
  if (exercises.length > 0) {
    const rows = exercises.map((ex, i) => ({ ...ex, workout_id: workout.id, sort_order: ex.sort_order ?? i }))
    const { error: ee } = await supabase.from('workout_exercises').insert(rows)
    if (ee) throw ee
  }
  return workout
}

// 개인 운동 수정: 제목 갱신 + 동작 전량 교체(간단·견고). 기존 로그의 exercise_name은 복사본이라 영향 없음.
export async function updatePersonalWorkout(
  workoutId: string,
  title: string,
  category: string | null,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<void> {
  const { error: te } = await supabase.from('workouts').update({ title, category }).eq('id', workoutId)
  if (te) throw te
  const { error: de } = await supabase.from('workout_exercises').delete().eq('workout_id', workoutId)
  if (de) throw de
  if (exercises.length > 0) {
    const rows = exercises.map((ex, i) => ({ ...ex, workout_id: workoutId, sort_order: ex.sort_order ?? i }))
    const { error: ie } = await supabase.from('workout_exercises').insert(rows)
    if (ie) throw ie
  }
}

export async function archiveWorkout(workoutId: string): Promise<void> {
  const { error } = await supabase.from('workouts').update({ archived: true }).eq('id', workoutId)
  if (error) throw error
}

