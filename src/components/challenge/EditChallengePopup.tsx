'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
import { updateChallenge, type UserChallenge } from '@/lib/api/challenges'

const WEEKDAYS = [
  { n: 1, label: '월' }, { n: 2, label: '화' }, { n: 3, label: '수' },
  { n: 4, label: '목' }, { n: 5, label: '금' }, { n: 6, label: '토' }, { n: 7, label: '일' },
]
const BAND_COLORS = ['검정', '보라', '핑크']
const EYEBROW = 'text-[11px] font-semibold uppercase tracking-wider text-text-secondary/70'

interface EditChallengePopupProps {
  isOpen: boolean
  challenge: UserChallenge | null
  onClose: () => void
  onSaved: () => void
}

// 훈련 요일 + 난이도 메타(밴드/중량) 수정. 트랙/변형은 읽기전용(변경 시 새 챌린지로 시작).
export default function EditChallengePopup({ isOpen, challenge, onClose, onSaved }: EditChallengePopupProps) {
  const [weekdays, setWeekdays] = useState<number[]>([1, 2, 3, 4, 5])
  const [bandCounts, setBandCounts] = useState<Record<string, number>>({})
  const [weightKg, setWeightKg] = useState('')
  const [saving, setSaving] = useState(false)

  const diff = (challenge?.difficulty ?? {}) as Record<string, unknown>
  const dk = typeof diff.difficulty_key === 'string' ? diff.difficulty_key : undefined
  const label = String(diff.label ?? dk ?? '')

  useEffect(() => {
    if (!isOpen || !challenge) return
    setWeekdays(challenge.training_weekdays?.length ? challenge.training_weekdays : [1, 2, 3, 4, 5])
    const d = challenge.difficulty as Record<string, unknown>
    if (Array.isArray(d.bands)) {
      const bc: Record<string, number> = {}
      for (const b of d.bands as Array<{ color?: unknown; count?: unknown }>) {
        if (b && typeof b.color === 'string') bc[b.color] = Number(b.count) || 1
      }
      setBandCounts(bc)
    } else setBandCounts({})
    setWeightKg(d.weight_kg != null ? String(d.weight_kg) : '')
    setSaving(false)
  }, [isOpen, challenge])

  if (!isOpen || !challenge) return null

  function toggleBand(color: string) {
    setBandCounts((prev) => {
      const next = { ...prev }
      if (next[color]) delete next[color]
      else next[color] = 1
      return next
    })
  }
  function setBandCount(color: string, n: number) {
    setBandCounts((prev) => ({ ...prev, [color]: n }))
  }
  function toggleWeekday(n: number) {
    setWeekdays((prev) => (prev.includes(n) ? prev.filter((x) => x !== n) : [...prev, n].sort((a, b) => a - b)))
  }

  async function handleSave() {
    if (!challenge || weekdays.length === 0) return
    const difficulty: Record<string, unknown> = { label, difficulty_key: dk }
    if (dk === 'banded') {
      difficulty.bands = Object.entries(bandCounts).filter(([, c]) => c > 0).map(([color, count]) => ({ color, count }))
    }
    if (dk === 'weighted') difficulty.weight_kg = parseFloat(weightKg) || 0
    setSaving(true)
    try {
      await updateChallenge(challenge.id, { trainingWeekdays: weekdays, difficulty })
      onSaved()
      onClose()
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-md bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto animate-slide-up">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-lg font-bold text-foreground">챌린지 수정</h3>
          <button onClick={onClose} className="-mr-1 p-1 text-text-secondary/60 hover:text-text-secondary transition-colors" aria-label="닫기"><X size={20} /></button>
        </div>

        <div className="space-y-5">
          {/* 난이도 (읽기전용) */}
          <div>
            <span className={EYEBROW}>난이도</span>
            <p className="text-sm text-foreground mt-1">
              {label} <span className="text-text-secondary/70">· 변경하려면 새 챌린지로 시작</span>
            </p>
          </div>

          {/* 밴드 (밴디드) */}
          {dk === 'banded' && (
            <div className="space-y-2">
              <span className={EYEBROW}>밴드 (복수 선택) · 갯수</span>
              {BAND_COLORS.map((color) => {
                const cnt = bandCounts[color] ?? 0
                const on = cnt > 0
                return (
                  <div key={color} className="flex items-center gap-2">
                    <button type="button" onClick={() => toggleBand(color)}
                      className={`px-3.5 py-1.5 rounded-full text-sm border ${on ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                      {color}
                    </button>
                    <div className="flex gap-1">
                      {[1, 2, 3].map((n) => (
                        <button key={n} type="button" disabled={!on} onClick={() => setBandCount(color, n)}
                          className={`w-9 h-9 rounded-lg text-sm border disabled:opacity-40 ${cnt === n ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                          {n}
                        </button>
                      ))}
                    </div>
                  </div>
                )
              })}
            </div>
          )}

          {/* 중량 (웨이티드) */}
          {dk === 'weighted' && (
            <div>
              <label className={`block ${EYEBROW} mb-1`}>중량 (kg)</label>
              <input type="number" inputMode="decimal" value={weightKg} onChange={(e) => setWeightKg(e.target.value)}
                placeholder="0" step="0.5"
                className="w-full px-3.5 py-2.5 rounded-xl border border-border bg-background text-foreground text-sm focus:outline-none focus:border-accent" />
            </div>
          )}

          {/* 훈련 요일 */}
          <div>
            <label className={`block ${EYEBROW} mb-2`}>훈련 요일</label>
            <div className="flex gap-1">
              {WEEKDAYS.map((w) => (
                <button key={w.n} type="button" onClick={() => toggleWeekday(w.n)}
                  className={`w-10 h-10 rounded-lg text-sm font-medium border ${weekdays.includes(w.n) ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                  {w.label}
                </button>
              ))}
            </div>
          </div>

          <button onClick={handleSave} disabled={saving || weekdays.length === 0}
            className="w-full py-3 rounded-xl bg-accent text-white font-semibold disabled:opacity-50">
            {saving ? '저장 중…' : '저장'}
          </button>
        </div>
      </div>
    </div>
  )
}
