# Acceleration Block 식단 횟수 + 저강도 유산소 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 5~8주차 Acceleration Block에 식단 횟수 카드 토글 + 저강도 유산소 체크/메모 기능 추가

**Architecture:** Supabase에 meal_slot_configs, cardio_logs 테이블 추가. Daily 페이지에 식단 횟수 섹션, Workout 페이지에 저강도 유산소 섹션 추가. 두 기능 모두 week_number >= 5일 때만 노출.

**Tech Stack:** Next.js 16 (App Router), TypeScript, Tailwind CSS v4, Supabase

---

### Task 1: Supabase 테이블 생성

**Files:**
- Create: `supabase/migration-acceleration-block.sql`

**Step 1: SQL 작성**

```sql
-- meal_slot_configs: 식단 슬롯 설정 이력
create table if not exists meal_slot_configs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  effective_date date not null,
  slot_count int not null default 4,
  created_at timestamptz default now(),
  unique(user_id, effective_date)
);

-- daily_logs에 식단 컬럼 추가
alter table daily_logs add column if not exists meal_completed int;
alter table daily_logs add column if not exists meal_total int;

-- cardio_logs: 저강도 유산소 기록
create table if not exists cardio_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  date date not null,
  completed boolean default false,
  memo text,
  created_at timestamptz default now(),
  unique(user_id, date)
);

-- RLS 정책
alter table meal_slot_configs enable row level security;
create policy "meal_slot_configs_all" on meal_slot_configs for all using (true);

alter table cardio_logs enable row level security;
create policy "cardio_logs_all" on cardio_logs for all using (true);
```

**Step 2: Supabase Dashboard에서 SQL 실행**

**Step 3: Commit**
```bash
git add supabase/migration-acceleration-block.sql
git commit -m "db: meal_slot_configs, cardio_logs 테이블 + daily_logs 컬럼 추가"
```

---

### Task 2: API 레이어 — meal_slot_configs + daily_logs 확장

**Files:**
- Create: `src/lib/api/meal-slots.ts`
- Modify: `src/lib/api/daily-logs.ts` — DailyLog 인터페이스에 meal_completed, meal_total 추가

**Step 1: meal-slots.ts 작성**

```typescript
import { supabase } from '../supabase'

export interface MealSlotConfig {
  id?: string
  user_id: string
  effective_date: string
  slot_count: number
}

// 특정 날짜에 적용되는 슬롯 수 조회 (effective_date <= date 중 가장 최근)
export async function getMealSlotCount(date: string, userId: string): Promise<number> {
  const { data } = await supabase
    .from('meal_slot_configs')
    .select('slot_count')
    .eq('user_id', userId)
    .lte('effective_date', date)
    .order('effective_date', { ascending: false })
    .limit(1)
    .single()
  return data?.slot_count ?? 0
}

// 슬롯 설정 추가/업데이트 (해당 날짜에 새 config)
export async function upsertMealSlotConfig(userId: string, date: string, slotCount: number) {
  const { data, error } = await supabase
    .from('meal_slot_configs')
    .upsert(
      { user_id: userId, effective_date: date, slot_count: slotCount },
      { onConflict: 'user_id,effective_date' }
    )
    .select()
    .single()
  if (error) throw error
  return data
}
```

**Step 2: daily-logs.ts DailyLog 인터페이스 확장**

`src/lib/api/daily-logs.ts`의 DailyLog 인터페이스에 추가:
```typescript
meal_completed: number | null
meal_total: number | null
```

**Step 3: Commit**
```bash
git add src/lib/api/meal-slots.ts src/lib/api/daily-logs.ts
git commit -m "feat: meal-slots API + daily_logs 식단 필드 확장"
```

---

### Task 3: API 레이어 — cardio_logs

**Files:**
- Create: `src/lib/api/cardio-logs.ts`

**Step 1: cardio-logs.ts 작성**

