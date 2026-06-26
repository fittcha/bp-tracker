import { supabase } from '@/lib/supabase'

// 시즌1 저강도 유산소 기록(레거시 날짜 조회용). 시즌2에선 신규 입력 없음.
export interface CardioLog {
  id: string
  memo: string | null
  completed: boolean
}

export async function getCardioLogs(date: string, userId: string): Promise<CardioLog[]> {
  const { data, error } = await supabase
    .from('cardio_logs')
    .select('id, memo, completed')
    .eq('user_id', userId)
    .eq('date', date)
    .order('session_number', { ascending: true })
  if (error) throw error
  return (data ?? []) as CardioLog[]
}

export async function setCardioCompleted(id: string, completed: boolean): Promise<void> {
  const { error } = await supabase.from('cardio_logs').update({ completed }).eq('id', id)
  if (error) throw error
}
