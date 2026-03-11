'use client'

import { useEffect, useState, useCallback, useRef } from 'react'
import { toDateString } from '@/lib/utils'
import { getWorkoutLogs, upsertWorkoutLog, addCustomExercise, deleteWorkoutLog, WorkoutLog } from '@/lib/api/workout-logs'
import { getTemplatesByWeek, getWeeks } from '@/lib/api/workout-templates'
import { getLoggedInUser } from '@/lib/auth'
import CustomExerciseForm from '@/components/workout/CustomExerciseForm'

interface TemplateEx {
  id: string
  section: string
  exercise_name: string
  sets: number | null
  reps: string | null
  rest_seconds: number | null
  notes: string | null
  sort_order: number
  day_number: number
}

interface Week {
  id: string
  week_number: number
  phase: string
  start_date: string
  end_date: string
}

const DAY_LABELS = ['월', '화', '수', '목', '금', '토', '일']

export default function WorkoutPage() {
  const user = getLoggedInUser()
  const userId = user?.id ?? ''
  const [date, setDate] = useState(toDateString(new Date()))
  const [selectedDay, setSelectedDay] = useState<number>(1)
  const [templates, setTemplates] = useState<TemplateEx[]>([])
  const [logs, setLogs] = useState<WorkoutLog[]>([])
  const [loading, setLoading] = useState(true)
  const [weekId, setWeekId] = useState<string | null>(null)
  const [weekInfo, setWeekInfo] = useState<Week | null>(null)
  const [weightOpen, setWeightOpen] = useState<Record<string, boolean>>({})
  const debounceRef = useRef<Record<string, NodeJS.Timeout>>({})

  // Get Monday of the week containing `date`
  function getMondayOfWeek(d: Date) {
    const result = new Date(d)
    const dow = result.getDay()
    const offset = dow === 0 ? -6 : 1 - dow
    result.setDate(result.getDate() + offset)
    return result
  }

  function shiftWeek(delta: number) {
    const monday = getMondayOfWeek(new Date(date))
    monday.setDate(monday.getDate() + delta * 7)
    setDate(toDateString(monday))
  }

  const getWeekDates = () => {
    const monday = getMondayOfWeek(new Date(date))
    return Array.from({ length: 7 }, (_, i) => {
      const day = new Date(monday)
      day.setDate(monday.getDate() + i)
      return {
        dayNum: i + 1,
        date: toDateString(day),
        dayOfMonth: day.getDate(),
        label: DAY_LABELS[i],
        isWorkoutDay: i < 5,
      }
    })
  }

  const weekDates = getWeekDates()

  const loadData = useCallback(async () => {
    setLoading(true)

    // Find week and derive day number directly from date to avoid race conditions
    const weeks = await getWeeks()
    const week = weeks?.find((w: Week) => date >= w.start_date && date <= w.end_date)
    if (week) {
      setWeekId(week.id)
      setWeekInfo(week)
    } else {
      setWeekId(null)
      setWeekInfo(null)
    }

    const d = new Date(date)
    const dow = d.getDay()
    const dayNum = dow === 0 ? 7 : dow
    setSelectedDay(dayNum)
    const isWorkoutDay = dayNum <= 5

    const currentWeekId = week?.id
    const [tmpl, existingLogs] = await Promise.all([
      isWorkoutDay && currentWeekId ? getTemplatesByWeek(currentWeekId) : Promise.resolve([]),
      getWorkoutLogs(date, userId),
    ])

    const dayTemplates = (tmpl || []).filter((t: TemplateEx) => t.day_number === dayNum)
    setTemplates(dayTemplates)

    if (isWorkoutDay) {
      const existingTemplateIds = new Set((existingLogs || []).map(l => l.template_id).filter(Boolean))
      for (const t of dayTemplates) {
        if (!existingTemplateIds.has(t.id)) {
          await upsertWorkoutLog({
            date,
            user_id: userId,
            template_id: t.id,
            is_custom: false,
            exercise_name: t.exercise_name,
            section: t.section,
            completed: false,
            weight_lb: null,
            weight_unit: 'lb' as const,
            memo: null,
          })
        }
      }
    }

    const allLogs = await getWorkoutLogs(date, userId)
    setLogs(allLogs || [])
    // Auto-open weight input for logs that already have weight
    const openMap: Record<string, boolean> = {}
    for (const l of allLogs || []) {
      if (l.weight_lb != null) openMap[l.id] = true
    }
    setWeightOpen(openMap)
    setLoading(false)
  }, [date, userId])

  useEffect(() => {
    loadData()
  }, [loadData])

  function handleToggleComplete(id: string, completed: boolean) {
    setLogs(prev => {
      const log = prev.find(l => l.id === id)
      if (log) upsertWorkoutLog({ ...log, completed })
      return prev.map(l => l.id === id ? { ...l, completed } : l)
    })
  }

  function toggleWeightInput(id: string) {
    setWeightOpen(prev => {
      const wasOpen = prev[id]
      if (wasOpen) {
        // Closing weight input → clear weight and save
        setLogs(p => {
          const log = p.find(l => l.id === id)
          if (log && log.weight_lb != null) upsertWorkoutLog({ ...log, weight_lb: null, weight_unit: 'lb' })
          return p.map(l => l.id === id ? { ...l, weight_lb: null, weight_unit: 'lb' as const } : l)
        })
      }
      return { ...prev, [id]: !wasOpen }
    })
  }

  function handleWeightChange(id: string, weight: number | null) {
    setLogs(prev => prev.map(l => l.id === id ? { ...l, weight_lb: weight } : l))
    if (debounceRef.current[id]) clearTimeout(debounceRef.current[id])
    debounceRef.current[id] = setTimeout(() => {
      setLogs(prev => {
        const log = prev.find(l => l.id === id)
        if (log) upsertWorkoutLog({ ...log, weight_lb: weight })
        return prev
      })
    }, 500)
  }

  function handleUnitToggle(id: string) {
    setLogs(prev => {
      const log = prev.find(l => l.id === id)
      if (!log) return prev
      const newUnit = log.weight_unit === 'lb' ? 'kg' as const : 'lb' as const
      const updated = { ...log, weight_unit: newUnit }
      if (debounceRef.current[id]) clearTimeout(debounceRef.current[id])
      debounceRef.current[id] = setTimeout(() => {
        upsertWorkoutLog(updated)
      }, 500)
      return prev.map(l => l.id === id ? updated : l)
    })
  }

  async function handleAddCustom(name: string) {
    await addCustomExercise(date, name, userId)
    loadData()
  }

  async function handleDeleteLog(id: string) {
    await deleteWorkoutLog(id)
    setLogs(prev => prev.filter(l => l.id !== id))
  }

  const coachLogs = logs.filter(l => !l.is_custom)
  const customLogs = logs.filter(l => l.is_custom)

  // Group coach logs by section (preserve order)
  const sections: { section: string; items: (WorkoutLog & { template?: TemplateEx })[] }[] = []
  const sectionMap = new Map<string, (WorkoutLog & { template?: TemplateEx })[]>()
  for (const log of coachLogs) {
    const sec = log.section || '?'
    if (!sectionMap.has(sec)) {
      const items: (WorkoutLog & { template?: TemplateEx })[] = []
      sectionMap.set(sec, items)
      sections.push({ section: sec, items })
    }
    const tmpl = templates.find(t => t.id === log.template_id)
    sectionMap.get(sec)!.push({ ...log, template: tmpl })
  }

  const completedCount = logs.filter(l => l.completed).length
  const isWorkoutDay = selectedDay <= 5

  function handleDaySelect(dayNum: number, dayDate: string) {
    setSelectedDay(dayNum)
    setDate(dayDate)
  }

  return (
    <div className="space-y-4">
      {/* Date + week info */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1">
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() - 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg></button>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            className="border border-border rounded-lg px-3 py-1.5 text-sm bg-surface"
          />
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() + 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg></button>
        </div>
        {weekInfo && (
          <span className="text-sm font-medium text-accent">
            {weekInfo.week_number}주차 · {weekInfo.phase}
          </span>
        )}
      </div>

      {/* Week nav arrows + 7-day selector */}
      <div className="flex items-center gap-1">
        <button
          onClick={() => shiftWeek(-1)}
          className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <div className="flex-1 grid grid-cols-7 gap-1">
          {weekDates.map(wd => {
            const isSelected = wd.date === date
            const isToday = wd.date === toDateString(new Date())
            return (
              <button
                key={wd.dayNum}
                onClick={() => handleDaySelect(wd.dayNum, wd.date)}
                className={`flex flex-col items-center py-2 rounded-xl text-xs transition-colors ${
                  isSelected
                    ? 'bg-accent text-white'
                    : isToday
                    ? 'bg-accent/10 text-accent'
                    : wd.isWorkoutDay
                    ? 'bg-surface border border-border text-foreground'
                    : 'bg-background text-text-secondary'
                }`}
              >
                <span className="font-medium">{wd.label}</span>
                <span className="text-lg font-bold mt-0.5">{wd.dayOfMonth}</span>
                {wd.isWorkoutDay && (
                  <span className={`text-[10px] mt-0.5 ${isSelected ? 'text-white/70' : 'text-text-secondary'}`}>
                    Day{wd.dayNum}
                  </span>
                )}
              </button>
            )
          })}
        </div>
        <button
          onClick={() => shiftWeek(1)}
          className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg>
        </button>
      </div>

      {/* Progress */}
      {logs.length > 0 && (
        <div className="text-xs text-text-secondary text-right">
          {completedCount}/{logs.length} 완료
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          {[1, 2, 3].map(i => (
            <div key={i} className="bg-surface border border-border rounded-xl p-4 animate-pulse">
              <div className="h-4 bg-border rounded w-3/4" />
            </div>
          ))}
        </div>
      ) : !isWorkoutDay ? (
        <div className="bg-surface border border-border rounded-xl p-6 text-center">
          <p className="text-text-secondary text-sm">휴식일입니다</p>
          <p className="text-xs text-text-secondary mt-1">개인 운동을 추가할 수 있어요</p>
        </div>
      ) : sections.length === 0 && customLogs.length === 0 ? (
        <div className="bg-surface border border-border rounded-xl p-6 text-center">
          <p className="text-text-secondary text-sm">등록된 운동이 없습니다</p>
        </div>
      ) : (
        <>
          {/* Coach exercises grouped by section */}
          {sections.map(({ section, items }) => {
            const isGroup = items.length > 1
            // Detect group label from first item's template
            const firstTmpl = items[0]?.template
            const groupSets = isGroup && firstTmpl?.sets ? firstTmpl.sets : null
            // Detect special type from notes (Superset, EMOM, AMRAP, etc.)
            const firstNotes = firstTmpl?.notes || ''
            const isSuperset = isGroup && firstNotes.toLowerCase().includes('superset')
            const isEmom = isGroup && firstNotes.toLowerCase().includes('emom')
            const isAmrap = isGroup && firstNotes.toLowerCase().includes('amrap')
            const isSpecial = isEmom || isAmrap
            const groupLabel = isEmom ? firstNotes
              : isAmrap ? firstNotes
              : isSuperset ? `Superset${groupSets ? ` · ${groupSets} Sets` : ''}`
              : isGroup && groupSets ? `${groupSets} Sets` : null

            // Group completion state
            const allCompleted = items.length > 0 && items.every(i => i.completed)
            const someCompleted = items.some(i => i.completed)

            function handleGroupToggle() {
              const newState = !allCompleted
              for (const item of items) {
                if (item.completed !== newState) {
                  handleToggleComplete(item.id!, newState)
                }
              }
            }

            return (
              <div key={section} className="bg-surface border border-border rounded-xl overflow-hidden">
                <div className="px-4 py-2.5 bg-background border-b border-border flex items-center gap-2">
                  {/* Group completion checkbox */}
                  <button
                    onClick={handleGroupToggle}
                    className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                      allCompleted ? 'bg-success border-success text-white'
                        : someCompleted ? 'border-success/50 bg-success/10'
                        : 'border-border'
                    }`}
                  >
                    {allCompleted && (
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                    )}
                    {someCompleted && !allCompleted && (
                      <div className="w-2 h-0.5 bg-success rounded" />
                    )}
                  </button>
                  <span className="text-xs font-bold text-accent">{section === 'WOD' ? 'WOD' : section}</span>
                  {groupLabel && (
                    <span className="text-xs text-text-secondary font-medium">{groupLabel}</span>
                  )}
                  {!isGroup && firstTmpl?.sets && firstTmpl.sets > 1 && (
                    <span className="text-xs text-text-secondary font-medium">{firstTmpl.sets} Sets</span>
                  )}
                </div>
                <div className="divide-y divide-border">
                  {items.map(log => {
                    const tmpl = log.template
                    const isWeightOpen = !!weightOpen[log.id!]
                    // For grouped exercises, show reps + rest inline (sets shown in header)
                    // For single exercises, show sets × reps as before
                    const showSetsInline = !isGroup
                    // For EMOM/AMRAP, don't prepend reps (they are '1' or null)
                    const showRepsPrefix = isGroup && !isSpecial && tmpl?.reps && tmpl.reps !== '1'

                    return (
                      <div key={log.id} className="flex items-center gap-3 px-4 py-3">
                        {/* Complete checkbox */}
                        <button
                          onClick={() => handleToggleComplete(log.id!, !log.completed)}
                          className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                            log.completed ? 'bg-text-secondary/40 border-transparent text-white' : 'border-border'
                          }`}
                        >
                          {log.completed && (
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                              <polyline points="20 6 9 17 4 12" />
                            </svg>
                          )}
                        </button>

                        {/* Exercise info */}
                        <div className="flex-1 min-w-0">
                          <p className={`text-sm font-medium ${log.completed ? 'line-through opacity-50' : ''}`}>
                            {showRepsPrefix ? `${tmpl!.reps} ` : ''}{log.exercise_name}
                          </p>
                          {showSetsInline && (tmpl?.sets || tmpl?.reps) && (
                            <p className="text-xs text-text-secondary">
                              {tmpl.sets && `${tmpl.sets}세트`} {tmpl.reps && `× ${tmpl.reps}`}
                              {tmpl.rest_seconds && ` / 휴식 ${Math.floor(tmpl.rest_seconds / 60)}:${String(tmpl.rest_seconds % 60).padStart(2, '0')}`}
                            </p>
                          )}
                          {isGroup && tmpl?.rest_seconds && (
                            <p className="text-xs text-text-secondary">
                              휴식 {Math.floor(tmpl.rest_seconds / 60)}:{String(tmpl.rest_seconds % 60).padStart(2, '0')}
                            </p>
                          )}
                          {tmpl?.notes && !(isGroup && (isSuperset || isEmom || isAmrap) && tmpl === firstTmpl) && (
                            <p className="text-[11px] text-text-secondary italic mt-0.5">{tmpl.notes}</p>
                          )}
                        </div>

                        {/* Weight toggle checkbox + input */}
                        <div className="flex items-center gap-1.5 flex-shrink-0">
                          <button
                            onClick={() => toggleWeightInput(log.id!)}
                            className={`w-6 h-6 rounded border-2 flex items-center justify-center transition-colors ${
                              isWeightOpen ? 'bg-accent border-accent text-white' : 'border-text-secondary/40 bg-surface'
                            }`}
                            title="무게 입력"
                          >
                            {isWeightOpen ? (
                              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                                <polyline points="20 6 9 17 4 12" />
                              </svg>
                            ) : (
                              <span className="text-[9px] font-bold text-text-secondary">{log.weight_unit ?? 'lb'}</span>
                            )}
                          </button>
                          {isWeightOpen && (
                            <>
                              <button
                                onClick={() => handleWeightChange(log.id!, Math.max(0, (log.weight_lb ?? 0) - (log.weight_unit === 'kg' ? 5 : 5)))}
                                className="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-xs font-bold text-text-secondary active:bg-border"
                              >−</button>
                              <input
                                type="number"
                                inputMode="decimal"
                                placeholder="0"
                                value={log.weight_lb ?? ''}
                                onChange={(e) => handleWeightChange(log.id!, e.target.value ? parseFloat(e.target.value) : null)}
                                className="w-14 border border-border rounded-lg px-1 py-1 text-sm text-center bg-background"
                              />
                              <button
                                onClick={() => handleUnitToggle(log.id!)}
                                className="text-[10px] text-text-secondary active:text-accent"
                              >{log.weight_unit ?? 'lb'}</button>
                              <button
                                onClick={() => handleWeightChange(log.id!, (log.weight_lb ?? 0) + (log.weight_unit === 'kg' ? 5 : 5))}
                                className="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-xs font-bold text-text-secondary active:bg-border"
                              >+</button>
                            </>
                          )}
                        </div>
                      </div>
                    )
                  })}
                </div>
              </div>
            )
          })}
        </>
      )}

      {/* Custom exercises */}
      {customLogs.length > 0 && (
        <div className="bg-surface border border-accent/20 rounded-xl overflow-hidden">
          <div className="px-4 py-2.5 bg-accent-light border-b border-accent/20">
            <span className="text-xs font-bold text-accent">개인 추가 운동</span>
          </div>
          <div className="divide-y divide-border">
            {customLogs.map(log => {
              const isWeightOpen = !!weightOpen[log.id!]
              return (
                <div key={log.id} className="flex items-center gap-3 px-4 py-3">
                  <button
                    onClick={() => handleToggleComplete(log.id!, !log.completed)}
                    className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                      log.completed ? 'bg-text-secondary/40 border-transparent text-white' : 'border-accent/30'
                    }`}
                  >
                    {log.completed && (
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                    )}
                  </button>
                  <p className={`flex-1 text-sm font-medium text-accent ${log.completed ? 'line-through opacity-50' : ''}`}>
                    {log.exercise_name}
                  </p>
                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    <button
                      onClick={() => toggleWeightInput(log.id!)}
                      className={`w-6 h-6 rounded border-2 flex items-center justify-center transition-colors ${
                        isWeightOpen ? 'bg-accent border-accent text-white' : 'border-text-secondary/40 bg-surface'
                      }`}
                    >
                      {isWeightOpen ? (
                        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                      ) : (
                        <span className="text-[9px] font-bold text-text-secondary">{log.weight_unit ?? 'lb'}</span>
                      )}
                    </button>
                    {isWeightOpen && (
                      <>
                        <button
                          onClick={() => handleWeightChange(log.id!, Math.max(0, (log.weight_lb ?? 0) - (log.weight_unit === 'kg' ? 5 : 5)))}
                          className="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-xs font-bold text-text-secondary active:bg-border"
                        >−</button>
                        <input
                          type="number"
                          inputMode="decimal"
                          placeholder="0"
                          value={log.weight_lb ?? ''}
                          onChange={(e) => handleWeightChange(log.id!, e.target.value ? parseFloat(e.target.value) : null)}
                          className="w-14 border border-border rounded-lg px-1 py-1 text-sm text-center bg-background"
                        />
                        <button
                          onClick={() => handleUnitToggle(log.id!)}
                          className="text-[10px] text-text-secondary active:text-accent"
                        >{log.weight_unit ?? 'lb'}</button>
                        <button
                          onClick={() => handleWeightChange(log.id!, (log.weight_lb ?? 0) + (log.weight_unit === 'kg' ? 5 : 5))}
                          className="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-xs font-bold text-text-secondary active:bg-border"
                        >+</button>
                      </>
                    )}
                  </div>
                  <button onClick={() => handleDeleteLog(log.id!)} className="text-danger text-xs">
                    삭제
                  </button>
                </div>
              )
            })}
          </div>
        </div>
      )}

      <CustomExerciseForm onAdd={handleAddCustom} />
    </div>
  )
}
