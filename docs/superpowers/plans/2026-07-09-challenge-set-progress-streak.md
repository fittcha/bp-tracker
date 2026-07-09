# 챌린지 세트별 진행 + 완료/스트릭 보호 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 챌린지 day 상세에서 세트별 클릭 진행 추적(모두 완료 시 자동 성공, 부분 보존) + "전체 완료" 버튼(아카이브)과 같은 종목 7일 내 재시작 시 연속기록 이어받기.

**Architecture:** 신규 `challenge_day_progress` 테이블에 day별 완료 세트 인덱스(jsonb) 저장. `user_challenges`에 `completed_at·carried_streak·final_streak` 추가. 순수함수(`toggleSet`/`isDayComplete`/`computeStreakWithCarry`)는 derive.ts에, 나머지는 challenges.ts API + DayStatusSheet/ChallengeDashboardCard UI. 무효화는 기존 `onChanged`(→`mutate(matchPrefix('challenges', uid))`).

**Tech Stack:** Next.js 16(App Router, 'use client'), React 19, TypeScript, Supabase(public, anon key, RLS allow-all), SWR, vitest, Tailwind v4.

## Global Constraints

- 성공은 terminal(잠금). 성공 경로 2개: **세트 전부 클릭** 또는 **기존 성공 버튼** — 둘 다 유지, 둘 다 `addAttempt(success)`.
- 성공 시 세트 칩 잠금 + **잠금 해제 장치 필수**: "잠금 해제"(성공만 취소, done_sets 보존) + "기록 삭제"(성공 취소 + done_sets 초기화).
- 부분 진행은 서버 보존, **카드(밖)엔 미표시**(untried 그대로). 실패 attempt는 done_sets 보존.
- 스트릭 이어받기: **같은 종목만**, 완료 후 **7일 내** 시작. `carried`는 시작 시 스냅샷. `computeStreakWithCarry`는 오늘부터 훈련일 역순으로 세다 **시작일 이전으로 끊김 없이 넘어가면 carried 합산**, 중간 끊기면 미포함. 완료~시작 갭은 검사 안 함(면제).
- 완료 = **아카이브**(`status='archived'` + `completed_at` + `final_streak`), 삭제 아님(attempts 보존). getActiveChallenges는 `status='active'`만.
- done_sets = 0-based 세트 인덱스 배열. 총 세트 = `sets_text.split('·').length`.
- SWR 무효화는 `onChanged()` 콜백 경유(전역 mutate 금지). 테마 토큰만. 한국어 UI.
- 마이그레이션은 anon 키로 불가 → `supabase/migration-challenge-progress.sql`을 SQL 에디터에서 1회. 테이블 미존재 시 progress 로드는 빈 map 폴백(앱 안 죽음).
- 순수함수만 vitest, supabase/React는 `npx tsc --noEmit` + `npm run build` + 수동.

---

### Task 1: 마이그레이션 SQL

**Files:**
- Create: `supabase/migration-challenge-progress.sql`

**Interfaces:**
- Produces: `challenge_day_progress` 테이블, `user_challenges.completed_at/carried_streak/final_streak` 컬럼.

- [ ] **Step 1: 마이그레이션 파일 작성**

Create `supabase/migration-challenge-progress.sql`:

```sql
-- 챌린지 세트별 진행 + 완료/스트릭 보호
-- anon 키로 불가 → Supabase SQL 에디터에서 1회 실행(재실행 안전).

-- Part A: day별 완료 세트 진행
create table if not exists challenge_day_progress (
  id uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no int not null,
  done_sets jsonb not null default '[]',
  updated_at timestamptz not null default now(),
  unique (user_challenge_id, day_no)
);
alter table challenge_day_progress enable row level security;
drop policy if exists "cdp all" on challenge_day_progress;
create policy "cdp all" on challenge_day_progress for all using (true) with check (true);

-- Part B: 완료/스트릭 보호 컬럼
alter table user_challenges add column if not exists completed_at timestamptz;
alter table user_challenges add column if not exists carried_streak int not null default 0;
alter table user_challenges add column if not exists final_streak int not null default 0;
```

- [ ] **Step 2: Commit**

```bash
git add supabase/migration-challenge-progress.sql
git commit -m "feat(challenge): 세트진행/완료 마이그레이션 SQL"
```

