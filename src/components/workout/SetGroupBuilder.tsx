'use client'

import type { Dispatch, SetStateAction } from 'react'
import type { ExerciseRow, SetGroup } from '@/lib/workout/build-exercises'

// 세트 그룹 편집 UI. AddWorkoutPopup(내 운동)과 UrbanTrainingPopup(urban 훈련)이 함께 쓴다.
// 그룹 = set_info 한 덩어리, 행 = 동작. 그룹 사이에는 'into' 연결자가 붙는다.
// 저장 시 buildExercisesFromGroups(테스트 있음)로 workout_exercises 행으로 변환한다.

export function emptyRow(): ExerciseRow {
  return { id: crypto.randomUUID(), exercise_name: '', reps: '', notes: '' }
}
export function emptyGroup(): SetGroup {
  return { id: crypto.randomUUID(), setInfo: '', rows: [emptyRow()] }
}

const exInputCls =
  'min-w-0 border border-border rounded-md px-1.5 py-1.5 text-xs bg-surface text-foreground placeholder:text-text-secondary/40 outline-none focus:border-accent'

interface Props {
  groups: SetGroup[]
  setGroups: Dispatch<SetStateAction<SetGroup[]>>
}

export default function SetGroupBuilder({ groups, setGroups }: Props) {
  function updateGroupInfo(gi: number, value: string) {
    setGroups((prev) => prev.map((g, i) => (i === gi ? { ...g, setInfo: value } : g)))
  }
  function addGroup() {
    setGroups((prev) => [...prev, emptyGroup()])
  }
  function removeGroup(gi: number) {
    setGroups((prev) => (prev.length <= 1 ? prev : prev.filter((_, i) => i !== gi)))
  }
  function updateRow(gi: number, ri: number, field: keyof ExerciseRow, value: string) {
    setGroups((prev) =>
      prev.map((g, i) =>
        i === gi ? { ...g, rows: g.rows.map((r, j) => (j === ri ? { ...r, [field]: value } : r)) } : g,
      ),
    )
  }
  function addRow(gi: number) {
    setGroups((prev) => prev.map((g, i) => (i === gi ? { ...g, rows: [...g.rows, emptyRow()] } : g)))
  }
  function removeRow(gi: number, ri: number) {
    setGroups((prev) =>
      prev.map((g, i) =>
        i === gi ? { ...g, rows: g.rows.length <= 1 ? g.rows : g.rows.filter((_, j) => j !== ri) } : g,
      ),
    )
  }

  return (
    <>
      {groups.map((g, gi) => (
        <div key={g.id}>
          {gi > 0 && (
            <div className="text-center text-[11px] text-text-secondary/50 italic py-1">– into –</div>
          )}
          <div className="border border-border rounded-xl overflow-hidden">
            {/* 그룹 헤더: 세트 info + 그룹 삭제 */}
            <div className="flex items-center gap-2 px-2.5 py-2 bg-accent-light/50 border-b border-border">
              <input
                placeholder="세트 정보 입력"
                value={g.setInfo}
                onChange={(e) => updateGroupInfo(gi, e.target.value)}
                className="flex-1 min-w-0 bg-transparent text-xs font-semibold text-accent outline-none placeholder:text-accent/40"
              />
              {groups.length > 1 && (
                <button
                  onClick={() => removeGroup(gi)}
                  className="w-5 h-5 flex items-center justify-center text-text-secondary/40 hover:text-danger flex-shrink-0"
                  aria-label="세트 그룹 삭제"
                >
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <line x1="18" y1="6" x2="6" y2="18" />
                    <line x1="6" y1="6" x2="18" y2="18" />
                  </svg>
                </button>
              )}
            </div>
            {/* 동작 행들 */}
            {g.rows.map((row, ri) => (
              <div
                key={row.id}
                className="grid grid-cols-[1.6fr_1fr_1.4fr_auto] gap-1.5 items-center px-2.5 py-1.5 border-t border-border"
              >
                <input
                  placeholder="동작명"
                  value={row.exercise_name}
                  onChange={(e) => updateRow(gi, ri, 'exercise_name', e.target.value)}
                  className={exInputCls}
                />
                <input
                  placeholder="횟수/시간"
                  value={row.reps}
                  onChange={(e) => updateRow(gi, ri, 'reps', e.target.value)}
                  className={`${exInputCls} text-center`}
                />
                <input
                  placeholder="메모"
                  value={row.notes}
                  onChange={(e) => updateRow(gi, ri, 'notes', e.target.value)}
                  className={exInputCls}
                />
                {g.rows.length > 1 ? (
                  <button
                    onClick={() => removeRow(gi, ri)}
                    className="w-5 h-5 flex items-center justify-center text-text-secondary/40 hover:text-danger flex-shrink-0"
                    aria-label="동작 삭제"
                  >
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                      <line x1="18" y1="6" x2="6" y2="18" />
                      <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  </button>
                ) : (
                  <span className="w-5" />
                )}
              </div>
            ))}
            {/* 그룹에 동작 추가 */}
            <button
              onClick={() => addRow(gi)}
              className="w-full text-[11px] font-medium text-accent/70 hover:text-accent py-1.5 border-t border-border"
            >
              + 동작 추가
            </button>
          </div>
        </div>
      ))}

      {/* 세트 그룹 추가 */}
      <button
        onClick={addGroup}
        className="w-full text-xs font-medium text-accent py-2 rounded-lg border border-dashed border-accent/40 hover:bg-accent/5 transition-colors"
      >
        + 세트 추가
      </button>
    </>
  )
}
