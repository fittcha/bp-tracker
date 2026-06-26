'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { getLoggedInUser } from '@/lib/auth'
import { getWorkoutLogsWithWorkout } from '@/lib/api/workout-logs'
import { getDefaultWorkoutsForWeekday, getWorkoutExercises } from '@/lib/api/workouts'
import { supabase } from '@/lib/supabase'
import { toDateString } from '@/lib/utils'

interface WorkoutProgress {
  completed: number
  total: number
}

interface LatestWeight {
  weight_kg: number
  date: string
}

export default function Home() {
  const [workoutProgress, setWorkoutProgress] = useState<WorkoutProgress | null>(null)
  const [latestWeight, setLatestWeight] = useState<LatestWeight | null | 'none'>('none')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const user = getLoggedInUser()
    if (!user) {
      setLoading(false)
      return
    }

    const today = new Date()
    const todayDs = toDateString(today)
    const jsDay = today.getDay()
    const weekday = jsDay === 0 ? 7 : jsDay

    async function load() {
      try {
        // 오늘의 추가운동 진행
        const logs = await getWorkoutLogsWithWorkout(todayDs, user!.id)
        let total = logs.length
        let completed = logs.filter((l) => l.completed).length

        // 오늘 로그가 없고 평일(월~금)이면 공용 기본운동 동작 수로 fallback
        if (total === 0 && weekday >= 1 && weekday <= 5) {
          const defaults = await getDefaultWorkoutsForWeekday(weekday)
          const exerciseCounts = await Promise.all(
            defaults.map((w) => getWorkoutExercises(w.id).then((exs) => exs.length)),
          )
          total = exerciseCounts.reduce((sum, n) => sum + n, 0)
          completed = 0
        }

        setWorkoutProgress({ completed, total })

        // 최근 체중
        const { data: weightRows, error: wErr } = await supabase
          .from('daily_logs')
          .select('weight_kg, date')
          .eq('user_id', user!.id)
          .not('weight_kg', 'is', null)
          .order('date', { ascending: false })
          .limit(1)

        if (wErr) throw wErr

        if (weightRows && weightRows.length > 0) {
          setLatestWeight({ weight_kg: weightRows[0].weight_kg as number, date: weightRows[0].date as string })
        } else {
          setLatestWeight(null)
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : '데이터를 불러오지 못했습니다.')
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [])

  if (loading) {
    return (
      <div className="flex flex-col gap-4 max-w-lg mx-auto px-4 py-6">
        <p className="text-text-secondary text-sm">불러오는 중...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex flex-col gap-4 max-w-lg mx-auto px-4 py-6">
        <p className="text-danger text-sm">{error}</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4 max-w-lg mx-auto px-4 py-6">
      {/* 오늘의 추가운동 */}
      <div className="bg-surface border border-border rounded-xl p-4">
        <h2 className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-3">
          오늘의 추가운동
        </h2>
        {workoutProgress ? (
          <>
            <p className="text-lg font-bold text-foreground">
              완료 {workoutProgress.completed} / 전체 {workoutProgress.total}
            </p>
            {workoutProgress.total > 0 && (
              <div className="mt-2 h-1.5 rounded-full bg-accent-light overflow-hidden">
                <div
                  className="h-full bg-accent rounded-full transition-all"
                  style={{
                    width: `${Math.round((workoutProgress.completed / workoutProgress.total) * 100)}%`,
                  }}
                />
              </div>
            )}
            {workoutProgress.total === 0 && (
              <p className="text-xs text-text-secondary mt-1">오늘은 운동이 없는 날이에요.</p>
            )}
          </>
        ) : (
          <p className="text-sm text-text-secondary">운동 기록이 없습니다.</p>
        )}
      </div>

      {/* 최근 체중 */}
      <div className="bg-surface border border-border rounded-xl p-4">
        <h2 className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-3">
          최근 체중
        </h2>
        {latestWeight && latestWeight !== 'none' ? (
          <>
            <p className="text-lg font-bold text-foreground">{latestWeight.weight_kg} kg</p>
            <p className="text-xs text-text-secondary mt-0.5">{latestWeight.date}</p>
          </>
        ) : latestWeight === null ? (
          <p className="text-sm text-text-secondary">기록 없음</p>
        ) : null}
      </div>

      {/* 운동 탭으로 이동 */}
      <Link
        href="/workout"
        className="block text-center bg-accent-light text-accent font-semibold text-sm rounded-xl py-3 hover:opacity-80 transition-opacity"
      >
        운동하러 가기 →
      </Link>
    </div>
  )
}
