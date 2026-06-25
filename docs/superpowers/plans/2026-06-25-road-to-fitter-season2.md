# ROAD TO FITTER 시즌2 피봇 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 15주 바디프로필 트래커(시즌1)를 멤버용 추가운동 앱 "ROAD TO FITTER"(시즌2)로 피봇한다 — 2계층 운동 라이브러리(공용 요일별 + 개인) · 날짜별 운동 뷰를 도입하고, 식단/수면/물/영양제/유산소/D-day를 미노출(보관)한다.

**Architecture:** 신규 테이블 `workouts`(공용·개인 운동 라이브러리) + `workout_exercises`(운동 내 동작), 기존 `workout_logs`에 `workout_exercise_id` 컬럼 1개 추가로 가볍게 피봇. 시즌1 데이터(weeks/workout_templates/cardio/meal/식단·수면 컬럼)는 삭제하지 않고 쿼리에서 분리해 보관. 체중·1RM·운동 검색은 시즌 무관 연속 노출. 운동 페이지는 "주차 네비+요일 그리드"에서 "날짜 네비+라이브러리 담기/생성"으로 전면 개편하되, 기존 그룹 렌더링·자동저장 디바운스 로직은 재사용.

**Tech Stack:** Next.js 16.1.6 (App Router) · React 19 · TypeScript 5 (strict) · Tailwind CSS v4 · Supabase JS 2.98 (anon 키) · recharts 3.8.

## Global Constraints

- **테스트 하네스 없음** → 각 태스크 검증 게이트 = `npm run build`(타입체크 포함) + `npm run lint` + 개발서버(`npm run dev`) 수동 확인. 자동 테스트 작성 단계 없음.
- **DB 변경은 raw SQL** 파일을 `supabase/`에 작성 → Supabase SQL 에디터(또는 anon 키 REST POST)로 **수동 적용**. 정식 마이그레이션 툴링 없음.
- **Supabase 접근**: `import { supabase } from '@/lib/supabase'` (anon 키). 경로 alias `@/*` → `./src/*`.
- **신규 테이블 RLS**: 기존 테이블과 동일하게 anon/authenticated에 select/insert/update/delete 전부 허용(친구 그룹용, 강한 보안 아님). 개인 운동 비공개는 **앱 쿼리 레벨**(`owner_user_id is null or owner_user_id = <user>`)로만 보장.
- **시맨틱 테마 토큰만 사용**: 신규/개편 컴포넌트는 하드코딩 hex나 `bg-blue-500` 류 대신 `bg-surface`, `text-accent`, `bg-accent-light`, `border-border`, `text-secondary` 등 `globals.css` 토큰 사용 (시즌2 비주얼 리디자인 대비). 폰트는 `--font-sans` 토큰.
- **시즌1 데이터 삭제 금지**: weeks, workout_templates, cardio_logs, meal_slot_configs, daily_logs의 식단/수면 컬럼은 보관(미쿼리). workout_logs 기존 행 유지.
- **기존 로그인 보존**: `auth.ts`의 localStorage `bp-*` 키는 그대로 유지(개명 금지) — 기존 유저 자동 로그인이 깨지지 않게.
- **커밋 컨벤션**: 한국어 메시지, 끝에 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- **앱명**: "ROAD TO FITTER". 기존 "2026 ZEST BP Tracker" / "BP Tracker" / "바디프로필 준비 트래커" 전부 교체.

## 핵심 데이터 모델 (전 태스크 공유)

```typescript
// src/lib/api/workouts.ts 에서 정의·export
export interface Workout {
  id: string
  title: string
  owner_user_id: string | null   // null = 공용(전원), 값 있으면 개인(본인만)
  default_weekday: number | null // 공용 전용: 1=월 .. 5=금, null=요일 매핑 없음
  notes: string | null
  archived: boolean
  sort_order: number
  created_by: string | null
  created_at?: string
}

export interface WorkoutExercise {
  id: string
  workout_id: string
  section: string | null
  exercise_name: string
  sets: string | null
  reps: string | null
  notes: string | null
  sort_order: number
}
```

`WorkoutLog`(기존, `src/lib/api/workout-logs.ts`)에 `workout_exercise_id: string | null` 추가. 시즌2 로그는 이 값이 채워지고 `template_id`는 null, `is_custom`은 false.

---

## Phase A — 데이터 모델 + API 기반

### Task A1: DB 마이그레이션 SQL 작성·적용

**Files:**
- Create: `supabase/migration-roadtofitter-season2.sql`

**Interfaces:**
- Produces: 테이블 `workouts`, `workout_exercises`; 컬럼 `workout_logs.workout_exercise_id`. 이후 모든 태스크가 의존.

- [ ] **Step 1: 마이그레이션 SQL 작성**

`supabase/migration-roadtofitter-season2.sql`:

```sql
-- ROAD TO FITTER 시즌2: 운동 라이브러리(공용+개인) + workout_logs 연결 컬럼
-- 시즌1 테이블은 건드리지 않는다.

-- 1) 운동 라이브러리
create table if not exists workouts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  owner_user_id uuid references users(id) on delete cascade,   -- null = 공용
  default_weekday int check (default_weekday between 1 and 5), -- 공용 요일(1=월..5=금)
  notes text,
  archived boolean not null default false,
  sort_order int not null default 0,
  created_by uuid references users(id),
  created_at timestamptz not null default now()
);

-- 2) 운동 안의 동작들
create table if not exists workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references workouts(id) on delete cascade,
  section text,
  exercise_name text not null,
  sets text,
  reps text,
  notes text,
  sort_order int not null default 0
);

-- 3) 결과 로그 ↔ 동작 연결 (시즌1 template_id와 공존, 둘 다 nullable)
alter table workout_logs
  add column if not exists workout_exercise_id uuid references workout_exercises(id) on delete set null;

-- 4) 조회 인덱스
create index if not exists idx_workouts_owner on workouts(owner_user_id);
create index if not exists idx_workouts_weekday on workouts(default_weekday) where owner_user_id is null;
create index if not exists idx_workout_exercises_workout on workout_exercises(workout_id);
create index if not exists idx_workout_logs_we on workout_logs(workout_exercise_id);

-- 5) RLS — 기존 테이블과 동일하게 전체 허용 (anon/authenticated)
alter table workouts enable row level security;
alter table workout_exercises enable row level security;

drop policy if exists "rtf_workouts_all" on workouts;
create policy "rtf_workouts_all" on workouts
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "rtf_workout_exercises_all" on workout_exercises;
create policy "rtf_workout_exercises_all" on workout_exercises
  for all to anon, authenticated using (true) with check (true);
```

- [ ] **Step 2: Supabase에 적용**

Supabase 대시보드 SQL 에디터에 위 SQL 붙여넣고 실행 (또는 사용자에게 적용 요청). `users` 테이블 PK가 `id uuid`임을 전제 — 다르면 FK 타입 맞춰 조정.

- [ ] **Step 3: 적용 확인**

SQL 에디터에서:
```sql
select column_name from information_schema.columns where table_name = 'workout_logs' and column_name = 'workout_exercise_id';
select count(*) from workouts;          -- 0
select count(*) from workout_exercises; -- 0
```
Expected: `workout_exercise_id` 1행 반환, 두 count 모두 0(에러 없이).

- [ ] **Step 4: Commit**

```bash
git add supabase/migration-roadtofitter-season2.sql
git commit -m "feat(db): 시즌2 운동 라이브러리 테이블 + workout_logs.workout_exercise_id 마이그레이션

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task A2: `workout-logs.ts` — workout_exercise_id 반영 + 날짜 조회 nested select + addWorkoutToDate

**Files:**
- Modify: `src/lib/api/workout-logs.ts`

**Interfaces:**
- Consumes: `supabase` from `@/lib/supabase`; 기존 `WorkoutLog`, `batchInsertWorkoutLogs`.
- Produces:
  - `WorkoutLog`에 `workout_exercise_id: string | null` 필드.
  - `getWorkoutLogsWithWorkout(date: string, userId: string): Promise<WorkoutLogJoined[]>` — workout 그룹 정보 포함.
  - `addWorkoutToDate(userId: string, date: string, workoutId: string): Promise<WorkoutLog[]>`.
  - type `WorkoutLogJoined = WorkoutLog & { workout?: { workout_id: string; title: string; owner_user_id: string | null } | null }`.

- [ ] **Step 1: `WorkoutLog` 인터페이스에 컬럼 추가**

`src/lib/api/workout-logs.ts`의 `WorkoutLog` 인터페이스에 한 줄 추가:
```typescript
  workout_exercise_id: string | null
```
(기존 `template_id: string | null` 아래에 둔다.) `batchInsertWorkoutLogs`가 `Omit<WorkoutLog,'id'>[]`를 받으므로 호출부에서 이 필드 포함 가능.

- [ ] **Step 2: nested select 조회 함수 추가**

파일 끝에 추가:
```typescript
export type WorkoutLogJoined = WorkoutLog & {
  workout?: { workout_id: string; title: string; owner_user_id: string | null } | null
}

export async function getWorkoutLogsWithWorkout(
  date: string,
  userId: string,
): Promise<WorkoutLogJoined[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select(
      'id, user_id, date, template_id, workout_exercise_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo, custom_sets, custom_reps, ' +
        'workout_exercises ( workout_id, workouts ( title, owner_user_id ) )',
    )
    .eq('date', date)
    .eq('user_id', userId)
  if (error) throw error
  return (data ?? []).map((row: Record<string, unknown>) => {
    const we = row.workout_exercises as
      | { workout_id: string; workouts?: { title: string; owner_user_id: string | null } | null }
      | null
    const { workout_exercises, ...rest } = row as Record<string, unknown>
    void workout_exercises
    return {
      ...(rest as unknown as WorkoutLog),
      workout: we
        ? { workout_id: we.workout_id, title: we.workouts?.title ?? '', owner_user_id: we.workouts?.owner_user_id ?? null }
        : null,
    }
  })
}
```

- [ ] **Step 3: addWorkoutToDate 추가**

```typescript
import { getWorkoutExercises } from './workouts' // 파일 상단 import에 추가

export async function addWorkoutToDate(
  userId: string,
  date: string,
  workoutId: string,
): Promise<WorkoutLog[]> {
  const exercises = await getWorkoutExercises(workoutId)
  const rows: Omit<WorkoutLog, 'id'>[] = exercises.map((ex) => ({
    user_id: userId,
    date,
    template_id: null,
    workout_exercise_id: ex.id,
    is_custom: false,
    exercise_name: ex.exercise_name,
    section: ex.section,
    completed: false,
    weight_lb: null,
    weight_unit: 'lb',
    memo: null,
    custom_sets: ex.sets,
    custom_reps: ex.reps,
  }))
  if (rows.length === 0) return []
  return batchInsertWorkoutLogs(rows)
}
```
(`getWorkoutExercises`는 Task A3에서 생성 — A3을 먼저 구현하거나, A3와 A2를 한 묶음으로 진행. 순서상 A3 → A2 권장이지만 분리 가능하면 import만 먼저.)

- [ ] **Step 4: 빌드·린트 검증**

Run: `npm run build && npm run lint`
Expected: 컴파일 성공, 신규 함수 타입 에러 없음.

- [ ] **Step 5: Commit**

```bash
git add src/lib/api/workout-logs.ts
git commit -m "feat(api): workout_logs에 workout_exercise_id + nested select 조회/addWorkoutToDate

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task A3: `workouts.ts` 신규 API

