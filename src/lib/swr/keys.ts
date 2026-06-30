// SWR 캐시 키 팩토리. 배열 키 — 첫 요소=리소스명, 유저별 분리 위해 uid 포함.
export const k = {
  homeStats: (uid: string, ym: string) => ['home-stats', uid, ym] as const,
  calDates: (uid: string, gridStart: string) => ['cal-dates', uid, gridStart] as const,
  program: (today: string) => ['program', today] as const,
  dayDefaults: (uid: string, ds: string) => ['day-defaults', uid, ds] as const,
  dayLogs: (uid: string, ds: string) => ['day-logs', uid, ds] as const,
  challenges: (uid: string) => ['challenges', uid] as const,
  cardio: (uid: string, ds: string) => ['cardio', uid, ds] as const,
  personalWorkouts: (uid: string) => ['personal-workouts', uid] as const,
  pr1rm: (uid: string) => ['pr-1rm', uid] as const,
  prNrm: (uid: string) => ['pr-nrm', uid] as const,
  prPace: (uid: string) => ['pr-pace', uid] as const,
  dailyLog: (uid: string, date: string) => ['daily-log', uid, date] as const,
  weightRange: (uid: string, start: string, end: string) => ['weight-range', uid, start, end] as const,
}
