'use client'

import { PieChart, Pie, Cell, ResponsiveContainer } from 'recharts'

interface MacroChartProps {
  carbs: number
  protein: number
  fat: number
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B']

export default function MacroChart({ carbs, protein, fat }: MacroChartProps) {
  const total = carbs + protein + fat
  if (total === 0) {
    return (
      <div className="bg-surface border border-border rounded-xl p-4">
        <p className="text-sm font-medium mb-2">매크로 비율</p>
        <p className="text-sm text-text-secondary">데이터가 없습니다</p>
      </div>
    )
  }

  const data = [
    { name: '탄수화물', value: carbs, color: COLORS[0] },
    { name: '단백질', value: protein, color: COLORS[1] },
    { name: '지방', value: fat, color: COLORS[2] },
  ]

  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <p className="text-sm font-medium mb-4">매크로 비율 (평균)</p>
      <div className="flex items-center gap-4">
        <ResponsiveContainer width={120} height={120}>
          <PieChart>
            <Pie
              data={data}
              cx="50%"
              cy="50%"
              innerRadius={30}
              outerRadius={50}
              dataKey="value"
            >
              {data.map((entry, i) => (
                <Cell key={i} fill={entry.color} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        <div className="space-y-2">
          {data.map(d => (
            <div key={d.name} className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: d.color }} />
              <span className="text-xs text-text-secondary">{d.name}</span>
              <span className="text-xs font-medium">{Math.round(d.value)}g ({Math.round((d.value / total) * 100)}%)</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
