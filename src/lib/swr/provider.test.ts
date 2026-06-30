// @vitest-environment jsdom
import { describe, it, expect, beforeEach } from 'vitest'
import { localStorageProvider } from './provider'

// jsdom 환경 가정(vitest.config의 environment). localStorage/document/window 사용.
describe('localStorageProvider', () => {
  beforeEach(() => localStorage.clear())

  it('비어있으면 빈 Map', () => {
    const m = localStorageProvider('u1')
    expect(m.size).toBe(0)
  })
  it('기존 캐시를 하이드레이트', () => {
    localStorage.setItem('r2r-swr:u1', JSON.stringify([['k1', { data: 42 }]]))
    const m = localStorageProvider('u1')
    expect(m.get('k1')).toEqual({ data: 42 })
  })
  it('유저별 네임스페이스 격리', () => {
    localStorage.setItem('r2r-swr:u1', JSON.stringify([['k1', { data: 1 }]]))
    const m2 = localStorageProvider('u2')
    expect(m2.size).toBe(0)
  })
  it('pagehide 시 현재 Map을 직렬화 저장', () => {
    const m = localStorageProvider('u1')
    m.set('k2', { data: 'x' })
    window.dispatchEvent(new Event('pagehide'))
    expect(JSON.parse(localStorage.getItem('r2r-swr:u1')!)).toEqual([['k2', { data: 'x' }]])
  })
})
