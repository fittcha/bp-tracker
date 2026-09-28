'use client'

import { useState } from 'react'
import { MoreVertical, Trash2 } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveStack } from '@/lib/challenge/stack'
import { addStackEntry, archiveStackChallenge, type StackChallengeWithEntries } from '@/lib/api/stack'

interface Props {
  item: StackChallengeWithEntries
  onChanged: () => void
}

const STEPS = [10, 5, 1] as const

// 쌓기 챌린지 카드. 누적 숫자가 주인공이고 나머지는 전부 그 아래에 작게 붙는다.
// 설계: docs/superpowers/specs/2026-09-28-stack-challenge-design.md
export default function StackChallengeCard({ item, onChanged }: Props) {
  const { challenge, entries } = item
  const [menuOpen, setMenuOpen] = useState(false)
  const [busy, setBusy] = useState(false)
  // 낙관적 보정: 서버 반영 전까지 화면 숫자를 먼저 움직인다.
  const [pending, setPending] = useState(0)

  const today = toDateString(new Date())
  const base = deriveStack(entries, challenge.started_at.slice(0, 10), today)
  const total = Math.max(0, base.total + pending)
  const todayTotal = base.todayTotal + pending

  const goal = challenge.goal_count
  const pct = goal && goal > 0 ? Math.min(100, Math.round((total / goal) * 100)) : null

  async function bump(delta: number) {
    if (busy) return
    const applied = delta < 0 ? -Math.min(total, -delta) : delta
    if (applied === 0) return
    setBusy(true)
    setPending((p) => p + applied)
    try {
      await addStackEntry(challenge.id, applied, total, today)
      setPending(0)
      onChanged()
    } catch (e) {
      setPending((p) => p - applied) // 되돌리기
      // 쓰기 실패를 콘솔에 삼키지 않는다(마이그레이션 미적용 등 원인 노출)
      alert(`기록에 실패했어요.\n\n(${e instanceof Error ? e.message : String(e)})`)
    } finally {
      setBusy(false)
    }
  }

  async function handleArchive() {
    setMenuOpen(false)
    if (!window.confirm(`"${challenge.title}" 쌓기를 그만둘까요?\n지금까지 쌓은 기록은 남습니다.`)) return
    try {
      await archiveStackChallenge(challenge.id)
      onChanged()
    } catch (e) {
      alert(`그만두기에 실패했어요.\n\n(${e instanceof Error ? e.message : String(e)})`)
    }
  }

  const btnCls =
    'flex-1 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-30 disabled:cursor-not-allowed'

  return (
    <div className="relative bg-surface border border-border rounded-xl p-4" onClick={() => setMenuOpen(false)}>
      {/* 헤더 */}
      <div className="flex items-start justify-between">
        <div className="min-w-0">
          <p className="text-sm font-bold text-foreground truncate">
            <span className="text-text-secondary font-medium">쌓기 · </span>
            {challenge.title}
          </p>
          <p className="text-xs text-text-secondary mt-0.5">{base.dayNo}일차</p>
        </div>
        <button
          onClick={(e) => { e.stopPropagation(); setMenuOpen((v) => !v) }}
          className="p-1 -mr-1 text-text-secondary/60 hover:text-foreground"
          aria-label="메뉴"
        >
          <MoreVertical size={18} />
        </button>
        {menuOpen && (
          <div
            className="absolute right-3 top-11 z-10 bg-surface border border-border rounded-lg shadow-lg overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={handleArchive}
              className="flex items-center gap-2 w-full px-4 py-2 text-xs text-danger hover:bg-accent-light"
            >
              <Trash2 size={13} /> 그만두기
            </button>
          </div>
        )}
      </div>

      {/* 누적 — 카드의 주인공 */}
      <div className="text-center py-5">
        <p className="text-5xl font-bold leading-none tabular-nums text-foreground">
          {total.toLocaleString()}
        </p>
        {goal != null && goal > 0 && (
          <div className="mt-3 mx-auto max-w-[200px]">
            <div className="flex items-center justify-between text-[11px] text-text-secondary tabular-nums">
              <span>/ {goal.toLocaleString()}</span>
              <span>{pct}%</span>
            </div>
            <div className="mt-1 h-1 rounded-full bg-border overflow-hidden">
              <div className="h-full bg-accent-pop" style={{ width: `${pct}%` }} />
            </div>
          </div>
        )}
      </div>

      {/* ± 버튼 */}
      <div className="flex items-center gap-1.5">
        {STEPS.map((n) => (
          <button
            key={`m${n}`}
            onClick={(e) => { e.stopPropagation(); void bump(-n) }}
            disabled={busy || total === 0}
            className={`${btnCls} border border-border text-text-secondary hover:bg-accent-light`}
          >
            −{n}
          </button>
        ))}
        <div className="w-px self-stretch bg-border mx-0.5" />
        {[...STEPS].reverse().map((n) => (
          <button
            key={`p${n}`}
            onClick={(e) => { e.stopPropagation(); void bump(n) }}
            disabled={busy}
            className={`${btnCls} bg-accent text-white hover:opacity-90`}
          >
            +{n}
          </button>
        ))}
      </div>

      <p className="text-[11px] text-text-secondary text-center mt-2.5 tabular-nums">
        오늘 {Math.max(0, todayTotal).toLocaleString()}개
      </p>
    </div>
  )
}
