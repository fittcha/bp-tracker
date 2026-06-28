# 챌린지 탭 (제공 챌린지 Phase 2a) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 제공 챌린지(풀업·푸쉬업)를 골라 난이도·훈련요일을 정해 시작하고, day별 목표 횟수표를 미도전→성공/실패/재도전으로 기록하며, 스트릭·이번 달 도전 횟수를 챌린지 탭과 홈 위젯에 노출한다.

**Architecture:** Supabase public 스키마에 정의(시드)·진행 테이블을 추가한다. day 상태·스트릭·횟수는 모두 append-only `challenge_attempts`에서 **파생**(순수 함수). 챌린지 탭은 active 인스턴스별 대시보드 카드(day 시퀀스 그리드 + 하단 시트), 홈은 정사각형 위젯 카드. 설계 문서: `docs/superpowers/specs/2026-06-28-challenge-tab-design.md`.

**Tech Stack:** Next.js 16 (App Router) + TypeScript + Tailwind v4 + Supabase JS v2 + lucide-react. 순수 로직 단위 테스트만 vitest 신규 도입.

## Global Constraints

- 인터랙티브 컴포넌트는 파일 최상단 `'use client'`.
- 모달/팝업/시트는 기존 패턴 준수: `fixed inset-0 z-50 flex items-end justify-center` + `absolute inset-0 bg-black/40` 백드롭 + `relative w-full max-w-lg bg-surface rounded-t-2xl p-6 pb-8 animate-slide-up`, 그리고 `if (!isOpen) return null`.
- 색상은 시맨틱 토큰만: `bg-surface` `bg-background` `border-border` `text-foreground` `text-text-secondary` `text-accent` `bg-accent text-white` `text-accent-pop`(골드) `bg-success`(파랑) `bg-danger`(빨강). 임의 hex 금지.
- 스트릭 살아있음=골드(`accent-pop`), 끊김=회색(`text-secondary`). day 성공=`success`(파랑), 실패=`danger`(빨강), 미도전=회색.
- 날짜 문자열은 항상 `YYYY-MM-DD` (`toDateString(new Date())` from `@/lib/utils`).
- 로그인 사용자: `getLoggedInUser()` from `@/lib/auth` → `{ id, username } | null`.
- Supabase 호출은 테이블 미생성 시 `error.code === 'PGRST205'` → 빈 배열/널 반환(`src/lib/api/pr.ts` 패턴).
- UI 카피는 한국어.
- 신규 런타임 의존성 추가 금지. vitest는 devDependency만.
- 라이브 DB 적용·시각 QA는 **사용자 소유 수동 단계**(시즌 관례). 자동 게이트는 `npx tsc --noEmit`, `npm run lint`, `npx vitest run`.

---

### Task 1: DB 마이그레이션 + 시드 SQL

**Files:**
- Create: `supabase/migration-challenges.sql`
- Create: `supabase/seed-challenges.sql`

**Interfaces:**
- Produces (테이블/컬럼, 이후 모든 Task가 의존):
  - `challenge_templates(key text pk, name, exercise, difficulty_mode 'equipment'|'range', sort_order)`
  - `challenge_programs(id uuid pk, template_key, difficulty_key text null, label text)` · unique(template_key, difficulty_key)
  - `challenge_program_days(id, program_id, day_no int, target_reps int)` · unique(program_id, day_no)
  - `user_challenges(id, user_id, template_key, program_id, difficulty jsonb, training_weekdays int[], started_at date, status 'active'|'archived')`
  - `challenge_attempts(id, user_challenge_id, day_no int, result 'success'|'fail', done_date date)`

- [ ] **Step 1: 마이그레이션 SQL 작성**

`supabase/migration-challenges.sql`:

```sql
-- 챌린지 (제공 챌린지 Phase 2a). 기존 테이블은 건드리지 않는다.
-- 설계: docs/superpowers/specs/2026-06-28-challenge-tab-design.md

-- 1) 챌린지 종류 (시드, 읽기 전용)
create table if not exists challenge_templates (
  key             text primary key,                 -- 'pullup' | 'pushup'
  name            text not null,                    -- '풀업 챌린지'
  exercise        text not null,                    -- '풀업'
  difficulty_mode text not null check (difficulty_mode in ('equipment','range')),
  sort_order      int  not null default 0,
  created_at      timestamptz not null default now()
);

-- 2) day별 목표 횟수표 (난이도 구간별 1개)
create table if not exists challenge_programs (
  id            uuid primary key default gen_random_uuid(),
  template_key  text not null references challenge_templates(key) on delete cascade,
  difficulty_key text,                              -- 풀업=NULL / 푸쉬업='knee_10_15' 등
  label         text,                               -- 표시용
  created_at    timestamptz not null default now(),
  unique (template_key, difficulty_key)
);

create table if not exists challenge_program_days (
  id          uuid primary key default gen_random_uuid(),
  program_id  uuid not null references challenge_programs(id) on delete cascade,
  day_no      int  not null,
  target_reps int  not null,
  unique (program_id, day_no)
);

-- 3) 도전 인스턴스
create table if not exists user_challenges (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references users(id) on delete cascade,
  template_key     text not null references challenge_templates(key),
  program_id       uuid not null references challenge_programs(id),
  difficulty       jsonb not null default '{}'::jsonb,
  training_weekdays int[] not null default '{1,2,3,4,5}',   -- 1=월 .. 7=일
  started_at       date not null default current_date,
  status           text not null default 'active' check (status in ('active','archived')),
  created_at       timestamptz not null default now()
);

-- 4) 도전 시도 이력 (append-only)
create table if not exists challenge_attempts (
  id                uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no            int  not null,
  result            text not null check (result in ('success','fail')),
  done_date         date not null default current_date,
  created_at        timestamptz not null default now()
);

-- 5) 인덱스
create index if not exists idx_user_challenges_user on user_challenges(user_id, status);
create index if not exists idx_challenge_attempts_uc on challenge_attempts(user_challenge_id, day_no);
create index if not exists idx_challenge_attempts_date on challenge_attempts(user_challenge_id, done_date);
```

- [ ] **Step 2: 시드 SQL 작성 (구조 + 임시 샘플 숫자)**

`supabase/seed-challenges.sql`:

```sql
-- ⚠️ target_reps / 푸쉬업 구간은 임시 샘플. 표 이미지 수령 후 실제 값으로 교체할 것.
insert into challenge_templates (key, name, exercise, difficulty_mode, sort_order) values
  ('pullup', '풀업 챌린지',  '풀업',  'equipment', 1),
  ('pushup', '푸쉬업 챌린지', '푸쉬업', 'range',     2)
on conflict (key) do nothing;

-- 풀업: 공통 프로그램 1개 (difficulty_key = null)
with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pullup', null, '풀업 공통')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,3),(2,4),(3,4),(4,5),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10)) as d(day_no, target_reps);

-- 푸쉬업: 구간별 프로그램 (니/풀 예시 2개)
with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pushup', 'knee_10_15', '니푸쉬업 (최대 10~15개)')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,5),(2,6),(3,8),(4,10),(5,12)) as d(day_no, target_reps);

with p as (
  insert into challenge_programs (template_key, difficulty_key, label)
  values ('pushup', 'full_15_25', '푸쉬업 (최대 15~25개)')
  on conflict (template_key, difficulty_key) do nothing
  returning id
)
insert into challenge_program_days (program_id, day_no, target_reps)
select p.id, d.day_no, d.target_reps from p,
  (values (1,10),(2,12),(3,15),(4,18),(5,20)) as d(day_no, target_reps);
```

- [ ] **Step 3: SQL 자체 검토**

확인: 5개 테이블 `create table if not exists`, FK가 `users(id)`/`challenge_*` 올바르게 참조, `check` 제약(difficulty_mode/status/result) 존재, unique 제약 2개, 인덱스 3개. 시드는 `on conflict do nothing`으로 재실행 안전.

- [ ] **Step 4: (수동) 라이브 적용 — 사용자 단계**

Supabase SQL Editor에 `migration-challenges.sql` → `seed-challenges.sql` 순서로 실행. 검증 쿼리:
```sql
select key, difficulty_mode from challenge_templates order by sort_order;        -- 2행
select template_key, difficulty_key, label from challenge_programs order by 1,2; -- 3행
select count(*) from challenge_program_days;                                     -- 20행
```
> 자동 실행 불가(DB 크리덴셜 없음). 적용 전까지 앱은 `PGRST205` 가드로 빈 상태 표시.

- [ ] **Step 5: 커밋**

```bash
git add supabase/migration-challenges.sql supabase/seed-challenges.sql
git commit -m "feat(challenge): DB 마이그레이션 + 시드 SQL (제공 챌린지 테이블)"
```

---

### Task 2: 파생 로직 순수 함수 (TDD, vitest)

**Files:**
- Modify: `package.json` (vitest devDependency + `test` 스크립트)
- Create: `src/lib/challenge/derive.ts`
- Test: `src/lib/challenge/derive.test.ts`

**Interfaces:**
- Produces (Task 3·6·8이 의존):
  - `type DayStatus = 'untried' | 'fail' | 'success'`
  - `interface AttemptInput { id: string; day_no: number; result: 'success'|'fail'; done_date: string; created_at?: string }`
  - `interface DayState { day_no: number; status: DayStatus; doneDate: string | null; successAttemptId: string | null }`
  - `deriveDayStates(attempts: AttemptInput[]): Map<number, DayState>`
  - `computeStreak(trainingWeekdays: number[], attemptDates: string[], today: string): { count: number; alive: boolean }`
  - `monthlyAttemptCount(doneDates: string[], yearMonth: string): number`  // yearMonth='YYYY-MM'

- [ ] **Step 1: vitest 설치 + 스크립트 추가**

```bash
npm install -D vitest
```
`package.json`의 `scripts`에 추가(기존 줄 유지):
```json
    "lint": "eslint",
    "test": "vitest run"
```

- [ ] **Step 2: 실패 테스트 작성**

`src/lib/challenge/derive.test.ts`:

```ts
import { describe, it, expect } from 'vitest'
import { deriveDayStates, computeStreak, monthlyAttemptCount } from './derive'

describe('deriveDayStates', () => {
  it('attempt 없으면 빈 맵', () => {
    expect(deriveDayStates([]).size).toBe(0)
  })
  it('success는 잠금 — fail 순서와 무관하게 success 유지', () => {
    const m = deriveDayStates([
      { id: 'a', day_no: 1, result: 'fail', done_date: '2026-06-01' },
      { id: 'b', day_no: 1, result: 'success', done_date: '2026-06-03' },
      { id: 'c', day_no: 1, result: 'fail', done_date: '2026-06-05' },
    ])
    expect(m.get(1)).toEqual({ day_no: 1, status: 'success', doneDate: '2026-06-03', successAttemptId: 'b' })
  })
  it('fail만 있으면 최신 fail 날짜 보존', () => {
    const m = deriveDayStates([
      { id: 'a', day_no: 2, result: 'fail', done_date: '2026-06-01' },
      { id: 'b', day_no: 2, result: 'fail', done_date: '2026-06-04' },
    ])
    expect(m.get(2)).toEqual({ day_no: 2, status: 'fail', doneDate: '2026-06-04', successAttemptId: null })
  })
})

describe('computeStreak (1=월..7=일)', () => {
  const MONFRI = [1, 2, 3, 4, 5]
  it('attempt 없으면 0/끊김', () => {
    expect(computeStreak(MONFRI, [], '2026-06-24')).toEqual({ count: 0, alive: false })
  })
  it('주말을 건너뛰고 연속 유지 (오늘=수, 미출석=살아있음)', () => {
    // 2026-06-18 목, 19 금, 22 월, 23 화 출석 / 24 수(오늘) 미출석
    const dates = ['2026-06-18', '2026-06-19', '2026-06-22', '2026-06-23']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 4, alive: true })
  })
  it('오늘도 출석하면 카운트 포함', () => {
    const dates = ['2026-06-22', '2026-06-23', '2026-06-24']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 3, alive: true })
  })
  it('지나간 훈련일 미출석이면 끊김(회색)', () => {
    // 22 월 출석, 23 화 미출석(지나감), 24 수 오늘
    expect(computeStreak(MONFRI, ['2026-06-22'], '2026-06-24')).toEqual({ count: 0, alive: false })
  })
  it('같은 날 여러 attempt는 1일로 묶임', () => {
    const dates = ['2026-06-23', '2026-06-23', '2026-06-24']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 2, alive: true })
  })
})

describe('monthlyAttemptCount', () => {
  it('해당 월 attempt 수(중복 날짜도 각각 카운트)', () => {
    const dates = ['2026-06-01', '2026-06-01', '2026-06-30', '2026-05-31', '2026-07-01']
    expect(monthlyAttemptCount(dates, '2026-06')).toBe(3)
  })
})
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `npx vitest run src/lib/challenge/derive.test.ts`
Expected: FAIL — `derive.ts` 없음 / 함수 미정의.

- [ ] **Step 4: 구현 작성**

`src/lib/challenge/derive.ts`:

```ts
// 챌린지 파생 로직 (순수 함수, 의존성 없음 — 단위 테스트 대상)
// day 상태·스트릭·도전 횟수는 모두 append-only attempts에서 파생한다.

