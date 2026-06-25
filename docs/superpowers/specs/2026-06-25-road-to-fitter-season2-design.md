# ROAD TO FITTER — 시즌2 설계 (바프 트래커 → 추가운동 앱 피봇)

- **작성일**: 2026-06-25
- **상태**: 설계 확정 · 구현 계획 작성됨 (`docs/superpowers/plans/2026-06-25-road-to-fitter-season2.md`)
- **작업 순서 결정**: 기능 피봇 먼저 구현 → 비주얼 리디자인(색상 테마·목업)은 별도 후속 단계 (§12)
- **이전 앱**: 2026 ZEST BP Tracker (15주 바디프로필 준비 트래커, 시즌1 — 2026.06.20 종료)
- **새 앱**: ROAD TO FITTER

## 1. 배경 & 목표

바디프로필 준비 프로그램(시즌1)이 완전히 종료되었다. 함께 추가운동을 하던 멤버들이 계속
운동을 만들어 공유하고 기록을 이어갈 수 있도록, 앱을 **추가운동 앱(ROAD TO FITTER)**으로 전환한다.

**핵심 목표**
- 멤버가 운동을 만들어 등록하고, **추가운동 기록 · 1RM · 체중변화**를 트래킹한다.
- 기존 유저들의 운동 데이터는 **보관**한다. 계속 의미 있는 데이터(체중·1RM·운동 기록)는
  계속 노출하고, 바프 전용 데이터(코치 15주 프로그램·식단·D-day 등)는 미노출한다.
- 기존 유저 계정/로그인은 그대로 유지한다 (로그아웃되지 않게).

## 2. 비목표 (YAGNI)

- 멀티시즌 전환/비교 UI (시즌 테이블 없음)
- 운동 댓글/좋아요/소셜 기능
- 식단(칼로리/매크로/OCR), 수면, 물, 영양제, 당·가공, 저강도 유산소 기능 (모두 제거/미노출)
- 시즌1 코치 운동을 새 라이브러리로 이관
- 개인 운동의 DB 레벨 RLS 격리 (가시성은 현행처럼 앱 쿼리에서 `owner_user_id`로 제어)

## 3. 핵심 개념 — 2계층 운동 라이브러리 + 요일 기본 제공

운동 라이브러리는 두 계층으로 구성된다.

1. **공용 기본 운동** — 관리자(chacha)가 직접 등록. 전원에게 노출.
   - 각 공용 운동은 **요일(월~금)에 매핑**되어 **매주 그 요일에 캘린더에 자동 제공**된다
     (예: 월=어깨/가슴, 화=하체, 수=등, 목=팔, 금=전신). 주말은 기본 제공 없음.
   - 앱 내에서는 멤버가 공용 운동을 만들 수 없다. chacha가 SQL/관리자 화면으로 시드한다
     (시즌1 주차 데이터 입력하던 방식과 동일).
2. **개인 운동** — 멤버가 현행 커스텀 운동처럼 직접 추가. **추가한 본인만** 노출.
   - 라이브러리에서 공용 운동 **아래에** 정렬된다.
   - 요일 매핑 없음. 멤버가 원하는 날짜에 직접 "담기"로 추가하며, 주말도 가능.

**결과 기록은 항상 개인별이다.** 공용 운동도 각자 자기 무게/완료/메모를 기록한다.

## 4. 데이터 모델

### 4.1 신규 테이블

```sql
-- 운동 라이브러리 (공용 + 개인)
create table workouts (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  owner_user_id uuid references users(id) on delete cascade,  -- NULL = 공용, 값 있으면 개인(본인만)
  default_weekday int check (default_weekday between 1 and 5), -- 공용 전용: 1=월 .. 5=금, NULL=요일 매핑 없음
  notes text,
  archived boolean not null default false,
  sort_order int not null default 0,
  created_by uuid references users(id),                        -- 작성자(감사용). 공용은 관리자
  created_at timestamp with time zone default now()
);

-- 운동 안의 동작들 (시즌1 workout_templates와 동일 구조 → 렌더링 로직 재사용)
create table workout_exercises (
  id uuid default gen_random_uuid() primary key,
  workout_id uuid references workouts(id) on delete cascade not null,
  section text,
  exercise_name text not null,
  sets text,
  reps text,
  notes text,
  sort_order int not null default 0
);
```

### 4.2 기존 테이블 변경

