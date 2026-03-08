'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

interface WeeklyData {
  avgCalories: number | null
  avgSleep: number | null
  workoutDays: number
  weightStart: number | null
  weightEnd: number | null
}

export default function WeeklySummaryCard() {
  const [data, setData] = useState<WeeklyData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchWeekly() {
      const now = new Date()
      const dayOfWeek = now.getDay()
      const monday = new Date(now)
      monday.setDate(now.getDate() - ((dayOfWeek + 6) % 7))
      const sunday = new Date(monday)
      sunday.setDate(monday.getDate() + 6)

      const startStr = monday.toISOString().split('T')[0]
      const endStr = sunday.toISOString().split('T')[0]

      const { data: logs } = await supabase
        .from('daily_logs')
        .select('*')
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date', { ascending: true })

      if (!logs || logs.length === 0) {
        setData(null)
        setLoading(false)
        return
      }

      const cals = logs.filter(l => l.total_calories).map(l => l.total_calories)
      const sleeps = logs.filter(l => l.sleep_hours).map(l => l.sleep_hours)
      const workouts = logs.filter(l => l.workout_done).length
      const weights = logs.filter(l => l.weight_kg).map(l => l.weight_kg)

      setData({
        avgCalories: cals.length ? Math.round(cals.reduce((a: number, b: number) => a + b, 0) / cals.length) : null,
        avgSleep: sleeps.length ? sleeps.reduce((a: number, b: number) => a + b, 0) / sleeps.length : null,
        workoutDays: workouts,
        weightStart: weights.length ? weights[0] : null,
        weightEnd: weights.length > 1 ? weights[weights.length - 1] : null,
      })
      setLoading(false)
    }

    fetchWeekly()
  }, [])

  if (loading) {
    return (
      <div className="bg-surface rounded-2xl p-5 border border-border animate-pulse">
        <div className="h-4 bg-border rounded w-24 mb-3" />
        <div className="h-16 bg-border rounded" />
      </div>
    )
  }

  if (!data) {
    return (
      <div className="bg-surface rounded-2xl p-5 border border-border">
        <p className="text-xs text-text-secondary font-medium mb-3">이번 주 요약</p>
        <p className="text-sm text-text-secondary">아직 기록이 없습니다</p>
      </div>
    )
  }

  const weightChange = data.weightStart && data.weightEnd
    ? Math.round((data.weightEnd - data.weightStart) * 10) / 10
    : null

  return (
    <div className="bg-surface rounded-2xl p-5 border border-border">
      <p className="text-xs text-text-secondary font-medium mb-3">이번 주 요약</p>
      <div className="grid grid-cols-2 gap-4">
        <StatItem
          label="체중 변화"
          value={weightChange !== null ? `${weightChange > 0 ? '+' : ''}${weightChange}kg` : '−'}
        />
        <StatItem
          label="평균 칼로리"
          value={data.avgCalories ? `${data.avgCalories}kcal` : '−'}
        />
        <StatItem
          label="평균 수면"
          value={data.avgSleep ? formatSleepHours(data.avgSleep) : '−'}
        />
        <StatItem
          label="운동 완료"
          value={`${data.workoutDays}/5일`}
        />
      </div>
    </div>
  )
}

function formatSleepHours(hours: number): string {
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  if (m === 0) return `${h}시간`
  return `${h}시간 ${m}분`
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs text-text-secondary">{label}</p>
      <p className="text-lg font-semibold text-foreground mt-0.5">{value}</p>
    </div>
  )
}
