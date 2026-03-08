'use client'

import { getCurrentWeek, getPhases } from '@/lib/utils'

export default function WeekProgressBar() {
  const currentWeek = getCurrentWeek()
  const phases = getPhases()

  return (
    <div className="bg-surface rounded-2xl p-5 border border-border">
      <p className="text-xs text-text-secondary font-medium mb-3">프로그램 진행</p>
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
                    ? 'bg-success'
                    : isActive
                    ? 'bg-accent'
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
