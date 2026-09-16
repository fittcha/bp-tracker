import { supabase } from '@/lib/supabase'
import { archiveWorkout, updatePersonalWorkout, type Workout, type WorkoutExercise } from './workouts'
import type { UrbanLogRow } from '@/lib/workout/urban-stats'

// urban 목록은 공용이라 한 사람이 고치면 전원에게 반영된다. 이 앱엔 권한 개념이 없어
// (users에 role 없음, PIN 전원 공용) 이 게이트는 보안이 아니라 '오조작 방지'다 —
// 목적은 일반 회원 화면에 편집 UI가 아예 안 보이게 하는 것. 코치가 늘면 배열에 추가한다.
export const URBAN_EDITORS = ['chacha']

export function canEditUrban(username?: string | null): boolean {
  return !!username && URBAN_EDITORS.includes(username)
}

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

// ── 편집 (코치 계정 전용 UI에서만 호출) ──

// 새 urban 훈련. sort_order는 현재 최대 + 1 → 목록 맨 아래에 붙는다.
export async function createUrbanTraining(
  title: string,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<Workout> {
  const { data: last, error: le } = await supabase
    .from('workouts')
    .select('sort_order')
    .is('owner_user_id', null)
    .is('default_weekday', null)
    .is('program_date', null)
    .eq('category', URBAN_CATEGORY)
    .order('sort_order', { ascending: false })
    .limit(1)
  if (le) throw le
  const nextOrder = ((last?.[0] as { sort_order: number } | undefined)?.sort_order ?? -1) + 1

  const { data, error } = await supabase
    .from('workouts')
    .insert({
      title,
      owner_user_id: null,
      default_weekday: null,
      program_date: null,
      program_label: null,
      category: URBAN_CATEGORY,
      sort_order: nextOrder,
    })
    .select()
    .single()
  if (error) throw error
  const workout = data as Workout
  if (exercises.length > 0) {
    const rows = exercises.map((ex, i) => ({ ...ex, workout_id: workout.id, sort_order: ex.sort_order ?? i }))
    const { error: ee } = await supabase.from('workout_exercises').insert(rows)
    if (ee) throw ee
  }
  return workout
}

// 동작 전체 교체 방식. updatePersonalWorkout이 owner를 안 따지므로 그대로 쓴다.
export async function updateUrbanTraining(
  workoutId: string,
  title: string,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<void> {
  return updatePersonalWorkout(workoutId, title, URBAN_CATEGORY, exercises)
}

// 삭제 = 아카이브. 행을 지우면 이미 담아 기록한 로그의 FK가 끊겨(on delete set null)
// 시즌1 레거시 카드처럼 렌더된다. archived=true면 목록에서만 사라지고 기록은 그대로.
// 복구: update workouts set archived = false where id = ...
export async function archiveUrbanTraining(workoutId: string): Promise<void> {
  return archiveWorkout(workoutId)
}
