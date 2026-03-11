import { supabase } from '@/lib/supabase'

export interface User1RM {
  id?: string
  user_id: string
  exercise_name: string
  weight: number
  weight_unit: 'lb' | 'kg'
  updated_at?: string
}

const DEFAULT_EXERCISES = [
  '백스쿼트',
  '프론트스쿼트',
  '데드리프트',
  '벤치프레스',
  '숄더프레스',
  '클린',
  '스내치',
]

export { DEFAULT_EXERCISES }

export async function getUser1RMs(userId: string): Promise<User1RM[]> {
  const { data, error } = await supabase
    .from('user_1rm')
    .select('*')
    .eq('user_id', userId)
    .order('updated_at', { ascending: true })
  if (error) throw error
  return data || []
}

export async function upsertUser1RM(record: User1RM) {
  const { error } = await supabase
    .from('user_1rm')
    .upsert(
      {
        user_id: record.user_id,
        exercise_name: record.exercise_name,
        weight: record.weight,
        weight_unit: record.weight_unit,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,exercise_name' }
    )
  if (error) throw error
}

export async function deleteUser1RM(id: string) {
  const { error } = await supabase
    .from('user_1rm')
    .delete()
    .eq('id', id)
  if (error) throw error
}
