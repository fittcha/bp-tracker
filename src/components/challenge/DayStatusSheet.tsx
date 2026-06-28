'use client'

import { useEffect, useState } from 'react'
import { X, Check, Timer, RotateCcw } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import type { DayStatus } from '@/lib/challenge/derive'

interface DayStatusSheetProps {
  isOpen: boolean
  weekNo: number
  dayInWeek: number
  setsText: string
  restSeconds: number | null
  state: { status: DayStatus; doneDate: string | null; successAttemptId: string | null } | null
  onClose: () => void
  onLog: (result: 'success' | 'fail', doneDate: string) => void
  onUpdateDate: (attemptId: string, doneDate: string) => void
}

const EYEBROW = 'text-[11px] font-semibold uppercase tracking-wider text-text-secondary/70'

export default function DayStatusSheet({
  isOpen, weekNo, dayInWeek, setsText, restSeconds, state, onClose, onLog, onUpdateDate,
}: DayStatusSheetProps) {
  const status: DayStatus = state?.status ?? 'untried'
  const [date, setDate] = useState(toDateString(new Date()))

  useEffect(() => {
    if (!isOpen) return
    // 성공이면 그 성공일을, 아니면 오늘을 기본값으로
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setDate(status === 'success' && state?.doneDate ? state.doneDate : toDateString(new Date()))
  }, [isOpen, status, state?.doneDate])

  if (!isOpen) return null

  const sets = setsText ? setsText.split('·') : []
  const hasAmrap = setsText.includes('+')

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-md bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto animate-slide-up">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-lg font-bold text-foreground">
            WEEK {weekNo} <span className="text-text-secondary/50">·</span> DAY {dayInWeek}
          </h3>
          <button onClick={onClose} className="-mr-1 p-1 text-text-secondary/60 hover:text-text-secondary transition-colors" aria-label="닫기"><X size={20} /></button>
        </div>

        <div className="space-y-5">
          {/* 세트 구성 */}
          {sets.length > 0 && (
            <div>
              <div className="flex items-baseline justify-between mb-2">
                <span className={EYEBROW}>세트 구성</span>
                {restSeconds != null && (
                  <span className="inline-flex items-center gap-1 text-xs text-text-secondary">
                    <Timer size={13} /> 휴식 {restSeconds}초
                  </span>
                )}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {sets.map((s, i) => {
                  const amrap = s.includes('+')
                  return (
                    <span
                      key={i}
                      className={`min-w-[2.75rem] text-center px-2 py-2 rounded-xl text-base font-bold tabular-nums border ${
                        amrap ? 'bg-accent-pop/10 text-accent-pop border-accent-pop/40' : 'bg-background text-foreground border-border'
                      }`}
                    >
                      {s}
                    </span>
                  )
                })}
              </div>
              {hasAmrap && (
                <p className="text-[11px] text-text-secondary/70 mt-2">
                  <span className="text-accent-pop font-bold">+</span> 가능한 만큼 (AMRAP)
                </p>
              )}
            </div>
          )}

          {/* 날짜 */}
          <div>
            <label className={`block ${EYEBROW} mb-2`}>날짜</label>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl border border-border bg-background text-foreground text-sm focus:outline-none focus:border-accent"
            />
          </div>

          {/* 액션 */}
          {status === 'success' ? (
            <div className="space-y-3">
              <p className="inline-flex items-center gap-1.5 text-sm font-medium text-success">
                <Check size={16} /> 성공 완료 · 날짜만 수정
              </p>
              <button
                onClick={() => state?.successAttemptId && onUpdateDate(state.successAttemptId, date)}
                disabled={!state?.successAttemptId}
                className="w-full py-3 rounded-xl bg-accent text-white font-semibold disabled:opacity-50"
              >
                날짜 저장
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {status === 'fail' && (
                <p className="inline-flex items-center gap-1.5 text-sm font-medium text-danger">
                  <RotateCcw size={14} /> 실패 — 재도전
                </p>
              )}
              <div className="grid grid-cols-2 gap-2.5">
                <button
                  onClick={() => onLog('success', date)}
                  className="inline-flex items-center justify-center gap-1.5 py-3 rounded-xl bg-success text-white font-semibold active:opacity-80 transition"
                >
                  <Check size={18} /> 성공
                </button>
                <button
                  onClick={() => onLog('fail', date)}
                  className="inline-flex items-center justify-center gap-1.5 py-3 rounded-xl bg-danger text-white font-semibold active:opacity-80 transition"
                >
                  <X size={18} /> 실패
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
