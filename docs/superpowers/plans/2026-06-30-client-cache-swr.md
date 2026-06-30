# 클라이언트 데이터 캐시 (SWR) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 전 읽기 화면을 SWR + localStorage 캐시로 전환해 재실행·탭전환 시 즉시 표시(stale-while-revalidate)하고, 쓰기 후 정확히 무효화한다.

**Architecture:** `swr` 도입 + `ClientLayout`에 전역 `<SWRConfig>`(localStorage 백업 provider, 유저별 네임스페이스). 읽기는 `useSWR(key, fetcher)`, 쓰기 후엔 `useSWRConfig().mutate(matcher)`로 prefix 무효화. 운동 자동담기는 읽기(useSWR)와 분리된 effect에서 누락분만 담고 day-logs를 mutate.

**Tech Stack:** Next.js 16 (App Router) · React 19 · TypeScript · Tailwind v4 · Supabase(anon) · SWR 2.x · vitest.

## Global Constraints

- 검증 게이트 = `npx tsc --noEmit` clean + `npm run lint`(기존 season1 lint 2건 `admin/workout/page.tsx`·`auth/AuthGuard.tsx`는 알려진 기술부채 — 새로 늘리지 말 것) + `npx vitest run` 통과.
- **커스텀 provider 사용 시 무효화는 반드시 `useSWRConfig().mutate`(바운드 mutate)로** — `import { mutate } from 'swr'`(전역)는 provider 캐시를 못 건드림.
- 캐시 키는 배열, 첫 요소=리소스명, 유저별 분리 위해 `uid` 포함. 키 팩토리는 `src/lib/swr/keys.ts`에만 정의(중복 금지).
- localStorage 영속 키 = `r2r-swr:${uid}`. 로그아웃 시 제거. 모바일 신뢰성 위해 `pagehide`+`visibilitychange(hidden)`에 저장.
- 읽기 키는 비로그인(uid 없음)일 때 `null`(조회 안 함). 로딩 스켈레톤은 `data === undefined`일 때만.
- 쓰기(변이) 자체 로직/시그니처는 변경 금지 — 호출 후 무효화만 추가.
- 운동 자동담기 규칙(현행 유지): WOD(요일공용)는 과거 포함 항상, 프로그램 등 날짜공용은 오늘/미래만.

---

## File Structure

- `src/lib/swr/keys.ts` (신규) — 키 팩토리 `k`.
- `src/lib/swr/provider.ts` (신규) — `localStorageProvider(uid)`.
- `src/lib/swr/revalidate.ts` (신규) — `matchPrefix(prefix, ...params)` 매처.
- `src/lib/swr/keys.test.ts`, `provider.test.ts`, `revalidate.test.ts` (신규) — vitest.
- `src/components/ClientLayout.tsx` (수정) — `<SWRConfig>` 래핑.
- `src/lib/auth.ts` (수정) — `logout()`에서 캐시 제거.
- 읽기 전환: `Header.tsx`, `app/page.tsx`, `home/WorkoutCalendar.tsx`, `home/ChallengeWidgets.tsx`, `app/workout/page.tsx`, `workout/AddWorkoutPopup.tsx`, `app/challenge/page.tsx`, `app/pr/page.tsx`, `app/my/page.tsx`.
- 무효화 추가: `workout/WorkoutCard.tsx`, `challenge/ChallengeDashboardCard.tsx`, `challenge/AddChallengePopup.tsx`, 위 PR/MY/AddWorkoutPopup.

---

## Task 1: SWR 인프라 (provider · keys · revalidate · SWRConfig · 로그아웃)

**Files:**
- Create: `src/lib/swr/keys.ts`, `src/lib/swr/provider.ts`, `src/lib/swr/revalidate.ts`
- Test: `src/lib/swr/provider.test.ts`, `src/lib/swr/revalidate.test.ts`
- Modify: `package.json`(+swr), `src/components/ClientLayout.tsx`, `src/lib/auth.ts`

**Interfaces:**
- Produces: `k` (키 팩토리, 아래), `localStorageProvider(uid: string): Map<string, unknown>`, `matchPrefix(prefix: string, ...params: unknown[]): (key: unknown) => boolean`.

- [ ] **Step 1: swr 설치**

