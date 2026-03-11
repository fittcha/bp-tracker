'use client'

import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, LabelList } from 'recharts'

interface WeightChartProps {
  data: { date: string; weight: number }[]
}

export default function WeightChart({ data }: WeightChartProps) {
  if (data.length === 0) {
    return (
      <div className="bg-surface border border-border rounded-xl p-4">
        <p className="text-sm font-medium mb-2">체중 변화 (kg)</p>
        <p className="text-sm text-text-secondary">데이터가 없습니다</p>
      </div>
    )
  }

  const minWeight = Math.floor(Math.min(...data.map(d => d.weight)) - 2)
  const maxWeight = Math.ceil(Math.max(...data.map(d => d.weight)) + 2)
  const lastIndex = data.length - 1

  // Custom dot: last point is accent blue, others are gray
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderDot = (props: any) => {
    const { cx, cy, index } = props
    const isLast = index === lastIndex
    return (
      <circle
        key={index}
        cx={cx}
        cy={cy}
        r={isLast ? 5 : 4}
        fill={isLast ? '#3B82F6' : '#6B7280'}
        stroke="white"
        strokeWidth={2}
      />
    )
  }

  // Custom label: show weight value above each dot, last one is blue + bold
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const renderLabel = (props: any) => {
    const { x, y, value, index } = props
    const isLast = index === lastIndex
    return (
      <text
        key={index}
        x={x}
        y={y - 14}
        textAnchor="middle"
        fontSize={11}
        fontWeight={isLast ? 700 : 500}
        fill={isLast ? '#3B82F6' : '#6B7280'}
      >
        {value.toFixed(1)}
      </text>
    )
  }

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <p className="text-sm font-medium mb-4">체중 변화 (kg)</p>
      <ResponsiveContainer width="100%" height={180}>
        <LineChart data={data} margin={{ top: 24, right: 20, bottom: 4, left: 20 }}>
          <XAxis
            dataKey="date"
            tick={{ fontSize: 10, fill: '#9CA3AF' }}
            tickFormatter={(v) => v.slice(5)}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            domain={[minWeight, maxWeight]}
            hide
          />
          <Line
            type="monotone"
            dataKey="weight"
            stroke="#D1D5DB"
            strokeWidth={2}
            dot={renderDot}
            activeDot={{ r: 6, fill: '#3B82F6', stroke: 'white', strokeWidth: 2 }}
            isAnimationActive={false}
          >
            <LabelList content={renderLabel} />
          </Line>
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
