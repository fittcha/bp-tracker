// SWR localStorage 백업 캐시. 재실행 시 하이드레이트 → 첫 렌더 즉시. 유저별 네임스페이스.
//
// 스냅샷은 { savedAt, entries } 형식이고 CACHE_MAX_AGE_MS가 지나면 버린다.
// 낡은 캐시로 첫 렌더하면 (a) 서버 응답이 도착할 때 화면이 크게 튀고, (b) 공용 프로그램
// 일정이 바뀐 뒤엔 옛 카드 목록을 되살려 자동담기가 엉뚱한 날짜에 담는다
// (2026-08-05 제서 2주 시프트에서 실제 발생 — 자동담기 쪽 방어는 lib/workout/pick-missing.ts).
// 키에 버전을 붙여 형식·스키마가 바뀌면 옛 캐시를 자동으로 버린다.

export const CACHE_KEY_PREFIX = 'r2r-swr:v2:'
export const CACHE_MAX_AGE_MS = 3 * 24 * 60 * 60 * 1000  // 3일

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function localStorageProvider(uid: string): Map<string, any> {
  const lsKey = `${CACHE_KEY_PREFIX}${uid}`
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let init: [string, any][] = []
  try {
    const raw = JSON.parse(localStorage.getItem(lsKey) || 'null')
    if (
      raw &&
      Array.isArray(raw.entries) &&
      typeof raw.savedAt === 'number' &&
      Date.now() - raw.savedAt < CACHE_MAX_AGE_MS
    ) {
      init = raw.entries
    }
  } catch {
    init = []
  }
  // 버전 없는 v1 캐시는 쓰지 않고 지운다(용량 회수).
  try {
    localStorage.removeItem(`r2r-swr:${uid}`)
  } catch {
    // 무시
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const map = new Map<string, any>(init)
  const persist = () => {
    try {
      localStorage.setItem(lsKey, JSON.stringify({ savedAt: Date.now(), entries: Array.from(map.entries()) }))
    } catch {
      // 용량 초과 등은 무시(캐시는 보조)
    }
  }
  if (typeof window !== 'undefined') {
    window.addEventListener('pagehide', persist)
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) persist()
    })
  }
  return map
}
