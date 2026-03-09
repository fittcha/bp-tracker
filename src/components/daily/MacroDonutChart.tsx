'use client'

interface MacroDonutChartProps {
  calories: number | null
  carbs: number | null
  protein: number | null
  fat: number | null
}

const COLORS = {
  carbs: '#3B82F6',
  protein: '#F97316',
  fat: '#FBBF24',
}

export default function MacroDonutChart({ calories, carbs, protein, fat }: MacroDonutChartProps) {
  const c = carbs ?? 0
  const p = protein ?? 0
  const f = fat ?? 0
  const kcal = calories ?? 0

  // Calorie contribution ratio: carbs*4 : protein*4 : fat*9
  const carbCal = c * 4
  const protCal = p * 4
  const fatCal = f * 9
  const totalCal = carbCal + protCal + fatCal

  if (totalCal === 0 && kcal === 0) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="w-28 h-28 rounded-full border-4 border-border flex items-center justify-center">
          <span className="text-xs text-text-secondary">No data</span>
        </div>
      </div>
    )
  }

  const carbPct = totalCal > 0 ? Math.round((carbCal / totalCal) * 100) : 0
  const protPct = totalCal > 0 ? Math.round((protCal / totalCal) * 100) : 0
  const fatPct = totalCal > 0 ? Math.round((fatCal / totalCal) * 100) : 0
  const displayKcal = kcal > 0 ? kcal : Math.round(totalCal)

  // SVG donut chart
  const size = 140
  const cx = size / 2
  const cy = size / 2
  const outer = 62
  const inner = 38
  const segments = [
    { value: carbCal, color: COLORS.carbs },
    { value: protCal, color: COLORS.protein },
    { value: fatCal, color: COLORS.fat },
  ].filter(s => s.value > 0)

  let cumulative = 0
  const paths = segments.map((seg) => {
    const startAngle = (cumulative / totalCal) * 360 - 90
    cumulative += seg.value
    const endAngle = (cumulative / totalCal) * 360 - 90
    const path = describeArc(cx, cy, outer, inner, startAngle, endAngle)
    return { path, color: seg.color }
  })

  return (
    <div className="flex flex-col items-center gap-1">
      <div className="relative" style={{ width: size, height: size }}>
        <svg width={size} height={size}>
          {paths.map((p, i) => (
            <path key={i} d={p.path} fill={p.color} />
          ))}
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <p className="text-sm font-bold text-text-primary leading-tight">{displayKcal}</p>
            <p className="text-[10px] text-text-secondary">kcal</p>
          </div>
        </div>
      </div>
      <div className="flex gap-3 text-xs">
        <span style={{ color: COLORS.carbs }}>탄 {carbPct}%</span>
        <span style={{ color: COLORS.protein }}>단 {protPct}%</span>
        <span style={{ color: COLORS.fat }}>지 {fatPct}%</span>
      </div>
    </div>
  )
}

function polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
  const rad = (angleDeg * Math.PI) / 180
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) }
}

function describeArc(cx: number, cy: number, outer: number, inner: number, startAngle: number, endAngle: number) {
  const gap = 0.5
  const s = startAngle + gap
  const e = endAngle - gap
  if (e - s <= 0) return ''
  const largeArc = e - s > 180 ? 1 : 0
  const outerStart = polarToCartesian(cx, cy, outer, s)
  const outerEnd = polarToCartesian(cx, cy, outer, e)
  const innerStart = polarToCartesian(cx, cy, inner, e)
  const innerEnd = polarToCartesian(cx, cy, inner, s)
  return [
    `M ${outerStart.x} ${outerStart.y}`,
    `A ${outer} ${outer} 0 ${largeArc} 1 ${outerEnd.x} ${outerEnd.y}`,
    `L ${innerStart.x} ${innerStart.y}`,
    `A ${inner} ${inner} 0 ${largeArc} 0 ${innerEnd.x} ${innerEnd.y}`,
    'Z',
  ].join(' ')
}
