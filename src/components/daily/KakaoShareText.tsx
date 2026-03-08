'use client'

import { useState } from 'react'
import { DailyLog } from '@/lib/api/daily-logs'
import { formatDate } from '@/lib/utils'

interface KakaoShareTextProps {
  log: DailyLog
}

export default function KakaoShareText({ log }: KakaoShareTextProps) {
  const [copied, setCopied] = useState(false)

  const date = new Date(log.date + 'T00:00:00')
  const dateStr = formatDate(date)

  function formatSleepHours(hours: number): string {
    const h = Math.floor(hours)
    const m = Math.round((hours - h) * 60)
    if (m === 0) return `${h}시간`
    return `${h}시간 ${m}분`
  }

  const sleepDisplay = log.sleep_hours
    ? formatSleepHours(log.sleep_hours)
    : '−'

  const sleepTimeShort = log.sleep_time ? log.sleep_time.slice(0, 5) : '−'
  const wakeTimeShort = log.wake_time ? log.wake_time.slice(0, 5) : '−'

  const text = `${dateStr}
총 수면 시간 : ${sleepDisplay} (${sleepTimeShort} / ${wakeTimeShort})
운동 여부 : ${log.workout_done ? 'O' : 'X'}
당/가공식품 섭취 여부 : ${log.sugar_processed || 'X'}`

  async function handleCopy() {
    await navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <div className="flex items-center justify-between mb-3">
        <p className="text-sm font-medium">카톡 공유 텍스트</p>
        <button
          onClick={handleCopy}
          className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
            copied
              ? 'bg-success text-white'
              : 'bg-accent text-white'
          }`}
        >
          {copied ? '복사됨!' : '복사'}
        </button>
      </div>
      <pre className="text-sm text-text-secondary whitespace-pre-wrap bg-background rounded-lg p-3 font-sans">
        {text}
      </pre>
    </div>
  )
}
