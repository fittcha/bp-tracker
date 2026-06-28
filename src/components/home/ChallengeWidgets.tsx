'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Flame } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import { getActiveChallenges, getChallengeTemplates } from '@/lib/api/challenges'
import { deriveDayStates, computeStreak, monthlyAttemptCount } from '@/lib/challenge/derive'
import { formatDifficulty } from '@/lib/challenge/format'
import { toDateString } from '@/lib/utils'

interface WidgetData {
  id: string
  name: string
  diff: string
  streak: { count: number; alive: boolean }
  monthCount: number
  doneDays: number
  totalDays: number
}

export default function ChallengeWidgets() {
  const [widgets, setWidgets] = useState<WidgetData[]>([])

  useEffect(() => {
    const user = getLoggedInUser()
    if (!user) return
    let cancelled = false
    Promise.all([getActiveChallenges(user.id), getChallengeTemplates()])
      .then(([actives, temps]) => {
        if (cancelled) return
        const exByKey = Object.fromEntries(temps.map((t) => [t.key, t.exercise]))
        const today = toDateString(new Date())
        setWidgets(
          actives.map((a) => {
            const dates = a.attempts.map((x) => x.done_date)
            const states = deriveDayStates(a.attempts)
            let doneDays = 0
            states.forEach((s) => { if (s.status === 'success') doneDays++ })
            return {
              id: a.challenge.id,
              name: exByKey[a.challenge.template_key] ?? a.challenge.template_key,
              diff: formatDifficulty(a.challenge.difficulty),
              streak: computeStreak(a.challenge.training_weekdays, dates, today),
              monthCount: monthlyAttemptCount(dates, today.slice(0, 7)),
              doneDays,
              totalDays: a.days.length,
            }
          }),
        )
      })
      .catch(() => { if (!cancelled) setWidgets([]) })
    return () => { cancelled = true }
  }, [])

  if (widgets.length === 0) return null

  return (
    <div>
      <p className="text-[11px] font-semibold uppercase tracking-wider text-text-secondary/70 mb-2">도전 중 챌린지</p>
      <div className="grid grid-cols-2 gap-3">
        {widgets.map((w) => {
          const pct = w.totalDays > 0 ? Math.round((w.doneDays / w.totalDays) * 100) : 0
          return (
            <Link
              key={w.id}
              href="/challenge"
              className="block bg-surface border border-border rounded-xl p-4 hover:border-accent/40 transition-colors"
            >
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <p className="text-sm font-bold text-foreground truncate">{w.name}</p>
                  {w.diff && <p className="text-[11px] text-text-secondary truncate mt-0.5">{w.diff}</p>}
                </div>
                <div className="flex items-center gap-0.5 shrink-0">
                  <Flame size={15} className={w.streak.alive ? 'text-[#EA580C]' : 'text-text-secondary/40'} />
                  <span className={`text-sm font-bold tabular-nums ${w.streak.alive ? 'text-[#EA580C]' : 'text-text-secondary'}`}>{w.streak.count}</span>
                </div>
              </div>

              <div className="mt-4">
                <div className="h-1.5 rounded-full bg-border overflow-hidden">
                  <div className="h-full rounded-full bg-accent" style={{ width: `${pct}%` }} />
                </div>
                <div className="flex items-center justify-between mt-1.5">
                  <span className="text-[11px] text-text-secondary tabular-nums">{w.doneDays}/{w.totalDays}일</span>
                  <span className="text-[11px] text-text-secondary tabular-nums">이번 달 {w.monthCount}회</span>
                </div>
              </div>
            </Link>
          )
        })}
      </div>
    </div>
  )
}
