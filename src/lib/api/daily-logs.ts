import { supabase } from '@/lib/supabase'

export interface DailyLog {
  id?: string
  user_id?: string
  date: string
  weight_kg: number | null
  sleep_time: string | null
  wake_time: string | null
  sleep_hours: number | null
  workout_done: boolean
  sugar_processed: string
  total_calories: number | null
  carbs_g: number | null
  protein_g: number | null
  fat_g: number | null
  food_image_url: string | null
  supplements: string | null
  water_liters: number | null
  memo: string | null
}

export async function getDailyLog(date: string, userId: string): Promise<DailyLog | null> {
  const { data, error } = await supabase
    .from('daily_logs')
    .select('*')
    .eq('date', date)
    .eq('user_id', userId)
    .single()
  if (error && error.code !== 'PGRST116') throw error
  return data
}

export async function upsertDailyLog(log: DailyLog) {
  if (log.id) {
    const { id, ...updateData } = log
    const { error } = await supabase
      .from('daily_logs')
      .update(updateData)
      .eq('id', id)
    if (error) throw error
  } else {
    const { error } = await supabase
      .from('daily_logs')
      .insert(log)
    if (error) throw error
  }
}

export async function uploadFoodImage(file: File, userId: string): Promise<string> {
  const fileName = `${userId}/${Date.now()}-${file.name}`
  const { error } = await supabase.storage
    .from('food-images')
    .upload(fileName, file)
  if (error) throw error

  const { data } = supabase.storage
    .from('food-images')
    .getPublicUrl(fileName)
  return data.publicUrl
}
