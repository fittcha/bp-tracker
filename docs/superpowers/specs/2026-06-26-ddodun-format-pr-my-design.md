# ROAD TO FITTER — ddodun 포맷 통일 + PR/MY 탭 (Phase 1) 설계

작성일: 2026-06-26 · 대상 레포: `/Users/chacha/lab/roadtofitter/app`

## 목표
ddodun(크로스핏 트래커, `/Users/chacha/lab/ddodun/app`)의 화면 포맷·디자인을 roadtofitter에 차용한다. **색상은 roadtofitter 파란색 유지**(토큰 이름이 동일해 ddodun 파일을 가져오면 우리 accent가 자동 적용, ddodun 초록은 안 따라옴). 하단 네비를 **5탭**(홈/운동/챌린지/PR/MY)으로 개편하고, ddodun의 **PR 탭**(1RM/nRM/PACE/WOD)을 이식한다.

## 범위
- **Phase 1 (이 스펙)**: 5탭 네비 + 홈 캘린더 재디자인 + PR 탭 이식 + MY 탭 + 챌린지 플레이스홀더.
- **Phase 2 (별도 스펙, 나중)**: 챌린지 기능 본구현. 사용자가 챌린지 포맷(풀업/푸쉬업 등) 제공 후 진행. 메커니즘은 §9에 기록.

## 핵심 사실 (조사 결과)
- ddodun ↔ roadtofitter는 **같은 Supabase 프로젝트** `qaiammqgkrrgfstqadef`. ddodun=`ddodun` 스키마, roadtofitter=`public` 스키마.
- `public.users`와 `ddodun.users`의 user id가 **다름** → ddodun PR 데이터는 자동 이전 불가. roadtofitter PR은 **자체 데이터**로 시작.
- `public.user_1rm` 컬럼(id, user_id, exercise_name, weight, weight_unit, updated_at)이 ddodun `user_1rm`과 **완전 일치** → 이식한 PR의 1RM API가 그대로 동작하고 **기존 roadtofitter 1RM 데이터 보존**.
- `lucide-react`(^0.577.0) 이미 설치. 스택 동일(Next 16.1.6 / React 19 / Tailwind v4 / supabase-js).
- roadtofitter auth = localStorage `bp-*` + `getLoggedInUser(): AuthUser{ id, ... }` (커스텀, Supabase Auth 아님). PR 코드의 `getLoggedInUser()?.id`는 우리 것으로 교체하면 호환.

