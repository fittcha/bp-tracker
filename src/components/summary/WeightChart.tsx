'use client'

import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, LabelList } from 'recharts'

interface WeekInfo {
  start_date: string
  week_number: number
}

interface WeightChartProps {
  data: { date: string; weight: number | null }[]
  mode: 'week' | 'all'
  weeks?: WeekInfo[]
}

const DAY_LABELS = ['월', '화', '수', '목', '금', '토', '일']

export default function WeightChart({ data, mode, weeks }: WeightChartProps) {
  const hasData = data.some(d => d.weight != null)

  if (!hasData) {
    return (
      <div className="bg-surface border border-border rounded-xl p-4">
        <p className="text-sm font-medium mb-2">체중 변화 (kg)</p>
        <p className="text-sm text-text-secondary">데이터가 없습니다</p>
      </div>
    )
  }

  const weights = data.filter(d => d.weight != null).map(d => d.weight!)
  const minWeight = Math.floor(Math.min(...weights) - 2)
  const maxWeight = Math.ceil(Math.max(...weights) + 2)

  // Find the last data point index
  let lastDataIndex = -1
  data.forEach((d, i) => { if (d.weight != null) lastDataIndex = i })

  const isAll = mode === 'all'

  // For "all" mode: build a set of week start dates for X-axis ticks
  const weekStartSet = new Set(weeks?.map(w => w.start_date) ?? [])
  const weekStartMap = new Map(weeks?.map(w => [w.start_date, w.week_number]) ?? [])

  // Custom dot
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderDot = (props: any) => {
    const { cx, cy, index, payload } = props
    if (payload.weight == null) return <g key={index} />
    const isLast = index === lastDataIndex
    return (
      <circle
        key={index}
        cx={cx}
        cy={cy}
        r={isLast ? 5 : (isAll ? 3 : 4)}
        fill={isLast ? '#3B82F6' : '#6B7280'}
        stroke="white"
        strokeWidth={isAll ? 1.5 : 2}
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
      // Only label first and last data points
      const firstDataIndex = data.findIndex(d => d.weight != null)
      if (index !== firstDataIndex && index !== lastDataIndex) return <g key={index} />
    }

    const isLast = index === lastDataIndex
    return (
      <text
        key={index}
        x={x}
        y={y - (isAll ? 10 : 14)}
        textAnchor="middle"
        fontSize={isAll ? 10 : 11}
        fontWeight={isLast ? 700 : 500}
        fill={isLast ? '#3B82F6' : '#6B7280'}
      >
        {entry.weight.toFixed(1)}
      </text>
    )
  }

  // X-axis tick formatter
  const formatTick = (value: string, index: number) => {
    if (isAll) {
      // Show week number labels at week start dates
      if (weekStartSet.has(value)) {
        const wn = weekStartMap.get(value)
        return `${wn}주`
      }
      return ''
    }
    return DAY_LABELS[index] ?? ''
  }

  // For "all" mode, only show ticks at week start dates
  const ticks = isAll ? data.filter(d => weekStartSet.has(d.date)).map(d => d.date) : undefined

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <p className="text-sm font-medium mb-4">체중 변화 (kg)</p>
      <ResponsiveContainer width="100%" height={isAll ? 220 : 180}>
        <LineChart data={data} margin={{ top: 24, right: 20, bottom: 4, left: 20 }}>
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
            hide
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