Run: `npm install swr`
Expected: `package.json` dependencies에 `"swr": "^2..."` 추가, 에러 없음.

- [ ] **Step 2: 키 팩토리 작성**

Create `src/lib/swr/keys.ts`:
```ts
// SWR 캐시 키 팩토리. 배열 키 — 첫 요소=리소스명, 유저별 분리 위해 uid 포함.
export const k = {
  homeStats: (uid: string, ym: string) => ['home-stats', uid, ym] as const,
  calDates: (uid: string, gridStart: string) => ['cal-dates', uid, gridStart] as const,
  program: (today: string) => ['program', today] as const,
  dayDefaults: (uid: string, ds: string) => ['day-defaults', uid, ds] as const,
  dayLogs: (uid: string, ds: string) => ['day-logs', uid, ds] as const,
  challenges: (uid: string) => ['challenges', uid] as const,
  personalWorkouts: (uid: string) => ['personal-workouts', uid] as const,
  pr1rm: (uid: string) => ['pr-1rm', uid] as const,
  prNrm: (uid: string) => ['pr-nrm', uid] as const,
  prPace: (uid: string) => ['pr-pace', uid] as const,
  dailyLog: (uid: string, date: string) => ['daily-log', uid, date] as const,
  weightRange: (uid: string, start: string, end: string) => ['weight-range', uid, start, end] as const,
}
```

- [ ] **Step 3: revalidate 매처 — 실패 테스트**

Create `src/lib/swr/revalidate.test.ts`:
```ts
import { describe, it, expect } from 'vitest'
import { matchPrefix } from './revalidate'

describe('matchPrefix', () => {
  it('prefix만 주면 그 prefix의 모든 키 매칭', () => {
    const m = matchPrefix('day-logs')
    expect(m(['day-logs', 'u1', '2026-07-06'])).toBe(true)
    expect(m(['day-logs', 'u2', '2026-07-07'])).toBe(true)
    expect(m(['home-stats', 'u1', '2026-07'])).toBe(false)
  })
  it('파라미터까지 주면 해당 키만 매칭', () => {
    const m = matchPrefix('day-logs', 'u1', '2026-07-06')
    expect(m(['day-logs', 'u1', '2026-07-06'])).toBe(true)
    expect(m(['day-logs', 'u1', '2026-07-07'])).toBe(false)
    expect(m(['day-logs', 'u2', '2026-07-06'])).toBe(false)
  })
  it('배열 아닌 키·짧은 키는 false', () => {
    const m = matchPrefix('day-logs', 'u1')
    expect(m('day-logs')).toBe(false)
    expect(m(['day-logs'])).toBe(false)
    expect(m(null)).toBe(false)
  })
})
```

- [ ] **Step 4: 테스트 실패 확인**

Run: `npx vitest run src/lib/swr/revalidate.test.ts`
Expected: FAIL — `Failed to resolve import "./revalidate"`.

- [ ] **Step 5: revalidate 구현**

Create `src/lib/swr/revalidate.ts`:
```ts
// 키 prefix(+선행 파라미터) 매처. useSWRConfig().mutate(matchPrefix(...))로 무효화.
export function matchPrefix(prefix: string, ...params: unknown[]) {
  return (key: unknown): boolean => {
    if (!Array.isArray(key) || key[0] !== prefix) return false
    return params.every((p, i) => key[i + 1] === p)
  }
}
```

- [ ] **Step 6: 테스트 통과 확인**

Run: `npx vitest run src/lib/swr/revalidate.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 7: provider — 실패 테스트**

Create `src/lib/swr/provider.test.ts`:
```ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { localStorageProvider } from './provider'

