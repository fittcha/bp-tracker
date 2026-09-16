import { supabase } from '@/lib/supabase'
import type { Workout } from './workouts'
import type { UrbanLogRow } from '@/lib/workout/urban-stats'

// urban 훈련 = 공용이면서 요일/날짜에 매이지 않은 라이브러리 항목.
// owner·weekday·date가 모두 null이라 자동담기 대상이 아니고, 사용자가 명시적으로 담을 때만 들어온다.
// 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md
export const URBAN_CATEGORY = 'urban'

export async function getUrbanTrainings(): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .is('owner_user_id', null)
    .is('default_weekday', null)
    .is('program_date', null)
    .eq('category', URBAN_CATEGORY)
    .eq('archived', false)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

// 통계용: 그 유저의 urban 훈련 로그 전부(완료 여부·메모 포함). 집계는 deriveUrbanStats가 한다.
export async function getUrbanLogs(userId: string): Promise<UrbanLogRow[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date, completed, memo, workout_exercises!inner ( workout_id, workouts!inner ( category ) )')
    .eq('user_id', userId)
    .eq('workout_exercises.workouts.category', URBAN_CATEGORY)
  if (error) throw error
  type Row = {
    date: string
    completed: boolean
    memo: string | null
    workout_exercises?: { workout_id: string } | null
  }
  return ((data ?? []) as unknown as Row[])
    .filter((r) => !!r.workout_exercises?.workout_id)
    .map((r) => ({
      workoutId: r.workout_exercises!.workout_id,
      date: r.date,
      completed: r.completed,
      memo: r.memo,
    }))
}
