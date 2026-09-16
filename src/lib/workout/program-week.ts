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

  // 프로그램 이름(라벨의 ' · ' 앞부분)별로 묶는다. 8주 프로그램이 끝나고 6주가 시작되는 식으로
  // 여러 개가 공존할 수 있어서, '가장 이른 것'이 아니라 '지금 것'을 골라야 한다.
  const byName = new Map<string, ProgramRow[]>()
  for (const r of sorted) {
    const n = r.program_label.split(' · ')[0]
    const arr = byName.get(n)
    if (arr) arr.push(r)
    else byName.set(n, [r])
  }
  // 주차 수를 읽을 수 있는 이름만 후보 — 일회성 이벤트 라벨이 배너를 가로채지 않게.
  const all = [...byName.entries()].map(([n, rs]) => ({
    name: n, rows: rs, start: rs[0].program_date, end: rs[rs.length - 1].program_date,
    totalWeeks: n.match(/(\d+)\s*주/) ? Number(n.match(/(\d+)\s*주/)![1]) : null,
  }))
  const cands = all.filter((c) => c.totalWeeks != null).length > 0
    ? all.filter((c) => c.totalWeeks != null)
    : all
  // 진행 중 > 곧 시작 > 가장 최근에 끝난 것 순으로 고른다.
  const active = cands.filter((c) => c.start <= today && today <= c.end).sort((a, b) => b.start.localeCompare(a.start))
  const upcoming = cands.filter((c) => c.start > today).sort((a, b) => a.start.localeCompare(b.start))
  const finished = cands.filter((c) => c.end < today).sort((a, b) => b.end.localeCompare(a.end))
  const picked = active[0] ?? upcoming[0] ?? finished[0]
  if (!picked) return null

  const { name, rows: prog, start: startDate, end: endDate, totalWeeks } = picked

  if (today < startDate) return { name, startDate, totalWeeks, currentWeek: null, status: 'upcoming' }
  if (today > endDate) return { name, startDate, totalWeeks, currentWeek: totalWeeks, status: 'done' }

  // 진행 중: 오늘 이하 마지막 세션의 라벨에서 'N주차'를 읽는다.
  const last = [...prog].reverse().find((r) => r.program_date <= today)
  const wkMatch = last?.program_label.match(/(\d+)\s*주차/)
  return { name, startDate, totalWeeks, currentWeek: wkMatch ? Number(wkMatch[1]) : null, status: 'active' }
}
