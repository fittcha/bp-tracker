import { describe, it, expect } from 'vitest'
import { deriveUrbanStats, type UrbanLogRow } from './urban-stats'

const row = (workoutId: string, date: string, completed: boolean, memo: string | null = null): UrbanLogRow =>
  ({ workoutId, date, completed, memo })

describe('deriveUrbanStats', () => {
  // 핵심: 세는 단위는 '훈련'이다. 동작이 3개라고 3회가 되면 안 된다.
  it('동작이 여러 개여도 그날 훈련은 1회로 센다', () => {
    const s = deriveUrbanStats([
      row('w1', '2026-09-18', true), row('w1', '2026-09-18', true), row('w1', '2026-09-18', true),
    ])
    expect(s.w1.count).toBe(1)
    expect(s.w1.dates).toEqual(['2026-09-18'])
  })

  it('하나라도 미완료면 그날은 완료로 치지 않는다', () => {
    const s = deriveUrbanStats([
      row('w1', '2026-09-18', true), row('w1', '2026-09-18', false),
    ])
    expect(s.w1).toMatchObject({ count: 0, dates: [], lastDate: null, lastMemo: null })
  })

  it('날짜별로 나눠 세고 최신순으로 정렬한다', () => {
    const s = deriveUrbanStats([
      row('w1', '2026-09-18', true),
      row('w1', '2026-10-14', true),
      row('w1', '2026-09-25', true),
    ])
    expect(s.w1.count).toBe(3)
    expect(s.w1.dates).toEqual(['2026-10-14', '2026-09-25', '2026-09-18'])
    expect(s.w1.lastDate).toBe('2026-10-14')
  })

  it('훈련별로 분리 집계한다', () => {
    const s = deriveUrbanStats([
      row('w1', '2026-09-18', true),
      row('w2', '2026-09-18', true), row('w2', '2026-09-25', true),
    ])
    expect(s.w1.count).toBe(1)
    expect(s.w2.count).toBe(2)
  })

  it('최근 완료일의 메모를 이어붙인다(빈 메모는 제외)', () => {
    const s = deriveUrbanStats([
      row('w1', '2026-09-18', true, '옛 기록'),
      row('w1', '2026-10-14', true, '5라운드 12:30'),
      row('w1', '2026-10-14', true, null),
      row('w1', '2026-10-14', true, '   '),
      row('w1', '2026-10-14', true, '마지막 세트 힘듦'),
    ])
    expect(s.w1.lastMemo).toBe('5라운드 12:30 · 마지막 세트 힘듦')
  })

  it('메모가 하나도 없으면 lastMemo는 null', () => {
    const s = deriveUrbanStats([row('w1', '2026-10-14', true)])
    expect(s.w1.lastMemo).toBeNull()
  })

  it('완료일이 없어도 훈련 키는 남긴다(목록에서 "기록 없음" 표시용)', () => {
    const s = deriveUrbanStats([row('w1', '2026-09-18', false)])
    expect(s.w1).toEqual({ count: 0, dates: [], lastDate: null, lastMemo: null })
  })

  it('로그가 없으면 빈 객체', () => {
    expect(deriveUrbanStats([])).toEqual({})
  })
})