**Files:**
- Create: `src/lib/api/workouts.ts`

**Interfaces:**
- Consumes: `supabase` from `@/lib/supabase`.
- Produces (이후 운동 페이지·addWorkoutToDate가 의존):
  - types `Workout`, `WorkoutExercise` (위 "핵심 데이터 모델"과 동일).
  - `getLibrary(userId: string): Promise<Workout[]>`
  - `getDefaultWorkoutsForWeekday(weekday: number): Promise<Workout[]>`
  - `getWorkoutExercises(workoutId: string): Promise<WorkoutExercise[]>`
  - `createPersonalWorkout(userId: string, title: string, exercises: Omit<WorkoutExercise,'id'|'workout_id'>[]): Promise<Workout>`
  - `updatePersonalWorkout(workoutId: string, title: string, exercises: Omit<WorkoutExercise,'id'|'workout_id'>[]): Promise<void>`
  - `archiveWorkout(workoutId: string): Promise<void>`
  - `getWorkoutProgress(userId: string, workoutId: string): Promise<{ date: string; exercise_name: string; weight_lb: number | null; weight_unit: 'lb'|'kg'; completed: boolean }[]>`

- [ ] **Step 1: 파일 작성**

`src/lib/api/workouts.ts`:
```typescript
import { supabase } from '@/lib/supabase'

export interface Workout {
  id: string
  title: string
  owner_user_id: string | null
  default_weekday: number | null
  notes: string | null
  archived: boolean
  sort_order: number
  created_by: string | null
  created_at?: string
}

export interface WorkoutExercise {
  id: string
  workout_id: string
  section: string | null
  exercise_name: string
  sets: string | null
  reps: string | null
  notes: string | null
  sort_order: number
}

// 라이브러리: 공용(owner null) + 본인 개인. 공용 먼저(owner_user_id nulls first), 그다음 sort_order.
export async function getLibrary(userId: string): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .or(`owner_user_id.is.null,owner_user_id.eq.${userId}`)
    .eq('archived', false)
    .order('owner_user_id', { ascending: true, nullsFirst: true })
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

// 그 요일에 매핑된 공용 기본운동
export async function getDefaultWorkoutsForWeekday(weekday: number): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .is('owner_user_id', null)
    .eq('default_weekday', weekday)
    .eq('archived', false)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}

export async function getWorkoutExercises(workoutId: string): Promise<WorkoutExercise[]> {
  const { data, error } = await supabase
    .from('workout_exercises')
    .select('*')
    .eq('workout_id', workoutId)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as WorkoutExercise[]
}

export async function createPersonalWorkout(
  userId: string,
  title: string,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<Workout> {
  const { data: w, error: we } = await supabase
    .from('workouts')
    .insert({ title, owner_user_id: userId, created_by: userId, default_weekday: null })
    .select()
    .single()
  if (we) throw we
  const workout = w as Workout
  if (exercises.length > 0) {
    const rows = exercises.map((ex, i) => ({ ...ex, workout_id: workout.id, sort_order: ex.sort_order ?? i }))
    const { error: ee } = await supabase.from('workout_exercises').insert(rows)
    if (ee) throw ee
  }
  return workout
}

// 개인 운동 수정: 제목 갱신 + 동작 전량 교체(간단·견고). 기존 로그의 exercise_name은 복사본이라 영향 없음.
export async function updatePersonalWorkout(
  workoutId: string,
  title: string,
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[],
): Promise<void> {
  const { error: te } = await supabase.from('workouts').update({ title }).eq('id', workoutId)
  if (te) throw te
  const { error: de } = await supabase.from('workout_exercises').delete().eq('workout_id', workoutId)
  if (de) throw de
  if (exercises.length > 0) {
    const rows = exercises.map((ex, i) => ({ ...ex, workout_id: workoutId, sort_order: ex.sort_order ?? i }))
    const { error: ie } = await supabase.from('workout_exercises').insert(rows)
    if (ie) throw ie
  }
}

export async function archiveWorkout(workoutId: string): Promise<void> {
  const { error } = await supabase.from('workouts').update({ archived: true }).eq('id', workoutId)
  if (error) throw error
}

// 운동별 본인 기록 추이: 이 운동의 동작들에 연결된 로그를 날짜순으로
export async function getWorkoutProgress(userId: string, workoutId: string) {
  const { data: exs, error: ee } = await supabase
    .from('workout_exercises')
    .select('id')
    .eq('workout_id', workoutId)
  if (ee) throw ee
  const ids = (exs ?? []).map((e: { id: string }) => e.id)
  if (ids.length === 0) return []
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date, exercise_name, weight_lb, weight_unit, completed')
    .eq('user_id', userId)
    .in('workout_exercise_id', ids)
    .order('date', { ascending: true })
  if (error) throw error
  return (data ?? []) as {
    date: string
    exercise_name: string
    weight_lb: number | null
    weight_unit: 'lb' | 'kg'
    completed: boolean
  }[]
}
```

