'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
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

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-2xl p-6 max-h-[85vh] overflow-y-auto animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">WEEK {weekNo} · DAY {dayInWeek}</h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>

        <div className="space-y-4">
          {/* 세트 구성 */}
          {sets.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-sm text-text-secondary">세트 구성</span>
                {restSeconds != null && <span className="text-xs text-text-secondary">세트간 휴식 {restSeconds}초</span>}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {sets.map((s, i) => (
                  <span key={i} className="px-2.5 py-1 rounded-md bg-background border border-border text-sm font-medium text-foreground">
                    {s}
                  </span>
                ))}
              </div>
              {setsText.includes('+') && (
                <p className="text-[11px] text-text-secondary mt-1">마지막 <b>+</b>는 가능한 만큼(AMRAP).</p>
              )}
            </div>
          )}

          <div>
            <label className="block text-sm text-text-secondary mb-1">날짜</label>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-border bg-background text-foreground focus:outline-none focus:border-accent"
            />
          </div>

          {status === 'success' ? (
            <>
              <p className="text-sm text-success font-medium">✓ 성공 완료 (날짜만 수정 가능)</p>
              <button
                onClick={() => state?.successAttemptId && onUpdateDate(state.successAttemptId, date)}
                disabled={!state?.successAttemptId}
                className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50"
              >
                날짜 저장
              </button>
            </>
          ) : (
            <>
              {status === 'fail' && <p className="text-sm text-danger font-medium">✗ 실패 — 재도전할 수 있어요</p>}
              <div className="flex gap-2">
                <button onClick={() => onLog('success', date)} className="flex-1 py-2.5 rounded-lg bg-success text-white font-medium">성공</button>
                <button onClick={() => onLog('fail', date)} className="flex-1 py-2.5 rounded-lg bg-danger text-white font-medium">실패</button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
