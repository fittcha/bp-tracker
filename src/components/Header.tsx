'use client'

import { getLoggedInUser } from '@/lib/auth'
import { toDateString } from '@/lib/utils'

export default function Header() {
  const user = getLoggedInUser()
  const todayLabel = user?.username ?? toDateString(new Date())

  return (
    <header className="sticky top-0 z-50 bg-surface border-b border-border px-4 py-3">
      <div className="flex items-center justify-between max-w-lg mx-auto">
        <h1 className="text-sm font-bold text-foreground">R2F</h1>
        <span className="text-xs text-text-secondary">{todayLabel}</span>
      </div>
    </header>
  )
}