```typescript
import { supabase } from '../supabase'

export interface CardioLog {
  id?: string
  user_id: string
  date: string
  completed: boolean
  memo: string | null
}

// 특정 날짜 cardio_log 조회
export async function getCardioLog(date: string, userId: string): Promise<CardioLog | null> {
  const { data } = await supabase
    .from('cardio_logs')
    .select('*')
    .eq('user_id', userId)
    .eq('date', date)
    .single()
  return data
}

// upsert cardio_log
export async function upsertCardioLog(log: CardioLog) {
  const { data, error } = await supabase
    .from('cardio_logs')
    .upsert(log, { onConflict: 'user_id,date' })
    .select()
    .single()
  if (error) throw error
  return data
}

// 주간 누적 카운트 (월~일 범위)
export async function getWeeklyCardioCount(startDate: string, endDate: string, userId: string): Promise<number> {
  const { count } = await supabase
    .from('cardio_logs')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('completed', true)
    .gte('date', startDate)
    .lte('date', endDate)
  return count ?? 0
}
```

**Step 2: Commit**
```bash
git add src/lib/api/cardio-logs.ts
git commit -m "feat: cardio-logs API 레이어"
```

---

### Task 4: Daily 페이지 — 식단 횟수 섹션 UI

**Files:**
- Modify: `src/app/daily/page.tsx`

**위치:** 기존 "당/가공식품" 섹션 아래, "식단" 섹션 위 (약 line 266-269 사이)

**Step 1: State 추가** (상단 state 영역)
```typescript
const [mealSlotCount, setMealSlotCount] = useState(0)
const [mealChecked, setMealChecked] = useState<boolean[]>([])
```

**Step 2: loadData에서 meal slot config + meal_completed 로드**
- `getMealSlotCount(date, userId)` → `mealSlotCount` 설정
- `log.meal_completed` → `mealChecked` 배열 복원 (completed 수만큼 앞에서부터 true)
- week_number 확인: `weekInfo?.week_number >= 5`

**Step 3: 식단 횟수 섹션 JSX**
```tsx
{weekInfo?.week_number >= 5 && mealSlotCount > 0 && (
  <Section title="식단 횟수" right={
    <button onClick={handleAddMealSlot} className="text-xs text-accent font-medium">+추가</button>
  }>
    <div className="flex flex-wrap gap-2">
      {mealChecked.map((checked, i) => (
        <button
          key={i}
          onClick={() => toggleMealSlot(i)}
          className={`w-12 h-10 rounded-lg border-2 flex items-center justify-center transition-colors ${
            checked ? 'border-accent bg-accent/10 text-accent' : 'border-border bg-surface text-text-secondary'
          }`}
        >
          {checked ? '✓' : i + 1}
        </button>
      ))}
    </div>
    <p className="text-xs text-text-secondary mt-2">
      {mealChecked.filter(Boolean).length} / {mealSlotCount}
    </p>
  </Section>
)}
```

**Step 4: 핸들러 함수**
- `handleAddMealSlot`: mealSlotCount + 1로 upsertMealSlotConfig, state 업데이트
- `toggleMealSlot(i)`: mealChecked 토글, meal_completed + meal_total 자동 저장 (autoSave)

**Step 5: Commit**
```bash
git add src/app/daily/page.tsx
git commit -m "feat: 식단 횟수 카드 토글 UI (5주차~)"
```

---

### Task 5: Workout 페이지 — 저강도 유산소 섹션

**Files:**
- Modify: `src/app/workout/page.tsx`

**위치:** 박스와드(WOD) 섹션 위, sections.map() 바로 전

**Step 1: State + 데이터 로드 추가**
```typescript
const [cardioLog, setCardioLog] = useState<CardioLog | null>(null)
const [cardioMemo, setCardioMemo] = useState('')
const [showCardioMemo, setShowCardioMemo] = useState(false)
```

