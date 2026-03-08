'use client'

import { getDday } from '@/lib/utils'

export default function DdayCard() {
  const dday = getDday()

  return (
    <div className="bg-surface rounded-2xl p-5 border border-border">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs text-text-secondary font-medium">촬영일까지</p>
          <p className="text-4xl font-bold text-foreground mt-1">
            D{dday <= 0 ? '+' : '-'}{Math.abs(dday)}
          </p>
        </div>
        <div className="text-right">
          <p className="text-sm text-text-secondary">2026.06.20</p>
          <p className="text-xs text-text-secondary mt-1">바디프로필 촬영</p>
        </div>
      </div>
    </div>
  )
}
