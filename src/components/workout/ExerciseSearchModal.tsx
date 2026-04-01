'use client'

import { useEffect, useRef, useState, useCallback } from 'react'
import { searchWorkoutLogs, type WorkoutLog } from '@/lib/api/workout-logs'
import { getWeeks } from '@/lib/api/workout-templates'
import { supabase } from '@/lib/supabase'

const DAY_LABELS = ['일', '월', '화', '수', '목', '금', '토']

interface Props {
  userId: string
  onClose: () => void
}

interface WeekInfo {
  id: string
  week_number: number
  start_date: string
  end_date: string
}

interface TemplateInfo {
  id: string
  sets: string | null
  reps: string | null
  rest_seconds: number | null
}

interface EnrichedLog extends WorkoutLog {
  weekNumber: number | null
  dayLabel: string
  templateSets: string | null
  templateReps: string | null
  templateRest: number | null
}

export default function ExerciseSearchModal({ userId, onClose }: Props) {
  const [query, setQuery] = useState('')
  const [completedOnly, setCompletedOnly] = useState(true)
  const [results, setResults] = useState<EnrichedLog[]>([])
  const [loading, setLoading] = useState(false)
  const [hasSearched, setHasSearched] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  // Auto-focus on mount
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  // Prevent body scroll while modal is open
  useEffect(() => {
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = ''
    }
  }, [])

  const doSearch = useCallback(async (q: string, onlyCompleted: boolean) => {
    if (!q.trim()) {
      setResults([])
      setHasSearched(false)
      return
    }

    setLoading(true)
    setHasSearched(true)

    try {
      // Fetch logs and weeks in parallel
      const [logs, weeks] = await Promise.all([
        searchWorkoutLogs(q.trim(), userId, onlyCompleted),
        getWeeks(),
      ]) as [WorkoutLog[], WeekInfo[]]

      // Collect unique template_ids for batch fetch
      const templateIds = [...new Set(
        logs.filter(l => l.template_id).map(l => l.template_id as string)
      )]

      // Batch fetch template info
      let templateMap: Record<string, TemplateInfo> = {}
      if (templateIds.length > 0) {
        const { data: templates } = await supabase
          .from('workout_templates')
          .select('id, sets, reps, rest_seconds')
          .in('id', templateIds)

        if (templates) {
          templateMap = Object.fromEntries(templates.map(t => [t.id, t]))
        }
      }

      // Enrich logs with week info + template info
      const enriched: EnrichedLog[] = logs.map(log => {
        // Find which week this log's date falls in
        const logDate = log.date
        const week = weeks.find(w => logDate >= w.start_date && logDate <= w.end_date)

        // Format day label: M/D(요일)
        const d = new Date(logDate + 'T00:00:00')
        const month = d.getMonth() + 1
        const day = d.getDate()
        const dayOfWeek = DAY_LABELS[d.getDay()]
        const dayLabel = `${month}/${day}(${dayOfWeek})`

        // Template info
        const tmpl = log.template_id ? templateMap[log.template_id] : null

        return {
          ...log,
          weekNumber: week?.week_number ?? null,
          dayLabel,
          templateSets: tmpl?.sets ?? null,
          templateReps: tmpl?.reps ?? null,
          templateRest: tmpl?.rest_seconds ?? null,
        }
      })

      setResults(enriched)
    } catch (err) {
      console.error('Search error:', err)
      setResults([])
    } finally {
      setLoading(false)
    }
  }, [userId])

  // Debounced search on query change
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)

    debounceRef.current = setTimeout(() => {
      doSearch(query, completedOnly)
    }, 400)

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current)
    }
  }, [query, completedOnly, doSearch])

  // Close on Escape
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [onClose])

  return (
    <div className="fixed inset-0 z-[100] bg-black/50 flex items-center justify-center p-3">
    <div className="bg-background rounded-2xl flex flex-col w-full h-full overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-2 px-4 py-3 border-b border-border">
        <div className="flex-1 relative">
          {/* Search icon inside input */}
          <svg
            className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            ref={inputRef}
            type="text"
            placeholder="운동 이름 검색..."
            value={query}
            onChange={e => setQuery(e.target.value)}
            className="w-full bg-surface border border-border rounded-lg pl-9 pr-3 py-2 text-sm text-foreground placeholder:text-text-secondary/60 focus:outline-none focus:border-accent"
          />
        </div>
        <button
          onClick={onClose}
          className="text-text-secondary p-1 flex-shrink-0"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>

      {/* Filter pills */}
      <div className="flex gap-2 px-4 py-2 border-b border-border">
        <button
          onClick={() => setCompletedOnly(false)}
          className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
            !completedOnly
              ? 'bg-accent text-white'
              : 'bg-surface border border-border text-text-secondary'
          }`}
        >
          전체
        </button>
        <button
          onClick={() => setCompletedOnly(true)}
          className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
            completedOnly
              ? 'bg-accent text-white'
              : 'bg-surface border border-border text-text-secondary'
          }`}
        >
          완료
        </button>
      </div>

      {/* Body */}
      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
        {/* Empty states */}
        {!query.trim() && !loading && (
          <p className="text-center text-text-secondary text-sm mt-8">
            운동 이름을 입력하세요
          </p>
        )}
        {loading && (
          <p className="text-center text-text-secondary text-sm mt-8">
            검색 중...
          </p>
        )}
        {!loading && hasSearched && query.trim() && results.length === 0 && (
          <p className="text-center text-text-secondary text-sm mt-8">
            검색 결과가 없습니다
          </p>
        )}

        {/* Result cards */}
        {!loading && results.map(log => {
          const isCompleted = log.completed
          const cardClasses = isCompleted
            ? 'bg-surface border border-border'
            : 'bg-surface border border-border/50'
          const textClasses = isCompleted
            ? ''
            : 'text-text-secondary/50'

          // Build subtext line
          const subParts: string[] = []
          if (log.templateSets && log.templateReps) {
            subParts.push(`${log.templateSets}x${log.templateReps}`)
          } else if (log.templateSets) {
            subParts.push(`${log.templateSets}세트`)
          } else if (log.templateReps) {
            subParts.push(`x${log.templateReps}`)
          }

          return (
            <div key={log.id} className={`rounded-xl overflow-hidden ${cardClasses}`}>
              {/* Header row - week/date */}
              <div className={`px-3 py-1.5 text-xs font-medium ${
                isCompleted ? 'text-accent' : 'text-accent/50'
              }`}>
                {log.weekNumber != null ? `Week ${log.weekNumber}` : 'Custom'}
                {' · '}
                {log.dayLabel}
              </div>

              {/* Main info */}
              <div className={`px-3 pb-2 ${textClasses}`}>
                <div className="flex items-center gap-2">
                  {log.section && (
                    <span className="text-xs font-bold text-text-secondary">
                      {log.section}.
                    </span>
                  )}
                  <span className="text-sm font-medium">
                    {log.exercise_name}
                  </span>
                  {log.weight_lb != null && (
                    <>
                      <span className="text-text-secondary text-xs">·</span>
                      <span className="text-sm font-semibold whitespace-nowrap">
                        {log.weight_lb} {log.weight_unit}
                      </span>
                    </>
                  )}
                  {isCompleted && (
                    <span className="text-success text-xs ml-auto">✓</span>
                  )}
                </div>

                {/* Subtext: sets/reps/rest from template */}
                {subParts.length > 0 && (
                  <p className="text-xs text-text-secondary/70 mt-0.5 ml-0.5">
                    {subParts.join('  ')}
                  </p>
                )}

                {/* Memo */}
                {log.memo && (
                  <p className="text-xs text-text-secondary italic mt-1 ml-0.5">
                    {log.memo}
                  </p>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
    </div>
  )
}
