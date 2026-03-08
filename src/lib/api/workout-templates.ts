import { supabase } from '@/lib/supabase'

export interface WorkoutTemplate {
  id?: string
  week_id: string
  day_number: number
  section: string
  exercise_name: string
  sets: number | null
  reps: string | null
  rest_seconds: number | null
  notes: string | null
  sort_order: number
}

export async function getWeeks() {
  const { data, error } = await supabase
    .from('weeks')
    .select('*')
    .order('week_number', { ascending: true })
  if (error) throw error
  return data
}

export async function getTemplatesByWeek(weekId: string) {
  const { data, error } = await supabase
    .from('workout_templates')
    .select('*')
    .eq('week_id', weekId)
    .order('day_number', { ascending: true })
    .order('sort_order', { ascending: true })
  if (error) throw error
  return data
}

export async function createTemplate(data: Omit<WorkoutTemplate, 'id'>) {
  const { data: result, error } = await supabase
    .from('workout_templates')
    .insert(data)
    .select()
    .single()
  if (error) throw error
  return result
}

export async function updateTemplate(id: string, data: Partial<WorkoutTemplate>) {
  const { error } = await supabase
    .from('workout_templates')
    .update(data)
    .eq('id', id)
  if (error) throw error
}

export async function deleteTemplate(id: string) {
  const { error } = await supabase
    .from('workout_templates')
    .delete()
    .eq('id', id)
  if (error) throw error
}

export async function copyWeekTemplates(fromWeekId: string, toWeekId: string) {
  const templates = await getTemplatesByWeek(fromWeekId)
  if (!templates?.length) return

  const newTemplates = templates.map(({ id, week_id, ...rest }) => ({
    ...rest,
    week_id: toWeekId,
  }))

  const { error } = await supabase
    .from('workout_templates')
    .insert(newTemplates)
  if (error) throw error
}
