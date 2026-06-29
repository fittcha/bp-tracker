import { describe, it, expect } from 'vitest'
import { buildExercisesFromGroups, type SetGroup } from './build-exercises'

const row = (name: string, reps = '', notes = '') => ({ id: name, exercise_name: name, reps, notes })

describe('buildExercisesFromGroups', () => {
  it('set_group 연속 + set_lead(첫 null, 이후 into) 부여', () => {
    const groups: SetGroup[] = [
      { id: 'g1', setInfo: '1 Sets', rows: [row('A', '400', "7'30\"")] },
      { id: 'g2', setInfo: 'For time', rows: [row('B', '800')] },
    ]
    const out = buildExercisesFromGroups(groups)
    expect(out).toHaveLength(2)
    expect(out[0]).toMatchObject({ set_group: 1, set_lead: null, set_info: '1 Sets', exercise_name: 'A', reps: '400', notes: "7'30\"", sort_order: 0 })
    expect(out[1]).toMatchObject({ set_group: 2, set_lead: 'into', set_info: 'For time', exercise_name: 'B', reps: '800', sort_order: 1 })
  })

  it('빈 그룹(동작명 없음) 건너뛰고 set_group 연속 유지', () => {
    const groups: SetGroup[] = [
      { id: 'g1', setInfo: '', rows: [row('   ')] },
      { id: 'g2', setInfo: '', rows: [row('Squat', '5')] },
      { id: 'g3', setInfo: '', rows: [row('Bench', '5')] },
    ]
    const out = buildExercisesFromGroups(groups)
    expect(out.map((e) => e.set_group)).toEqual([1, 2])
    expect(out[0].set_lead).toBeNull()
    expect(out[1].set_lead).toBe('into')
  })

  it('빈 setInfo/reps/notes는 null, sets/section은 항상 null', () => {
    const out = buildExercisesFromGroups([{ id: 'g', setInfo: '  ', rows: [row('X', ' ', ' ')] }])
    expect(out[0]).toMatchObject({ set_info: null, reps: null, notes: null, sets: null, section: null })
  })
})
