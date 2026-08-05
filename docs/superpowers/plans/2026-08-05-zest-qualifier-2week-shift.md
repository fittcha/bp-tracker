# 제서 예선 반영 — 8주 프로그램 2주 시프트 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 제서(ZEST SURVIVOR) 예선 기간(7/27~8/5)의 추가운동을 `ZEST SURVIVOR 예선` 카드 한 장으로 대체하고, 남은 4~8주차를 8/10부터 2주 뒤로 밀되 주차 표기가 콘텐츠와 함께 이동하게 한다.

**Architecture:** 데이터는 라이브 SQL 1회성 마이그레이션(사용자가 Supabase SQL 에디터에서 수동 실행)으로 옮기고, 같은 커밋에서 시드·데이터 문서를 새 일정에 맞춰 재작성해 단일 진실을 유지한다. 코드는 두 곳만 바뀐다 — 과거 날짜 자동담기 가드 제거, 헤더 주차 계산을 날짜 산술에서 라벨 파싱으로 전환(순수 함수로 분리해 단위 테스트).

**Tech Stack:** Next.js 16 (App Router) · React 19 · TypeScript · Supabase(Postgres, anon 키 · RLS 전체 허용) · SWR · vitest

**설계 문서:** `docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md`

## Global Constraints

- 시프트 기준일 **2026-07-27**, 시프트량 **+14일**. 7/24 이전(1~3주차)은 손대지 않는다.
- 예선 카드 날짜는 평일 8일: `2026-07-27, 07-28, 07-29, 07-30, 07-31, 08-03, 08-04, 08-05`. 주말(8/1~8/2) 제외.
- 예선 카드 문구는 정확히 이 문자열 — `workouts.title` = `ZEST SURVIVOR 예선`, `workout_exercises.exercise_name` = `제서 이벤트 측정`. `workouts.category` = `측정`, `workouts.program_label` = **null**(헤더 프로그램 배너에서 제외됨), `sets`/`reps`/`notes`/`section` = null.
- 8/6(목)·8/7(금) 스페셜 세션은 **이 계획의 범위 밖**. 플레이스홀더 카드도 넣지 않는다(나중에 동작 행을 교체하면 사용자 로그 FK가 `set null`로 끊겨 레거시 카드로 렌더됨).
- **라이브 SQL은 구현자가 실행하지 않는다.** 이 프로젝트의 DB 변경은 사용자가 Supabase SQL 에디터에서 직접 돌린다. 구현자는 SQL 파일을 작성·커밋하고 Task 6에서 실행을 요청한다.
- 앱/문서/커밋 메시지는 한국어. 커밋 메시지 형식은 기존 이력대로 `type(scope): 한국어 요약`, 본문 끝에 `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.
- 임시 스크립트는 스크래치패드(`/private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad`)에 쓰고 리포에 커밋하지 않는다.

---

## File Structure

| 파일 | 역할 | 상태 |
|---|---|---|
| `src/lib/workout/program-week.ts` | 프로그램 행 목록 + 오늘 날짜 → 진행 상태(`CurrentProgram`) 파생. 순수 함수, DB 의존 없음 | 신규 |
| `src/lib/workout/program-week.test.ts` | 위 함수의 단위 테스트 | 신규 |
| `src/lib/api/workouts.ts` | `getCurrentProgram`이 조회만 하고 파생은 위임 | 수정 |
| `src/components/Header.tsx` | `currentWeek`이 null일 때 "null주차" 방지 | 수정 |
| `src/app/workout/page.tsx` | 자동담기 `isPast` 가드 제거 | 수정 |
| `supabase/migration-strength-shift-2w.sql` | 라이브 1회성: 껍데기 로그 정리 → 2주 시프트 → 예선 카드 삽입 | 신규 |
| `supabase/seed-strength-8week.sql` | 처음부터 새 일정이 나오게 날짜 재작성 + 예선 카드 블록 | 수정 |
| `docs/data/season2-strength-8week-data.md` | 사람이 읽는 원본 문서의 날짜/주차 표기 동기화 | 수정 |

---

## Task 1: 헤더 주차를 라벨 기준으로 (순수 함수 + 테스트)

**Files:**
- Create: `src/lib/workout/program-week.ts`
- Test: `src/lib/workout/program-week.test.ts`
- Modify: `src/lib/api/workouts.ts:71-113` (`CurrentProgram` 인터페이스 + `getCurrentProgram` 본문)
- Modify: `src/components/Header.tsx:29-34` (`progLabel` 조립)

**Interfaces:**
- Produces:
  - `export interface ProgramRow { program_date: string; program_label: string }`
  - `export interface CurrentProgram { name: string; startDate: string; totalWeeks: number | null; currentWeek: number | null; status: 'upcoming' | 'active' | 'done' }`
  - `export function deriveProgram(rows: ProgramRow[], today: string): CurrentProgram | null`
- Consumes: 없음(첫 태스크)

**왜:** 현재 `getCurrentProgram`은 `floor((today - startDate)/7)+1`로 주차를 센다. 2주 시프트로 날짜와 라벨 사이에 갭이 생기면 8/10에 라벨은 "4주차"인데 헤더는 "6주차"로 뜬다. 라벨이 진실이므로 라벨에서 읽는다.

- [ ] **Step 1: 실패하는 테스트 작성**

`src/lib/workout/program-week.test.ts`:

```ts
import { describe, it, expect } from 'vitest'
import { deriveProgram, type ProgramRow } from './program-week'

