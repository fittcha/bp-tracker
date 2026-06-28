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

// 사용자의 밴드 색상 목록(필요 시 조정). 표 이미지 확정 시 갱신.
const BAND_COLORS = ['노랑', '빨강', '초록', '파랑', '검정', '보라']
const WEEKDAYS = [
  { n: 1, label: '월' }, { n: 2, label: '화' }, { n: 3, label: '수' },
  { n: 4, label: '목' }, { n: 5, label: '금' }, { n: 6, label: '토' }, { n: 7, label: '일' },
]

interface AddChallengePopupProps {
  isOpen: boolean
  onClose: () => void
  onStarted: () => void
}

type EquipType = 'band' | 'bodyweight' | 'weighted'

export default function AddChallengePopup({ isOpen, onClose, onStarted }: AddChallengePopupProps) {
  const [step, setStep] = useState(1)
  const [templates, setTemplates] = useState<ChallengeTemplate[]>([])
  const [template, setTemplate] = useState<ChallengeTemplate | null>(null)
  const [programs, setPrograms] = useState<ChallengeProgram[]>([])

  // 풀업(equipment) 난이도
  const [equipType, setEquipType] = useState<EquipType>('band')
  const [bandColor, setBandColor] = useState(BAND_COLORS[0])
  const [bandCount, setBandCount] = useState(1)
  const [weightKg, setWeightKg] = useState('')
  // 푸쉬업(range) 난이도
  const [programId, setProgramId] = useState<string>('')

  const [weekdays, setWeekdays] = useState<number[]>([1, 2, 3, 4, 5])
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!isOpen) return
    setStep(1); setTemplate(null); setPrograms([]); setProgramId('')
    setEquipType('band'); setBandColor(BAND_COLORS[0]); setBandCount(1); setWeightKg('')
    setWeekdays([1, 2, 3, 4, 5])
    setSaving(false)
    getChallengeTemplates().then(setTemplates).catch(() => setTemplates([]))
  }, [isOpen])

  if (!isOpen) return null

  async function pickTemplate(t: ChallengeTemplate) {
    setTemplate(t)
    const progs = await getProgramsForTemplate(t.key)
    setPrograms(progs)
    if (t.difficulty_mode === 'range' && progs[0]) setProgramId(progs[0].id)
    setStep(2)
  }

  function toggleWeekday(n: number) {
    setWeekdays((prev) => (prev.includes(n) ? prev.filter((x) => x !== n) : [...prev, n].sort((a, b) => a - b)))
  }

  function resolveStart(): { programId: string; difficulty: Record<string, unknown> } | null {
    if (!template) return null
    if (template.difficulty_mode === 'equipment') {
      const prog = programs[0]
      if (!prog) return null
      let difficulty: Record<string, unknown>
      if (equipType === 'band') difficulty = { type: 'band', color: bandColor, count: bandCount }
      else if (equipType === 'weighted') difficulty = { type: 'weighted', weight_kg: parseFloat(weightKg) || 0 }
      else difficulty = { type: 'bodyweight' }
      return { programId: prog.id, difficulty }
    }
    // range
    const prog = programs.find((p) => p.id === programId)
    if (!prog) return null
    return { programId: prog.id, difficulty: { type: 'range', difficulty_key: prog.difficulty_key, label: prog.label } }
  }

  async function handleStart() {
    const user = getLoggedInUser()
    const resolved = resolveStart()
    if (!user || !template || !resolved || weekdays.length === 0) return
    setSaving(true)
    try {
      await startChallenge({
        userId: user.id,
        templateKey: template.key,
        programId: resolved.programId,
        difficulty: resolved.difficulty,
        trainingWeekdays: weekdays,
      })
      onStarted()
      onClose()
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-t-2xl p-6 pb-8 animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">
            {step === 1 ? '챌린지 선택' : step === 2 ? '난이도 구성' : '훈련 요일'}
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
                className="p-4 rounded-xl border border-border bg-background text-left hover:border-accent"
              >
                <p className="font-semibold text-foreground">{t.name}</p>
                <p className="text-xs text-text-secondary mt-1">{t.exercise}</p>
              </button>
            ))}
          </div>
        )}

        {/* Step 2: 난이도 */}
        {step === 2 && template?.difficulty_mode === 'equipment' && (
          <div className="space-y-4">
            <div className="flex gap-2">
              {([['band', '밴드'], ['bodyweight', '맨몸'], ['weighted', '중량']] as const).map(([v, l]) => (
                <button key={v} type="button" onClick={() => setEquipType(v)}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium border ${equipType === v ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                  {l}
                </button>
              ))}
            </div>
            {equipType === 'band' && (
              <div className="space-y-3">
                <div>
                  <label className="block text-sm text-text-secondary mb-1">밴드 색상</label>
                  <div className="flex flex-wrap gap-1">
                    {BAND_COLORS.map((c) => (
                      <button key={c} type="button" onClick={() => setBandColor(c)}
                        className={`px-3 py-1.5 rounded-lg text-sm border ${bandColor === c ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                        {c}
                      </button>
                    ))}
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-text-secondary mb-1">갯수</label>
                  <div className="flex gap-1">
                    {[1, 2, 3].map((n) => (
                      <button key={n} type="button" onClick={() => setBandCount(n)}
                        className={`w-10 h-10 rounded-lg text-sm font-medium border ${bandCount === n ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                        {n}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}
            {equipType === 'weighted' && (
              <div>
                <label className="block text-sm text-text-secondary mb-1">중량 (kg)</label>
                <input type="number" inputMode="decimal" value={weightKg} onChange={(e) => setWeightKg(e.target.value)}
                  placeholder="0" step="0.5"
                  className="w-full px-3 py-2 rounded-lg border border-border bg-background text-foreground focus:outline-none focus:border-accent" />
              </div>
            )}
            <button onClick={() => setStep(3)} disabled={programs.length === 0}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50">다음</button>
          </div>
        )}

        {step === 2 && template?.difficulty_mode === 'range' && (
          <div className="space-y-3">
            {programs.length === 0 && <p className="text-sm text-text-secondary">난이도 프로그램이 없어요.</p>}
            {programs.map((p) => (
              <button key={p.id} type="button" onClick={() => setProgramId(p.id)}
                className={`w-full p-3 rounded-lg border text-left ${programId === p.id ? 'border-accent bg-accent/10' : 'border-border bg-background'}`}>
                <span className="text-sm font-medium text-foreground">{p.label ?? p.difficulty_key}</span>
              </button>
            ))}
            <button onClick={() => setStep(3)} disabled={!programId}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50">다음</button>
          </div>
        )}

        {/* Step 3: 훈련 요일 */}
        {step === 3 && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-text-secondary mb-2">훈련 요일 (기본 월~금)</label>
              <div className="flex gap-1">
                {WEEKDAYS.map((w) => (
                  <button key={w.n} type="button" onClick={() => toggleWeekday(w.n)}
                    className={`w-10 h-10 rounded-lg text-sm font-medium border ${weekdays.includes(w.n) ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                    {w.label}
                  </button>
                ))}
              </div>
            </div>
            <button onClick={handleStart} disabled={saving || weekdays.length === 0}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50">
              {saving ? '시작 중…' : '시작'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