```sql
-- 결과 기록을 시즌1·2 통합 유지. template_id(시즌1)와 공존, 둘 다 nullable.
alter table workout_logs
  add column workout_exercise_id uuid references workout_exercises(id) on delete set null;
```

- `workout_logs`는 그대로 재사용한다: `date, user_id, exercise_name, section, completed,
  weight_lb, weight_unit, memo, custom_sets, custom_reps`.
- 시즌2 로그는 `workout_exercise_id`가 채워지고 `template_id`는 null.
- `exercise_name`/`section`은 기존 패턴대로 동작에서 복사해 로그에 저장(이력 견고성).

### 4.3 보관(미쿼리) — 삭제하지 않음

- `weeks`, `workout_templates` (시즌1 코치 프로그램)
- `cardio_logs`, `meal_slot_configs`
- `daily_logs`의 식단/수면/물/영양제/당가공 컬럼 (기존 행 값 유지, UI 미노출)

### 4.4 계속 사용

- `daily_logs.weight_kg` (+ `memo`) — 체중 기록
- `user_1rm` — 1RM (시즌 무관 연속)
- `users` — 인증 (변경 없음)

### 4.5 RLS / 가시성

- 신규 테이블의 RLS는 기존 테이블과 동일하게 anon 키로 select/insert/update/delete가
  가능하도록 허용한다 (현행 2026bp와 동일 정책).
- **개인 운동 비공개는 앱 쿼리 레벨에서 보장**한다: 라이브러리/날짜 조회 시
  `owner_user_id is null or owner_user_id = <currentUser>` 필터. (현행 멀티유저가 user_id
  필터로 분리하는 방식과 동일하며, 실제 강한 보안은 아님 — 친구 그룹용.)

## 5. 핵심 기능 흐름

### 5.1 운동 페이지 — 날짜별 뷰 (전면 개편)

시즌1의 "주차 네비 + 요일 그리드(1~5일) + 코치 템플릿" 구조를 다음으로 대체한다.

- **날짜 네비게이터**: 7일 스트립 + 날짜 이동. 평일/주말 모두 선택 가능.
- **선택 날짜의 운동 목록** (workout 단위 카드, 동작별 체크/무게/메모 — 기존 컨트롤 재사용):
  - **공용 운동 섹션**: 그 날짜 요일에 매핑된 공용 운동 (default_weekday = 요일).
  - **개인 운동 섹션** (공용 아래): 그 날짜에 사용자가 담은 개인 운동.
- **운동 추가 버튼**:
  - ① 라이브러리에서 선택 → 이 날짜에 담기
  - ② 새 개인 운동 만들기 (제목 + 동작들) → 라이브러리(개인)에 등록 + 이 날짜에 담기
- **검색/이력**: 기존 `searchWorkoutLogs`(ILIKE) 유지 — 시즌1·2 로그 모두 검색됨.
- **제거**: 저강도 유산소 섹션, 주차/요일(1~5일) 제약, "칼로리 진행률" 문구.

### 5.2 날짜 로드 로직 (`loadData`, 시즌1 패턴 계승)

선택 날짜 D, 요일 W = weekday(D)일 때:

1. `defaultWorkouts` = `workouts`에서 `owner_user_id is null and default_weekday = W and not archived`.
2. 해당 날짜의 `workout_logs`(user, D) 로드 — `workout_exercise_id`로 workout 연결 정보 포함.
3. 각 공용 default 운동에 (user, D) 로그가 없으면 동작들로 **로그 자동 생성**
   (`completed=false, weight_lb=null`), 시즌1 auto-create와 동일.
4. 로그가 존재하는 workout_id 들(= 담은 개인 운동 + 손댄 공용)과 default를 합쳐 그날의 운동 집합 구성.
5. workout 단위로 그룹핑해 렌더 (공용/개인 구분).
6. (연속성) 그 날짜에 `workout_exercise_id`/연결이 없는 시즌1 로그가 있으면 섹션 기준으로
   읽기 위주 렌더 — 과거 날짜 조회 시 기존 기록이 그대로 보인다.

### 5.3 운동 담기 / 기록

- **담기**: 라이브러리에서 운동 선택 → 그 운동의 동작들로 (user, D) 로그를 batch insert.
- **기록**: 동작 체크/무게/메모 변경 시 `upsertWorkoutLog` (기존 800ms 디바운스 패턴).
- **개인 운동 생성**: 제목 + 동작 입력 → `workouts`(owner=current user) + `workout_exercises`
  insert. 곧바로 선택 날짜에 담기.