// 제서 예선으로 7/27~8/7이 비고 4주차가 8/10부터 재개되는 실제 일정(주차별 대표 날짜만 추림)
const SCHEDULE: ProgramRow[] = [
  { program_date: '2026-07-06', program_label: 'Strength 8주 · 1주차' },
  { program_date: '2026-07-13', program_label: 'Strength 8주 · 2주차' },
  { program_date: '2026-07-20', program_label: 'Strength 8주 · 3주차' },
  { program_date: '2026-07-24', program_label: 'Strength 8주 · 3주차' },
  { program_date: '2026-08-10', program_label: 'Strength 8주 · 4주차' },
  { program_date: '2026-08-17', program_label: 'Strength 8주 · 5주차' },
  { program_date: '2026-09-11', program_label: 'Strength 8주 · 8주차' },
]

describe('deriveProgram', () => {
  it('갭 기간에는 마지막 진행 세션의 라벨 주차를 유지(날짜 산술이면 5주차로 틀림)', () => {
    expect(deriveProgram(SCHEDULE, '2026-08-05')).toEqual({
      name: 'Strength 8주',
      startDate: '2026-07-06',
      totalWeeks: 8,
      currentWeek: 3,
      status: 'active',
    })
  })

  it('재개일부터 라벨대로 4주차', () => {
    expect(deriveProgram(SCHEDULE, '2026-08-10')?.currentWeek).toBe(4)
  })

  it('시작 전이면 upcoming · 주차 null', () => {
    expect(deriveProgram(SCHEDULE, '2026-07-01')).toMatchObject({ status: 'upcoming', currentWeek: null })
  })

  it('마지막 세션 이후면 done · 주차는 총 주차', () => {
    expect(deriveProgram(SCHEDULE, '2026-09-12')).toMatchObject({ status: 'done', currentWeek: 8 })
  })

  it('라벨이 다른 특별 세션은 종료일 계산에서 제외', () => {
    const rows: ProgramRow[] = [...SCHEDULE, { program_date: '2026-09-30', program_label: 'ZEST 이벤트 · 특별' }]
    expect(deriveProgram(rows, '2026-09-12')).toMatchObject({ status: 'done', name: 'Strength 8주' })
  })

  it('라벨에서 주차를 못 읽으면 currentWeek null', () => {
    const rows: ProgramRow[] = [{ program_date: '2026-07-06', program_label: 'Strength 8주 · 디로드' }]
    expect(deriveProgram(rows, '2026-07-06')).toMatchObject({ currentWeek: null, status: 'active' })
  })

  it('정렬되지 않은 입력도 날짜순으로 판정', () => {
    expect(deriveProgram([...SCHEDULE].reverse(), '2026-08-05')?.currentWeek).toBe(3)
  })

  it('행이 없으면 null', () => {
    expect(deriveProgram([], '2026-08-05')).toBeNull()
  })
})
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

Run: `npx vitest run src/lib/workout/program-week.test.ts`
Expected: FAIL — `Failed to resolve import "./program-week"`

- [ ] **Step 3: 최소 구현**

`src/lib/workout/program-week.ts`:

```ts
// 공용 날짜기반 프로그램의 진행 상태 파생 — 순수 함수(DB 의존 없음).
// 주차는 날짜 산술이 아니라 '라벨'에서 읽는다: 제서 예선처럼 일정이 밀려 날짜와 주차 사이에
// 갭이 생기면 날짜 산술은 어긋나고 라벨이 진실이기 때문.
// 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md

export interface ProgramRow {
  program_date: string   // 'YYYY-MM-DD'
  program_label: string  // 예: 'Strength 8주 · 3주차'
}

export interface CurrentProgram {
  name: string                 // 'Strength 8주' (라벨의 ' · ' 앞부분)
  startDate: string            // 첫 세션 날짜 'YYYY-MM-DD'
  totalWeeks: number | null
  currentWeek: number | null   // null = 시작 전이거나 라벨에서 주차를 못 읽음
  status: 'upcoming' | 'active' | 'done'
}

export function deriveProgram(rows: ProgramRow[], today: string): CurrentProgram | null {
  // 호출부가 정렬해 주지만 방어적으로 한 번 더(테스트/향후 호출부 대비)
  const sorted = [...rows].sort((a, b) => a.program_date.localeCompare(b.program_date))
  if (sorted.length === 0) return null

  const name = sorted[0].program_label.split(' · ')[0]
  // 같은 프로그램 행만 범위 계산에 쓴다 — 라벨이 다른 특별 세션이 시작/종료일을 흔들지 않게.
  const prog = sorted.filter((r) => r.program_label.startsWith(name))
  const startDate = prog[0].program_date
  const endDate = prog[prog.length - 1].program_date
  const totMatch = name.match(/(\d+)\s*주/)
  const totalWeeks = totMatch ? Number(totMatch[1]) : null

  if (today < startDate) return { name, startDate, totalWeeks, currentWeek: null, status: 'upcoming' }
  if (today > endDate) return { name, startDate, totalWeeks, currentWeek: totalWeeks, status: 'done' }

  // 진행 중: 오늘 이하 마지막 세션의 라벨에서 'N주차'를 읽는다.
  const last = [...prog].reverse().find((r) => r.program_date <= today)
  const wkMatch = last?.program_label.match(/(\d+)\s*주차/)
  return { name, startDate, totalWeeks, currentWeek: wkMatch ? Number(wkMatch[1]) : null, status: 'active' }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `npx vitest run src/lib/workout/program-week.test.ts`
Expected: PASS (8 tests)

- [ ] **Step 5: `getCurrentProgram`을 위임으로 교체**

`src/lib/api/workouts.ts` — 파일 맨 위 import에 추가:

```ts
import { deriveProgram, type CurrentProgram, type ProgramRow } from '@/lib/workout/program-week'
```

`71-113`행의 `export interface CurrentProgram { ... }` 블록과 `getCurrentProgram` 본문을 아래로 전부 교체(인터페이스는 `program-week.ts`로 옮겨졌으므로 여기서는 재수출만 한다):

```ts
export type { CurrentProgram }

