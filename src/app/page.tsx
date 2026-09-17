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
      {/* 정렬: 아래를 맞춰(items-end) D-day 숫자와 '이번 주 운동' 값이 같은 선에 놓인다.
          오른쪽은 라벨/값 2열 그리드 — 값이 한 열로 떨어져 4줄 들쭉날쭉이 사라진다.
          숫자는 전부 tabular-nums: D-day가 매일 줄고(31→30→9) 자릿수가 바뀌어도 안 흔들린다. */}
      <div className="bg-surface border border-border rounded-xl px-4 py-3.5">
        <div className="flex items-end justify-between gap-4">
          {/* 왼쪽: 대회 카운트다운. 대회가 지나면 숨기고 통계만 남는다 */}
          {dday != null && (
            <div className="min-w-0">
              <p className="text-[11px] font-semibold uppercase tracking-[0.12em] text-text-secondary truncate">
                {EVENT.name}
              </p>
              <p className="mt-1 text-2xl font-bold leading-none tabular-nums text-accent-pop">
                {formatDday(dday)}
              </p>
            </div>
          )}
          {/* 오른쪽: 이번 달 / 이번 주 */}
          <dl className="grid grid-cols-[auto_auto] items-baseline gap-x-3 gap-y-1.5 text-right">
            <dt className="text-[11px] text-text-secondary">이번 달 운동</dt>
            <dd className="text-sm font-semibold tabular-nums text-foreground">{monthCount ?? '–'}일</dd>
            <dt className="text-[11px] text-text-secondary">이번 주 운동</dt>
            <dd className="text-sm font-semibold tabular-nums text-accent">{weekCount ?? '–'}일</dd>
          </dl>
        </div>
      </div>

      {/* 도전 중 챌린지 위젯 */}
      <ChallengeWidgets />
    </div>
  )
}
