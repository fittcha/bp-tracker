'use client'

import { useEffect, useState, useRef, useCallback } from 'react'
import { toDateString, calcSleepHours } from '@/lib/utils'
import { getDailyLog, upsertDailyLog, DailyLog } from '@/lib/api/daily-logs'
import { getWeeks } from '@/lib/api/workout-templates'
import { getLoggedInUser } from '@/lib/auth'
import FoodImageUpload from '@/components/daily/FoodImageUpload'
import MacroDonutChart from '@/components/daily/MacroDonutChart'
import KakaoShareText from '@/components/daily/KakaoShareText'

const SUPPLEMENTS = [
  '비타민B',
  '비타민D',
  '비타민C',
  '오메가3',
  '마그네슘',
  '유산균',
]

const emptyLog = (date: string): DailyLog => ({
  date,
  weight_kg: null,
  sleep_time: null,
  wake_time: null,
  sleep_hours: null,
  workout_done: false,
  sugar_processed: 'X',
  total_calories: null,
  carbs_g: null,
  protein_g: null,
  fat_g: null,
  food_image_url: null,
  supplements: null,
  water_liters: null,
  memo: null,
})

function parseSupplements(str: string | null): Set<string> {
  if (!str) return new Set()
  return new Set(str.split(',').map(s => s.trim()).filter(Boolean))
}

function serializeSupplements(set: Set<string>): string | null {
  if (set.size === 0) return null
  return Array.from(set).join(', ')
}

