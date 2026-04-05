import { supabase } from '../supabase'

export interface CardioLog {
  id?: string
  user_id: string
  date: string
  completed: boolean
  memo: string | null
}

// 특정 날짜 cardio_log 조회
export async function getCardioLog(date: string, userId: string): Promise<CardioLog | null> {
  const { data } = await supabase
    .from('cardio_logs')
    .select('*')
    .eq('user_id', userId)
    .eq('date', date)
    .single()
  return data
}

// upsert cardio_log
export async function upsertCardioLog(log: CardioLog) {
  const { data, error } = await supabase
    .from('cardio_logs')
    .upsert(log, { onConflict: 'user_id,date' })
    .select()
    .single()
  if (error) throw error
  return data
}

// 주간 누적 카운트 (월~일 범위)
export async function getWeeklyCardioCount(startDate: string, endDate: string, userId: string): Promise<number> {
  const { count } = await supabase
    .from('cardio_logs')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('completed', true)
    .gte('date', startDate)
    .lte('date', endDate)
  return count ?? 0
}