- [ ] **Step 2: 빌드·린트**

Run: `npm run build && npm run lint`
Expected: 성공.

- [ ] **Step 3: Commit**

```bash
git add src/lib/api/workouts.ts
git commit -m "feat(api): workouts.ts — 공용/개인 운동 라이브러리 CRUD + 요일조회 + 운동별 추이

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task A4: 공용 기본운동 시드 틀(SQL 템플릿)

**Files:**
- Create: `supabase/seed-shared-workouts.sql`

**Interfaces:**
- Produces: 월~금 공용 운동 시드 예시. chacha가 실제 운동으로 채워 적용.

- [ ] **Step 1: 시드 템플릿 작성**

`supabase/seed-shared-workouts.sql` (예시 1건 + 작성 가이드 주석):
```sql
-- 공용 기본운동 시드 (owner_user_id = null). default_weekday: 1=월 .. 5=금.
-- chacha가 운동별로 아래 블록을 복제해 채운다.

-- 예시: 월요일 "어깨·가슴"
with w as (
  insert into workouts (title, owner_user_id, default_weekday, sort_order)
  values ('어깨·가슴', null, 1, 0)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order)
select w.id, v.section, v.exercise_name, v.sets, v.reps, v.notes, v.sort_order
from w, (values
  ('A', '바벨 숄더프레스', '4 sets', '8-10', null, 0),
  ('A', '인클라인 덤벨프레스', '4 sets', '10-12', null, 1)
) as v(section, exercise_name, sets, reps, notes, sort_order);
```

- [ ] **Step 2: (선택) 적용**

실제 운동 데이터는 chacha가 채운 뒤 SQL 에디터로 적용. 이 태스크는 틀만 커밋.

- [ ] **Step 3: Commit**

```bash
git add supabase/seed-shared-workouts.sql
git commit -m "chore(db): 공용 기본운동 시드 SQL 템플릿

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase B — 운동 페이지 전면 개편

> `src/app/workout/page.tsx`(1240줄)를 날짜 기반으로 재작성한다. 거대 단일 파일을 줄이기 위해 운동 카드 렌더를 컴포넌트로 분리한다. 기존 그룹 렌더링 규칙(groupLabel / setInfo / `__sep__` / 서브그룹 / 무게 lb·kg 입력 / 메모 auto-height)과 자동저장 디바운스(무게 500ms·메모 800ms, useRef per-id)는 **그대로 이식**한다.

### Task B1: 날짜 네비 + loadData(date) 스켈레톤

**Files:**
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: `getDefaultWorkoutsForWeekday`, `getWorkoutExercises` (workouts.ts); `getWorkoutLogsWithWorkout`, `addWorkoutToDate`, `batchInsertWorkoutLogs` (workout-logs.ts); `getLoggedInUser` (auth.ts); `toDateString` (utils.ts).
- Produces: `loadData(date: Date)` — 그 날짜의 그룹 데이터 `groups: { workoutId: string; title: string; isShared: boolean; logs: WorkoutLogJoined[] }[]`를 state에 세팅.

- [ ] **Step 1: 주차/요일(1~5) 네비 제거, 7일 날짜 스트립 도입**

`page.tsx` 상단 state를 다음으로 교체(기존 `selectedDay`, `weekId`, `weekInfo`, `templates` 제거):
```typescript
const [date, setDate] = useState<Date>(() => new Date())
const [groups, setGroups] = useState<
  { workoutId: string; title: string; isShared: boolean; logs: WorkoutLogJoined[] }[]
>([])
const [loading, setLoading] = useState(true)
```
`getWeekDates()` / `getMondayOfWeek()`는 7일 스트립 계산에 재사용(월~일 7칸, 오늘 표시). `shiftWeek(±7)`은 `shiftDays(±1)`/주 이동 버튼으로 단순화. 날짜 칸 클릭 → `setDate(d)`.

- [ ] **Step 2: loadData(date) 작성 (spec §5.2)**