// 홈 배너용: 활성 공용 프로그램의 진행 상태. 주차 판정은 program-week.deriveProgram(라벨 기준).
export async function getCurrentProgram(today: string): Promise<CurrentProgram | null> {
  const { data, error } = await supabase
    .from('workouts')
    .select('program_date, program_label')
    .is('owner_user_id', null)
    .not('program_date', 'is', null)
    .not('program_label', 'is', null)
    .eq('archived', false)
    .order('program_date', { ascending: true })
  if (error) throw error
  return deriveProgram((data ?? []) as ProgramRow[], today)
}
```

- [ ] **Step 6: `Header.tsx`의 주차 null 대응**

`src/components/Header.tsx:29-34`의 `progLabel` 조립을 교체:

```tsx
  let progLabel = ''
  if (program) {
    const [, sm, sd] = program.startDate.split('-').map(Number)
    const right =
      program.status === 'upcoming'
        ? `${sm}월 ${sd}일 시작`
        : program.status === 'done'
          ? '완료'
          : program.currentWeek != null
            ? `${program.currentWeek}주차`
            : '진행 중'
    progLabel = `${program.name} · ${right}`
  }
```

- [ ] **Step 7: 타입·린트·전체 테스트 확인**

Run: `npx tsc --noEmit && npm run lint && npm test`
Expected: 에러 0, 모든 테스트 PASS

- [ ] **Step 8: 커밋**

```bash
git add src/lib/workout/program-week.ts src/lib/workout/program-week.test.ts src/lib/api/workouts.ts src/components/Header.tsx
git commit -m "$(cat <<'EOF'
fix(program): 헤더 주차를 날짜 산술 → 라벨 기준으로

일정이 밀려 날짜와 주차 사이에 갭이 생기면 날짜 산술이 어긋난다.
deriveProgram 순수 함수로 분리해 단위 테스트.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: 과거 날짜 자동담기 허용

**Files:**
- Modify: `src/app/workout/page.tsx:186-190`

**Interfaces:**
- Consumes: 없음 (Task 1과 독립)
- Produces: 없음

**왜:** 날짜기반 프로그램은 오늘/미래에만 자동으로 담긴다. 그래서 (a) 과거인 7/27~8/4에 예선 카드를 새로 깔아도 화면에 안 뜨고, (b) 8/6~8/7 스페셜 세션을 뒤늦게 삽입하면 그날이 지난 뒤엔 담기지 않고, (c) 그날 앱을 못 연 사람은 과거 세션을 뒤늦게 기록할 방법이 없다. 선행 설계에서 이 제약은 안전장치가 아니라 YAGNI 범위 축소였다(`docs/superpowers/specs/2026-06-28-public-workout-date-program-design.md:27`).

**테스트를 새로 만들지 않는 이유:** 조건 하나를 삭제하는 변경이고 남는 로직은 이미 자명한 `!present.has(w.id)` 필터뿐이다. React effect 안이라 단위 테스트로 감싸려면 프로덕션 코드를 테스트 편의로 재구성해야 해서 이득이 없다. 검증은 tsc/lint(미사용 변수 검출) + Task 6의 실제 앱 확인으로 한다.

- [ ] **Step 1: 가드 제거**

`src/app/workout/page.tsx` — 아래 3줄을 찾아서(186~190행 사이)

```tsx
    const present = new Set(logs.map((l) => l.workout?.workout_id).filter(Boolean))
    const isPast = ds < toDateString(new Date())
    const weekdayIds = new Set(defaults.weekday.map((w) => w.id))
    const all = [...defaults.weekday, ...defaults.date]
    const missing = all.filter((w) => !present.has(w.id) && (!isPast || weekdayIds.has(w.id)))
```

이렇게 바꾼다:

```tsx
    const present = new Set(logs.map((l) => l.workout?.workout_id).filter(Boolean))
    const all = [...defaults.weekday, ...defaults.date]
    // 과거 날짜도 담는다: 예선 카드/스페셜 세션을 뒤늦게 삽입해도 담기고, 놓친 과거 세션을
    // 뒤늦게 기록할 수 있다. 캘린더 표시는 평일이면 이미 무조건 회색 점이라 영향 없음.
    const missing = all.filter((w) => !present.has(w.id))
```

- [ ] **Step 2: 자동담기 주석의 오래된 설명 수정**

같은 파일 `172-173`행 부근 주석에서 "WOD(요일 공용)는 과거 포함 항상, 프로그램 등 날짜 공용은 오늘/미래만." 문장을 "요일 공용·날짜 공용 모두 과거 포함 항상 담는다." 로 바꾼다.

- [ ] **Step 3: 미사용 변수·타입 확인**

Run: `npx tsc --noEmit && npm run lint`
Expected: 에러 0. (`toDateString`은 같은 파일 `todayDs`에서 계속 쓰이므로 import는 그대로 둔다. `weekdayIds`가 남아 있으면 lint가 미사용으로 잡는다 — 잡히면 삭제 누락이니 지운다)

- [ ] **Step 4: 커밋**

