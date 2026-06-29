# 공용 운동 날짜 기반 프로그램 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 공용 운동을 `program_date`로 특정 날짜에 배정하고, 한 세션을 `set_group`/`set_info`/`set_lead` 세트 그룹으로 렌더해 8주 스트렝스 프로그램을 표현한다.

**Architecture:** `workouts`에 `program_date`/`program_label`, `workout_exercises`·`workout_logs`에 `set_lead`(그룹 연결자) 컬럼을 추가한다. 그날 뷰는 요일반복 대신 날짜 기반(`getWorkoutsForDate`)으로 세션을 가져온다. 렌더는 `set_group` 존재 시 그룹 레이아웃을 쓰고, 그룹 사이 연결을 `set_lead`(`'into'`=서킷 구분선 / 자유텍스트=이탤릭 / `null`=블록 분리)로 결정한다. 콘텐츠는 SQL 시드로만 관리.

**Tech Stack:** Next.js 16 (App Router) · TypeScript · Tailwind v4 · Supabase(public schema, anon key, RLS allow-all) · vitest(유일한 테스트 러너).

## Global Constraints

- 검증 게이트 = `npx tsc --noEmit` clean + `npm run lint` (기존 season1 lint 2건 `admin/workout/page.tsx`, `auth/AuthGuard.tsx`는 알려진 기술부채 — **새로 늘리지 말 것**) + `npx vitest run` 통과.
- 마이그레이션 SQL은 **배포 전에** 사용자가 라이브 DB에 수동 적용(코드가 `set_lead`/`program_label`을 select하므로 컬럼 없으면 조회 깨짐).
- `set_lead` 의미(고정): `'into'` → `– into –` 구분선 / 비어있지 않은 그 외 텍스트 → 이탤릭 연결자 줄 / `null` → 블록 분리(연결자 텍스트 없음). **첫 그룹(gi===0)은 연결자 없음.**
- 그룹 렌더 판정 = 로그에 `set_group != null`이 하나라도 있으면 그룹 레이아웃, 아니면 기존 섹션 레이아웃.
- %1RM은 **메모 텍스트로만** 표시(자동 중량계산 없음).
- 휴지통(그날에서 빼기)은 **개인 전용**(`owner_user_id != null`) 유지.
- 모든 UI 카피 한글. 동작명은 영어 원문 유지(데이터 그대로).
- 개인운동 빌더는 항상 그룹 2번째부터 `set_lead='into'`(서킷). 공용 스트렝스 세션은 전부 `set_lead=null`(블록).

---

## File Structure

- `supabase/migration-workout-program.sql` (신규) — ALTER 4컬럼 + 인덱스.
- `supabase/seed-strength-8week.sql` (신규) — 40세션 시드 + 레거시 공용 archive.
- `docs/data/season2-strength-8week-data.md` (신규) — 원본 데이터 사본(시드 작성 참조용).
- `src/lib/workout/build-exercises.ts` (신규) — 빌더 그룹→동작 순수 매핑(+테스트 가능).
- `src/lib/workout/build-exercises.test.ts` (신규) — vitest.
- `src/lib/api/workouts.ts` (수정) — 타입 + `getWorkoutsForDate`.
- `src/lib/api/workout-logs.ts` (수정) — 타입 + select + `addWorkoutToDate`.
- `src/components/workout/AddWorkoutPopup.tsx` (수정) — 순수 매핑·공유 타입 사용.
- `src/components/workout/WorkoutCard.tsx` (수정) — 그룹 판정 일반화 + `set_lead` 연결자 + `program_label` eyebrow.
- `src/app/workout/page.tsx` (수정) — 날짜 기반 조회.

---

## Task 1: DB 마이그레이션 + API 데이터 레이어

**Files:**
- Create: `supabase/migration-workout-program.sql`
- Modify: `src/lib/api/workouts.ts` (`Workout`/`WorkoutExercise` 타입, `getWorkoutsForDate` 추가)
- Modify: `src/lib/api/workout-logs.ts` (`WorkoutLog`/`WorkoutLogJoined` 타입, `getWorkoutLogsWithWorkout` select+map, `addWorkoutToDate`)

**Interfaces:**
- Produces: `getWorkoutsForDate(date: string): Promise<Workout[]>`; `WorkoutExercise.set_lead?: string | null`; `WorkoutLog.set_lead?: string | null`; `Workout.program_date?: string | null`; `Workout.program_label?: string | null`; `WorkoutLogJoined.workout.program_label: string | null`.

