# 운동 이력 검색 기능 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 운동 이름으로 과거 이력을 ILIKE 검색하여 주차/요일별 무게, sets/reps 정보를 카드 형태로 표시

**Architecture:** 운동 페이지에 돋보기 아이콘 추가 → 전체화면 모달에서 검색 input + 필터(전체/완료만) → Supabase ILIKE 쿼리로 workout_logs + weeks + workout_templates 조인 → 최신순 카드 리스트 렌더링

**Tech Stack:** Next.js App Router, Supabase JS client, Tailwind CSS v4

---

### Task 1: 검색 API 함수 추가

**Files:**
- Modify: `src/lib/api/workout-logs.ts`

**Step 1: API 함수 작성**

`workout-logs.ts` 하단에 추가:

```typescript
export async function searchWorkoutLogs(
  query: string,
  userId: string,
  completedOnly: boolean = true
) {
  let q = supabase
    .from('workout_logs')
    .select('*, weeks:date_week_lookup(*)')
    .eq('user_id', userId)
    .ilike('exercise_name', `%${query}%`)
    .order('date', { ascending: false })

  if (completedOnly) {
    q = q.eq('completed', true)
  }

  const { data, error } = await q
  if (error) throw error
  return data
}
```

> **주의:** Supabase에서 workout_logs → weeks 직접 조인이 안 됨 (FK가 없음). 대신 weeks를 별도로 가져와서 클라이언트에서 매칭하는 방식 사용.

실제 구현:

```typescript
export async function searchWorkoutLogs(
  query: string,
  userId: string,
  completedOnly: boolean = true
) {
  let q = supabase
    .from('workout_logs')
    .select('*')
    .eq('user_id', userId)
    .ilike('exercise_name', `%${query}%`)
    .order('date', { ascending: false })

  if (completedOnly) {
    q = q.eq('completed', true)
  }

  const { data, error } = await q
  if (error) throw error
  return data
}
```

**Step 2: 확인**

빌드 에러 없는지 확인: `npm run build` (또는 dev 서버에서 import 확인)

**Step 3: Commit**

```bash
git add src/lib/api/workout-logs.ts
git commit -m "feat: add searchWorkoutLogs API function"
```

---

### Task 2: ExerciseSearchModal 컴포넌트 생성

**Files:**
- Create: `src/components/workout/ExerciseSearchModal.tsx`

**Step 1: 모달 컴포넌트 작성**