---

### Task 2: 순수 함수 (TDD)

**Files:**
- Modify: `src/lib/challenge/derive.ts`
- Modify: `src/lib/challenge/derive.test.ts`

**Interfaces:**
- Produces:
  - `toggleSet(doneSets: number[], index: number): number[]`
  - `isDayComplete(doneSets: number[], totalSets: number): boolean`
  - `computeStreakWithCarry(trainingWeekdays: number[], attemptDates: string[], today: string, startDate: string, carried: number): { count: number; alive: boolean }`

- [ ] **Step 1: 실패 테스트 추가**

`src/lib/challenge/derive.test.ts` 상단 import에 새 함수 추가(기존 import 라인 확장):

```ts
import { toggleSet, isDayComplete, computeStreakWithCarry } from './derive'
```

파일 끝에 추가:

```ts
describe('toggleSet', () => {
  it('없으면 추가(정렬)', () => { expect(toggleSet([2, 0], 1)).toEqual([0, 1, 2]) })
  it('있으면 제거', () => { expect(toggleSet([0, 1, 2], 1)).toEqual([0, 2]) })
})

describe('isDayComplete', () => {
  it('모든 인덱스 채우면 true', () => { expect(isDayComplete([0, 1, 2], 3)).toBe(true) })
  it('일부면 false', () => { expect(isDayComplete([0, 2], 3)).toBe(false) })
  it('범위밖/중복 무시', () => { expect(isDayComplete([0, 0, 5], 3)).toBe(false) })
  it('total 0이면 false', () => { expect(isDayComplete([], 0)).toBe(false) })
})

describe('computeStreakWithCarry', () => {
  // 훈련요일 월(1)·수(3)·금(5)
  const wd = [1, 3, 5]
  it('시작일까지 무결 → carried 합산', () => {
    // 2026-07-06(월)~08(수)~10(금) 다 출석, 오늘 금, 시작 07-06, carried 12
    const r = computeStreakWithCarry(wd, ['2026-07-06', '2026-07-08', '2026-07-10'], '2026-07-10', '2026-07-06', 12)
    expect(r.count).toBe(15) // 3 + 12
  })
  it('중간 끊기면 carried 미포함', () => {
    // 07-08(수) 빠짐, 07-10만 출석, 오늘 금
    const r = computeStreakWithCarry(wd, ['2026-07-10'], '2026-07-10', '2026-07-06', 12)
    expect(r.count).toBe(1) // 금 1개, 수 미출석에서 끊김
  })
  it('기록 0 + 갓 시작 → carried 표시', () => {
    // 오늘=시작일 월, 아직 출석 전, carried 12
    const r = computeStreakWithCarry(wd, [], '2026-07-06', '2026-07-06', 12)
    expect(r.count).toBe(12)
    expect(r.alive).toBe(true)
  })
  it('carried 0이면 기존 스트릭과 동일(합산 없음)', () => {
    const r = computeStreakWithCarry(wd, ['2026-07-06', '2026-07-08'], '2026-07-08', '2026-07-06', 0)
    expect(r.count).toBe(2)
  })
})
```

- [ ] **Step 2: 실패 확인**

Run: `npx vitest run src/lib/challenge/derive.test.ts`
Expected: FAIL — `toggleSet`/`isDayComplete`/`computeStreakWithCarry` export 없음.

- [ ] **Step 3: 구현 추가**

`src/lib/challenge/derive.ts` 파일 끝에 추가(기존 `weekdayMon1`, `addDays` 헬퍼 재사용):