```typescript
async function loadData(d: Date) {
  setLoading(true)
  const user = getLoggedInUser()
  if (!user) { setLoading(false); return }
  const ds = toDateString(d)
  const jsDay = d.getDay()                 // 0=일..6=토
  const weekday = jsDay === 0 ? 7 : jsDay  // 1=월..7=일

  // 1) 그 요일 공용 기본운동 (월~금만 매핑됨)
  const defaults = weekday <= 5 ? await getDefaultWorkoutsForWeekday(weekday) : []

  // 2) 그 날짜 로그 (workout 조인)
  let logs = await getWorkoutLogsWithWorkout(ds, user.id)

  // 3) 공용 기본운동 중 로그 없는 것 자동 생성
  const presentWorkoutIds = new Set(logs.map((l) => l.workout?.workout_id).filter(Boolean))
  for (const wk of defaults) {
    if (!presentWorkoutIds.has(wk.id)) {
      await addWorkoutToDate(user.id, ds, wk.id)
    }
  }
  if (defaults.some((wk) => !presentWorkoutIds.has(wk.id))) {
    logs = await getWorkoutLogsWithWorkout(ds, user.id) // 재조회
  }

  // 4) workout_id로 그룹핑. 공용/개인 구분은 owner_user_id로.
  const byWorkout = new Map<string, { title: string; isShared: boolean; logs: WorkoutLogJoined[] }>()
  const legacy: WorkoutLogJoined[] = [] // 시즌1 로그(workout 연결 없음) — 과거 날짜 읽기용
  for (const l of logs) {
    const wid = l.workout?.workout_id
    if (!wid) { legacy.push(l); continue }
    if (!byWorkout.has(wid)) {
      byWorkout.set(wid, { title: l.workout!.title, isShared: l.workout!.owner_user_id === null, logs: [] })
    }
    byWorkout.get(wid)!.logs.push(l)
  }
  const grouped = [...byWorkout.entries()].map(([workoutId, g]) => ({ workoutId, ...g }))
  // 공용 먼저, 개인 나중
  grouped.sort((a, b) => Number(b.isShared) - Number(a.isShared))
  // 시즌1 레거시 로그가 있으면 맨 아래 읽기 그룹으로
  if (legacy.length) grouped.push({ workoutId: '__legacy__', title: '이전 기록', isShared: false, logs: legacy })

  setGroups(grouped)
  setLoading(false)
}

useEffect(() => { loadData(date) /* eslint-disable-next-line */ }, [date])
```
임시로 `groups`를 `<pre>{JSON.stringify(groups,null,2)}</pre>`로 렌더(B2에서 카드로 교체).

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
그다음 `npm run dev` → 로그인 후 `/workout`: 공용 요일 운동이 있는 날짜면 로그 자동 생성되고 그룹 JSON이 보임. 날짜 스트립 이동 동작. (시드가 비어 있으면 그룹 0개 — 정상.)

- [ ] **Step 4: Commit**

```bash
git add src/app/workout/page.tsx
git commit -m "feat(workout): 날짜 기반 loadData + 공용/개인 그룹핑 스켈레톤 (주차·요일 그리드 제거)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task B2: WorkoutCard 컴포넌트 — 그룹 렌더 + 자동저장 이식

**Files:**
- Create: `src/components/workout/WorkoutCard.tsx`
- Modify: `src/app/workout/page.tsx` (JSON 임시 렌더 → `<WorkoutCard>`)

**Interfaces:**
- Consumes: `WorkoutLogJoined`, `upsertWorkoutLog` (workout-logs.ts).
- Produces: `WorkoutCard({ title, isShared, logs, onChanged }: { title: string; isShared: boolean; logs: WorkoutLogJoined[]; onChanged?: () => void })` — 한 운동(workout) 카드. 동작별 완료 체크/무게(lb·kg)/메모, setInfo·`__sep__`·서브그룹 표기.

- [ ] **Step 1: 기존 렌더 로직 이식**

`page.tsx` 기존 라인 585~837(코치 그룹 렌더)·767~833(무게 입력·메모 textarea)·231~266(무게/메모 디바운스 useRef)를 `WorkoutCard.tsx`로 옮겨 prop 기반으로 일반화한다. 핵심 보존 요소:
- `groupLabel` 추출(첫 동작 notes/sets 기반, multi-item이면 그룹 라벨), Superset/EMOM/AMRAP/"N Sets" 감지, `" / "` 분리.
- `__sep__` notes → 흐린 구분선.
- 서브그룹: `getSubType()`(superset/amrap/emom/every) 변화 또는 sets 변화 시 `isNewSubGroup` 구분선.
- 무게 입력: 닫힘=lb/kg 라벨 버튼, 열림=−/숫자/단위/+ 컨트롤. `weight_unit` 토글.
- 메모: auto-height textarea(ref 콜백).
- 자동저장: `debounceRef = useRef<Record<string, ReturnType<typeof setTimeout>>>({})`, 무게 500ms·단위 500ms·메모 800ms 후 `upsertWorkoutLog(updatedLog)`. 변경 시 로컬 state 즉시 갱신(optimistic).
- 카드 헤더: 운동 제목 + (isShared ? 공용 뱃지 : 개인 뱃지). 그룹 완료 체크(전체 토글)는 기존 동작 유지.

시맨틱 토큰만 사용(`bg-surface`/`border-border`/`text-secondary`/`text-accent`).

- [ ] **Step 2: page.tsx에서 사용**

```tsx
{groups.map((g) => (
  <WorkoutCard key={g.workoutId} title={g.title} isShared={g.isShared} logs={g.logs} onChanged={() => loadData(date)} />
))}
{!loading && groups.length === 0 && (
  <p className="text-center text-secondary text-sm py-12">이 날짜에 등록된 운동이 없어요. 아래에서 운동을 추가하세요.</p>
)}
```

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
`npm run dev`: 공용 운동 카드가 동작별로 렌더되고 완료 체크/무게 입력/메모가 저장(새로고침 후 유지)되는지 확인. 무게 단위 lb↔kg 토글 확인.

- [ ] **Step 4: Commit**

```bash
git add src/components/workout/WorkoutCard.tsx src/app/workout/page.tsx
git commit -m "feat(workout): WorkoutCard 컴포넌트로 그룹 렌더·자동저장 이식

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task B3: 공용/개인 섹션 구분 + 빈 상태

**Files:**
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: B2 `WorkoutCard`, B1 `groups`.

- [ ] **Step 1: 섹션 헤더로 분리 렌더**

`groups`를 `isShared`로 나눠 두 섹션으로:
```tsx
{sharedGroups.length > 0 && <h2 className="text-sm font-semibold text-accent mt-2 mb-1">오늘의 공용 운동</h2>}
{sharedGroups.map((g) => <WorkoutCard ... />)}
{personalGroups.length > 0 && <h2 className="text-sm font-semibold text-secondary mt-4 mb-1">내 운동</h2>}
{personalGroups.map((g) => <WorkoutCard ... />)}
```
`__legacy__` 그룹은 "이전 기록" 헤더로 개인 아래.

