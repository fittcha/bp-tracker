// 쌓기 챌린지 파생 — 순수 함수. 기존 derive.ts(요일·성공/실패·스트릭)와 달리
// 여기엔 요일도 성공/실패도 없다. 시작일부터 매일 일차가 오르고 delta를 합할 뿐이다.
// 설계: docs/superpowers/specs/2026-09-28-stack-challenge-design.md

export interface StackEntry {
  delta: number
  done_date: string   // 'YYYY-MM-DD'
}

export interface StackState {
  dayNo: number       // 시작일 = 1일차
  total: number       // 누적(0 미만으로 내려가지 않음)
  todayTotal: number  // 오늘 올린 양
}

// 'YYYY-MM-DD' 두 개의 차이(일). UTC 자정끼리 빼 타임존·서머타임 영향을 없앤다.
function diffDays(from: string, to: string): number {
  return Math.round((Date.parse(`${to}T00:00:00Z`) - Date.parse(`${from}T00:00:00Z`)) / 86_400_000)
}

export function deriveStack(entries: StackEntry[], startedAt: string, today: string): StackState {
  const dayNo = Math.max(1, diffDays(startedAt, today) + 1)
  const sum = entries.reduce((acc, e) => acc + e.delta, 0)
  const todayTotal = entries.reduce((acc, e) => (e.done_date === today ? acc + e.delta : acc), 0)
  return { dayNo, total: Math.max(0, sum), todayTotal }
}