- [ ] **Step 1: 마이그레이션 SQL 작성**

Create `supabase/migration-workout-program.sql`:
```sql
-- 공용 운동 날짜 기반 프로그램: workouts에 program_date/program_label, 동작/로그에 set_lead(그룹 연결자).
-- 기존 컬럼(default_weekday 등)은 호환 위해 유지. 설계:
-- docs/superpowers/specs/2026-06-28-public-workout-date-program-design.md
alter table workouts
  add column if not exists program_date  date,   -- 공용 프로그램 세션 날짜(null=비프로그램)
  add column if not exists program_label text;    -- 프로그램 태그 eyebrow (예: 'Strength 8주 · 1주차')

alter table workout_exercises
  add column if not exists set_lead text;         -- 그룹 위 연결자: 'into' | 자유텍스트 | null

alter table workout_logs
  add column if not exists set_lead text;

create index if not exists idx_workouts_program_date
  on workouts(program_date) where owner_user_id is null;
```

- [ ] **Step 2: `workouts.ts` 타입 + 조회 함수**

In `src/lib/api/workouts.ts`, `Workout` 인터페이스에 두 필드 추가(`created_at?` 위에):
```ts
  created_by: string | null
  program_date?: string | null   // 공용 프로그램 세션 날짜(YYYY-MM-DD)
  program_label?: string | null  // 프로그램 태그 eyebrow
  created_at?: string
```
`WorkoutExercise` 인터페이스에 `set_lead` 추가(`set_info` 아래):
```ts
  set_group?: number | null  // 개인운동 세트 그룹 순서(1-based)
  set_info?: string | null   // 그룹 헤더(예: '3 Sets')
  set_lead?: string | null   // 그룹 위 연결자('into'|자유텍스트|null)
```
`getDefaultWorkoutsForWeekday` 아래에 신규 함수 추가:
```ts
// 그 날짜에 배정된 공용 프로그램 세션 (날짜 기반). owner=공용, sort_order 순.
export async function getWorkoutsForDate(date: string): Promise<Workout[]> {
  const { data, error } = await supabase
    .from('workouts')
    .select('*')
    .is('owner_user_id', null)
    .eq('program_date', date)
    .eq('archived', false)
    .order('sort_order', { ascending: true })
  if (error) throw error
  return (data ?? []) as Workout[]
}
```

- [ ] **Step 3: `workout-logs.ts` 타입 + select + 복사**

In `src/lib/api/workout-logs.ts`:

(a) `WorkoutLog` 인터페이스에 `set_lead` 추가(`set_info` 아래):
```ts
  set_group?: number | null
  set_info?: string | null
  set_lead?: string | null
```

(b) `WorkoutLogJoined` 의 workout 타입에 `program_label` 추가:
```ts
export type WorkoutLogJoined = WorkoutLog & {
  workout?: { workout_id: string; title: string; owner_user_id: string | null; program_label: string | null } | null
}
```

(c) `getWorkoutLogsWithWorkout` 의 select 문자열을 교체(컬럼에 `set_lead`, workouts 조인에 `program_label`):
```ts
    .select(
      'id, user_id, date, template_id, workout_exercise_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo, custom_sets, custom_reps, custom_notes, set_group, set_info, set_lead, ' +
        'workout_exercises ( workout_id, workouts ( title, owner_user_id, program_label ) ), ' +
        'workout_templates ( sets, reps, notes )',
    )
```

(d) 같은 함수 내 `we` 타입과 매핑에 `program_label` 추가:
```ts
    const we = row.workout_exercises as
      | { workout_id: string; workouts?: { title: string; owner_user_id: string | null; program_label: string | null } | null }
      | null
```
그리고 return 객체의 workout:
```ts
      workout: we
        ? { workout_id: we.workout_id, title: we.workouts?.title ?? '', owner_user_id: we.workouts?.owner_user_id ?? null, program_label: we.workouts?.program_label ?? null }
        : null,
```

(e) `addWorkoutToDate` 의 rows 매핑에 `set_lead` 복사 추가(`set_info` 아래):
```ts
    set_group: ex.set_group ?? 1,
    set_info: ex.set_info ?? null,
    set_lead: ex.set_lead ?? null,
```

