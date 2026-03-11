'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { logout, getLoggedInUser } from '@/lib/auth'
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

const PROGRAM_START = '2026-03-09'
const PROGRAM_END = '2026-06-20'

export default function SummaryPage() {
  const router = useRouter()
  const user = getLoggedInUser()
  const userId = user?.id ?? ''
  const [weeks, setWeeks] = useState<Week[]>([])
  const [selectedWeekId, setSelectedWeekId] = useState('')
  const [chartMode, setChartMode] = useState<'week' | 'all'>('week')
  const [logs, setLogs] = useState<DailyLogRow[]>([])
  const [allLogs, setAllLogs] = useState<DailyLogRow[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function load() {
      try {
        const data = await getWeeks()
        setWeeks(data || [])
        if (data?.length) setSelectedWeekId(data[0].id)
      } catch (err) {
        console.error('Failed to load weeks:', err)
      }
      setLoading(false)
    }
    load()
  }, [])

  // Load weekly logs
  useEffect(() => {
    async function loadLogs() {
      if (!selectedWeekId) return
      const week = weeks.find(w => w.id === selectedWeekId)
      if (!week) return

      try {
        const { data } = await supabase
          .from('daily_logs')
          .select('date, weight_kg, sleep_hours, workout_done, sugar_processed, total_calories, carbs_g, protein_g, fat_g')
          .gte('date', week.start_date)
          .lte('date', week.end_date)
          .eq('user_id', userId)
          .order('date', { ascending: true })

        setLogs(data || [])
      } catch (err) {
        console.error('Failed to load logs:', err)
      }
    }
    loadLogs()
  }, [selectedWeekId, weeks, userId])

  // Load all logs when switching to "all" mode
  useEffect(() => {
    async function loadAllLogs() {
      if (chartMode !== 'all') return
      try {
        const { data } = await supabase
          .from('daily_logs')
          .select('date, weight_kg, sleep_hours, workout_done, sugar_processed, total_calories, carbs_g, protein_g, fat_g')
          .gte('date', PROGRAM_START)
          .lte('date', PROGRAM_END)
          .eq('user_id', userId)
          .order('date', { ascending: true })

        setAllLogs(data || [])
      } catch (err) {
        console.error('Failed to load all logs:', err)
      }
    }
    loadAllLogs()
  }, [chartMode, userId])

  const selectedWeek = weeks.find(w => w.id === selectedWeekId)

  // Weight chart data
  const weightData = (() => {
    if (chartMode === 'all') {
      const logMap = new Map(allLogs.filter(l => l.weight_kg).map(l => [l.date, l.weight_kg!]))
      const start = new Date(PROGRAM_START)
      const end = new Date(PROGRAM_END)
      const days: { date: string; weight: number | null }[] = []
      for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
        const dateStr = d.toISOString().slice(0, 10)
        days.push({ date: dateStr, weight: logMap.get(dateStr) ?? null })
      }
      return days
    } else if (selectedWeek) {
      const logMap = new Map(logs.filter(l => l.weight_kg).map(l => [l.date, l.weight_kg!]))
      const start = new Date(selectedWeek.start_date)
      return Array.from({ length: 7 }, (_, i) => {
        const d = new Date(start)
        d.setDate(start.getDate() + i)
        const dateStr = d.toISOString().slice(0, 10)
        return { date: dateStr, weight: logMap.get(dateStr) ?? null }
      })
    }
    return []
  })()

  // Stats use weekly logs (not affected by chart mode)
  const carbLogs = logs.filter(l => l.carbs_g)
  const proteinLogs = logs.filter(l => l.protein_g)
  const fatLogs = logs.filter(l => l.fat_g)
  const avgCarbs = carbLogs.length ? carbLogs.reduce((s, l) => s + l.carbs_g!, 0) / carbLogs.length : 0
  const avgProtein = proteinLogs.length ? proteinLogs.reduce((s, l) => s + l.protein_g!, 0) / proteinLogs.length : 0
  const avgFat = fatLogs.length ? fatLogs.reduce((s, l) => s + l.fat_g!, 0) / fatLogs.length : 0

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

      {/* Date range + chart mode radio */}
      <div className="flex items-center justify-between">
        {selectedWeek && (
          <p className="text-xs text-text-secondary">
            {selectedWeek.start_date} ~ {selectedWeek.end_date}
          </p>
        )}
        <div className="flex items-center gap-3">
          <button
            onClick={() => setChartMode('all')}
            className="flex items-center gap-1.5"
          >
            <span className={`w-2 h-2 rounded-full ${chartMode === 'all' ? 'bg-success' : 'bg-text-secondary/40'}`} />
            <span className={`text-xs ${chartMode === 'all' ? 'text-success font-medium' : 'text-text-secondary'}`}>전체</span>
          </button>
          <button
            onClick={() => setChartMode('week')}
            className="flex items-center gap-1.5"
          >
            <span className={`w-2 h-2 rounded-full ${chartMode === 'week' ? 'bg-success' : 'bg-text-secondary/40'}`} />
            <span className={`text-xs ${chartMode === 'week' ? 'text-success font-medium' : 'text-text-secondary'}`}>주차별</span>
          </button>
        </div>
      </div>

      <WeightChart data={weightData} mode={chartMode} weeks={chartMode === 'all' ? weeks : undefined} />
      <MacroChart carbs={avgCarbs} protein={avgProtein} fat={avgFat} />
      <WeeklyStats
        avgCalories={avgCalories}
        avgSleep={avgSleep}
        workoutDays={workoutDays}
        totalDays={5}
        sugarDays={sugarDays}
      />

      <button
        onClick={() => { logout(); router.push('/login') }}
        className="w-full py-3 text-sm text-danger border border-border rounded-xl bg-surface"
      >
        로그아웃
      </button>
    </div>
  )
}
