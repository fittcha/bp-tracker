import { describe, it, expect } from 'vitest'
import { pickMissingWorkouts, type DefaultWorkout } from './pick-missing'

const wod = (id: string): DefaultWorkout => ({ id })                        // 요일 공용(program_date 없음)
const prog = (id: string, program_date: string): DefaultWorkout => ({ id, program_date })

describe('pickMissingWorkouts', () => {
  it('이미 담긴 카드는 제외', () => {
    const all = [wod('w1'), prog('p1', '2026-07-28')]
    expect(pickMissingWorkouts(all, new Set(['w1']), '2026-07-28').map((w) => w.id)).toEqual(['p1'])
  })

  it('program_date가 그날과 같은 프로그램 카드는 담는다', () => {
    const all = [prog('p1', '2026-07-28'), prog('p2', '2026-07-28')]
    expect(pickMissingWorkouts(all, new Set(), '2026-07-28').map((w) => w.id)).toEqual(['p1', 'p2'])
  })

  // 회귀: 2026-08-05 2주 시프트 직후, localStorage SWR 캐시가 7/28용으로 시프트 이전
  // 목록(지금은 8/11인 카드들)을 내려줘 7/28에 옛 카드 11행이 담겼다.
  it('낡은 캐시가 내려준 다른 날짜 카드는 담지 않는다', () => {
    const all = [prog('shifted', '2026-08-11'), prog('today', '2026-07-28')]
    expect(pickMissingWorkouts(all, new Set(), '2026-07-28').map((w) => w.id)).toEqual(['today'])
  })

  it('요일 공용(program_date null·undefined)은 날짜와 무관하게 담는다', () => {
    const all: DefaultWorkout[] = [{ id: 'w1' }, { id: 'w2', program_date: null }]
    expect(pickMissingWorkouts(all, new Set(), '2026-07-28').map((w) => w.id)).toEqual(['w1', 'w2'])
  })

  it('입력 순서를 보존한다(요일 공용 → 프로그램 순서가 카드 정렬 기준)', () => {
    const all = [wod('wod'), prog('a', '2026-08-06'), prog('b', '2026-08-06')]
    expect(pickMissingWorkouts(all, new Set(), '2026-08-06').map((w) => w.id)).toEqual(['wod', 'a', 'b'])
  })

  it('빈 입력이면 빈 배열', () => {
    expect(pickMissingWorkouts([], new Set(), '2026-08-06')).toEqual([])
  })
})