```tsx
'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { searchWorkoutLogs, WorkoutLog } from '@/lib/api/workout-logs'
import { getWeeks } from '@/lib/api/workout-templates'

interface Week {
  id: string
  week_number: number
  phase: string
  start_date: string
  end_date: string
}

interface SearchResult extends WorkoutLog {
  weekNumber?: number
  dayLabel?: string
  template?: {
    sets: string | null
    reps: string | null
    rest_seconds: number | null
  }
}

const DAY_LABELS = ['일', '월', '화', '수', '목', '금', '토']

export default function ExerciseSearchModal({
  userId,
  onClose,
}: {
  userId: string
  onClose: () => void
}) {
  const [query, setQuery] = useState('')
  const [completedOnly, setCompletedOnly] = useState(true)
  const [results, setResults] = useState<SearchResult[]>([])
  const [loading, setLoading] = useState(false)
  const [weeks, setWeeks] = useState<Week[]>([])
  const inputRef = useRef<HTMLInputElement>(null)
  const debounceRef = useRef<NodeJS.Timeout | null>(null)

  // Load weeks once
  useEffect(() => {
    getWeeks().then(setWeeks)
  }, [])

  // Auto focus
  useEffect(() => {
    setTimeout(() => inputRef.current?.focus(), 100)
  }, [])

  const doSearch = useCallback(async (q: string, completed: boolean) => {
    if (q.trim().length === 0) {
      setResults([])
      return
    }
    setLoading(true)
    try {
      const logs = await searchWorkoutLogs(q.trim(), userId, completed)

      // template_id가 있는 로그의 템플릿 정보를 일괄 조회
      const templateIds = [...new Set((logs || []).map(l => l.template_id).filter(Boolean))]
      let templateMap: Record<string, { sets: string | null; reps: string | null; rest_seconds: number | null }> = {}
      if (templateIds.length > 0) {
        const { data: templates } = await (await import('@/lib/supabase')).supabase
          .from('workout_templates')
          .select('id, sets, reps, rest_seconds')
          .in('id', templateIds)
        if (templates) {
          templateMap = Object.fromEntries(templates.map(t => [t.id, { sets: t.sets, reps: t.reps, rest_seconds: t.rest_seconds }]))
        }
      }

      const enriched: SearchResult[] = (logs || []).map(log => {
        const logDate = new Date(log.date + 'T00:00:00')
        const week = weeks.find(w => log.date >= w.start_date && log.date <= w.end_date)
        const dayOfWeek = logDate.getDay()
        const month = logDate.getMonth() + 1
        const day = logDate.getDate()
        return {
          ...log,
          weekNumber: week?.week_number,
          dayLabel: `${month}/${day}(${DAY_LABELS[dayOfWeek]})`,
          template: log.template_id ? templateMap[log.template_id] : undefined,
        }
      })
      setResults(enriched)
    } catch (e) {
      console.error('Search error:', e)
    } finally {
      setLoading(false)
    }
  }, [userId, weeks])

  // Debounced search
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => {
      doSearch(query, completedOnly)
    }, 400)
    return () => { if (debounceRef.current) clearTimeout(debounceRef.current) }
  }, [query, completedOnly, doSearch])

  return (
    <div className="fixed inset-0 z-[100] bg-background flex flex-col">
      {/* Header */}
      <div className="flex items-center gap-2 px-4 py-3 border-b border-border">
        <div className="flex-1 relative">
          <input
            ref={inputRef}
            type="text"
            placeholder="운동 이름 검색..."
            value={query}
            onChange={e => setQuery(e.target.value)}
            className="w-full border border-border rounded-lg pl-9 pr-3 py-2 text-sm bg-surface"
          />
          <svg className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
        </div>
        <button onClick={onClose} className="w-8 h-8 flex items-center justify-center text-text-secondary">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>

      {/* Filter */}
      <div className="flex gap-2 px-4 py-2 border-b border-border">
        <button
          onClick={() => setCompletedOnly(false)}
          className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
            !completedOnly ? 'bg-accent text-white' : 'bg-surface border border-border text-text-secondary'
          }`}
        >전체</button>
        <button
          onClick={() => setCompletedOnly(true)}
          className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
            completedOnly ? 'bg-accent text-white' : 'bg-surface border border-border text-text-secondary'
          }`}
        >완료만</button>
      </div>

      {/* Results */}
      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
        {loading ? (
          <div className="text-center text-text-secondary text-sm py-8">검색 중...</div>
        ) : query.trim() === '' ? (
          <div className="text-center text-text-secondary text-sm py-8">운동 이름을 입력하세요</div>
        ) : results.length === 0 ? (
          <div className="text-center text-text-secondary text-sm py-8">검색 결과가 없습니다</div>
        ) : (
          results.map(r => {
            const isIncomplete = !r.completed
            return (
              <div
                key={r.id}
                className={`rounded-xl border p-3 ${
                  isIncomplete
                    ? 'border-border/50 text-text-secondary/50'
                    : 'border-border bg-surface'
                }`}
              >
                <div className={`text-xs font-medium mb-1 ${isIncomplete ? 'text-text-secondary/50' : 'text-accent'}`}>
                  {r.weekNumber ? `Week ${r.weekNumber}` : '—'} · {r.dayLabel}
                </div>
                <div className="flex items-center gap-2">
                  {r.section && (
                    <span className={`text-xs font-bold ${isIncomplete ? 'text-text-secondary/40' : 'text-accent/70'}`}>{r.section}.</span>
                  )}
                  <span className={`text-sm font-medium ${isIncomplete ? '' : 'text-foreground'}`}>{r.exercise_name}</span>
                  {r.weight_lb != null && (
                    <span className={`text-sm ${isIncomplete ? '' : 'text-foreground'}`}>· {r.weight_lb} {r.weight_unit}</span>
                  )}
                  {r.completed ? (
                    <span className="text-success text-xs">✓</span>
                  ) : (
                    <span className="text-text-secondary/40 text-xs">✗</span>
                  )}
                </div>
                {r.template && (r.template.sets || r.template.reps) && (
                  <div className={`text-[11px] mt-1 ${isIncomplete ? 'text-text-secondary/30' : 'text-text-secondary'}`}>
                    {r.template.sets && `${r.template.sets}세트`}
                    {r.template.reps && ` × ${r.template.reps}`}
                    {r.template.rest_seconds && ` · rest ${r.template.rest_seconds}s`}
                  </div>
                )}
                {r.memo && (
                  <div className={`text-[11px] mt-1 italic ${isIncomplete ? 'text-text-secondary/30' : 'text-text-secondary'}`}>
                    {r.memo}
                  </div>
                )}
              </div>
            )
          })
        )}
      </div>
    </div>
  )
}
```

**Step 2: 확인**

dev 서버에서 컴포넌트 문법 에러 없는지 확인

**Step 3: Commit**

```bash
git add src/components/workout/ExerciseSearchModal.tsx
git commit -m "feat: add ExerciseSearchModal component"
```

---

### Task 3: 운동 페이지에 돋보기 아이콘 + 모달 연동

**Files:**
- Modify: `src/app/workout/page.tsx`

**Step 1: import 추가 & state 추가**

파일 상단 import에 추가:
```tsx
import ExerciseSearchModal from '@/components/workout/ExerciseSearchModal'
```

state 추가 (gifModalExercise 근처):
```tsx
const [searchOpen, setSearchOpen] = useState(false)
```

**Step 2: Progress 영역 수정 (5/7 완료 → 왼쪽, 돋보기 → 오른쪽)**

기존 코드 (약 353-358행):
```tsx
{totalSections > 0 && (
  <div className="text-xs text-text-secondary text-right">
    {completedSections}/{totalSections} 완료
  </div>
)}
```

변경:
```tsx
{totalSections > 0 && (
  <div className="flex items-center justify-between">
    <span className="text-xs text-text-secondary">
      {completedSections}/{totalSections} 완료
    </span>
    <button
      onClick={() => setSearchOpen(true)}
      className="w-8 h-8 flex items-center justify-center rounded-lg text-text-secondary hover:text-accent transition-colors"
      title="운동 이력 검색"
    >
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
    </button>
  </div>
)}
```

**Step 3: 모달 렌더링 추가**

`gifModalExercise` 모달 근처 (파일 하단)에 추가:
```tsx
{searchOpen && (
  <ExerciseSearchModal
    userId={userId}
    onClose={() => setSearchOpen(false)}
  />
)}
```

**Step 4: 확인**

dev 서버에서 동작 확인:
1. 돋보기 아이콘이 progress 오른쪽에 표시되는지
2. 클릭 시 전체화면 모달 열리는지
3. 운동 이름 검색 시 결과가 카드로 표시되는지
4. 전체/완료만 필터 동작 확인
5. 미완료 항목 연한 회색 처리 확인
6. X 버튼으로 닫기

**Step 5: Commit**

```bash
git add src/app/workout/page.tsx
git commit -m "feat: integrate exercise search modal into workout page"
```
