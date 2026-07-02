import { describe, it, expect } from 'vitest'
import { getInitial } from './avatar'

describe('getInitial', () => {
  it('영문 첫 글자를 대문자로', () => {
    expect(getInitial('alice')).toBe('A')
    expect(getInitial('Bob')).toBe('B')
  })
  it('앞뒤 공백을 무시', () => {
    expect(getInitial('  spaced')).toBe('S')
  })
  it('빈 문자열/공백은 물음표', () => {
    expect(getInitial('')).toBe('?')
    expect(getInitial('   ')).toBe('?')
  })
  it('한글 첫 글자', () => {
    expect(getInitial('지수')).toBe('지')
  })
  it('유니코드(이모지) 첫 코드포인트', () => {
    expect(getInitial('🔥nova')).toBe('🔥')
  })
})
