'use client'

import { useState } from 'react'
import { RotateCcw, Flame, MoreVertical, Pencil, Trash2 } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreak, monthlyAttemptCount, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, resetChallenge, deleteChallenge,
  type ActiveChallenge, type ChallengeTemplate, type ChallengeProgramDay,
} from '@/lib/api/challenges'
import DayStatusSheet from './DayStatusSheet'
import EditChallengePopup from './EditChallengePopup'
import { formatDifficulty } from '@/lib/challenge/format'

interface ChallengeDashboardCardProps {
  active: ActiveChallenge
  template?: ChallengeTemplate
  onChanged: () => void
}

export default function ChallengeDashboardCard({ active, template, onChanged }: ChallengeDashboardCardProps) {
  const { challenge, days, attempts } = active
  const [openDay, setOpenDay] = useState<number | null>(null)
  const [menuOpen, setMenuOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)

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

  // 주 블록 그리드 열 수: 요일 적은 종목(푸쉬업 3일)=3열, 많으면(풀업 5일)=2열
  const daysPerWeek = weeks.reduce((m, w) => Math.max(m, w.days.length), 0)
  const gridCls = daysPerWeek <= 3 ? 'grid-cols-3 gap-x-2' : 'grid-cols-2 gap-x-3'

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
  async function handleDelete() {
    if (!confirm('이 챌린지를 삭제할까요? 모든 기록이 함께 삭제돼요. (되돌릴 수 없어요)')) return
    await deleteChallenge(challenge.id)
    onChanged()
  }

  return (
    <div className="bg-surface border border-border rounded-xl">
      {/* 헤더: 종목 + 난이도 / 스트릭(골드) · 이번 달 / 초기화 */}
      <div className="px-4 py-3.5 border-b border-border flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <p className="text-base font-bold text-foreground leading-tight">{name}</p>
          {diffLabel && <p className="text-xs text-text-secondary mt-0.5 truncate">{diffLabel}</p>}
        </div>
        <div className="flex flex-col items-end shrink-0">
          <div className="flex items-center gap-1">
            <Flame size={17} className={streak.alive ? 'text-[#F97316]' : 'text-text-secondary/40'} />
            <span className={`text-base font-bold tabular-nums ${streak.alive ? 'text-[#F97316]' : 'text-text-secondary'}`}>{streak.count}</span>
          </div>
          <span className="text-[11px] text-text-secondary mt-0.5 tabular-nums">이번 달 {monthCount}회</span>
        </div>
        <div className="relative shrink-0">
          <button onClick={() => setMenuOpen((o) => !o)} className="-mr-1 p-1 text-text-secondary/50 hover:text-text-secondary transition-colors" aria-label="메뉴">
            <MoreVertical size={16} />
          </button>
          {menuOpen && (
            <>
              <div className="fixed inset-0 z-40" onClick={() => setMenuOpen(false)} />
              <div className="absolute right-0 top-full mt-1 z-50 w-36 bg-surface border border-border rounded-xl shadow-lg py-1">
                <button onClick={() => { setMenuOpen(false); setEditOpen(true) }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground hover:bg-background">
                  <Pencil size={14} /> 수정
                </button>
                <button onClick={() => { setMenuOpen(false); handleReset() }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground hover:bg-background">
                  <RotateCcw size={14} /> 전체 초기화
                </button>
                <button onClick={() => { setMenuOpen(false); handleDelete() }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-danger hover:bg-background">
                  <Trash2 size={14} /> 삭제
                </button>
              </div>
            </>
          )}
        </div>
      </div>

      {/* 주차 2열 그리드, 각 주: 요일=열 / 세트=세로 */}
      <div className={`px-4 pt-3 pb-4 grid ${gridCls} gap-y-4`}>
        {weeks.length === 0 && <p className="col-span-full text-xs text-text-secondary py-2">프로그램 데이터가 없어요.</p>}
        {weeks.map(({ week, days: wd }) => (
          <div key={week}>
            <p className="text-[10px] font-semibold uppercase tracking-wider text-text-secondary/70 mb-1.5">Week {week}</p>
            <div className="flex gap-1">
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

      <EditChallengePopup
        isOpen={editOpen}
        challenge={challenge}
        onClose={() => setEditOpen(false)}
        onSaved={onChanged}
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
  const sets = setsText ? setsText.split('·') : []
  const md = state?.doneDate ? mdLabel(state.doneDate) : ''
  return (
    <button onClick={onTap} className={`flex-1 min-w-0 flex flex-col rounded-lg border overflow-hidden transition active:opacity-70 ${tint}`}>
      <div className="py-0.5 text-center text-[10px] font-semibold text-text-secondary">D{dayInWeek}</div>
      <div className="flex-1 flex flex-col items-center pb-1 tabular-nums">
        {sets.map((s, i) => (
          <span key={i} className="text-[11px] leading-tight text-foreground">{s}</span>
        ))}
      </div>
      {/* 상태 구역: 회색 도트 → 성공/실패 시 색칠 + 날짜 */}
      <div className="border-t border-border/60 py-1 flex flex-col items-center gap-0.5">
        <span className={`w-2 h-2 rounded-full ${
          status === 'success' ? 'bg-success'
          : status === 'fail' ? 'bg-danger'
          : 'border border-text-secondary/40'
        }`} />
        <span className={`text-[9px] leading-none tabular-nums ${status === 'success' ? 'text-success' : status === 'fail' ? 'text-danger' : 'text-transparent'}`}>{md || ' '}</span>
      </div>
    </button>
  )
}

// done_date(YYYY-MM-DD) → 'M/D'
function mdLabel(s: string): string {
  const p = s.split('-')
  return p.length === 3 ? `${Number(p[1])}/${Number(p[2])}` : s
}
