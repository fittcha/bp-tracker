'use client'

interface ExerciseCardProps {
  id: string
  section: string | null
  exerciseName: string
  sets?: string | null
  reps?: string | null
  restSeconds?: number | null
  notes?: string | null
  completed: boolean
  weightLb: number | null
  isCustom: boolean
  onToggleComplete: (id: string, completed: boolean) => void
  onWeightChange: (id: string, weight: number | null) => void
  onDelete?: (id: string) => void
}

export default function ExerciseCard({
  id,
  section,
  exerciseName,
  sets,
  reps,
  restSeconds,
  notes,
  completed,
  weightLb,
  isCustom,
  onToggleComplete,
  onWeightChange,
  onDelete,
}: ExerciseCardProps) {
  return (
    <div className={`bg-surface border rounded-xl p-4 transition-colors ${
      completed ? 'border-success/30 bg-success/5' : 'border-border'
    }`}>
      <div className="flex items-start gap-3">
        {/* Checkbox */}
        <button
          onClick={() => onToggleComplete(id, !completed)}
          className={`mt-0.5 w-6 h-6 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
            completed
              ? 'bg-success border-success text-white'
              : 'border-border'
          }`}
        >
          {completed && (
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          )}
        </button>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            {section && (
              <span className={`text-xs font-bold ${isCustom ? 'text-accent' : 'text-text-secondary'}`}>
                {section}.
              </span>
            )}
            <span className={`text-sm font-medium ${
              isCustom ? 'text-accent' : 'text-foreground'
            } ${completed ? 'line-through opacity-60' : ''}`}>
              {exerciseName}
            </span>
            {isCustom && onDelete && (
              <button onClick={() => onDelete(id)} className="text-danger text-xs ml-auto">
                삭제
              </button>
            )}
          </div>

          {/* Meta info */}
          {(sets || reps) && (
            <p className="text-xs text-text-secondary mt-1">
              {sets && `${sets}세트`} {reps && `× ${reps}`}
            </p>
          )}
          {notes && (
            <p className="text-xs text-text-secondary mt-0.5 italic">{notes}</p>
          )}

          {/* Weight input */}
          <div className="flex items-center gap-2 mt-2">
            <input
              type="number"
              inputMode="decimal"
              placeholder="무게"
              value={weightLb ?? ''}
              onChange={(e) => onWeightChange(id, e.target.value ? parseFloat(e.target.value) : null)}
              className="w-20 border border-border rounded-lg px-2 py-1.5 text-sm text-center bg-background"
            />
            <span className="text-xs text-text-secondary">lb</span>
          </div>
        </div>
      </div>
    </div>
  )
}
