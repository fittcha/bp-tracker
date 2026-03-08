'use client'

interface WeeklyStatsProps {
  avgCalories: number | null
  avgSleep: number | null
  workoutDays: number
  totalDays: number
  sugarDays: number
}

export default function WeeklyStats({ avgCalories, avgSleep, workoutDays, totalDays, sugarDays }: WeeklyStatsProps) {
  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      <p className="text-sm font-medium mb-3">주간 통계</p>
      <div className="grid grid-cols-2 gap-4">
        <StatItem label="평균 칼로리" value={avgCalories ? `${avgCalories}kcal` : '−'} />
        <StatItem label="평균 수면" value={avgSleep ? formatSleepHours(avgSleep) : '−'} />
        <StatItem label="운동 완료" value={`${workoutDays}/${totalDays}일`} />
        <StatItem label="당/가공식품 섭취" value={`${sugarDays}회`} />
      </div>
    </div>
  )
}

function formatSleepHours(hours: number): string {
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  if (m === 0) return `${h}시간`
  return `${h}시간 ${m}분`
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs text-text-secondary">{label}</p>
      <p className="text-lg font-semibold text-foreground mt-0.5">{value}</p>
    </div>
  )
}
