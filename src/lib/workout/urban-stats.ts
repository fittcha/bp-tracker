// urban 훈련 완료 통계 — 순수 함수(DB 접근 없음).
//
// 세는 단위는 '훈련'이다. 훈련 하나에 동작이 3개여도 그날 완료는 1회다.
// 그날 담긴 동작이 전부 완료됐을 때만 그 날짜를 완료일로 친다(부분 완료는 제외).
// 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md

export interface UrbanLogRow {
  workoutId: string
  date: string            // 'YYYY-MM-DD'
  completed: boolean
  memo: string | null
}

export interface UrbanStat {
  count: number           // 완료일 수
  dates: string[]         // 완료일, 최신순
  lastDate: string | null
  lastMemo: string | null // 최근 완료일 로그들의 메모를 ' · '로 이은 값
}

export function deriveUrbanStats(rows: UrbanLogRow[]): Record<string, UrbanStat> {
  // (훈련, 날짜)로 묶는다
  const byWorkout = new Map<string, Map<string, UrbanLogRow[]>>()
  for (const r of rows) {
    let byDate = byWorkout.get(r.workoutId)
    if (!byDate) {
      byDate = new Map()
      byWorkout.set(r.workoutId, byDate)
    }
    const arr = byDate.get(r.date)
    if (arr) arr.push(r)
    else byDate.set(r.date, [r])
  }

  const out: Record<string, UrbanStat> = {}
  for (const [workoutId, byDate] of byWorkout) {
    const done = [...byDate.entries()]
      .filter(([, logs]) => logs.length > 0 && logs.every((l) => l.completed))
      .sort((a, b) => b[0].localeCompare(a[0]))   // 최신순
    const dates = done.map(([d]) => d)
    const lastLogs = done[0]?.[1] ?? []
    const memos = lastLogs.map((l) => (l.memo ?? '').trim()).filter((m) => m.length > 0)
    out[workoutId] = {
      count: dates.length,
      dates,
      lastDate: dates[0] ?? null,
      lastMemo: memos.length > 0 ? memos.join(' · ') : null,
    }
  }
  return out
}
