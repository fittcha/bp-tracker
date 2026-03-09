'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { toDateString } from '@/lib/utils'
import Link from 'next/link'

type Status = 'none' | 'in-progress' | 'done'

export default function TodayStatus() {
  const [workoutStatus, setWorkoutStatus] = useState<Status>('none')
  const [dailyStatus, setDailyStatus] = useState<Status>('none')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const today = toDateString(new Date())

    async function fetchStatus() {
      const [workoutRes, dailyRes] = await Promise.all([
        supabase.from('workout_logs').select('completed').eq('date', today),
        supabase.from('daily_logs').select('weight_kg, sleep_time, wake_time, total_calories, workout_done').eq('date', today).limit(1),
      ])

      // 운동: daily_logs.workout_done=true → 완료, workout_logs에 completed=true 있으면 → 진행중
      const dailyLog = dailyRes.data?.[0]
      if (dailyLog?.workout_done) {
        setWorkoutStatus('done')
      } else if ((workoutRes.data ?? []).some(l => l.completed)) {
        setWorkoutStatus('in-progress')
      } else {
        setWorkoutStatus('none')
      }

      // 일일기록: 체중+수면+식단 모두 입력 → 완료, 하나라도 → 진행중
      if (dailyLog) {
        const hasWeight = dailyLog.weight_kg != null
        const hasSleep = dailyLog.sleep_time != null && dailyLog.wake_time != null
        const hasFood = dailyLog.total_calories != null
        if (hasWeight && hasSleep && hasFood) {
          setDailyStatus('done')
        } else if (hasWeight || hasSleep || hasFood) {
          setDailyStatus('in-progress')
        } else {
          setDailyStatus('none')
        }
      } else {
        setDailyStatus('none')
      }

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
        <StatusCard href="/workout" label="운동" status={workoutStatus} />
        <StatusCard href="/daily" label="일일기록" status={dailyStatus} />
      </div>
    </div>
  )
}

function StatusCard({ href, label, status }: { href: string; label: string; status: Status }) {
  const config = {
    'none': { icon: '−', text: '진행전', iconClass: 'bg-border text-text-secondary' },
    'in-progress': { icon: '~', text: '진행중', iconClass: 'bg-success/10 text-success' },
    'done': { icon: '✓', text: '완료', iconClass: 'bg-green-500/10 text-green-500' },
  }[status]

  return (
    <Link href={href} className="flex items-center gap-3 p-3 rounded-xl bg-background">
      <span className={`w-8 h-8 rounded-full flex items-center justify-center text-sm ${config.iconClass}`}>
        {config.icon}
      </span>
      <div>
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-text-secondary">{config.text}</p>
      </div>
    </Link>
  )
}