- [ ] **Step 2: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint` → dev에서 두 섹션 헤더 표시 확인.

- [ ] **Step 3: Commit**

```bash
git add src/app/workout/page.tsx
git commit -m "feat(workout): 공용/개인/이전기록 섹션 구분 렌더

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task B4: 운동 추가 — 라이브러리 담기 + 새 개인 운동 만들기

**Files:**
- Create: `src/components/workout/AddWorkoutSheet.tsx`
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: `getLibrary`, `createPersonalWorkout`, `WorkoutExercise` (workouts.ts); `addWorkoutToDate` (workout-logs.ts); `getLoggedInUser`.
- Produces: `AddWorkoutSheet({ userId, date, onAdded, onClose }: { userId: string; date: string; onAdded: () => void; onClose: () => void })`.

- [ ] **Step 1: 시트 컴포넌트 작성**

두 탭:
1. **라이브러리에서 담기**: `getLibrary(userId)` 목록(공용 위, 개인 아래) → 항목 탭 → `addWorkoutToDate(userId, date, workout.id)` → `onAdded()`.
2. **새 개인 운동 만들기**: 제목 입력 + 동작 행 추가(section/exercise_name/sets/reps/notes, 기존 `CustomExerciseForm` 입력 UX 참고) → `createPersonalWorkout(userId, title, rows)` → 생성된 운동 즉시 `addWorkoutToDate` → `onAdded()`.

기존 `CustomExerciseForm.tsx`의 입력 행 UI를 재사용하거나 참고. 시맨틱 토큰 사용.

- [ ] **Step 2: page.tsx에 "운동 추가" 버튼 + 시트**

```tsx
const [addOpen, setAddOpen] = useState(false)
// ...
<button onClick={() => setAddOpen(true)} className="w-full rounded-xl border border-border py-3 text-sm text-accent">+ 운동 추가</button>
{addOpen && (
  <AddWorkoutSheet userId={getLoggedInUser()!.id} date={toDateString(date)}
    onAdded={() => { setAddOpen(false); loadData(date) }} onClose={() => setAddOpen(false)} />
)}
```

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev: 라이브러리에서 담기 → 카드 추가 확인. 새 개인 운동 생성 → 라이브러리(개인)에 등록되고 그 날짜에 카드로 추가 확인.

- [ ] **Step 4: Commit**

```bash
git add src/components/workout/AddWorkoutSheet.tsx src/app/workout/page.tsx
git commit -m "feat(workout): 운동 추가 시트 — 라이브러리 담기 + 새 개인 운동 생성

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task B5: 라이브러리 관리 + 운동별 추이

**Files:**
- Create: `src/components/workout/LibrarySheet.tsx`
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: `getLibrary`, `getWorkoutExercises`, `updatePersonalWorkout`, `archiveWorkout`, `getWorkoutProgress` (workouts.ts); `getLoggedInUser`.
- Produces: `LibrarySheet({ userId, onClose }: { userId: string; onClose: () => void })`.

- [ ] **Step 1: 라이브러리 시트 작성**

- 공용(상단, 읽기 전용) + 개인(하단, 수정/보관) 목록.
- 개인 항목: 수정(`updatePersonalWorkout`) / 보관(`archiveWorkout`).
- 항목 탭 → `getWorkoutProgress(userId, workoutId)`로 본인 기록 추이(날짜별 무게/완료) 간단 리스트(또는 recharts 미니 차트) 표시.

- [ ] **Step 2: page.tsx에 라이브러리 진입 버튼**

헤더 영역에 "라이브러리" 버튼 → `LibrarySheet` 오픈.

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev: 라이브러리 열기 → 개인 운동 수정/보관 반영, 운동 탭 시 추이 표시.

- [ ] **Step 4: Commit**

```bash
git add src/components/workout/LibrarySheet.tsx src/app/workout/page.tsx
git commit -m "feat(workout): 라이브러리 관리(수정/보관) + 운동별 기록 추이

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task B6: 카디오 제거 + 검색/계산기/GIF 유지 + 잔여 정리

**Files:**
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: `ExerciseSearchModal`, `Calculator`, `ExerciseGifModal` (기존 유지).

- [ ] **Step 1: 카디오 섹션·상태·핸들러·import 제거**

기존 카디오 렌더(약 460~545)·상태(51~53)·useEffect 초기화(130~145)·핸들러(293~347)·`cardio-logs` import(8) 전부 삭제. "저강도 유산소"·"칼로리 진행률" 문구 제거. `ExerciseSearchModal`(시즌1·2 로그 모두 ILIKE 검색), `Calculator`, `ExerciseGifModal`(롱프레스 GIF)는 그대로 둔다.

- [ ] **Step 2: 미사용 import/변수 정리**

`getWeeks`, `getTemplatesByWeek`, `getCurrentWeek` 등 시즌1 의존 import가 남아있으면 제거. (단 `utils.ts`의 헬퍼 자체 삭제는 Phase D에서.)

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
Expected: 미사용 import 경고 없음. dev: 운동 페이지에 카디오 없음, 검색/계산기/GIF 동작.

- [ ] **Step 4: Commit**

