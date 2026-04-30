'use client'

import { useState } from 'react'

interface ExerciseRow {
  type: 'exercise' | 'andthen'
  name: string
  info: string
}

interface CustomExerciseFormProps {
  onAddMultiple: (section: string | undefined, sectionInfo: string | undefined, rows: ExerciseRow[]) => void
}

export default function CustomExerciseForm({ onAddMultiple }: CustomExerciseFormProps) {
  const [open, setOpen] = useState(false)
  const [section, setSection] = useState('')
  const [sectionInfo, setSectionInfo] = useState('')
  const [rows, setRows] = useState<ExerciseRow[]>([{ type: 'exercise', name: '', info: '' }])

  function resetForm() {
    setSection('')
    setSectionInfo('')
    setRows([{ type: 'exercise', name: '', info: '' }])
    setOpen(false)
  }

  function addRow(type: 'exercise' | 'andthen') {
    setRows(prev => [...prev, type === 'exercise' ? { type: 'exercise', name: '', info: '' } : { type: 'andthen', name: '— and then —', info: '' }])
  }

  function removeRow(index: number) {
    setRows(prev => prev.length <= 1 ? prev : prev.filter((_, i) => i !== index))
  }

  function updateRow(index: number, field: 'name' | 'info', value: string) {
    setRows(prev => prev.map((r, i) => i === index ? { ...r, [field]: value } : r))
  }

  function handleSubmit() {
    const validRows = rows.filter(r => r.type === 'andthen' || r.name.trim())
    if (validRows.length === 0) return
    onAddMultiple(
      section.trim() || undefined,
      sectionInfo.trim() || undefined,
      validRows,
    )
    resetForm()
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
    <div className="bg-surface border border-accent/20 rounded-xl overflow-hidden">
      {/* Section header */}
      <div className="px-4 py-1.5 bg-accent-light border-b border-accent/20 flex items-center gap-2">
        <div className="w-5 h-5 rounded border-2 border-accent/30 flex items-center justify-center flex-shrink-0">
          <span className="text-accent text-[10px] font-bold">+</span>
        </div>
        <input
          autoFocus
          placeholder="section (ex: A, legs)"
          value={section}
          onChange={(e) => setSection(e.target.value)}
          className="text-xs font-bold text-accent bg-transparent outline-none placeholder:text-accent/40 min-w-0 flex-1"
        />
        <input
          placeholder="set info (ex: 4 sets, amrap 10, emom 10)"
          value={sectionInfo}
          onChange={(e) => setSectionInfo(e.target.value)}
          className="flex-1 text-xs text-text-secondary font-medium bg-transparent outline-none placeholder:text-text-secondary/40"
        />
      </div>
      {/* Exercise rows */}
      <div className="divide-y divide-border">
        {rows.map((row, i) => {
          if (row.type === 'andthen') {
            return (
              <div key={i} className="flex items-center px-4 py-1.5">
                <span className="flex-1 text-[11px] text-text-secondary/50 text-center italic">and then</span>
                <button
                  onClick={() => removeRow(i)}
                  className="w-4 h-4 flex items-center justify-center text-text-secondary/20 hover:text-danger transition-colors flex-shrink-0"
                >
                  <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                  </svg>
                </button>
              </div>
            )
          }
          return (
            <div key={i} className="flex items-center gap-3 px-4 py-3">
              <div className="w-5 h-5 rounded-full border-2 border-accent/30 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <input
                  placeholder="exercise name"
                  value={row.name}
                  onChange={(e) => updateRow(i, 'name', e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
                  className="w-full text-sm font-medium text-accent bg-transparent outline-none placeholder:text-accent/40"
                />
                <input
                  placeholder="exercise info (ex: 50lb, rest 60s, × 12)"
                  value={row.info}
                  onChange={(e) => updateRow(i, 'info', e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
                  className="w-full text-[11px] text-text-secondary italic bg-transparent outline-none mt-0.5 placeholder:text-text-secondary/40 placeholder:not-italic"
                />
              </div>
              {rows.length > 1 && (
                <button
                  onClick={() => removeRow(i)}
                  className="w-5 h-5 flex items-center justify-center text-text-secondary/30 hover:text-danger transition-colors flex-shrink-0"
                >
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                  </svg>
                </button>
              )}
            </div>
          )
        })}
      </div>
      {/* Add row + action buttons */}
      <div className="px-4 py-2 border-t border-accent/20 flex items-center">
        <div className="flex gap-3">
          <button
            onClick={() => addRow('exercise')}
            className="text-[11px] text-accent/40 hover:text-accent transition-colors"
          >
            + 운동
          </button>
          <button
            onClick={() => addRow('andthen')}
            className="text-[11px] text-text-secondary/40 hover:text-text-secondary transition-colors"
          >
            + and then
          </button>
        </div>
        <div className="flex-1" />
        <button
          onClick={resetForm}
          className="px-3 py-1 text-xs text-text-secondary"
        >
          취소
        </button>
        <button
          onClick={handleSubmit}
          className="px-4 py-1 bg-accent text-white rounded-lg text-xs font-medium"
        >
          추가
        </button>
      </div>
    </div>
  )
}
