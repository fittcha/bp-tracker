'use client'

import { useState } from 'react'
import useSWR from 'swr'
import { getUrbanTrainings, getUrbanLogs } from '@/lib/api/urban'
import { getWorkoutExercises, type Workout } from '@/lib/api/workouts'
import { addWorkoutToDate } from '@/lib/api/workout-logs'
import { deriveUrbanStats, type UrbanStat } from '@/lib/workout/urban-stats'
import { k } from '@/lib/swr/keys'

interface Props {
  userId: string
  date: string
  onAdded: () => void
  onClose: () => void
}

const md = (ds: string) => `${Number(ds.slice(5, 7))}/${Number(ds.slice(8, 10))}`

// urban 훈련 목록/상세 팝업. 내 운동 팝업과 달리 카테고리 탭이 없고, 탭하면 담기지 않고
// 상세가 열린다. 담기는 상세의 '오늘 운동에 추가'로만.
// 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md
export default function UrbanTrainingPopup({ userId, date, onAdded, onClose }: Props) {
  const [selected, setSelected] = useState<Workout | null>(null)
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const { data: trainings, isLoading } = useSWR(k.urbanTrainings(), getUrbanTrainings)
  const { data: logs } = useSWR(userId ? k.urbanStats(userId) : null, () => getUrbanLogs(userId))
  const { data: exercises } = useSWR(
    selected ? k.urbanExercises(selected.id) : null,
    () => getWorkoutExercises(selected!.id),
  )

  const stats = deriveUrbanStats(logs ?? [])
  const statOf = (id: string): UrbanStat =>
    stats[id] ?? { count: 0, dates: [], lastDate: null, lastMemo: null }

  async function handleAdd() {
    if (!selected || adding) return
    setAdding(true)
    setError(null)
    try {
      await addWorkoutToDate(userId, date, selected.id)
      onAdded()
    } catch (e) {
      setError(e instanceof Error ? e.message : '운동을 담지 못했습니다.')
      setAdding(false)
    }
  }

  return (
    <div className="fixed inset-0 z-[70] bg-black/40 flex items-end sm:items-center justify-center" onClick={onClose}>
      <div
        className="bg-surface w-full sm:max-w-lg max-h-[85vh] rounded-t-2xl sm:rounded-2xl flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* 헤더 */}
        <div className="px-4 py-3 border-b border-border flex items-center gap-2">
          {selected && (
            <button onClick={() => { setSelected(null); setError(null) }} className="text-text-secondary" aria-label="뒤로">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6" /></svg>
            </button>
          )}
          <h2 className="text-sm font-bold text-foreground flex-1 truncate">
            {selected ? selected.title : 'urban 훈련'}
          </h2>
          <button onClick={onClose} className="text-text-secondary text-sm">닫기</button>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
          {/* ── 목록 ── */}
          {!selected && (
            isLoading ? (
              <div className="space-y-2">
                {[1, 2, 3].map((i) => <div key={i} className="h-14 bg-border/40 rounded-xl animate-pulse" />)}
              </div>
            ) : (trainings ?? []).length === 0 ? (
              <p className="text-center text-text-secondary text-sm py-12">등록된 urban 훈련이 없습니다.</p>
            ) : (
              (trainings ?? []).map((w) => {
                const s = statOf(w.id)
                return (
                  <button
                    key={w.id}
                    onClick={() => setSelected(w)}
                    className="w-full text-left bg-background border border-border rounded-xl px-4 py-3 hover:border-accent transition-colors"
                  >
                    <p className="text-sm font-medium text-foreground">{w.title}</p>
                    <p className="text-xs text-text-secondary mt-0.5">
                      {s.count > 0 ? `완료 ${s.count}회 · 최근 ${md(s.lastDate!)}` : '기록 없음'}
                    </p>
                  </button>
                )
              })
            )
          )}

          {/* ── 상세 ── */}
          {selected && (
            <>
              <div className="space-y-1">
                {(exercises ?? []).map((ex, i, arr) => {
                  const headerHere = i === 0 || (arr[i - 1].set_info ?? '') !== (ex.set_info ?? '')
                  return (
                    <div key={ex.id}>
                      {headerHere && ex.set_info && (
                        <p className="text-xs font-semibold text-accent mt-3 mb-1">{ex.set_info}</p>
                      )}
                      <p className="text-sm text-foreground">
                        {ex.exercise_name}
                        {ex.reps && <span className="text-text-secondary"> × {ex.reps}</span>}
                      </p>
                      {ex.notes && <p className="text-xs text-text-secondary">{ex.notes}</p>}
                    </div>
                  )
                })}
                {exercises && exercises.length === 0 && (
                  <p className="text-sm text-text-secondary">등록된 동작이 없습니다.</p>
                )}
              </div>

              {/* 완료 이력 */}
              <div className="mt-4 pt-3 border-t border-border">
                {(() => {
                  const s = statOf(selected.id)
                  if (s.count === 0) return <p className="text-xs text-text-secondary">아직 완료한 기록이 없습니다.</p>
                  return (
                    <div className="space-y-1">
                      <p className="text-xs font-semibold text-foreground">완료 {s.count}회</p>
                      <p className="text-xs text-text-secondary">훈련일 {s.dates.map(md).join(' · ')}</p>
                      {s.lastMemo && (
                        <p className="text-xs text-text-secondary">최근 &ldquo;{s.lastMemo}&rdquo;</p>
                      )}
                    </div>
                  )
                })()}
              </div>
            </>
          )}
        </div>

        {/* 하단 액션 */}
        {selected && (
          <div className="px-4 py-3 border-t border-border">
            {error && <p className="text-xs text-danger mb-2">{error}</p>}
            <button
              onClick={handleAdd}
              disabled={adding}
              className="w-full rounded-xl bg-accent text-white py-3 text-sm font-medium disabled:opacity-50"
            >
              {adding ? '담는 중…' : '오늘 운동에 추가'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
