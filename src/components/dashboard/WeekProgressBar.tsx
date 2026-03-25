'use client'

import { getCurrentWeek, getPhases } from '@/lib/utils'

function getProgramDay(): number {
  const startDate = new Date(2026, 2, 9) // 2026-03-09 (1일차)
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  return Math.floor((today.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1
}

export default function WeekProgressBar() {
  const currentWeek = getCurrentWeek()
  const phases = getPhases()
  const programDay = getProgramDay()

  return (
    <div className="bg-surface rounded-2xl p-5 border border-border">
      <p className="text-xs text-text-secondary font-medium mb-3">프로그램 진행</p>
      <div className="flex gap-1 mb-1">
        {phases.map((phase) => {
          const totalWeeks = phase.endWeek - phase.startWeek + 1
          const isActive = currentWeek >= phase.startWeek && currentWeek <= phase.endWeek
          return (
            <div key={phase.name} className="flex-1 text-center" style={{ flex: totalWeeks }}>
              {isActive ? (
                <p className="text-[10px] text-accent font-semibold">{programDay}일차</p>
              ) : (
                <p className="text-[10px] invisible">-</p>
              )}
            </div>
          )
        })}
      </div>
      <div className="flex gap-1">
        {phases.map((phase) => {
          const totalWeeks = phase.endWeek - phase.startWeek + 1
          const isActive = currentWeek >= phase.startWeek && currentWeek <= phase.endWeek
          const isCompleted = currentWeek > phase.endWeek
          return (
            <div key={phase.name} className="flex-1" style={{ flex: totalWeeks }}>
              <div
                className={`h-2 rounded-full transition-colors ${
                  isCompleted
                    ? 'bg-accent'
                    : isActive
                    ? 'bg-accent-pop'
                    : 'bg-border'
                }`}
              />
              <p className={`text-[10px] mt-1.5 truncate ${
                isActive ? 'text-accent font-semibold' : 'text-text-secondary'
              }`}>
                {phase.name}
              </p>
            </div>
          )
        })}
      </div>
    </div>
  )
}