// jsdom 환경 가정(vitest.config의 environment). localStorage/document/window 사용.
describe('localStorageProvider', () => {
  beforeEach(() => localStorage.clear())

  it('비어있으면 빈 Map', () => {
    const m = localStorageProvider('u1')
    expect(m.size).toBe(0)
  })
  it('기존 캐시를 하이드레이트', () => {
    localStorage.setItem('r2r-swr:u1', JSON.stringify([['k1', { data: 42 }]]))
    const m = localStorageProvider('u1')
    expect(m.get('k1')).toEqual({ data: 42 })
  })
  it('유저별 네임스페이스 격리', () => {
    localStorage.setItem('r2r-swr:u1', JSON.stringify([['k1', { data: 1 }]]))
    const m2 = localStorageProvider('u2')
    expect(m2.size).toBe(0)
  })
  it('pagehide 시 현재 Map을 직렬화 저장', () => {
    const m = localStorageProvider('u1')
    m.set('k2', { data: 'x' })
    window.dispatchEvent(new Event('pagehide'))
    expect(JSON.parse(localStorage.getItem('r2r-swr:u1')!)).toEqual([['k2', { data: 'x' }]])
  })
})
```

- [ ] **Step 8: 테스트 실패 확인**

Run: `npx vitest run src/lib/swr/provider.test.ts`
Expected: FAIL — `Failed to resolve import "./provider"`.

- [ ] **Step 9: provider 구현**

Create `src/lib/swr/provider.ts`:
```ts
// SWR localStorage 백업 캐시. 재실행 시 하이드레이트 → 첫 렌더 즉시. 유저별 네임스페이스.
export function localStorageProvider(uid: string): Map<string, unknown> {
  const lsKey = `r2r-swr:${uid}`
  let init: [string, unknown][] = []
  try {
    init = JSON.parse(localStorage.getItem(lsKey) || '[]')
  } catch {
    init = []
  }
  const map = new Map<string, unknown>(init)
  const persist = () => {
    try {
      localStorage.setItem(lsKey, JSON.stringify(Array.from(map.entries())))
    } catch {
      // 용량 초과 등은 무시(캐시는 보조)
    }
  }
  if (typeof window !== 'undefined') {
    window.addEventListener('pagehide', persist)
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) persist()
    })
  }
  return map
}
```

- [ ] **Step 10: provider 테스트 통과 확인**

Run: `npx vitest run src/lib/swr/provider.test.ts`
Expected: PASS (4 tests). (vitest environment가 `node`면 jsdom 필요 — `provider.test.ts` 상단에 `// @vitest-environment jsdom` 추가하고 `npm i -D jsdom` 미설치 시 설치.)

- [ ] **Step 11: SWRConfig 래핑 (ClientLayout)**

`src/components/ClientLayout.tsx`에서 `getLoggedInUser` import 추가 후, `<AuthGuard>` 내부 비-login 경로를 `<SWRConfig>`로 감싼다. uid로 키잉해 유저 전환 시 provider 재생성:
```tsx
'use client'

import { useEffect, useState } from 'react'
import { usePathname } from 'next/navigation'
import { SWRConfig } from 'swr'
import Header from '@/components/Header'
import BottomNav from '@/components/BottomNav'
import AuthGuard from '@/components/auth/AuthGuard'
import { getLoggedInUser } from '@/lib/auth'
import { localStorageProvider } from '@/lib/swr/provider'

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const isLogin = pathname === '/login'
  const [overlayVisible, setOverlayVisible] = useState(false)
  const uid = getLoggedInUser()?.id ?? 'anon'

  useEffect(() => {
    const handler = (e: Event) => setOverlayVisible((e as CustomEvent).detail)
    window.addEventListener('calc-open', handler)
    return () => window.removeEventListener('calc-open', handler)
  }, [])

  const content = (
    <>
      {!isLogin && <Header />}
      <main className={isLogin ? '' : 'max-w-lg mx-auto px-4 pt-3 pb-20'}>{children}</main>
      {!isLogin && <BottomNav />}
      {overlayVisible && (
        <div
          className="fixed inset-0 bg-black/40 z-[55]"
          onClick={() => {
            setOverlayVisible(false)
            window.dispatchEvent(new CustomEvent('calc-close'))
          }}
        />
      )}
    </>
  )

  return (
    <AuthGuard>
      <SWRConfig
        key={uid}
        value={{
          provider: () => localStorageProvider(uid),
          revalidateOnFocus: true,
          revalidateOnReconnect: true,
          dedupingInterval: 2000,
          keepPreviousData: true,
        }}
      >
        {content}
      </SWRConfig>
    </AuthGuard>
  )
}
```

- [ ] **Step 12: 로그아웃 시 캐시 제거**