export default function DailyPage() {
  const user = getLoggedInUser()
  const userId = user?.id ?? ''
  const [date, setDate] = useState(toDateString(new Date()))
  const [log, setLog] = useState<DailyLog>(emptyLog(date))
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [sugarToggle, setSugarToggle] = useState(true)
  const [checkedSupps, setCheckedSupps] = useState<Set<string>>(new Set())
  const [weekLabel, setWeekLabel] = useState<string | null>(null)
  const debounceRef = useRef<NodeJS.Timeout | null>(null)
  const isLoadedRef = useRef(false)

  useEffect(() => {
    async function load() {
      isLoadedRef.current = false
      setLoading(true)
      try {
        const existing = await getDailyLog(date, userId)
        if (existing) {
          setLog(existing)
          setSugarToggle(existing.sugar_processed === 'X')
          setCheckedSupps(parseSupplements(existing.supplements))
        } else {
          setLog(emptyLog(date))
          setSugarToggle(true)
          setCheckedSupps(new Set())
        }
      } catch (err) {
        console.error('Load failed:', err)
        setLog(emptyLog(date))
      }
      setLoading(false)
      isLoadedRef.current = true
    }
    async function loadWeek() {
      const weeks = await getWeeks()
      if (!weeks) return
      const week = weeks.find((w: { start_date: string; end_date: string }) => date >= w.start_date && date <= w.end_date)
      setWeekLabel(week ? `${week.week_number}주차 · ${week.phase}` : null)
    }
    load()
    loadWeek()
  }, [date, userId])

  const autoSave = useCallback((updated: DailyLog) => {
    if (!isLoadedRef.current) return
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(async () => {
      setSaving(true)
      try {
        await upsertDailyLog({ ...updated, user_id: userId })
        const saved = await getDailyLog(updated.date, userId)
        if (saved) setLog(saved)
      } catch (err) {
        console.error('Auto-save failed:', err)
      }
      setSaving(false)
    }, 800)
  }, [userId])

  function updateField<K extends keyof DailyLog>(field: K, value: DailyLog[K]) {
    setLog(prev => {
      const updated = { ...prev, [field]: value }
      if ((field === 'sleep_time' || field === 'wake_time') && updated.sleep_time && updated.wake_time) {
        updated.sleep_hours = calcSleepHours(updated.sleep_time, updated.wake_time)
      }
      autoSave(updated)
      return updated
    })
  }

  function toggleSupplement(name: string) {
    setCheckedSupps(prev => {
      const next = new Set(prev)
      if (next.has(name)) next.delete(name)
      else next.add(name)
      setLog(l => {
        const updated = { ...l, supplements: serializeSupplements(next) }
        autoSave(updated)
        return updated
      })
      return next
    })
  }

  function handleOcrResult(result: { totalCalories: number | null; carbs: number | null; protein: number | null; fat: number | null }) {
    setLog(prev => {
      const updated = {
        ...prev,
        total_calories: result.totalCalories ?? prev.total_calories,
        carbs_g: result.carbs ?? prev.carbs_g,
        protein_g: result.protein ?? prev.protein_g,
        fat_g: result.fat ?? prev.fat_g,
      }
      autoSave(updated)
      return updated
    })
  }

  if (loading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="bg-surface border border-border rounded-xl p-4 animate-pulse">
            <div className="h-4 bg-border rounded w-1/2 mb-2" />
            <div className="h-8 bg-border rounded" />
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-4 pb-4">
      {/* Date picker + week info */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1">
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() - 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg></button>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            className="border border-border rounded-lg px-3 py-1.5 text-sm bg-surface"
          />
          <button
            onClick={() => { const d = new Date(date); d.setDate(d.getDate() + 1); setDate(toDateString(d)) }}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-border bg-surface text-text-secondary"
          ><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg></button>
        </div>
        {weekLabel && (
          <span className="text-sm font-medium text-accent">{weekLabel}</span>
        )}
      </div>

      {/* 체중 */}
      <Section title="체중">
        <div className="flex items-center gap-2">
          <input
            type="number"
            inputMode="decimal"
            step="0.1"
            placeholder="0.0"
            value={log.weight_kg ?? ''}
            onChange={(e) => updateField('weight_kg', e.target.value ? parseFloat(e.target.value) : null)}
            className="w-24 border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
          <span className="text-sm text-text-secondary">kg</span>
        </div>
      </Section>

      {/* 수면 */}
      <Section title="수면">
        <div className="grid grid-cols-2 gap-10">
          <TimeInput24 label="취침시간" value={log.sleep_time} onChange={(v) => updateField('sleep_time', v)} />
          <TimeInput24 label="기상시간" value={log.wake_time} onChange={(v) => updateField('wake_time', v)} />
        </div>
        {log.sleep_hours != null && log.sleep_hours > 0 && (
          <p className={`text-sm font-medium mt-2 ${log.sleep_hours >= 7 ? 'text-success' : 'text-danger'}`}>
            총 수면시간: {formatSleepHours(log.sleep_hours)}
          </p>
        )}
      </Section>

      {/* 운동 여부 */}
      <Section title="운동 여부">
        <div className="flex gap-3">
          <button
            onClick={() => updateField('workout_done', true)}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
              log.workout_done ? 'bg-success text-white' : 'bg-background border border-border text-text-secondary'
            }`}
          >
            O
          </button>
          <button
            onClick={() => updateField('workout_done', false)}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
              !log.workout_done ? 'bg-danger text-white' : 'bg-background border border-border text-text-secondary'
            }`}
          >
            X
          </button>
        </div>
      </Section>

      {/* 당/가공식품 */}
      <Section title="당/가공식품 섭취 여부">
        <div className="flex gap-3 mb-2">
          <button
            onClick={() => { setSugarToggle(true); updateField('sugar_processed', 'X') }}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
              sugarToggle ? 'bg-success text-white' : 'bg-background border border-border text-text-secondary'
            }`}
          >
            X (미섭취)
          </button>
          <button
            onClick={() => { setSugarToggle(false); updateField('sugar_processed', '') }}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
              !sugarToggle ? 'bg-danger text-white' : 'bg-background border border-border text-text-secondary'
            }`}
          >
            섭취함
          </button>
        </div>
        {!sugarToggle && (
          <input
            placeholder="섭취 항목 입력"
            value={log.sugar_processed === 'X' ? '' : log.sugar_processed}
            onChange={(e) => updateField('sugar_processed', e.target.value)}
            className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-background"
          />
        )}
      </Section>

      {/* 식단 이미지 + OCR */}
      <Section title="식단">
        <FoodImageUpload
          imageUrl={log.food_image_url}
          onUploaded={(url) => updateField('food_image_url', url)}
          onOcrResult={handleOcrResult}
          userId={userId}
        />
        <div className="flex gap-3 mt-3">
          <div className="w-1/3 space-y-2">
            <NumberInput label="칼로리" value={log.total_calories} onChange={(v) => updateField('total_calories', v)} unit="kcal" />
            <NumberInput label="탄수화물" value={log.carbs_g} onChange={(v) => updateField('carbs_g', v)} unit="g" />
            <NumberInput label="단백질" value={log.protein_g} onChange={(v) => updateField('protein_g', v)} unit="g" />
            <NumberInput label="지방" value={log.fat_g} onChange={(v) => updateField('fat_g', v)} unit="g" />
          </div>
          <div className="w-2/3 flex items-center justify-center">
            <MacroDonutChart
              calories={log.total_calories}
              carbs={log.carbs_g}
              protein={log.protein_g}
              fat={log.fat_g}
            />
          </div>
        </div>
      </Section>

      {/* 영양제 체크리스트 */}
      <Section title="영양제">
        <div className="grid grid-cols-2 gap-2">
          {SUPPLEMENTS.map(name => (
            <button
              key={name}
              onClick={() => toggleSupplement(name)}
              className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition-colors ${
                checkedSupps.has(name)
                  ? 'bg-success/10 text-success border border-success/30'
                  : 'bg-background border border-border text-text-secondary'
              }`}
            >
              <span className={`w-4 h-4 rounded border flex items-center justify-center flex-shrink-0 ${
                checkedSupps.has(name) ? 'bg-success border-success text-white' : 'border-border'
              }`}>
                {checkedSupps.has(name) && (
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                )}
              </span>
              {name}
            </button>
          ))}
        </div>
      </Section>

      {/* 수분 + 메모 */}
      <Section title="추가">
        <div className="space-y-3">
          <WaterCups value={log.water_liters} onChange={(v) => updateField('water_liters', v)} />
          <div>
            <label className="text-xs text-text-secondary">메모</label>
            <textarea
              placeholder="자유 메모"
              value={log.memo ?? ''}
              onChange={(e) => updateField('memo', e.target.value || null)}
              rows={3}
              className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-background mt-1 resize-none"
            />
          </div>
        </div>
      </Section>

      {/* Kakao share */}
      {log.id && <KakaoShareText log={log} />}
    </div>
  )
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-surface border border-border rounded-xl p-4">
      {title && <p className="text-sm font-medium mb-3">{title}</p>}
      {children}
    </div>
  )
}

function formatSleepHours(hours: number): string {
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  if (m === 0) return `${h}시간`
  return `${h}시간 ${m}분`
}

const HOURS = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))
const MINUTES = Array.from({ length: 12 }, (_, i) => String(i * 5).padStart(2, '0'))

function TimeInput24({
  label,
  value,
  onChange,
}: {
  label: string
  value: string | null
  onChange: (v: string | null) => void
}) {
  const [h, m] = (value ?? '').split(':')
  const hour = h ?? ''
  const min = m ?? ''

  function update(newH: string, newM: string) {
    if (!newH && !newM) { onChange(null); return }
    onChange(`${newH.padStart(2, '0')}:${newM.padStart(2, '0')}`)
  }

  return (
    <div>
      <label className="text-xs text-text-secondary">{label}</label>
      <div className="flex items-center justify-center gap-1 mt-1">
        <select
          value={hour}
          onChange={(e) => update(e.target.value, min || '00')}
          className="flex-1 border border-border rounded-lg px-2 py-2 text-sm bg-background text-center appearance-none [text-align-last:center]"
        >
          <option value="">시</option>
          {HOURS.map(h => <option key={h} value={h}>{h}</option>)}
        </select>
        <span className="text-sm font-medium">:</span>
        <select
          value={min}
          onChange={(e) => update(hour || '00', e.target.value)}
          className="flex-1 border border-border rounded-lg px-2 py-2 text-sm bg-background text-center appearance-none [text-align-last:center]"
        >
          <option value="">분</option>
          {MINUTES.map(m => <option key={m} value={m}>{m}</option>)}
        </select>
      </div>
    </div>
  )
}

function WaterCups({
  value,
  onChange,
}: {
  value: number | null
  onChange: (v: number | null) => void
}) {
  const cups = Math.round((value ?? 0) / 0.25)

  function toggle(index: number) {
    const clicked = index + 1
    const newCups = cups === clicked ? clicked - 1 : clicked
    onChange(newCups > 0 ? newCups * 0.25 : null)
  }

  return (
    <div>
      <label className="text-xs text-text-secondary">수분 섭취량</label>
      <div className="flex items-center gap-2 mt-2 flex-wrap">
        {[0, 1, 2, 3, 4, 5, 6, 7].map(i => {
          const filled = i < cups
          return (
            <button key={i} onClick={() => toggle(i)} className="flex flex-col items-center gap-1">
              <svg width="26" height="32" viewBox="0 0 38 48" fill="none">
                {/* Shadow */}
                <ellipse cx="19" cy="46" rx="10" ry="2" fill={filled ? '#BFDBFE' : '#E5E7EB'} opacity="0.5" />
                {/* Cup body - rounded tumbler */}
                <path d="M8 10 C8 8, 9 7, 11 7 L27 7 C29 7, 30 8, 30 10 L28 38 C28 41, 26 43, 23 43 L15 43 C12 43, 10 41, 10 38 Z"
                  fill={filled ? '#DBEAFE' : '#F5F5F5'}
                  stroke={filled ? '#60A5FA' : '#D1D5DB'}
                  strokeWidth="1.5"
                />
                {/* Water fill with wave */}
                {filled && (
                  <>
                    <path d="M10 20 C13 17, 16 23, 19 20 C22 17, 25 23, 28 20 L27 38 C27 40, 25 42, 23 42 L15 42 C13 42, 11 40, 11 38 Z"
                      fill="#60A5FA" opacity="0.45"
                    />
                    <path d="M10 20 C13 17, 16 23, 19 20 C22 17, 25 23, 28 20 L27 38 C27 40, 25 42, 23 42 L15 42 C13 42, 11 40, 11 38 Z"
                      fill="#3B82F6" opacity="0.25"
                    />
                  </>
                )}
                {/* Lid */}
                <rect x="6" y="4" width="26" height="5" rx="2.5"
                  fill={filled ? '#93C5FD' : '#E5E7EB'}
                  stroke={filled ? '#60A5FA' : '#D1D5DB'}
                  strokeWidth="1.5"
                />
                {/* Straw */}
                <rect x="22" y="0" width="2.5" height="12" rx="1.25"
                  fill={filled ? '#60A5FA' : '#D1D5DB'}
                />
                {/* Shine */}
                <path d="M13 12 L13 30" stroke="white" strokeWidth="1.5" strokeLinecap="round" opacity="0.5" />
              </svg>
              <span className="text-[9px] text-text-secondary">250</span>
            </button>
          )
        })}
        <span className="text-sm font-medium ml-1 text-success">
          {(cups * 0.25).toFixed(2)}L
        </span>
      </div>
    </div>
  )
}

function NumberInput({
  label,
  value,
  onChange,
  unit,
}: {
  label: string
  value: number | null
  onChange: (v: number | null) => void
  unit?: string
}) {
  return (
    <div>
      <label className="text-xs text-text-secondary">{label}</label>
      <div className="flex items-center gap-1 mt-1">
        <input
          type="number"
          inputMode="decimal"
          placeholder="0"
          value={value ?? ''}
          onChange={(e) => onChange(e.target.value ? parseFloat(e.target.value) : null)}
          className="w-full border border-border rounded-lg px-2 py-1.5 text-sm bg-background"
        />
        {unit && <span className="text-[10px] text-text-secondary flex-shrink-0">{unit}</span>}
      </div>
    </div>
  )
}
