'use client'

import useSWR from 'swr'
import WorkoutCalendar from '@/components/home/WorkoutCalendar'
import ChallengeWidgets from '@/components/home/ChallengeWidgets'
import { getLoggedInUser } from '@/lib/auth'
import { getCompletedDatesInRange } from '@/lib/api/workout-logs'
import { toDateString } from '@/lib/utils'
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

  return (
    <div className="flex flex-col gap-4">
      {/* 운동 캘린더 */}
      <WorkoutCalendar />

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