```bash
git add src/app/workout/page.tsx
git commit -m "$(cat <<'EOF'
feat(workout): 과거 날짜도 날짜기반 프로그램 자동담기

예선 카드/스페셜 세션을 뒤늦게 삽입해도 담기고, 놓친 과거 세션을
뒤늦게 기록할 수 있다. 캘린더 표시는 평일 회색 점이 이미 무조건이라 불변.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: 라이브 1회성 마이그레이션 SQL 작성

**Files:**
- Create: `supabase/migration-strength-shift-2w.sql`

**Interfaces:**
- Consumes: 없음
- Produces: Task 6에서 사용자가 실행할 SQL 파일

**주의:** 이 파일을 실행하는 것은 Task 6이고 실행자는 사용자다. 여기서는 작성만 한다. 세 단계는 **순서가 중요**하고 **멱등하지 않다**.

- [ ] **Step 1: 파일 작성**

`supabase/migration-strength-shift-2w.sql`:

```sql
-- 제서(ZEST SURVIVOR) 예선 반영 — Strength 8주 프로그램 2주 시프트 (1회성).
-- 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md
--
-- 예선이 7/27(월)~8/5(수)로 진행돼 그 기간 추가운동을 아무도 하지 못했다.
-- 7/27~8/5 = 'ZEST SURVIVOR 예선' 카드 1장, 8/6~8/7 = 스페셜(내용 후속 확정, 여기선 비움),
-- 4~8주차 = 8/10부터 재개(+14일). 라벨은 콘텐츠에 붙어 함께 이동하므로 재작성하지 않는다.
--
-- !!! 멱등하지 않다 — 절대 두 번 실행하지 말 것 !!!
--   2)를 두 번 돌리면 4주가 밀리고, 1)은 시프트 후 정상 로그를 지우고, 3)은 카드를 중복 생성한다.
-- 시드(seed-strength-8week.sql)를 처음부터 새로 돌리는 경우엔 이 파일이 필요 없다(시드에 이미 반영됨).
-- anon 키로 Supabase SQL editor 실행.

-- ===== 0) 사전 점검: 이미 적용됐는지 확인. 0이어야 미적용 =====
select count(*) as already_applied
from workouts
where owner_user_id is null
  and program_label = 'Strength 8주 · 8주차'
  and program_date > '2026-09-01';

-- ===== 1) 껍데기 로그 정리 (기대: 236행) =====
-- 시프트로 전부 stale이 되는 7/27 이후 프로그램 로그. 전량 미완료임을 사전 확인했고,
-- completed = false 조건으로 실제 기록은 절대 지우지 않는다.
-- 이걸 먼저 하지 않으면: 8/24 로그가 9/7로 옮겨간 8주차 카드를 가리킨 채 8/24에 그대로
-- 렌더돼, 새로 담기는 6주차와 겹쳐 보인다.
delete from workout_logs wl
using workout_exercises we, workouts w
where wl.workout_exercise_id = we.id
  and we.workout_id = w.id
  and w.owner_user_id is null
  and w.program_label like 'Strength 8주%'
  and wl.date >= '2026-07-27'
  and wl.completed = false;

-- ===== 2) 4~8주차 2주 시프트 (기대: 143행) =====
update workouts
set program_date = program_date + 14
where owner_user_id is null
  and program_label like 'Strength 8주%'
  and program_date >= '2026-07-27';

-- ===== 3) 예선 카드 8일치 삽입 (평일 8일 · 날짜당 카드 1장 · 동작 1행) =====
-- program_label = null → getCurrentProgram이 라벨 있는 행만 프로그램 범위로 보므로
-- 헤더 배너의 시작/종료/주차 계산에 영향 없음.
with d(program_date) as (values
  ('2026-07-27'::date), ('2026-07-28'), ('2026-07-29'), ('2026-07-30'),
  ('2026-07-31'), ('2026-08-03'), ('2026-08-04'), ('2026-08-05')
), w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  select 'ZEST SURVIVOR 예선', null, null, '측정', d.program_date, null, 0 from d
  returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;

-- ===== 4) 사후 검증 =====
-- (a) stale 로그 0건이어야 한다
select count(*) as stale_logs
from workout_logs wl
join workout_exercises we on we.id = wl.workout_exercise_id
join workouts w on w.id = we.workout_id
where w.program_label like 'Strength 8주%' and wl.date >= '2026-07-27';

-- (b) 날짜별 카드 수/라벨. 7/27~8/5=예선(label null), 8/6~8/7=없음,
--     8/10~8/14=4주차 … 9/7~9/11=8주차
select program_date, coalesce(program_label, title) as label, count(*) as cards
from workouts
where owner_user_id is null and program_date >= '2026-07-20'
group by 1, 2
order by 1;
```

- [ ] **Step 2: 파일 안의 상수 자기 점검**

다음을 눈으로 확인한다(틀리면 라이브 데이터가 어긋난다):
- 삽입 날짜 8개가 `07-27, 07-28, 07-29, 07-30, 07-31, 08-03, 08-04, 08-05`이고 주말이 없다.
- 시프트/삭제 기준일이 둘 다 `'2026-07-27'`이다.
- 문자열이 `ZEST SURVIVOR 예선` / `제서 이벤트 측정`과 정확히 일치한다.

- [ ] **Step 3: 커밋**

```bash
git add supabase/migration-strength-shift-2w.sql
git commit -m "$(cat <<'EOF'
feat(strength): 2주 시프트 라이브 마이그레이션 SQL (1회성)

껍데기 로그 236건 정리 → 4~8주차 program_date +14일 → 예선 카드 8일치 삽입.
사전/사후 점검 쿼리 포함. 멱등하지 않아 재실행 금지.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: 시드 파일을 새 일정으로 재작성

