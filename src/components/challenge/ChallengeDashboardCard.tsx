'use client'

import { useState } from 'react'
import { RotateCcw, Flame } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreak, monthlyAttemptCount, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, resetChallenge,
  type ActiveChallenge, type ChallengeTemplate, type ChallengeProgramDay,
} from '@/lib/api/challenges'
import DayStatusSheet from './DayStatusSheet'

// 난이도 jsonb → 사람이 읽는 요약 (홈 위젯에서도 재사용).
// 항상 {label} 보유. 풀업 밴디드=bands[], 웨이티드=weight_kg 부가 표시.
export function formatDifficulty(difficulty: Record<string, unknown>): string {
  const label = String(difficulty.label ?? difficulty.difficulty_key ?? '')
  const dk = difficulty.difficulty_key
  if (dk === 'banded' && Array.isArray(difficulty.bands) && difficulty.bands.length > 0) {
    const bands = difficulty.bands as Array<{ color?: unknown; count?: unknown }>
    const parts = bands.map((b) => `${String(b.color)} ${String(b.count)}`).join(' · ')
    return `${label} ${parts}`
  }
  if (dk === 'weighted' && difficulty.weight_kg != null && difficulty.weight_kg !== 0) {
    return `${label} +${String(difficulty.weight_kg)}kg`
  }
  return label
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

  const name = template?.exercise ?? template?.name ?? challenge.template_key
  const diffLabel = formatDifficulty(challenge.difficulty)

  // 주차별 그룹 (등장 순서 보존, 주차 내 day_in_week 순)
  const weeks: { week: number; days: ChallengeProgramDay[] }[] = []
  const byWeek = new Map<number, ChallengeProgramDay[]>()
  for (const d of [...days].sort((a, b) => a.day_no - b.day_no)) {
    if (!byWeek.has(d.week_no)) {
      const arr: ChallengeProgramDay[] = []
      byWeek.set(d.week_no, arr)
      weeks.push({ week: d.week_no, days: arr })
    }
    byWeek.get(d.week_no)!.push(d)
  }

  const openDayObj = openDay != null ? (days.find((d) => d.day_no === openDay) ?? null) : null
  const openState: DayState | null = openDay != null ? (dayStates.get(openDay) ?? null) : null

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
      {/* 헤더: 종목 + 난이도 / 스트릭(골드) · 이번 달 / 초기화 */}
      <div className="px-4 py-3.5 border-b border-border flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <p className="text-base font-bold text-foreground leading-tight">{name}</p>
          {diffLabel && <p className="text-xs text-text-secondary mt-0.5 truncate">{diffLabel}</p>}
        </div>
        <div className="flex flex-col items-end shrink-0">
          <div className="flex items-center gap-1">
            <Flame size={17} className={streak.alive ? 'text-accent-pop' : 'text-text-secondary/40'} />
            <span className={`text-base font-bold tabular-nums ${streak.alive ? 'text-accent-pop' : 'text-text-secondary'}`}>{streak.count}</span>
          </div>
          <span className="text-[11px] text-text-secondary mt-0.5 tabular-nums">이번 달 {monthCount}회</span>
        </div>
        <button onClick={handleReset} className="shrink-0 -mr-1 p-1 text-text-secondary/50 hover:text-text-secondary transition-colors" aria-label="전체 초기화">
          <RotateCcw size={15} />
        </button>
      </div>

      {/* 주차별 트레이닝 표: 요일=열(내용폭), 세트=세로 */}
      <div className="px-4 pt-3 pb-4 space-y-3.5">
        {weeks.length === 0 && <p className="text-xs text-text-secondary py-2">프로그램 데이터가 없어요.</p>}
        {weeks.map(({ week, days: wd }) => (
          <div key={week}>
            <p className="text-[10px] font-semibold uppercase tracking-wider text-text-secondary/70 mb-1.5">Week {week}</p>
            <div className="flex gap-1.5">
              {wd.map((d) => (
                <DayColumn
                  key={d.day_no}
                  dayInWeek={d.day_in_week}
                  setsText={d.sets_text}
                  state={dayStates.get(d.day_no) ?? null}
                  onTap={() => setOpenDay(d.day_no)}
                />
              ))}
            </div>
          </div>
        ))}
      </div>

      <DayStatusSheet
        isOpen={openDay != null}
        weekNo={openDayObj?.week_no ?? 0}
        dayInWeek={openDayObj?.day_in_week ?? 0}
        setsText={openDayObj?.sets_text ?? ''}
        restSeconds={openDayObj?.rest_seconds ?? null}
        state={openState ? { status: openState.status, doneDate: openState.doneDate, successAttemptId: openState.successAttemptId } : null}
        onClose={() => setOpenDay(null)}
        onLog={handleLog}
        onUpdateDate={handleUpdateDate}
      />
    </div>
  )
}

// ── day 칼럼: 헤더(D + 상태 점) + 세트 세로. 내용폭 고정(w-12), stretch 안 함. ──
function DayColumn({ dayInWeek, setsText, state, onTap }: {
  dayInWeek: number
  setsText: string
  state: DayState | null
  onTap: () => void
}) {
  const status = state?.status ?? 'untried'
  const tint =
    status === 'success' ? 'border-success/40 bg-success/5'
    : status === 'fail' ? 'border-danger/40 bg-danger/5'
    : 'border-border bg-background'
  const dot =
    status === 'success' ? 'bg-success'
    : status === 'fail' ? 'bg-danger'
    : 'bg-text-secondary/30'
  const sets = setsText ? setsText.split('·') : []
  return (
    <button onClick={onTap} className={`w-12 shrink-0 rounded-lg border overflow-hidden transition active:opacity-70 ${tint}`}>
      <div className="flex items-center justify-center gap-1 py-1">
        <span className="text-[10px] font-semibold text-text-secondary">D{dayInWeek}</span>
        <span className={`w-1.5 h-1.5 rounded-full ${dot}`} />
      </div>
      <div className="flex flex-col items-center pb-1.5 tabular-nums">
        {sets.map((s, i) => (
          <span key={i} className="text-xs leading-5 text-foreground">{s}</span>
        ))}
      </div>
    </button>
  )
}