```bash
git add src/app/workout/page.tsx
git commit -m "refactor(workout): 카디오·시즌1 잔여 제거, 검색/계산기/GIF 유지

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase C — 나머지 페이지 축소

### Task C1: 기록(daily) 페이지 — 체중 + 메모만

**Files:**
- Modify: `src/app/daily/page.tsx`

**Interfaces:**
- Consumes: `getDailyLog`, `upsertDailyLog` (daily-logs.ts, 그대로). `weight_kg`, `memo` 필드만 사용.

- [ ] **Step 1: 체중·메모 외 섹션 전부 제거**

`daily/page.tsx`에서 수면(취침/기상)·운동여부(O/X)·당가공·식단횟수(meal slot)·식단(이미지/OCR/매크로)·영양제·물(water cups) 섹션과 관련 state(`sugarToggle`, `checkedSupps`, `mealSlotNames`, `mealCheckedSet`, `weeklyCardioCount`, `showMealInput`, `newMealName`, `mealEditMode`, `weekLabel`, `weekNumber`)·핸들러(`handleAddMealSlot`/`toggleMealSlot`/`handleRemoveMealSlot`)·API호출(`getMealSlotNames`/`upsertMealSlotConfig`/`getWeeklyCardioCount`)·`FoodImageUpload`/`MacroDonutChart`/`KakaoShareText` import·KakaoShareText 렌더 전부 삭제. 남기는 건 **체중 입력 + 메모 textarea** 두 섹션. 자동저장 패턴 유지(`upsertDailyLog`에 weight_kg/memo만 채워 호출 — 나머지 컬럼은 기존 값 보존되도록 upsert가 전체 row를 덮어쓰면 안 됨; `getDailyLog`로 읽은 기존 객체에 weight_kg/memo만 갱신해 upsert).

- [ ] **Step 2: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev `/daily`: 체중 + 메모만 표시, 입력 저장·재로드 유지. (삭제 컴포넌트 파일 자체는 Phase D에서 제거.)

- [ ] **Step 3: Commit**

```bash
git add src/app/daily/page.tsx
git commit -m "refactor(daily): 체중+메모만 유지, 식단/수면/물/영양제/식단횟수 제거

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task C2: 요약(summary) 페이지 — 체중 그래프 + 1RM만

**Files:**
- Modify: `src/app/summary/page.tsx`

**Interfaces:**
- Consumes: `WeightChart`, `OneRMSection` (유지). `MacroChart`, `WeeklyStats` 제거.

- [ ] **Step 1: 주차 선택·매크로·주간통계 제거**

`summary/page.tsx`에서 `chartMode` 토글·"전체/주차별" 라디오·`selectedWeekId`/`selectedWeek` 로직·주차 드롭다운·`PROGRAM_START`/`PROGRAM_END` 상수·수면/당/칼로리 필터링·`MacroChart`/`WeeklyStats` import·렌더 전부 삭제. `WeightChart`(전체 연속, 동적 범위)와 `OneRMSection`, 로그아웃 버튼만 유지.

- [ ] **Step 2: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev `/summary`: 체중 그래프 전체 표시 + 1RM 섹션 + 로그아웃만.

- [ ] **Step 3: Commit**

```bash
git add src/app/summary/page.tsx
git commit -m "refactor(summary): 체중 그래프+1RM만 유지, 주차선택/매크로/주간통계 제거

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task C3: 홈 + 헤더 개편

**Files:**
- Modify: `src/app/page.tsx`, `src/components/Header.tsx`

**Interfaces:**
- Consumes: `getDefaultWorkoutsForWeekday`/`getWorkoutLogsWithWorkout` (오늘의 운동 진행), `getDailyLog`(최근 체중), `getLoggedInUser`, `toDateString`.

- [ ] **Step 1: Header 단순화**

`Header.tsx`에서 `getCurrentWeek`/`getCurrentPhase`/`getDday` import·사용·D-day 표시 제거. "ROAD TO FITTER" 앱명 + 로그인 사용자명(또는 오늘 날짜)만 표시. 시맨틱 토큰 사용.

- [ ] **Step 2: 홈 재구성**

`page.tsx`에서 `DdayCard`/`WeekProgressBar`/`TodayStatus`/`WeeklySummaryCard` import·렌더 제거. 대체:
- "오늘의 추가운동" 카드: 오늘 요일 공용 + 담은 개인 운동의 동작 완료 진행(예: `완료 X / 전체 Y`). 데이터는 오늘 날짜로 `getWorkoutLogsWithWorkout` + (없으면) `getDefaultWorkoutsForWeekday` 동작 수 합산.
- 최근 체중 스냅샷: 최근 `daily_logs.weight_kg`(간단히 최신 1건).
- `/workout`로 이동 링크.

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev `/`: D-day/주차 없음, 오늘 운동 진행 + 최근 체중 표시.

- [ ] **Step 4: Commit**

```bash
git add src/app/page.tsx src/components/Header.tsx
git commit -m "feat(home): 홈/헤더 개편 — 오늘의 추가운동+최근 체중, D-day/주차/단계 제거

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase D — 브랜딩 + 정리

### Task D1: 브랜딩 ROAD TO FITTER 교체

**Files:**
- Modify: `src/app/login/page.tsx`, `src/app/layout.tsx`, `public/manifest.json`

- [ ] **Step 1: 문구 교체**

- `login/page.tsx`: `2026 ZEST BP Tracker` → `ROAD TO FITTER`.
- `layout.tsx` metadata: `title: "BP Tracker"` → `"ROAD TO FITTER"`, `description: "바디프로필 준비 트래커"` → `"운동 기록 트래커"`, appleWebApp title 동일 교체.
- `public/manifest.json`: `name`/`short_name` → `"ROAD TO FITTER"`, `description` → `"운동 트래커"`.
- (localStorage `bp-*` 키는 **건드리지 않는다** — 기존 로그인 보존.)