`src/lib/auth.ts`의 `logout()`에 캐시 키 제거 추가. 먼저 현재 `logout` 확인:
Run: `grep -n "export function logout\|export async function logout" src/lib/auth.ts`
그 함수 본문 맨 앞(세션 제거 전후)에서, 현재 유저 id를 알 수 있으면 그 키를, 아니면 prefix 일괄 제거:
```ts
// 로그아웃: SWR 영속 캐시 제거 (r2r-swr:* 전부)
try {
  for (let i = localStorage.length - 1; i >= 0; i--) {
    const key = localStorage.key(i)
    if (key && key.startsWith('r2r-swr:')) localStorage.removeItem(key)
  }
} catch {
  /* noop */
}
```
(기존 로그아웃 로직은 유지하고 이 블록만 추가.)

- [ ] **Step 13: 검증**

Run: `npx vitest run` → 전체 PASS(기존 + 신규 7).
Run: `npx tsc --noEmit` → 출력 없음.
Run: `npx eslint src/lib/swr/*.ts src/components/ClientLayout.tsx src/lib/auth.ts` → 출력 없음.

- [ ] **Step 14: 커밋**

```bash
git add package.json package-lock.json src/lib/swr src/components/ClientLayout.tsx src/lib/auth.ts
git commit -m "feat(perf): SWR 인프라 — localStorage provider + 키 팩토리 + 무효화 매처 + SWRConfig"
```

---

## Read-migration recipe (Task 2~7 공통 패턴)

각 읽기 화면은 다음 형태로 전환한다(태스크마다 구체 키/fetcher 명시):
```tsx
import useSWR from 'swr'
import { useSWRConfig } from 'swr'      // 무효화 필요한 화면만
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'

const uid = getLoggedInUser()?.id ?? ''
const { data } = useSWR(uid ? k.something(uid, ...) : null, () => fetchFn(...))
// 로딩: data === undefined && 스켈레톤 / 아니면 data 사용
```
무효화(쓰기 후): `const { mutate } = useSWRConfig(); await writeFn(...); mutate(matchPrefix('prefix', uid, ...))`.
기존 `useState+useEffect(fetch)`는 제거. `onChanged`류 수동 재조회 콜백은 해당 키 `mutate`로 대체.

---

## Task 2: 헤더 프로그램 읽기 → useSWR

**Files:** Modify `src/components/Header.tsx`

**Interfaces:** Consumes `k.program`(Task 1), `getCurrentProgram`(기존). Produces: 없음.

- [ ] **Step 1: useSWR로 전환**

`Header.tsx`의 `useState(program)`+`useEffect(fetch)`를 제거하고 useSWR로:
```tsx
'use client'
import useSWR from 'swr'
import { getLoggedInUser } from '@/lib/auth'
import { getCurrentProgram } from '@/lib/api/workouts'
import { k } from '@/lib/swr/keys'
import { toDateString } from '@/lib/utils'

export default function Header() {
  const user = getLoggedInUser()
  const username = user?.username ?? toDateString(new Date())
  const today = toDateString(new Date())
  const { data: program } = useSWR(k.program(today), () => getCurrentProgram(today))
  // program: CurrentProgram | null | undefined (undefined=로딩). 기존 렌더 분기 그대로 사용.
  // ... 기존 segColor/progLabel/JSX 유지 (program이 undefined면 줄 미표시) ...
}
```
(기존 `import { useEffect, useState }`, `type CurrentProgram` import는 불필요해지면 제거. segColor/progLabel/렌더 블록은 그대로.)

- [ ] **Step 2: 검증**

