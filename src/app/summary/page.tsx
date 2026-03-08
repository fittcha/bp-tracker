'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { getWeeks } from '@/lib/api/workout-templates'
import WeightChart from '@/components/summary/WeightChart'
import MacroChart from '@/components/summary/MacroChart'
import WeeklyStats from '@/components/summary/WeeklyStats'

interface Week {
  id: string
  week_number: number
  phase: string
  start_date: string
  end_date: string
}

interface DailyLogRow {
  date: string
  weight_kg: number | null
  sleep_hours: number | null
  workout_done: boolean
  sugar_processed: string
  total_calories: number | null
  carbs_g: number | null
  protein_g: number | null
  fat_g: number | null
}

export default function SummaryPage() {
  const [weeks, setWeeks] = useState<Week[]>([])
  const [selectedWeekId, setSelectedWeekId] = useState('')
  const [logs, setLogs] = useState<DailyLogRow[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function load() {
      const data = await getWeeks()
      setWeeks(data || [])
      if (data?.length) setSelectedWeekId(data[0].id)
      setLoading(false)
    }
    load()
  }, [])

  useEffect(() => {
    async function loadLogs() {
      if (!selectedWeekId) return
      const week = weeks.find(w => w.id === selectedWeekId)
      if (!week) return

      const { data } = await supabase
        .from('daily_logs')
        .select('date, weight_kg, sleep_hours, workout_done, sugar_processed, total_calories, carbs_g, protein_g, fat_g')
        .gte('date', week.start_date)
        .lte('date', week.end_date)
        .order('date', { ascending: true })

      setLogs(data || [])
    }
    loadLogs()
  }, [selectedWeekId, weeks])

  const selectedWeek = weeks.find(w => w.id === selectedWeekId)

  // Weight chart data
  const weightData = logs
    .filter(l => l.weight_kg)
    .map(l => ({ date: l.date, weight: l.weight_kg! }))

  // Macro averages
  const carbLogs = logs.filter(l => l.carbs_g)
  const proteinLogs = logs.filter(l => l.protein_g)
  const fatLogs = logs.filter(l => l.fat_g)
  const avgCarbs = carbLogs.length ? carbLogs.reduce((s, l) => s + l.carbs_g!, 0) / carbLogs.length : 0
  const avgProtein = proteinLogs.length ? proteinLogs.reduce((s, l) => s + l.protein_g!, 0) / proteinLogs.length : 0
  const avgFat = fatLogs.length ? fatLogs.reduce((s, l) => s + l.fat_g!, 0) / fatLogs.length : 0

  // Stats
  const calLogs = logs.filter(l => l.total_calories)
  const sleepLogs = logs.filter(l => l.sleep_hours)
  const avgCalories = calLogs.length ? Math.round(calLogs.reduce((s, l) => s + l.total_calories!, 0) / calLogs.length) : null
  const avgSleep = sleepLogs.length ? Math.round((sleepLogs.reduce((s, l) => s + l.sleep_hours!, 0) / sleepLogs.length) * 10) / 10 : null
  const workoutDays = logs.filter(l => l.workout_done).length
  const sugarDays = logs.filter(l => l.sugar_processed && l.sugar_processed !== 'X').length

  if (loading) return <div className="p-4">로딩 중...</div>

  return (
    <div className="space-y-4">
      {/* Week selector */}
      <select
        value={selectedWeekId}
        onChange={(e) => setSelectedWeekId(e.target.value)}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      >
        {weeks.map(w => (
          <option key={w.id} value={w.id}>{w.week_number}주차 - {w.phase}</option>
        ))}
      </select>

      {selectedWeek && (
        <p className="text-xs text-text-secondary">
          {selectedWeek.start_date} ~ {selectedWeek.end_date}
        </p>
      )}

      <WeightChart data={weightData} />
      <MacroChart carbs={avgCarbs} protein={avgProtein} fat={avgFat} />
      <WeeklyStats
        avgCalories={avgCalories}
        avgSleep={avgSleep}
        workoutDays={workoutDays}
        totalDays={5}
        sugarDays={sugarDays}
      />
    </div>
  )
}
