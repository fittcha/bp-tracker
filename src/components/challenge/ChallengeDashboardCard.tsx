'use client'

import { useState } from 'react'
import { RotateCcw, Flame, MoreVertical, Pencil, Trash2, CheckCircle2 } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreakWithCarry, monthlyAttemptCount, toggleSet, isDayComplete, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, deleteAttempt, resetChallenge, deleteChallenge,
  setDayProgress, clearDayProgress, completeChallenge,
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
  const { challenge, days, attempts, progress } = active
  const [openDay, setOpenDay] = useState<number | null>(null)
  const [menuOpen, setMenuOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)

  const dayStates = deriveDayStates(attempts)
  const attemptDates = attempts.map((a) => a.done_date)
  const today = toDateString(new Date())
  const startDate = challenge.started_at.slice(0, 10)
  const streak = computeStreakWithCarry(challenge.training_weekdays, attemptDates, today, startDate, challenge.carried_streak ?? 0)
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

  const openDoneSets = openDay != null ? (progress[openDay] ?? []) : []
  const openTotalSets = openDayObj?.sets_text ? openDayObj.sets_text.split('·').length : 0

  // 쓰기 실패를 콘솔에 삼키지 말고 사용자에게 노출.
  // (예: 마이그레이션 미적용으로 컬럼/테이블이 없을 때 조용히 무반응하던 문제 방지)
  // 성공 시에만 후속 상태 전환(onChanged/setOpenDay)이 일어나도록 fn 안에 함께 둔다.
  async function runWrite(fn: () => Promise<void>) {
    try {
      await fn()
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      alert(`저장에 실패했어요. 잠시 후 다시 시도해 주세요.\n\n(${msg})`)
    }
  }

  async function handleToggleSet(index: number) {
    if (openDay == null) return
    const day = openDay
    const next = toggleSet(progress[day] ?? [], index)
    await runWrite(async () => {
      await setDayProgress(challenge.id, day, next)
      if (isDayComplete(next, openTotalSets)) {
        await addAttempt({ userChallengeId: challenge.id, dayNo: day, result: 'success', doneDate: toDateString(new Date()) })
      }
      onChanged()
    })
  }
  async function handleUnlock() {
    if (openDay == null || openState?.successAttemptId == null) return
    const attemptId = openState.successAttemptId
    await runWrite(async () => {
      await deleteAttempt(attemptId) // done_sets 보존 → 편집 가능
      setOpenDay(null)
      onChanged()
    })
  }

  async function handleLog(result: 'success' | 'fail', doneDate: string) {
    if (openDay == null) return
    const day = openDay
    await runWrite(async () => {
      await addAttempt({ userChallengeId: challenge.id, dayNo: day, result, doneDate })
      setOpenDay(null)
      onChanged()
    })
  }
  async function handleUpdateDate(attemptId: string, doneDate: string) {
    await runWrite(async () => {
      await updateAttemptDate(attemptId, doneDate)
      setOpenDay(null)
      onChanged()
    })
  }
  async function handleDeleteAttempt(attemptId: string) {
    if (!confirm('이 성공 기록을 삭제할까요? 세트 진행도 함께 초기화돼요. (되돌릴 수 없어요)')) return
    const day = openDay
    await runWrite(async () => {
      if (day != null) await clearDayProgress(challenge.id, day)
      await deleteAttempt(attemptId)
      setOpenDay(null)
      onChanged()
    })
  }
  async function handleReset() {
    if (!confirm('이 챌린지의 모든 도전 기록을 초기화할까요? (되돌릴 수 없어요)')) return
    await runWrite(async () => {
      await resetChallenge(challenge.id)
      onChanged()
    })
  }
  async function handleDelete() {
    if (!confirm('이 챌린지를 삭제할까요? 모든 기록이 함께 삭제돼요. (되돌릴 수 없어요)')) return
    await runWrite(async () => {
      await deleteChallenge(challenge.id)
      onChanged()
    })
  }
  async function handleComplete() {
    if (!confirm('이 챌린지를 완료할까요?\n기록은 보존되고, 7일 안에 같은 종목 다음 난이도를 시작하면 연속기록이 이어져요.')) return
    await runWrite(async () => {
      await completeChallenge(challenge.id, streak.count)
      onChanged()
    })
  }

  return (
    <div className="bg-surface border border-border rounded-xl">
      {/* 헤더: 종목 + 난이도 / 스트릭(골드) · 이번 달 / 초기화 */}
      <div className="px-4 py-3.5 border-b border-border flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <p className="text-base font-bold text-foreground leading-tight">{name}</p>
          {diffLabel && <p className="text-[11px] text-text-secondary mt-0.5 truncate">{diffLabel}</p>}
          {(challenge.carried_streak ?? 0) > 0 && (
            <p className="text-[10px] font-semibold text-accent-pop mt-0.5">🔥 이전 기록 {challenge.carried_streak}일 이어받음</p>
          )}
        </div>
        <div className="flex flex-col items-end shrink-0">
          <div className="flex items-center gap-1">
            <Flame size={17} className={streak.alive ? 'text-[#F97316]' : 'text-text-secondary/40'} />
            <span className={`text-base font-bold leading-tight tabular-nums ${streak.alive ? 'text-[#F97316]' : 'text-text-secondary'}`}>{streak.count}</span>
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
                <button onClick={() => { setMenuOpen(false); handleComplete() }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-accent-pop hover:bg-background">
                  <CheckCircle2 size={14} /> 완료(다음 난이도로)
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
        {weeks.map(({ week, days: wd }) => {
          // 한 주 내 day들의 세트 줄 수가 달라 칼럼 높이가 어긋나면 하단 도트가 안 맞음 →
          // 주 내 최대 세트수로 통일해 칼럼 높이 균등 + 도트 정렬
          const maxSets = wd.reduce((m, d) => Math.max(m, d.sets_text ? d.sets_text.split('·').length : 0), 0)
          return (
            <div key={week}>
              <p className="text-[10px] font-semibold uppercase tracking-wider text-text-secondary/70 mb-1.5">Week {week}</p>
              <div className="flex gap-1">
                {wd.map((d) => (
                  <DayColumn
                    key={d.day_no}
                    dayInWeek={d.day_in_week}
                    setsText={d.sets_text}
                    maxSets={maxSets}
                    state={dayStates.get(d.day_no) ?? null}
                    onTap={() => setOpenDay(d.day_no)}
                  />
                ))}
              </div>
            </div>
          )
        })}
      </div>

      <DayStatusSheet
        isOpen={openDay != null}
        weekNo={openDayObj?.week_no ?? 0}
        dayInWeek={openDayObj?.day_in_week ?? 0}
        setsText={openDayObj?.sets_text ?? ''}
        restSeconds={openDayObj?.rest_seconds ?? null}
        doneSets={openDoneSets}
        onToggleSet={handleToggleSet}
        onUnlock={handleUnlock}
        state={openState ? { status: openState.status, doneDate: openState.doneDate, successAttemptId: openState.successAttemptId } : null}
        onClose={() => setOpenDay(null)}
        onLog={handleLog}
        onUpdateDate={handleUpdateDate}
        onDeleteAttempt={handleDeleteAttempt}
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
function DayColumn({ dayInWeek, setsText, maxSets, state, onTap }: {
  dayInWeek: number
  setsText: string
  maxSets: number
  state: DayState | null
  onTap: () => void
}) {
  const status = state?.status ?? 'untried'
  const tint =
    status === 'success' ? 'border-success/40 bg-success/5'
    : status === 'fail' ? 'border-danger/40 bg-danger/5'
    : 'border-border bg-background'
  const sets = setsText ? setsText.split('·') : []
  const pad = Math.max(0, maxSets - sets.length) // 주 내 최대 세트수에 맞춰 빈 줄 채워 높이 통일
  const md = state?.doneDate ? mdLabel(state.doneDate) : ''
  return (
    <button onClick={onTap} className={`flex-1 min-w-0 flex flex-col rounded-lg border overflow-hidden transition active:opacity-70 ${tint}`}>
      <div className="py-0.5 text-center text-[10px] font-semibold text-text-secondary">D{dayInWeek}</div>
      <div className="flex-1 flex flex-col items-center justify-center pb-1 tabular-nums">
        {sets.map((s, i) => (
          <span key={i} className="w-full text-center text-[11px] leading-tight text-foreground">{s}</span>
        ))}
        {Array.from({ length: pad }, (_, i) => (
          <span key={`pad-${i}`} aria-hidden className="w-full text-center text-[11px] leading-tight text-transparent select-none">0</span>
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
