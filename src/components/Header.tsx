'use client'

import { getCurrentWeek, getCurrentPhase, getDday } from '@/lib/utils'
import { getLoggedInUser } from '@/lib/auth'

export default function Header() {
  const week = getCurrentWeek()
  const phase = getCurrentPhase()
  const dday = getDday()
  const user = getLoggedInUser()

  return (
    <header className="sticky top-0 z-50 bg-surface border-b border-border px-4 py-3">
      <div className="flex items-center justify-between max-w-lg mx-auto">
        <div>
          <h1 className="text-sm font-bold text-foreground">
            {week > 0 && week <= 15 ? `${week}주차` : '준비중'} · {phase}
          </h1>
          {user && (
            <p className="text-xs text-text-secondary">user: {user.username}</p>
          )}
        </div>
        <div className="text-sm font-semibold text-accent-pop">
          D{dday <= 0 ? '+' : '-'}{Math.abs(dday)}
        </div>
      </div>
    </header>
  )
}