- [ ] **Step 4: 검증**

Run: `npx tsc --noEmit`
Expected: 출력 없음(에러 0).
Run: `npx eslint src/lib/api/workouts.ts src/lib/api/workout-logs.ts`
Expected: 출력 없음.

- [ ] **Step 5: 커밋**

```bash
git add supabase/migration-workout-program.sql src/lib/api/workouts.ts src/lib/api/workout-logs.ts
git commit -m "feat(workout): 공용 날짜기반 프로그램 DB/API 레이어 (program_date/label, set_lead, getWorkoutsForDate)"
```

---

## Task 2: 빌더 그룹→동작 순수 매핑 (set_lead 부여 + vitest)

**Files:**
- Create: `src/lib/workout/build-exercises.ts`
- Test: `src/lib/workout/build-exercises.test.ts`
- Modify: `src/components/workout/AddWorkoutPopup.tsx` (로컬 타입/함수 제거, 공유 헬퍼 사용)

**Interfaces:**
- Consumes: `WorkoutExercise`(Task 1, `set_lead` 포함).
- Produces: `buildExercisesFromGroups(groups: SetGroup[]): Omit<WorkoutExercise,'id'|'workout_id'>[]`; `interface ExerciseRow { id, exercise_name, reps, notes }`; `interface SetGroup { id, setInfo, rows: ExerciseRow[] }`.

- [ ] **Step 1: 실패 테스트 작성**

Create `src/lib/workout/build-exercises.test.ts`:
```ts
import { describe, it, expect } from 'vitest'
import { buildExercisesFromGroups, type SetGroup } from './build-exercises'

const row = (name: string, reps = '', notes = '') => ({ id: name, exercise_name: name, reps, notes })

describe('buildExercisesFromGroups', () => {
  it('set_group 연속 + set_lead(첫 null, 이후 into) 부여', () => {
    const groups: SetGroup[] = [
      { id: 'g1', setInfo: '1 Sets', rows: [row('A', '400', "7'30\"")] },
      { id: 'g2', setInfo: 'For time', rows: [row('B', '800')] },
    ]
    const out = buildExercisesFromGroups(groups)
    expect(out).toHaveLength(2)
    expect(out[0]).toMatchObject({ set_group: 1, set_lead: null, set_info: '1 Sets', exercise_name: 'A', reps: '400', notes: "7'30\"", sort_order: 0 })
    expect(out[1]).toMatchObject({ set_group: 2, set_lead: 'into', set_info: 'For time', exercise_name: 'B', reps: '800', sort_order: 1 })
  })

  it('빈 그룹(동작명 없음) 건너뛰고 set_group 연속 유지', () => {
    const groups: SetGroup[] = [
      { id: 'g1', setInfo: '', rows: [row('   ')] },
      { id: 'g2', setInfo: '', rows: [row('Squat', '5')] },
      { id: 'g3', setInfo: '', rows: [row('Bench', '5')] },
    ]
    const out = buildExercisesFromGroups(groups)
    expect(out.map((e) => e.set_group)).toEqual([1, 2])
    expect(out[0].set_lead).toBeNull()
    expect(out[1].set_lead).toBe('into')
  })

  it('빈 setInfo/reps/notes는 null, sets/section은 항상 null', () => {
    const out = buildExercisesFromGroups([{ id: 'g', setInfo: '  ', rows: [row('X', ' ', ' ')] }])
    expect(out[0]).toMatchObject({ set_info: null, reps: null, notes: null, sets: null, section: null })
  })
})
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `npx vitest run src/lib/workout/build-exercises.test.ts`
Expected: FAIL — `Failed to resolve import "./build-exercises"` (모듈 없음).

- [ ] **Step 3: 헬퍼 구현**

Create `src/lib/workout/build-exercises.ts`:
```ts
import type { WorkoutExercise } from '@/lib/api/workouts'

export interface ExerciseRow {
  id: string
  exercise_name: string
  reps: string // 횟수/시간
  notes: string // 메모
}
export interface SetGroup {
  id: string
  setInfo: string // 그룹 헤더 (예: '3 Sets', 'AMRAP 10')
  rows: ExerciseRow[]
}

