// 챌린지 파생 로직 (순수 함수, 의존성 없음 — 단위 테스트 대상)
// day 상태·스트릭·도전 횟수는 모두 append-only attempts에서 파생한다.

export type DayStatus = 'untried' | 'fail' | 'success'

export interface AttemptInput {
  id: string
  day_no: number
  result: 'success' | 'fail'
  done_date: string // YYYY-MM-DD
  created_at?: string
}

export interface DayState {
  day_no: number
  status: DayStatus
  doneDate: string | null // success면 성공일, fail이면 최신 fail일, untried면 null
  successAttemptId: string | null
}

// day_no별 현재 상태: success > fail > untried. success는 잠금(terminal).
export function deriveDayStates(attempts: AttemptInput[]): Map<number, DayState> {
  const map = new Map<number, DayState>()
  for (const a of attempts) {
    const cur = map.get(a.day_no)
    if (!cur) {
      map.set(a.day_no, {
        day_no: a.day_no,
        status: a.result,
        doneDate: a.done_date,
        successAttemptId: a.result === 'success' ? a.id : null,
      })
      continue
    }
    if (cur.status === 'success') continue // 이미 잠금
    if (a.result === 'success') {
      cur.status = 'success'
      cur.doneDate = a.done_date
      cur.successAttemptId = a.id
    } else if (cur.doneDate == null || a.done_date >= cur.doneDate) {
      cur.doneDate = a.done_date // 최신 fail 날짜
    }
  }
  return map
}

// ── 날짜 헬퍼 (YYYY-MM-DD, 로컬) ──
function parseYmd(s: string): Date {
  const [y, m, d] = s.split('-').map(Number)
  return new Date(y, m - 1, d)
}
function fmtYmd(dt: Date): string {
  const y = dt.getFullYear()
  const m = String(dt.getMonth() + 1).padStart(2, '0')
  const d = String(dt.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}
function weekdayMon1(s: string): number {
  const wd = parseYmd(s).getDay() // 0=일..6=토
  return wd === 0 ? 7 : wd // 1=월..7=일
}
function addDays(s: string, n: number): string {
  const dt = parseYmd(s)
  dt.setDate(dt.getDate() + n)
  return fmtYmd(dt)
}

// 훈련요일 기준 연속 출석. 비훈련요일은 건너뜀. 오늘 미출석은 끊김 아님(유지).
export function computeStreak(
  trainingWeekdays: number[],
  attemptDates: string[],
  today: string,
): { count: number; alive: boolean } {
  if (trainingWeekdays.length === 0 || attemptDates.length === 0) return { count: 0, alive: false }
  const attended = new Set(attemptDates)
  const training = new Set(trainingWeekdays)
  const isTraining = (s: string) => training.has(weekdayMon1(s))

  let floor = attemptDates[0]
  for (const d of attemptDates) if (d < floor) floor = d

  let cur = today
  // 오늘이 훈련일인데 미출석이면 유예: 어제부터 따짐
  if (isTraining(cur) && !attended.has(cur)) cur = addDays(cur, -1)

  let count = 0
  while (cur >= floor) {
    if (isTraining(cur)) {
      if (attended.has(cur)) count++
      else break // 지나간 훈련일 미출석 → 끊김
    }
    cur = addDays(cur, -1)
  }
  return { count, alive: count > 0 }
}

// 이번 달 도전 횟수 = 그 달 done_date를 가진 attempt 수(중복 날짜 각각 카운트)
export function monthlyAttemptCount(doneDates: string[], yearMonth: string): number {
  return doneDates.filter((d) => d.slice(0, 7) === yearMonth).length
}
