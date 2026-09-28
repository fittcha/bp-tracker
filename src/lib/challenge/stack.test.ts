import { describe, it, expect } from 'vitest'
import { deriveStack, type StackEntry } from './stack'

const e = (delta: number, done_date: string): StackEntry => ({ delta, done_date })

describe('deriveStack', () => {
  it('시작일이 1일차', () => {
    expect(deriveStack([], '2026-09-28', '2026-09-28').dayNo).toBe(1)
  })

  it('하루 지나면 2일차 — 요일과 무관하게 매일 오른다', () => {
    expect(deriveStack([], '2026-09-28', '2026-09-29').dayNo).toBe(2)
    expect(deriveStack([], '2026-09-28', '2026-10-09').dayNo).toBe(12)
  })

  it('delta를 전부 합해 누적을 낸다', () => {
    const s = deriveStack([e(10, '2026-09-28'), e(5, '2026-09-29'), e(1, '2026-09-29')], '2026-09-28', '2026-09-29')
    expect(s.total).toBe(16)
  })

  it('감소도 합산된다', () => {
    const s = deriveStack([e(10, '2026-09-28'), e(-5, '2026-09-28')], '2026-09-28', '2026-09-28')
    expect(s.total).toBe(5)
  })

  // 음수 횟수는 말이 안 된다 — 합이 음수면 0으로 막는다.
  it('합이 음수면 0으로 클램프', () => {
    const s = deriveStack([e(5, '2026-09-28'), e(-10, '2026-09-28')], '2026-09-28', '2026-09-28')
    expect(s.total).toBe(0)
  })

  it('오늘 합계는 오늘 날짜 항목만 센다', () => {
    const s = deriveStack(
      [e(100, '2026-09-28'), e(20, '2026-09-29'), e(10, '2026-09-29')],
      '2026-09-28',
      '2026-09-29',
    )
    expect(s.total).toBe(130)
    expect(s.todayTotal).toBe(30)
  })

  it('오늘 기록이 없으면 오늘 합계는 0', () => {
    expect(deriveStack([e(100, '2026-09-28')], '2026-09-28', '2026-09-30').todayTotal).toBe(0)
  })

  it('기록이 없으면 전부 0, 1일차', () => {
    expect(deriveStack([], '2026-09-28', '2026-09-28')).toEqual({ dayNo: 1, total: 0, todayTotal: 0 })
  })

  it('시작일이 아직 안 왔으면 1일차로 막는다', () => {
    expect(deriveStack([], '2026-10-01', '2026-09-28').dayNo).toBe(1)
  })

  it('월·연 경계를 넘어도 일차가 맞는다', () => {
    expect(deriveStack([], '2026-12-28', '2027-01-03').dayNo).toBe(7)
  })
})
