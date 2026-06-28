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

// 난이도 jsonb → 사람이 읽는 요약 (홈 위젯에서도 재사용). 난이도는 항상 {label} 보유.
export function formatDifficulty(difficulty: Record<string, unknown>): string {
  return String(difficulty.label ?? difficulty.difficulty_key ?? '')
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

      {/* 주차별 day 그룹 */}
      <div className="p-3 space-y-3">
        {weeks.length === 0 && <p className="text-xs text-text-secondary text-center py-2">프로그램 데이터가 없어요.</p>}
        {weeks.map(({ week, days: wd }) => (
          <div key={week}>
            <p className="text-[11px] font-semibold text-text-secondary mb-1">WEEK {week}</p>
            <div className="space-y-1">
              {wd.map((d) => (
                <DayRow
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

// ── day 행 (내부 서브컴포넌트): D라벨 + 세트 구성(횟수) + 상태 ──
function DayRow({ dayInWeek, setsText, state, onTap }: {
  dayInWeek: number
  setsText: string
  state: DayState | null
  onTap: () => void
}) {
  const status = state?.status ?? 'untried'
  const box =
    status === 'success' ? 'border-success bg-success/10'
    : status === 'fail' ? 'border-danger bg-danger/10'
    : 'border-border bg-background'
  const iconCls = status === 'success' ? 'text-success' : status === 'fail' ? 'text-danger' : 'text-text-secondary'
  const icon = status === 'success' ? '✓' : status === 'fail' ? '✗' : '·'
  return (
    <button onClick={onTap} className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg border ${box}`}>
      <span className="text-xs font-semibold text-text-secondary w-7 shrink-0 text-left">D{dayInWeek}</span>
      <span className="flex-1 text-left text-sm font-medium text-foreground">{setsText}</span>
      <span className={`text-base font-bold shrink-0 ${iconCls}`}>{icon}</span>
    </button>
  )
}
