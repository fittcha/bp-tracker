import { describe, it, expect } from 'vitest'
import { buildSharePayload, isBlankQuery, filterNewRecipients } from './share-payload'
import type { WorkoutExercise } from '@/lib/api/workouts'

const ex = (over: Partial<WorkoutExercise>): WorkoutExercise => ({
  id: 'x', workout_id: 'w', section: null, exercise_name: 'E', sets: null,
  reps: null, notes: null, sort_order: 0, set_group: 1, set_info: null, set_lead: null, ...over,
})

describe('buildSharePayload', () => {
  it('strips id/workout_id, keeps set_group/set_info/set_lead, sorts by sort_order', () => {
    const out = buildSharePayload(
      { title: '가슴 루틴', category: '가슴' },
      [ex({ id: 'b', sort_order: 1, exercise_name: 'B', set_info: 'Superset · 3 Sets', set_lead: 'into' }),
       ex({ id: 'a', sort_order: 0, exercise_name: 'A', set_info: '3 Sets' })],
    )
    expect(out.title).toBe('가슴 루틴')
    expect(out.category).toBe('가슴')
    expect(out.exercises.map((e) => e.exercise_name)).toEqual(['A', 'B'])
    expect(out.exercises[1]).toMatchObject({ set_info: 'Superset · 3 Sets', set_lead: 'into', set_group: 1 })
    expect(out.exercises[0]).not.toHaveProperty('id')
    expect(out.exercises[0]).not.toHaveProperty('workout_id')
  })
  it('null category → null', () => {
    expect(buildSharePayload({ title: 'T', category: null }, []).category).toBeNull()
  })
})

describe('isBlankQuery', () => {
  it('true for empty/whitespace', () => {
    expect(isBlankQuery('')).toBe(true)
    expect(isBlankQuery('   ')).toBe(true)
  })
  it('false for non-blank', () => {
    expect(isBlankQuery('som')).toBe(false)
  })
})

describe('filterNewRecipients', () => {
  it('removes already-pending and dedups input', () => {
    expect(filterNewRecipients(['a', 'b', 'b', 'c'], ['b'])).toEqual(['a', 'c'])
  })
  it('empty when all pending', () => {
    expect(filterNewRecipients(['a', 'b'], ['a', 'b'])).toEqual([])
  })
})
