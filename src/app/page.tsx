'use client'

import useSWR from 'swr'
import WorkoutCalendar from '@/components/home/WorkoutCalendar'
import ChallengeWidgets from '@/components/home/ChallengeWidgets'
import { getLoggedInUser } from '@/lib/auth'
import { getCompletedDatesInRange } from '@/lib/api/workout-logs'
import { toDateString } from '@/lib/utils'
import { EVENT, daysUntil, formatDday } from '@/lib/workout/dday'
import { k } from '@/lib/swr/keys'

export default function Home() {
  const uid = getLoggedInUser()?.id ?? ''
  const now = new Date()
  const ym = `${now.getFullYear()}-${now.getMonth() + 1}`
  const { data: stats } = useSWR(uid ? k.homeStats(uid, ym) : null, async () => {
    const weekStart = new Date(now); weekStart.setDate(weekStart.getDate() - weekStart.getDay())
    const weekEnd = new Date(weekStart); weekEnd.setDate(weekStart.getDate() + 6)
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0)
    const [week, month] = await Promise.all([
      getCompletedDatesInRange(uid, toDateString(weekStart), toDateString(weekEnd)),
      getCompletedDatesInRange(uid, toDateString(monthStart), toDateString(monthEnd)),
    ])
    return { week: week.length, month: month.length }
  })
  const weekCount = stats?.week ?? null
  const monthCount = stats?.month ?? null

  // 대회 당일까지 카운트다운. 지나면(음수) 숨기고 통계만 보여준다.
  const remaining = daysUntil(EVENT.date, toDateString(now))
  const dday = remaining >= 0 ? remaining : null

  return (
    <div className="flex flex-col gap-4">
      {/* 운동 캘린더 */}
      <WorkoutCalendar />

      {/* 대회 D-day + 운동 통계 */}
      <div className="bg-surface border border-border rounded-xl p-4">
        <div className="flex items-start justify-between gap-4">
          {/* 왼쪽: 대회 카운트다운. 대회가 지나면 숨기고 통계만 남는다 */}
          {dday != null && (
            <div className="min-w-0">
              <p className="text-xs font-semibold text-text-secondary">{EVENT.name}</p>
              <p className="text-4xl font-bold text-accent-pop leading-none mt-2.5">{formatDday(dday)}</p>
            </div>
          )}
          {/* 오른쪽: 이번 달 / 이번 주 */}
          <div className={`space-y-2.5 ${dday != null ? 'text-right' : 'flex-1 flex items-end justify-between'}`}>
            <div>
              <p className="text-xs text-text-secondary">이번 달 운동</p>
              <p className="text-lg font-semibold text-foreground leading-none mt-1">{monthCount ?? '–'}일</p>
            </div>
            <div>
              <p className="text-xs text-text-secondary">이번 주 운동</p>
              <p className="text-lg font-semibold text-accent leading-none mt-1">{weekCount ?? '–'}일</p>
            </div>
          </div>
        </div>
      </div>

      {/* 도전 중 챌린지 위젯 */}
      <ChallengeWidgets />
    </div>
  )
}
