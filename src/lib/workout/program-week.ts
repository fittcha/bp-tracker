// 공용 날짜기반 프로그램의 진행 상태 파생 — 순수 함수(DB 의존 없음).
// 주차는 날짜 산술이 아니라 '라벨'에서 읽는다: 제서 예선처럼 일정이 밀려 날짜와 주차 사이에
// 갭이 생기면 날짜 산술은 어긋나고 라벨이 진실이기 때문.
// 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md

export interface ProgramRow {
  program_date: string   // 'YYYY-MM-DD'
  program_label: string  // 예: 'Strength 8주 · 3주차'
}

export interface CurrentProgram {
  name: string                 // 'Strength 8주' (라벨의 ' · ' 앞부분)
  startDate: string            // 첫 세션 날짜 'YYYY-MM-DD'
  totalWeeks: number | null
  currentWeek: number | null   // null = 시작 전이거나 라벨에서 주차를 못 읽음
  status: 'upcoming' | 'active' | 'done'
}

export function deriveProgram(rows: ProgramRow[], today: string): CurrentProgram | null {
  // 호출부가 정렬해 주지만 방어적으로 한 번 더(테스트/향후 호출부 대비)
  const sorted = [...rows].sort((a, b) => a.program_date.localeCompare(b.program_date))
  if (sorted.length === 0) return null

  const name = sorted[0].program_label.split(' · ')[0]
  // 같은 프로그램 행만 범위 계산에 쓴다 — 라벨이 다른 특별 세션이 시작/종료일을 흔들지 않게.
  const prog = sorted.filter((r) => r.program_label.startsWith(name))
  const startDate = prog[0].program_date
  const endDate = prog[prog.length - 1].program_date
  const totMatch = name.match(/(\d+)\s*주/)
  const totalWeeks = totMatch ? Number(totMatch[1]) : null

  if (today < startDate) return { name, startDate, totalWeeks, currentWeek: null, status: 'upcoming' }
  if (today > endDate) return { name, startDate, totalWeeks, currentWeek: totalWeeks, status: 'done' }

  // 진행 중: 오늘 이하 마지막 세션의 라벨에서 'N주차'를 읽는다.
  const last = [...prog].reverse().find((r) => r.program_date <= today)
  const wkMatch = last?.program_label.match(/(\d+)\s*주차/)
  return { name, startDate, totalWeeks, currentWeek: wkMatch ? Number(wkMatch[1]) : null, status: 'active' }
}