**Files:**
- Modify: `supabase/seed-strength-8week.sql` (228개 카드 중 143개의 날짜 리터럴 + wipe 범위 종료일 + 예선 블록 추가)

**Interfaces:**
- Consumes: Task 3의 예선 카드 컬럼 구성(동일한 문구·컬럼을 시드에도 넣는다)
- Produces: 처음부터 돌려도 새 일정이 나오는 시드

**배경 수치(현재 시드):** 프로그램 카드 총 228개. 날짜 리터럴은 전부 `'Strength 8주 · ` 라벨이 같이 있는 `values (...)` 줄에 있고, **예외는 wipe 블록의 두 줄**(`19`, `26`행 `date between '2026-06-29' and '2026-08-28'`)이다. 그래서 치환은 라벨 줄에만 적용하고 wipe 종료일은 따로 바꾼다.

- [ ] **Step 1: 변경 전 날짜 분포 기록**

```bash
cd /Users/chacha/lab/roadtorxd/app
grep -o "'2026-[0-9][0-9]-[0-9][0-9]'" supabase/seed-strength-8week.sql | sort | uniq -c > /private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad/seed-dates-before.txt
grep -c "insert into workouts" supabase/seed-strength-8week.sql   # 228이어야 한다
```

- [ ] **Step 2: 날짜 시프트 스크립트 작성·실행**

`/private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad/shift-seed.py`:

```python
import re, datetime, pathlib

p = pathlib.Path('supabase/seed-strength-8week.sql')
CUT = datetime.date(2026, 7, 27)
src = p.read_text()

def bump(m):
    d = datetime.date.fromisoformat(m.group(1))
    return f"'{d + datetime.timedelta(days=14)}'" if d >= CUT else m.group(0)

out, shifted = [], 0
for line in src.split('\n'):
    # 날짜 리터럴은 program_label이 함께 있는 values 줄에만 있다. wipe 블록의
    # 'date between ...' 줄은 라벨이 없어 여기서 건드려지지 않는다.
    if "'Strength 8주 · " in line:
        new = re.sub(r"'(2026-\d{2}-\d{2})'", bump, line)
        if new != line:
            shifted += 1
        line = new
    out.append(line)

s = '\n'.join(out)
# wipe 범위 종료일: 프로그램 마지막 날이 8/28 → 9/11로 늘어남
before = s.count("and '2026-08-28'")
s = s.replace("and '2026-08-28'", "and '2026-09-11'")
p.write_text(s)
print('shifted card lines:', shifted, '(기대 143)')
print('wipe range lines updated:', before, '(기대 2)')
```

Run:
```bash
cd /Users/chacha/lab/roadtorxd/app && python3 /private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad/shift-seed.py
```
Expected: `shifted card lines: 143 (기대 143)` / `wipe range lines updated: 2 (기대 2)`

- [ ] **Step 3: 날짜 분포 검증**

```bash
cd /Users/chacha/lab/roadtorxd/app
grep -o "'2026-[0-9][0-9]-[0-9][0-9]'" supabase/seed-strength-8week.sql | sort | uniq -c
```
Expected:
- `'2026-06-29'` 2개(wipe 시작일, 불변), `'2026-09-11'` 2개(wipe 종료일) + 6개(8주차 금요일 카드) = 8개
- 7/6~7/24 각 날짜 개수 불변(28+29+28 = 85개)
- 7/27~8/7 날짜가 **하나도 없다**
- 8/10~8/14 = 옛 7/27~7/31 개수(5,7,5,6,6), 9/7~9/11 = 옛 8/24~8/28 개수(5,7,5,6,6)
- `grep -c "insert into workouts"` = 228 (아직 예선 블록 전)

- [ ] **Step 4: 예선 카드 블록 삽입**

`-- 4주차` 구분선(현재 815행의 `-- ============================================================`) **바로 앞**에 아래 블록을 넣는다. 날짜 8개 각각 같은 형태로 8번 반복한다(아래는 8개 전부):

```sql
-- ============================================================
-- 제서(ZEST SURVIVOR) 예선 — 7/27~8/5 평일 8일
-- 예선 기간이라 추가운동을 이 카드 1장으로 대체. program_label 없음(헤더 프로그램 배너 제외).
-- 기록은 각자 로그의 메모/무게 칸에 남긴다.
-- ============================================================

with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-07-27', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-07-28', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-07-29', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-07-30', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-07-31', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-08-03', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-08-04', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('ZEST SURVIVOR 예선', null, null, '측정', '2026-08-05', null, 0) returning id
)
insert into workout_exercises (workout_id, exercise_name, sort_order, set_group)
select w.id, '제서 이벤트 측정', 0, 1 from w;
```

- [ ] **Step 5: 시드 헤더 주석에 시프트 이력 추가**

파일 맨 위 주석 블록(1~8행)에서 첫 줄과 데이터 원본 줄 사이에 다음 두 줄을 추가한다:

```sql
-- 2026-08-05: 제서(ZEST SURVIVOR) 예선(7/27~8/5) 반영 — 4~8주차를 +14일 시프트(8/10 재개, 종료 9/11),
--   7/27~8/5 평일 8일에 'ZEST SURVIVOR 예선' 카드 삽입. 8/6~8/7 스페셜은 내용 확정 후 별도 추가.
--   설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md
```

- [ ] **Step 6: 최종 검증**