export type DayStatus = 'untried' | 'fail' | 'success'

export interface AttemptInput {
  id: string
  day_no: number
  result: 'success' | 'fail'
  done_date: string // YYYY-MM-DD
  created_at?: string
}

export interface DayState {
  day_no: number
  status: DayStatus
  doneDate: string | null // success면 성공일, fail이면 최신 fail일, untried면 null
  successAttemptId: string | null
}

// day_no별 현재 상태: success > fail > untried. success는 잠금(terminal).
export function deriveDayStates(attempts: AttemptInput[]): Map<number, DayState> {
  const map = new Map<number, DayState>()
  for (const a of attempts) {
    const cur = map.get(a.day_no)
    if (!cur) {
      map.set(a.day_no, {
        day_no: a.day_no,
        status: a.result,
        doneDate: a.done_date,
        successAttemptId: a.result === 'success' ? a.id : null,
      })
      continue
    }
    if (cur.status === 'success') continue // 이미 잠금
    if (a.result === 'success') {
      cur.status = 'success'
      cur.doneDate = a.done_date
      cur.successAttemptId = a.id
    } else if (cur.doneDate == null || a.done_date >= cur.doneDate) {
      cur.doneDate = a.done_date // 최신 fail 날짜
    }
  }
  return map
}

// ── 날짜 헬퍼 (YYYY-MM-DD, 로컬) ──
function parseYmd(s: string): Date {
  const [y, m, d] = s.split('-').map(Number)
  return new Date(y, m - 1, d)
}
function fmtYmd(dt: Date): string {
  const y = dt.getFullYear()
  const m = String(dt.getMonth() + 1).padStart(2, '0')
  const d = String(dt.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}
function weekdayMon1(s: string): number {
  const wd = parseYmd(s).getDay() // 0=일..6=토
  return wd === 0 ? 7 : wd // 1=월..7=일
}
function addDays(s: string, n: number): string {
  const dt = parseYmd(s)
  dt.setDate(dt.getDate() + n)
  return fmtYmd(dt)
}

// 훈련요일 기준 연속 출석. 비훈련요일은 건너뜀. 오늘 미출석은 끊김 아님(유지).
export function computeStreak(
  trainingWeekdays: number[],
  attemptDates: string[],
  today: string,
): { count: number; alive: boolean } {
  if (trainingWeekdays.length === 0 || attemptDates.length === 0) return { count: 0, alive: false }
  const attended = new Set(attemptDates)
  const training = new Set(trainingWeekdays)
  const isTraining = (s: string) => training.has(weekdayMon1(s))

  let floor = attemptDates[0]
  for (const d of attemptDates) if (d < floor) floor = d

  let cur = today
  // 오늘이 훈련일인데 미출석이면 유예: 어제부터 따짐
  if (isTraining(cur) && !attended.has(cur)) cur = addDays(cur, -1)

  let count = 0
  while (cur >= floor) {
    if (isTraining(cur)) {
      if (attended.has(cur)) count++
      else break // 지나간 훈련일 미출석 → 끊김
    }
    cur = addDays(cur, -1)
  }
  return { count, alive: count > 0 }
}

// 이번 달 도전 횟수 = 그 달 done_date를 가진 attempt 수(중복 날짜 각각 카운트)
export function monthlyAttemptCount(doneDates: string[], yearMonth: string): number {
  return doneDates.filter((d) => d.slice(0, 7) === yearMonth).length
}
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `npx vitest run src/lib/challenge/derive.test.ts`
Expected: PASS (모든 케이스 green).

- [ ] **Step 6: 커밋**

```bash
git add package.json package-lock.json src/lib/challenge/derive.ts src/lib/challenge/derive.test.ts
git commit -m "feat(challenge): 파생 로직 순수 함수 + vitest (day상태/스트릭/월횟수)"
```

---

### Task 3: API 모듈 `challenges.ts`

**Files:**
- Create: `src/lib/api/challenges.ts`

**Interfaces:**
- Consumes: `supabase` (`@/lib/supabase`), `AttemptInput`/`DayState` 개념(Task 2)
- Produces (Task 4·6·7·8이 의존):
  - `interface ChallengeTemplate { key; name; exercise; difficulty_mode: 'equipment'|'range'; sort_order }`
  - `interface ChallengeProgram { id; template_key; difficulty_key: string|null; label: string|null }`
  - `interface ChallengeProgramDay { id; program_id; day_no; target_reps }`
  - `interface UserChallenge { id; user_id; template_key; program_id; difficulty: Record<string, unknown>; training_weekdays: number[]; started_at: string; status: 'active'|'archived' }`
  - `interface ChallengeAttempt { id; user_challenge_id; day_no; result: 'success'|'fail'; done_date; created_at? }`
  - `interface ActiveChallenge { challenge: UserChallenge; days: ChallengeProgramDay[]; attempts: ChallengeAttempt[] }`
  - `getChallengeTemplates(): Promise<ChallengeTemplate[]>`
  - `getProgramsForTemplate(templateKey: string): Promise<ChallengeProgram[]>`
  - `getActiveChallenges(userId: string): Promise<ActiveChallenge[]>`
  - `startChallenge(p: { userId; templateKey; programId; difficulty: Record<string, unknown>; trainingWeekdays: number[] }): Promise<UserChallenge>`
  - `addAttempt(p: { userChallengeId; dayNo; result: 'success'|'fail'; doneDate: string }): Promise<ChallengeAttempt>`
  - `updateAttemptDate(attemptId: string, doneDate: string): Promise<void>`
  - `resetChallenge(userChallengeId: string): Promise<void>`

- [ ] **Step 1: 모듈 작성**

`src/lib/api/challenges.ts`:

```ts
import { supabase } from '@/lib/supabase'

export interface ChallengeTemplate {
  key: string
  name: string
  exercise: string
  difficulty_mode: 'equipment' | 'range'
  sort_order: number
}

export interface ChallengeProgram {
  id: string
  template_key: string
  difficulty_key: string | null
  label: string | null
}

export interface ChallengeProgramDay {
  id: string
  program_id: string
  day_no: number
  target_reps: number
}

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
}

export interface ChallengeAttempt {
  id: string
  user_challenge_id: string
  day_no: number
  result: 'success' | 'fail'
  done_date: string
  created_at?: string
}

export interface ActiveChallenge {
  challenge: UserChallenge
  days: ChallengeProgramDay[]
  attempts: ChallengeAttempt[]
}

const MISSING = 'PGRST205' // 테이블 미생성(마이그레이션 PENDING)

export async function getChallengeTemplates(): Promise<ChallengeTemplate[]> {
  const { data, error } = await supabase.from('challenge_templates').select('*').order('sort_order')
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  return (data ?? []) as ChallengeTemplate[]
}

export async function getProgramsForTemplate(templateKey: string): Promise<ChallengeProgram[]> {
  const { data, error } = await supabase
    .from('challenge_programs')
    .select('*')
    .eq('template_key', templateKey)
    .order('difficulty_key', { ascending: true, nullsFirst: true })
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  return (data ?? []) as ChallengeProgram[]
}

async function getProgramDays(programId: string): Promise<ChallengeProgramDay[]> {
  const { data, error } = await supabase
    .from('challenge_program_days')
    .select('*')
    .eq('program_id', programId)
    .order('day_no')
  if (error) throw error
  return (data ?? []) as ChallengeProgramDay[]
}

async function getAttempts(userChallengeId: string): Promise<ChallengeAttempt[]> {
  const { data, error } = await supabase
    .from('challenge_attempts')
    .select('*')
    .eq('user_challenge_id', userChallengeId)
  if (error) throw error
  return (data ?? []) as ChallengeAttempt[]
}

export async function getActiveChallenges(userId: string): Promise<ActiveChallenge[]> {
  const { data, error } = await supabase
    .from('user_challenges')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'active')
    .order('created_at', { ascending: true })
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  const challenges = (data ?? []) as UserChallenge[]
  return Promise.all(
    challenges.map(async (challenge) => {
      const [days, attempts] = await Promise.all([
        getProgramDays(challenge.program_id),
        getAttempts(challenge.id),
      ])
      return { challenge, days, attempts }
    }),
  )
}

export async function startChallenge(p: {
  userId: string
  templateKey: string
  programId: string
  difficulty: Record<string, unknown>
  trainingWeekdays: number[]
}): Promise<UserChallenge> {
  const { data, error } = await supabase
    .from('user_challenges')
    .insert({
      user_id: p.userId,
      template_key: p.templateKey,
      program_id: p.programId,
      difficulty: p.difficulty,
      training_weekdays: p.trainingWeekdays,
    })
    .select()
    .single()
  if (error) throw error
  return data as UserChallenge
}

export async function addAttempt(p: {
  userChallengeId: string
  dayNo: number
  result: 'success' | 'fail'
  doneDate: string
}): Promise<ChallengeAttempt> {
  // 성공 attempt가 이미 있으면 잠금 — 추가 거부
  const { data: locked, error: le } = await supabase
    .from('challenge_attempts')
    .select('id')
    .eq('user_challenge_id', p.userChallengeId)
    .eq('day_no', p.dayNo)
    .eq('result', 'success')
    .maybeSingle()
  if (le) throw le
  if (locked) throw new Error('이미 성공한 day입니다')

  const { data, error } = await supabase
    .from('challenge_attempts')
    .insert({
      user_challenge_id: p.userChallengeId,
      day_no: p.dayNo,
      result: p.result,
      done_date: p.doneDate,
    })
    .select()
    .single()
  if (error) throw error
  return data as ChallengeAttempt
}

export async function updateAttemptDate(attemptId: string, doneDate: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .update({ done_date: doneDate })
    .eq('id', attemptId)
  if (error) throw error
}

export async function resetChallenge(userChallengeId: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .delete()
    .eq('user_challenge_id', userChallengeId)
  if (error) throw error
}
```

- [ ] **Step 2: 타입 체크**

Run: `npx tsc --noEmit`
Expected: 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/lib/api/challenges.ts
git commit -m "feat(challenge): challenges API 모듈 (조회/시작/도전기록/초기화)"
```

---

### Task 4: 챌린지 추가 팝업 `AddChallengePopup.tsx`

**Files:**
- Create: `src/components/challenge/AddChallengePopup.tsx`

**Interfaces:**
- Consumes (Task 3): `getChallengeTemplates`, `getProgramsForTemplate`, `startChallenge`, `ChallengeTemplate`, `ChallengeProgram`; `getLoggedInUser`(`@/lib/auth`)
- Produces (Task 7): `interface AddChallengePopupProps { isOpen: boolean; onClose: () => void; onStarted: () => void }`; `export default function AddChallengePopup(props): JSX.Element | null`

- [ ] **Step 1: 컴포넌트 작성 (3단계: 챌린지→난이도→훈련요일)**

`src/components/challenge/AddChallengePopup.tsx`:

```tsx
'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import {
  getChallengeTemplates,
  getProgramsForTemplate,
  startChallenge,
  type ChallengeTemplate,
  type ChallengeProgram,
} from '@/lib/api/challenges'