```ts
// 세트 완료 인덱스 토글(0-based). 순수.
export function toggleSet(doneSets: number[], index: number): number[] {
  return doneSets.includes(index)
    ? doneSets.filter((i) => i !== index)
    : [...doneSets, index].sort((a, b) => a - b)
}

// 유효 인덱스(0..total-1)가 total개 모두 채워졌는지. 순수.
export function isDayComplete(doneSets: number[], totalSets: number): boolean {
  if (totalSets <= 0) return false
  const valid = new Set(doneSets.filter((i) => Number.isInteger(i) && i >= 0 && i < totalSets))
  return valid.size === totalSets
}

// carried 이어받기 반영 스트릭. 오늘부터 훈련일 역순, startDate 이전으로 끊김없이 넘으면 carried 합산.
// startDate 이전(완료~시작 갭)은 검사하지 않음(=7일 보호). 중간 훈련일 미출석은 끊김.
export function computeStreakWithCarry(
  trainingWeekdays: number[],
  attemptDates: string[],
  today: string,
  startDate: string,
  carried: number,
): { count: number; alive: boolean } {
  if (trainingWeekdays.length === 0) {
    return carried > 0 ? { count: carried, alive: true } : { count: 0, alive: false }
  }
  const attended = new Set(attemptDates)
  const training = new Set(trainingWeekdays)
  const isTraining = (s: string) => training.has(weekdayMon1(s))

  let cur = today
  if (isTraining(cur) && !attended.has(cur)) cur = addDays(cur, -1) // 오늘 미출석 유예

  let count = 0
  while (cur >= startDate) {
    if (isTraining(cur)) {
      if (attended.has(cur)) count++
      else return { count, alive: count > 0 } // 끊김 → carried 미포함
    }
    cur = addDays(cur, -1)
  }
  const total = count + carried // startDate 이전으로 무결 도달 → carried 합산
  return { count: total, alive: total > 0 }
}
```

- [ ] **Step 4: 통과 확인**

Run: `npx vitest run src/lib/challenge/derive.test.ts`
Expected: PASS (신규 + 기존 전부).

- [ ] **Step 5: Commit**

```bash
git add src/lib/challenge/derive.ts src/lib/challenge/derive.test.ts
git commit -m "feat(challenge): toggleSet/isDayComplete/computeStreakWithCarry 순수함수"
```

---

### Task 3: challenge API 확장

**Files:**
- Modify: `src/lib/api/challenges.ts`

**Interfaces:**
- Consumes: 없음(순수 supabase).
- Produces:
  - `UserChallenge`에 `completed_at: string | null; carried_streak: number; final_streak: number`
  - `ActiveChallenge`에 `progress: Record<number, number[]>`
  - `setDayProgress(userChallengeId: string, dayNo: number, doneSets: number[]): Promise<void>`
  - `clearDayProgress(userChallengeId: string, dayNo: number): Promise<void>`
  - `completeChallenge(userChallengeId: string, finalStreak: number): Promise<void>`
  - `startChallenge`는 내부에서 `carried_streak` 산출(시그니처 불변)

- [ ] **Step 1: 타입 확장**

`UserChallenge` 인터페이스(29-39행)에 3줄 추가:

```ts
export interface UserChallenge {
  id: string
  user_id: string
  template_key: string
  program_id: string
  difficulty: Record<string, unknown>
  training_weekdays: number[]
  started_at: string
  status: 'active' | 'archived'
  created_at?: string
  completed_at?: string | null
  carried_streak?: number
  final_streak?: number
}
```

`ActiveChallenge` 인터페이스(50-54행)에 progress 추가:

```ts
export interface ActiveChallenge {
  challenge: UserChallenge
  days: ChallengeProgramDay[]
  attempts: ChallengeAttempt[]
  progress: Record<number, number[]> // day_no → 완료 세트 인덱스
}
```

- [ ] **Step 2: progress 로더 + getActiveChallenges 반영**

`getAttempts`(90-98행) 아래에 추가:

```ts
async function getDayProgress(userChallengeId: string): Promise<Record<number, number[]>> {
  const { data, error } = await supabase
    .from('challenge_day_progress')
    .select('day_no, done_sets')
    .eq('user_challenge_id', userChallengeId)
  if (error) {
    if (error.code === MISSING) return {} // 테이블 미생성 폴백
    throw error
  }
  const map: Record<number, number[]> = {}
  for (const r of (data ?? []) as { day_no: number; done_sets: number[] }[]) {
    map[r.day_no] = Array.isArray(r.done_sets) ? r.done_sets : []
  }
  return map
}
```

`getActiveChallenges`(100-121행)의 `Promise.all` 매핑에 progress 로드 추가:

```ts
  return Promise.all(
    challenges.map(async (challenge) => {
      const [days, attempts, progress] = await Promise.all([
        getProgramDays(challenge.program_id),
        getAttempts(challenge.id),
        getDayProgress(challenge.id),
      ])
      return { challenge, days, attempts, progress }
    }),
  )
```