## Global Constraints
- **시맨틱 테마 토큰만**: `bg-surface`, `text-accent`, `bg-accent-light`, `border-border`, `text-text-secondary`, `text-foreground`, `text-danger`, `text-success` 등. 하드코딩 hex/`bg-blue-500`류 금지. (ddodun 파일에서 가져온 토큰명이 우리 globals.css와 동일 → 파란색 자동.)
- **테스트 하네스 없음** → 검증 게이트 = `npm run build`(타입체크) + `npm run lint` + dev 수동 확인.
- **DB 변경은 raw SQL** 파일을 `supabase/`에 작성 → Supabase SQL 에디터 또는 anon REST로 적용. 신규 테이블 RLS는 기존과 동일하게 anon/authenticated 전체 허용.
- **기존 로그인 보존**: `bp-*` localStorage 키 불변.
- 커밋 메시지 한국어 + `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- **작업트리 주의**: 세션 이전 untracked 파일 다수 → `git add -A` 금지, 변경 경로만 stage.

---

## §1 하단 네비 (5탭)
파일: `src/components/BottomNav.tsx` 수정.

탭 순서/라우트/아이콘(lucide-react):
1. 홈 `/` — `Calendar`
2. 운동 `/workout` — `Dumbbell`
3. 챌린지 `/challenge` — `Flame` (플레이스홀더)
4. PR `/pr` — `Trophy`
5. MY `/my` — `User`

- 기존 커스텀 SVG 아이콘 → lucide 아이콘으로 교체(ddodun 포맷 통일). active=`text-accent-pop`(또는 현 active 토큰), inactive=`text-text-secondary`.
- 레이아웃 `flex justify-around`는 5탭에서도 그대로 동작.
- 기존 `기록` 탭(`/daily`) 제거 → MY로 대체.

## §2 홈 캘린더 재디자인 + 통계
파일: `src/components/home/WorkoutCalendar.tsx`, `src/app/page.tsx` 수정.

**캘린더 (ddodun 스타일)**:
- 월 그리드, 일~토(일요일 시작). 헤더 "YYYY년 M월" + "오늘" 배지 + 이전/다음 달 네비.
- 날짜 셀: 숫자 + **숫자 아래 작은 점**.
  - **회색 점**(`bg-text-secondary/40` 류): 그 날짜에 운동 로그가 있으나 완료 0 (= 운동 있는 날)
  - **파란 점**(`bg-accent`): 그 날짜에 완료된 동작 ≥1 (= 운동 한 날). 파란 점이 회색보다 우선.
  - 점 없음: 로그 없는 날.
- 오늘: 숫자를 `bg-accent text-white` 채운 원으로. (점은 오늘도 규칙대로 표시 가능.)
- 날짜 탭 → `/workout?date=YYYY-MM-DD` (기존 동작 유지).
- 무거운 "셀 가득 채운 동그라미" 방식 폐기(사용자 피드백: 부담스러움).

**통계 카드 (유지)**: 캘린더 아래 `이번 달 운동 N일`(메인) + `이번 주 N일`(보조). 완료일 기준(일~토 주). 기존 `app/page.tsx` 통계 로직 유지.

**데이터**: `workout-logs.ts`에 두 가지 날짜 집합 조회 필요:
- `getCompletedDatesInRange(userId, start, end)`: 완료(`completed=true`) 날짜 (기존 헬퍼).
- `getWorkoutDatesInRange(userId, start, end)`: 로그가 존재하는 모든 날짜(완료 무관). **신규 헬퍼**.
- 캘린더는 그리드 범위로 두 집합을 받아: 파란 점 = completed 집합, 회색 점 = (workout 집합 − completed 집합).

## §3 PR 탭 (ddodun 이식, 파란색)
신규 라우트 `src/app/pr/page.tsx`. ddodun PR 탭을 그대로 이식.

**이식 파일** (ddodun `→` roadtofitter, 경로 동일 매핑):
- `src/app/pr/page.tsx` (메인: PR/WOD 서브탭, 1RM 그리드, nRM, PACE, 인라인 유틸 formatTime/calcPace 등)
- `src/components/pr/ExerciseIcons.tsx`
- `src/components/pr/NrmAddModal.tsx`
- `src/components/pr/PaceAddModal.tsx`
- `src/components/pr/WodTab.tsx`
- `src/components/pr/WodRecordModal.tsx`
- `src/components/pr/WodHistoryModal.tsx`
- `src/components/pr/OpenWodAddModal.tsx`
- `src/lib/api/pr.ts` (getAll1RM/upsert1RM/delete1RM, getAllNRM/upsertNRM/deleteNRM, getAllPaceRecords/upsertPaceRecord/deletePaceRecord)
- `src/lib/api/wod.ts` (getAllWodRecords/getWodRecords/createWodRecord/deleteWodRecord + WOD 프리셋 상수)

**이식 시 적응 (필수)**:
1. **auth**: ddodun `getLoggedInUser` import → roadtofitter `@/lib/auth`의 `getLoggedInUser`. 반환 `.id` 사용은 동일.
2. **supabase 스키마**: ddodun 클라이언트는 `db.schema: 'ddodun'`. roadtofitter 클라이언트는 public(스키마 옵션 없음). 이식한 `pr.ts`/`wod.ts`는 roadtofitter `@/lib/supabase`(public)를 그대로 import → 테이블이 public에 있으면 동작. **추가 클라이언트 불필요.**
3. **date-utils**: `WodTab`이 ddodun `@/lib/date-utils`의 `DAY_LABELS` 등 사용. roadtofitter엔 `@/lib/utils`에 `formatDate`/`toDateString`만 있음. 필요한 헬퍼(`DAY_LABELS` 등)는 이식 파일에서 쓰는 것만 골라 `@/lib/utils`에 추가하거나 WodTab 내부로 인라인. (이식 시 실제 사용 심볼만.)
4. **테마 토큰**: 그대로 두면 우리 파란 accent 자동 적용. 하드코딩 색 없는지 확인.
5. **lucide 아이콘**: `Plus`, `Trash2`, `X` — 이미 설치됨.

**1RM 정합(중요)**:
- 이식한 `pr.ts`의 1RM API는 `public.user_1rm`(컬럼 일치)을 사용 → **기존 roadtofitter 1RM 데이터 그대로 노출**.
- 1RM 기본 운동 목록은 ddodun PR 탭의 **12개**(백/프론트스쿼트, 데드리프트, 벤치/숄더/푸시프레스, 클린/파워클린/클린앤저크/푸시저크, 스내치/파워스내치) 사용(스크린샷 그리드 기준).
- **제거(중복 해소)**: roadtofitter 기존 `src/components/summary/OneRMSection.tsx`, `src/components/summary/ExerciseIcons.tsx`, `src/lib/api/user-1rm.ts` 삭제(이식한 PR이 대체). 단 삭제 전 소비처 0 확인(현재 OneRMSection은 기록 탭에서만 사용 → MY로 가며 제거됨).
- `src/components/summary/WeightChart.tsx`는 **유지**(MY 탭이 사용).

## §4 MY 탭
신규 라우트 `src/app/my/page.tsx`. 기존 `src/app/daily/page.tsx` 콘텐츠를 이전·변형:
- **체중 입력** + **체중 그래프**(`WeightChart`) 유지.
- **1RM 섹션 제거**(PR 탭으로 이동).
- **로그아웃/계정** 버튼 유지(기존 daily 하단 로그아웃).
- 자동저장은 기존 부분 업데이트(기존 row spread → `weight_kg`만, 보관 컬럼 보존) 유지. 메모는 이미 제거됨.
- 기존 `src/app/daily/page.tsx`는 삭제(라우트 `/daily` 제거). `/daily` 참조 잔여 없게 정리.

## §5 챌린지 플레이스홀더
신규 라우트 `src/app/challenge/page.tsx`:
- "챌린지 준비 중이에요" 안내 + 간단 일러스트/문구. 시맨틱 토큰.
- Phase 2에서 본구현 교체.

## §6 DB 마이그레이션 (public 스키마)
파일: `supabase/migration-pr-tables.sql` 신규.
- `user_1rm`은 **이미 존재** → 건드리지 않음.
- 신규 3개 테이블(ddodun 스키마 정의를 public으로 복제):

```sql
-- nRM
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
-- PACE
create table if not exists user_pace_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  equipment text not null,
  distance text not null,
  time_seconds int,
  updated_at timestamptz default now(),
  unique(user_id, equipment, distance)
);
-- WOD
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
-- RLS (기존 테이블과 동일 전체 허용)
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
- 적용: chacha가 Supabase SQL 에디터로 실행(런타임 PENDING). 이식한 코드 자체는 빈 테이블이어도 동작(빈 목록).

