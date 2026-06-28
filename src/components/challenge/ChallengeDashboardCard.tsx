'use client'

import { useState } from 'react'
import { RotateCcw, Flame } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreak, monthlyAttemptCount, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, resetChallenge,
  type ActiveChallenge, type ChallengeTemplate,
} from '@/lib/api/challenges'
import DayStatusSheet from './DayStatusSheet'

// 난이도 jsonb → 사람이 읽는 요약 (Task 8 위젯에서도 재사용)
export function formatDifficulty(difficulty: Record<string, unknown>): string {
  const t = difficulty.type
  if (t === 'band') return `${String(difficulty.color)}밴드 ${String(difficulty.count)}개`
  if (t === 'bodyweight') return '맨몸'
  if (t === 'weighted') return `중량 ${String(difficulty.weight_kg)}kg`
  if (t === 'range') return String(difficulty.label ?? difficulty.difficulty_key ?? '')
  return ''
}

interface ChallengeDashboardCardProps {
  active: ActiveChallenge
  template?: ChallengeTemplate
  onChanged: () => void
}

export default function ChallengeDashboardCard({ active, template, onChanged }: ChallengeDashboardCardProps) {
  const { challenge, days, attempts } = active
  const [openDay, setOpenDay] = useState<number | null>(null)

  const dayStates = deriveDayStates(attempts)
  const attemptDates = attempts.map((a) => a.done_date)
  const today = toDateString(new Date())
  const streak = computeStreak(challenge.training_weekdays, attemptDates, today)
  const monthCount = monthlyAttemptCount(attemptDates, today.slice(0, 7))

  const name = template?.name ?? challenge.template_key
  const diffLabel = formatDifficulty(challenge.difficulty)

  const openState: DayState | null = openDay != null ? (dayStates.get(openDay) ?? null) : null
  const openTarget = openDay != null ? (days.find((d) => d.day_no === openDay)?.target_reps ?? 0) : 0

  async function handleLog(result: 'success' | 'fail', doneDate: string) {
    if (openDay == null) return
    await addAttempt({ userChallengeId: challenge.id, dayNo: openDay, result, doneDate })
    setOpenDay(null)
    onChanged()
  }
  async function handleUpdateDate(attemptId: string, doneDate: string) {
    await updateAttemptDate(attemptId, doneDate)
    setOpenDay(null)
    onChanged()
  }
  async function handleReset() {
    if (!confirm('이 챌린지의 모든 도전 기록을 초기화할까요? (되돌릴 수 없어요)')) return
    await resetChallenge(challenge.id)
    onChanged()
  }

  return (
    <div className="bg-surface border border-border rounded-xl overflow-hidden">
      {/* 헤더 */}
      <div className="px-4 py-3 bg-background border-b border-border flex items-center gap-2">
        <div className="min-w-0 flex-1">
          <p className="text-sm font-semibold text-foreground truncate">{name}</p>
          {diffLabel && <p className="text-xs text-text-secondary truncate">{diffLabel}</p>}
        </div>
        <div className="flex items-center gap-1 shrink-0">
          <Flame size={16} className={streak.alive ? 'text-accent-pop' : 'text-text-secondary'} />
          <span className={`text-sm font-bold ${streak.alive ? 'text-accent-pop' : 'text-text-secondary'}`}>{streak.count}</span>
        </div>
        <span className="text-xs text-text-secondary shrink-0">이번 달 {monthCount}회</span>
        <button onClick={handleReset} className="p-1 text-text-secondary shrink-0" aria-label="전체 초기화">
          <RotateCcw size={16} />
        </button>
      </div>

      {/* day 그리드 (7개씩) */}
      <div className="grid grid-cols-7 gap-1.5 p-3">
        {days.map((d) => (
          <DayCell key={d.day_no} dayNo={d.day_no} target={d.target_reps}
            state={dayStates.get(d.day_no) ?? null} onTap={() => setOpenDay(d.day_no)} />
        ))}
        {days.length === 0 && <p className="col-span-7 text-xs text-text-secondary text-center py-2">프로그램 데이터가 없어요.</p>}
      </div>

      <DayStatusSheet
        isOpen={openDay != null}
        dayNo={openDay ?? 0}
        targetReps={openTarget}
        state={openState ? { status: openState.status, doneDate: openState.doneDate, successAttemptId: openState.successAttemptId } : null}
        onClose={() => setOpenDay(null)}
        onLog={handleLog}
        onUpdateDate={handleUpdateDate}
      />
    </div>
  )
}

// ── day 셀 (내부 서브컴포넌트) ──
function DayCell({ dayNo, target, state, onTap }: {
  dayNo: number
  target: number
  state: DayState | null
  onTap: () => void
}) {
  const status = state?.status ?? 'untried'
  const ring =
    status === 'success' ? 'border-success bg-success/10 text-success'
    : status === 'fail' ? 'border-danger bg-danger/10 text-danger'
    : 'border-border bg-background text-text-secondary'
  const icon = status === 'success' ? '✓' : status === 'fail' ? '✗' : '·'
  return (
    <button onClick={onTap} className={`aspect-square rounded-lg border flex flex-col items-center justify-center ${ring}`}>
      <span className="text-[10px] leading-none opacity-70">D{dayNo}</span>
      <span className="text-sm font-bold leading-tight">{icon}</span>
      <span className="text-[10px] leading-none opacity-70">{target}</span>
    </button>
  )
}