### 5.4 라이브러리 관리

- **라이브러리 뷰** (모달 또는 별도 화면): 공용(상단, 멤버는 읽기 전용) + 개인(하단, 본인 편집/보관).
  개인 운동 생성/수정/보관(archive)을 여기서 수행.
- **공용 운동 관리**: chacha가 `/admin/workout`을 공용 운동 관리용으로 가볍게 재활용하거나
  SQL로 시드 (초기엔 SQL만으로 충분, YAGNI).

### 5.5 운동별 조회

- 라이브러리에서 특정 운동을 탭하면 그 운동에 대한 **본인 기록 추이**(날짜별 무게/완료)를 표시.
- 데이터: `workout_logs`를 `workout_exercise_id → workout_id` 기준으로 집계.

## 6. 화면별 변경

| 화면 | 변경 |
|---|---|
| **홈 (`/`)** | `DdayCard`·`WeekProgressBar`·`WeeklySummaryCard` 제거 → "오늘의 추가운동" 카드(오늘 요일의 공용+담은 개인 운동 진행 상태) + 최근 체중 스냅샷 |
| **헤더 (`Header.tsx`)** | 주차/단계/D-day 제거 → 앱명("ROAD TO FITTER") + 사용자명 (또는 오늘 날짜) |
| **운동 (`/workout`)** | 5.1~5.5대로 전면 개편 |
| **기록 (`/daily`)** | **체중 + 메모만** 유지. 수면·식단·OCR·매크로·물·영양제·당가공·식단횟수·운동여부 토글 제거. 자동저장 패턴 유지 |
| **요약 (`/summary`)** | `WeightChart`(전체 연속, 동적 범위) + `OneRMSection` 유지. `MacroChart`·`WeeklyStats`·주차 선택 드롭다운·`PROGRAM_START/END` 제거 |
| **로그인/메타** | "2026 ZEST BP Tracker" → "ROAD TO FITTER", "바디프로필 준비 트래커" → 추가운동 트래커류 문구. username+PIN 흐름 불변. localStorage `bp-*` 키는 내부값이라 유지(기존 로그인 보존) |
| **하단 네비 (`BottomNav`)** | 탭 구성 유지(홈/운동/기록/요약). 라벨/아이콘은 필요 시 미세 조정 |
| **`/admin/workout`** | 시즌1 템플릿 관리 → 공용 기본운동 관리용으로 재활용(또는 미연결 방치). 멤버에겐 개인 운동 생성만 개방 |

## 7. 시즌1 데이터 처리

- **삭제 없음.** 분리는 날짜 컷오버가 아니라 "테이블/쿼리"로 자연 분리한다
  (신규 라이브러리/로그 연결엔 시즌2만 존재).
- **체중 그래프·1RM**: 시즌 무관 전부 연속 노출.
- **운동 검색/이력**: 시즌1 로그도 계속 검색·조회됨. 과거 날짜로 이동하면 그날 기록이 그대로 보인다.
- **날짜/캘린더 기본 뷰**: 시즌2(공용 요일 운동 + 담은 개인 운동) 위주.

## 8. lib/api 변경

- **신규** `src/lib/api/workouts.ts`:
  - `getLibrary(userId)` — 공용(owner null) + 개인(owner=userId), 공용 우선 정렬, archived 제외
  - `getDefaultWorkoutsForWeekday(weekday)` — 공용 + default_weekday 매칭
  - `getWorkoutExercises(workoutId)`
  - `createPersonalWorkout(userId, title, exercises[])`, `updatePersonalWorkout`, `archiveWorkout`
  - `getWorkoutProgress(userId, workoutId)` — 운동별 기록 추이
- **변경** `src/lib/api/workout-logs.ts`:
  - 로그 생성/조회 시 `workout_exercise_id` 반영. 날짜 조회를 workout 그룹으로 묶기 위한
    nested select(`workout_exercises(workout_id, workouts(title, owner_user_id))`) 추가.
  - `addWorkoutToDate(userId, date, workoutId)` — 동작들로 로그 batch insert.
- **축소** `src/lib/api/daily-logs.ts`: 체중/메모 위주 사용 (식단/수면 필드는 미사용으로 남김).
- **제거/미사용**: `cardio-logs.ts`, `meal-slots.ts`, `workout-templates.ts`(weeks/templates),
  식단 OCR 컴포넌트(`FoodImageUpload`) 등은 import 끊고 미사용 처리. (파일 즉시 삭제는 선택)