## §7 검증
- 각 단계 `npm run build` + `npm run lint` 클린(신규 lint 0; 기존 시즌1 lint 2건은 범위 밖).
- dev 수동: 5탭 이동, 홈 캘린더 2색 점·오늘 표시·통계, PR 탭 1RM(기존 데이터)·nRM/PACE/WOD 입력, MY 탭 체중/그래프/로그아웃, 챌린지 플레이스홀더, 운동 탭 정상.

## §8 파일 변경 요약
- **신규**: `app/pr/page.tsx`, `app/my/page.tsx`, `app/challenge/page.tsx`, `components/pr/*`(7), `lib/api/pr.ts`, `lib/api/wod.ts`, `supabase/migration-pr-tables.sql`. `lib/utils.ts`에 WodTab용 헬퍼 추가(필요분만).
- **수정**: `components/BottomNav.tsx`(5탭+lucide), `components/home/WorkoutCalendar.tsx`(2색 점), `app/page.tsx`(통계 유지·캘린더 props), `lib/api/workout-logs.ts`(`getWorkoutDatesInRange` 추가).
- **삭제**: `app/daily/page.tsx`(→MY), `components/summary/OneRMSection.tsx`, `components/summary/ExerciseIcons.tsx`, `lib/api/user-1rm.ts`.
- **유지**: `components/summary/WeightChart.tsx`(MY).

## §9 Phase 2 — 챌린지 (메커니즘 기록, 본구현 보류)
사용자가 포맷 제공 후 별도 스펙. 확정 메커니즘:
- 제공되는 **데일리 횟수 스케줄 테이블** 챌린지(예: 풀업 챌린지, 푸쉬업 챌린지).
- 목록에서 **선택해 시작** 가능. **난이도 입력** 가능.
- **하루하루 완료 체크**. **미완료 시 다음날 재도전**(스케줄 진행 안 됨/그 날 재시도).
- 완료 표시에 **날짜 기록**.
- 중간 **초기화** 가능 — **초기화 컨펌 다이얼로그** 필수.
- 챌린지 포맷 데이터 구조(요일×횟수 등)는 사용자 제공 예정.
