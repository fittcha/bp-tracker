'use client'

import { useEffect, useState, useCallback, useRef } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { getLoggedInUser } from '@/lib/auth'
import { getDefaultWorkoutsForWeekday } from '@/lib/api/workouts'
import { getWorkoutLogsWithWorkout, addWorkoutToDate, type WorkoutLogJoined } from '@/lib/api/workout-logs'
import { getCardioLogs, setCardioCompleted, type CardioLog } from '@/lib/api/cardio-logs'
import WorkoutCard from '@/components/workout/WorkoutCard'
import Calculator from '@/components/workout/Calculator'
import ExerciseGifModal from '@/components/workout/ExerciseGifModal'
import ExerciseSearchModal from '@/components/workout/ExerciseSearchModal'
import AddWorkoutPopup from '@/components/workout/AddWorkoutPopup'

const DAY_LABELS = ['월', '화', '수', '목', '금', '토', '일']

interface WorkoutGroup {
  workoutId: string
  title: string
  isShared: boolean
  isLegacy?: boolean
  logs: WorkoutLogJoined[]
}

export default function WorkoutPage() {
  const user = getLoggedInUser()
  const userId = user?.id ?? ''
  const [date, setDate] = useState<Date>(() => new Date())
  const [groups, setGroups] = useState<WorkoutGroup[]>([])
  const [cardio, setCardio] = useState<CardioLog[]>([])
  const [loading, setLoading] = useState(true)
  const [gifModalExercise, setGifModalExercise] = useState<string | null>(null)
  const [searchOpen, setSearchOpen] = useState(false)
  const [addOpen, setAddOpen] = useState(false)
  const dateInputRef = useRef<HTMLInputElement>(null)

  const [calcOpen, _setCalcOpen] = useState(false)
  const setCalcOpen = useCallback((open: boolean) => {
    _setCalcOpen(open)
    window.dispatchEvent(new CustomEvent('calc-open', { detail: open }))
  }, [])

  useEffect(() => {
    const handler = () => setCalcOpen(false)
    window.addEventListener('calc-close', handler)
    return () => window.removeEventListener('calc-close', handler)
  }, [setCalcOpen])

  // 홈 캘린더 등에서 ?date=YYYY-MM-DD로 들어오면 해당 날짜로 시작 (없거나 형식 불량이면 오늘)
  useEffect(() => {
    const param = new URLSearchParams(window.location.search).get('date')
    if (param && /^\d{4}-\d{2}-\d{2}$/.test(param)) {
      const [y, m, d] = param.split('-').map(Number)
      const parsed = new Date(y, m - 1, d)
      // 마운트 시 URL 파라미터로 초기 날짜 1회 설정(의도된 동작).
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (!isNaN(parsed.getTime())) setDate(parsed)
    }
  }, [])

  // ── 7일 날짜 스트립: date가 속한 주의 월요일부터 7칸 ──
  function getMondayOfWeek(d: Date) {
    const result = new Date(d)
    const dow = result.getDay()
    const offset = dow === 0 ? -6 : 1 - dow
    result.setDate(result.getDate() + offset)
    result.setHours(0, 0, 0, 0)
    return result
  }

  function shiftWeek(delta: number) {
    setDate((prev) => {
      const d = new Date(prev)
      d.setDate(d.getDate() + delta * 7)
      return d
    })
  }

  const monday = getMondayOfWeek(date)
  const weekDates = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(monday)
    d.setDate(monday.getDate() + i)
    return {
      dayNum: i + 1,
      date: d,
      ds: toDateString(d),
      dayOfMonth: d.getDate(),
      label: DAY_LABELS[i],
      isWorkoutDay: i < 5,
    }
  })

  const loadData = useCallback(async (d: Date) => {
    setLoading(true)
    const loggedIn = getLoggedInUser()
    if (!loggedIn) {
      setLoading(false)
      return
    }
    const ds = toDateString(d)
    const jsDay = d.getDay() // 0=일..6=토
    const weekday = jsDay === 0 ? 7 : jsDay // 1=월..7=일

    // 1) 그 요일 공용 기본운동 (월~금만 매핑됨)
    const defaults = weekday <= 5 ? await getDefaultWorkoutsForWeekday(weekday) : []

    // 2) 그 날짜 로그 (workout 조인)
    let logs = await getWorkoutLogsWithWorkout(ds, loggedIn.id)

    // 3) 공용 기본운동 중 로그 없는 것 자동 생성 (과거 날짜는 자동생성 안 함 — 과거 기록 오염 방지)
    const presentWorkoutIds = new Set(logs.map((l) => l.workout?.workout_id).filter(Boolean))
    const isPast = ds < toDateString(new Date())
    const missing = isPast ? [] : defaults.filter((wk) => !presentWorkoutIds.has(wk.id))
    for (const wk of missing) {
      await addWorkoutToDate(loggedIn.id, ds, wk.id)
    }
    if (missing.length > 0) {
      logs = await getWorkoutLogsWithWorkout(ds, loggedIn.id) // 재조회
    }

    // 4) workout_id로 그룹핑. 공용/개인은 owner_user_id(null=공용).
    const byWorkout = new Map<string, { title: string; isShared: boolean; logs: WorkoutLogJoined[] }>()
    const legacy: WorkoutLogJoined[] = [] // 시즌1 로그(workout 연결 없음) — 과거 날짜 읽기용
    for (const l of logs) {
      const wid = l.workout?.workout_id
      if (!wid) {
        legacy.push(l)
        continue
      }
      if (!byWorkout.has(wid)) {
        byWorkout.set(wid, {
          title: l.workout!.title,
          isShared: l.workout!.owner_user_id === null,
          logs: [],
        })
      }
      byWorkout.get(wid)!.logs.push(l)
    }
    const grouped: WorkoutGroup[] = [...byWorkout.entries()].map(([workoutId, g]) => ({ workoutId, ...g }))
    // 공용 먼저, 개인 나중
    grouped.sort((a, b) => Number(b.isShared) - Number(a.isShared))
    // 시즌1 레거시 로그: 섹션(A,B,C…)별로 분리해 A→F 순으로 각각 카드 노출
    if (legacy.length) {
      const bySection = new Map<string, WorkoutLogJoined[]>()
      for (const l of legacy) {
        const sec = l.section || '?'
        if (!bySection.has(sec)) bySection.set(sec, [])
        bySection.get(sec)!.push(l)
      }
      // WOD 최상위, 나머지 A→F 순
      const sortedSecs = [...bySection.keys()].sort((a, b) => {
        if (a === 'WOD') return -1
        if (b === 'WOD') return 1
        return a.localeCompare(b)
      })
      for (const sec of sortedSecs) {
        grouped.push({ workoutId: `__legacy_${sec}__`, title: '', isShared: false, isLegacy: true, logs: bySection.get(sec)! })
      }
    }

    // 시즌1 저강도 유산소(레거시 날짜) 조회
    setCardio(await getCardioLogs(ds, loggedIn.id))

    setGroups(grouped)
    setLoading(false)
  }, [])

  useEffect(() => {
    // loadData는 async라 setLoading은 동기 실행되지 않음(규칙 오탐). 날짜 변경 시 재조회.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadData(date)
  }, [date, loadData])

  async function toggleCardio(id: string, completed: boolean) {
    setCardio((prev) => prev.map((c) => (c.id === id ? { ...c, completed } : c)))
    try {
      await setCardioCompleted(id, completed)
    } catch {
      setCardio((prev) => prev.map((c) => (c.id === id ? { ...c, completed: !completed } : c)))
    }
  }

  const todayDs = toDateString(new Date())
  const selectedDs = toDateString(date)

  return (
    <div className="space-y-4">
      {/* 날짜: 월 라벨(탭→픽커) + 7일 스트립 (ddodun 스타일, 파란 accent) */}
      <div>
        <div className="flex items-center justify-center mb-3 relative">
          <button onClick={() => dateInputRef.current?.showPicker()} className="text-sm font-bold">
            {date.getFullYear() !== new Date().getFullYear() ? `${date.getFullYear()}년 ` : ''}{date.getMonth() + 1}월
          </button>
          <input
            ref={dateInputRef}
            type="date"
            value={selectedDs}
            onChange={(e) => {
              if (e.target.value) {
                const [y, m, dd] = e.target.value.split('-').map(Number)
                setDate(new Date(y, m - 1, dd))
              }
            }}
            className="absolute inset-0 opacity-0 w-0 h-0"
            tabIndex={-1}
          />
        </div>

        <div className="flex items-center gap-1 px-[5%]">
          <button onClick={() => shiftWeek(-1)} className="p-1 text-text-secondary" aria-label="이전 주">
            <ChevronLeft size={16} />
          </button>
          <div className="flex-1 grid grid-cols-7 gap-0.5">
            {weekDates.map((wd, i) => {
              const isSelected = wd.ds === selectedDs
              const isToday = wd.ds === todayDs
              return (
                <button
                  key={wd.dayNum}
                  onClick={() => setDate(wd.date)}
                  className={`flex flex-col items-center py-1 rounded-md transition-colors ${
                    isSelected
                      ? 'bg-accent text-white'
                      : isToday
                        ? 'bg-accent/10'
                        : wd.isWorkoutDay
                          ? 'border border-border'
                          : ''
                  }`}
                >
                  <span className={`text-[10px] ${
                    isSelected ? 'text-white/70' : i === 5 ? 'text-accent' : i === 6 ? 'text-danger' : 'text-text-secondary'
                  }`}>
                    {wd.label}
                  </span>
                  <span className={`text-sm font-bold ${
                    isSelected ? 'text-white' : isToday ? 'text-accent' : ''
                  }`}>
                    {wd.dayOfMonth}
                  </span>
                </button>
              )
            })}
          </div>
          <button onClick={() => shiftWeek(1)} className="p-1 text-text-secondary" aria-label="다음 주">
            <ChevronRight size={16} />
          </button>
        </div>
      </div>

      {/* 검색 */}
      <div className="flex items-center justify-end -mb-0.5">
        <button
          onClick={() => setSearchOpen(true)}
          className="w-8 h-8 flex items-center justify-center rounded-lg text-text-secondary hover:text-accent transition-colors"
          title="운동 이력 검색"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="10" cy="10" r="6" /><line x1="21" y1="21" x2="14.5" y2="14.5" />
          </svg>
        </button>
      </div>

      {/* 저강도 유산소 (시즌1 레거시 날짜) */}
      {cardio.map((c) => (
        <div key={c.id} className="bg-surface border border-border rounded-xl overflow-hidden">
          <div className="px-4 py-2.5 bg-background border-b border-border flex items-center gap-2">
            <button
              onClick={() => toggleCardio(c.id, !c.completed)}
              className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                c.completed ? 'bg-success border-success text-white' : 'border-border'
              }`}
            >
              {c.completed && (
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><polyline points="20 6 9 17 4 12" /></svg>
              )}
            </button>
            <span className="text-sm font-bold text-foreground">저강도 유산소</span>
          </div>
          {c.memo && <div className="px-4 py-3 text-sm text-foreground whitespace-pre-line">{c.memo}</div>}
        </div>
      ))}

      {/* 운동 카드들 */}
      {loading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="bg-surface border border-border rounded-xl p-4 animate-pulse">
              <div className="h-4 bg-border rounded w-3/4" />
            </div>
          ))}
        </div>
      ) : (
        <>
          {groups.length === 0 ? (
            <p className="text-center text-text-secondary text-sm py-12">이 날짜에 등록된 운동이 없어요. 아래에서 운동을 추가하세요.</p>
          ) : (
            <>
              {/* 공용 운동 (WOD 등) — 헤더 없이 카드만 */}
              {groups.filter((g) => g.isShared).map((g) => (
                <WorkoutCard
                  key={g.workoutId}
                  title={g.title}
                  isShared={g.isShared}
                  logs={g.logs}
                  onChanged={() => loadData(date)}
                  onExerciseLongPress={setGifModalExercise}
                />
              ))}

              {/* 추가 운동 (개인, 비레거시) */}
              {groups.filter((g) => !g.isShared && !g.isLegacy).length > 0 && (
                <h2 className="text-sm font-semibold text-text-secondary mt-4 mb-1">추가 운동</h2>
              )}
              {groups.filter((g) => !g.isShared && !g.isLegacy).map((g) => (
                <WorkoutCard
                  key={g.workoutId}
                  title={g.title}
                  isShared={g.isShared}
                  logs={g.logs}
                  onChanged={() => loadData(date)}
                  onExerciseLongPress={setGifModalExercise}
                />
              ))}

              {/* 이전 데이터 — 섹션 A~F 카드 (헤더 없이, 그룹별) */}
              {groups.filter((g) => g.isLegacy).map((g) => (
                <WorkoutCard
                  key={g.workoutId}
                  title={g.title}
                  isShared={g.isShared}
                  logs={g.logs}
                  onChanged={() => loadData(date)}
                  onExerciseLongPress={setGifModalExercise}
                />
              ))}
            </>
          )}
        </>
      )}

      {/* 운동 추가 버튼 */}
      {!loading && (
        <button
          onClick={() => setAddOpen(true)}
          className="w-full rounded-xl border border-border py-3 text-sm text-accent"
        >
          + 운동 추가
        </button>
      )}
      {addOpen && (
        <AddWorkoutPopup
          userId={userId}
          date={toDateString(date)}
          onAdded={() => { setAddOpen(false); loadData(date) }}
          onClose={() => setAddOpen(false)}
        />
      )}

      {/* 계산기 패널 */}
      {calcOpen && (
        <div className="fixed bottom-[4rem] left-3 right-3 z-[60] bg-surface border border-border rounded-2xl shadow-lg">
          <div className="max-w-lg mx-auto px-4 py-3 flex items-center gap-1">
            <div className="flex-1 min-w-0">
              <Calculator userId={userId} />
            </div>
            <button
              onClick={() => setCalcOpen(false)}
              className="w-6 h-6 flex items-center justify-center text-text-secondary flex-shrink-0"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
        </div>
      )}

      {/* 플로팅 계산기 버튼 */}
      {!calcOpen && (
        <button
          onClick={() => setCalcOpen(true)}
          className="fixed bottom-20 right-4 w-10 h-10 rounded-full bg-transparent border-2 border-accent text-accent shadow-lg flex items-center justify-center z-40 active:bg-accent/10"
          title="계산기"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <rect x="4" y="2" width="16" height="20" rx="2" />
            <line x1="8" y1="6" x2="16" y2="6" />
            <line x1="8" y1="10" x2="8" y2="10.01" />
            <line x1="12" y1="10" x2="12" y2="10.01" />
            <line x1="16" y1="10" x2="16" y2="10.01" />
            <line x1="8" y1="14" x2="8" y2="14.01" />
            <line x1="12" y1="14" x2="12" y2="14.01" />
            <line x1="16" y1="14" x2="16" y2="14.01" />
            <line x1="8" y1="18" x2="8" y2="18.01" />
            <line x1="12" y1="18" x2="16" y2="18" />
          </svg>
        </button>
      )}

      {gifModalExercise && (
        <ExerciseGifModal exerciseName={gifModalExercise} onClose={() => setGifModalExercise(null)} />
      )}

      {searchOpen && <ExerciseSearchModal userId={userId} onClose={() => setSearchOpen(false)} />}
    </div>
  )
}