// 사용자의 밴드 색상 목록(필요 시 조정). 표 이미지 확정 시 갱신.
const BAND_COLORS = ['노랑', '빨강', '초록', '파랑', '검정', '보라']
const WEEKDAYS = [
  { n: 1, label: '월' }, { n: 2, label: '화' }, { n: 3, label: '수' },
  { n: 4, label: '목' }, { n: 5, label: '금' }, { n: 6, label: '토' }, { n: 7, label: '일' },
]

interface AddChallengePopupProps {
  isOpen: boolean
  onClose: () => void
  onStarted: () => void
}

type EquipType = 'band' | 'bodyweight' | 'weighted'

export default function AddChallengePopup({ isOpen, onClose, onStarted }: AddChallengePopupProps) {
  const [step, setStep] = useState(1)
  const [templates, setTemplates] = useState<ChallengeTemplate[]>([])
  const [template, setTemplate] = useState<ChallengeTemplate | null>(null)
  const [programs, setPrograms] = useState<ChallengeProgram[]>([])

  // 풀업(equipment) 난이도
  const [equipType, setEquipType] = useState<EquipType>('band')
  const [bandColor, setBandColor] = useState(BAND_COLORS[0])
  const [bandCount, setBandCount] = useState(1)
  const [weightKg, setWeightKg] = useState('')
  // 푸쉬업(range) 난이도
  const [programId, setProgramId] = useState<string>('')

  const [weekdays, setWeekdays] = useState<number[]>([1, 2, 3, 4, 5])
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!isOpen) return
    setStep(1); setTemplate(null); setPrograms([]); setProgramId('')
    setEquipType('band'); setBandColor(BAND_COLORS[0]); setBandCount(1); setWeightKg('')
    setWeekdays([1, 2, 3, 4, 5])
    getChallengeTemplates().then(setTemplates).catch(() => setTemplates([]))
  }, [isOpen])

  if (!isOpen) return null

  async function pickTemplate(t: ChallengeTemplate) {
    setTemplate(t)
    const progs = await getProgramsForTemplate(t.key)
    setPrograms(progs)
    if (t.difficulty_mode === 'range' && progs[0]) setProgramId(progs[0].id)
    setStep(2)
  }

  function toggleWeekday(n: number) {
    setWeekdays((prev) => (prev.includes(n) ? prev.filter((x) => x !== n) : [...prev, n].sort((a, b) => a - b)))
  }

  function resolveStart(): { programId: string; difficulty: Record<string, unknown> } | null {
    if (!template) return null
    if (template.difficulty_mode === 'equipment') {
      const prog = programs[0]
      if (!prog) return null
      let difficulty: Record<string, unknown>
      if (equipType === 'band') difficulty = { type: 'band', color: bandColor, count: bandCount }
      else if (equipType === 'weighted') difficulty = { type: 'weighted', weight_kg: parseFloat(weightKg) || 0 }
      else difficulty = { type: 'bodyweight' }
      return { programId: prog.id, difficulty }
    }
    // range
    const prog = programs.find((p) => p.id === programId)
    if (!prog) return null
    return { programId: prog.id, difficulty: { type: 'range', difficulty_key: prog.difficulty_key, label: prog.label } }
  }

  async function handleStart() {
    const user = getLoggedInUser()
    const resolved = resolveStart()
    if (!user || !template || !resolved || weekdays.length === 0) return
    setSaving(true)
    try {
      await startChallenge({
        userId: user.id,
        templateKey: template.key,
        programId: resolved.programId,
        difficulty: resolved.difficulty,
        trainingWeekdays: weekdays,
      })
      onStarted()
      onClose()
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-t-2xl p-6 pb-8 animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">
            {step === 1 ? '챌린지 선택' : step === 2 ? '난이도 구성' : '훈련 요일'}
          </h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>

        {/* Step 1: 챌린지 선택 */}
        {step === 1 && (
          <div className="grid grid-cols-2 gap-3">
            {templates.length === 0 && <p className="col-span-2 text-sm text-text-secondary">사용 가능한 챌린지가 없어요.</p>}
            {templates.map((t) => (
              <button
                key={t.key}
                onClick={() => pickTemplate(t)}
                className="p-4 rounded-xl border border-border bg-background text-left hover:border-accent"
              >
                <p className="font-semibold text-foreground">{t.name}</p>
                <p className="text-xs text-text-secondary mt-1">{t.exercise}</p>
              </button>
            ))}
          </div>
        )}

        {/* Step 2: 난이도 */}
        {step === 2 && template?.difficulty_mode === 'equipment' && (
          <div className="space-y-4">
            <div className="flex gap-2">
              {([['band', '밴드'], ['bodyweight', '맨몸'], ['weighted', '중량']] as const).map(([v, l]) => (
                <button key={v} type="button" onClick={() => setEquipType(v)}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium border ${equipType === v ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                  {l}
                </button>
              ))}
            </div>
            {equipType === 'band' && (
              <div className="space-y-3">
                <div>
                  <label className="block text-sm text-text-secondary mb-1">밴드 색상</label>
                  <div className="flex flex-wrap gap-1">
                    {BAND_COLORS.map((c) => (
                      <button key={c} type="button" onClick={() => setBandColor(c)}
                        className={`px-3 py-1.5 rounded-lg text-sm border ${bandColor === c ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                        {c}
                      </button>
                    ))}
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-text-secondary mb-1">갯수</label>
                  <div className="flex gap-1">
                    {[1, 2, 3].map((n) => (
                      <button key={n} type="button" onClick={() => setBandCount(n)}
                        className={`w-10 h-10 rounded-lg text-sm font-medium border ${bandCount === n ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                        {n}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}
            {equipType === 'weighted' && (
              <div>
                <label className="block text-sm text-text-secondary mb-1">중량 (kg)</label>
                <input type="number" inputMode="decimal" value={weightKg} onChange={(e) => setWeightKg(e.target.value)}
                  placeholder="0" step="0.5"
                  className="w-full px-3 py-2 rounded-lg border border-border bg-background text-foreground focus:outline-none focus:border-accent" />
              </div>
            )}
            <button onClick={() => setStep(3)} className="w-full py-2.5 rounded-lg bg-accent text-white font-medium">다음</button>
          </div>
        )}

        {step === 2 && template?.difficulty_mode === 'range' && (
          <div className="space-y-3">
            {programs.length === 0 && <p className="text-sm text-text-secondary">난이도 프로그램이 없어요.</p>}
            {programs.map((p) => (
              <button key={p.id} type="button" onClick={() => setProgramId(p.id)}
                className={`w-full p-3 rounded-lg border text-left ${programId === p.id ? 'border-accent bg-accent/10' : 'border-border bg-background'}`}>
                <span className="text-sm font-medium text-foreground">{p.label ?? p.difficulty_key}</span>
              </button>
            ))}
            <button onClick={() => setStep(3)} disabled={!programId}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50">다음</button>
          </div>
        )}

        {/* Step 3: 훈련 요일 */}
        {step === 3 && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-text-secondary mb-2">훈련 요일 (기본 월~금)</label>
              <div className="flex gap-1">
                {WEEKDAYS.map((w) => (
                  <button key={w.n} type="button" onClick={() => toggleWeekday(w.n)}
                    className={`w-10 h-10 rounded-lg text-sm font-medium border ${weekdays.includes(w.n) ? 'bg-accent text-white border-accent' : 'bg-background border-border text-foreground'}`}>
                    {w.label}
                  </button>
                ))}
              </div>
            </div>
            <button onClick={handleStart} disabled={saving || weekdays.length === 0}
              className="w-full py-2.5 rounded-lg bg-accent text-white font-medium disabled:opacity-50">
              {saving ? '시작 중…' : '시작'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
```

- [ ] **Step 2: 타입 체크 + 린트**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/components/challenge/AddChallengePopup.tsx
git commit -m "feat(challenge): 챌린지 추가 팝업 (3단계: 선택/난이도/훈련요일)"
```

---

### Task 5: day 상태 하단 시트 `DayStatusSheet.tsx`

**Files:**
- Create: `src/components/challenge/DayStatusSheet.tsx`

**Interfaces:**
- Consumes (Task 2): `DayState`, `DayStatus`; `toDateString`(`@/lib/utils`)
- Produces (Task 6):
  - `interface DayStatusSheetProps { isOpen: boolean; dayNo: number; targetReps: number; state: { status: DayStatus; doneDate: string | null; successAttemptId: string | null } | null; onClose: () => void; onLog: (result: 'success'|'fail', doneDate: string) => void; onUpdateDate: (attemptId: string, doneDate: string) => void }`
  - `export default function DayStatusSheet(props): JSX.Element | null`

- [ ] **Step 1: 컴포넌트 작성**

`src/components/challenge/DayStatusSheet.tsx`:

```tsx
'use client'

import { useEffect, useState } from 'react'
import { X } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import type { DayStatus } from '@/lib/challenge/derive'

interface DayStatusSheetProps {
  isOpen: boolean
  dayNo: number
  targetReps: number
  state: { status: DayStatus; doneDate: string | null; successAttemptId: string | null } | null
  onClose: () => void
  onLog: (result: 'success' | 'fail', doneDate: string) => void
  onUpdateDate: (attemptId: string, doneDate: string) => void
}

export default function DayStatusSheet({ isOpen, dayNo, targetReps, state, onClose, onLog, onUpdateDate }: DayStatusSheetProps) {
  const status: DayStatus = state?.status ?? 'untried'
  const [date, setDate] = useState(toDateString(new Date()))

  useEffect(() => {
    if (!isOpen) return
    // 성공이면 그 성공일을, 아니면 오늘을 기본값으로
    setDate(status === 'success' && state?.doneDate ? state.doneDate : toDateString(new Date()))
  }, [isOpen, status, state?.doneDate])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-surface rounded-t-2xl p-6 pb-8 animate-slide-up">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">Day {dayNo} · 목표 {targetReps}회</h3>
          <button onClick={onClose} className="p-1 text-text-secondary" aria-label="닫기"><X size={20} /></button>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm text-text-secondary mb-1">날짜</label>
            <input type="date" value={date} onChange={(e) => setDate(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-border bg-background text-foreground focus:outline-none focus:border-accent" />
          </div>

          {status === 'success' ? (
            <>
              <p className="text-sm text-success font-medium">✓ 성공 완료 (날짜만 수정 가능)</p>
              <button
                onClick={() => state?.successAttemptId && onUpdateDate(state.successAttemptId, date)}
                className="w-full py-2.5 rounded-lg bg-accent text-white font-medium">
                날짜 저장
              </button>
            </>
          ) : (
            <>
              {status === 'fail' && <p className="text-sm text-danger font-medium">✗ 실패 — 재도전할 수 있어요</p>}
              <div className="flex gap-2">
                <button onClick={() => onLog('success', date)}
                  className="flex-1 py-2.5 rounded-lg bg-success text-white font-medium">성공</button>
                <button onClick={() => onLog('fail', date)}
                  className="flex-1 py-2.5 rounded-lg bg-danger text-white font-medium">실패</button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: 타입 체크 + 린트**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/components/challenge/DayStatusSheet.tsx
git commit -m "feat(challenge): day 상태 하단 시트 (도전/재도전/성공날짜수정)"
```

---

### Task 6: 대시보드 카드 `ChallengeDashboardCard.tsx`

**Files:**
- Create: `src/components/challenge/ChallengeDashboardCard.tsx`

**Interfaces:**
- Consumes: `ActiveChallenge`/`ChallengeTemplate`/`addAttempt`/`updateAttemptDate`/`resetChallenge`(Task 3); `deriveDayStates`/`computeStreak`/`monthlyAttemptCount`(Task 2); `DayStatusSheet`(Task 5); `toDateString`(`@/lib/utils`)
- Produces (Task 7):
  - `interface ChallengeDashboardCardProps { active: ActiveChallenge; template?: ChallengeTemplate; onChanged: () => void }`
  - `export default function ChallengeDashboardCard(props): JSX.Element`
  - `export function formatDifficulty(difficulty: Record<string, unknown>): string` (Task 8 재사용)

- [ ] **Step 1: 컴포넌트 작성 (헤더 + day 그리드 + 시트 연결, DayCell은 내부 서브컴포넌트)**

`src/components/challenge/ChallengeDashboardCard.tsx`:

```tsx
'use client'

import { useState } from 'react'
import { RotateCcw, Flame } from 'lucide-react'
import { toDateString } from '@/lib/utils'
import { deriveDayStates, computeStreak, monthlyAttemptCount, type DayState } from '@/lib/challenge/derive'
import {
  addAttempt, updateAttemptDate, resetChallenge,
  type ActiveChallenge, type ChallengeTemplate,
} from '@/lib/api/challenges'
import DayStatusSheet from './DayStatusSheet'

// 난이도 jsonb → 사람이 읽는 요약 (Task 8 위젯에서도 재사용)
export function formatDifficulty(difficulty: Record<string, unknown>): string {
  const t = difficulty.type
  if (t === 'band') return `${String(difficulty.color)}밴드 ${String(difficulty.count)}개`
  if (t === 'bodyweight') return '맨몸'
  if (t === 'weighted') return `중량 ${String(difficulty.weight_kg)}kg`
  if (t === 'range') return String(difficulty.label ?? difficulty.difficulty_key ?? '')
  return ''
}

interface ChallengeDashboardCardProps {
  active: ActiveChallenge
  template?: ChallengeTemplate
  onChanged: () => void
}

export default function ChallengeDashboardCard({ active, template, onChanged }: ChallengeDashboardCardProps) {
  const { challenge, days, attempts } = active
  const [openDay, setOpenDay] = useState<number | null>(null)

  const dayStates = deriveDayStates(attempts)
  const attemptDates = attempts.map((a) => a.done_date)
  const today = toDateString(new Date())
  const streak = computeStreak(challenge.training_weekdays, attemptDates, today)
  const monthCount = monthlyAttemptCount(attemptDates, today.slice(0, 7))

  const name = template?.name ?? challenge.template_key
  const diffLabel = formatDifficulty(challenge.difficulty)

  const openState: DayState | null = openDay != null ? (dayStates.get(openDay) ?? null) : null
  const openTarget = openDay != null ? (days.find((d) => d.day_no === openDay)?.target_reps ?? 0) : 0

  async function handleLog(result: 'success' | 'fail', doneDate: string) {
    if (openDay == null) return
    await addAttempt({ userChallengeId: challenge.id, dayNo: openDay, result, doneDate })
    setOpenDay(null)
    onChanged()
  }
  async function handleUpdateDate(attemptId: string, doneDate: string) {
    await updateAttemptDate(attemptId, doneDate)
    setOpenDay(null)
    onChanged()
  }
  async function handleReset() {
    if (!confirm('이 챌린지의 모든 도전 기록을 초기화할까요? (되돌릴 수 없어요)')) return
    await resetChallenge(challenge.id)
    onChanged()
  }

  return (
    <div className="bg-surface border border-border rounded-xl overflow-hidden">
      {/* 헤더 */}
      <div className="px-4 py-3 bg-background border-b border-border flex items-center gap-2">
        <div className="min-w-0 flex-1">
          <p className="text-sm font-semibold text-foreground truncate">{name}</p>
          {diffLabel && <p className="text-xs text-text-secondary truncate">{diffLabel}</p>}
        </div>
        <div className="flex items-center gap-1 shrink-0">
          <Flame size={16} className={streak.alive ? 'text-accent-pop' : 'text-text-secondary'} />
          <span className={`text-sm font-bold ${streak.alive ? 'text-accent-pop' : 'text-text-secondary'}`}>{streak.count}</span>
        </div>
        <span className="text-xs text-text-secondary shrink-0">이번 달 {monthCount}회</span>
        <button onClick={handleReset} className="p-1 text-text-secondary shrink-0" aria-label="전체 초기화">
          <RotateCcw size={16} />
        </button>
      </div>

      {/* day 그리드 (7개씩) */}
      <div className="grid grid-cols-7 gap-1.5 p-3">
        {days.map((d) => (
          <DayCell key={d.day_no} dayNo={d.day_no} target={d.target_reps}
            state={dayStates.get(d.day_no) ?? null} onTap={() => setOpenDay(d.day_no)} />
        ))}
        {days.length === 0 && <p className="col-span-7 text-xs text-text-secondary text-center py-2">프로그램 데이터가 없어요.</p>}
      </div>

      <DayStatusSheet
        isOpen={openDay != null}
        dayNo={openDay ?? 0}
        targetReps={openTarget}
        state={openState ? { status: openState.status, doneDate: openState.doneDate, successAttemptId: openState.successAttemptId } : null}
        onClose={() => setOpenDay(null)}
        onLog={handleLog}
        onUpdateDate={handleUpdateDate}
      />
    </div>
  )
}

// ── day 셀 (내부 서브컴포넌트) ──
function DayCell({ dayNo, target, state, onTap }: {
  dayNo: number
  target: number
  state: DayState | null
  onTap: () => void
}) {
  const status = state?.status ?? 'untried'
  const ring =
    status === 'success' ? 'border-success bg-success/10 text-success'
    : status === 'fail' ? 'border-danger bg-danger/10 text-danger'
    : 'border-border bg-background text-text-secondary'
  const icon = status === 'success' ? '✓' : status === 'fail' ? '✗' : '·'
  return (
    <button onClick={onTap} className={`aspect-square rounded-lg border flex flex-col items-center justify-center ${ring}`}>
      <span className="text-[10px] leading-none opacity-70">D{dayNo}</span>
      <span className="text-sm font-bold leading-tight">{icon}</span>
      <span className="text-[10px] leading-none opacity-70">{target}</span>
    </button>
  )
}
```

- [ ] **Step 2: 타입 체크 + 린트**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/components/challenge/ChallengeDashboardCard.tsx
git commit -m "feat(challenge): 대시보드 카드 (헤더+day그리드+시트연결)"
```

---

### Task 7: 챌린지 탭 페이지 통합

**Files:**
- Modify: `src/app/challenge/page.tsx` (현재 플레이스홀더 전체 교체)

**Interfaces:**
- Consumes: `getLoggedInUser`(`@/lib/auth`); `getActiveChallenges`/`getChallengeTemplates`/`ActiveChallenge`/`ChallengeTemplate`(Task 3); `ChallengeDashboardCard`(Task 6); `AddChallengePopup`(Task 4)

- [ ] **Step 1: 페이지 작성**

`src/app/challenge/page.tsx` (전체 교체):

```tsx
'use client'

import { useCallback, useEffect, useState } from 'react'
import { Plus } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import {
  getActiveChallenges, getChallengeTemplates,
  type ActiveChallenge, type ChallengeTemplate,
} from '@/lib/api/challenges'
import ChallengeDashboardCard from '@/components/challenge/ChallengeDashboardCard'
import AddChallengePopup from '@/components/challenge/AddChallengePopup'

export default function ChallengePage() {
  const [actives, setActives] = useState<ActiveChallenge[]>([])
  const [templates, setTemplates] = useState<Record<string, ChallengeTemplate>>({})
  const [loading, setLoading] = useState(true)
  const [addOpen, setAddOpen] = useState(false)

  const reload = useCallback(async () => {
    const user = getLoggedInUser()
    if (!user) { setLoading(false); return }
    const [list, temps] = await Promise.all([getActiveChallenges(user.id), getChallengeTemplates()])
    setActives(list)
    setTemplates(Object.fromEntries(temps.map((t) => [t.key, t])))
    setLoading(false)
  }, [])

  useEffect(() => { reload() }, [reload])

  return (
    <div className="flex flex-col gap-4">
      <button
        onClick={() => setAddOpen(true)}
        className="flex items-center justify-center gap-1.5 w-full py-2.5 rounded-xl border border-dashed border-accent text-accent font-medium">
        <Plus size={18} /> 챌린지 추가
      </button>

      {loading ? (
        <p className="text-sm text-text-secondary text-center py-12">불러오는 중…</p>
      ) : actives.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-center">
          <p className="text-base font-semibold text-foreground mb-1">도전 중인 챌린지가 없어요</p>
          <p className="text-sm text-text-secondary">위 버튼으로 풀업·푸쉬업 챌린지를 시작해보세요.</p>
        </div>
      ) : (
        actives.map((a) => (
          <ChallengeDashboardCard key={a.challenge.id} active={a} template={templates[a.challenge.template_key]} onChanged={reload} />
        ))
      )}

      <AddChallengePopup isOpen={addOpen} onClose={() => setAddOpen(false)} onStarted={reload} />
    </div>
  )
}
```

- [ ] **Step 2: 타입 체크 + 린트**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 없음.

- [ ] **Step 3: (수동) dev QA — 사용자 단계**

Task 1 시드 적용된 DB 기준으로 `npm run dev` 후 `/challenge`에서:
- 빈 상태 → `챌린지 추가` → 풀업 선택 → 밴드/색상/갯수 → 훈련요일(월~금) → 시작 → 카드 등장
- day 셀 탭 → 성공/실패 기록(날짜 기본 오늘) → 그리드 아이콘·🔥·이번 달 N회 반영
- 실패 셀 재탭 → 재도전 → 성공 → 잠금(날짜만 수정)
- ⟳ → 컨펌 → 전 day 미도전 리셋

- [ ] **Step 4: 커밋**

```bash
git add src/app/challenge/page.tsx
git commit -m "feat(challenge): 챌린지 탭 페이지 (추가버튼+카드목록+빈상태)"
```

---

### Task 8: 홈 위젯 (정사각형 카드)

**Files:**
- Create: `src/components/home/ChallengeWidgets.tsx`
- Modify: `src/app/page.tsx` (운동 통계 카드 아래 위젯 삽입)

**Interfaces:**
- Consumes: `getLoggedInUser`(`@/lib/auth`); `getActiveChallenges`/`getChallengeTemplates`(Task 3); `computeStreak`/`monthlyAttemptCount`(Task 2); `toDateString`(`@/lib/utils`); `next/link`
- Produces: `export default function ChallengeWidgets(): JSX.Element | null` (active 없으면 null)

- [ ] **Step 1: 위젯 컴포넌트 작성**

`src/components/home/ChallengeWidgets.tsx`:

```tsx
'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Flame } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import { getActiveChallenges, getChallengeTemplates } from '@/lib/api/challenges'
import { computeStreak, monthlyAttemptCount } from '@/lib/challenge/derive'
import { toDateString } from '@/lib/utils'

interface WidgetData {
  id: string
  name: string
  streak: { count: number; alive: boolean }
  monthCount: number
}

export default function ChallengeWidgets() {
  const [widgets, setWidgets] = useState<WidgetData[]>([])

  useEffect(() => {
    const user = getLoggedInUser()
    if (!user) return
    let cancelled = false
    Promise.all([getActiveChallenges(user.id), getChallengeTemplates()])
      .then(([actives, temps]) => {
        if (cancelled) return
        const nameByKey = Object.fromEntries(temps.map((t) => [t.key, t.name]))
        const today = toDateString(new Date())
        setWidgets(
          actives.map((a) => {
            const dates = a.attempts.map((x) => x.done_date)
            return {
              id: a.challenge.id,
              name: nameByKey[a.challenge.template_key] ?? a.challenge.template_key,
              streak: computeStreak(a.challenge.training_weekdays, dates, today),
              monthCount: monthlyAttemptCount(dates, today.slice(0, 7)),
            }
          }),
        )
      })
      .catch(() => { if (!cancelled) setWidgets([]) })
    return () => { cancelled = true }
  }, [])

  if (widgets.length === 0) return null

  return (
    <div>
      <p className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-2">도전 중 챌린지</p>
      <div className="grid grid-cols-2 gap-3">
        {widgets.map((w) => (
          <Link key={w.id} href="/challenge"
            className="aspect-square bg-surface border border-border rounded-xl p-4 flex flex-col">
            <p className="text-sm font-semibold text-foreground truncate">{w.name}</p>
            <div className="flex-1 flex flex-col items-center justify-center gap-1">
              <div className="flex items-center gap-1">
                <Flame size={20} className={w.streak.alive ? 'text-accent-pop' : 'text-text-secondary'} />
                <span className={`text-2xl font-bold ${w.streak.alive ? 'text-accent-pop' : 'text-text-secondary'}`}>{w.streak.count}</span>
              </div>
            </div>
            <p className="text-xs text-text-secondary text-center">{w.monthCount}회 도전</p>
          </Link>
        ))}
      </div>
    </div>
  )
}
```

- [ ] **Step 2: 홈에 삽입**

`src/app/page.tsx` — import 추가:
```tsx
import ChallengeWidgets from '@/components/home/ChallengeWidgets'
```
운동 통계 카드 `</div>`(닫는 div) **바로 다음**, 최상위 `</div>` 직전에 삽입:
```tsx
      {/* 도전 중 챌린지 위젯 */}
      <ChallengeWidgets />
```
(즉 `{/* 운동 통계 */}` 블록과 같은 레벨로, 그 아래에 위치.)

- [ ] **Step 3: 타입 체크 + 린트**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 없음.

- [ ] **Step 4: (수동) dev QA — 사용자 단계**

`/`(홈)에서: active 챌린지 없으면 위젯 섹션 미표시 / 있으면 운동 통계 카드 아래 정사각형 카드(이름·🔥스트릭·N회 도전), 탭 시 `/challenge` 이동. 스트릭 살아있으면 골드, 끊기면 회색.

- [ ] **Step 5: 커밋**

```bash
git add src/components/home/ChallengeWidgets.tsx src/app/page.tsx
git commit -m "feat(challenge): 홈 도전 중 챌린지 위젯 (정사각형 카드)"
```

---

## 부록: 표 이미지 수령 후 (별도, 코드 변경 불필요)

`supabase/seed-challenges.sql`의 `challenge_program_days` 값(및 푸쉬업 `difficulty_key`/`label`, `AddChallengePopup`의 `BAND_COLORS`)을 실제 표로 교체 → 재실행. 스키마·컴포넌트 로직 변경 없음.

## Self-Review (작성자 체크 완료)

- **스펙 커버리지**: §4 데이터모델→Task1, §5 상태머신/§6 계산→Task2(+3 addAttempt 잠금), §7 탭 UI→Task4·5·6·7, §8 홈 위젯→Task8, §9 난이도→Task4, §10 시드 분리→Task1/부록, §11 배치(파일/API/유틸/컴포넌트)→Task2·3·4·5·6·8. 누락 없음.
- **플레이스홀더 스캔**: 모든 step에 실제 코드/명령. 시드 숫자는 "임시 샘플"로 명시(구조는 확정), 표 이미지는 부록에서 데이터만 교체 — 코드 공백 아님.
- **타입 일관성**: `ActiveChallenge{challenge,days,attempts}`·`UserChallenge.training_weekdays:number[]`·`ChallengeAttempt.done_date:string`·`DayState{status,doneDate,successAttemptId}`·`formatDifficulty`·`computeStreak(weekdays,dates,today)`·`monthlyAttemptCount(dates,'YYYY-MM')` — Task 간 시그니처 일치 확인.
