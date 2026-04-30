'use client'

import { useState, useEffect } from 'react'

interface CustomExerciseFormProps {
  onAdd: (name: string, section?: string, sets?: string, reps?: string) => void
  editingLog?: {
    id: string
    exercise_name: string
    section: string | null
    custom_sets: string | null
    custom_reps: string | null
  } | null
  onUpdate?: (id: string, name: string, section: string | null, sets: string | null, reps: string | null) => void
  onCancelEdit?: () => void
}

export default function CustomExerciseForm({ onAdd, editingLog, onUpdate, onCancelEdit }: CustomExerciseFormProps) {
  const [name, setName] = useState('')
  const [section, setSection] = useState('')
  const [sets, setSets] = useState('')
  const [reps, setReps] = useState('')
  const [open, setOpen] = useState(false)

  const isEditing = !!editingLog

  useEffect(() => {
    if (editingLog) {
      setName(editingLog.exercise_name)
      setSection(editingLog.section || '')
      setSets(editingLog.custom_sets || '')
      setReps(editingLog.custom_reps || '')
      setOpen(true)
    }
  }, [editingLog])

  function resetForm() {
    setName('')
    setSection('')
    setSets('')
    setReps('')
    setOpen(false)
  }

  function handleSubmit() {
    if (!name.trim()) return
    if (isEditing && onUpdate) {
      onUpdate(
        editingLog!.id,
        name.trim(),
        section.trim() || null,
        sets.trim() || null,
        reps.trim() || null,
      )
    } else {
      onAdd(name.trim(), section.trim() || undefined, sets.trim() || undefined, reps.trim() || undefined)
    }
    resetForm()
  }

  function handleCancel() {
    resetForm()
    if (isEditing && onCancelEdit) onCancelEdit()
  }

  if (!open && !isEditing) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="w-full border-2 border-dashed border-accent/30 rounded-xl py-3 text-sm font-medium text-accent hover:border-accent/50 transition-colors"
      >
        + 운동 추가
      </button>
    )
  }

  return (
    <div className="bg-accent-light border border-accent/20 rounded-xl p-4 space-y-3">
      <input
        autoFocus
        placeholder="운동명"
        value={name}
        onChange={(e) => setName(e.target.value)}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      />
      <input
        placeholder="섹션 (예: 복근, 스트레칭)"
        value={section}
        onChange={(e) => setSection(e.target.value)}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      />
      <div className="flex gap-2">
        <input
          placeholder="세트 (예: 4)"
          value={sets}
          onChange={(e) => setSets(e.target.value)}
          className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-surface"
        />
        <input
          placeholder="렙 (예: 12)"
          value={reps}
          onChange={(e) => setReps(e.target.value)}
          className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-surface"
        />
      </div>
      <div className="flex gap-2">
        <button
          onClick={handleSubmit}
          className="flex-1 bg-accent text-white rounded-lg py-2 text-sm font-medium"
        >
          {isEditing ? '수정' : '추가'}
        </button>
        <button
          onClick={handleCancel}
          className="px-4 py-2 text-sm text-text-secondary"
        >
          취소
        </button>
      </div>
    </div>
  )
}
