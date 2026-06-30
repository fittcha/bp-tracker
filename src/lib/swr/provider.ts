// SWR localStorage 백업 캐시. 재실행 시 하이드레이트 → 첫 렌더 즉시. 유저별 네임스페이스.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function localStorageProvider(uid: string): Map<string, any> {
  const lsKey = `r2r-swr:${uid}`
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let init: [string, any][] = []
  try {
    init = JSON.parse(localStorage.getItem(lsKey) || '[]')
  } catch {
    init = []
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const map = new Map<string, any>(init)
  const persist = () => {
    try {
      localStorage.setItem(lsKey, JSON.stringify(Array.from(map.entries())))
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
