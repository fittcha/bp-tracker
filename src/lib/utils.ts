const SHOOT_DATE = new Date('2026-06-20')
const START_DATE = new Date('2026-03-09')

const PHASES = [
  { name: 'Reset Block', startWeek: 1, endWeek: 2 },
  { name: 'Adaptation Cut', startWeek: 3, endWeek: 4 },
  { name: 'Acceleration', startWeek: 5, endWeek: 8 },
  { name: 'Cutting Peak', startWeek: 9, endWeek: 14 },
  { name: 'Make Up', startWeek: 15, endWeek: 15 },
]

export function getDday(): number {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const shoot = new Date(SHOOT_DATE)
  shoot.setHours(0, 0, 0, 0)
  return Math.ceil((shoot.getTime() - today.getTime()) / (1000 * 60 * 60 * 24))
}

export function getCurrentWeek(): number {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const start = new Date(START_DATE)
  start.setHours(0, 0, 0, 0)
  const diffDays = Math.floor((today.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))
  if (diffDays < 0) return 0
  const week = Math.floor(diffDays / 7) + 1
  return Math.min(week, 15)
}

export function getCurrentPhase(): string {
  const week = getCurrentWeek()
  if (week <= 0) return '시작 전'
  const phase = PHASES.find(p => week >= p.startWeek && week <= p.endWeek)
  return phase?.name ?? '완료'
}

export function getWeekProgress(): number {
  const week = getCurrentWeek()
  if (week <= 0) return 0
  return Math.min(Math.round((week / 15) * 100), 100)
}

export function getPhases() {
  return PHASES
}

export function formatDate(date: Date): string {
  const days = ['일', '월', '화', '수', '목', '금', '토']
  const m = date.getMonth() + 1
  const d = date.getDate()
  const day = days[date.getDay()]
  return `${m}/${d}(${day})`
}

export function toDateString(date: Date): string {
  return date.toISOString().split('T')[0]
}

export function calcSleepHours(sleepTime: string, wakeTime: string): number {
  const [sh, sm] = sleepTime.split(':').map(Number)
  const [wh, wm] = wakeTime.split(':').map(Number)
  let sleepMin = sh * 60 + sm
  let wakeMin = wh * 60 + wm
  if (wakeMin <= sleepMin) wakeMin += 24 * 60
  const totalMin = wakeMin - sleepMin
  return totalMin / 60
}
