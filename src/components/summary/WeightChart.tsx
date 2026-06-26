'use client'

import { useState } from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, ResponsiveContainer, LabelList } from 'recharts'
import { toDateString } from '@/lib/utils'

interface WeightChartProps {
  data: { date: string; weight: number | null }[]
}

const PERIODS = [
  { key: '1w', label: '1주', weeks: 1 },
  { key: '4w', label: '4주', weeks: 4 },
  { key: '12w', label: '12주', weeks: 12 },
] as const

type PeriodKey = (typeof PERIODS)[number]['key']

export default function WeightChart({ data }: WeightChartProps) {
  const [open, setOpen] = useState(false) // 기본 접힘(아코디언)
  const [period, setPeriod] = useState<PeriodKey>('4w') // 기본 최근 4주
  const hasData = data.some((d) => d.weight != null)
  const weeks = PERIODS.find((p) => p.key === period)!.weeks

  return (
    <div className="bg-surface border border-border rounded-xl">
      <button onClick={() => setOpen((o) => !o)} className="w-full flex items-center justify-between p-4">
        <span className="text-sm font-medium">체중 변화 (kg)</span>
        <svg
          width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
          className={`text-text-secondary transition-transform ${open ? 'rotate-180' : ''}`}
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>
      {open && (
        <div className="px-4 pb-4">
          {/* 기간 선택 */}
          <div className="flex gap-1.5 mb-3">
            {PERIODS.map((p) => (
              <button
                key={p.key}
                onClick={() => setPeriod(p.key)}
                className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                  period === p.key ? 'bg-accent text-white' : 'bg-background border border-border text-text-secondary'
                }`}
              >
                {p.label}
              </button>
            ))}
          </div>
          {hasData ? (
            <WeightChartBody data={data} weeks={weeks} />
          ) : (
            <p className="text-sm text-text-secondary py-6 text-center">데이터가 없습니다</p>
          )}
        </div>
      )}
    </div>
  )
}

function WeightChartBody({ data, weeks }: { data: WeightChartProps['data']; weeks: number }) {
  // 최근 N주: 마지막 기록일 기준으로 N*7일 이전까지
  const dated = data.filter((d) => d.weight != null)
  const lastDate = dated.length ? dated[dated.length - 1].date : toDateString(new Date())
  const cutoff = new Date(lastDate)
  cutoff.setDate(cutoff.getDate() - weeks * 7)
  const cutoffStr = toDateString(cutoff)
  const filtered = data.filter((d) => d.date >= cutoffStr && d.date <= lastDate)

  const weights = filtered.filter((d) => d.weight != null).map((d) => d.weight!)
  if (weights.length === 0) {
    return <p className="text-sm text-text-secondary py-8 text-center">이 기간에 기록이 없어요</p>
  }

  const rawMin = Math.min(...weights)
  const rawMax = Math.max(...weights)
  const minWeight = Math.floor((rawMin - 1) * 2) / 2
  const maxWeight = Math.ceil(rawMax + 1)
  const range = maxWeight - minWeight
  const yTicks: number[] = []
  for (let v = Math.ceil(minWeight); v <= maxWeight + 0.01; v += 1) yTicks.push(v)

  // 최신(마지막) 데이터 포인트 강조
  let highlightIndex = -1
  filtered.forEach((d, i) => { if (d.weight != null) highlightIndex = i })
  const firstDataIndex = filtered.findIndex((d) => d.weight != null)

  const fmtDate = (s: string) => {
    const parts = s.split('-')
    return `${+parts[1]}/${+parts[2]}`
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderDot = (p: any) => {
    const { cx, cy, index, payload } = p
    if (payload.weight == null) return <g key={index} />
    const isHi = index === highlightIndex
    return <circle key={index} cx={cx} cy={cy} r={isHi ? 4 : 2} fill={isHi ? '#3B82F6' : '#6B7280'} />
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderLabel = (p: any) => {
    const { x, y, index } = p
    const entry = filtered[index]
    if (!entry || entry.weight == null) return <g key={index} />
    if (index !== firstDataIndex && index !== highlightIndex) return <g key={index} />
    const isHi = index === highlightIndex
    return (
      <text key={index} x={x} y={y - 10} textAnchor="middle" fontSize={10} fontWeight={isHi ? 700 : 500} fill={isHi ? '#3B82F6' : '#6B7280'}>
        {entry.weight.toFixed(1)}
      </text>
    )
  }

  return (
    <ResponsiveContainer width="100%" height={Math.max(180, Math.ceil(range) * 20 + 50)}>
      <LineChart data={filtered} margin={{ top: 16, right: 12, bottom: 0, left: -8 }}>
        <CartesianGrid stroke="#E5E7EB" strokeOpacity={0.5} />
        <XAxis
          dataKey="date"
          tickFormatter={fmtDate}
          tick={{ fontSize: 9, fill: '#9CA3AF' }}
          minTickGap={28}
          interval="preserveStartEnd"
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          domain={[minWeight, maxWeight]}
          ticks={yTicks}
          tickFormatter={(v: number) => `${v}`}
          tick={{ fontSize: 9, fill: '#9CA3AF' }}
          interval={0}
          axisLine={false}
          tickLine={false}
          width={28}
        />
        <Line
          type="monotone"
          dataKey="weight"
          stroke="#D1D5DB"
          strokeWidth={1.5}
          dot={renderDot}
          activeDot={{ r: 5, fill: '#3B82F6', stroke: 'white', strokeWidth: 2 }}
          isAnimationActive={false}
          connectNulls={true}
        >
          <LabelList content={renderLabel} />
        </Line>
      </LineChart>
    </ResponsiveContainer>
  )
}
