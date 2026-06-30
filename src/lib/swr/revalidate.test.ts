import { describe, it, expect } from 'vitest'
import { matchPrefix } from './revalidate'

describe('matchPrefix', () => {
  it('prefix만 주면 그 prefix의 모든 키 매칭', () => {
    const m = matchPrefix('day-logs')
    expect(m(['day-logs', 'u1', '2026-07-06'])).toBe(true)
    expect(m(['day-logs', 'u2', '2026-07-07'])).toBe(true)
    expect(m(['home-stats', 'u1', '2026-07'])).toBe(false)
  })
  it('파라미터까지 주면 해당 키만 매칭', () => {
    const m = matchPrefix('day-logs', 'u1', '2026-07-06')
    expect(m(['day-logs', 'u1', '2026-07-06'])).toBe(true)
    expect(m(['day-logs', 'u1', '2026-07-07'])).toBe(false)
    expect(m(['day-logs', 'u2', '2026-07-06'])).toBe(false)
  })
  it('배열 아닌 키·짧은 키는 false', () => {
    const m = matchPrefix('day-logs', 'u1')
    expect(m('day-logs')).toBe(false)
    expect(m(['day-logs'])).toBe(false)
    expect(m(null)).toBe(false)
  })
})
