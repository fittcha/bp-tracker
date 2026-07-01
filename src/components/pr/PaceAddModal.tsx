'use client'

import { useState } from 'react'
import { X } from 'lucide-react'
import { PACE_DISTANCE_KM } from '@/lib/api/pr'

const DEFAULT_EQUIPMENT = ['Rowing', 'Running']
const DISTANCE_BY_EQUIPMENT: Record<string, string[]> = {
  'Rowing': ['2K', '5K'],
  'Running': ['5K', '10K', 'HALF', 'FULL'],
}

interface PaceAddModalProps {
  isOpen: boolean
  onClose: () => void
  onSave: (equipment: string, distance: string, timeSeconds: number) => Promise<void>
}

export default function PaceAddModal({ isOpen, onClose, onSave }: PaceAddModalProps) {
  const [equipment, setEquipment] = useState('')
  const [distance, setDistance] = useState('')
  const [hours, setHours] = useState('')
  const [minutes, setMinutes] = useState('')
  const [seconds, setSeconds] = useState('')
  const [saving, setSaving] = useState(false)

  if (!isOpen) return null

  // 러닝은 하프/풀 등 1시간 초과가 흔해 hh:mm:ss, 로잉은 mm:ss.
  const showHours = equipment === 'Running'
  const totalSeconds =
    (showHours ? (parseInt(hours) || 0) * 3600 : 0) +
    (parseInt(minutes) || 0) * 60 +
    (parseInt(seconds) || 0)

  function reset() {
    setEquipment('')
    setDistance('')
    setHours('')
    setMinutes('')
    setSeconds('')
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!equipment || !distance || totalSeconds <= 0 || saving) return
    setSaving(true)
    try {
      await onSave(equipment, distance, totalSeconds)
      reset()
    } catch (err) {
      console.error('Failed to save pace:', err)
    } finally {
      setSaving(false)
    }
  }

  const inputCls =
    'w-full min-w-0 px-3 py-2 rounded-lg border border-border bg-background text-foreground text-center focus:outline-none focus:border-accent'

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">페이스 기록 추가</h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-text-secondary mb-1">종목 *</label>
            <div className="flex gap-2">
              {DEFAULT_EQUIPMENT.map(eq => (
                <button
                  key={eq}
                  type="button"
                  onClick={() => { setEquipment(eq); setDistance('') }}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium ${
                    equipment === eq ? 'bg-accent text-white' : 'bg-background border border-border text-foreground'
                  }`}
                >
                  {eq}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="block text-sm text-text-secondary mb-1">거리 *</label>
            <div className="flex gap-2">
              {(DISTANCE_BY_EQUIPMENT[equipment] || ['2K', '5K']).map(d => (
                <button
                  key={d}
                  type="button"
                  onClick={() => setDistance(d)}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium ${
                    distance === d ? 'bg-accent text-white' : 'bg-background border border-border text-foreground'
                  }`}
                >
                  {d}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="block text-sm text-text-secondary mb-1">
              총 시간 ({showHours ? 'hh:mm:ss' : 'mm:ss'}) *
            </label>
            <div className={`grid ${showHours ? 'grid-cols-[1fr_auto_1fr_auto_1fr]' : 'grid-cols-[1fr_auto_1fr]'} items-center gap-2`}>
              {showHours && (
                <>
                  <input type="number" value={hours} onChange={e => setHours(e.target.value)} placeholder="시" min="0" className={inputCls} />
                  <span className="text-lg font-bold">:</span>
                </>
              )}
              <input type="number" value={minutes} onChange={e => setMinutes(e.target.value)} placeholder="분" min="0" className={inputCls} />
              <span className="text-lg font-bold">:</span>
              <input type="number" value={seconds} onChange={e => setSeconds(e.target.value)} placeholder="초" min="0" max="59" className={inputCls} />
            </div>
            {equipment && distance && totalSeconds > 0 && (() => {
              const km = PACE_DISTANCE_KM[distance] ?? parseInt(distance) ?? 0
              const splits = equipment === 'Rowing' ? (km * 1000) / 500 : km
              if (splits <= 0) return null
              const paceSeconds = totalSeconds / splits
              const pm = Math.floor(paceSeconds / 60)
              const ps = paceSeconds % 60
              const label = equipment === 'Rowing' ? '/500m' : '/km'
              return (
                <p className="text-sm text-accent font-medium mt-2 text-center">
                  페이스: {pm}:{ps.toFixed(1).padStart(4, '0')}{label}
                </p>
              )
            })()}
          </div>
          <button
            type="submit"
            disabled={!equipment || !distance || totalSeconds <= 0 || saving}
            className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50"
          >
            {saving ? '저장 중...' : '저장'}
          </button>
        </form>
      </div>
    </div>
  )
}
