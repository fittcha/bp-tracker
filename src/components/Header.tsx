'use client'

import useSWR from 'swr'
import { getLoggedInUser } from '@/lib/auth'
import { getCurrentProgram } from '@/lib/api/workouts'
import { k } from '@/lib/swr/keys'
import { toDateString } from '@/lib/utils'

export default function Header() {
  const user = getLoggedInUser()
  const username = user?.username ?? toDateString(new Date())
  const today = toDateString(new Date())
  // undefined=로딩, null=프로그램 없음
  const { data: program } = useSWR(k.program(today), () => getCurrentProgram(today))

  // 주차별 미니 세그먼트 색: 완료=남색 / 현재=골드 / 미래=빈칸
  const segColor = (wk: number) => {
    if (!program) return 'bg-border'
    if (program.status === 'done' || (program.currentWeek != null && wk < program.currentWeek)) return 'bg-accent'
    if (program.status === 'active' && wk === program.currentWeek) return 'bg-accent-pop'
    return 'bg-border'
  }

  let progLabel = ''
  if (program) {
    const [, sm, sd] = program.startDate.split('-').map(Number)
    const right =
      program.status === 'upcoming' ? `${sm}월 ${sd}일 시작` : program.status === 'done' ? '완료' : `${program.currentWeek}주차`
    progLabel = `${program.name} · ${right}`
  }

  return (
    <header className="sticky top-0 z-50 bg-surface border-b border-border px-4 py-2.5">
      <div className="max-w-lg mx-auto">
        <div className="flex items-center justify-between">
          <h1 className="text-sm font-bold text-foreground">Road to Rx&apos;d</h1>
          <span className="text-xs text-text-secondary">{username}</span>
        </div>
        {/* 진행 중 프로그램 (작게) */}
        {program !== undefined && (
          <div className="mt-1 flex items-center gap-2">
            {program ? (
              <>
                <span className="text-[11px] font-medium text-accent truncate">{progLabel}</span>
                {program.totalWeeks != null && (
                  <div className="ml-auto flex gap-0.5 shrink-0">
                    {Array.from({ length: program.totalWeeks }, (_, i) => (
                      <span key={i} className={`w-2 h-1 rounded-sm ${segColor(i + 1)}`} />
                    ))}
                  </div>
                )}
              </>
            ) : (
              <span className="text-[11px] text-text-secondary/60">진행 중인 프로그램이 없습니다</span>
            )}
          </div>
        )}
      </div>
    </header>
  )
}
