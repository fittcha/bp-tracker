'use client'

import { useEffect, useState, useCallback } from 'react'
import {
  getWeeks,
  getTemplatesByWeek,
  createTemplate,
  deleteTemplate,
  copyWeekTemplates,
  WorkoutTemplate,
} from '@/lib/api/workout-templates'

interface Week {
  id: string
  week_number: number
  phase: string
}

export default function AdminWorkoutPage() {
  const [weeks, setWeeks] = useState<Week[]>([])
  const [selectedWeekId, setSelectedWeekId] = useState('')
  const [selectedDay, setSelectedDay] = useState(1)
  const [templates, setTemplates] = useState<WorkoutTemplate[]>([])
  const [loading, setLoading] = useState(true)

  // New exercise form
  const [newExercise, setNewExercise] = useState({
    section: '',
    exercise_name: '',
    sets: '',
    reps: '',
    rest_seconds: '',
    notes: '',
  })

  const [copyFromWeekId, setCopyFromWeekId] = useState('')

  useEffect(() => {
    async function loadWeeks() {
      const data = await getWeeks()
      setWeeks(data || [])
      if (data?.length) setSelectedWeekId(data[0].id)
      setLoading(false)
    }
    loadWeeks()
  }, [])

  const loadTemplates = useCallback(async () => {
    if (!selectedWeekId) return
    const data = await getTemplatesByWeek(selectedWeekId)
    setTemplates(data || [])
  }, [selectedWeekId])

  useEffect(() => {
    loadTemplates()
  }, [loadTemplates])

  const dayTemplates = templates.filter(t => t.day_number === selectedDay)

  async function handleAdd() {
    if (!newExercise.section || !newExercise.exercise_name) return
    const maxOrder = dayTemplates.length > 0
      ? Math.max(...dayTemplates.map(t => t.sort_order)) + 1
      : 1

    await createTemplate({
      week_id: selectedWeekId,
      day_number: selectedDay,
      section: newExercise.section,
      exercise_name: newExercise.exercise_name,
      sets: newExercise.sets || null,
      reps: newExercise.reps || null,
      rest_seconds: newExercise.rest_seconds ? parseInt(newExercise.rest_seconds) : null,
      notes: newExercise.notes || null,
      sort_order: maxOrder,
    })

    setNewExercise({ section: '', exercise_name: '', sets: '', reps: '', rest_seconds: '', notes: '' })
    loadTemplates()
  }

  async function handleDelete(id: string) {
    await deleteTemplate(id)
    loadTemplates()
  }

  async function handleCopyWeek() {
    if (!copyFromWeekId || !selectedWeekId) return
    await copyWeekTemplates(copyFromWeekId, selectedWeekId)
    loadTemplates()
    setCopyFromWeekId('')
  }

  if (loading) return <div className="p-4">로딩 중...</div>

  const selectedWeek = weeks.find(w => w.id === selectedWeekId)

  return (
    <div className="space-y-6">
      <h2 className="text-lg font-bold">운동 템플릿 관리</h2>

      {/* Week selector */}
      <div className="flex gap-2 items-center">
        <select
          value={selectedWeekId}
          onChange={(e) => setSelectedWeekId(e.target.value)}
          className="border border-border rounded-lg px-3 py-2 text-sm bg-surface"
        >
          {weeks.map(w => (
            <option key={w.id} value={w.id}>{w.week_number}주차 - {w.phase}</option>
          ))}
        </select>
      </div>

      {/* Day tabs */}
      <div className="flex gap-2">
        {[1, 2, 3, 4, 5].map(day => (
          <button
            key={day}
            onClick={() => setSelectedDay(day)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              selectedDay === day
                ? 'bg-accent text-white'
                : 'bg-surface text-text-secondary border border-border'
            }`}
          >
            Day {day}
          </button>
        ))}
      </div>

      {/* Templates list */}
      <div className="space-y-2">
        {dayTemplates.length === 0 && (
          <p className="text-sm text-text-secondary py-4">등록된 운동이 없습니다</p>
        )}
        {dayTemplates.map(t => (
          <div key={t.id} className="bg-surface border border-border rounded-xl p-3 flex items-start justify-between">
            <div>
              <span className="text-xs font-bold text-accent mr-2">{t.section}.</span>
              <span className="text-sm font-medium">{t.exercise_name}</span>
              <p className="text-xs text-text-secondary mt-1">
                {t.sets && `${t.sets}세트`} {t.reps && `× ${t.reps}`} {t.rest_seconds && `/ 휴식 ${t.rest_seconds}초`}
              </p>
              {t.notes && <p className="text-xs text-text-secondary mt-0.5">{t.notes}</p>}
            </div>
            <button
              onClick={() => t.id && handleDelete(t.id)}
              className="text-danger text-xs px-2 py-1"
            >
              삭제
            </button>
          </div>
        ))}
      </div>

      {/* Add new exercise */}
      <div className="bg-surface border border-border rounded-xl p-4 space-y-3">
        <p className="text-sm font-medium">운동 추가</p>
        <div className="grid grid-cols-2 gap-2">
          <input
            placeholder="섹션 (A, B, C...)"
            value={newExercise.section}
            onChange={(e) => setNewExercise(prev => ({ ...prev, section: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <input
            placeholder="운동명"
            value={newExercise.exercise_name}
            onChange={(e) => setNewExercise(prev => ({ ...prev, exercise_name: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <input
            placeholder="세트 수"
            value={newExercise.sets}
            onChange={(e) => setNewExercise(prev => ({ ...prev, sets: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
            inputMode="numeric"
          />
          <input
            placeholder="렙 (예: 10~15)"
            value={newExercise.reps}
            onChange={(e) => setNewExercise(prev => ({ ...prev, reps: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <input
            placeholder="휴식(초)"
            value={newExercise.rest_seconds}
            onChange={(e) => setNewExercise(prev => ({ ...prev, rest_seconds: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
            inputMode="numeric"
          />
          <input
            placeholder="메모"
            value={newExercise.notes}
            onChange={(e) => setNewExercise(prev => ({ ...prev, notes: e.target.value }))}
            className="border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
        </div>
        <button
          onClick={handleAdd}
          className="w-full bg-accent text-white rounded-lg py-2 text-sm font-medium"
        >
          추가
        </button>
      </div>

      {/* Copy from another week */}
      <div className="bg-surface border border-border rounded-xl p-4 space-y-3">
        <p className="text-sm font-medium">다른 주차에서 복사</p>
        <div className="flex gap-2">
          <select
            value={copyFromWeekId}
            onChange={(e) => setCopyFromWeekId(e.target.value)}
            className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-background"
          >
            <option value="">주차 선택</option>
            {weeks.filter(w => w.id !== selectedWeekId).map(w => (
              <option key={w.id} value={w.id}>{w.week_number}주차</option>
            ))}
          </select>
          <button
            onClick={handleCopyWeek}
            className="bg-text-secondary text-white rounded-lg px-4 py-2 text-sm font-medium"
          >
            복사
          </button>
        </div>
      </div>
    </div>
  )
}
