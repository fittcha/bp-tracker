'use client'

import { useEffect, useRef, useState } from 'react'
import { upsertWorkoutLog, type WorkoutLogJoined } from '@/lib/api/workout-logs'

interface Props {
  title: string
  isShared: boolean
  logs: WorkoutLogJoined[]
  onChanged?: () => void
  onExerciseLongPress?: (exerciseName: string) => void
}

// 한 운동(workout) 카드. 시즌1 page.tsx의 섹션 그룹 렌더(groupLabel/setInfo/Superset/EMOM/AMRAP·
// __sep__ 구분선·서브그룹 디바이더·무게 lb/kg 입력·메모 auto-height·디바운스 자동저장)를
// workout의 logs 기준으로 일반화해 이식한 것.
//
// 시즌2 데이터 흐름: addWorkoutToDate가 workout_exercise.sets→custom_sets, reps→custom_reps로
// 복사하므로, 시즌1에서 template.sets/template.notes가 하던 역할을 custom_sets/custom_reps가 맡는다.
//   - custom_sets : "N sets" / setInfo (Superset/EMOM/AMRAP 등 그룹 라벨 소스)
//   - custom_reps : 반복수 또는 동작별 부가 노트(@/*/Rest…) / '__sep__' 구분자
export default function WorkoutCard({ title, isShared, logs, onChanged, onExerciseLongPress }: Props) {
  // 낙관적 로컬 상태(autosave 즉시 반영). props 변경 시 동기화.
  const [items, setItems] = useState<WorkoutLogJoined[]>(logs)
  useEffect(() => {
    setItems(logs)
  }, [logs])

  // 동작명 롱프레스 → GIF 모달 (시즌1 동작 유지)
  const longPressRef = useRef<Record<string, ReturnType<typeof setTimeout>>>({})
  function handleLongPressStart(name: string) {
    if (!onExerciseLongPress) return
    longPressRef.current[name] = setTimeout(() => onExerciseLongPress(name), 1000)
  }
  function handleLongPressEnd(name: string) {
    if (longPressRef.current[name]) {
      clearTimeout(longPressRef.current[name])
      delete longPressRef.current[name]
    }
  }

  const [weightOpen, setWeightOpen] = useState<Record<string, boolean>>({})
  const [memoOpen, setMemoOpen] = useState<Record<string, boolean>>({})

  // 무게가 이미 있는 행은 입력칸 자동 펼침, 메모 있는 행은 메모 자동 펼침
  useEffect(() => {
    const wOpen: Record<string, boolean> = {}
    const mOpen: Record<string, boolean> = {}
    for (const l of logs) {
      if (l.id && l.weight_lb != null) wOpen[l.id] = true
      if (l.id && l.memo) mOpen[l.id] = true
    }
    setWeightOpen((prev) => ({ ...wOpen, ...prev }))
    setMemoOpen((prev) => ({ ...mOpen, ...prev }))
  }, [logs])

  const debounceRef = useRef<Record<string, ReturnType<typeof setTimeout>>>({})

  // ── 자동저장 핸들러 (무게 500ms · 단위 500ms · 메모 800ms) ──
  function handleToggleComplete(id: string, completed: boolean) {
    setItems((prev) => {
      const log = prev.find((l) => l.id === id)
      if (log) upsertWorkoutLog({ ...log, completed })
      return prev.map((l) => (l.id === id ? { ...l, completed } : l))
    })
  }

  function toggleWeightInput(id: string) {
    setWeightOpen((prev) => {
      const wasOpen = prev[id]
      if (wasOpen) {
        // 닫을 때: 무게 초기화 + 저장
        setItems((p) => {
          const log = p.find((l) => l.id === id)
          if (log && log.weight_lb != null) upsertWorkoutLog({ ...log, weight_lb: null, weight_unit: 'lb' })
          return p.map((l) => (l.id === id ? { ...l, weight_lb: null, weight_unit: 'lb' as const } : l))
        })
      }
      return { ...prev, [id]: !wasOpen }
    })
  }

  function handleWeightChange(id: string, weight: number | null) {
    setItems((prev) => prev.map((l) => (l.id === id ? { ...l, weight_lb: weight } : l)))
    if (debounceRef.current[id]) clearTimeout(debounceRef.current[id])
    debounceRef.current[id] = setTimeout(() => {
      setItems((prev) => {
        const log = prev.find((l) => l.id === id)
        if (log) upsertWorkoutLog({ ...log, weight_lb: weight })
        return prev
      })
    }, 500)
  }

  function handleUnitToggle(id: string) {
    setItems((prev) => {
      const log = prev.find((l) => l.id === id)
      if (!log) return prev
      const newUnit = log.weight_unit === 'lb' ? ('kg' as const) : ('lb' as const)
      const updated = { ...log, weight_unit: newUnit }
      if (debounceRef.current[id]) clearTimeout(debounceRef.current[id])
      debounceRef.current[id] = setTimeout(() => {
        upsertWorkoutLog(updated)
      }, 500)
      return prev.map((l) => (l.id === id ? updated : l))
    })
  }

  function handleMemoChange(logId: string, memo: string) {
    setItems((prev) => prev.map((l) => (l.id === logId ? { ...l, memo } : l)))
    const key = `memo_${logId}`
    if (debounceRef.current[key]) clearTimeout(debounceRef.current[key])
    debounceRef.current[key] = setTimeout(() => {
      setItems((prev) => {
        const log = prev.find((l) => l.id === logId)
        if (log) upsertWorkoutLog({ ...log, memo: memo || null })
        return prev
      })
    }, 800)
  }

  // ── 섹션 단위로 그룹핑 (등장 순서 보존) ──
  const sections: { section: string; rows: WorkoutLogJoined[] }[] = []
  const sectionMap = new Map<string, WorkoutLogJoined[]>()
  for (const log of items) {
    const sec = log.section || '?'
    if (!sectionMap.has(sec)) {
      const rows: WorkoutLogJoined[] = []
      sectionMap.set(sec, rows)
      sections.push({ section: sec, rows })
    }
    sectionMap.get(sec)!.push(log)
  }

  // 카드 전체 완료 상태
  const allDone = items.length > 0 && items.every((l) => l.completed)
  const someDone = items.some((l) => l.completed)
  const firstId = items[0]?.id

  function handleCardToggle() {
    const newState = !allDone
    for (const item of items) {
      if (item.id && item.completed !== newState) handleToggleComplete(item.id, newState)
    }
    onChanged?.()
  }

  return (
    <div className="bg-surface border border-border rounded-xl overflow-hidden">
      {/* 카드 헤더: 완료 토글 + 운동 제목 + 공용/개인 뱃지 + 메모 토글 */}
      <div className="px-4 py-2.5 bg-background border-b border-border flex items-center gap-2">
        <button
          onClick={handleCardToggle}
          className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
            allDone
              ? 'bg-success border-success text-white'
              : someDone
                ? 'border-success/50 bg-success/10'
                : 'border-border'
          }`}
        >
          {allDone && (
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          )}
          {someDone && !allDone && <div className="w-2 h-0.5 bg-success rounded" />}
        </button>
        <span className="text-sm font-bold text-foreground truncate">{title}</span>
        <span
          className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full flex-shrink-0 ${
            isShared ? 'bg-accent-light text-accent' : 'bg-background border border-border text-text-secondary'
          }`}
        >
          {isShared ? '공용' : '개인'}
        </span>
        <div className="flex-1" />
        {firstId && (
          <button
            onClick={() => setMemoOpen((prev) => ({ ...prev, [firstId]: !prev[firstId] }))}
            className={`w-6 h-6 flex items-center justify-center rounded transition-colors ${
              memoOpen[firstId] ? 'text-accent' : items[0]?.memo ? 'text-accent/60' : 'text-text-secondary/40'
            }`}
            title="메모"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
              <polyline points="14 2 14 8 20 8" />
              <line x1="16" y1="13" x2="8" y2="13" />
              <line x1="16" y1="17" x2="8" y2="17" />
            </svg>
          </button>
        )}
      </div>

      {/* 섹션 그룹들 */}
      {sections.map(({ section, rows }) => (
        <SectionGroup
          key={section}
          section={section}
          rows={rows}
          weightOpen={weightOpen}
          onToggleComplete={handleToggleComplete}
          onToggleWeight={toggleWeightInput}
          onWeightChange={handleWeightChange}
          onUnitToggle={handleUnitToggle}
          onLongPressStart={handleLongPressStart}
          onLongPressEnd={handleLongPressEnd}
        />
      ))}

      {/* 카드 메모 (첫 동작에 귀속) */}
      {firstId && memoOpen[firstId] && (
        <div className="px-4 py-2.5 border-t border-border bg-background/50">
          <textarea
            placeholder="메모 입력..."
            value={items[0]?.memo || ''}
            onChange={(e) => {
              handleMemoChange(firstId, e.target.value)
              e.target.style.height = 'auto'
              e.target.style.height = e.target.scrollHeight + 'px'
            }}
            ref={(el) => {
              if (el) {
                el.style.height = 'auto'
                el.style.height = el.scrollHeight + 'px'
              }
            }}
            className="w-full text-xs bg-transparent resize-none outline-none text-foreground placeholder:text-text-secondary/50"
            rows={1}
          />
        </div>
      )}
    </div>
  )
}

