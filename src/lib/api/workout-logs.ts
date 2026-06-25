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
  workout?: { workout_id: string; title: string; owner_user_id: string | null } | null
}

export async function getWorkoutLogsWithWorkout(
  date: string,
  userId: string,
): Promise<WorkoutLogJoined[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select(
      'id, user_id, date, template_id, workout_exercise_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo, custom_sets, custom_reps, ' +
        'workout_exercises ( workout_id, workouts ( title, owner_user_id ) )',
    )
    .eq('date', date)
    .eq('user_id', userId)
  if (error) throw error
  return ((data ?? []) as unknown as Record<string, unknown>[]).map((row) => {
    const we = row.workout_exercises as
      | { workout_id: string; workouts?: { title: string; owner_user_id: string | null } | null }
      | null
    const { workout_exercises, ...rest } = row
    void workout_exercises
    return {
      ...(rest as unknown as WorkoutLog),
      workout: we
        ? { workout_id: we.workout_id, title: we.workouts?.title ?? '', owner_user_id: we.workouts?.owner_user_id ?? null }
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
  }))
  if (rows.length === 0) return []
  return batchInsertWorkoutLogs(rows)
}
