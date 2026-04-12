'use client'

import { LineChart, Line, XAxis, YAxis, CartesianGrid, ResponsiveContainer, LabelList } from 'recharts'
import { toDateString } from '@/lib/utils'

interface WeekInfo {
  start_date: string
  week_number: number
}

interface WeightChartProps {
  data: { date: string; weight: number | null }[]
  mode: 'week' | 'all'
  weeks?: WeekInfo[]
  dday?: string  // e.g. '2026-06-20'
}

const DAY_LABELS = ['월', '화', '수', '목', '금', '토', '일']

export default function WeightChart({ data, mode, weeks, dday }: WeightChartProps) {
  const hasData = data.some(d => d.weight != null)

  if (!hasData) {
    return (
      <div className="bg-surface border border-border rounded-xl p-4">
        <p className="text-sm font-medium mb-2">체중 변화 (kg)</p>
        <p className="text-sm text-text-secondary">데이터가 없습니다</p>
      </div>
    )
  }

  const isAll = mode === 'all'
  const weights = data.filter(d => d.weight != null).map(d => d.weight!)
  // For "all" mode: snap domain to 0.5 boundaries
  const rawMin = Math.min(...weights)
  const rawMax = Math.max(...weights)
  // All mode: min snaps down 1.5kg, max snaps up based on decimal
  // decimal >= 0.5 → ceil + 1, < 0.5 → ceil (integer → +1)
  const maxFrac = rawMax % 1
  const allMax = maxFrac >= 0.5 ? Math.ceil(rawMax) + 1 : maxFrac === 0 ? rawMax + 1 : Math.ceil(rawMax)
  const minWeight = isAll ? Math.floor((rawMin - 1.5) * 2) / 2 : rawMin - 1.5
  const maxWeight = isAll ? allMax : rawMax + 1.5

  // Y-axis ticks: 1kg intervals
  const range = maxWeight - minWeight
  const yTicks: number[] = []
  if (isAll) {
    const start = Math.ceil(minWeight)
    for (let v = start; v <= maxWeight + 0.01; v += 1) {
      yTicks.push(v)
    }
  }

  // Find today's data point index (fallback to last data point)
  const todayStr = toDateString(new Date())
  const todayDataIndex = data.findIndex(d => d.date === todayStr && d.weight != null)
  let lastDataIndex = -1
  data.forEach((d, i) => { if (d.weight != null) lastDataIndex = i })
  const highlightIndex = todayDataIndex >= 0 ? todayDataIndex : lastDataIndex

  // For "all" mode: build a set of week start dates for X-axis ticks
  const weekStartSet = new Set(weeks?.map(w => w.start_date) ?? [])
  const weekStartMap = new Map(weeks?.map(w => [w.start_date, w.week_number]) ?? [])

  // Custom dot
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderDot = (props: any) => {
    const { cx, cy, index, payload } = props
    if (payload.weight == null) return <g key={index} />
    const isHighlight = index === highlightIndex
    return (
      <circle
        key={index}
        cx={cx}
        cy={cy}
        r={isHighlight ? (isAll ? 3 : 5) : (isAll ? 1.5 : 4)}
        fill={isHighlight ? '#3B82F6' : '#6B7280'}
        stroke={isAll ? 'none' : 'white'}
        strokeWidth={isAll ? 0 : 2}
      />
    )
  }

  // Custom label: week mode shows all labels, all mode shows only first and last
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderLabel = (props: any) => {
    const { x, y, index } = props
    const entry = data[index]
    if (!entry || entry.weight == null) return <g key={index} />

    if (isAll) {
      // Only label first data point and highlighted (today / last) point
      const firstDataIndex = data.findIndex(d => d.weight != null)
      if (index !== firstDataIndex && index !== highlightIndex) return <g key={index} />
    }

    const isHighlight = index === highlightIndex
    return (
      <text
        key={index}
        x={x}
        y={y - (isAll ? 10 : 14)}
        textAnchor="middle"
        fontSize={isAll ? 10 : 11}
        fontWeight={isHighlight ? 700 : 500}
        fill={isHighlight ? '#3B82F6' : '#6B7280'}
      >
        {entry.weight.toFixed(1)}
      </text>
    )
  }

  // X-axis tick formatter
  const formatTick = (value: string, index: number) => {
    if (isAll) {
      if (dday && value === dday) return '✌🏻'
      if (weekStartSet.has(value)) {
        const wn = weekStartMap.get(value)
        return `${wn}주`
      }
      return ''
    }
    return DAY_LABELS[index] ?? ''
  }

  // For "all" mode, show ticks at week start dates + D-day
  const ticks = isAll
    ? [
        ...data.filter(d => weekStartSet.has(d.date)).map(d => d.date),
        ...(dday && data.some(d => d.date === dday) ? [dday] : []),
      ]
    : undefined

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <p className="text-sm font-medium mb-2">체중 변화 (kg)</p>
      <ResponsiveContainer width="100%" height={isAll ? Math.max(180, Math.ceil(range) * 20 + 40) : 140}>
        <LineChart data={data} margin={isAll ? { top: 14, right: 4, bottom: 0, left: -8 } : { top: 24, right: 20, bottom: -8, left: 20 }}>
          {isAll && (
            <CartesianGrid
              stroke="#E5E7EB"
              strokeOpacity={0.5}
            />
          )}
          <XAxis
            dataKey="date"
            tick={{ fontSize: isAll ? 9 : 10, fill: '#9CA3AF' }}
            tickFormatter={formatTick}
            ticks={ticks}
            axisLine={false}
            tickLine={false}
            interval={isAll ? 0 : undefined}
          />
          <YAxis
            domain={[minWeight, maxWeight]}
            hide={!isAll}
            ticks={isAll ? yTicks : undefined}
            tickFormatter={isAll ? (v: number) => `${v}` : undefined}
            tick={isAll ? { fontSize: 9, fill: '#9CA3AF' } : undefined}
            interval={0}
            axisLine={false}
            tickLine={false}
            width={isAll ? 28 : 0}
          />
          <Line
            type="monotone"
            dataKey="weight"
            stroke="#D1D5DB"
            strokeWidth={isAll ? 1.5 : 2}
            dot={renderDot}
            activeDot={{ r: 6, fill: '#3B82F6', stroke: 'white', strokeWidth: 2 }}
            isAnimationActive={false}
            connectNulls={true}
          >
            <LabelList content={renderLabel} />
          </Line>
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