Run: `npx tsc --noEmit` → 출력 없음.
Run: `npx eslint src/components/Header.tsx` → 출력 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/components/Header.tsx
git commit -m "perf(header): 프로그램 조회 useSWR 캐시 전환"
```

---

## Task 3: 홈 (통계 · 캘린더 · 챌린지 위젯) 읽기 → useSWR

**Files:** Modify `src/app/page.tsx`, `src/components/home/WorkoutCalendar.tsx`, `src/components/home/ChallengeWidgets.tsx`

**Interfaces:** Consumes `k.homeStats`/`k.calDates`/`k.challenges`, 기존 `getCompletedDatesInRange`/`getWorkoutDatesInRange`/`getActiveChallenges`.

- [ ] **Step 1: 홈 통계(page.tsx) 전환**

`src/app/page.tsx`의 useEffect 2-쿼리(week/month completed)를 useSWR로. `ym`=`${year}-${month}` 키:
```tsx
import useSWR from 'swr'
import { k } from '@/lib/swr/keys'
// ... 컴포넌트 내부 ...
const uid = getLoggedInUser()?.id ?? ''
const now = new Date()
const ym = `${now.getFullYear()}-${now.getMonth() + 1}`
const { data: stats } = useSWR(uid ? k.homeStats(uid, ym) : null, async () => {
  const weekStart = new Date(now); weekStart.setDate(weekStart.getDate() - weekStart.getDay())
  const weekEnd = new Date(weekStart); weekEnd.setDate(weekStart.getDate() + 6)
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
  const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  const [week, month] = await Promise.all([
    getCompletedDatesInRange(uid, toDateString(weekStart), toDateString(weekEnd)),
    getCompletedDatesInRange(uid, toDateString(monthStart), toDateString(monthEnd)),
  ])
  return { week: week.length, month: month.length }
})
const weekCount = stats?.week ?? null
const monthCount = stats?.month ?? null
```
기존 `useState(weekCount/monthCount)` + 그 useEffect 제거. JSX의 `weekCount/monthCount` 사용은 그대로.

- [ ] **Step 2: 캘린더(WorkoutCalendar) 전환**

`WorkoutCalendar.tsx`의 useEffect(completed+worked, gridStart..+41)를 useSWR로. 키 파라미터 = `toDateString(gridStart)`:
```tsx
import useSWR from 'swr'
import { k } from '@/lib/swr/keys'
// monthStart 변경 시 gridStart 재계산은 기존 로직 유지
const uid = getLoggedInUser()?.id ?? ''
const gs = gridStartOf(monthStart)
const ge = new Date(gs); ge.setDate(gs.getDate() + 41)
const gsStr = toDateString(gs)
const { data } = useSWR(uid ? k.calDates(uid, gsStr) : null, async () => {
  const [completedDates, workedDates] = await Promise.all([
    getCompletedDatesInRange(uid, gsStr, toDateString(ge)),
    getWorkoutDatesInRange(uid, gsStr, toDateString(ge)),
  ])
  return { completed: completedDates, worked: workedDates }
})
const completed = new Set(data?.completed ?? [])
const worked = new Set(data?.worked ?? [])
```
기존 `useState(completed/worked)` + 그 useEffect 제거. 도트 렌더(주중 회색 포함)는 그대로.

- [ ] **Step 3: 챌린지 위젯(ChallengeWidgets) 전환**

`ChallengeWidgets.tsx`의 challenges 조회를 useSWR `k.challenges(uid)` + `getActiveChallenges(uid)`로 전환. 빈 배열이면 `return null`(현행) 유지. 기존 useState/useEffect/`.then+cancelled` 제거.

- [ ] **Step 4: 검증**

Run: `npx tsc --noEmit` → 출력 없음. `npx eslint src/app/page.tsx src/components/home/WorkoutCalendar.tsx src/components/home/ChallengeWidgets.tsx` → 출력 없음.

- [ ] **Step 5: 커밋**

```bash
git add src/app/page.tsx src/components/home/WorkoutCalendar.tsx src/components/home/ChallengeWidgets.tsx
git commit -m "perf(home): 통계·캘린더·챌린지 위젯 useSWR 캐시 전환"
```

---

## Task 4: 챌린지 탭 읽기 + 쓰기 무효화

**Files:** Modify `src/app/challenge/page.tsx`, `src/components/challenge/ChallengeDashboardCard.tsx`, `src/components/challenge/AddChallengePopup.tsx`

**Interfaces:** Consumes `k.challenges`, `matchPrefix`, `getActiveChallenges`, 기존 변이(addAttempt/updateAttemptDate/deleteAttempt/resetChallenge/deleteChallenge/updateChallenge/startChallenge).

- [ ] **Step 1: 챌린지 페이지 읽기 전환**

`app/challenge/page.tsx`의 challenges 조회 useState/useEffect를 useSWR `k.challenges(uid)`로. 카드에 내려주던 `onChanged`(수동 reload) 대신, 페이지에서 `const { mutate } = useSWRConfig()` + `onChanged={() => mutate(matchPrefix('challenges', uid))}` 전달. loading/empty 분기는 `data === undefined`/`data.length===0` 기준.
```tsx
import useSWR, { useSWRConfig } from 'swr'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'
// ...
const uid = getLoggedInUser()?.id ?? ''
const { data: challenges } = useSWR(uid ? k.challenges(uid) : null, () => getActiveChallenges(uid))
const { mutate } = useSWRConfig()
const reload = () => mutate(matchPrefix('challenges', uid))
// AddChallengePopup onStarted/카드 onChanged → reload
```

- [ ] **Step 2: 카드/팝업 무효화 연결**

`ChallengeDashboardCard.tsx`: 카드 내부 변이 핸들러(handleLog/handleUpdateDate/handleDeleteAttempt/handleReset/handleDelete/수정저장)는 이미 `onChanged()` 호출 → 이제 `onChanged`가 `reload`(challenges mutate)이므로 추가 변경 불필요. (카드가 자체적으로 무효화하지 않고 onChanged에 위임하는 현 구조 유지.)
`AddChallengePopup.tsx`: 시작 성공 시 `onStarted()` 호출 → 페이지의 reload 연결 확인.
홈 위젯도 같은 `challenges` 키라 챌린지 변이 시 함께 갱신됨(자동).

- [ ] **Step 3: 검증**

Run: `npx tsc --noEmit` → 출력 없음. `npx eslint src/app/challenge/page.tsx src/components/challenge/ChallengeDashboardCard.tsx src/components/challenge/AddChallengePopup.tsx` → 출력 없음.

- [ ] **Step 4: 커밋**

```bash
git add src/app/challenge/page.tsx src/components/challenge/ChallengeDashboardCard.tsx src/components/challenge/AddChallengePopup.tsx
git commit -m "perf(challenge): 챌린지 조회 useSWR + 변이 무효화"
```

---

## Task 5: 운동 탭 (defaults+logs+자동담기) + 운동 쓰기 무효화 + 개인운동 팝업

**Files:** Modify `src/app/workout/page.tsx`, `src/components/workout/WorkoutCard.tsx`, `src/components/workout/AddWorkoutPopup.tsx`

**Interfaces:** Consumes `k.dayDefaults`/`k.dayLogs`/`k.personalWorkouts`, `matchPrefix`, 기존 `getDefaultWorkoutsForWeekday`/`getWorkoutsForDate`/`getWorkoutLogsWithWorkout`/`addWorkoutToDate`/`getPersonalWorkouts`/변이.

- [ ] **Step 1: day-defaults/day-logs useSWR + 자동담기 effect**

`app/workout/page.tsx` `loadData` 제거하고 useSWR 2개 + 자동담기 effect + 파생(useMemo)으로 재구성. `ds`=선택 날짜 문자열.
```tsx
import useSWR, { useSWRConfig } from 'swr'
import { useRef, useMemo } from 'react'
import { k } from '@/lib/swr/keys'
// ...
const uid = getLoggedInUser()?.id ?? ''
const ds = toDateString(date)
const { mutate } = useSWRConfig()

