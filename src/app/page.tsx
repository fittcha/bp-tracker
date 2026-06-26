'use client'

import { useEffect, useState } from 'react'
import WorkoutCalendar from '@/components/home/WorkoutCalendar'
import { getLoggedInUser } from '@/lib/auth'
import { getCompletedDatesInRange } from '@/lib/api/workout-logs'
import { toDateString } from '@/lib/utils'

export default function Home() {
  const [weekCount, setWeekCount] = useState<number | null>(null)
  const [monthCount, setMonthCount] = useState<number | null>(null)

  useEffect(() => {
    const user = getLoggedInUser()
    if (!user) return

    const now = new Date()
    // 이번 주(일~토)
    const weekStart = new Date(now)
    const dow = weekStart.getDay() // 0=일..6=토
    weekStart.setDate(weekStart.getDate() - dow)
    const weekEnd = new Date(weekStart)
    weekEnd.setDate(weekStart.getDate() + 6)
    // 이번 달
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0)

    let cancelled = false
    Promise.all([
      getCompletedDatesInRange(user.id, toDateString(weekStart), toDateString(weekEnd)),
      getCompletedDatesInRange(user.id, toDateString(monthStart), toDateString(monthEnd)),
    ])
      .then(([week, month]) => {
        if (cancelled) return
        setWeekCount(week.length)
        setMonthCount(month.length)
      })
      .catch(() => {
        if (cancelled) return
        setWeekCount(0)
        setMonthCount(0)
      })
    return () => {
      cancelled = true
    }
  }, [])

  return (
    <div className="flex flex-col gap-4">
      {/* 운동 캘린더 */}
      <WorkoutCalendar />

      {/* 운동 통계 */}
      <div className="bg-surface border border-border rounded-xl p-4">
        <div className="flex items-end justify-between">
          <div>
            <p className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-1">이번 달 운동</p>
            <p className="text-3xl font-bold text-foreground leading-none">
              {monthCount ?? '–'}
              <span className="text-base font-medium text-text-secondary ml-1">일</span>
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs text-text-secondary mb-1">이번 주</p>
            <p className="text-lg font-semibold text-accent leading-none">{weekCount ?? '–'}일</p>
          </div>
        </div>
      </div>
    </div>
  )
}
