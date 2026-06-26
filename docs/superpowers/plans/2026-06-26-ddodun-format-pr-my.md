# ddodun 포맷 통일 + PR/MY 탭 (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ddodun의 화면 포맷을 roadtorxd에 차용한다 — 5탭 네비(홈/운동/챌린지/PR/MY), 홈 캘린더 2색 점, ddodun PR 탭(1RM/nRM/PACE/WOD) 이식, MY 탭. 색은 우리 파란색 유지.

**Architecture:** ddodun과 roadtorxd는 같은 Supabase 프로젝트(`qaiammqgkrrgfstqadef`)를 쓰되 ddodun=`ddodun` 스키마, roadtorxd=`public` 스키마. ddodun PR 파일들은 `@/lib/supabase`(앱별 클라이언트)·`@/lib/auth`(앱별 getLoggedInUser)를 동일 경로로 import하므로 **복사하면 우리 public 클라이언트+우리 auth로 자동 적응**된다. PR의 1RM은 우리 `public.user_1rm`(컬럼 일치)을 그대로 써서 기존 데이터 보존, nRM/PACE/WOD는 public에 신규 테이블 생성.

**Tech Stack:** Next.js 16.1.6 (App Router) · React 19 · TypeScript 5 (strict) · Tailwind CSS v4 · Supabase JS (anon, public 스키마) · lucide-react ^0.577.0 · recharts.

## Global Constraints

- **시맨틱 테마 토큰만**: `bg-surface`/`text-accent`/`bg-accent-light`/`border-border`/`text-text-secondary`/`text-foreground`/`text-danger`/`text-success`. 하드코딩 hex·`bg-blue-500`류 금지. (ddodun 파일의 토큰명이 우리 globals.css와 동일 → 파란 accent 자동 적용.)
- **테스트 하네스 없음** → 검증 게이트 = `npm run build`(타입체크) + `npm run lint`(변경 파일 0 에러) + dev 수동 확인. 자동 테스트 작성 단계 없음.
- **기존 시즌1 lint 에러 2건**(admin/workout/page.tsx, auth/AuthGuard.tsx, set-state-in-effect)은 범위 밖 — 무시. 단 본인이 만든/수정한 파일은 lint 클린이어야 함.
- **DB 변경은 raw SQL** 파일을 `supabase/`에 작성. 적용은 사용자(chacha)가 Supabase SQL 에디터로 수동 실행(런타임 PENDING). 코드는 빈 테이블이어도 동작해야 함.
- **기존 로그인 보존**: localStorage `bp-*` 키 불변.
- **작업트리 주의**: 세션 이전 untracked 파일 다수 → **`git add -A` 금지, 변경 경로만 stage**.
- 커밋 메시지 한국어 + 끝에 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- ddodun 소스 루트: `/Users/chacha/lab/ddodun/app` (포팅 원본). roadtorxd 루트: `/Users/chacha/lab/roadtorxd/app`.

---

## Task 1: PR 테이블 마이그레이션 SQL

**Files:**
- Create: `supabase/migration-pr-tables.sql`

**Interfaces:**
- Produces: public 스키마 테이블 `user_nrm`, `user_pace_records`, `wod_records`. (`user_1rm`은 이미 존재 — 건드리지 않음.) 이후 PR API가 의존.

- [ ] **Step 1: 마이그레이션 SQL 작성**

