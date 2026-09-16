import { supabase } from '@/lib/supabase'
import type { WorkoutExercise } from './workouts'
import { buildLogRowsForWorkouts } from '@/lib/workout/log-rows'

export interface WorkoutLog {
  id?: string
  user_id?: string
  date: string
  template_id: string | null
  workout_exercise_id: string | null
  is_custom: boolean
  exercise_name: string
  section: string | null
  completed: boolean
  weight_lb: number | null
  weight_unit: 'lb' | 'kg'
  memo: string | null
  custom_sets: string | null
  custom_reps: string | null
  custom_notes: string | null
  set_group?: number | null
  set_info?: string | null
  set_lead?: string | null
}

export async function getWorkoutLogs(date: string, userId: string) {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('*')
    .eq('date', date)
    .eq('user_id', userId)
    .order('created_at', { ascending: true })
  if (error) throw error
  return data
}

export async function upsertWorkoutLog(log: WorkoutLog) {
  if (log.id) {
    const { error } = await supabase
      .from('workout_logs')
      .update({
        completed: log.completed,
        weight_lb: log.weight_lb,
        weight_unit: log.weight_unit,
        memo: log.memo,
      })
      .eq('id', log.id)
    if (error) throw error
  } else {
    const { data, error } = await supabase
      .from('workout_logs')
      .insert(log)
      .select()
      .single()
    if (error) throw error
    return data
  }
}

export async function batchInsertWorkoutLogs(logs: Omit<WorkoutLog, 'id'>[]) {
  if (logs.length === 0) return []
  const { data, error } = await supabase
    .from('workout_logs')
    .insert(logs)
    .select()
  if (error) throw error
  return data
}

