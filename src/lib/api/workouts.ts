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

// 운동별 본인 기록 추이: 이 운동의 동작들에 연결된 로그를 날짜순으로
export async function getWorkoutProgress(userId: string, workoutId: string) {
  const { data: exs, error: ee } = await supabase
    .from('workout_exercises')
    .select('id')
    .eq('workout_id', workoutId)
  if (ee) throw ee
  const ids = (exs ?? []).map((e: { id: string }) => e.id)
  if (ids.length === 0) return []
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date, exercise_name, weight_lb, weight_unit, completed')
    .eq('user_id', userId)
    .in('workout_exercise_id', ids)
    .order('date', { ascending: true })
  if (error) throw error
  return (data ?? []) as {
    date: string
    exercise_name: string
    weight_lb: number | null
    weight_unit: 'lb' | 'kg'
    completed: boolean
  }[]
}
