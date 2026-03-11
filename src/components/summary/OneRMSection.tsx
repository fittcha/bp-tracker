'use client'

import { useEffect, useState, useRef } from 'react'
import { getUser1RMs, upsertUser1RM, deleteUser1RM, User1RM, DEFAULT_EXERCISES } from '@/lib/api/user-1rm'
import { getExerciseIcon } from './ExerciseIcons'

interface OneRMSectionProps {
  userId: string
}

export default function OneRMSection({ userId }: OneRMSectionProps) {
  const [open, setOpen] = useState(false)
  const [records, setRecords] = useState<User1RM[]>([])
  const [adding, setAdding] = useState(false)
  const [newName, setNewName] = useState('')
  const debounceRef = useRef<Record<string, NodeJS.Timeout>>({})

  useEffect(() => {
    async function load() {
      try {
        const data = await getUser1RMs(userId)
        const savedMap = new Map(data.map(d => [d.exercise_name, d]))
        // Default exercises in fixed order
        const ordered: User1RM[] = DEFAULT_EXERCISES.map(name =>
          savedMap.get(name) ?? { user_id: userId, exercise_name: name, weight: 0, weight_unit: 'lb' as const }
        )
        // Custom exercises (non-default) appended at end
        const custom = data.filter(d => !DEFAULT_EXERCISES.includes(d.exercise_name))
        setRecords([...ordered, ...custom])
      } catch (err) {
        console.error('Failed to load 1RM:', err)
      }
    }
    load()
  }, [userId])

  function handleWeightChange(exerciseName: string, value: string) {
    const weight = parseFloat(value) || 0
    setRecords(prev => prev.map(r =>
      r.exercise_name === exerciseName ? { ...r, weight } : r
    ))
    if (debounceRef.current[exerciseName]) clearTimeout(debounceRef.current[exerciseName])
    debounceRef.current[exerciseName] = setTimeout(() => {
      if (weight > 0) {
        setRecords(prev => {
          const record = prev.find(r => r.exercise_name === exerciseName)
          if (record) {
            upsertUser1RM({
              user_id: userId,
              exercise_name: exerciseName,
              weight,
              weight_unit: record.weight_unit,
            })
          }
          return prev
        })
      }
    }, 800)
  }

  function handleUnitToggle(exerciseName: string) {
    setRecords(prev => prev.map(r => {
      if (r.exercise_name !== exerciseName) return r
      const newUnit = r.weight_unit === 'lb' ? 'kg' as const : 'lb' as const
      if (r.weight > 0) {
        upsertUser1RM({
          user_id: userId,
          exercise_name: exerciseName,
          weight: r.weight,
          weight_unit: newUnit,
        })
      }
      return { ...r, weight_unit: newUnit }
    }))
  }

  async function handleDelete(record: User1RM) {
    if (record.id) await deleteUser1RM(record.id)
    setRecords(prev => prev.filter(r => r.exercise_name !== record.exercise_name))
  }

  function handleAddExercise() {
    const name = newName.trim()
    if (!name || records.some(r => r.exercise_name === name)) return
    setRecords(prev => [...prev, {
      user_id: userId,
      exercise_name: name,
      weight: 0,
      weight_unit: 'lb' as const,
    }])
    setNewName('')
    setAdding(false)
  }

  return (
    <div className="bg-surface border border-border rounded-xl">
      <button
        onClick={() => setOpen(prev => !prev)}
        className="w-full flex items-center justify-between p-4"
      >
        <span className="text-sm font-medium">나의 1RM</span>
        <svg
          width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
          className={`text-text-secondary transition-transform ${open ? 'rotate-180' : ''}`}
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>
      {open && (
        <div className="px-4 pb-4">
          <div className="grid grid-cols-4 gap-1.5">
            {records.map(r => {
              const Icon = getExerciseIcon(r.exercise_name)
              const hasValue = r.weight > 0
              return (
                <div
                  key={r.exercise_name}
                  className={`relative rounded-lg border py-2 px-1 flex flex-col items-center gap-0.5 ${
                    hasValue ? 'border-success/30 bg-success/5' : 'border-border bg-background'
                  }`}
                >
                  {!DEFAULT_EXERCISES.includes(r.exercise_name) && (
                    <button
                      onClick={() => handleDelete(r)}
                      className="absolute top-0.5 right-0.5 text-text-secondary/40 active:text-danger"
                    >
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                        <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                      </svg>
                    </button>
                  )}
                  <div className={hasValue ? 'text-success' : 'text-text-secondary/30'}>
                    <Icon size={22} />
                  </div>
                  <span className="text-[9px] text-text-secondary leading-tight text-center">{r.exercise_name}</span>
                  <div className="flex items-baseline justify-center">
                    <input
                      type="text"
                      inputMode="decimal"
                      maxLength={3}
                      placeholder="–"
                      value={r.weight ? `${r.weight}` : ''}
                      onChange={(e) => {
                        const v = e.target.value
                        if (v === '' || /^\d*\.?\d*$/.test(v)) handleWeightChange(r.exercise_name, v)
                      }}
                      className={`w-[1.8rem] py-0 text-xs text-center bg-transparent font-bold ${
                        hasValue ? 'text-foreground' : 'text-text-secondary/40'
                      }`}
                    />
                    <button
                      onClick={() => handleUnitToggle(r.exercise_name)}
                      className="text-[9px] text-text-secondary active:text-accent"
                    >{r.weight_unit}</button>
                  </div>
                </div>
              )
            })}
          </div>
          {adding ? (
            <div className="flex items-center gap-2 mt-3">
              <input
                type="text"
                placeholder="운동명"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleAddExercise()}
                className="flex-1 border border-border rounded-lg px-2 py-1 text-sm bg-background"
                autoFocus
              />
              <button onClick={handleAddExercise} className="text-xs text-success font-medium">추가</button>
              <button onClick={() => { setAdding(false); setNewName('') }} className="text-xs text-text-secondary">취소</button>
            </div>
          ) : (
            <button
              onClick={() => setAdding(true)}
              className="mt-3 text-xs text-accent font-medium"
            >+ 운동 추가</button>
          )}
        </div>
      )}
    </div>
  )
}
