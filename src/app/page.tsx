'use client'

import { useEffect, useState } from 'react'
import WorkoutCalendar from '@/components/home/WorkoutCalendar'
import ChallengeWidgets from '@/components/home/ChallengeWidgets'
import { getLoggedInUser } from '@/lib/auth'
import { getCompletedDatesInRange } from '@/lib/api/workout-logs'
import { getCurrentProgram, type CurrentProgram } from '@/lib/api/workouts'
import { toDateString } from '@/lib/utils'

export default function Home() {
  const [weekCount, setWeekCount] = useState<number | null>(null)
  const [monthCount, setMonthCount] = useState<number | null>(null)
  const [program, setProgram] = useState<CurrentProgram | null>(null)

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
      getCurrentProgram(toDateString(now)),
    ])
      .then(([week, month, prog]) => {
        if (cancelled) return
        setWeekCount(week.length)
        setMonthCount(month.length)
        setProgram(prog)
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

      {/* 공용 날짜기반 프로그램 배너 (운동 카드 대신 여기 한 곳만) */}
      {program &&
        (() => {
          const [, sm, sd] = program.startDate.split('-').map(Number)
          const pct =
            program.status === 'upcoming'
              ? 0
              : program.status === 'done'
                ? 100
                : program.currentWeek && program.totalWeeks
                  ? Math.round((program.currentWeek / program.totalWeeks) * 100)
                  : 0
          const eyebrow =
            program.status === 'upcoming' ? '예정된 프로그램' : program.status === 'done' ? '완료한 프로그램' : '진행 중 프로그램'
          const right =
            program.status === 'upcoming' ? `${sm}월 ${sd}일 시작` : program.status === 'done' ? '완료' : `${program.currentWeek}주차`
          return (
            <div className="bg-surface border border-border rounded-xl px-4 py-3">
              <p className="text-[11px] text-text-secondary mb-1.5">{eyebrow}</p>
              <div className="flex items-baseline justify-between mb-2">
                <p className="text-sm text-accent">{program.name}</p>
                <p className="text-xs text-text-secondary">{right}</p>
              </div>
              <div className="h-1.5 rounded-full bg-border overflow-hidden">
                <div className="h-full bg-accent-pop rounded-full transition-all" style={{ width: `${pct}%` }} />
              </div>
            </div>
          )
        })()}

      {/* 운동 통계 */}
      <div className="bg-surface border border-border rounded-xl p-4">
        <div className="flex items-end justify-between">
          <div>
            <p className="text-xs font-semibold text-text-secondary mb-1">이번 달 운동</p>
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

      {/* 도전 중 챌린지 위젯 */}
      <ChallengeWidgets />
    </div>
  )
}
