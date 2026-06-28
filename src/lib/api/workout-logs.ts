import { supabase } from '@/lib/supabase'
import { getWorkoutExercises } from './workouts'

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
  workout?: { workout_id: string; title: string; owner_user_id: string | null; program_label: string | null } | null
}

export async function getWorkoutLogsWithWorkout(
  date: string,
  userId: string,
): Promise<WorkoutLogJoined[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select(
      'id, user_id, date, template_id, workout_exercise_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo, custom_sets, custom_reps, custom_notes, set_group, set_info, set_lead, ' +
        'workout_exercises ( workout_id, workouts ( title, owner_user_id, program_label ) ), ' +
        'workout_templates ( sets, reps, notes )',
    )
    .eq('date', date)
    .eq('user_id', userId)
  if (error) throw error
  return ((data ?? []) as unknown as Record<string, unknown>[]).map((row) => {
    const we = row.workout_exercises as
      | { workout_id: string; workouts?: { title: string; owner_user_id: string | null; program_label: string | null } | null }
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
        ? { workout_id: we.workout_id, title: we.workouts?.title ?? '', owner_user_id: we.workouts?.owner_user_id ?? null, program_label: we.workouts?.program_label ?? null }
        : null,
    }
  })
}

export async function addWorkoutToDate(
  userId: string,
  date: string,
  workoutId: string,
): Promise<WorkoutLog[]> {
  const exercises = await getWorkoutExercises(workoutId)
  const rows: Omit<WorkoutLog, 'id'>[] = exercises.map((ex) => ({
    user_id: userId,
    date,
    template_id: null,
    workout_exercise_id: ex.id,
    is_custom: false,
    exercise_name: ex.exercise_name,
    section: ex.section,
    completed: false,
    weight_lb: null,
    weight_unit: 'lb',
    memo: null,
    custom_sets: ex.sets,
    custom_reps: ex.reps,
    custom_notes: ex.notes,
    set_group: ex.set_group ?? 1,
    set_info: ex.set_info ?? null,
    set_lead: ex.set_lead ?? null,
  }))
  if (rows.length === 0) return []
  return batchInsertWorkoutLogs(rows)
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
