import type { WorkoutExercise } from '@/lib/api/workouts'

export interface ExerciseRow {
  id: string
  exercise_name: string
  reps: string // 횟수/시간
  notes: string // 메모
}
export interface SetGroup {
  id: string
  setInfo: string // 그룹 헤더 (예: '3 Sets', 'AMRAP 10')
  rows: ExerciseRow[]
}

// 빌더 그룹 → 저장용 동작 배열. 유효 그룹(동작명 있는 행 ≥1)만, set_group 연속 부여,
// 첫 그룹 set_lead=null, 이후 그룹은 'into'(개인운동=서킷). sets/section은 미사용(null).
export function buildExercisesFromGroups(
  groups: SetGroup[],
): Omit<WorkoutExercise, 'id' | 'workout_id'>[] {
  const exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[] = []
  let order = 0
  let groupNo = 0
  for (const g of groups) {
    const validRows = g.rows.filter((r) => r.exercise_name.trim())
    if (validRows.length === 0) continue
    groupNo++
    const info = g.setInfo.trim() || null
    const lead = groupNo === 1 ? null : 'into'
    for (const r of validRows) {
      exercises.push({
        section: null,
        exercise_name: r.exercise_name.trim(),
        sets: null,
        reps: r.reps.trim() || null,
        notes: r.notes.trim() || null,
        sort_order: order++,
        set_group: groupNo,
        set_info: info,
        set_lead: lead,
      })
    }
  }
  return exercises
}
