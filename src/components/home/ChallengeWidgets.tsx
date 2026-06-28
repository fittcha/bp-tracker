'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Flame } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import { getActiveChallenges, getChallengeTemplates } from '@/lib/api/challenges'
import { computeStreak, monthlyAttemptCount } from '@/lib/challenge/derive'
import { toDateString } from '@/lib/utils'

interface WidgetData {
  id: string
  name: string
  streak: { count: number; alive: boolean }
  monthCount: number
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
        const nameByKey = Object.fromEntries(temps.map((t) => [t.key, t.name]))
        const today = toDateString(new Date())
        setWidgets(
          actives.map((a) => {
            const dates = a.attempts.map((x) => x.done_date)
            return {
              id: a.challenge.id,
              name: nameByKey[a.challenge.template_key] ?? a.challenge.template_key,
              streak: computeStreak(a.challenge.training_weekdays, dates, today),
              monthCount: monthlyAttemptCount(dates, today.slice(0, 7)),
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
      <p className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-2">도전 중 챌린지</p>
      <div className="grid grid-cols-2 gap-3">
        {widgets.map((w) => (
          <Link key={w.id} href="/challenge"
            className="aspect-square bg-surface border border-border rounded-xl p-4 flex flex-col">
            <p className="text-sm font-semibold text-foreground truncate">{w.name}</p>
            <div className="flex-1 flex flex-col items-center justify-center gap-1">
              <div className="flex items-center gap-1">
                <Flame size={20} className={w.streak.alive ? 'text-accent-pop' : 'text-text-secondary'} />
                <span className={`text-2xl font-bold ${w.streak.alive ? 'text-accent-pop' : 'text-text-secondary'}`}>{w.streak.count}</span>
              </div>
            </div>
            <p className="text-xs text-text-secondary text-center">{w.monthCount}회 도전</p>
          </Link>
        ))}
      </div>
    </div>
  )
}
