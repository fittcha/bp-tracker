import { describe, it, expect } from 'vitest'
import { daysUntil, formatDday, EVENT } from './dday'

describe('daysUntil', () => {
  it('남은 일수를 센다', () => {
    expect(daysUntil('2026-10-18', '2026-09-17')).toBe(31)
    expect(daysUntil('2026-10-18', '2026-10-17')).toBe(1)
  })

  it('당일은 0', () => {
    expect(daysUntil('2026-10-18', '2026-10-18')).toBe(0)
  })

  it('지났으면 음수', () => {
    expect(daysUntil('2026-10-18', '2026-10-21')).toBe(-3)
  })

  it('월·연 경계를 넘어도 맞는다', () => {
    expect(daysUntil('2027-01-01', '2026-12-25')).toBe(7)
    expect(daysUntil('2026-10-01', '2026-09-30')).toBe(1)
  })
})

describe('formatDday', () => {
  it('남았으면 D-n', () => {
    expect(formatDday(31)).toBe('D-31')
    expect(formatDday(1)).toBe('D-1')
  })

  it('당일은 D-DAY', () => {
    expect(formatDday(0)).toBe('D-DAY')
  })

  it('지났으면 D+n', () => {
    expect(formatDday(-3)).toBe('D+3')
  })
})

describe('EVENT', () => {
  it('어반웨이브 대회일은 2026-10-18', () => {
    expect(EVENT).toEqual({ name: 'Urban Wave', date: '2026-10-18' })
  })
})