- [ ] **Step 2: 빌드·린트·수동 확인**

Run: `npm run build && npm run lint`
dev: 로그인 화면·탭 타이틀·홈 화면 브랜딩이 ROAD TO FITTER로. 기존 로그인 유지 확인(로그아웃 안 됨).

- [ ] **Step 3: Commit**

```bash
git add src/app/login/page.tsx src/app/layout.tsx public/manifest.json
git commit -m "feat(branding): ROAD TO FITTER로 앱명/메타데이터 교체

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task D2: utils.ts 바프 헬퍼 제거

**Files:**
- Modify: `src/lib/utils.ts`

- [ ] **Step 1: 시즌1 전용 헬퍼 삭제**

`SHOOT_DATE`, `START_DATE`, `PHASES`, `getDday`, `getCurrentWeek`, `getCurrentPhase`, `getWeekProgress`, `getPhases` 삭제. `formatDate`, `toDateString`는 유지. `calcSleepHours`는 수면 제거됐으니 남은 참조 없으면 삭제(있으면 유지).

- [ ] **Step 2: 빌드로 잔여 참조 검출**

Run: `npm run build`
Expected: 어디선가 삭제된 헬퍼를 아직 import하면 컴파일 에러 → 해당 파일에서 제거 후 재빌드. 에러 0까지.
그다음 `npm run lint`.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(utils): 시즌1 전용 날짜/주차/단계 헬퍼 제거

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task D3: 미사용 컴포넌트/API 파일 삭제

**Files:**
- Delete: `src/components/dashboard/DdayCard.tsx`, `WeekProgressBar.tsx`, `TodayStatus.tsx`, `WeeklySummaryCard.tsx`
- Delete: `src/components/daily/FoodImageUpload.tsx`, `MacroDonutChart.tsx`, `KakaoShareText.tsx`
- Delete: `src/components/summary/MacroChart.tsx`, `WeeklyStats.tsx`
- Delete: `src/components/AnnouncementPopup.tsx`, `src/components/FinalWeekCheerPopup.tsx`
- Delete: `src/lib/api/meal-slots.ts`, `src/lib/api/cardio-logs.ts`
- Modify: `src/components/ClientLayout.tsx` (팝업 import/렌더 제거)

- [ ] **Step 1: ClientLayout에서 팝업 제거**

`ClientLayout.tsx`의 `AnnouncementPopup`, `FinalWeekCheerPopup` import·렌더 삭제.

- [ ] **Step 2: 파일 삭제**

```bash
git rm src/components/dashboard/DdayCard.tsx src/components/dashboard/WeekProgressBar.tsx \
  src/components/dashboard/TodayStatus.tsx src/components/dashboard/WeeklySummaryCard.tsx \
  src/components/daily/FoodImageUpload.tsx src/components/daily/MacroDonutChart.tsx \
  src/components/daily/KakaoShareText.tsx src/components/summary/MacroChart.tsx \
  src/components/summary/WeeklyStats.tsx src/components/AnnouncementPopup.tsx \
  src/components/FinalWeekCheerPopup.tsx src/lib/api/meal-slots.ts src/lib/api/cardio-logs.ts
```
(`exercise-db.ts`/`getExerciseGif`는 GIF 모달에서 계속 쓰므로 **삭제하지 않음**.)

- [ ] **Step 3: 빌드로 잔여 import 검출·정리**

Run: `npm run build`
Expected: 삭제 파일을 아직 import하는 곳이 있으면 에러 → 제거. 에러 0까지. `npm run lint`.

- [ ] **Step 4: 수동 전체 점검**

`npm run dev`로 4개 탭(홈/운동/기록/요약) 전부 로드, 콘솔 에러 없음, 핵심 플로우(운동 담기/기록/체중/1RM) 동작 확인.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: 시즌1 전용 컴포넌트/API 파일 삭제 + 팝업 정리

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## 비주얼 리디자인 (이 계획 범위 밖)

색상 테마·목업은 사용자(chacha)가 추후 제공 → 별도 단계. 본 계획은 시맨틱 토큰만 사용해 후속 테마 교체를 `globals.css :root` 값 변경으로 수렴시킨다. 설계 §12 참조.

---

## Self-Review 메모

- **Spec 커버리지**: §4 데이터모델→A1~A3 / §5 운동흐름→B1~B5 / §6 화면변경→C1~C3,D1 / §8 lib/api→A2,A3,D2 / §9 마이그레이션·유틸정리→A1,D2 / §3 2계층 라이브러리→A3,B3,B4 / §12 비주얼은 범위 밖 명시. 누락 없음.
- **타입 일관성**: `Workout`/`WorkoutExercise`는 "핵심 데이터 모델"·A3에서 단일 정의. `WorkoutLogJoined`는 A2에서 정의, B1·B2·C3에서 소비. `addWorkoutToDate`/`getWorkoutExercises` 시그니처 A2↔A3 일치.
- **검증**: 테스트 하네스 없음 → 전 태스크 build+lint+manual. (TDD 대체, Global Constraints 명시.)
- **순서 의존성**: A3(getWorkoutExercises)을 A2(addWorkoutToDate)보다 먼저 또는 함께 구현. D2/D3는 모든 소비처 제거 후 마지막.
```