```bash
cd /Users/chacha/lab/roadtorxd/app
grep -c "insert into workouts" supabase/seed-strength-8week.sql          # 236 (228 + 예선 8)
grep -c "ZEST SURVIVOR 예선" supabase/seed-strength-8week.sql            # 8
grep -c "제서 이벤트 측정" supabase/seed-strength-8week.sql               # 8
grep -o "'2026-0[78]-[0-9][0-9]'" supabase/seed-strength-8week.sql | sort | uniq -c
```
Expected: 마지막 명령에서 7/27~7/31·8/3~8/5는 **각 1개**(예선 카드), 8/6·8/7은 **0개**, 7/6~7/24는 이전과 동일, 8/10 이후는 시프트된 프로그램 카드 개수.

- [ ] **Step 7: 커밋**

```bash
git add supabase/seed-strength-8week.sql
git commit -m "$(cat <<'EOF'
feat(strength): 시드에 2주 시프트 반영 + 예선 카드 8일치

4~8주차 날짜 리터럴 143개 +14일(8/10 재개, 종료 9/11), wipe 범위 종료일 갱신.
7/27~8/5 평일 8일에 'ZEST SURVIVOR 예선' 카드 추가.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: 데이터 문서 동기화

**Files:**
- Modify: `docs/data/season2-strength-8week-data.md` (주차 헤더 5개 + 세션 헤더 25개 + 상단 설명 + 예선 섹션)

**Interfaces:**
- Consumes: Task 4의 새 일정(같은 날짜여야 한다)
- Produces: 없음(사람이 읽는 원본)

**형식:** 주차 헤더는 `## 4주차 — 디로드 (7/27 ~ 7/31)`, 세션 헤더는 `### 월 7/27 · 스쿼트  _(category: 하체(스쿼트))_`. 시프트가 정확히 14일이라 요일 라벨(월~금)은 바뀌지 않는다.

- [ ] **Step 1: 날짜 치환 스크립트 작성·실행**

`/private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad/shift-doc.py`:

```python
import re, datetime, pathlib

p = pathlib.Path('docs/data/season2-strength-8week-data.md')
CUT = datetime.date(2026, 7, 27)
lines = p.read_text().split('\n')

def bump(m):
    mo, dy = map(int, m.group(0).split('/'))
    d = datetime.date(2026, mo, dy)
    if d < CUT:
        return m.group(0)
    n = d + datetime.timedelta(days=14)
    return f'{n.month}/{n.day}'

changed = 0
for i, line in enumerate(lines):
    # M/D 표기는 헤딩에만 있다. 표 안의 '12/12' 같은 좌우 횟수는 건드리지 않기 위해
    # '## ' / '### ' 로 시작하는 줄로만 제한한다.
    if line.startswith('## ') or line.startswith('### '):
        new = re.sub(r'\b\d{1,2}/\d{1,2}\b', bump, line)
        if new != line:
            changed += 1
        lines[i] = new

p.write_text('\n'.join(lines))
print('headings changed:', changed, '(기대 30 = 주차 5 + 세션 25)')
```

Run:
```bash
cd /Users/chacha/lab/roadtorxd/app && python3 /private/tmp/claude-501/-Users-chacha-lab-roadtorxd-app/416dd064-5d65-4e11-8ed7-925262b84d15/scratchpad/shift-doc.py
```
Expected: `headings changed: 30 (기대 30 = 주차 5 + 세션 25)`

- [ ] **Step 2: 결과 확인**

```bash
cd /Users/chacha/lab/roadtorxd/app && grep -n "^## " docs/data/season2-strength-8week-data.md
```
Expected:
```
## 1주차 — 축적 (7/6 ~ 7/10)
## 2주차 — 축적 (7/13 ~ 7/17)
## 3주차 — 축적·볼륨 정점 (7/20 ~ 7/24)
## 4주차 — 디로드 (8/10 ~ 8/14)
## 5주차 — 강화 (8/17 ~ 8/21)
## 6주차 — 강화 (8/24 ~ 8/28)
## 7주차 — 강화·피킹 (8/31 ~ 9/4)
## 8주차 — 실현 / Find Heavy (9/7 ~ 9/11)
```

- [ ] **Step 3: 상단 설명 갱신**

문서 상단의 다음 줄

```markdown
- 시작일: **2026-07-06 (월)**, 주 5일 × 8주 = 40개 세션
```

를 이렇게 바꾼다:

```markdown
- 시작일: **2026-07-06 (월)**, 주 5일 × 8주 = 40개 세션. 종료 **2026-09-11 (금)**
- 제서(ZEST SURVIVOR) 예선(**7/27~8/5**)으로 4~8주차를 2주 미뤘다 — 3주차(7/24) 다음이 4주차(8/10)다.
  예선 기간 8일은 `ZEST SURVIVOR 예선` 카드 1장으로 대체, 8/6~8/7은 스페셜 세션(내용 별도 확정)
```

- [ ] **Step 4: 예선 섹션 추가**

`## 4주차 — 디로드 (8/10 ~ 8/14)` 바로 앞에 아래 섹션을 넣는다(그 앞의 `---` 구분선은 그대로 두고, 이 섹션 뒤에 `---`를 하나 더 붙인다):

```markdown
## 제서 예선 (7/27 ~ 8/5) · 스페셜 (8/6 ~ 8/7)

ZEST SURVIVOR 예선 기간이라 추가운동을 대체한다. 평일 8일(7/27~7/31, 8/3~8/5) 각각 카드 1장:

| 섹션 | 운동 | 세트 | 횟수 | 메모 |
|---|---|---|---|---|
| — | 제서 이벤트 측정 | — | — | 카드 제목 `ZEST SURVIVOR 예선` · 기록은 각자 메모에 |

8/6(목)·8/7(금)은 스페셜 세션 — 내용 미확정. 정해지면 이 자리에 표로 추가하고 시드에도 반영한다.

---
```