const { data: defaults } = useSWR(uid ? k.dayDefaults(uid, ds) : null, async () => {
  const jsDay = new Date(`${ds}T00:00:00`).getDay()
  const weekday = jsDay === 0 ? 7 : jsDay
  const [weekday_, date_] = await Promise.all([
    weekday <= 5 ? getDefaultWorkoutsForWeekday(weekday) : Promise.resolve([]),
    getWorkoutsForDate(ds),
  ])
  return { weekday: weekday_, date: date_ } // 직렬화 위해 배열로
})
const { data: logs } = useSWR(uid ? k.dayLogs(uid, ds) : null, () => getWorkoutLogsWithWorkout(ds, uid))

// 자동담기: defaults·logs 로드 후, ds당 1회. WOD(요일)는 과거 포함, 그 외 오늘/미래만.
const autoAddedRef = useRef<Set<string>>(new Set())
useEffect(() => {
  if (!uid || !defaults || !logs) return
  if (autoAddedRef.current.has(ds)) return
  autoAddedRef.current.add(ds)
  const present = new Set(logs.map((l) => l.workout?.workout_id).filter(Boolean))
  const isPast = ds < toDateString(new Date())
  const weekdayIds = new Set(defaults.weekday.map((w) => w.id))
  const all = [...defaults.weekday, ...defaults.date]
  const missing = all.filter((w) => !present.has(w.id) && (!isPast || weekdayIds.has(w.id)))
  if (missing.length === 0) return
  ;(async () => {
    for (const w of missing) await addWorkoutToDate(uid, ds, w.id)
    mutate(k.dayLogs(uid, ds))
  })()
}, [uid, ds, defaults, logs, mutate])