- **유지**: `user-1rm.ts`, `users.ts`, `auth.ts`.

## 9. 마이그레이션 & 배포

- DB: `workouts`, `workout_exercises` 생성 + `workout_logs.workout_exercise_id` 추가 +
  신규 테이블 RLS 정책(기존과 동일 허용). `supabase/` 아래 마이그레이션 SQL로 작성.
- 공용 기본 운동 시드: chacha가 운동 데이터(제목/요일/동작) 작성 → SQL/관리자로 등록.
- `lib/utils.ts`의 `SHOOT_DATE`/`START_DATE`/`PHASES`/`getDday`/`getCurrentWeek`/
  `getCurrentPhase`/`getWeekProgress` 등 바프 전용 헬퍼 제거 또는 미사용 처리.
- 배포: 기존 Vercel 파이프라인 그대로. 기존 유저 로그인 유지(`bp-*` 키 보존).

## 10. 결정 로그 (확정됨)

- 운동 공유: **공용은 관리자 큐레이션(전원 노출) / 개인은 멤버 생성(본인만)**.
- 운동 구성: **라이브러리 + 날짜 담기**(혼합), 날짜별·운동별 둘 다 조회.
- 공용 기본운동: **주중 5일 요일별 고정**, 매주 자동 반복.
- 유지: 추가운동 기록 · 체중+그래프 · 1RM. 미노출: 수면 · 식단 · 물·영양제·당가공·유산소.
- 데이터 구조: **가볍게 피봇** (시즌 테이블 없음, 신규 테이블 + 컬럼 1개, 시즌1 보관).
- 앱명: **ROAD TO FITTER**.

## 11. 구현 순서 (개략 — 상세는 구현 계획에서)

**1단계 — 기능 피봇 (지금 진행).** 비주얼은 현행 테마 토큰 그대로 두고 구조만 개편한다.

1. DB 마이그레이션 (신규 테이블 + `workout_logs` 컬럼 + RLS) 및 공용 운동 시드 틀
2. lib/api: `workouts.ts` 신규, `workout-logs.ts` 확장
3. 운동 페이지 개편 (날짜 뷰 + 공용/개인 섹션 + 담기/생성 + 라이브러리)
4. 기록 페이지 체중+메모로 축소
5. 요약 페이지 정리 (체중 그래프 + 1RM)
6. 홈 + 헤더 개편
7. 브랜딩/문구 교체 (ROAD TO FITTER)
8. 정리 (바프 전용 컴포넌트/유틸 import 제거)

**2단계 — 비주얼 리디자인 (별도 후속, §12).** 사용자가 색상 테마·화면 목업을 제공하면 진행.

## 12. 비주얼 리디자인 (별도 단계 · 추후 사용자 제공 자산 기반)

색상 테마와 화면 목업은 **사용자(chacha)가 추후 제공**한다. 그 자산을 받은 뒤 별도 단계로
진행하며, 1단계 기능 피봇과 독립적으로 작업한다.

**1단계에서 미리 지켜둘 것 (후속 테마 교체를 중앙화하기 위한 제약)**
- 현재 테마는 `src/app/globals.css`의 `:root` CSS 변수 + `@theme inline` 매핑으로 중앙화돼 있다
  (`--background`, `--surface`, `--accent`, `--accent-pop`, `--success`, `--danger`, `--border`,
  `--text-secondary`, `--font-sans` 등).
- 시즌2 신규/개편 컴포넌트는 **하드코딩 hex나 Tailwind 팔레트(`bg-blue-500` 등) 대신 시맨틱
  토큰**(`bg-surface`, `text-accent`, `bg-accent-light`, `border-border`, `text-secondary` 등)을
  사용한다. → 색상 테마 교체가 `:root` 값 변경만으로 대부분 끝난다.
- 폰트도 `--font-sans` 토큰을 통해서만 사용.

**2단계 범위 (자산 수령 후 확정)**
- `:root` 색상 토큰 값 교체(라이트/다크 여부 포함) + 필요 시 토큰 추가.
- 제공된 목업 기준 레이아웃/컴포넌트 시각 조정 (토큰 교체로 안 되는 부분).
- 로고/앱 아이콘/스플래시 등 브랜딩 자산 반영 (제공 시).