- [ ] **Step 5: 커밋**

```bash
git add docs/data/season2-strength-8week-data.md
git commit -m "$(cat <<'EOF'
docs(strength): 데이터 문서 2주 시프트 동기화

4~8주차 주차/세션 헤더 날짜 +14일(종료 9/11), 예선·스페셜 섹션 추가.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: 전체 검증 및 라이브 적용

**Files:** 없음(실행·확인만)

**Interfaces:**
- Consumes: Task 1~5 전부

- [ ] **Step 1: 로컬 전체 검증**

```bash
cd /Users/chacha/lab/roadtorxd/app && npm test && npm run lint && npx tsc --noEmit && npm run build
```
Expected: 테스트 전부 PASS, lint/타입 에러 0, 빌드 성공

- [ ] **Step 2: 사용자에게 SQL 실행 요청**

`supabase/migration-strength-shift-2w.sql`을 Supabase SQL 에디터에서 **위에서 아래로 순서대로 한 번만** 실행해 달라고 요청한다. 전달할 내용:
- 0번 사전 점검이 `already_applied = 0`이어야 진행
- 1번 delete 결과 **236행**, 2번 update 결과 **143행** 기대. 다르면 멈추고 알려 달라고 요청
- 4번 사후 쿼리 두 개의 결과를 붙여 달라고 요청

- [ ] **Step 3: 사후 결과 검증**

받은 결과가 다음과 같은지 확인한다:
- `stale_logs = 0`
- 날짜별 카드: 7/20~7/24 = 3주차, **7/27~7/31·8/3~8/5 = `ZEST SURVIVOR 예선` 각 1장**, **8/6·8/7 없음**, 8/10~8/14 = 4주차, 8/17~8/21 = 5주차, 8/24~8/28 = 6주차, 8/31~9/4 = 7주차, 9/7~9/11 = 8주차

- [ ] **Step 4: 앱에서 눈으로 확인**

```bash
cd /Users/chacha/lab/roadtorxd/app && npm run dev
```
확인 항목:
- 헤더가 `Strength 8주 · 3주차` (오늘 8/5 기준 — 갭 기간이라 마지막 진행 주차 유지)
- 운동 탭에서 **7/28**로 이동 → `ZEST SURVIVOR 예선` 카드 1장이 담기고 `제서 이벤트 측정` 체크가 동작
- **8/6** → 프로그램 카드 없음(요일 WOD만)
- **8/10** → 4주차 콘텐츠(월요일 = 스쿼트)
- **7/15** → 2주차 카드가 담긴다(가드 제거 효과 — 과거 세션 뒤늦게 기록 가능)

- [ ] **Step 5: 배포**

기존 배포 방식대로 `main` 푸시. 푸시 전 `git log --oneline -6`으로 Task 1~5 커밋 5개가 다 있는지 확인한다.

---

---

## Task 7: 8/6~8/7 스페셜 세션 삽입

**Files:**
- Create: `supabase/migration-strength-special-0806.sql`
- Modify: `supabase/seed-strength-8week.sql` (예선 블록과 `-- 4주차` 구분선 사이에 같은 카드 추가)
- Modify: `docs/data/season2-strength-8week-data.md` (스페셜 섹션의 "내용 미확정" 문단을 실제 표로 교체)

**Interfaces:**
- Consumes: Task 3의 예선 카드 메타 규칙(`program_label` null, `category` `측정`)
- Produces: 8/6·8/7 날짜에 카드 3장씩

**내용 출처:** 설계 문서 §5의 표가 유일한 진실. 카드 6장 = 8/6 `A · Baseline`/`B · 어깨·전거근`/`C · 코어`, 8/7 `A · Annie`/`B · 어깨·전거근`/`C · 안정화`.

- [ ] **Step 1: 마이그레이션 파일 작성**

`supabase/migration-strength-special-0806.sql`:

```sql
-- 8/6(목)·8/7(금) 스페셜 세션 삽입 (1회성).
-- 설계: docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md §5
-- 제서 예선 직후 이틀 — 벤치마크(8/6 Baseline · 8/7 Annie) + 어깨·전거근·코어 보조.
-- program_label = null → 헤더 프로그램 배너 미포함(예선 카드와 동일).
-- !!! 멱등하지 않다 — 두 번 실행하면 카드가 중복 생성된다 !!!
-- anon 키로 Supabase SQL editor 실행.

-- 사전 점검: 0이어야 미적용
select count(*) as already_applied from workouts
where owner_user_id is null and program_date in ('2026-08-06', '2026-08-07');