- [ ] **Step 3: setDayProgress / clearDayProgress 추가**

`addAttempt` 함수 아래(174행 근처)에 추가:

```ts
export async function setDayProgress(userChallengeId: string, dayNo: number, doneSets: number[]): Promise<void> {
  const { error } = await supabase
    .from('challenge_day_progress')
    .upsert(
      { user_challenge_id: userChallengeId, day_no: dayNo, done_sets: doneSets, updated_at: new Date().toISOString() },
      { onConflict: 'user_challenge_id,day_no' },
    )
  if (error) throw error
}

export async function clearDayProgress(userChallengeId: string, dayNo: number): Promise<void> {
  const { error } = await supabase
    .from('challenge_day_progress')
    .delete()
    .eq('user_challenge_id', userChallengeId)
    .eq('day_no', dayNo)
  if (error) throw error
}
```

- [ ] **Step 4: startChallenge에 carried 산출**

`startChallenge`(123-143행)를 교체 — insert 전에 같은 종목 7일 내 완료 챌린지의 final_streak 조회:

```ts
export async function startChallenge(p: {
  userId: string
  templateKey: string
  programId: string
  difficulty: Record<string, unknown>
  trainingWeekdays: number[]
}): Promise<UserChallenge> {
  // 같은 종목, 7일 내 완료건의 final_streak 이어받기
  const cutoff = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
  const { data: prev } = await supabase
    .from('user_challenges')
    .select('final_streak, completed_at')
    .eq('user_id', p.userId)
    .eq('template_key', p.templateKey)
    .eq('status', 'archived')
    .not('completed_at', 'is', null)
    .gte('completed_at', cutoff)
    .order('completed_at', { ascending: false })
    .limit(1)
    .maybeSingle()
  const carried = (prev?.final_streak as number | undefined) ?? 0

  const { data, error } = await supabase
    .from('user_challenges')
    .insert({
      user_id: p.userId,
      template_key: p.templateKey,
      program_id: p.programId,
      difficulty: p.difficulty,
      training_weekdays: p.trainingWeekdays,
      carried_streak: carried,
    })
    .select()
    .single()
  if (error) throw error
  return data as UserChallenge
}
```

- [ ] **Step 5: completeChallenge 추가**

`deleteChallenge`(218-224행) 위에 추가:

```ts
// 완료: 아카이브 + 완료시각 + 스트릭 스냅샷(삭제 아님, attempts 보존).
export async function completeChallenge(userChallengeId: string, finalStreak: number): Promise<void> {
  const { error } = await supabase
    .from('user_challenges')
    .update({ status: 'archived', completed_at: new Date().toISOString(), final_streak: finalStreak })
    .eq('id', userChallengeId)
  if (error) throw error
}
```

- [ ] **Step 6: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 에러 없음. (getActiveChallenges 반환에 progress 추가로 ActiveChallenge 소비처가 optional 아님 → Task 5에서 카드가 사용. 이 시점 tsc는 progress를 항상 세팅하므로 통과.)

- [ ] **Step 7: Commit**

```bash
git add src/lib/api/challenges.ts
git commit -m "feat(challenge): progress 로드/저장 + completeChallenge + startChallenge carried"
```

---

### Task 4: DayStatusSheet — 세트 토글 + 잠금 + 잠금해제

**Files:**
- Modify: `src/components/challenge/DayStatusSheet.tsx`

**Interfaces:**
- Consumes: 부모(Task 5)가 넘기는 새 props.
- Produces: `DayStatusSheetProps`에 `doneSets: number[]`, `totalSets: number`, `onToggleSet: (index: number) => void`, `onUnlock: () => void`, `onClearProgress` 통합(기존 `onDeleteAttempt`가 성공+진행 초기화 담당).

- [ ] **Step 1: props 확장 + 세트 칩을 토글 버튼으로**

`DayStatusSheetProps`(8-19행)에 추가:

