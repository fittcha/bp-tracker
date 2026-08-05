// @vitest-environment jsdom
import { describe, it, expect, beforeEach } from 'vitest'
import { localStorageProvider, CACHE_KEY_PREFIX, CACHE_MAX_AGE_MS } from './provider'

const key = (uid: string) => `${CACHE_KEY_PREFIX}${uid}`
const snapshot = (entries: [string, unknown][], ageMs = 0) =>
  JSON.stringify({ savedAt: Date.now() - ageMs, entries })

// jsdom 환경 가정(vitest.config의 environment). localStorage/document/window 사용.
describe('localStorageProvider', () => {
  beforeEach(() => localStorage.clear())

  it('비어있으면 빈 Map', () => {
    expect(localStorageProvider('u1').size).toBe(0)
  })

  it('최근 스냅샷을 하이드레이트', () => {
    localStorage.setItem(key('u1'), snapshot([['k1', { data: 42 }]]))
    expect(localStorageProvider('u1').get('k1')).toEqual({ data: 42 })
  })

  // 낡은 캐시로 첫 렌더하면 화면이 튀고, 프로그램 일정이 바뀐 뒤엔 옛 카드를 되살린다.
  it('만료된 스냅샷은 버린다', () => {
    localStorage.setItem(key('u1'), snapshot([['k1', { data: 42 }]], CACHE_MAX_AGE_MS + 1000))
    expect(localStorageProvider('u1').size).toBe(0)
  })

  it('savedAt 없는 옛 형식(배열)은 무시한다', () => {
    localStorage.setItem(key('u1'), JSON.stringify([['k1', { data: 42 }]]))
    expect(localStorageProvider('u1').size).toBe(0)
  })

  it('버전 없는 옛 키는 하이드레이트하지 않고 지운다(용량 회수)', () => {
    localStorage.setItem('r2r-swr:u1', JSON.stringify([['k1', { data: 42 }]]))
    expect(localStorageProvider('u1').size).toBe(0)
    expect(localStorage.getItem('r2r-swr:u1')).toBeNull()
  })

  it('유저별 네임스페이스 격리', () => {
    localStorage.setItem(key('u1'), snapshot([['k1', { data: 1 }]]))
    expect(localStorageProvider('u2').size).toBe(0)
  })

  it('pagehide 시 savedAt과 함께 저장', () => {
    const m = localStorageProvider('u1')
    m.set('k2', { data: 'x' })
    window.dispatchEvent(new Event('pagehide'))
    const saved = JSON.parse(localStorage.getItem(key('u1'))!)
    expect(saved.entries).toEqual([['k2', { data: 'x' }]])
    expect(typeof saved.savedAt).toBe('number')
    expect(Date.now() - saved.savedAt).toBeLessThan(5000)
  })
})
