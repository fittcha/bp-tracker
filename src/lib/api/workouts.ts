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
  name: string                 // 'Strength 8주' (라벨의 ' · ' 앞부분)
  startDate: string            // 첫 세션 날짜 'YYYY-MM-DD'
  totalWeeks: number | null
  currentWeek: number | null   // null = 아직 시작 전
  status: 'upcoming' | 'active' | 'done'
}

// 홈 배너용: 활성 공용 프로그램의 진행 상태. 오늘 기준 시작 전/진행 중/완료 + 현재 주차(날짜로 계산).
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
  const startDate = rows[0].program_date
  const endDate = rows[rows.length - 1].program_date
  const firstLabel = rows[0].program_label
  const name = firstLabel.split(' · ')[0]
  const totMatch = firstLabel.match(/(\d+)\s*주\s*·/)
  const totalWeeks = totMatch ? Number(totMatch[1]) : null
  let status: CurrentProgram['status']
  let currentWeek: number | null
  if (today < startDate) {
    status = 'upcoming'
    currentWeek = null
  } else if (today > endDate) {
    status = 'done'
    currentWeek = totalWeeks
  } else {
    status = 'active'
    const days = Math.floor((Date.parse(today) - Date.parse(startDate)) / 86_400_000)
    const wk = Math.floor(days / 7) + 1
    currentWeek = totalWeeks ? Math.min(wk, totalWeeks) : wk
  }
  // TEMP 하드코딩(미리보기용): 강제 진행 중 2주차. 7/6 시작 후 이 2줄 삭제.
  status = 'active'
  currentWeek = 2
  return { name, startDate, totalWeeks, currentWeek, status }
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

