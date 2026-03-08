'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { toDateString } from '@/lib/utils'
import Link from 'next/link'

export default function TodayStatus() {
  const [workoutDone, setWorkoutDone] = useState(false)
  const [dailyDone, setDailyDone] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const today = toDateString(new Date())

    async function fetchStatus() {
      const [workoutRes, dailyRes] = await Promise.all([
        supabase.from('workout_logs').select('id').eq('date', today).limit(1),
        supabase.from('daily_logs').select('id').eq('date', today).limit(1),
      ])
      setWorkoutDone((workoutRes.data?.length ?? 0) > 0)
      setDailyDone((dailyRes.data?.length ?? 0) > 0)
      setLoading(false)
    }

    fetchStatus()
  }, [])

  if (loading) {
    return (
      <div className="bg-surface rounded-2xl p-5 border border-border animate-pulse">
        <div className="h-4 bg-border rounded w-24 mb-3" />
        <div className="h-10 bg-border rounded" />
      </div>
    )
  }

  return (
    <div className="bg-surface rounded-2xl p-5 border border-border">
      <p className="text-xs text-text-secondary font-medium mb-3">오늘의 기록</p>
      <div className="grid grid-cols-2 gap-3">
        <Link href="/workout" className="flex items-center gap-3 p-3 rounded-xl bg-background">
          <span className={`w-8 h-8 rounded-full flex items-center justify-center text-sm ${
            workoutDone ? 'bg-success/10 text-success' : 'bg-border text-text-secondary'
          }`}>
            {workoutDone ? '✓' : '−'}
          </span>
          <div>
            <p className="text-sm font-medium">운동</p>
            <p className="text-xs text-text-secondary">{workoutDone ? '완료' : '미완료'}</p>
          </div>
        </Link>
        <Link href="/daily" className="flex items-center gap-3 p-3 rounded-xl bg-background">
          <span className={`w-8 h-8 rounded-full flex items-center justify-center text-sm ${
            dailyDone ? 'bg-success/10 text-success' : 'bg-border text-text-secondary'
          }`}>
            {dailyDone ? '✓' : '−'}
          </span>
          <div>
            <p className="text-sm font-medium">일일기록</p>
            <p className="text-xs text-text-secondary">{dailyDone ? '완료' : '미완료'}</p>
          </div>
        </Link>
      </div>
    </div>
  )
}