// ── 섹션 그룹 (시즌1 sections.map 렌더 이식) ──
interface SectionGroupProps {
  section: string
  rows: WorkoutLogJoined[]
  weightOpen: Record<string, boolean>
  onToggleComplete: (id: string, completed: boolean) => void
  onToggleWeight: (id: string) => void
  onWeightChange: (id: string, weight: number | null) => void
  onUnitToggle: (id: string) => void
  onLongPressStart: (name: string) => void
  onLongPressEnd: (name: string) => void
}

function SectionGroup({
  section,
  rows,
  weightOpen,
  onToggleComplete,
  onToggleWeight,
  onWeightChange,
  onUnitToggle,
  onLongPressStart,
  onLongPressEnd,
}: SectionGroupProps) {
  const isGroup = rows.length > 1
  const first = rows[0]
  // 시즌2: sets는 custom_sets, notes(setInfo)는 custom_reps에서 온다.
  const groupSets = isGroup && first?.custom_sets ? first.custom_sets : null
  const firstNotes = first?.custom_reps || ''
  const isSuperset = isGroup && firstNotes.toLowerCase().includes('superset')
  // @, *, Rest, Climbing 으로 시작하는 노트는 동작별 노트(setInfo 아님)
  const isExerciseNote = /^[@*]|^Rest\b|^Climbing\b/i.test(firstNotes)
  const isSetInfo = !!firstNotes && !isExerciseNote && !isSuperset
  const setInfoParts = isSetInfo ? firstNotes.split(' / ') : []
  const setInfoLabel = setInfoParts.filter((p) => !/^[@*]|^Rest\b|^Climbing\b|^No\s/i.test(p)).join(' / ')
  const setInfoExerciseNotes = setInfoParts.filter((p) => /^[@*]|^Rest\b|^Climbing\b|^No\s/i.test(p)).join(' / ')
  const groupLabel = isSuperset
    ? `Superset${groupSets ? ` · ${groupSets} Sets` : ''}`
    : isSetInfo && setInfoLabel
      ? `${groupSets ? `${groupSets} Sets · ` : ''}${setInfoLabel}`
      : isGroup && groupSets
        ? `${groupSets} Sets`
        : null

  return (
    <div className="border-t border-border first:border-t-0">
      {/* 섹션 라벨 줄 (단일 동작이면 라벨 줄 생략, 동작 행에 인라인 표시) */}
      {(isGroup || section !== '?') && (
        <div className="px-4 py-1.5 bg-background/40 border-b border-border flex items-center gap-2">
          {section !== '?' && <span className="text-xs font-bold text-accent">{section}</span>}
          {groupLabel && <span className="text-xs text-text-secondary font-medium">{groupLabel}</span>}
          {!isGroup && first?.custom_sets && (
            <span className="text-xs text-text-secondary font-medium">{first.custom_sets} Sets</span>
          )}
        </div>
      )}

      <div className="divide-y divide-border">
        {rows.map((log, logIndex) => {
          const isWeightOpen = !!(log.id && weightOpen[log.id])

          // __sep__ 구분선 (custom_reps === '__sep__')
          if (log.custom_reps === '__sep__') {
            return (
              <div key={log.id} className="flex items-center px-4 py-1.5 border-t border-border bg-border/30">
                <span className="flex-1 text-[11px] text-text-secondary/50 text-center italic">{log.exercise_name}</span>
              </div>
            )
          }

          // 그룹 동작: reps를 앞에 표기(EMOM/AMRAP의 '1'·null은 제외), 단일 동작: 세트×반복 표기
          const showSetsInline = !isGroup
          const showRepsPrefix = isGroup && log.custom_reps && log.custom_reps !== '1' && !/^[@*]|^Rest\b|^Climbing\b/i.test(log.custom_reps)

          // 서브그룹 디바이더: setInfo 타입 변화 또는 sets 변화 시
          const getSubType = (n: string) =>
            n.includes('superset') ? 'superset' : n.includes('amrap') ? 'amrap' : n.includes('emom') ? 'emom' : n.includes('every') ? 'every' : null
          const curNotes = (log.custom_reps || '').toLowerCase()
          const prevRow = rows[logIndex - 1]
          const prevNotes = (prevRow?.custom_reps || '').toLowerCase()
          const curSubType = getSubType(curNotes)
          const prevSubType = getSubType(prevNotes)
          const prevIsSep = prevRow?.custom_reps === '__sep__'
          const setsChanged = isGroup && logIndex > 0 && !!log.custom_sets && !!prevRow?.custom_sets && log.custom_sets !== prevRow.custom_sets
          const isNewSubGroup = logIndex > 0 && ((!!curSubType && curSubType !== prevSubType) || setsChanged || prevIsSep)
          const getSetInfo = (notes: string | null | undefined) => {
            if (!notes) return null
            const f = notes.split(' / ')[0]
            const fl = f.toLowerCase()
            if (fl.startsWith('rest') || fl.startsWith('*') || fl.startsWith('@')) return null
            return f
          }
          const subSetInfo = prevIsSep ? getSetInfo(log.custom_reps) : null
          const setsLabel = log.custom_sets ? `${log.custom_sets} Set${log.custom_sets !== '1' ? 's' : ''}` : null
          const subGroupLabel = isNewSubGroup
            ? (setsChanged || prevIsSep) && log.custom_sets
              ? subSetInfo
                ? `${setsLabel} (${subSetInfo})`
                : setsLabel
              : curSubType === 'superset'
                ? `Superset${log.custom_sets ? ` · ${log.custom_sets} Sets` : ''}`
                : log.custom_reps
            : null

          return (
            <div key={log.id}>
              {isNewSubGroup && (
                <div className="px-4 py-1.5 bg-background border-t border-border">
                  <span className="text-xs text-text-secondary font-medium">{subGroupLabel}</span>
                </div>
              )}
              <div className="flex items-center gap-3 px-4 py-3">
                {/* 완료 체크 */}
                <button
                  onClick={() => log.id && onToggleComplete(log.id, !log.completed)}
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

                {/* 동작 정보 */}
                <div className="flex-1 min-w-0">
                  <p
                    className={`text-sm font-medium select-none whitespace-pre-line ${log.completed ? 'line-through opacity-50' : ''}`}
                    onTouchStart={() => onLongPressStart(log.exercise_name)}
                    onTouchEnd={() => onLongPressEnd(log.exercise_name)}
                    onTouchCancel={() => onLongPressEnd(log.exercise_name)}
                    onMouseDown={() => onLongPressStart(log.exercise_name)}
                    onMouseUp={() => onLongPressEnd(log.exercise_name)}
                    onMouseLeave={() => onLongPressEnd(log.exercise_name)}
                    onContextMenu={(e) => e.preventDefault()}
                  >
                    {showRepsPrefix ? `${log.custom_reps} ` : ''}
                    {log.exercise_name}
                  </p>
                  {showSetsInline && (log.custom_sets || log.custom_reps) && (
                    <p className="text-xs text-text-secondary">
                      {log.custom_sets && `${log.custom_sets}세트`} {log.custom_reps && `× ${log.custom_reps}`}
                    </p>
                  )}
                  {isGroup &&
                    log.custom_reps &&
                    (!isNewSubGroup || setsChanged) &&
                    (() => {
                      // 그룹 첫 동작: 그룹 라벨로 빠진 prefix는 제거하고 나머지만 표시
                      if (log === first) {
                        if (isSetInfo) {
                          if (!setInfoExerciseNotes) return null
                          return <p className="text-[11px] text-text-secondary italic mt-0.5">{setInfoExerciseNotes}</p>
                        }
                        if (isSuperset) {
                          const stripped = log.custom_reps.replace(/^Superset\s*\/?\.?\s*/i, '').replace(/^\s*\/\s*/, '').trim()
                          if (!stripped) return null
                          return <p className="text-[11px] text-text-secondary italic mt-0.5">{stripped}</p>
                        }
                      }
                      // showRepsPrefix로 이미 동작명 앞에 표기되는 reps는 노트로 중복 표시하지 않음
                      if (showRepsPrefix) return null
                      return <p className="text-[11px] text-text-secondary italic mt-0.5">{log.custom_reps}</p>
                    })()}
                </div>

                {/* 무게 토글 + 입력 */}
                <div className="flex items-center gap-1 flex-shrink-0">
                  <button
                    onClick={() => log.id && onToggleWeight(log.id)}
                    className={`w-5 h-5 rounded border flex items-center justify-center transition-colors ${
                      isWeightOpen ? 'bg-accent border-accent text-white' : 'border-text-secondary/30 bg-surface'
                    }`}
                    title="무게 입력"
                  >
                    {isWeightOpen ? (
                      <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                    ) : (
                      <span className="text-[8px] font-bold text-text-secondary">{log.weight_unit ?? 'lb'}</span>
                    )}
                  </button>
                  {isWeightOpen && (
                    <>
                      <button
                        onClick={() => log.id && onWeightChange(log.id, Math.max(0, (log.weight_lb ?? 0) - 5))}
                        className="w-5 h-5 rounded bg-background border border-border flex items-center justify-center text-[10px] font-bold text-text-secondary active:bg-border"
                      >
                        −
                      </button>
                      <input
                        type="number"
                        inputMode="decimal"
                        placeholder="0"
                        value={log.weight_lb ?? ''}
                        onChange={(e) => log.id && onWeightChange(log.id, e.target.value ? parseFloat(e.target.value) : null)}
                        className="w-12 border border-border rounded-lg px-1 py-0.5 text-xs text-center bg-background"
                      />
                      <button onClick={() => log.id && onUnitToggle(log.id)} className="text-[9px] text-text-secondary active:text-accent">
                        {log.weight_unit ?? 'lb'}
                      </button>
                      <button
                        onClick={() => log.id && onWeightChange(log.id, (log.weight_lb ?? 0) + 5)}
                        className="w-5 h-5 rounded bg-background border border-border flex items-center justify-center text-[10px] font-bold text-text-secondary active:bg-border"
                      >
                        +
                      </button>
                    </>
                  )}
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