- `loadData()`에서: `getCardioLog(date, userId)` 호출, week_number >= 5일 때만
- cardioLog 존재하면 state 세팅

**Step 2: 저강도 유산소 섹션 JSX** (sections.map 바로 위)
```tsx
{weekInfo?.week_number >= 5 && selectedDay <= 5 && (
  <div className="bg-surface border border-border rounded-xl p-3 mb-3">
    <div className="flex items-center justify-between">
      <span className="text-sm font-medium">저강도 유산소</span>
      <div className="flex items-center gap-2">
        <button onClick={() => setShowCardioMemo(!showCardioMemo)}
          className="text-xs text-text-secondary">메모</button>
        <button onClick={handleCardioToggle}
          className={`w-8 h-8 rounded-lg border-2 flex items-center justify-center text-sm ${
            cardioLog?.completed ? 'border-accent bg-accent/10 text-accent' : 'border-border'
          }`}>
          {cardioLog?.completed ? '✓' : ''}
        </button>
      </div>
    </div>
    {showCardioMemo && (
      <textarea
        value={cardioMemo}
        onChange={(e) => { setCardioMemo(e.target.value); handleCardioMemoSave(e.target.value) }}
        placeholder="머신 종류, 시간 등"
        className="w-full mt-2 p-2 text-sm bg-background border border-border rounded-lg resize-none"
        rows={1}
      />
    )}
  </div>
)}
```

**Step 3: 핸들러 함수**
- `handleCardioToggle`: completed 토글 → upsertCardioLog
- `handleCardioMemoSave`: 800ms 디바운스 → upsertCardioLog

**Step 4: Commit**
```bash
git add src/app/workout/page.tsx
git commit -m "feat: 저강도 유산소 체크/메모 섹션 (5주차~, 운동탭)"
```

---

### Task 6: 카톡 공유 텍스트 업데이트

**Files:**
- Modify: `src/components/daily/KakaoShareText.tsx`

**Step 1: props 확장**
```typescript
interface Props {
  log: DailyLog
  weekNumber?: number
  weeklyCardioCount?: number  // 추가
}
```

**Step 2: 공유 텍스트에 식단 + 유산소 추가** (week_number >= 5일 때)
```typescript
const lines = [
  `${dateStr}`,
  `총 수면 시간 : ${sleepDisplay} (${sleepTimeShort} / ${wakeTimeShort})`,
  `운동 여부 : ${log.workout_done ? 'O' : 'X'}`,
  `식단 : ${log.sugar_processed || 'X'}`,
]
if (weekNumber && weekNumber >= 5) {
  // 당/가공식품 다음에 추가
  lines.push(`당/가공식품 섭취 여부 : ${log.sugar_processed || 'X'}`)
  lines.push(`식단 : ${log.meal_completed ?? 0}/${log.meal_total ?? 0}`)
  lines.push(`저강도 유산소 : ${weeklyCardioCount ?? 0}/2`)
}
```

**Step 3: Daily 페이지에서 weeklyCardioCount 전달**
- daily/page.tsx에서 `getWeeklyCardioCount()` 호출
- KakaoShareText에 prop으로 전달

**Step 4: Commit**
```bash
git add src/components/daily/KakaoShareText.tsx src/app/daily/page.tsx
git commit -m "feat: 카톡 공유에 식단/저강도유산소 포함 (5주차~)"
```

---

### Task 7: 통합 테스트 + 배포

**Step 1: 로컬 확인**
- Daily 페이지: 5주차 날짜(4/6)에서 식단 횟수 섹션 노출 확인
- +추가 → 카드 증가, 토글 동작, 이전 날짜 영향 없음
- Workout 페이지: 5주차 월~금에서 저강도 유산소 섹션 노출
- 체크/메모 동작, 카톡 공유 텍스트 반영

**Step 2: 4주차 날짜에서 미노출 확인**

**Step 3: git push 배포**
```bash
git push origin main
```
