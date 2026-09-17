// 대회 D-day — 순수 함수. 시즌1 utils.getDday(삭제됨)와 달리 today를 인자로 받아 테스트 가능.
// 설계: docs/superpowers/specs/2026-09-17-home-dday-design.md

export const EVENT = { name: 'Urban Wave', date: '2026-10-18' } as const

// 남은 일수. 오늘이면 0, 지났으면 음수. 'YYYY-MM-DD' 두 개를 UTC 자정끼리 빼서
// 서머타임·타임존 영향을 받지 않게 한다.
export function daysUntil(target: string, today: string): number {
  const t = Date.parse(`${target}T00:00:00Z`)
  const n = Date.parse(`${today}T00:00:00Z`)
  return Math.round((t - n) / 86_400_000)
}

// 표기: 남았으면 'D-30', 당일 'D-DAY', 지났으면 'D+3'
export function formatDday(days: number): string {
  if (days === 0) return 'D-DAY'
  return days > 0 ? `D-${days}` : `D+${-days}`
}
