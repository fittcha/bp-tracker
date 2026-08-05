// 자동담기/운동담기의 삽입 행 계산 — 순수 함수(DB 접근 없음).
//
// 예전엔 워크아웃 하나당 addWorkoutToDate가 라운드트립 4번(동작 조회 → we_id 중복검사 →
// 이름 중복검사 → 삽입)을 순차로 돌아, 하루 6~7장이면 24~28번 왕복 = 1~3초였다.
// 조회 2번 + 삽입 1번으로 묶고 그 사이 판정을 여기로 뺐다.
//
// 순차 호출과 결과가 같아야 한다: 앞 워크아웃이 담은 이름은 뒤 워크아웃에서 제외된다
// (실제 사례 2026-07-14 'DB Arnold Press'가 두 카드에 걸침). 단 한 카드 안의 같은 이름
// 2행(메인 + 백오프)은 둘 다 남긴다 — 예전 동작과 동일.

import type { WorkoutExercise } from '@/lib/api/workouts'
import type { WorkoutLog } from '@/lib/api/workout-logs'

export interface BuildLogRowsInput {
  userId: string
  date: string
  /** 담을 순서대로. exercises는 카드 안 sort_order 순. */
  workouts: { workoutId: string; exercises: WorkoutExercise[] }[]
  /** 그날 이미 있는 로그의 workout_exercise_id */
  existingExerciseIds: ReadonlySet<string>
  /** 그날 이미 있는 로그의 exercise_name */
  existingNames: ReadonlySet<string>
}

export function buildLogRowsForWorkouts({
  userId,
  date,
  workouts,
  existingExerciseIds,
  existingNames,
}: BuildLogRowsInput): Omit<WorkoutLog, 'id'>[] {
  const claimedNames = new Set(existingNames)
  const rows: Omit<WorkoutLog, 'id'>[] = []

  for (const { exercises } of workouts) {
    if (exercises.length === 0) continue
    // 멱등: 이 워크아웃의 동작이 하나라도 그날 담겨 있으면 통째로 건너뛴다.
    if (exercises.some((ex) => existingExerciseIds.has(ex.id))) continue

    for (const ex of exercises) {
      if (claimedNames.has(ex.exercise_name)) continue
      rows.push({
        user_id: userId,
        date,
        template_id: null,
        workout_exercise_id: ex.id,
        is_custom: false,
        exercise_name: ex.exercise_name,
        section: ex.section,
        completed: false,
        weight_lb: null,
        weight_unit: 'lb',
        memo: null,
        custom_sets: ex.sets,
        custom_reps: ex.reps,
        custom_notes: ex.notes,
        set_group: ex.set_group ?? 1,
        set_info: ex.set_info ?? null,
        set_lead: ex.set_lead ?? null,
      })
    }
    // 카드 단위로 이름을 누적한다 — 카드 안 중복은 허용하고, 뒤 카드에서만 막기 위해.
    for (const ex of exercises) claimedNames.add(ex.exercise_name)
  }

  return rows
}