`supabase/migration-pr-tables.sql`:
```sql
-- ROAD TO FITTER: PR 탭(ddodun 이식)용 테이블 (public 스키마). user_1rm은 기존 재사용.
create table if not exists user_nrm (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  exercise_name text not null,
  rep_max int not null check (rep_max between 2 and 10),
  weight decimal,
  weight_unit text default 'lb',
  updated_at timestamptz default now(),
  unique(user_id, exercise_name, rep_max)
);
create table if not exists user_pace_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  equipment text not null,
  distance text not null,
  time_seconds int,
  updated_at timestamptz default now(),
  unique(user_id, equipment, distance)
);
create table if not exists wod_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  wod_type text not null check (wod_type in ('named','open')),
  wod_name text not null,
  score_type text not null check (score_type in ('time','amrap','reps')),
  time_seconds int,
  rounds int,
  extra_reps int,
  reps int,
  memo text,
  recorded_at date not null default current_date,
  created_at timestamptz not null default now()
);
alter table user_nrm enable row level security;
alter table user_pace_records enable row level security;
alter table wod_records enable row level security;
drop policy if exists "pr_user_nrm_all" on user_nrm;
create policy "pr_user_nrm_all" on user_nrm for all to anon, authenticated using (true) with check (true);
drop policy if exists "pr_user_pace_all" on user_pace_records;
create policy "pr_user_pace_all" on user_pace_records for all to anon, authenticated using (true) with check (true);
drop policy if exists "pr_wod_records_all" on wod_records;
create policy "pr_wod_records_all" on wod_records for all to anon, authenticated using (true) with check (true);
create index if not exists idx_user_nrm_user on user_nrm(user_id);
create index if not exists idx_user_pace_user on user_pace_records(user_id);
create index if not exists idx_wod_records_user on wod_records(user_id);
```

- [ ] **Step 2: Commit**
```bash
git add supabase/migration-pr-tables.sql
git commit -m "feat(db): PR 탭용 user_nrm/user_pace_records/wod_records 테이블 (public)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```
(적용은 사용자가 SQL 에디터로 — 런타임 PENDING. 빌드/코드와 무관.)

---

## Task 2: PR 데이터 레이어 이식 (pr.ts · wod.ts · date-utils)

**Files:**
- Create: `src/lib/api/pr.ts` (ddodun `src/lib/api/pr.ts` 복사)
- Create: `src/lib/api/wod.ts` (ddodun `src/lib/api/wod.ts` 복사)
- Create: `src/lib/date-utils.ts` (ddodun `src/lib/date-utils.ts` 복사)

**Interfaces:**
- Consumes: `@/lib/supabase`(우리 public 클라이언트, 동일 경로). Task 1 테이블.
- Produces: `getAll1RM/upsert1RM/delete1RM`, `getAllNRM/upsertNRM/deleteNRM`, `getAllPaceRecords/upsertPaceRecord/deletePaceRecord` (pr.ts); `getAllWodRecords/getWodRecords/createWodRecord/deleteWodRecord` + WOD 프리셋 상수 (wod.ts); `DAY_LABELS` 등 (date-utils.ts). 타입 `OneRM/NRM/PaceRecord/WodRecord/WodPreset/ScoreType`.

- [ ] **Step 1: 3개 파일 그대로 복사**

ddodun → roadtorxd로 **내용 변경 없이** 복사:
- `/Users/chacha/lab/ddodun/app/src/lib/api/pr.ts` → `src/lib/api/pr.ts`
- `/Users/chacha/lab/ddodun/app/src/lib/api/wod.ts` → `src/lib/api/wod.ts`
- `/Users/chacha/lab/ddodun/app/src/lib/date-utils.ts` → `src/lib/date-utils.ts`

이 파일들은 `import { supabase } from '@/lib/supabase'`를 쓴다. roadtorxd의 `@/lib/supabase`는 public 클라이언트라, 복사만으로 public 테이블을 조회한다. **스키마 관련 코드 수정 불필요.**

- [ ] **Step 2: 빌드·린트**

Run: `npm run build && npx eslint src/lib/api/pr.ts src/lib/api/wod.ts src/lib/date-utils.ts`
Expected: 컴파일 성공, 세 파일 lint 0. (만약 ddodun 코드가 우리에 없는 import를 참조하면 — 예상 밖 — 해당 import만 우리 등가물로 교체하고 보고.)