-- ===== 8/6 (목) =====
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · Baseline', null, null, '측정', '2026-08-06', null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Row (Erg)', null, '500m', null, 0, 1, 'For Time · 1 Round', null),
  ('A', 'Air Squat', null, '40', null, 1, 1, 'For Time · 1 Round', null),
  ('A', 'Sit ups', null, '30', null, 2, 1, 'For Time · 1 Round', null),
  ('A', 'Push up', null, '20', null, 3, 1, 'For Time · 1 Round', null),
  ('A', 'Pull up', null, '10', null, 4, 1, 'For Time · 1 Round', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 어깨·전거근', null, null, '측정', '2026-08-06', null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Serratus Punch (band)', null, '15', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Banded Face Pull', null, '20', 'Rest 1:00 b/w sets', 1, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 코어', null, null, '측정', '2026-08-06', null, 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Dead Bug', null, '10/10', null, 0, 1, '3 Sets', null),
  ('C', 'Pallof Press', null, '12/12', 'Rest as needed', 1, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- ===== 8/7 (금) =====
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('A · Annie', null, null, '측정', '2026-08-07', null, 0) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('A', 'Double Under', null, '50-40-30-20-10', null, 0, 1, 'For Time', null),
  ('A', 'Sit ups', null, '50-40-30-20-10', null, 1, 1, 'For Time', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('B · 어깨·전거근', null, null, '측정', '2026-08-07', null, 1) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('B', 'Serratus Punch (band)', null, '15', null, 0, 1, 'Superset · 3 Sets', null),
  ('B', 'Rear Delt Fly', null, '15', null, 1, 1, 'Superset · 3 Sets', null),
  ('B', 'Lateral Raises', null, '15', 'Rest 1:00 b/w sets', 2, 1, 'Superset · 3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);
with w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  values ('C · 안정화', null, null, '측정', '2026-08-07', null, 2) returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, v.* from w, (values
  ('C', 'Plank Shoulder Taps', null, '0:45', 'Rest as needed', 0, 1, '3 Sets', null)
) as v(section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead);

-- 사후 검증: 8/6·8/7 각 3장, 동작 8/6=9행·8/7=6행
select w.program_date, w.sort_order, w.title, count(e.id) as ex
from workouts w left join workout_exercises e on e.workout_id = w.id
where w.owner_user_id is null and w.program_date in ('2026-08-06', '2026-08-07')
group by 1, 2, 3 order by 1, 2;
```

- [ ] **Step 2: 시드에 같은 카드 추가**

`supabase/seed-strength-8week.sql`에서 예선 카드 마지막 블록(`'2026-08-05'`)과 `-- 4주차` 구분선 사이에, Step 1의 `-- ===== 8/6 (목) =====` ~ 마지막 insert까지(사전/사후 select 제외)를 그대로 붙인다. 앞에 구분 주석을 단다:

```sql
-- ============================================================
-- 스페셜 세션 — 8/6(목) Baseline · 8/7(금) Annie
-- 예선 직후 이틀. 벤치마크 + 어깨·전거근·코어 보조. program_label 없음.
-- ============================================================
```

- [ ] **Step 3: 시드 검증**

```bash
cd /Users/chacha/lab/roadtorxd/app
grep -c "insert into workouts" supabase/seed-strength-8week.sql   # 242 (236 + 스페셜 6)
grep -o "'2026-08-0[67]'" supabase/seed-strength-8week.sql | sort | uniq -c   # 각 3
```
Expected: 242 / `'2026-08-06'` 3개, `'2026-08-07'` 3개

- [ ] **Step 4: 데이터 문서의 스페셜 문단을 표로 교체**

`docs/data/season2-strength-8week-data.md`에서

```markdown
8/6(목)·8/7(금)은 스페셜 세션 — 내용 미확정. 정해지면 이 자리에 표로 추가하고 시드에도 반영한다.
```

를 아래로 교체한다:

```markdown
### 목 8/6 · Baseline  _(category: 측정)_

| 섹션 | 운동 | 세트 | 횟수 | 메모 |
|---|---|---|---|---|
| A | Row (Erg) | For Time · 1 Round | 500m | |
| A | Air Squat | — | 40 | |
| A | Sit ups | — | 30 | |
| A | Push up | — | 20 | |
| A | Pull up | — | 10 | |
| B | Serratus Punch (band) | 3 sets | 15 | Superset |
| B | Banded Face Pull | 3 sets | 20 | Rest 1:00 b/w sets |
| C | Dead Bug | 3 sets | 10/10 | |
| C | Pallof Press | 3 sets | 12/12 | Rest as needed |

### 금 8/7 · Annie  _(category: 측정)_

| 섹션 | 운동 | 세트 | 횟수 | 메모 |
|---|---|---|---|---|
| A | Double Under | For Time | 50-40-30-20-10 | |
| A | Sit ups | — | 50-40-30-20-10 | |
| B | Serratus Punch (band) | 3 sets | 15 | Superset |
| B | Rear Delt Fly | 3 sets | 15 | |
| B | Lateral Raises | 3 sets | 15 | Rest 1:00 b/w sets |
| C | Plank Shoulder Taps | 3 sets | 0:45 | Rest as needed |

Baseline(관례적 벤치마크)과 Annie(공식 Girls)는 기록이 남아 나중에 재측정 기준으로 쓸 수 있다.
Annie가 Sit ups 150개라 8/7에는 굴곡 코어를 더 넣지 않고 견갑 안정화만 붙였다.
```

- [ ] **Step 5: 커밋**

```bash
git add supabase/migration-strength-special-0806.sql supabase/seed-strength-8week.sql docs/data/season2-strength-8week-data.md
git commit -m "$(cat <<'EOF'
feat(strength): 8/6~8/7 스페셜 세션 — Baseline · Annie

예선 직후 이틀: 벤치마크 + 어깨·전거근·코어 보조(카드 3장씩).
하지 부하가 있는 Baseline을 목요일로 당겨 8/10 스쿼트 디로드 직전을 비움.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 6: 사용자에게 SQL 실행 요청**

`supabase/migration-strength-special-0806.sql`을 SQL 에디터에서 한 번만 실행 요청. `already_applied = 0` 확인 후 진행, 사후 쿼리가 8/6 3장(9동작)·8/7 3장(6동작)인지 확인.

---

## 후속 (이 계획 범위 밖)

- 챌린지(풀업 등) 일정은 이번 시프트 대상이 아니다.
- `docs/data/season2-strength-8week-data.md`의 4~8주차 표는 2026-07-16 고립/보조 보강(시드에는 반영됨)이 빠진 옛 구조다. 이번 시프트와 무관한 선행 누락이라 손대지 않았다.
