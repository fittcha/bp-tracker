'use client'

import { useEffect, useState } from 'react'
import {
  getPersonalWorkouts,
  createPersonalWorkout,
  type Workout,
  type WorkoutExercise,
} from '@/lib/api/workouts'
import { addWorkoutToDate } from '@/lib/api/workout-logs'

// 카테고리 표준 목록 (탭 순서·생성 폼 select 공용). '전체'는 UI 메타탭으로 별도.
export const WORKOUT_CATEGORIES = ['전신', '가슴', '등', '어깨', '팔', '하체', '코어', '유산소']

interface ExerciseRow {
  id: string
  section: string
  exercise_name: string
  sets: string
  reps: string
  notes: string
}

function emptyRow(): ExerciseRow {
  return { id: crypto.randomUUID(), section: '', exercise_name: '', sets: '', reps: '', notes: '' }
}

interface AddWorkoutPopupProps {
  userId: string
  date: string
  onAdded: () => void
  onClose: () => void
}

export default function AddWorkoutPopup({ userId, date, onAdded, onClose }: AddWorkoutPopupProps) {
  const [workouts, setWorkouts] = useState<Workout[]>([])
  const [loading, setLoading] = useState(true)
  const [fetchError, setFetchError] = useState<string | null>(null)
  const [addError, setAddError] = useState<string | null>(null)
  const [selectedCat, setSelectedCat] = useState<string>('전체')
  const [addingId, setAddingId] = useState<string | null>(null)

  // 새 운동 생성 폼
  const [showCreate, setShowCreate] = useState(false)
  const [newTitle, setNewTitle] = useState('')
  const [newCategory, setNewCategory] = useState<string>('')
  const [rows, setRows] = useState<ExerciseRow[]>([emptyRow()])
  const [submitting, setSubmitting] = useState(false)
  const [createError, setCreateError] = useState<string | null>(null)

  useEffect(() => {
    getPersonalWorkouts(userId)
      .then(setWorkouts)
      .catch((e) => setFetchError(e instanceof Error ? e.message : '운동 목록을 불러오지 못했습니다.'))
      .finally(() => setLoading(false))
  }, [userId])

  // 활성 카테고리 탭 목록: 전체 + 실제 데이터 있는 카테고리만
  const activeCats = [
    '전체',
    ...WORKOUT_CATEGORIES.filter((c) => workouts.some((w) => w.category === c)),
  ]

  const filtered =
    selectedCat === '전체' ? workouts : workouts.filter((w) => w.category === selectedCat)

  // ── 카드 탭 → 담기 ──
  async function handleAddWorkout(workoutId: string) {
    if (addingId) return
    setAddingId(workoutId)
    setAddError(null)
    try {
      await addWorkoutToDate(userId, date, workoutId)
      onAdded()
    } catch (e) {
      setAddError(e instanceof Error ? e.message : '운동을 담지 못했습니다.')
    } finally {
      setAddingId(null)
    }
  }

  // ── 동작 행 관리 ──
  function updateRow(i: number, field: keyof ExerciseRow, value: string) {
    setRows((prev) => prev.map((r, idx) => (idx === i ? { ...r, [field]: value } : r)))
  }
  function addRow() {
    setRows((prev) => [...prev, emptyRow()])
  }
  function removeRow(i: number) {
    setRows((prev) => (prev.length <= 1 ? prev : prev.filter((_, idx) => idx !== i)))
  }

  // ── 새 운동 생성 + 담기 ──
  async function handleCreate() {
    if (!newTitle.trim()) {
      setCreateError('운동 이름을 입력하세요.')
      return
    }
    setSubmitting(true)
    setCreateError(null)
    try {
      const exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[] = rows
        .filter((r) => r.exercise_name.trim())
        .map(({ section, exercise_name, sets, reps, notes }, i) => ({
          section: section.trim() || null,
          exercise_name: exercise_name.trim(),
          sets: sets.trim() || null,
          reps: reps.trim() || null,
          notes: notes.trim() || null,
          sort_order: i,
        }))
      const w = await createPersonalWorkout(
        userId,
        newTitle.trim(),
        newCategory || null,
        exercises,
      )
      await addWorkoutToDate(userId, date, w.id)
      onAdded()
    } catch (e) {
      setCreateError(e instanceof Error ? e.message : '생성에 실패했습니다.')
      setSubmitting(false)
    }
  }

  function resetCreate() {
    setShowCreate(false)
    setNewTitle('')
    setNewCategory('')
    setRows([emptyRow()])
    setCreateError(null)
  }

  return (
    // 딤 배경
    <div
      className="fixed inset-0 z-50 flex flex-col justify-end bg-foreground/40"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose()
      }}
    >
      {/* 팝업 시트 */}
      <div className="bg-surface rounded-t-2xl max-h-[85dvh] flex flex-col overflow-hidden">
        {/* 헤더 */}
        <div className="flex items-center justify-between px-4 pt-4 pb-3 border-b border-border flex-shrink-0">
          <h2 className="text-base font-bold text-foreground">운동 추가</h2>
          <div className="flex items-center gap-2">
            {!showCreate && (
              <button
                onClick={() => setShowCreate(true)}
                className="text-sm font-medium text-accent px-3 py-1.5 rounded-lg bg-accent-light"
              >
                + 새 운동
              </button>
            )}
            <button
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center text-text-secondary rounded-lg"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
        </div>

        {/* 스크롤 영역 */}
        <div className="flex-1 overflow-y-auto">
          {/* ── 새 운동 생성 폼 ── */}
          {showCreate && (
            <div className="px-4 pt-4 pb-2 border-b border-border space-y-3">
              <h3 className="text-sm font-semibold text-accent">새 개인 운동 만들기</h3>

              {/* 제목 + 카테고리 */}
              <div className="flex gap-2">
                <input
                  autoFocus
                  placeholder="운동 이름"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-surface text-foreground placeholder:text-text-secondary outline-none focus:border-accent"
                />
                <select
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                  className="border border-border rounded-lg px-2 py-2 text-sm bg-surface text-foreground outline-none focus:border-accent"
                >
                  <option value="">카테고리</option>
                  {WORKOUT_CATEGORIES.map((c) => (
                    <option key={c} value={c}>{c}</option>
                  ))}
                </select>
              </div>

              {/* 동작 행들 */}
              <div className="bg-surface border border-border rounded-xl overflow-hidden">
                {/* 컬럼 레이블 */}
                <div className="grid grid-cols-[2fr_1fr_1fr_2fr] gap-1 px-3 py-1.5 bg-accent-light border-b border-border text-[10px] text-text-secondary font-medium">
                  <span>동작명</span>
                  <span>세트</span>
                  <span>횟수/시간</span>
                  <span>메모</span>
                </div>
                {rows.map((row, i) => (
                  <div key={row.id} className="flex items-center gap-1 px-3 py-2 border-b border-border last:border-b-0">
                    <div className="grid grid-cols-[2fr_1fr_1fr_2fr] gap-1 flex-1">
                      <input
                        placeholder="ex: 벤치프레스"
                        value={row.exercise_name}
                        onChange={(e) => updateRow(i, 'exercise_name', e.target.value)}
                        className="text-sm text-foreground bg-transparent outline-none placeholder:text-text-secondary/40"
                      />
                      <input
                        placeholder="3"
                        value={row.sets}
                        onChange={(e) => updateRow(i, 'sets', e.target.value)}
                        className="text-sm text-text-secondary bg-transparent outline-none placeholder:text-text-secondary/40"
                      />
                      <input
                        placeholder="12"
                        value={row.reps}
                        onChange={(e) => updateRow(i, 'reps', e.target.value)}
                        className="text-sm text-text-secondary bg-transparent outline-none placeholder:text-text-secondary/40"
                      />
                      <input
                        placeholder="ex: 50lb"
                        value={row.notes}
                        onChange={(e) => updateRow(i, 'notes', e.target.value)}
                        className="text-sm text-text-secondary bg-transparent outline-none placeholder:text-text-secondary/40"
                      />
                    </div>
                    {rows.length > 1 && (
                      <button
                        onClick={() => removeRow(i)}
                        className="w-5 h-5 flex items-center justify-center text-text-secondary/30 hover:text-danger flex-shrink-0"
                      >
                        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                          <line x1="18" y1="6" x2="6" y2="18" />
                          <line x1="6" y1="6" x2="18" y2="18" />
                        </svg>
                      </button>
                    )}
                  </div>
                ))}
              </div>

              <button
                onClick={addRow}
                className="text-[11px] text-accent/60 hover:text-accent transition-colors"
              >
                + 동작 추가
              </button>

              {createError && (
                <p className="text-xs text-danger">{createError}</p>
              )}

              {/* 액션 버튼 */}
              <div className="flex items-center justify-end gap-2 pb-1">
                <button
                  onClick={resetCreate}
                  disabled={submitting}
                  className="px-4 py-2 text-sm text-text-secondary rounded-lg"
                >
                  취소
                </button>
                <button
                  onClick={handleCreate}
                  disabled={submitting || !newTitle.trim()}
                  className="px-4 py-2 text-sm font-medium bg-accent text-white rounded-lg disabled:opacity-50"
                >
                  {submitting ? '저장 중…' : '만들고 담기'}
                </button>
              </div>
            </div>
          )}

          {/* ── 카테고리 탭 (가로 스크롤) ── */}
          {!showCreate && (
            <>
              <div className="flex gap-2 px-4 pt-3 pb-2 overflow-x-auto flex-shrink-0 scrollbar-none">
                {activeCats.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setSelectedCat(cat)}
                    className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
                      selectedCat === cat
                        ? 'bg-accent text-white'
                        : 'bg-accent-light text-accent'
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>

              {/* ── 카드 그리드 ── */}
              {addError && (
                <p className="px-4 pt-3 text-xs text-danger">{addError}</p>
              )}
              {loading ? (
                <div className="px-4 pb-4 space-y-2">
                  {[1, 2, 3].map((i) => (
                    <div key={i} className="bg-accent-light rounded-xl h-16 animate-pulse" />
                  ))}
                </div>
              ) : fetchError ? (
                <div className="px-4 pb-8 pt-4 text-center">
                  <p className="text-sm text-danger">{fetchError}</p>
                </div>
              ) : filtered.length === 0 ? (
                <div className="px-4 pb-8 pt-4 text-center">
                  <p className="text-sm text-text-secondary">
                    {workouts.length === 0
                      ? '개인 운동이 없어요. + 새 운동으로 만들어 보세요.'
                      : '이 카테고리에 운동이 없어요.'}
                  </p>
                </div>
              ) : (
                <div className="px-4 pb-6 grid grid-cols-2 gap-2 pt-1">
                  {filtered.map((w) => (
                    <button
                      key={w.id}
                      onClick={() => handleAddWorkout(w.id)}
                      disabled={addingId === w.id}
                      className="text-left bg-surface border border-border rounded-xl p-3 transition-colors active:bg-accent-light disabled:opacity-60"
                    >
                      <p className="text-sm font-semibold text-foreground leading-snug line-clamp-2">
                        {w.title}
                      </p>
                      {w.category && (
                        <p className="text-[11px] text-text-secondary mt-1">{w.category}</p>
                      )}
                      {addingId === w.id && (
                        <p className="text-[11px] text-accent mt-1">담는 중…</p>
                      )}
                    </button>
                  ))}
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  )
}
