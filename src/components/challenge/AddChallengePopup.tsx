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

interface AddChallengePopupProps {
  isOpen: boolean
  onClose: () => void
  onStarted: () => void
}

// 3단계: ① 챌린지 선택 → ② 난이도(프로그램) 선택 → ③ 훈련 요일
// 난이도는 종목 불문 "프로그램 택1"로 통일 (푸쉬업=최대개수 트랙, 풀업=변형).
export default function AddChallengePopup({ isOpen, onClose, onStarted }: AddChallengePopupProps) {
  const [step, setStep] = useState(1)
  const [templates, setTemplates] = useState<ChallengeTemplate[]>([])
  const [template, setTemplate] = useState<ChallengeTemplate | null>(null)
  const [programs, setPrograms] = useState<ChallengeProgram[]>([])
  const [programId, setProgramId] = useState('')
  const [weekdays, setWeekdays] = useState<number[]>([1, 2, 3, 4, 5])
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!isOpen) return
    setStep(1); setTemplate(null); setPrograms([]); setProgramId('')
    setWeekdays([1, 2, 3, 4, 5]); setSaving(false)
    getChallengeTemplates().then(setTemplates).catch(() => setTemplates([]))
  }, [isOpen])

  if (!isOpen) return null

  async function pickTemplate(t: ChallengeTemplate) {
    setTemplate(t)
    setProgramId('')
    const progs = await getProgramsForTemplate(t.key)
    setPrograms(progs)
    setStep(2)
  }

  function toggleWeekday(n: number) {
    setWeekdays((prev) => (prev.includes(n) ? prev.filter((x) => x !== n) : [...prev, n].sort((a, b) => a - b)))
  }

  async function handleStart() {
    const user = getLoggedInUser()
    const prog = programs.find((p) => p.id === programId)
    if (!user || !template || !prog || weekdays.length === 0) return
    setSaving(true)
    try {
      await startChallenge({
        userId: user.id,
        templateKey: template.key,
        programId: prog.id,
        difficulty: { label: prog.label, difficulty_key: prog.difficulty_key },
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
                className="p-4 rounded-xl border border-border bg-background text-left hover:border-accent"
              >
                <p className="font-semibold text-foreground">{t.name}</p>
                <p className="text-xs text-text-secondary mt-1">{t.exercise}</p>
              </button>
            ))}
          </div>
        )}

        {/* Step 2: 난이도(프로그램) 선택 */}
        {step === 2 && (
          <div className="space-y-3">
            <p className="text-sm text-text-secondary">난이도(최대 가능 개수 / 변형)를 골라주세요.</p>
            {programs.length === 0 && <p className="text-sm text-text-secondary">난이도 프로그램이 없어요.</p>}
            {programs.map((p) => (
              <button
                key={p.id}
                type="button"
                onClick={() => setProgramId(p.id)}
                className={`w-full p-3 rounded-lg border text-left ${programId === p.id ? 'border-accent bg-accent/10' : 'border-border bg-background'}`}
              >
                <span className="text-sm font-medium text-foreground">{p.label ?? p.difficulty_key}</span>
              </button>
            ))}
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