// 파생: 그룹핑/정렬 (기존 로직을 useMemo로, defaults·logs 입력)
const groups = useMemo(() => buildGroups(logs ?? [], [...(defaults?.weekday ?? []), ...(defaults?.date ?? [])]), [logs, defaults])
const loading = logs === undefined || defaults === undefined
```
기존 `loadData`의 그룹핑/정렬(공용→프로그램 순 orderIndex, 개인, 시즌1 레거시 섹션 분리) 로직을 순수 함수 `buildGroups(logs, defaults)`로 추출(같은 파일 하단). 카드에 `onChanged={() => mutate(k.dayLogs(uid, ds))}` 전달. cardio도 useSWR로 전환 가능하나 범위 밖이면 기존 유지(단 setState-in-effect 경고 주의) — cardio는 `useSWR(uid?['cardio',uid,ds]:null, ()=>getCardioLogs(ds,uid))`로 함께 전환 권장.

- [ ] **Step 2: WorkoutCard 무효화 (완료/무게/메모/빼기)**

`WorkoutCard.tsx`: 완료 토글·무게·메모 저장(upsertWorkoutLog)과 `handleRemoveWorkout`(deleteWorkoutLogs) 후, 그날 로그·홈 키 무효화. `useSWRConfig().mutate` 사용. 낙관적 로컬 상태는 유지하고, 저장 완료 후 `cal-dates`·`home-stats`를 무효화(완료 수 반영). day-logs는 onChanged(상위)로.
```tsx
import { useSWRConfig } from 'swr'
import { matchPrefix } from '@/lib/swr/revalidate'
// ...
const { mutate } = useSWRConfig()
const uid = items[0]?.user_id ?? ''
// 완료/무게/메모 저장 디바운스 콜백 끝에서: mutate(matchPrefix('cal-dates', uid)); mutate(matchPrefix('home-stats', uid))
// handleRemoveWorkout: deleteWorkoutLogs 후 onChanged?.() (day-logs) + 위 cal/home 무효화
```
(WorkoutCard는 `user_id`를 로그에서 얻거나, prop으로 uid를 받도록 추가 — 가장 단순히 `items[0]?.user_id`. 없으면 `getLoggedInUser()?.id`.)

- [ ] **Step 3: AddWorkoutPopup (개인운동 목록 + 생성/수정/보관 무효화)**

`AddWorkoutPopup.tsx`: 개인운동 목록 조회를 `useSWR(k.personalWorkouts(uid), () => getPersonalWorkouts(uid))`로. 생성/수정/숨김(create/update/archivePersonalWorkout) 후 `mutate(matchPrefix('personal-workouts', uid))`. "만들기"(생성+담기)는 추가로 그날 `mutate(k.dayLogs(uid, date))`(이미 onAdded로 상위 갱신 시 그쪽에서). 기존 `getPersonalWorkouts().then(setWorkouts)` 제거.

- [ ] **Step 4: 검증**

Run: `npx tsc --noEmit` → 출력 없음. `npx eslint src/app/workout/page.tsx src/components/workout/WorkoutCard.tsx src/components/workout/AddWorkoutPopup.tsx` → 출력 없음.
(자동담기 중복 방지: 같은 ds 재마운트 시 autoAddedRef는 컴포넌트 생존 동안 유효 — 날짜 이동 후 복귀 시 재실행되나, presentWorkoutIds로 이미 담긴 건 missing=0이라 무해.)

- [ ] **Step 5: 커밋**

```bash
git add src/app/workout/page.tsx src/components/workout/WorkoutCard.tsx src/components/workout/AddWorkoutPopup.tsx
git commit -m "perf(workout): 그날 defaults/logs useSWR + 자동담기 분리 + 변이 무효화"
```

---

## Task 6: PR 탭 읽기 + 쓰기 무효화

**Files:** Modify `src/app/pr/page.tsx`

**Interfaces:** Consumes `k.pr1rm`/`k.prNrm`/`k.prPace`, `matchPrefix`, 기존 getAll/upsert/delete (1RM·NRM·Pace).

- [ ] **Step 1: 3개 조회 useSWR + 변이 무효화**

`pr/page.tsx`의 `Promise.all([getAll1RM,getAllNRM,getAllPaceRecords])` useEffect를 3개 useSWR로(또는 하나의 키 `['pr', uid]`로 묶어도 됨 — 분리 권장):
```tsx
const uid = getLoggedInUser()?.id ?? ''
const { data: rm } = useSWR(uid ? k.pr1rm(uid) : null, () => getAll1RM(uid))
const { data: nrm } = useSWR(uid ? k.prNrm(uid) : null, () => getAllNRM(uid))
const { data: pace } = useSWR(uid ? k.prPace(uid) : null, () => getAllPaceRecords(uid))
const { mutate } = useSWRConfig()
// upsert1RM 후: mutate(matchPrefix('pr-1rm', uid))
// upsertNRM/deleteNRM 후: mutate(matchPrefix('pr-nrm', uid))
// upsertPaceRecord/deletePaceRecord 후: mutate(matchPrefix('pr-pace', uid))
```
기존 useState/useEffect 제거. `rm/nrm/pace`가 undefined일 때 로딩 처리.

- [ ] **Step 2: 검증**

Run: `npx tsc --noEmit` → 출력 없음. `npx eslint src/app/pr/page.tsx` → 출력 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/app/pr/page.tsx
git commit -m "perf(pr): 1RM/nRM/Pace useSWR + 변이 무효화"
```

