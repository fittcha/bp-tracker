'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
import { updateStackChallenge, type StackChallenge } from '@/lib/api/stack'

interface Props {
  isOpen: boolean
  challenge: StackChallenge | null
  onClose: () => void
  onSaved: () => void
}

// 쌓기 챌린지의 종목명·목표 수정. 누적 개수는 ± 버튼으로만 움직이므로 여기서 못 고치고,
// 시작일도 일차의 기준이라 고정이다(기존 EditChallengePopup도 시작일은 안 건드린다).
export default function EditStackChallengePopup({ isOpen, challenge, onClose, onSaved }: Props) {
  const [title, setTitle] = useState('')
  const [hasGoal, setHasGoal] = useState(false)
  const [goal, setGoal] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!isOpen || !challenge) return
    setTitle(challenge.title)
    setHasGoal(challenge.goal_count != null)
    setGoal(challenge.goal_count != null ? String(challenge.goal_count) : '')
    setSaving(false)
  }, [isOpen, challenge])

  if (!isOpen || !challenge) return null

  const goalNum = parseInt(goal, 10)
  const ready = title.trim().length > 0 && (!hasGoal || (Number.isFinite(goalNum) && goalNum > 0))

  async function handleSave() {
    if (!challenge || !ready || saving) return
    setSaving(true)
    try {
      await updateStackChallenge(challenge.id, {
        title: title.trim(),
        goalCount: hasGoal ? goalNum : null,
      })
      onSaved()
      onClose()
    } catch (e) {
      alert(`수정에 실패했어요.\n\n(${e instanceof Error ? e.message : String(e)})`)
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-md bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">쌓기 수정</h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm text-text-secondary mb-1.5">종목</label>
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="예: 푸쉬업"
              className="w-full border border-border rounded-lg px-3 py-2.5 text-sm bg-background text-foreground placeholder:text-text-secondary/40 outline-none focus:border-accent"
            />
          </div>

          <div>
            <label className="block text-sm text-text-secondary mb-1.5">목표 설정</label>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setHasGoal(false)}
                className={`flex-1 py-2 rounded-lg border text-sm font-medium transition ${!hasGoal ? 'border-accent bg-accent text-white' : 'border-border bg-background text-foreground'}`}
              >
                없음
              </button>
              <button
                type="button"
                onClick={() => setHasGoal(true)}
                className={`flex-1 py-2 rounded-lg border text-sm font-medium transition ${hasGoal ? 'border-accent bg-accent text-white' : 'border-border bg-background text-foreground'}`}
              >
                있음
              </button>
            </div>
            {hasGoal && (
              <input
                type="number"
                inputMode="numeric"
                min={1}
                value={goal}
                onChange={(e) => setGoal(e.target.value)}
                placeholder="목표 개수 (예: 10000)"
                className="mt-2 w-full border border-border rounded-lg px-3 py-2.5 text-sm bg-background text-foreground placeholder:text-text-secondary/40 outline-none focus:border-accent"
              />
            )}
          </div>

          <p className="text-xs text-text-secondary">
            쌓은 개수와 시작일({challenge.started_at.slice(0, 10)})은 바뀌지 않아요.
          </p>

          <div className="flex gap-2">
            <button onClick={onClose} className="px-4 py-2.5 rounded-lg border border-border text-sm text-text-secondary">
              취소
            </button>
            <button
              onClick={handleSave}
              disabled={!ready || saving}
              className="flex-1 py-2.5 rounded-lg bg-accent text-white text-sm font-semibold disabled:opacity-40"
            >
              {saving ? '저장 중…' : '저장'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