export async function addCustomExercise(
  date: string,
  exerciseName: string,
  userId: string,
  section?: string,
  customSets?: string,
  customReps?: string,
) {
  const { data, error } = await supabase
    .from('workout_logs')
    .insert({
      date,
      user_id: userId,
      template_id: null,
      is_custom: true,
      exercise_name: exerciseName,
      section: section || null,
      completed: false,
      weight_lb: null,
      weight_unit: 'lb',
      memo: null,
      custom_sets: customSets || null,
      custom_reps: customReps || null,
      custom_notes: null,
    })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateCustomExercise(
  id: string,
  fields: {
    exercise_name: string
    section: string | null
    custom_sets: string | null
    custom_reps: string | null
  },
) {
  const { error } = await supabase
    .from('workout_logs')
    .update(fields)
    .eq('id', id)
  if (error) throw error
}

export async function deleteWorkoutLog(id: string) {
  const { error } = await supabase
    .from('workout_logs')
    .delete()
    .eq('id', id)
  if (error) throw error
}

// 그날 카드 통째로 빼기: 해당 로그 id들 일괄 삭제. (운동 정의는 보존 — 다음에 다시 담기 가능)
export async function deleteWorkoutLogs(ids: string[]) {
  if (ids.length === 0) return
  const { error } = await supabase
    .from('workout_logs')
    .delete()
    .in('id', ids)
  if (error) throw error
}

export async function searchWorkoutLogs(
  query: string,
  userId: string,
  completedOnly: boolean = true
) {
  let q = supabase
    .from('workout_logs')
    .select('*')
    .eq('user_id', userId)
    .ilike('exercise_name', `%${query}%`)

  if (completedOnly) {
    q = q.eq('completed', true)
  }

  const { data, error } = await q
    .order('date', { ascending: false })
    .order('section', { ascending: true })
    .order('created_at', { ascending: true })
  if (error) throw error
  return data
}

export type WorkoutLogJoined = WorkoutLog & {
  workout?: { workout_id: string; title: string; owner_user_id: string | null; program_label: string | null; category: string | null } | null
}

export async function getWorkoutLogsWithWorkout(
  date: string,
  userId: string,
): Promise<WorkoutLogJoined[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select(
      'id, user_id, date, created_at, template_id, workout_exercise_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo, custom_sets, custom_reps, custom_notes, set_group, set_info, set_lead, ' +
        'workout_exercises ( workout_id, sort_order, workouts ( title, owner_user_id, program_label, category ) ), ' +
        'workout_templates ( sets, reps, notes, sort_order )',
    )
    .eq('date', date)
    .eq('user_id', userId)
  if (error) throw error
  // 동작 표시 순서. 시즌2 로그는 workout_exercises.sort_order, 시즌1 템플릿 로그는
  // workout_templates.sort_order로 원래 순서가 보존돼 있다. 둘 다 없으면(커스텀) 동순위 →
  // created_at·id로 안정 정렬. 예전엔 we.sort_order만 봐서 템플릿/커스텀 행이 비결정적
  // 순서로 와 '같은 섹션 안 동작이 뒤섞여' 보이던 문제 해결.
  const orderKey = (r: Record<string, unknown>): number => {
    const we = (r.workout_exercises as { sort_order?: number } | null)?.sort_order
    const tpl = (r.workout_templates as { sort_order?: number } | null)?.sort_order
    return we ?? tpl ?? 9999
  }
  const sorted = ((data ?? []) as unknown as Record<string, unknown>[]).slice().sort((a, b) => {
    const d = orderKey(a) - orderKey(b)
    if (d !== 0) return d
    const ca = String(a.created_at ?? ''), cb = String(b.created_at ?? '')
    if (ca !== cb) return ca < cb ? -1 : 1
    return String(a.id ?? '') < String(b.id ?? '') ? -1 : 1
  })
  return sorted.map((row) => {
    const we = row.workout_exercises as
      | { workout_id: string; sort_order?: number; workouts?: { title: string; owner_user_id: string | null; program_label: string | null; category: string | null } | null }
      | null
    const tmpl = row.workout_templates as { sets: string | null; reps: string | null; notes: string | null } | null
    const { workout_exercises, workout_templates, ...rest } = row
    void workout_exercises
    void workout_templates
    const base = rest as unknown as WorkoutLog
    return {
      ...base,
      // 시즌1 레거시 등 template 연결 로그: 세트/횟수/노트가 workout_templates에 있음 → 렌더용 custom_*로 보강
      custom_sets: base.custom_sets || tmpl?.sets || null,
      custom_reps: base.custom_reps || tmpl?.reps || null,
      custom_notes: base.custom_notes || tmpl?.notes || null,
      workout: we
        ? { workout_id: we.workout_id, title: we.workouts?.title ?? '', owner_user_id: we.workouts?.owner_user_id ?? null, program_label: we.workouts?.program_label ?? null, category: we.workouts?.category ?? null }
        : null,
    }
  })
}

// 여러 운동을 한 날짜에 한 번에 담는다. 라운드트립 3번(동작 일괄조회 → 그날 로그 조회 → 삽입)
// 으로 고정 — 예전엔 운동당 4번씩 순차라 하루 6~7장이면 24~28번 왕복이었다.
// 중복 판정은 buildLogRowsForWorkouts(순수·테스트됨): we_id가 이미 있으면 그 운동 통째 건너뜀,
// 이름이 이미 있으면 그 동작만 제외(박스 와드 placeholder 방어), 같은 배치 앞 카드가 담은
// 이름도 뒤 카드에서 제외(순차 호출과 동일 결과).
export async function addWorkoutsToDate(
  userId: string,
  date: string,
  workoutIds: string[],
): Promise<WorkoutLog[]> {
  if (workoutIds.length === 0) return []
  const { data: exData, error: ee } = await supabase
    .from('workout_exercises')
    .select('*')
    .in('workout_id', workoutIds)
    .order('sort_order', { ascending: true })
  if (ee) throw ee
  const byWorkout = new Map<string, WorkoutExercise[]>()
  for (const ex of (exData ?? []) as WorkoutExercise[]) {
    const arr = byWorkout.get(ex.workout_id)
    if (arr) arr.push(ex)
    else byWorkout.set(ex.workout_id, [ex])
  }
  if (byWorkout.size === 0) return []

  const { data: existing, error: xe } = await supabase
    .from('workout_logs')
    .select('workout_exercise_id, exercise_name')
    .eq('user_id', userId)
    .eq('date', date)
  if (xe) throw xe
  const exist = (existing ?? []) as { workout_exercise_id: string | null; exercise_name: string }[]

  const rows = buildLogRowsForWorkouts({
    userId,
    date,
    workouts: workoutIds.map((id) => ({ workoutId: id, exercises: byWorkout.get(id) ?? [] })),
    existingExerciseIds: new Set(exist.map((r) => r.workout_exercise_id).filter((v): v is string => !!v)),
    existingNames: new Set(exist.map((r) => r.exercise_name)),
  })
  return batchInsertWorkoutLogs(rows)
}

export async function addWorkoutToDate(
  userId: string,
  date: string,
  workoutId: string,
): Promise<WorkoutLog[]> {
  return addWorkoutsToDate(userId, date, [workoutId])
}

// 캘린더용: 기간 내 '완료 동작이 1개 이상' 있는 날짜 목록(중복 제거).
export async function getCompletedDatesInRange(
  userId: string,
  startDate: string,
  endDate: string,
): Promise<string[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date')
    .eq('user_id', userId)
    .eq('completed', true)
    .gte('date', startDate)
    .lte('date', endDate)
  if (error) throw error
  const dates = (data ?? []).map((r: { date: string }) => r.date)
  return [...new Set(dates)]
}

// 캘린더용: 기간 내 운동 로그가 '있는' 모든 날짜(완료 무관, 중복 제거).
export async function getWorkoutDatesInRange(
  userId: string,
  startDate: string,
  endDate: string,
): Promise<string[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date')
    .eq('user_id', userId)
    .gte('date', startDate)
    .lte('date', endDate)
  if (error) throw error
  const dates = (data ?? []).map((r: { date: string }) => r.date)
  return [...new Set(dates)]
}