---

## Task 7: MY 탭 읽기 + 쓰기 무효화

**Files:** Modify `src/app/my/page.tsx`

**Interfaces:** Consumes `k.dailyLog`/`k.weightRange`, `matchPrefix`, 기존 `getDailyLog`/`upsertDailyLog` + 체중 범위 supabase 쿼리.

- [ ] **Step 1: daily-log + weight-range useSWR + 무효화**

`my/page.tsx`: 선택 날짜 daily-log를 `useSWR(k.dailyLog(uid, date), () => getDailyLog(date, uid))`. 체중 그래프 범위 쿼리(인라인 supabase)는 `useSWR(k.weightRange(uid, startStr, endStr), () => fetchWeightRange(...))`로(인라인 fetcher). `upsertDailyLog` 후 `mutate(matchPrefix('daily-log', uid, date))` + `mutate(matchPrefix('weight-range', uid))`. 기존 useEffect 조회 제거.

- [ ] **Step 2: 검증**

Run: `npx tsc --noEmit` → 출력 없음. `npx eslint src/app/my/page.tsx` → 출력 없음.

- [ ] **Step 3: 커밋**

```bash
git add src/app/my/page.tsx
git commit -m "perf(my): daily-log/체중범위 useSWR + 변이 무효화"
```

---

## Self-Review (작성자 점검)

**1. 스펙 커버리지**: §3 SWRConfig→T1. §4 키→keys.ts(T1) 전부. §5 provider→T1. §6 읽기 7화면→T2(헤더)·T3(홈3)·T4(챌린지)·T5(운동+개인운동팝업)·T6(PR)·T7(MY). §7 무효화→각 화면 변이 처리(T4/T5/T6/T7) + cal/home(T5 WorkoutCard). §8 운동 자동담기→T5 Step1. §9 영향파일 전부 태스크에 포함. §10 에러=SWR 기본+cached 우선. §11 테스트=T1 vitest 7 + 게이트. 누락 없음.
**2. 플레이스홀더**: 인프라(T1)는 완전 코드. 화면 전환은 "recipe + 화면별 구체 키/fetcher/위치/무효화" 제공(동일 보일러플레이트 8회 반복 대신 레시피 1회 + 파라미터 명시) — TBD/모호지시 없음. 운동 자동담기(T5)는 완전 코드.
**3. 타입/키 일관성**: 키 팩토리 `k.*`·`matchPrefix` 명칭 전 태스크 일치. `dayDefaults` fetcher가 `{weekday,date}` 반환 ↔ 자동담기에서 `defaults.weekday`/`defaults.date` 사용 일치. `useSWRConfig().mutate` 사용 규칙(전역 mutate 금지) Global Constraints에 명시.
