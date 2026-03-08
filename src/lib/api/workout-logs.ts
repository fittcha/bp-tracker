import { supabase } from '@/lib/supabase'

export interface WorkoutLog {
  id?: string
  date: string
  template_id: string | null
  is_custom: boolean
  exercise_name: string
  section: string | null
  completed: boolean
  weight_lb: number | null
  memo: string | null
}

export async function getWorkoutLogs(date: string) {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('*')
    .eq('date', date)
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

export async function addCustomExercise(date: string, exerciseName: string) {
  const { data, error } = await supabase
    .from('workout_logs')
    .insert({
      date,
      template_id: null,
      is_custom: true,
      exercise_name: exerciseName,
      section: null,
      completed: false,
      weight_lb: null,
      memo: null,
    })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function deleteWorkoutLog(id: string) {
  const { error } = await supabase
    .from('workout_logs')
    .delete()
    .eq('id', id)
  if (error) throw error
}
