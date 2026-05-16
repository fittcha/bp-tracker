import { supabase } from '../supabase'

export interface CardioLog {
  id?: string
  user_id: string
  date: string
  completed: boolean
  memo: string | null
  session_number: number
}

// 특정 날짜 cardio_logs 전체 조회 (세션 순)
export async function getCardioLogs(date: string, userId: string): Promise<CardioLog[]> {
  const { data } = await supabase
    .from('cardio_logs')
    .select('*')
    .eq('user_id', userId)
    .eq('date', date)
    .order('session_number')
  return data ?? []
}

// upsert cardio_log (session_number 포함)
export async function upsertCardioLog(log: CardioLog) {
  const { data, error } = await supabase
    .from('cardio_logs')
    .upsert(log, { onConflict: 'user_id,date,session_number' })
    .select()
    .single()
  if (error) throw error
  return data
}

// cardio_log 삭제
export async function deleteCardioLog(id: string) {
  const { error } = await supabase
    .from('cardio_logs')
    .delete()
    .eq('id', id)
  if (error) throw error
}

// 주간 누적 카운트 (월~일 범위, completed된 세션 수 합산)
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