```ts
interface DayStatusSheetProps {
  isOpen: boolean
  weekNo: number
  dayInWeek: number
  setsText: string
  restSeconds: number | null
  doneSets: number[]
  onToggleSet: (index: number) => void
  onUnlock: () => void
  state: { status: DayStatus; doneDate: string | null; successAttemptId: string | null } | null
  onClose: () => void
  onLog: (result: 'success' | 'fail', doneDate: string) => void
  onUpdateDate: (attemptId: string, doneDate: string) => void
  onDeleteAttempt: (attemptId: string) => void
}
```

구조분해(23-25행)에 `doneSets, onToggleSet, onUnlock` 추가.

세트 칩 블록(63-69행)을 교체 — 클릭 토글 + 성공 시 잠금:

```tsx
              <div className="flex flex-wrap gap-1.5">
                {sets.map((s, i) => {
                  const done = status === 'success' || doneSets.includes(i)
                  const locked = status === 'success'
                  return (
                    <button
                      key={i}
                      type="button"
                      disabled={locked}
                      onClick={() => onToggleSet(i)}
                      aria-pressed={done}
                      className={`min-w-[2.75rem] text-center px-2.5 py-2 rounded-lg border text-base font-medium tabular-nums transition-colors ${
                        done ? 'border-accent bg-accent text-white' : 'border-accent/40 text-foreground active:bg-accent-light'
                      } ${locked ? 'opacity-100 cursor-default' : ''}`}
                    >
                      {s}
                    </button>
                  )
                })}
              </div>
```

- [ ] **Step 2: 성공 상태 액션에 "잠금 해제" 추가**

성공 상태 블록(92-124행)의 "성공 완료 문구 + 휴지통" 줄(110-123행)을 교체 — 잠금 해제 버튼 추가:

```tsx
              {/* 성공 완료 + 잠금해제(수정) + 휴지통(완전삭제) */}
              <div className="flex items-center justify-center gap-4 pt-1">
                <p className="inline-flex items-center gap-1.5 text-sm font-medium text-success">
                  <Check size={16} /> 성공 완료
                </p>
                <button
                  onClick={onUnlock}
                  className="px-3 py-1.5 rounded-lg border border-border text-xs font-medium text-text-secondary active:bg-background"
                >
                  잠금 해제
                </button>
                <button
                  onClick={() => state?.successAttemptId && onDeleteAttempt(state.successAttemptId)}
                  disabled={!state?.successAttemptId}
                  className="w-8 h-8 flex items-center justify-center rounded-lg border border-danger/40 text-danger active:bg-danger/10 disabled:opacity-50"
                  aria-label="기록 삭제"
                >
                  <Trash2 size={15} />
                </button>
              </div>
```

- [ ] **Step 3: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 부모가 아직 새 props를 안 넘겨 에러 발생 예상 — Task 5에서 해소. 이 태스크 단독 커밋 후 Task 5와 함께 통과.

(주: 이 태스크는 Task 5와 짝. 커밋만 하고 최종 tsc/build는 Task 5 말미에서 확인.)

- [ ] **Step 4: Commit**

```bash
git add src/components/challenge/DayStatusSheet.tsx
git commit -m "feat(challenge): DayStatusSheet 세트 토글 + 성공 잠금/잠금해제"
```

---

### Task 5: ChallengeDashboardCard — 배선 + 완료 버튼 + carried 스트릭

**Files:**
- Modify: `src/components/challenge/ChallengeDashboardCard.tsx`

**Interfaces:**
- Consumes: `setDayProgress`/`clearDayProgress`/`completeChallenge`(Task 3), `toggleSet`/`isDayComplete`/`computeStreakWithCarry`(Task 2), DayStatusSheet 새 props(Task 4), `active.progress`(Task 3).

- [ ] **Step 1: import 확장**

상단 import 교체:

```tsx
import { RotateCcw, Flame, MoreVertical, Pencil, Trash2, CheckCircle2 } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreakWithCarry, monthlyAttemptCount, toggleSet, isDayComplete, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, deleteAttempt, resetChallenge, deleteChallenge,
  setDayProgress, clearDayProgress, completeChallenge,
  type ActiveChallenge, type ChallengeTemplate, type ChallengeProgramDay,
} from '@/lib/api/challenges'
```

- [ ] **Step 2: progress·스트릭·핸들러 반영**

컴포넌트 상단(22-31행 근처)에서 `active` 구조분해에 `progress` 추가 + 스트릭 교체:

