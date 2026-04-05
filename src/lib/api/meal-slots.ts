import { supabase } from '../supabase'

export interface MealSlotConfig {
  id?: string
  user_id: string
  effective_date: string
  slot_count: number
}

// 특정 날짜에 적용되는 슬롯 수 조회 (effective_date <= date 중 가장 최근)
export async function getMealSlotCount(date: string, userId: string): Promise<number> {
  const { data } = await supabase
    .from('meal_slot_configs')
    .select('slot_count')
    .eq('user_id', userId)
    .lte('effective_date', date)
    .order('effective_date', { ascending: false })
    .limit(1)
    .single()
  return data?.slot_count ?? 0
}

// 슬롯 설정 추가/업데이트 (해당 날짜에 새 config)
export async function upsertMealSlotConfig(userId: string, date: string, slotCount: number) {
  const { data, error } = await supabase
    .from('meal_slot_configs')
    .upsert(
      { user_id: userId, effective_date: date, slot_count: slotCount },
      { onConflict: 'user_id,effective_date' }
    )
    .select()
    .single()
  if (error) throw error
  return data
}
