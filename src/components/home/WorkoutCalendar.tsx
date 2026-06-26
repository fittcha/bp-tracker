'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { getLoggedInUser } from '@/lib/auth'
import { getCompletedDatesInRange, getWorkoutDatesInRange } from '@/lib/api/workout-logs'
import { toDateString } from '@/lib/utils'

const WEEKDAY_LABELS = ['일', '월', '화', '수', '목', '금', '토']

// 그 달 1일이 포함된 주의 일요일(그리드 시작)
function gridStartOf(monthStart: Date): Date {
  const d = new Date(monthStart)
  const dow = d.getDay() // 0=일..6=토
  d.setDate(d.getDate() - dow)
  d.setHours(0, 0, 0, 0)
  return d
}

export default function WorkoutCalendar() {
  const router = useRouter()
  const [monthStart, setMonthStart] = useState(() => {
    const d = new Date()
    d.setDate(1)
    d.setHours(0, 0, 0, 0)
    return d
  })
  const [completed, setCompleted] = useState<Set<string>>(new Set())
  const [worked, setWorked] = useState<Set<string>>(new Set())

  const year = monthStart.getFullYear()
  const month = monthStart.getMonth() // 0-based
  const gridStart = gridStartOf(monthStart)
  const cells = Array.from({ length: 42 }, (_, i) => {
    const d = new Date(gridStart)
    d.setDate(gridStart.getDate() + i)
    return d
  })
  const todayDs = toDateString(new Date())

  useEffect(() => {
    const user = getLoggedInUser()
    if (!user) return
    const gs = gridStartOf(monthStart)
    const ge = new Date(gs)
    ge.setDate(gs.getDate() + 41)
    let cancelled = false
    Promise.all([
      getCompletedDatesInRange(user.id, toDateString(gs), toDateString(ge)),
      getWorkoutDatesInRange(user.id, toDateString(gs), toDateString(ge)),
    ])
      .then(([completedDates, workedDates]) => {
        if (!cancelled) {
          setCompleted(new Set(completedDates))
          setWorked(new Set(workedDates))
        }
      })
      .catch(() => {
        if (!cancelled) {
          setCompleted(new Set())
          setWorked(new Set())
        }
      })
    return () => {
      cancelled = true
    }
  }, [monthStart])

  function shiftMonth(delta: number) {
    setMonthStart(new Date(year, month + delta, 1))
  }

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      {/* 월 네비 */}
      <div className="flex items-center justify-between mb-3">
        <button
          onClick={() => shiftMonth(-1)}
          aria-label="이전 달"
          className="w-8 h-8 flex items-center justify-center rounded-lg border border-border text-text-secondary"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6" /></svg>
        </button>
        <p className="text-sm font-semibold text-foreground">{year}년 {month + 1}월</p>
        <button
          onClick={() => shiftMonth(1)}
          aria-label="다음 달"
          className="w-8 h-8 flex items-center justify-center rounded-lg border border-border text-text-secondary"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6" /></svg>
        </button>
      </div>

      {/* 요일 헤더 */}
      <div className="grid grid-cols-7 gap-1 mb-1">
        {WEEKDAY_LABELS.map((label) => (
          <div key={label} className="text-center text-xs text-text-secondary py-1">{label}</div>
        ))}
      </div>

      {/* 날짜 그리드 (6주) */}
      <div className="grid grid-cols-7 gap-1">
        {cells.map((d) => {
          const ds = toDateString(d)
          const inMonth = d.getMonth() === month
          const isToday = ds === todayDs
          const isCompleted = completed.has(ds)
          const hasWorkout = worked.has(ds)
          const dotClass = isCompleted ? 'bg-accent' : hasWorkout ? 'bg-text-secondary/40' : 'bg-transparent'
          const numClass = isToday
            ? 'bg-accent text-white'
            : inMonth ? 'text-foreground' : 'text-text-secondary/30'
          return (
            <button
              key={ds}
              onClick={() => router.push(`/workout?date=${ds}`)}
              className="flex flex-col items-center justify-start gap-0.5 h-11 pt-1"
            >
              <span className={`flex items-center justify-center w-7 h-7 rounded-full text-sm ${numClass}`}>
                {d.getDate()}
              </span>
              <span className={`w-1.5 h-1.5 rounded-full ${dotClass}`} />
            </button>
          )
        })}
      </div>
    </div>
  )
}