```tsx
  const { challenge, days, attempts, progress } = active
```

스트릭 계산(30행) 교체:

```tsx
  const startDate = challenge.started_at.slice(0, 10)
  const streak = computeStreakWithCarry(challenge.training_weekdays, attemptDates, today, startDate, challenge.carried_streak ?? 0)
```

`openDayObj`/`openState` 아래에 openDay의 done_sets + total 파생 + 토글/잠금해제 핸들러 추가:

```tsx
  const openDoneSets = openDay != null ? (progress[openDay] ?? []) : []
  const openTotalSets = openDayObj?.sets_text ? openDayObj.sets_text.split('·').length : 0

  async function handleToggleSet(index: number) {
    if (openDay == null) return
    const next = toggleSet(progress[openDay] ?? [], index)
    await setDayProgress(challenge.id, openDay, next)
    if (isDayComplete(next, openTotalSets)) {
      await addAttempt({ userChallengeId: challenge.id, dayNo: openDay, result: 'success', doneDate: toDateString(new Date()) })
    }
    onChanged()
  }
  async function handleUnlock() {
    if (openDay == null || openState?.successAttemptId == null) return
    await deleteAttempt(openState.successAttemptId) // done_sets 보존 → 편집 가능
    setOpenDay(null)
    onChanged()
  }
```

`handleDeleteAttempt`(66-71행) 교체 — 성공 삭제 시 진행도 초기화:

```tsx
  async function handleDeleteAttempt(attemptId: string) {
    if (!confirm('이 성공 기록을 삭제할까요? 세트 진행도 함께 초기화돼요. (되돌릴 수 없어요)')) return
    if (openDay != null) await clearDayProgress(challenge.id, openDay)
    await deleteAttempt(attemptId)
    setOpenDay(null)
    onChanged()
  }
```

`handleComplete` 추가(handleDelete 근처):

```tsx
  async function handleComplete() {
    if (!confirm('이 챌린지를 완료할까요?\n기록은 보존되고, 7일 안에 같은 종목 다음 난이도를 시작하면 연속기록이 이어져요.')) return
    await completeChallenge(challenge.id, streak.count)
    onChanged()
  }
```

- [ ] **Step 3: ⋯ 메뉴에 완료 + carried 배지**

⋯ 메뉴(수정/초기화/삭제, 106-114행)의 "수정" 아래에 "완료" 추가:

```tsx
                <button onClick={() => { setMenuOpen(false); setEditOpen(true) }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground hover:bg-background">
                  <Pencil size={14} /> 수정
                </button>
                <button onClick={() => { setMenuOpen(false); handleComplete() }} className="w-full flex items-center gap-2 px-3 py-2 text-sm text-accent-pop hover:bg-background">
                  <CheckCircle2 size={14} /> 완료(다음 난이도로)
                </button>
```

난이도 라벨(89행) 아래에 carried 배지 추가:

```tsx
          {diffLabel && <p className="text-[11px] text-text-secondary mt-0.5 truncate">{diffLabel}</p>}
          {(challenge.carried_streak ?? 0) > 0 && (
            <p className="text-[10px] font-semibold text-accent-pop mt-0.5">🔥 이전 기록 {challenge.carried_streak}일 이어받음</p>
          )}
```

- [ ] **Step 4: DayStatusSheet에 새 props 전달**

`<DayStatusSheet ... />`(148-159행)에 props 추가:

```tsx
      <DayStatusSheet
        isOpen={openDay != null}
        weekNo={openDayObj?.week_no ?? 0}
        dayInWeek={openDayObj?.day_in_week ?? 0}
        setsText={openDayObj?.sets_text ?? ''}
        restSeconds={openDayObj?.rest_seconds ?? null}
        doneSets={openDoneSets}
        totalSets={openTotalSets}
        onToggleSet={handleToggleSet}
        onUnlock={handleUnlock}
        state={openState ? { status: openState.status, doneDate: openState.doneDate, successAttemptId: openState.successAttemptId } : null}
        onClose={() => setOpenDay(null)}
        onLog={handleLog}
        onUpdateDate={handleUpdateDate}
        onDeleteAttempt={handleDeleteAttempt}
      />
```

- [ ] **Step 5: 타입 검증 + 빌드**

