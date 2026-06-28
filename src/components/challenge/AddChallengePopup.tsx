'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import {
  getChallengeTemplates,
  getProgramsForTemplate,
  startChallenge,
  type ChallengeTemplate,
  type ChallengeProgram,
} from '@/lib/api/challenges'

const WEEKDAYS = [
  { n: 1, label: '월' }, { n: 2, label: '화' }, { n: 3, label: '수' },
  { n: 4, label: '목' }, { n: 5, label: '금' }, { n: 6, label: '토' }, { n: 7, label: '일' },
]
const BAND_COLORS = ['검정', '보라', '핑크']

interface AddChallengePopupProps {
  isOpen: boolean
  onClose: () => void
  onStarted: () => void
}

// 3단계: ① 챌린지 선택 → ② 난이도(프로그램) 선택 [+ 밴디드=밴드/갯수, 웨이티드=중량] → ③ 훈련 요일
// 난이도는 종목 불문 "프로그램 택1"로 통일. 풀업 밴디드/웨이티드만 추가 메타(표시용, 횟수 불변).
export default function AddChallengePopup({ isOpen, onClose, onStarted }: AddChallengePopupProps) {
  const [step, setStep] = useState(1)
  const [templates, setTemplates] = useState<ChallengeTemplate[]>([])
  const [template, setTemplate] = useState<ChallengeTemplate | null>(null)
  const [programs, setPrograms] = useState<ChallengeProgram[]>([])
  const [programId, setProgramId] = useState('')
  // 풀업 밴디드: 색상→갯수 (0/없음=미선택). 웨이티드: 중량(kg)
  const [bandCounts, setBandCounts] = useState<Record<string, number>>({})
  const [weightKg, setWeightKg] = useState('')
  const [weekdays, setWeekdays] = useState<number[]>([1, 2, 3, 4, 5])
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!isOpen) return
    setStep(1); setTemplate(null); setPrograms([]); setProgramId('')
    setBandCounts({}); setWeightKg('')
    setWeekdays([1, 2, 3, 4, 5]); setSaving(false)
    getChallengeTemplates().then(setTemplates).catch(() => setTemplates([]))
  }, [isOpen])

  if (!isOpen) return null

  const selProg = programs.find((p) => p.id === programId) ?? null

  async function pickTemplate(t: ChallengeTemplate) {
    setTemplate(t)
    setProgramId(''); setBandCounts({}); setWeightKg('')
    const progs = await getProgramsForTemplate(t.key)
    setPrograms(progs)
    setStep(2)
  }

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

  async function handleStart() {
    const user = getLoggedInUser()
    const prog = programs.find((p) => p.id === programId)
    if (!user || !template || !prog || weekdays.length === 0) return
    const dk = prog.difficulty_key
    const difficulty: Record<string, unknown> = { label: prog.label, difficulty_key: dk }
    if (dk === 'banded') {
      difficulty.bands = Object.entries(bandCounts)
        .filter(([, c]) => c > 0)
        .map(([color, count]) => ({ color, count }))
    }
    if (dk === 'weighted') difficulty.weight_kg = parseFloat(weightKg) || 0
    setSaving(true)
    try {
      await startChallenge({
        userId: user.id,
        templateKey: template.key,
        programId: prog.id,
        difficulty,
        trainingWeekdays: weekdays,
      })
      onStarted()
      onClose()
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">
            {step === 1 ? '챌린지 선택' : step === 2 ? '난이도 선택' : '훈련 요일'}
          </h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>

        {/* Step 1: 챌린지 선택 */}
        {step === 1 && (
          <div className="grid grid-cols-2 gap-3">
            {templates.length === 0 && <p className="col-span-2 text-sm text-text-secondary">사용 가능한 챌린지가 없어요.</p>}
            {templates.map((t) => (
              <button
                key={t.key}
                onClick={() => pickTemplate(t)}
                className="py-5 rounded-xl border border-border bg-background font-semibold text-foreground hover:border-accent"
              >
                {t.exercise}
              </button>
            ))}
          </div>
        )}

        {/* Step 2: 난이도(프로그램) 선택 + 밴드/중량 추가 구성 */}
        {step === 2 && (
          <div className="space-y-3">
            <p className="text-sm text-text-secondary">난이도를 골라주세요.</p>
            {programs.length === 0 && <p className="text-sm text-text-secondary">난이도 프로그램이 없어요.</p>}
            <div className="grid grid-cols-2 gap-2">
              {programs.map((p) => (
                <button
                  key={p.id}
                  type="button"
                  onClick={() => setProgramId(p.id)}
                  className={`py-2.5 px-3 rounded-lg border text-sm font-medium text-foreground ${programId === p.id ? 'border-accent bg-accent/10' : 'border-border bg-background'}`}
                >
                  {p.label ?? p.difficulty_key}
                </button>
              ))}
            </div>

            {/* 밴디드: 밴드 종류(복수) + 각 갯수 */}
            {selProg?.difficulty_key === 'banded' && (
              <div className="space-y-2 pt-1">
                <p className="text-xs text-text-secondary">밴드 종류(복수 선택) · 갯수</p>
                {BAND_COLORS.map((color) => {
                  const cnt = bandCounts[color] ?? 0
                  const on = cnt > 0
                  return (
                    <div key={color} className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => toggleBand(color)}
                        className={`w-16 px-3 py-1.5 rounded-lg text-sm border ${on ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}
                      >
                        {color}
                      </button>
                      <div className="flex gap-1">
                        {[1, 2, 3].map((n) => (
                          <button
                            key={n}
                            type="button"
                            disabled={!on}
                            onClick={() => setBandCount(color, n)}
                            className={`w-9 h-9 rounded-lg text-sm border disabled:opacity-40 ${cnt === n ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}
                          >
                            {n}
                          </button>
                        ))}
                      </div>
                    </div>
                  )
                })}
              </div>
            )}

            {/* 웨이티드: 중량(kg) */}
            {selProg?.difficulty_key === 'weighted' && (
              <div className="pt-1">
                <label className="block text-sm text-text-secondary mb-1">중량 (kg)</label>
                <input
                  type="number"
                  inputMode="decimal"
                  value={weightKg}
                  onChange={(e) => setWeightKg(e.target.value)}
                  placeholder="0"
                  step="0.5"
                  className="w-full px-3 py-2 rounded-lg border border-border bg-background text-foreground focus:outline-none focus:border-accent"
                />
              </div>
            )}

            <button
              onClick={() => setStep(3)}
              disabled={!programId}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50"
            >
              다음
            </button>
          </div>
        )}

        {/* Step 3: 훈련 요일 */}
        {step === 3 && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-text-secondary mb-2">훈련 요일 (기본 월~금)</label>
              <div className="flex gap-1">
                {WEEKDAYS.map((w) => (
                  <button
                    key={w.n}
                    type="button"
                    onClick={() => toggleWeekday(w.n)}
                    className={`w-10 h-10 rounded-lg text-sm font-medium border ${weekdays.includes(w.n) ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}
                  >
                    {w.label}
                  </button>
                ))}
              </div>
            </div>
            <button
              onClick={handleStart}
              disabled={saving || weekdays.length === 0}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50"
            >
              {saving ? '시작 중…' : '시작'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
