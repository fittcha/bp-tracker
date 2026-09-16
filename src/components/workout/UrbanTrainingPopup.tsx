'use client'

import { useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import {
  getUrbanTrainings,
  getUrbanLogs,
  createUrbanTraining,
  updateUrbanTraining,
  archiveUrbanTraining,
  canEditUrban,
} from '@/lib/api/urban'
import { getWorkoutExercises, type Workout } from '@/lib/api/workouts'
import { addWorkoutToDate } from '@/lib/api/workout-logs'
import { getLoggedInUser } from '@/lib/auth'
import { buildExercisesFromGroups, type SetGroup } from '@/lib/workout/build-exercises'
import SetGroupBuilder, { emptyGroup } from '@/components/workout/SetGroupBuilder'
import { deriveUrbanStats, type UrbanStat } from '@/lib/workout/urban-stats'
import { k } from '@/lib/swr/keys'

interface Props {
  userId: string
  date: string
  onAdded: () => void
  onClose: () => void
}

const md = (ds: string) => `${Number(ds.slice(5, 7))}/${Number(ds.slice(8, 10))}`

// urban 훈련 목록/상세/편집 팝업. 내 운동 팝업과 달리 카테고리 탭이 없고, 탭하면 담기지 않고
// 상세가 열린다. 담기는 상세의 '오늘 운동에 추가'로만.
// 편집(생성/수정/삭제)은 코치 계정에서만 노출 — canEditUrban 참고(보안 아님, 오조작 방지).
// 설계: docs/superpowers/specs/2026-09-16-urban-training-tab-design.md
//       docs/superpowers/specs/2026-09-16-urban-training-crud-design.md
export default function UrbanTrainingPopup({ userId, date, onAdded, onClose }: Props) {
  const { mutate } = useSWRConfig()
  const canEdit = canEditUrban(getLoggedInUser()?.username)

  const [selected, setSelected] = useState<Workout | null>(null)
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // 편집 폼: editing = null(닫힘) | {id: null}(새로 만들기) | {id}(수정)
  const [editing, setEditing] = useState<{ id: string | null } | null>(null)
  const [formTitle, setFormTitle] = useState('')
  const [formGroups, setFormGroups] = useState<SetGroup[]>([emptyGroup()])
  const [saving, setSaving] = useState(false)
  const [menuOpenId, setMenuOpenId] = useState<string | null>(null)

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

  function openCreate() {
    setMenuOpenId(null)
    setError(null)
    setEditing({ id: null })
    setFormTitle('')
    setFormGroups([emptyGroup()])
  }

  // 수정 진입: 기존 동작을 set_group 기준으로 묶어 그룹을 복원한다.
  async function openEdit(w: Workout) {
    setMenuOpenId(null)
    setError(null)
    try {
      const exs = await getWorkoutExercises(w.id) // sort_order 순
      const order: number[] = []
      const byGroup = new Map<number, SetGroup>()
      for (const ex of exs) {
        const gNo = ex.set_group ?? 1
        if (!byGroup.has(gNo)) {
          byGroup.set(gNo, { id: crypto.randomUUID(), setInfo: ex.set_info ?? '', rows: [] })
          order.push(gNo)
        }
        byGroup.get(gNo)!.rows.push({
          id: crypto.randomUUID(),
          exercise_name: ex.exercise_name,
          reps: ex.reps ?? '',
          notes: ex.notes ?? '',
        })
      }
      const loaded = order.map((g) => byGroup.get(g)!)
      setEditing({ id: w.id })
      setFormTitle(w.title)
      setFormGroups(loaded.length > 0 ? loaded : [emptyGroup()])
    } catch (e) {
      setError(e instanceof Error ? e.message : '동작을 불러오지 못했습니다.')
    }
  }

  async function handleSave() {
    if (saving || !editing) return
    if (!formTitle.trim()) {
      setError('훈련 이름을 입력하세요.')
      return
    }
    const exs = buildExercisesFromGroups(formGroups)
    if (exs.length === 0) {
      setError('동작을 하나 이상 입력하세요.')
      return
    }
    setSaving(true)
    setError(null)
    try {
      if (editing.id) await updateUrbanTraining(editing.id, formTitle.trim(), exs)
      else await createUrbanTraining(formTitle.trim(), exs)
      await mutate(k.urbanTrainings())
      if (editing.id) await mutate(k.urbanExercises(editing.id))
      setEditing(null)
      setSelected(null)
    } catch (e) {
      setError(e instanceof Error ? e.message : '저장하지 못했습니다.')
    } finally {
      setSaving(false)
    }
  }

  async function handleArchive(w: Workout) {
    setMenuOpenId(null)
    if (!window.confirm(`"${w.title}"을(를) 목록에서 지울까요?\n이미 담아서 기록한 건 그대로 남습니다.`)) return
    try {
      await archiveUrbanTraining(w.id)
      await mutate(k.urbanTrainings())
      setSelected(null)
    } catch (e) {
      window.alert(e instanceof Error ? e.message : '삭제하지 못했습니다.')
    }
  }

  const headerTitle = editing ? (editing.id ? '훈련 수정' : '새 urban 훈련') : selected ? selected.title : 'urban 훈련'

  return (
    <div className="fixed inset-0 z-[70] bg-black/40 flex items-end sm:items-center justify-center" onClick={onClose}>
      <div
        className="bg-surface w-full sm:max-w-lg max-h-[85vh] rounded-t-2xl sm:rounded-2xl flex flex-col overflow-hidden"
        onClick={(e) => { e.stopPropagation(); setMenuOpenId(null) }}
      >
        {/* 헤더 */}
        <div className="px-4 py-3 border-b border-border flex items-center gap-2">
          {(selected || editing) && (
            <button
              onClick={() => {
                if (editing) setEditing(null)
                else setSelected(null)
                setError(null)
              }}
              className="text-text-secondary"
              aria-label="뒤로"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6" /></svg>
            </button>
          )}
          <h2 className="text-sm font-bold text-foreground flex-1 truncate">{headerTitle}</h2>
          <button onClick={onClose} className="text-text-secondary text-sm">닫기</button>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
          {/* ── 편집 폼 ── */}
          {editing && (
            <div className="space-y-2">
              <input
                placeholder="훈련 이름"
                value={formTitle}
                onChange={(e) => setFormTitle(e.target.value)}
                className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface text-foreground placeholder:text-text-secondary/40 outline-none focus:border-accent"
              />
              <SetGroupBuilder groups={formGroups} setGroups={setFormGroups} />
              {error && <p className="text-xs text-danger">{error}</p>}
            </div>
          )}

          {/* ── 목록 ── */}
          {!selected && !editing && (
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
                  <div key={w.id} className="relative bg-background border border-border rounded-xl flex items-center">
                    <button
                      onClick={() => setSelected(w)}
                      className="flex-1 min-w-0 text-left px-4 py-3 hover:text-accent transition-colors"
                    >
                      <p className="text-sm font-medium text-foreground truncate">{w.title}</p>
                      <p className="text-xs text-text-secondary mt-0.5">
                        {s.count > 0 ? `완료 ${s.count}회 · 최근 ${md(s.lastDate!)}` : '기록 없음'}
                      </p>
                    </button>
                    {canEdit && (
                      <button
                        onClick={(e) => { e.stopPropagation(); setMenuOpenId(menuOpenId === w.id ? null : w.id) }}
                        className="px-3 py-3 text-text-secondary/60 hover:text-foreground"
                        aria-label="메뉴"
                      >
                        ⋯
                      </button>
                    )}
                    {canEdit && menuOpenId === w.id && (
                      <div
                        className="absolute right-2 top-11 z-10 bg-surface border border-border rounded-lg shadow-lg overflow-hidden"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <button onClick={() => openEdit(w)} className="block w-full text-left px-4 py-2 text-xs hover:bg-accent-light">수정</button>
                        <button onClick={() => handleArchive(w)} className="block w-full text-left px-4 py-2 text-xs text-danger hover:bg-accent-light">삭제</button>
                      </div>
                    )}
                  </div>
                )
              })
            )
          )}

          {/* ── 상세 ── */}
          {selected && !editing && (
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
        {editing ? (
          <div className="px-4 py-3 border-t border-border flex items-center justify-end gap-2">
            <button onClick={() => setEditing(null)} disabled={saving} className="px-4 py-2 text-sm text-text-secondary rounded-lg hover:bg-accent-light disabled:opacity-50">
              취소
            </button>
            <button onClick={handleSave} disabled={saving} className="px-5 py-2 rounded-lg bg-accent text-white text-sm font-medium disabled:opacity-50">
              {saving ? '저장 중…' : '저장'}
            </button>
          </div>
        ) : selected ? (
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
        ) : canEdit ? (
          <div className="px-4 py-3 border-t border-border">
            <button
              onClick={openCreate}
              className="w-full rounded-xl border border-border py-3 text-sm text-accent hover:bg-accent-light transition-colors"
            >
              + 새 urban 훈련
            </button>
          </div>
        ) : null}
      </div>
    </div>
  )
}