- [ ] **Step 3: Commit**
```bash
git add src/lib/api/pr.ts src/lib/api/wod.ts src/lib/date-utils.ts
git commit -m "feat(pr): ddodun PR 데이터 레이어 이식 (pr.ts/wod.ts/date-utils)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: PR 컴포넌트 이식 (components/pr/*)

**Files:**
- Create: `src/components/pr/ExerciseIcons.tsx`, `NrmAddModal.tsx`, `PaceAddModal.tsx`, `WodTab.tsx`, `WodRecordModal.tsx`, `WodHistoryModal.tsx`, `OpenWodAddModal.tsx` (각각 ddodun `src/components/pr/*` 복사)

**Interfaces:**
- Consumes: Task 2의 `@/lib/api/pr`, `@/lib/api/wod`, `@/lib/date-utils`; `lucide-react`(Plus/Trash2/X — 설치됨).
- Produces: `getExerciseIcon`/`getEquipmentIcon` (ExerciseIcons), 각 모달 컴포넌트, `WodTab`. Task 4(PR 페이지)가 소비.

- [ ] **Step 1: 7개 컴포넌트 그대로 복사**

`/Users/chacha/lab/ddodun/app/src/components/pr/` 의 7개 파일을 `src/components/pr/`로 **내용 변경 없이** 복사:
`ExerciseIcons.tsx`, `NrmAddModal.tsx`, `PaceAddModal.tsx`, `WodTab.tsx`, `WodRecordModal.tsx`, `WodHistoryModal.tsx`, `OpenWodAddModal.tsx`.

모든 import(`@/lib/api/*`, `@/lib/date-utils`, `lucide-react`, 시맨틱 토큰)가 우리 환경에서 동일 경로로 해소된다.

- [ ] **Step 2: 빌드·린트**

Run: `npm run build && npx eslint src/components/pr/`
Expected: 컴파일 성공, lint 0. (예상 밖 미해소 import만 우리 등가물로 교체.)

- [ ] **Step 3: Commit**
```bash
git add src/components/pr/
git commit -m "feat(pr): ddodun PR 컴포넌트 7종 이식 (아이콘·모달·WodTab)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: PR 페이지 이식 (app/pr/page.tsx)

**Files:**
- Create: `src/app/pr/page.tsx` (ddodun `src/app/pr/page.tsx` 복사)

**Interfaces:**
- Consumes: Task 2/3의 PR API·컴포넌트; `@/lib/auth`의 `getLoggedInUser`(우리 것, `.id` 반환 호환).

- [ ] **Step 1: 페이지 그대로 복사**

`/Users/chacha/lab/ddodun/app/src/app/pr/page.tsx` → `src/app/pr/page.tsx` (내용 변경 없이).
- `getLoggedInUser` import는 `@/lib/auth`로 동일 → 우리 auth가 자동 적용(우리 user.id 사용 → 우리 데이터).
- 1RM API(`getAll1RM` 등)는 `public.user_1rm`(컬럼 일치)을 조회 → **기존 roadtorxd 1RM 데이터 그대로 노출**.

- [ ] **Step 2: 빌드·린트**

Run: `npm run build && npx eslint src/app/pr/page.tsx`
Expected: 컴파일 성공, lint 0.

- [ ] **Step 3: 수동 확인**

`npm run dev` → 로그인 후 `/pr` 직접 접근(네비는 Task 7): PR/WOD 서브탭, 1RM 12개 그리드(기존 입력값 표시), nRM/PACE 추가·삭제, WOD 기록/히스토리 동작. 색이 우리 **파란색**인지, ClientLayout 패딩과 페이지 자체 패딩이 **이중 적용**되지 않는지 확인(이중이면 페이지 루트의 px/py 패딩 제거).

- [ ] **Step 4: Commit**
```bash
git add src/app/pr/page.tsx
git commit -m "feat(pr): PR 탭 페이지 이식 (1RM/nRM/PACE/WOD) — 기존 1RM 데이터 재사용

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: MY 탭 (기존 daily 변형)

**Files:**
- Create: `src/app/my/page.tsx`

**Interfaces:**
- Consumes: `getDailyLog`/`upsertDailyLog` (daily-logs.ts), `WeightChart`(`@/components/summary/WeightChart`), `getLoggedInUser`/`logout`(`@/lib/auth`), `useRouter`, `supabase`, `toDateString`.

- [ ] **Step 1: my/page.tsx 작성 (daily 콘텐츠에서 1RM 제거 버전)**

현재 `src/app/daily/page.tsx`의 내용을 `src/app/my/page.tsx`로 옮기되 **1RM(OneRMSection) 관련 import·렌더 전부 제외**. 최종 구성(위→아래): 날짜 픽커 + 체중 입력 + 체중 그래프(`<WeightChart data={weightData} mode="all" />`) + 로그아웃 버튼. 자동저장은 기존 부분 업데이트(`{ ...existing, weight_kg: updated.weight_kg }`, 보관 컬럼 보존) 그대로. (현재 daily엔 메모·1RM이 이미 없거나 상단; OneRMSection import가 있으면 제거.)

`src/app/daily/page.tsx`를 그대로 복사한 뒤, `OneRMSection` import 라인과 그 `<OneRMSection .../>` 렌더만 삭제하면 됨(나머지 동일).

- [ ] **Step 2: 빌드·린트**

Run: `npm run build && npx eslint src/app/my/page.tsx`
Expected: 컴파일 성공, lint 0(미사용 import 없게).

- [ ] **Step 3: 수동 확인**

dev `/my`: 체중 입력·저장·재로드, 체중 그래프, 로그아웃 동작. 1RM 없음.

- [ ] **Step 4: Commit**
```bash
git add src/app/my/page.tsx
git commit -m "feat(my): MY 탭 — 체중 입력·그래프·로그아웃 (기존 daily서 1RM 제거)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: 홈 캘린더 2색 점 + getWorkoutDatesInRange

**Files:**
- Modify: `src/lib/api/workout-logs.ts`
- Modify: `src/components/home/WorkoutCalendar.tsx`
- Modify: `src/app/page.tsx` (캘린더 props만; 통계 카드는 유지)

**Interfaces:**
- Consumes: 기존 `getCompletedDatesInRange`.
- Produces: `getWorkoutDatesInRange(userId, start, end): Promise<string[]>` (로그 존재 날짜, 완료 무관).

- [ ] **Step 1: workout-logs.ts에 헬퍼 추가**

`src/lib/api/workout-logs.ts` 끝에:
```typescript
// 캘린더용: 기간 내 운동 로그가 '있는' 모든 날짜(완료 무관, 중복 제거).
export async function getWorkoutDatesInRange(
  userId: string,
  startDate: string,
  endDate: string,
): Promise<string[]> {
  const { data, error } = await supabase
    .from('workout_logs')
    .select('date')
    .eq('user_id', userId)
    .gte('date', startDate)
    .lte('date', endDate)
  if (error) throw error
  const dates = (data ?? []).map((r: { date: string }) => r.date)
  return [...new Set(dates)]
}
```

- [ ] **Step 2: WorkoutCalendar.tsx — 셀 가득 동그라미 → 2색 점**

`src/components/home/WorkoutCalendar.tsx`에서:
- state를 두 집합으로: `const [completed, setCompleted] = useState<Set<string>>(new Set())` 유지 + `const [worked, setWorked] = useState<Set<string>>(new Set())` 추가.
- useEffect에서 그리드 범위(gs~ge)로 `getCompletedDatesInRange`와 `getWorkoutDatesInRange`를 함께 조회(Promise.all)해 두 Set 세팅(에러 시 둘 다 빈 Set).
- 셀 렌더 교체 — 숫자 + 그 아래 점:
```tsx
const ds = toDateString(d)
const inMonth = d.getMonth() === month
const isToday = ds === todayDs
const isCompleted = completed.has(ds)
const hasWorkout = worked.has(ds)
const dotClass = isCompleted ? 'bg-accent' : hasWorkout ? 'bg-text-secondary/40' : 'bg-transparent'
const numClass = isToday
  ? 'bg-accent text-white'
  : inMonth ? 'text-foreground' : 'text-text-secondary/30'
return (
  <button
    key={ds}
    onClick={() => router.push(`/workout?date=${ds}`)}
    className="flex flex-col items-center justify-start gap-0.5 h-11 pt-1"
  >
    <span className={`flex items-center justify-center w-7 h-7 rounded-full text-sm ${numClass}`}>
      {d.getDate()}
    </span>
    <span className={`w-1.5 h-1.5 rounded-full ${dotClass}`} />
  </button>
)
```
(기존 `circleClass`/`w-8 h-8` 채운 원 방식 제거.)

- [ ] **Step 3: page.tsx 확인**

`src/app/page.tsx`는 `<WorkoutCalendar />`를 그대로 렌더(props 없음). 통계 카드(이번 달/이번 주) 변경 없음. 수정 없을 수 있음 — 빌드만 확인.

- [ ] **Step 4: 빌드·린트·수동 확인**

Run: `npm run build && npx eslint src/lib/api/workout-logs.ts src/components/home/WorkoutCalendar.tsx src/app/page.tsx`
dev `/`: 완료된 날 **파란 점**, 운동만 있고 미완료인 날 **회색 점**, 오늘 파란 채움. 날짜 탭 → 운동 페이지 이동.

- [ ] **Step 5: Commit**
```bash
git add src/lib/api/workout-logs.ts src/components/home/WorkoutCalendar.tsx src/app/page.tsx
git commit -m "feat(home): 캘린더 2색 점(회색=운동/파란=완료) + getWorkoutDatesInRange

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: 하단 네비 5탭(lucide) + 챌린지 플레이스홀더

**Files:**
- Modify: `src/components/BottomNav.tsx`
- Create: `src/app/challenge/page.tsx`

**Interfaces:**
- Consumes: 라우트 `/`, `/workout`, `/challenge`, `/pr`(Task 4), `/my`(Task 5).

- [ ] **Step 1: 챌린지 플레이스홀더 페이지**

`src/app/challenge/page.tsx`:
```tsx
export default function ChallengePage() {
  return (
    <div className="flex flex-col items-center justify-center py-24 text-center">
      <p className="text-base font-semibold text-foreground mb-2">챌린지 준비 중이에요</p>
      <p className="text-sm text-text-secondary">풀업·푸쉬업 등 데일리 챌린지가 곧 추가됩니다.</p>
    </div>
  )
}
```

- [ ] **Step 2: BottomNav 5탭 + lucide 아이콘**

`src/components/BottomNav.tsx`를 5탭으로 교체. 기존 커스텀 SVG 아이콘 함수들 제거, lucide 사용:
```tsx
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Calendar, Dumbbell, Flame, Trophy, User } from 'lucide-react'

const tabs = [
  { href: '/', label: '홈', Icon: Calendar },
  { href: '/workout', label: '운동', Icon: Dumbbell },
  { href: '/challenge', label: '챌린지', Icon: Flame },
  { href: '/pr', label: 'PR', Icon: Trophy },
  { href: '/my', label: 'MY', Icon: User },
]

export default function BottomNav() {
  const pathname = usePathname()
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-surface border-t border-border">
      <div className="flex items-center justify-around max-w-lg mx-auto h-16">
        {tabs.map((tab) => {
          const isActive = pathname === tab.href
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center gap-1 px-3 py-2 text-xs transition-colors ${
                isActive ? 'text-accent-pop' : 'text-text-secondary'
              }`}
            >
              <tab.Icon size={22} strokeWidth={isActive ? 2.5 : 2} />
              <span className="font-medium">{tab.label}</span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
```
(`text-accent-pop`이 globals.css에 없으면 `text-accent`로.)

- [ ] **Step 3: 빌드·린트·수동 확인**

Run: `npm run build && npx eslint src/components/BottomNav.tsx src/app/challenge/page.tsx`
dev: 하단 5탭(홈/운동/챌린지/PR/MY) 균등 배치·아이콘 표시, 각 탭 이동, 챌린지=준비중 안내.

- [ ] **Step 4: Commit**
```bash
git add src/components/BottomNav.tsx src/app/challenge/page.tsx
git commit -m "feat(nav): 하단 5탭(홈/운동/챌린지/PR/MY) lucide 아이콘 + 챌린지 플레이스홀더

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: 시즌 잔여 정리 (daily·OneRMSection·user-1rm 삭제)

**Files:**
- Delete: `src/app/daily/page.tsx`, `src/components/summary/OneRMSection.tsx`, `src/components/summary/ExerciseIcons.tsx`, `src/lib/api/user-1rm.ts`

**Interfaces:**
- 선행: Task 4(PR)·5(MY)·7(네비)가 이 파일들의 소비처를 모두 대체한 상태여야 함.

- [ ] **Step 1: 소비처 0 확인 후 삭제**

먼저 잔여 참조 확인:
```bash
grep -rnE "OneRMSection|api/user-1rm|summary/ExerciseIcons|'/daily'|\"/daily\"|app/daily" src/
```
참조가 남아있으면 해당 파일에서 제거(예: 네비/링크의 `/daily`). 그 후:
```bash
git rm src/app/daily/page.tsx src/components/summary/OneRMSection.tsx src/components/summary/ExerciseIcons.tsx src/lib/api/user-1rm.ts
```
(`src/components/summary/WeightChart.tsx`는 **삭제 금지** — MY가 사용.)

- [ ] **Step 2: 빌드로 잔여 import 검출·정리**

Run: `npm run build`
Expected: 삭제 파일을 아직 import하는 곳이 있으면 에러 → 제거 후 재빌드. 에러 0까지. 그다음 `npm run lint`(신규 에러 0).

- [ ] **Step 3: 수동 전체 점검**

`npm run dev`로 5탭 전부 로드, 콘솔 에러 없음. `/daily` 직접 접근 시 404(정상). 핵심 플로우(홈 캘린더/운동 담기/PR 1RM·WOD/MY 체중) 동작.

- [ ] **Step 4: Commit**
```bash
git add -A -- src/app/daily src/components/summary/OneRMSection.tsx src/components/summary/ExerciseIcons.tsx src/lib/api/user-1rm.ts
git commit -m "chore: daily 페이지·기존 OneRMSection·user-1rm 제거 (PR/MY로 대체)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```
(주의: `git add -A`는 경로 한정 형태로만. 무관 untracked 파일 stage 금지.)

---

## Self-Review 메모
- **Spec 커버리지**: §1 네비→T7 / §2 캘린더·통계→T6(통계 유지) / §3 PR→T2·T3·T4 / §4 MY→T5 / §5 챌린지 플레이스홀더→T7 / §6 DB→T1 / §8 삭제→T8. 누락 없음.
- **순서 의존성**: T1(DB)·T2(API)→T3(컴포넌트)→T4(PR페이지). T5(MY)·T7(네비)는 독립. T8(삭제)은 T4·T5·T7 이후 마지막.
- **포팅 적응 최소**: `@/lib/supabase`(public)·`@/lib/auth`(getLoggedInUser)·`@/lib/date-utils`(T2서 복사)가 동일 경로로 해소 → 대부분 무수정 복사. 빌드 에러 시에만 해당 import 우리 등가물로 교체.
- **1RM 데이터**: `public.user_1rm` 컬럼이 ddodun과 일치 → 기존 데이터 보존. T8에서 구 user-1rm.ts/OneRMSection 제거(중복 해소).
- **검증**: 테스트 하네스 없음 → 전 태스크 build+lint+manual.
- **런타임 PENDING**: T1 SQL 적용은 사용자 수동. 미적용 시 nRM/PACE/WOD는 빈 목록(에러 아님), 1RM은 기존 동작.
