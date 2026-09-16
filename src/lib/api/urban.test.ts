import { describe, it, expect } from 'vitest'
import { canEditUrban, URBAN_EDITORS } from './urban'

// 보안이 아니라 오조작 방지용 게이트다 — 이 앱은 PIN이 전원 공용이라
// 누구든 코치 계정으로 로그인하면 통과한다. 목적은 일반 회원 화면에서 편집 UI를 숨기는 것.
describe('canEditUrban', () => {
  it('코치 계정은 편집할 수 있다', () => {
    expect(canEditUrban('chacha')).toBe(true)
  })

  it('일반 계정은 편집할 수 없다', () => {
    expect(canEditUrban('esther')).toBe(false)
    expect(canEditUrban('jhkim')).toBe(false)
  })

  it('로그인 정보가 없으면 false', () => {
    expect(canEditUrban(null)).toBe(false)
    expect(canEditUrban(undefined)).toBe(false)
    expect(canEditUrban('')).toBe(false)
  })

  it('코치 목록은 비어 있지 않다(전원 편집 불가로 잠기는 사고 방지)', () => {
    expect(URBAN_EDITORS.length).toBeGreaterThan(0)
  })
})
