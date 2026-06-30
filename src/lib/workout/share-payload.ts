import type { Workout, WorkoutExercise } from '@/lib/api/workouts'

export interface SharePayload {
  title: string
  category: string | null
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[]
}

// 원본 개인운동 → 공유 스냅샷. id/workout_id 제거, sort_order 순 보존(set_group/set_info/set_lead 포함).
export function buildSharePayload(
  workout: Pick<Workout, 'title' | 'category'>,
  exercises: WorkoutExercise[],
): SharePayload {
  return {
    title: workout.title,
    category: workout.category ?? null,
    exercises: exercises
      .slice()
      .sort((a, b) => a.sort_order - b.sort_order)
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      .map(({ id, workout_id, ...rest }) => rest),
  }
}

export function isBlankQuery(query: string): boolean {
  return query.trim() === ''
}

// 실제로 새로 insert할 수신자: 입력 중복 제거 + 이미 대기 중인 수신자 제외.
export function filterNewRecipients(toIds: string[], existingPendingToIds: string[]): string[] {
  const seen = new Set(existingPendingToIds)
  const out: string[] = []
  for (const id of toIds) {
    if (seen.has(id)) continue
    seen.add(id)
    out.push(id)
  }
  return out
}
