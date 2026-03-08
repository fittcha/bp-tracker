'use client'

import { useState } from 'react'

interface CustomExerciseFormProps {
  onAdd: (name: string) => void
}

export default function CustomExerciseForm({ onAdd }: CustomExerciseFormProps) {
  const [name, setName] = useState('')
  const [open, setOpen] = useState(false)

  function handleSubmit() {
    if (!name.trim()) return
    onAdd(name.trim())
    setName('')
    setOpen(false)
  }

  if (!open) {
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
        placeholder="운동명 입력"
        value={name}
        onChange={(e) => setName(e.target.value)}
        onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      />
      <div className="flex gap-2">
        <button
          onClick={handleSubmit}
          className="flex-1 bg-accent text-white rounded-lg py-2 text-sm font-medium"
        >
          추가
        </button>
        <button
          onClick={() => { setOpen(false); setName('') }}
          className="px-4 py-2 text-sm text-text-secondary"
        >
          취소
        </button>
      </div>
    </div>
  )
}