Run: `npx tsc --noEmit`
Expected: 에러 없음(Task 4 DayStatusSheet props와 정합).

Run: `npm run build`
Expected: 빌드 성공.

- [ ] **Step 6: Commit**

```bash
git add src/components/challenge/ChallengeDashboardCard.tsx
git commit -m "feat(challenge): 세트토글/완료버튼/carried스트릭 배선 + DayStatusSheet 연결"
```

---

### Task 6: 대시보드 안내문구 + 최종 확인

**Files:**
- Modify: `src/app/challenge/page.tsx`

**Interfaces:**
- Consumes: 없음(문구만).

- [ ] **Step 1: 대시보드 상단 안내 1줄**

`src/app/challenge/page.tsx`에서 활성 카드 목록(`{data...map(... ChallengeDashboardCard ...)}`, 40행 근처) **위**에, 활성 챌린지가 1개 이상일 때 안내 1줄 추가:

```tsx
      {(data?.actives.length ?? 0) > 0 && (
        <p className="text-[11px] text-text-secondary/80 px-1 mb-2">
          💡 완주 후 <span className="font-semibold text-text-secondary">7일 안에</span> 다음 난이도를 시작하면 🔥연속기록이 이어져요. (카드 ⋯ → 완료)
        </p>
      )}
```

(정확한 위치: `actives.map` 렌더 컨테이너 바로 앞. 기존 구조에 맞춰 삽입.)

- [ ] **Step 2: 타입 검증 + 빌드**

Run: `npx tsc --noEmit && npm run build`
Expected: 둘 다 성공.

- [ ] **Step 3: 기존 테스트 회귀**

Run: `npm test`
Expected: 전부 PASS(derive 신규 포함).

- [ ] **Step 4: Commit**

```bash
git add src/app/challenge/page.tsx
git commit -m "feat(challenge): 대시보드 스트릭 보호 안내문구"
```

---

## 수동 확인 (구현 후)
- day 상세: 세트 칩 클릭→채움/해제, 전부 채우면 자동 성공+잠금, 성공 상태 "잠금 해제"→편집 가능/"기록 삭제"→초기화. 실패 후에도 진행 유지.
- 완료: ⋯→완료→확인문구→카드 사라짐(활성 목록). 같은 종목 새 챌린지 7일 내 시작 시 "이어받음" 배지 + 스트릭 유지.
- 안내문구 대시보드 상단 표시.

## 배포 후 액션 (구현 외)
- `supabase/migration-challenge-progress.sql`을 Supabase SQL 에디터에서 1회 실행(테이블+3컬럼). 미적용 시 세트진행/완료/이어받기 무동작(앱은 폴백으로 정상).

## Self-Review

**1. Spec coverage:**
- 세트 토글/자동성공/부분보존/카드미표시 → Task 4·5 ✅
- 성공 잠금 + 잠금해제(성공만 취소) + 기록삭제(초기화) → Task 4·5 ✅
- 성공/실패 버튼 유지 → DayStatusSheet 기존 유지(Task 4는 세트칩·성공액션만 변경, 실패/성공 버튼 블록 그대로) ✅
- challenge_day_progress + 3컬럼 마이그레이션 → Task 1 ✅
- setDayProgress/clearDayProgress/completeChallenge/startChallenge carried → Task 3 ✅
- computeStreakWithCarry(브릿지·끊김·갭면제) → Task 2 ✅
- 완료=아카이브(보존) → Task 3·5 ✅
- 같은종목 7일 이어받기 → Task 3(startChallenge) ✅
- 안내문구 3곳(완료 다이얼로그·carried 배지·대시보드 상단) → Task 5·6 ✅
- 폴백(테이블 미존재 빈 map) → Task 3 getDayProgress ✅

**2. Placeholder scan:** "TBD/적절히" 없음. 코드 스텝마다 완전 코드.

**3. Type consistency:** `progress: Record<number, number[]>`, `carried_streak?`, `computeStreakWithCarry(training, dates, today, startDate, carried)`, `setDayProgress(id, dayNo, doneSets)`, `completeChallenge(id, finalStreak)`, DayStatusSheet `doneSets/totalSets/onToggleSet/onUnlock` — 태스크 간 일치.