// 빌더 그룹 → 저장용 동작 배열. 유효 그룹(동작명 있는 행 ≥1)만, set_group 연속 부여,
// 첫 그룹 set_lead=null, 이후 그룹은 'into'(개인운동=서킷). sets/section은 미사용(null).
export function buildExercisesFromGroups(
  groups: SetGroup[],
): Omit<WorkoutExercise, 'id' | 'workout_id'>[] {
  const exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[] = []
  let order = 0
  let groupNo = 0
  for (const g of groups) {
    const validRows = g.rows.filter((r) => r.exercise_name.trim())
    if (validRows.length === 0) continue
    groupNo++
    const info = g.setInfo.trim() || null
    const lead = groupNo === 1 ? null : 'into'
    for (const r of validRows) {
      exercises.push({
        section: null,
        exercise_name: r.exercise_name.trim(),
        sets: null,
        reps: r.reps.trim() || null,
        notes: r.notes.trim() || null,
        sort_order: order++,
        set_group: groupNo,
        set_info: info,
        set_lead: lead,
      })
    }
  }
  return exercises
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `npx vitest run src/lib/workout/build-exercises.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: 빌더에서 공유 헬퍼 사용**

In `src/components/workout/AddWorkoutPopup.tsx`:

(a) import 블록(`@/lib/api/workouts`)에서 `WorkoutExercise` 가 더 이상 직접 쓰이지 않으면 제거하고, 신규 import 추가:
```ts
import {
  getPersonalWorkouts,
  createPersonalWorkout,
  getWorkoutExercises,
  updatePersonalWorkout,
  archiveWorkout,
  type Workout,
} from '@/lib/api/workouts'
import { addWorkoutToDate } from '@/lib/api/workout-logs'
import { buildExercisesFromGroups, type ExerciseRow, type SetGroup } from '@/lib/workout/build-exercises'
```
(`WorkoutExercise` 는 `createPersonalWorkout`/`updatePersonalWorkout` 인자 타입에 쓰이지만 그건 그 함수 시그니처가 처리 — AddWorkoutPopup 본문에서 직접 참조 안 하면 import 제거. lint에서 unused 뜨면 제거.)

(b) 로컬 `interface ExerciseRow {…}` 와 `interface SetGroup {…}` 정의를 **삭제**(헬퍼에서 import). `emptyRow`/`emptyGroup` 함수는 유지(이제 import한 타입을 반환).

(c) 로컬 `function buildExercises() {…}` 정의를 **삭제**.

(d) `handleCreate` 안의 `const exercises = buildExercises()` 를 교체:
```ts
    const exercises = buildExercisesFromGroups(groups)
```

- [ ] **Step 6: 검증**

Run: `npx vitest run`
Expected: 전체 PASS(challenge 12 + build-exercises 3).
Run: `npx tsc --noEmit`
Expected: 출력 없음.
Run: `npx eslint src/components/workout/AddWorkoutPopup.tsx src/lib/workout/build-exercises.ts`
Expected: 출력 없음.

- [ ] **Step 7: 커밋**

```bash
git add src/lib/workout/build-exercises.ts src/lib/workout/build-exercises.test.ts src/components/workout/AddWorkoutPopup.tsx
git commit -m "feat(workout): 빌더 그룹→동작 매핑 추출(set_lead 부여) + vitest"
```

---

## Task 3: 렌더 일반화 + set_lead 연결자 + program_label eyebrow

**Files:**
- Modify: `src/components/workout/WorkoutCard.tsx`

**Interfaces:**
- Consumes: `WorkoutLogJoined`(`set_group`/`set_info`/`set_lead`, `workout.program_label`)(Task 1).

배경(현재 코드): `WorkoutCard`는 `isPersonal`(owner!=null)일 때만 `personalGroups`로 묶어 `PersonalGroup`을 렌더하고, 그룹 사이에 항상 `into` 구분선을 넣는다. 이걸 **`set_group` 존재 기준**으로 일반화하고, 연결자를 `set_lead` 기준으로 분기한다. `isPersonal`은 휴지통 버튼 조건으로만 남긴다.

- [ ] **Step 1: 그룹 계산 일반화 (set_group 기준 + setLead 캡처)**

`src/components/workout/WorkoutCard.tsx`에서 현재의 `isPersonal` 분기 그룹 계산 블록(주석 `// ── 개인 운동 분기 …`부터 `personalGroups.sort(...)` 까지)을 아래로 교체:
```ts
  // ── 그룹 렌더: 로그에 set_group이 있으면(개인 + 공용 프로그램) 세트 그룹으로 묶는다. ──
  // set_group 없으면(레거시 요일반복 공용·시즌1 템플릿) 아래 섹션 로직 그대로.
  const isPersonal = !!items[0]?.workout?.owner_user_id // 휴지통(그날에서 빼기) 조건용
  const hasGroups = items.some((l) => l.set_group != null)
  const groups: { key: number; setInfo: string | null; setLead: string | null; rows: WorkoutLogJoined[] }[] = []
  if (hasGroups) {
    const gMap = new Map<number, WorkoutLogJoined[]>()
    for (const log of items) {
      const g = log.set_group ?? 1
      if (!gMap.has(g)) {
        const rows: WorkoutLogJoined[] = []
        gMap.set(g, rows)
        groups.push({ key: g, setInfo: log.set_info ?? null, setLead: log.set_lead ?? null, rows })
      }
      gMap.get(g)!.push(log)
    }
    groups.sort((a, b) => a.key - b.key)
  }
  const programLabel = items[0]?.workout?.program_label ?? null
```
그리고 바로 아래 `singleSection` 계산의 조건 `!isPersonal` 을 `!hasGroups` 로 변경:
```ts
  const singleSection = !hasGroups && sections.length === 1 ? sections[0] : null
```

- [ ] **Step 2: 헤더에 program_label eyebrow**

헤더의 제목 표시 분기(`{title ? (<span …>{title}</span>) : singleSection ? …`)에서 title 케이스를 eyebrow 포함 컬럼으로 교체:
```tsx
        {title ? (
          <div className="flex flex-col min-w-0">
            {programLabel && <span className="text-[10px] font-medium text-accent/70 truncate">{programLabel}</span>}
            <span className="text-xs font-medium text-foreground truncate">{title}</span>
          </div>
        ) : singleSection ? (
          <div className="flex items-baseline gap-2 min-w-0">
            {singleSection.section !== '?' && <span className="text-xs font-medium text-accent shrink-0">{singleSection.section}</span>}
            {headerLabel && <span className="text-xs text-text-secondary font-medium truncate">{headerLabel}</span>}
          </div>
        ) : null}
```

- [ ] **Step 3: 렌더 분기 + set_lead 연결자**

그룹/섹션 렌더 분기(`{isPersonal ? personalGroups.map(...) : sections.map(...)}`)를 아래로 교체. 그룹 컴포넌트 이름은 `ExerciseGroup`(Step 5에서 rename):
```tsx
      {/* set_group 있으면 세트 그룹(연결자=set_lead) · 그 외 섹션 그룹 */}
      {hasGroups
        ? groups.map((g, gi) => (
            <div key={g.key}>
              {gi > 0 && g.setLead === 'into' && (
                <div className="px-4 py-1.5 flex items-center gap-2 border-t border-border">
                  <span className="h-px flex-1 bg-border" />
                  <span className="text-[10px] text-text-secondary/50 italic tracking-wide">into</span>
                  <span className="h-px flex-1 bg-border" />
                </div>
              )}
              {gi > 0 && g.setLead && g.setLead !== 'into' && (
                <div className="px-4 py-1.5 border-t border-border">
                  <span className="text-[10px] text-text-secondary/60 italic">{g.setLead}</span>
                </div>
              )}
              {gi > 0 && !g.setLead && <div className="border-t border-border" />}
              <ExerciseGroup
                setInfo={g.setInfo}
                rows={g.rows}
                weightOpen={weightOpen}
                onToggleComplete={handleToggleComplete}
                onToggleWeight={toggleWeightInput}
                onWeightChange={handleWeightChange}
                onUnitToggle={handleUnitToggle}
                onLongPressStart={handleLongPressStart}
                onLongPressEnd={handleLongPressEnd}
              />
            </div>
          ))
        : sections.map(({ section, rows }) => (
            <SectionGroup
              key={section}
              section={section}
              rows={rows}
              inHeader={labelInHeader}
              weightOpen={weightOpen}
              onToggleComplete={handleToggleComplete}
              onToggleWeight={toggleWeightInput}
              onWeightChange={handleWeightChange}
              onUnitToggle={handleUnitToggle}
              onLongPressStart={handleLongPressStart}
              onLongPressEnd={handleLongPressEnd}
            />
          ))}
```

- [ ] **Step 4: ExerciseGroup 루트 보더 제거(연결자가 분리 담당)**

`PersonalGroup` 컴포넌트 루트 div의 클래스에서 `border-t border-border first:border-t-0` 를 제거(연결자/블록 구분선이 Step 3에서 그룹 위 보더를 담당하므로 중복·`first:` 오작동 방지):
```tsx
function PersonalGroup({ /* …props… */ }: PersonalGroupProps) {
  return (
    <div>
      {/* 그룹 헤더 = set_info (있을 때만) */}
      {setInfo && (
        <div className="px-4 py-1.5 bg-border/50 border-b border-border">
          <span className="text-xs text-text-secondary font-semibold">{setInfo}</span>
        </div>
      )}
      {/* …rows… (변경 없음) */}
```
(루트 `<div className="border-t border-border first:border-t-0">` → `<div>` 로만 변경. 내부 헤더 `border-b`·rows `divide-y`는 유지.)

- [ ] **Step 5: PersonalGroup → ExerciseGroup 리네임**

`PersonalGroup`/`PersonalGroupProps` 식별자를 `ExerciseGroup`/`ExerciseGroupProps`로 전부 교체(이제 공용 프로그램에도 쓰이므로). 정의·타입·Step 3 사용처 모두.

- [ ] **Step 6: 검증**

Run: `npx tsc --noEmit`
Expected: 출력 없음.
Run: `npx eslint src/components/workout/WorkoutCard.tsx`
Expected: 출력 없음.
(컴포넌트 테스트 없음 — 시각 QA는 사용자 수동.)

- [ ] **Step 7: 커밋**

```bash
git add src/components/workout/WorkoutCard.tsx
git commit -m "feat(workout): 그룹 렌더 일반화(set_group 기준)+set_lead 연결자+program_label eyebrow"
```

---

## Task 4: 그날 뷰 날짜 기반 조회

**Files:**
- Modify: `src/app/workout/page.tsx`

**Interfaces:**
- Consumes: `getWorkoutsForDate(date)`(Task 1).

- [ ] **Step 1: import 교체**

`src/app/workout/page.tsx` 상단 import에서 `getDefaultWorkoutsForWeekday` 를 `getWorkoutsForDate` 로 교체:
```ts
import { getWorkoutsForDate } from '@/lib/api/workouts'
```

- [ ] **Step 2: 날짜 기반 조회로 교체 (미사용 weekday 계산 제거)**

`loadData` 안에서 요일 계산과 공용 기본운동 조회를 교체. 현재:
```ts
    const ds = toDateString(d)
    const jsDay = d.getDay() // 0=일..6=토
    const weekday = jsDay === 0 ? 7 : jsDay // 1=월..7=일

    // 1) 그 요일 공용 기본운동 (월~금만 매핑됨)
    const defaults = weekday <= 5 ? await getDefaultWorkoutsForWeekday(weekday) : []
```
교체 후:
```ts
    const ds = toDateString(d)

    // 1) 그 날짜에 배정된 공용 프로그램 세션
    const defaults = await getWorkoutsForDate(ds)
```
(나머지 — `presentWorkoutIds`, `isPast` 가드, `missing` 자동담기, 그룹핑 — 변경 없음. 자동담기는 기존대로 오늘/미래만.)

- [ ] **Step 3: 검증**

Run: `npx tsc --noEmit`
Expected: 출력 없음(미사용 `jsDay`/`weekday` 제거로 lint 경고도 없음).
Run: `npx eslint src/app/workout/page.tsx`
Expected: 출력 없음.

- [ ] **Step 4: 커밋**

```bash
git add src/app/workout/page.tsx
git commit -m "feat(workout): 그날 뷰를 날짜 기반 공용 조회(getWorkoutsForDate)로 전환"
```

---

## Task 5: 8주 스트렝스 시드

**Files:**
- Create: `docs/data/season2-strength-8week-data.md` (원본 사본)
- Create: `supabase/seed-strength-8week.sql`

**매핑 규칙 (데이터 문서 → 시드):**
- 세션 1개 = `workouts` 1행: `title`=요일 운동명("스쿼트"/"덤벨 상체"/"데드리프트"/"단측 하체"/"오버헤드 프레스"/"벤치프레스"), `owner_user_id`=null, `default_weekday`=null, `category`=데이터의 _(category: …)_, `program_date`=해당 날짜, `program_label`=`'Strength 8주 · N주차'`, `sort_order`=날짜 인덱스(0부터).
- 주차 날짜: W1 7/6~7/10, W2 7/13~17, W3 7/20~24, W4 7/27~31, W5 8/3~7, W6 8/10~14, W7 8/17~21, W8 8/24~28 (평일만).
- 섹션 → `set_group`: 같은 섹션 레터·같은 세트수 = 한 그룹. **세트수가 다른 블록(예: A 메인 + A 백오프)은 별도 그룹**(set_group 증가).
- `set_info` = `"{레터}. {역할} · {세트스킴}"`. 역할: A=메인, B=슈퍼셋, C=안정화, D=피니셔. 세트스킴: "세트" 열 값을 `"N Sets"`로(예 `"A. 메인 · 4 Sets"`, `"B. 슈퍼셋 · 3 Sets"`, `"C. 안정화 · 2 Sets"`). "세트"가 `—`면 스킴 텍스트 사용(예 `"A. 메인 · Find Heavy Single"`, `"D. 피니셔 · EMOM 8분"`, `"D. 피니셔 · For time"`). 단일 섹션(목요일 Skill Practice 등)은 `"C. 스킬"`.
- `set_lead` = **모두 null**(공용 스트렝스는 블록). → INSERT 컬럼에서 생략(기본 null).
- `sets` = **null**(그룹 헤더로 이동) → INSERT 컬럼에서 생략.
- `exercise_name` = "운동" 열. `reps` = "횟수" 열(예 `5`, `8`, `12/12`, `0:30`, `Max`, `1`, `~10분`, `100`). `notes` = "메모" 열에서 `set_info`에 이미 들어간 역할 접두(`슈퍼셋 · `)는 **제거**(예 메모 `슈퍼셋 · 이중 점진` → `이중 점진`). 그 외 메모(@%1RM·RIR·Rest·전거근·코어 등)는 그대로.
- `section` = 섹션 레터(추적용 기록).

- [ ] **Step 1: 원본 데이터 사본 + 시드 골격**

원본을 레포로 복사:
```bash
mkdir -p docs/data
cp /Users/chacha/Downloads/season2-strength-8week-data.md docs/data/season2-strength-8week-data.md
```
Create `supabase/seed-strength-8week.sql` 헤더 + 레거시 공용 정리:
```sql
-- 8주 스트렝스 공용 프로그램 시드 (2026-07-06 시작, 평일 40세션).
-- 적용 전: migration-workout-program.sql 먼저. anon 키로 Supabase SQL editor 실행.
-- 매핑 규칙: docs/superpowers/plans/2026-06-28-public-workout-date-program.md (Task 5)
-- 데이터 원본: docs/data/season2-strength-8week-data.md

-- 0) 레거시 요일반복 공용(program_date 없는 공용)은 날짜기반 전환으로 미사용 → archive.
update workouts set archived = true
  where owner_user_id is null and program_date is null and archived = false;
```

- [ ] **Step 2: 세션 INSERT — 템플릿 패턴 (W1 월 7/6 · 스쿼트)**

각 세션은 CTE로 workout 먼저 넣고 동작을 잇는다. 첫 세션 예시(그대로 작성):
```sql
-- W1 · 2026-07-06 (월) · 스쿼트
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('스쿼트', null, null, '하체(스쿼트)', '2026-07-06', 'Strength 8주 · 1주차', 0)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'Back Squat',                  '5',     '@ 75% 1RM · 4~5개 남기기 · Rest 2:00', 0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Banded Strict Chest to bar',  '8',     '이중 점진',                            1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Single Arm DB Row',           '12/12', '이중 점진',                            2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Plank Shoulder Taps',         '0:30',  '전거근',                               3, 3, 'C. 안정화 · 2 Sets')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);
```

- [ ] **Step 3: 세션 INSERT — 피니셔/백오프 예시 (W1 화 7/7 · 덤벨 상체)**

피니셔(D)·단일 동작 처리 예시:
```sql
-- W1 · 2026-07-07 (화) · 덤벨 상체
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('덤벨 상체', null, null, '상체(밀기)', '2026-07-07', 'Strength 8주 · 1주차', 1)
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info)
select w.id, v.section, v.exercise_name, v.reps, v.notes, v.sort_order, v.set_group, v.set_info
from w, (values
  ('A', 'DB Hex Press',         '8',     '이중 점진',                          0, 1, 'A. 메인 · 4 Sets'),
  ('B', 'Bar/Box Dips',         '8~12',  null,                                 1, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('B', 'Close-grip Push up',   '10~15', null,                                 2, 2, 'B. 슈퍼셋 · 3 Sets'),
  ('C', 'Side Plank Hip Touch', '10/10', '항회전 코어',                        3, 3, 'C. 안정화 · 3 Sets'),
  ('D', 'Toes to bar',          '8',     '벅차면 Knee Raises 10개 · 오늘의 피니셔', 4, 4, 'D. 피니셔 · EMOM 8분')
) as v(section, exercise_name, reps, notes, sort_order, set_group, set_info);
```
백오프(W3 월 A에 `Back Squat` + `Back Squat (백오프)`)는 두 그룹으로: `set_group 1, 'A. 메인 · 5 Sets'` / `set_group 2, 'A. 백오프 · 1 Set'`(set_lead 생략=null=블록).

- [ ] **Step 4: 나머지 38세션 전사**

`docs/data/season2-strength-8week-data.md`의 W1 수~금 + W2~W8 전 세션을 Step 2/3 패턴과 **매핑 규칙**대로 작성한다. 각 세션 `sort_order`는 전체 날짜 인덱스(W1월=0 … W8금=39). `program_label`은 주차에 맞게. 동작/횟수/메모는 문서 그대로(단어 한 글자도 바꾸지 말 것), 메모의 `슈퍼셋 · ` 접두만 제거.

- [ ] **Step 5: 매핑 검증(체크리스트)**

문서와 시드를 1:1 대조:
- [ ] 세션 40개(평일 7/6~8/28), `program_date` 중복/누락 없음, `sort_order` 0~39.
- [ ] 각 세션 `title`/`category`/`program_label`(주차) 일치.
- [ ] 섹션별 `set_group`/`set_info`(세트수·역할) 일치. 백오프·세트수 다른 블록은 별도 그룹.
- [ ] 동작명/횟수(reps)/메모(notes) 문서 일치. 메모 `슈퍼셋 · ` 접두 제거 외 변경 없음.
- [ ] SQL 작은따옴표 이스케이프(`''`), `&` 같은 특수문자 정상.
- [ ] (가능하면) 로컬/스테이징에서 1회 실행해 에러 없는지 확인. 불가하면 SQL 문법 육안 검토.

- [ ] **Step 6: 커밋**

```bash
git add docs/data/season2-strength-8week-data.md supabase/seed-strength-8week.sql
git commit -m "feat(workout): 8주 스트렝스 공용 프로그램 시드 (40세션, 날짜기반)"
```

---

## 적용 / 배포 (구현 후 사용자 수동)

1. 사용자가 Supabase SQL editor에서 **`migration-workout-program.sql`** 실행(배포 전 필수).
2. 이어서 **`seed-strength-8week.sql`** 실행.
3. 모바일 시각 QA: 7/6 열어 스쿼트 세션이 A/B/C/D 블록(헤더 밴드, into 없음)으로, program_label eyebrow("Strength 8주 · 1주차") 표시. 7/7 덤벨상체(피니셔 포함). 개인운동은 into 유지.
4. 코드 `main` 머지 + push(Vercel 배포).

---

## Self-Review (작성자 점검 결과)

**1. 스펙 커버리지:** §5 모델→Task1(SQL/타입), §6 API→Task1, §7 렌더→Task3, §8 빌더→Task2, §9 시드→Task5, §6.4 그날뷰→Task4. program_label eyebrow→Task3 Step2. set_lead 연결자 3분기→Task3 Step3. 누락 없음.
**2. 플레이스홀더:** 코드 스텝은 전부 실제 코드. Task5 Step4(38세션 전사)는 데이터 문서를 소스로 한 전사 작업 — 규칙+완성 예시 2개 제시(데이터 중복 전사 회피). TBD/모호 지시 없음.
**3. 타입 일관성:** `getWorkoutsForDate`(Task1)=Task4 사용. `buildExercisesFromGroups`/`SetGroup`/`ExerciseRow`(Task2)=빌더 사용. `set_lead`/`set_group`/`set_info`/`program_label` 명칭 전 태스크 일치. `ExerciseGroup` 리네임(Task3)은 같은 태스크 내 정의·사용 모두 교체.
