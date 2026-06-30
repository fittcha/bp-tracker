# 개인운동 공유 기능 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 개인운동을 아이디 검색으로 고른 여러 유저에게 공유하고, 받는 쪽은 앱 로드 시 수락/거부, 보낸 쪽은 응답 전 취소할 수 있게 한다.

**Architecture:** `workout_shares` 대기 전용 테이블(payload 스냅샷 + source_workout_id). 보내기는 라이브러리 `⋯ → 공유` 모달(아이디 ilike 검색·체크박스·취소). 받기는 `ClientLayout`이 앱 로드 시 대기건 조회 후 전역 목록 모달로 수락/거부. 기존 SWR 캐시·테마 토큰 패턴을 그대로 따른다.

**Tech Stack:** Next.js 16 App Router, React 19, TypeScript, Tailwind v4, Supabase(anon, RLS allow-all), SWR, vitest.

## Global Constraints

- 공유 단위 = 개인운동 1개(`owner_user_id`=본인). 공용·시즌1 운동엔 공유 진입점 없음.
- 빈 검색어(`query.trim()===''`)는 조회 안 함 → `[]`. 검색은 `ilike '%query%'` + `active=true` + 본인 제외, limit 20.
- 공유 시점 **스냅샷**(payload jsonb)으로 저장. 수락은 payload만 사용(원본 미참조).
- 수락/거부/취소 = `workout_shares` 행 **삭제**(상태 컬럼·이력 없음).
- 무효화는 바운드 `useSWRConfig().mutate`(전역 import 금지) + `matchPrefix`. 키 `k.pendingShares(uid)`.
- 테마 토큰만 사용: 네이비 `accent`(#1E3A5F)/골드 `accent-pop`(#C0974A)/`accent-light`/`surface`/`border`/`text-secondary`/`danger`. 모달 관례: `fixed inset-0 z-[100] bg-foreground/40`, 중앙 `bg-surface rounded-2xl`.
- 게이트: `npx tsc --noEmit` + `npx eslint <touched>` + `npx vitest run`.
- 신규 컴포넌트는 `'use client'`.

---

## File Structure

- `supabase/migration-workout-shares.sql` — 테이블 + 인덱스(신규).
- `src/lib/workout/share-payload.ts` — 순수 헬퍼: `SharePayload` 타입, `buildSharePayload`, `isBlankQuery`, `filterNewRecipients`(supabase import 없음 → vitest 가능).
- `src/lib/api/workout-shares.ts` — 공유 CRUD(신규).
- `src/lib/api/users.ts` — `searchUsersByUsername` 추가(수정).
- `src/lib/swr/keys.ts` — `pendingShares` 키 추가(수정).
- `src/components/workout/ShareWorkoutModal.tsx` — 보내기 모달(신규).
- `src/components/workout/AddWorkoutPopup.tsx` — ⋯ 메뉴 '공유' + 모달 연결(수정).
- `src/components/PendingSharesModal.tsx` — 받기 목록 모달(신규).
- `src/components/ClientLayout.tsx` — 앱 로드 시 대기 게이트(수정).
- `src/lib/workout/share-payload.test.ts` — vitest(신규).

---

### Task 1: 마이그레이션 + 순수 헬퍼 + SWR 키

**Files:**
- Create: `supabase/migration-workout-shares.sql`
- Create: `src/lib/workout/share-payload.ts`
- Create: `src/lib/workout/share-payload.test.ts`
- Modify: `src/lib/swr/keys.ts`

**Interfaces:**
- Consumes: `Workout`, `WorkoutExercise` from `@/lib/api/workouts`.
- Produces:
  - `interface SharePayload { title: string; category: string | null; exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[] }`
  - `buildSharePayload(workout: Pick<Workout, 'title' | 'category'>, exercises: WorkoutExercise[]): SharePayload`
  - `isBlankQuery(query: string): boolean`
  - `filterNewRecipients(toIds: string[], existingPendingToIds: string[]): string[]`
  - `k.pendingShares(uid: string) => ['pending-shares', uid]`

- [ ] **Step 1: 마이그레이션 SQL 작성**

Create `supabase/migration-workout-shares.sql`:
```sql
-- 개인운동 공유 대기 테이블. 행 존재 = pending. 수락/거부/취소 시 행 삭제.
create table if not exists workout_shares (
  id                uuid primary key default gen_random_uuid(),
  from_user_id      uuid not null references users(id),
  to_user_id        uuid not null references users(id),
  source_workout_id uuid,            -- 보낸 쪽 참조용(취소·대기목록). 원본 삭제돼도 payload로 수락 가능 → FK 미설정
  payload           jsonb not null,  -- 공유 시점 스냅샷 { title, category, exercises:[...] }
  created_at        timestamptz not null default now()
);
create index if not exists idx_workout_shares_to on workout_shares (to_user_id);
create index if not exists idx_workout_shares_from_src on workout_shares (from_user_id, source_workout_id);

-- RLS: 앱 기존 방식(anon 전체 허용)
alter table workout_shares enable row level security;
drop policy if exists workout_shares_all on workout_shares;
create policy workout_shares_all on workout_shares for all using (true) with check (true);
```

- [ ] **Step 2: 실패 테스트 작성**

Create `src/lib/workout/share-payload.test.ts`:
```ts
import { describe, it, expect } from 'vitest'
import { buildSharePayload, isBlankQuery, filterNewRecipients } from './share-payload'
import type { WorkoutExercise } from '@/lib/api/workouts'

const ex = (over: Partial<WorkoutExercise>): WorkoutExercise => ({
  id: 'x', workout_id: 'w', section: null, exercise_name: 'E', sets: null,
  reps: null, notes: null, sort_order: 0, set_group: 1, set_info: null, set_lead: null, ...over,
})

describe('buildSharePayload', () => {
  it('strips id/workout_id, keeps set_group/set_info/set_lead, sorts by sort_order', () => {
    const out = buildSharePayload(
      { title: '가슴 루틴', category: '가슴' },
      [ex({ id: 'b', sort_order: 1, exercise_name: 'B', set_info: 'Superset · 3 Sets', set_lead: 'into' }),
       ex({ id: 'a', sort_order: 0, exercise_name: 'A', set_info: '3 Sets' })],
    )
    expect(out.title).toBe('가슴 루틴')
    expect(out.category).toBe('가슴')
    expect(out.exercises.map((e) => e.exercise_name)).toEqual(['A', 'B'])
    expect(out.exercises[1]).toMatchObject({ set_info: 'Superset · 3 Sets', set_lead: 'into', set_group: 1 })
    expect(out.exercises[0]).not.toHaveProperty('id')
    expect(out.exercises[0]).not.toHaveProperty('workout_id')
  })
  it('null category → null', () => {
    expect(buildSharePayload({ title: 'T', category: null }, []).category).toBeNull()
  })
})

describe('isBlankQuery', () => {
  it('true for empty/whitespace', () => {
    expect(isBlankQuery('')).toBe(true)
    expect(isBlankQuery('   ')).toBe(true)
  })
  it('false for non-blank', () => {
    expect(isBlankQuery('som')).toBe(false)
  })
})

describe('filterNewRecipients', () => {
  it('removes already-pending and dedups input', () => {
    expect(filterNewRecipients(['a', 'b', 'b', 'c'], ['b'])).toEqual(['a', 'c'])
  })
  it('empty when all pending', () => {
    expect(filterNewRecipients(['a', 'b'], ['a', 'b'])).toEqual([])
  })
})
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `npx vitest run src/lib/workout/share-payload.test.ts`
Expected: FAIL — `share-payload.ts` 없음(또는 export 없음).

- [ ] **Step 4: 순수 헬퍼 구현**

Create `src/lib/workout/share-payload.ts`:
```ts
import type { Workout, WorkoutExercise } from '@/lib/api/workouts'

export interface SharePayload {
  title: string
  category: string | null
  exercises: Omit<WorkoutExercise, 'id' | 'workout_id'>[]
}

// 원본 개인운동 → 공유 스냅샷. id/workout_id 제거, sort_order 순 보존(set_group/set_info/set_lead 포함).
export function buildSharePayload(
  workout: Pick<Workout, 'title' | 'category'>,
  exercises: WorkoutExercise[],
): SharePayload {
  return {
    title: workout.title,
    category: workout.category ?? null,
    exercises: exercises
      .slice()
      .sort((a, b) => a.sort_order - b.sort_order)
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      .map(({ id, workout_id, ...rest }) => rest),
  }
}

export function isBlankQuery(query: string): boolean {
  return query.trim() === ''
}

// 실제로 새로 insert할 수신자: 입력 중복 제거 + 이미 대기 중인 수신자 제외.
export function filterNewRecipients(toIds: string[], existingPendingToIds: string[]): string[] {
  const seen = new Set(existingPendingToIds)
  const out: string[] = []
  for (const id of toIds) {
    if (seen.has(id)) continue
    seen.add(id)
    out.push(id)
  }
  return out
}
```

- [ ] **Step 5: SWR 키 추가**

Modify `src/lib/swr/keys.ts` — `weightRange` 줄 다음에 추가:
```ts
  pendingShares: (uid: string) => ['pending-shares', uid] as const,
```

- [ ] **Step 6: 테스트 통과 + 게이트 확인**

Run: `npx vitest run src/lib/workout/share-payload.test.ts` → PASS
Run: `npx tsc --noEmit` → clean
Run: `npx eslint src/lib/workout/share-payload.ts src/lib/swr/keys.ts` → no new errors

- [ ] **Step 7: Commit**

```bash
git add supabase/migration-workout-shares.sql src/lib/workout/share-payload.ts src/lib/workout/share-payload.test.ts src/lib/swr/keys.ts
git commit -m "feat(share): workout_shares 마이그레이션 + 공유 순수 헬퍼 + SWR 키"
```

---

### Task 2: API 레이어 (검색 + 공유 CRUD)

**Files:**
- Modify: `src/lib/api/users.ts`
- Create: `src/lib/api/workout-shares.ts`

**Interfaces:**
- Consumes: `supabase` from `@/lib/supabase`; `User` from `@/lib/api/users`; `SharePayload`, `buildSharePayload`, `isBlankQuery`, `filterNewRecipients` from `@/lib/workout/share-payload`; `createPersonalWorkout`, `getWorkoutExercises`, `Workout` from `@/lib/api/workouts`.
- Produces:
  - `searchUsersByUsername(query: string, excludeId: string): Promise<User[]>`
  - `interface PendingShare { id: string; fromUsername: string; title: string }`
  - `interface SentShare { id: string; toUsername: string }`
  - `shareWorkout(fromId: string, sourceWorkoutId: string, toIds: string[]): Promise<void>`
  - `getPendingShares(toId: string): Promise<PendingShare[]>`
  - `getSentPendingShares(fromId: string, sourceWorkoutId: string): Promise<SentShare[]>`
  - `acceptShare(shareId: string): Promise<void>`
  - `rejectShare(shareId: string): Promise<void>`
  - `cancelShare(shareId: string): Promise<void>`

- [ ] **Step 1: `searchUsersByUsername` 추가**

Modify `src/lib/api/users.ts` — `import { isBlankQuery } from '@/lib/workout/share-payload'` 추가하고, `getUserByUsername` 다음에:
```ts
// 아이디 like 검색(공유 대상 선택용). 빈 문자열은 조회 안 함. 본인·비활성 제외.
export async function searchUsersByUsername(query: string, excludeId: string): Promise<User[]> {
  if (isBlankQuery(query)) return []
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .ilike('username', `%${query.trim()}%`)
    .eq('active', true)
    .neq('id', excludeId)
    .order('username', { ascending: true })
    .limit(20)
  if (error) throw error
  return (data ?? []) as User[]
}
```

- [ ] **Step 2: `workout-shares.ts` 구현**

Create `src/lib/api/workout-shares.ts`:
```ts
import { supabase } from '@/lib/supabase'
import { buildSharePayload, filterNewRecipients, type SharePayload } from '@/lib/workout/share-payload'
import { createPersonalWorkout, getWorkoutExercises, type Workout } from '@/lib/api/workouts'

export interface PendingShare { id: string; fromUsername: string; title: string }
export interface SentShare { id: string; toUsername: string }

// 보낸 사람 본인 → 선택 유저들에게 공유. payload 스냅샷, 이미 대기 중인 수신자는 건너뜀.
export async function shareWorkout(fromId: string, sourceWorkoutId: string, toIds: string[]): Promise<void> {
  if (toIds.length === 0) return
  const { data: w, error: we } = await supabase
    .from('workouts').select('title, category').eq('id', sourceWorkoutId).single()
  if (we) throw we
  const exercises = await getWorkoutExercises(sourceWorkoutId)
  const payload: SharePayload = buildSharePayload(w as Pick<Workout, 'title' | 'category'>, exercises)

  const { data: existing, error: ee } = await supabase
    .from('workout_shares').select('to_user_id')
    .eq('from_user_id', fromId).eq('source_workout_id', sourceWorkoutId).in('to_user_id', toIds)
  if (ee) throw ee
  const already = (existing ?? []).map((r) => r.to_user_id as string)
  const targets = filterNewRecipients(toIds, already)
  if (targets.length === 0) return

  const rows = targets.map((toId) => ({
    from_user_id: fromId, to_user_id: toId, source_workout_id: sourceWorkoutId, payload,
  }))
  const { error: ie } = await supabase.from('workout_shares').insert(rows)
  if (ie) throw ie
}

// 받는 사람 대기건 + 보낸사람 username. 2-step(임베드 힌트 회피).
export async function getPendingShares(toId: string): Promise<PendingShare[]> {
  const { data, error } = await supabase
    .from('workout_shares').select('id, from_user_id, payload')
    .eq('to_user_id', toId).order('created_at', { ascending: true })
  if (error) throw error
  const rows = (data ?? []) as { id: string; from_user_id: string; payload: SharePayload }[]
  if (rows.length === 0) return []
  const fromIds = [...new Set(rows.map((r) => r.from_user_id))]
  const { data: us, error: ue } = await supabase.from('users').select('id, username').in('id', fromIds)
  if (ue) throw ue
  const nameById = new Map((us ?? []).map((u) => [u.id as string, u.username as string]))
  return rows.map((r) => ({ id: r.id, fromUsername: nameById.get(r.from_user_id) ?? '알 수 없음', title: r.payload?.title ?? '운동' }))
}

// 공유 모달의 '대기 중' 목록(이 운동을 누구에게 보냈나) + 받는사람 username.
export async function getSentPendingShares(fromId: string, sourceWorkoutId: string): Promise<SentShare[]> {
  const { data, error } = await supabase
    .from('workout_shares').select('id, to_user_id')
    .eq('from_user_id', fromId).eq('source_workout_id', sourceWorkoutId).order('created_at', { ascending: true })
  if (error) throw error
  const rows = (data ?? []) as { id: string; to_user_id: string }[]
  if (rows.length === 0) return []
  const toIds = [...new Set(rows.map((r) => r.to_user_id))]
  const { data: us, error: ue } = await supabase.from('users').select('id, username').in('id', toIds)
  if (ue) throw ue
  const nameById = new Map((us ?? []).map((u) => [u.id as string, u.username as string]))
  return rows.map((r) => ({ id: r.id, toUsername: nameById.get(r.to_user_id) ?? '알 수 없음' }))
}

// 수락: payload로 내 라이브러리에 개인운동 생성 후 행 삭제.
export async function acceptShare(shareId: string): Promise<void> {
  const { data, error } = await supabase
    .from('workout_shares').select('to_user_id, payload').eq('id', shareId).single()
  if (error) throw error
  const row = data as { to_user_id: string; payload: SharePayload }
  if (row?.payload?.title) {
    await createPersonalWorkout(row.to_user_id, row.payload.title, row.payload.category ?? null, row.payload.exercises ?? [])
  }
  const { error: de } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (de) throw de
}

// 거부/취소: 행 삭제(동작 동일, 의미 구분).
export async function rejectShare(shareId: string): Promise<void> {
  const { error } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (error) throw error
}
export async function cancelShare(shareId: string): Promise<void> {
  const { error } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (error) throw error
}
```

- [ ] **Step 3: 게이트 확인**

Run: `npx tsc --noEmit` → clean (Task 1 헬퍼가 이미 있어야 함)
Run: `npx eslint src/lib/api/users.ts src/lib/api/workout-shares.ts` → no new errors
Run: `npx vitest run` → 기존 통과 유지(이 태스크는 새 단위테스트 없음 — 순수 로직은 Task 1에서 커버, API는 tsc+수동).

- [ ] **Step 4: Commit**

```bash
git add src/lib/api/users.ts src/lib/api/workout-shares.ts
git commit -m "feat(share): 아이디 검색 + 공유 CRUD API (share/getPending/getSent/accept/reject/cancel)"
```

---

### Task 3: 보내기 모달 + 라이브러리 ⋯ '공유' 연결

**Files:**
- Create: `src/components/workout/ShareWorkoutModal.tsx`
- Modify: `src/components/workout/AddWorkoutPopup.tsx`

**Interfaces:**
- Consumes: `searchUsersByUsername` from `@/lib/api/users`; `shareWorkout`, `getSentPendingShares`, `cancelShare`, `type SentShare` from `@/lib/api/workout-shares`; `type User` from `@/lib/api/users`; `Workout` from `@/lib/api/workouts`.
- Produces: `ShareWorkoutModal({ userId, workout, onClose }: { userId: string; workout: Workout; onClose: () => void })`.

- [ ] **Step 1: `ShareWorkoutModal` 구현 (테마·폴리시 반영)**

Create `src/components/workout/ShareWorkoutModal.tsx`:
```tsx
'use client'

import { useState, useEffect, useCallback } from 'react'
import { searchUsersByUsername, type User } from '@/lib/api/users'
import { shareWorkout, getSentPendingShares, cancelShare, type SentShare } from '@/lib/api/workout-shares'
import type { Workout } from '@/lib/api/workouts'

interface Props { userId: string; workout: Workout; onClose: () => void }

export default function ShareWorkoutModal({ userId, workout, onClose }: Props) {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<User[]>([])
  const [searching, setSearching] = useState(false)
  const [selected, setSelected] = useState<User[]>([])
  const [pending, setPending] = useState<SentShare[]>([])
  const [sharing, setSharing] = useState(false)
  const [err, setErr] = useState<string | null>(null)
  const [done, setDone] = useState(false)

  const loadPending = useCallback(async () => {
    try { setPending(await getSentPendingShares(userId, workout.id)) } catch { /* 무시 */ }
  }, [userId, workout.id])

  useEffect(() => { loadPending() }, [loadPending])

  // 검색 디바운스
  useEffect(() => {
    if (query.trim() === '') { setResults([]); return }
    setSearching(true)
    const t = setTimeout(async () => {
      try { setResults(await searchUsersByUsername(query, userId)) }
      catch { setResults([]) }
      finally { setSearching(false) }
    }, 250)
    return () => clearTimeout(t)
  }, [query, userId])

  const pendingUsernames = new Set(pending.map((p) => p.toUsername))
  const selectedIds = new Set(selected.map((u) => u.id))

  function toggle(u: User) {
    setSelected((prev) => prev.some((s) => s.id === u.id) ? prev.filter((s) => s.id !== u.id) : [...prev, u])
  }

  async function handleShare() {
    if (selected.length === 0) return
    setSharing(true); setErr(null)
    try {
      await shareWorkout(userId, workout.id, selected.map((u) => u.id))
      setSelected([]); setQuery(''); setResults([]); setDone(true)
      await loadPending()
      setTimeout(() => setDone(false), 1800)
    } catch (e) {
      setErr(e instanceof Error ? e.message : '공유에 실패했습니다.')
    } finally { setSharing(false) }
  }

  async function handleCancel(shareId: string) {
    try { await cancelShare(shareId); await loadPending() }
    catch (e) { setErr(e instanceof Error ? e.message : '취소에 실패했습니다.') }
  }

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 bg-foreground/40"
      onClick={(e) => { if (e.target === e.currentTarget) onClose() }}>
      <div className="w-full max-w-md bg-surface rounded-2xl max-h-[85vh] flex flex-col overflow-hidden">
        {/* 헤더 */}
        <div className="px-4 pt-4 pb-3 border-b border-border flex items-center justify-between flex-shrink-0">
          <div className="min-w-0">
            <p className="text-[11px] text-text-secondary">운동 공유</p>
            <h2 className="text-base font-bold text-foreground truncate">{workout.title}</h2>
          </div>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center text-text-secondary rounded-lg shrink-0">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-3">
          {/* 검색 */}
          <input
            autoFocus value={query} onChange={(e) => setQuery(e.target.value)} placeholder="아이디 검색"
            className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface text-foreground placeholder:text-text-secondary outline-none focus:border-accent"
          />

          {/* 선택 칩(골드 톤) */}
          {selected.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {selected.map((u) => (
                <span key={u.id} className="inline-flex items-center gap-1 pl-2.5 pr-1.5 py-1 rounded-full bg-accent-pop/15 text-accent-pop text-xs font-medium">
                  {u.username}
                  <button onClick={() => toggle(u)} className="w-4 h-4 flex items-center justify-center" aria-label="제거">
                    <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
                  </button>
                </span>
              ))}
            </div>
          )}

          {/* 검색 결과 */}
          {query.trim() === '' ? (
            <p className="text-xs text-text-secondary/70 py-2">아이디를 입력하세요.</p>
          ) : searching ? (
            <p className="text-xs text-text-secondary/70 py-2">검색 중…</p>
          ) : results.length === 0 ? (
            <p className="text-xs text-text-secondary/70 py-2">검색 결과 없음</p>
          ) : (
            <div className="space-y-0.5">
              {results.map((u) => {
                const isPending = pendingUsernames.has(u.username)
                const isSel = selectedIds.has(u.id)
                return (
                  <button key={u.id} disabled={isPending} onClick={() => toggle(u)}
                    className={`w-full flex items-center gap-2.5 px-2 py-2 rounded-lg text-left transition-colors ${isPending ? 'opacity-40' : 'hover:bg-accent-light'}`}>
                    <span className={`w-4 h-4 rounded border flex items-center justify-center shrink-0 ${isSel ? 'bg-accent border-accent text-white' : 'border-border'}`}>
                      {isSel && <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><polyline points="20 6 9 17 4 12" /></svg>}
                    </span>
                    <span className="text-sm text-foreground flex-1">{u.username}</span>
                    {isPending && <span className="text-[10px] text-text-secondary">대기 중</span>}
                  </button>
                )
              })}
            </div>
          )}

          {/* 공유 대기 중(취소) */}
          {pending.length > 0 && (
            <div className="pt-2 border-t border-border">
              <p className="text-[11px] font-semibold text-text-secondary mb-1.5">공유 대기 중</p>
              <div className="space-y-0.5">
                {pending.map((p) => (
                  <div key={p.id} className="flex items-center justify-between px-2 py-1.5">
                    <span className="text-sm text-foreground">{p.toUsername}</span>
                    <button onClick={() => handleCancel(p.id)} className="text-[11px] font-medium text-danger px-2 py-1 rounded">취소</button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {err && <p className="text-xs text-danger">{err}</p>}
          {done && <p className="text-xs text-accent-pop">공유했어요.</p>}
        </div>

        {/* 푸터 액션 */}
        <div className="px-4 py-3 border-t border-border flex-shrink-0">
          <button onClick={handleShare} disabled={selected.length === 0 || sharing}
            className="w-full py-2.5 rounded-lg text-sm font-semibold bg-accent text-white disabled:opacity-50">
            {sharing ? '공유 중…' : selected.length > 0 ? `${selected.length}명에게 공유하기` : '공유하기'}
          </button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: `AddWorkoutPopup`에 '공유' 연결**

Modify `src/components/workout/AddWorkoutPopup.tsx`:

(a) import 추가(파일 상단 import 묶음에):
```ts
import ShareWorkoutModal from '@/components/workout/ShareWorkoutModal'
```
(b) 상태 추가(`const [menuOpenId, setMenuOpenId] = useState<string | null>(null)` 다음 줄):
```ts
  const [shareTarget, setShareTarget] = useState<Workout | null>(null)
```
(c) ⋯ 메뉴(수정/숨김 버튼들 사이/아래)에 '공유' 추가 — `handleEditWorkout` 버튼과 `handleArchiveWorkout` 버튼 사이에:
```tsx
                          <button
                            onClick={() => { setMenuOpenId(null); setShareTarget(w) }}
                            className="w-full text-left px-3 py-2 text-xs font-medium text-foreground hover:bg-accent-light transition-colors"
                          >
                            공유
                          </button>
```
(d) 모달 렌더 — 최상위 딤 배경 `<div className="fixed inset-0 z-[100] ...">` **닫는 태그 직전**(가장 바깥 div 안 끝부분)에:
```tsx
      {shareTarget && (
        <ShareWorkoutModal userId={userId} workout={shareTarget} onClose={() => setShareTarget(null)} />
      )}
```

- [ ] **Step 4: 게이트 확인**

Run: `npx tsc --noEmit` → clean
Run: `npx eslint src/components/workout/ShareWorkoutModal.tsx src/components/workout/AddWorkoutPopup.tsx` → no new errors (미사용 변수 0)
Run: `npx vitest run` → 기존 통과 유지

- [ ] **Step 5: Commit**

```bash
git add src/components/workout/ShareWorkoutModal.tsx src/components/workout/AddWorkoutPopup.tsx
git commit -m "feat(share): 보내기 모달(검색·체크·칩·대기취소) + 라이브러리 ⋯ 공유 연결"
```

---

### Task 4: 받기 목록 모달 + 앱 로드 게이트

**Files:**
- Create: `src/components/PendingSharesModal.tsx`
- Modify: `src/components/ClientLayout.tsx`

**Interfaces:**
- Consumes: `getPendingShares`, `acceptShare`, `rejectShare`, `type PendingShare` from `@/lib/api/workout-shares`; `k` from `@/lib/swr/keys`; `matchPrefix` from `@/lib/swr/revalidate`; `useSWR`, `useSWRConfig` from `swr`; `getLoggedInUser` from `@/lib/auth`.
- Produces: `PendingSharesGate({ uid }: { uid: string })` (SWRConfig 내부에서 렌더, 대기건 있으면 모달 표시).

- [ ] **Step 1: `PendingSharesModal` 구현 (게이트 포함)**

Create `src/components/PendingSharesModal.tsx`:
```tsx
'use client'

import { useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import { getPendingShares, acceptShare, rejectShare } from '@/lib/api/workout-shares'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'

// SWRConfig 내부에서 렌더되어야 함(provider 사용). 대기건 1+ 이면 모달 노출.
export default function PendingSharesGate({ uid }: { uid: string }) {
  const { mutate } = useSWRConfig()
  const { data: shares } = useSWR(uid ? k.pendingShares(uid) : null, () => getPendingShares(uid))
  const [busyId, setBusyId] = useState<string | null>(null)
  const [closed, setClosed] = useState(false)

  if (!shares || shares.length === 0 || closed) return null

  async function handleAccept(id: string) {
    setBusyId(id)
    try {
      await acceptShare(id)
      mutate(k.pendingShares(uid))
      mutate(matchPrefix('personal-workouts', uid))
    } finally { setBusyId(null) }
  }
  async function handleReject(id: string) {
    setBusyId(id)
    try { await rejectShare(id); mutate(k.pendingShares(uid)) }
    finally { setBusyId(null) }
  }

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4 bg-foreground/50">
      <div className="w-full max-w-sm bg-surface rounded-2xl max-h-[80vh] flex flex-col overflow-hidden">
        <div className="px-4 pt-4 pb-3 border-b border-border flex items-center justify-between flex-shrink-0">
          <h2 className="text-base font-bold text-foreground">공유 받은 운동 <span className="text-accent-pop">{shares.length}</span></h2>
          <button onClick={() => setClosed(true)} className="w-8 h-8 flex items-center justify-center text-text-secondary rounded-lg">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
          </button>
        </div>
        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
          {shares.map((s) => (
            <div key={s.id} className="border border-border rounded-xl px-3 py-2.5">
              <p className="text-sm text-foreground"><span className="font-bold">{s.fromUsername}</span>님이 공유</p>
              <p className="text-sm font-semibold text-foreground mt-0.5">{s.title}</p>
              <div className="flex items-center gap-2 mt-2.5">
                <button onClick={() => handleReject(s.id)} disabled={busyId === s.id}
                  className="flex-1 py-2 rounded-lg text-sm font-medium border border-border text-text-secondary disabled:opacity-50">거부</button>
                <button onClick={() => handleAccept(s.id)} disabled={busyId === s.id}
                  className="flex-1 py-2 rounded-lg text-sm font-semibold bg-accent text-white disabled:opacity-50">수락</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: `ClientLayout`에 게이트 연결**

Modify `src/components/ClientLayout.tsx`:

(a) import 추가:
```ts
import PendingSharesGate from '@/components/PendingSharesModal'
```
(b) `content` JSX에서 `{!isLogin && <BottomNav />}` 다음 줄에 추가(SWRConfig 내부·로그인 제외·실유저만):
```tsx
      {!isLogin && uid !== 'anon' && <PendingSharesGate uid={uid} />}
```

- [ ] **Step 3: 게이트 확인**

Run: `npx tsc --noEmit` → clean
Run: `npx eslint src/components/PendingSharesModal.tsx src/components/ClientLayout.tsx` → no new errors
Run: `npx vitest run` → 기존 통과 유지

- [ ] **Step 4: Commit**

```bash
git add src/components/PendingSharesModal.tsx src/components/ClientLayout.tsx
git commit -m "feat(share): 받기 목록 모달 + 앱 로드 시 전역 게이트(수락/거부)"
```

---

### Task 5: 디자인 폴리시 + 수동 QA

**Files:**
- Modify: `src/components/workout/ShareWorkoutModal.tsx`, `src/components/PendingSharesModal.tsx` (시각 디테일만)

**Interfaces:** 변경 없음(스타일/카피만).

- [ ] **Step 1: frontend-design 원칙으로 두 모달 시각 다듬기**

스펙 §10.5 기준으로 점검·보정(기능 변경 금지):
- 간격/타입 스케일 일관(헤더 `text-base font-bold`, 보조 `text-[11px] text-text-secondary`), 탭 타겟 ≥40px 높이.
- 공유하기 버튼은 선택 수 반영("N명에게 공유하기"), 비활성 시 `opacity-50`.
- 받기 모달 수락=네이비 채움 / 거부=옅은 보더, 카드형 행.
- 빈/로딩/에러 카피: "아이디를 입력하세요" / "검색 중…" / "검색 결과 없음" / "공유했어요." 유지.
- `prefers-reduced-motion` 존중(트랜지션은 `transition-colors` 수준만, 큰 모션 없음).

- [ ] **Step 2: 수동 QA (dev 서버)**

Run: `npm run dev` 후 두 계정으로 확인 — 체크리스트:
- 라이브러리 개인운동 ⋯ → 공유 → 빈 검색 결과 0 → 아이디 입력 시 like 결과 → 체크/칩 누적 → "N명에게 공유하기" → 대기 목록에 표시 → 취소 동작.
- 상대 계정 앱 로드 시 목록 모달 → 수락 시 라이브러리에 추가(운동 추가 팝업에서 확인) / 거부 시 사라짐 → 새로고침해도 재출현 없음.
- 이미 대기 중 유저는 검색에서 "대기 중" 비활성.

- [ ] **Step 3: 게이트 + Commit**

Run: `npx tsc --noEmit` → clean / `npx eslint <두 파일>` → clean / `npx vitest run` → green
```bash
git add src/components/workout/ShareWorkoutModal.tsx src/components/PendingSharesModal.tsx
git commit -m "polish(share): 공유/받기 모달 시각 디테일·카피 다듬기"
```

---

## 적용/배포 메모

- 코드 머지 전/후 **라이브 DB에 `supabase/migration-workout-shares.sql` 1회 적용**(Supabase SQL editor). 신규 테이블이라 데이터 마이그레이션 없음.
- 머지 후 PWA 새 번들 받아야 받기 게이트가 동작.
