import { describe, it, expect } from 'vitest'
import { buildLogRowsForWorkouts } from './log-rows'
import type { WorkoutExercise } from '@/lib/api/workouts'

const ex = (id: string, name: string, over: Partial<WorkoutExercise> = {}): WorkoutExercise => ({
  id,
  workout_id: 'w',
  section: 'A',
  exercise_name: name,
  sets: null,
  reps: '5',
  notes: null,
  sort_order: 0,
  ...over,
})

const base = { userId: 'u1', date: '2026-08-06' }
const empty = { existingExerciseIds: new Set<string>(), existingNames: new Set<string>() }

describe('buildLogRowsForWorkouts', () => {
  it('동작을 순서대로 행으로 만들고 필드를 매핑한다', () => {
    const rows = buildLogRowsForWorkouts({
      ...base,
      ...empty,
      workouts: [{ workoutId: 'w1', exercises: [
        ex('e1', 'Back Squat', { sets: '4', reps: '5', notes: '@ 75%', set_group: 2, set_info: '6 Sets', set_lead: 'into' }),
      ] }],
    })
    expect(rows).toHaveLength(1)
    expect(rows[0]).toMatchObject({
      user_id: 'u1', date: '2026-08-06', exercise_name: 'Back Squat', section: 'A',
      workout_exercise_id: 'e1', template_id: null, is_custom: false, completed: false,
      custom_sets: '4', custom_reps: '5', custom_notes: '@ 75%',
      set_group: 2, set_info: '6 Sets', set_lead: 'into',
    })
  })

  it('set_group이 없으면 1로 채운다', () => {
    const rows = buildLogRowsForWorkouts({
      ...base, ...empty,
      workouts: [{ workoutId: 'w1', exercises: [ex('e1', 'Sit ups')] }],
    })
    expect(rows[0].set_group).toBe(1)
  })

  it('동작이 하나라도 이미 담긴 워크아웃은 통째로 건너뛴다(멱등)', () => {
    const rows = buildLogRowsForWorkouts({
      ...base,
      existingExerciseIds: new Set(['e2']),
      existingNames: new Set(),
      workouts: [{ workoutId: 'w1', exercises: [ex('e1', 'A동작'), ex('e2', 'B동작')] }],
    })
    expect(rows).toEqual([])
  })

  it('이름이 이미 그날 있는 동작만 제외한다(박스 와드 placeholder 중복 방어)', () => {
    const rows = buildLogRowsForWorkouts({
      ...base,
      existingExerciseIds: new Set(),
      existingNames: new Set(['박스 와드']),
      workouts: [{ workoutId: 'w1', exercises: [ex('e1', '박스 와드'), ex('e2', 'Back Squat')] }],
    })
    expect(rows.map((r) => r.exercise_name)).toEqual(['Back Squat'])
  })

  it('한 카드 안의 같은 이름 2행은 둘 다 남긴다(메인 + 백오프)', () => {
    const rows = buildLogRowsForWorkouts({
      ...base, ...empty,
      workouts: [{ workoutId: 'w1', exercises: [
        ex('e1', 'Back Squat', { reps: '5' }),
        ex('e2', 'Back Squat', { reps: 'AMRAP' }),
      ] }],
    })
    expect(rows.map((r) => r.custom_reps)).toEqual(['5', 'AMRAP'])
  })

  // 순차 addWorkoutToDate 호출과 동일한 결과를 배치에서도 보장한다.
  // 실제 사례: 2026-07-14에 'DB Arnold Press'가 두 카드에 걸쳐 있어, 예전엔 두 번째 카드의
  // 그 행이 이름 중복으로 자동 제외됐다. 배치로 묶어도 같아야 한다.
  it('같은 배치에서 앞 카드가 담은 이름은 뒤 카드에서 제외한다', () => {
    const rows = buildLogRowsForWorkouts({
      ...base, ...empty,
      workouts: [
        { workoutId: 'w1', exercises: [ex('e1', 'DB Arnold Press')] },
        { workoutId: 'w2', exercises: [ex('e2', 'DB Arnold Press'), ex('e3', 'DB Bent Row')] },
      ],
    })
    expect(rows.map((r) => [r.exercise_name, r.workout_exercise_id])).toEqual([
      ['DB Arnold Press', 'e1'],
      ['DB Bent Row', 'e3'],
    ])
  })

  it('동작이 없는 워크아웃은 무시하고 순서를 유지한다', () => {
    const rows = buildLogRowsForWorkouts({
      ...base, ...empty,
      workouts: [
        { workoutId: 'w1', exercises: [] },
        { workoutId: 'w2', exercises: [ex('e1', '첫째')] },
        { workoutId: 'w3', exercises: [ex('e2', '둘째')] },
      ],
    })
    expect(rows.map((r) => r.exercise_name)).toEqual(['첫째', '둘째'])
  })

  it('워크아웃이 없으면 빈 배열', () => {
    expect(buildLogRowsForWorkouts({ ...base, ...empty, workouts: [] })).toEqual([])
  })
})
