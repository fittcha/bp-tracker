'use client'

import { useEffect, useState, useRef, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { toDateString } from '@/lib/utils'
import { getDailyLog, upsertDailyLog, DailyLog } from '@/lib/api/daily-logs'
import { getLoggedInUser, logout } from '@/lib/auth'
import { supabase } from '@/lib/supabase'
import WeightChart from '@/components/summary/WeightChart'

interface DailyLogRow {
  date: string
  weight_kg: number | null
}

const emptyLog = (date: string): DailyLog => ({
  date,
  weight_kg: null,
  sleep_time: null,
  wake_time: null,
  sleep_hours: null,
  workout_done: false,
  sugar_processed: 'X',
  total_calories: null,
  carbs_g: null,
  protein_g: null,
  fat_g: null,
  food_image_url: null,
  supplements: null,
  water_liters: null,
  memo: null,
  meal_completed: null,
  meal_total: null,
  meal_checked: null,
})

export default function MyPage() {
  const router = useRouter()
  const user = getLoggedInUser()
  const userId = user?.id ?? ''
  const [date, setDate] = useState(toDateString(new Date()))
  const [log, setLog] = useState<DailyLog>(emptyLog(date))
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [weightData, setWeightData] = useState<{ date: string; weight: number | null }[]>([])
  const debounceRef = useRef<NodeJS.Timeout | null>(null)
  const isLoadedRef = useRef(false)

  useEffect(() => {
    async function load() {
      isLoadedRef.current = false
      setLoading(true)
      try {
        const existing = await getDailyLog(date, userId)
        if (existing) {
          setLog(existing)
        } else {
          setLog(emptyLog(date))
        }
      } catch (err) {
        console.error('Load failed:', err)
        setLog(emptyLog(date))
      }
      setLoading(false)
      isLoadedRef.current = true
    }
    load()
  }, [date, userId])

  // Load all weight logs for chart (mode="all", no program date bounds)
  useEffect(() => {
    async function loadWeightData() {
      if (!userId) return
      try {
        const { data } = await supabase
          .from('daily_logs')
          .select('date, weight_kg')
          .eq('user_id', userId)
          .order('date', { ascending: true })

        const rows: DailyLogRow[] = data || []
        const weighedLogs = rows.filter(l => l.weight_kg != null)
        if (!weighedLogs.length) {
          setWeightData([])
          return
        }
        const logMap = new Map(weighedLogs.map(l => [l.date, l.weight_kg!]))
        const start = new Date(weighedLogs[0].date)
        // x-axis end: last weight date + 2 days (label padding)
        const end = new Date(weighedLogs[weighedLogs.length - 1].date)
        end.setDate(end.getDate() + 2)
        const days: { date: string; weight: number | null }[] = []
        for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
          const dateStr = d.toISOString().slice(0, 10)
          days.push({ date: dateStr, weight: logMap.get(dateStr) ?? null })
        }
        setWeightData(days)
      } catch (err) {
        console.error('Failed to load weight data:', err)
      }
    }
    loadWeightData()
  }, [userId])

  const autoSave = useCallback((updated: DailyLog) => {
    if (!isLoadedRef.current) return
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(async () => {
      setSaving(true)
      try {
        // Read existing row first to preserve archived season1 columns
        const existing = await getDailyLog(updated.date, userId)
        const toSave: DailyLog = existing
          ? { ...existing, weight_kg: updated.weight_kg }
          : { ...updated, user_id: userId }
        await upsertDailyLog({ ...toSave, user_id: userId })
        const saved = await getDailyLog(updated.date, userId)
        if (saved) setLog(saved)
      } catch (err) {
        console.error('Auto-save failed:', err)
      }
      setSaving(false)
    }, 800)
  }, [userId])

  function updateWeight(value: number | null) {
    setLog(prev => {
      const updated = { ...prev, weight_kg: value }
      autoSave(updated)
      return updated
    })
  }

  if (loading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="bg-surface border border-border rounded-xl p-4 animate-pulse">
            <div className="h-4 bg-border rounded w-1/2 mb-2" />
            <div className="h-8 bg-border rounded" />
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-4 pb-4">
      {/* Date picker */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1">
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() - 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg></button>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            className="border border-border rounded-lg px-3 py-1.5 text-sm bg-surface"
          />
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() + 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg></button>
        </div>
        {saving && <span className="text-xs text-text-secondary">저장 중...</span>}
      </div>

      {/* 체중 입력 */}
      <Section title="체중">
        <div className="flex items-center gap-2">
          <input
            type="number"
            inputMode="decimal"
            step="0.1"
            placeholder="0.0"
            value={log.weight_kg ?? ''}
            onChange={(e) => updateWeight(e.target.value ? parseFloat(e.target.value) : null)}
            className="w-24 border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <span className="text-sm text-text-secondary">kg</span>
        </div>
      </Section>

      {/* 체중 그래프 */}
      <WeightChart data={weightData} />

      <button
        onClick={() => { logout(); router.push('/login') }}
        className="w-full py-3 text-sm text-danger border border-border rounded-xl bg-surface"
      >
        로그아웃
      </button>
    </div>
  )
}

function Section({ title, right, children }: {
  title: string
  right?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      {title && (
        <div className="flex items-center justify-between mb-3">
          <p className="text-sm font-medium">{title}</p>
          {right}
        </div>
      )}
      {children}
    </div>
  )
}
