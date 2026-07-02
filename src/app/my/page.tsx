'use client'

import { useState, useRef, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import useSWR, { useSWRConfig } from 'swr'
import { toDateString } from '@/lib/utils'
import { getDailyLog, upsertDailyLog, DailyLog } from '@/lib/api/daily-logs'
import { getLoggedInUser, logout } from '@/lib/auth'
import { supabase } from '@/lib/supabase'
import WeightChart from '@/components/summary/WeightChart'
import AvatarEditor from '@/components/profile/AvatarEditor'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'

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
  const { mutate } = useSWRConfig()
  const user = getLoggedInUser()
  const uid = user?.id ?? ''
  const [date, setDate] = useState(toDateString(new Date()))
  const [saving, setSaving] = useState(false)
  // Local weight state for optimistic editing while typing; null = follow SWR
  const [localWeight, setLocalWeight] = useState<number | null | undefined>(undefined)
  const debounceRef = useRef<NodeJS.Timeout | null>(null)

  // Selected-date daily log
  const { data: swrLog } = useSWR(
    uid ? k.dailyLog(uid, date) : null,
    () => getDailyLog(date, uid),
  )

  // Weight graph range query (all rows, ordered by date)
  const { data: weightData } = useSWR(
    uid ? k.weightRange(uid, '', '') : null,
    async () => {
      const { data } = await supabase
        .from('daily_logs')
        .select('date, weight_kg')
        .eq('user_id', uid)
        .order('date', { ascending: true })

      const rows: DailyLogRow[] = data || []
      const weighedLogs = rows.filter(l => l.weight_kg != null)
      if (!weighedLogs.length) return []
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
      return days
    },
  )

  const loading = swrLog === undefined || weightData === undefined

  // Resolved log: prefer SWR data; fall back to emptyLog while loading
  const log: DailyLog = swrLog ?? emptyLog(date)

  // Weight displayed: local optimistic value while typing; SWR after save
  const displayWeight = localWeight !== undefined ? localWeight : log.weight_kg

  const autoSave = useCallback((weight: number | null) => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(async () => {
      setSaving(true)
      try {
        // Read existing row first to preserve archived season1 columns
        const existing = await getDailyLog(date, uid)
        const toSave: DailyLog = existing
          ? { ...existing, weight_kg: weight }
          : { ...emptyLog(date), weight_kg: weight, user_id: uid }
        await upsertDailyLog({ ...toSave, user_id: uid })
        // Invalidate both keys; SWR will refetch and become source of truth
        mutate(matchPrefix('daily-log', uid, date))
        mutate(matchPrefix('weight-range', uid))
        // Clear local shadow so SWR data takes over
        setLocalWeight(undefined)
      } catch (err) {
        console.error('Auto-save failed:', err)
      }
      setSaving(false)
    }, 800)
  }, [uid, date, mutate, setSaving, setLocalWeight])

  function updateWeight(value: number | null) {
    setLocalWeight(value)
    autoSave(value)
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
      {uid && user && <AvatarEditor uid={uid} username={user.username} />}

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
            value={displayWeight ?? ''}
            onChange={(e) => updateWeight(e.target.value ? parseFloat(e.target.value) : null)}
            className="w-24 border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <span className="text-sm text-text-secondary">kg</span>
        </div>
      </Section>

      {/* 체중 그래프 */}
      <WeightChart data={weightData ?? []} />

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
