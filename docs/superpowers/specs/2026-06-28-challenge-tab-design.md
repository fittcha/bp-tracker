# 챌린지 탭 설계 — 제공 챌린지 (Phase 2a)

- **작성일**: 2026-06-28
- **상태**: 설계 확정 (사용자 리뷰 대기) → 구현 계획(writing-plans) 예정
- **앱**: ROAD TO FITTER / Road to Rx'd (`/Users/chacha/lab/roadtorxd/app`)
- **스택**: Next.js 16 (App Router) + TypeScript + Tailwind v4 + Supabase (public 스키마)
- **선행 의존(PENDING)**: 풀업·푸쉬업 **표 이미지** — day별 목표 횟수, 밴드 색상 목록, 푸쉬업 난이도 구간. 구조는 본 문서대로 두고 **숫자만 시드 SQL로 채움**(시즌1 주차 데이터 입력 방식과 동일).

## 1. 배경 & 목표

하단탭 `챌린지`(Flame)는 현재 플레이스홀더(`src/app/challenge/page.tsx` = "챌린지 준비 중")다. 멤버가 풀업·푸쉬업 같은 **데일리 챌린지**를 골라 난이도를 설정하고, day별 목표 횟수표를 따라 도전하며, **연속 도전(스트릭)** 과 **이번 달 도전 횟수**를 트래킹할 수 있게 한다.

**핵심 목표**
- **제공 챌린지**(현재 풀업·푸쉬업 2종)를 골라 난이도·훈련요일을 설정하고 시작한다.
- 시작하면 day별 목표 횟수표가 열리고, 각 day를 **미도전 → 성공/실패 → (실패 시) 재도전**으로 기록한다.
- 동시에 여러 챌린지를 진행할 수 있다.
- 홈 탭에 **도전 중 챌린지** 위젯(정사각형 카드 = 챌린지명 + 스트릭 + 이번 달 도전 횟수)을 노출한다.
- 챌린지 정의(표)는 **시드 테이블**로 관리해 나중에 SQL로 숫자 수정이 가능하다(앱 데이터 관리 방식과 동일).

## 2. 비목표 (YAGNI · 후속 단계)

- **개인 구성 챌린지**(동작·난이도·기간·요일별 횟수를 사용자가 직접 구성) — **Phase 2b**. 본 문서의 "공통 엔진" 위에 별도 소스로 얹는다. 별도 스펙으로 진행.
- **운동 탭 연동**(도전 중 챌린지를 운동 탭에서 함께 보기) — 구현 난이도 보고 후속 결정.
- 챌린지 정의의 앱 내 편집 UI(관리자 화면). chacha가 SQL/시드로만 관리.
- 소셜/리더보드/타인과 비교, 푸시 알림, 챌린지 정의의 RLS 격리.
- 난이도 변경(시작 후). 난이도는 **시작 시 고정** — 바꾸려면 새 인스턴스로 다시 시작.

## 3. 핵심 개념

챌린지 기능은 **공통 엔진**(day 시퀀스 · 성공/실패 상태머신 · 스트릭 · 홈 위젯) 위에 **제공 챌린지**가 얹히는 구조다. 본 문서는 공통 엔진 + 제공 챌린지(Phase 2a)만 다룬다.

핵심 설계 결정 두 가지:

1. **표(프로그램)는 순수 day 시퀀스다.** `Day1, Day2, … DayN` + day별 목표 횟수. **요일 정보 없음.** 표에는 요일을 적지 않는다.
2. **스트릭은 사용자가 선택한 "훈련 요일" 기준의 캘린더 출석으로 잰다.** day 진행과 분리한다.
   - 이유: 실패 후 **재도전이 반복**되면 "day ↔ 요일" 매핑이 깨진다(한 day를 며칠에 걸쳐 재도전). 따라서 스트릭은 *"어느 day를 했는지"* 가 아니라 *"훈련요일에 출석(=그날 1번이라도 도전)했는지"* 로 잰다. → 재도전을 몇 번 하든 스트릭 계산은 영향받지 않는다.

난이도 방식은 챌린지 종류마다 다르다.
- **풀업** = `equipment`(장비형). 난이도(밴드 색·갯수 / 맨몸 / 중량)는 **기록·표시용**이고 day 표는 **공통 1개**.
- **푸쉬업** = `range`(구간형). 난이도(니/풀 × 최대 가능 갯수 구간)마다 **독립된 day 표** 1개씩.

## 4. 데이터 모델

모두 Supabase **public** 스키마. uuid PK, `users(id)` 참조는 기존 테이블과 동일 컨벤션.

### 4.1 정의 (시드, 읽기 전용)

```sql
-- 챌린지 종류
create table challenge_templates (
  key            text primary key,              -- 'pullup' | 'pushup'
  name           text not null,                 -- '풀업 챌린지'
  exercise       text not null,                 -- '풀업'
  difficulty_mode text not null,                -- 'equipment'(풀업) | 'range'(푸쉬업)
  sort_order     int  not null default 0,
  created_at     timestamptz not null default now()
);

-- day별 목표 횟수표 (난이도 구간별로 1개)
create table challenge_programs (
  id            uuid default gen_random_uuid() primary key,
  template_key  text not null references challenge_templates(key),
  difficulty_key text,                          -- 풀업=NULL(공통 1개) / 푸쉬업='knee_10_15' 같은 구간키
  label         text,                           -- 표시용(예: '니푸쉬업 10~15개')
  created_at    timestamptz not null default now(),
  unique (template_key, difficulty_key)
);

create table challenge_program_days (
  id          uuid default gen_random_uuid() primary key,
  program_id  uuid not null references challenge_programs(id) on delete cascade,
  day_no      int  not null,                    -- 1-based 순수 시퀀스 (요일 없음)
  target_reps int  not null,                    -- 그 day 목표 횟수
  unique (program_id, day_no)
);
```

- 풀업: `challenge_programs` 1행(`difficulty_key=NULL`) + 그 아래 `challenge_program_days` N행.
- 푸쉬업: 난이도 구간 수만큼 `challenge_programs` 행 + 각 프로그램의 `challenge_program_days`.
- **총 day 수(total_days)** 는 `max(day_no)` 로 도출(별도 컬럼 없음).

### 4.2 사용자 진행 (실데이터)

```sql
-- 도전 인스턴스
create table user_challenges (
  id               uuid default gen_random_uuid() primary key,
  user_id          uuid not null references users(id) on delete cascade,
  template_key     text not null references challenge_templates(key),
  program_id       uuid not null references challenge_programs(id),  -- 난이도로 해석된 프로그램
  difficulty       jsonb not null default '{}'::jsonb,               -- 표시·기록용 난이도 상세
  training_weekdays int[] not null,                                  -- 훈련요일 [1..7] (1=월 .. 7=일), 기본 {1,2,3,4,5}
  started_at       date not null default current_date,
  status           text not null default 'active',                  -- 'active' | 'archived'
  created_at       timestamptz not null default now()
);

-- 도전 시도 이력 (append-only; 도전/재도전 1회 = 1행, 영구 보존)
create table challenge_attempts (
  id                uuid default gen_random_uuid() primary key,
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no            int  not null,                       -- 어느 program day를 도전했는지
  result            text not null,                       -- 'success' | 'fail'
  done_date         date not null default current_date,  -- 도전한 날 (기본 오늘, 수정 가능)
  created_at        timestamptz not null default now()
);
create index on challenge_attempts (user_challenge_id, day_no);
create index on challenge_attempts (user_challenge_id, done_date);
```

> **모델 핵심**: day별 "현재 상태"를 저장하는 테이블은 **두지 않는다.** 도전/재도전은 모두
> `challenge_attempts`에 **append-only**로 쌓고(이력 영구 보존), day의 현재 상태·스트릭·횟수는
> 모두 attempts에서 **파생**한다. 시작 시 day 행을 미리 생성하지 않는다(`user_challenges` 1행만 생성).

**day별 현재 상태 파생 규칙** (특정 `day_no` 기준)
- `result='success'` attempt 존재 → **성공(잠금)**
- 없고 `result='fail'` attempt 존재 → **실패(재도전 가능)**
- 둘 다 없음 → **미도전**

**목표 횟수(`target_reps`)** 는 `challenge_program_days`에서 **live 조회**(스냅샷 미보관). 시드 표는
관리자(chacha)가 통제하므로 진행 중 변경 위험은 낮다고 가정(§12).

**`difficulty` jsonb 예시**
- 풀업: `{"type":"band","color":"red","count":2}` · `{"type":"bodyweight"}` · `{"type":"weighted","weight_kg":10}`
- 푸쉬업: `{"variant":"knee","range_key":"10_15"}` (→ 해당 `program_id`로 해석)

> 밴드 색상 목록·중량 단위·푸쉬업 구간(variant×최대갯수)의 **정확한 값은 표 이미지 수령 후 확정**(§9, §10).

## 5. 상태 머신 (day 단위 — attempts에서 파생)

```
            도전(성공)                       성공 attempt 존재 → 잠금
 미도전 ──────────────────▶ 성공 ───────────────────────────────────┐
   │                          ▲                                      │
   │ 도전(실패)               │ 재도전(성공)                          │ done_date 수정만
   ▼                          │                                      ▼
 실패 ◀──────────────────────┘   (실패인 동안 재도전 버튼 노출)        (이력은 영구 보존)
   └─ 재도전(실패) → 또 실패 attempt append …
```

- **미도전(untried)**: 해당 day에 attempt 없음.
- **도전** → **성공/실패** 선택 → `challenge_attempts` 1행 **INSERT**(`done_date` 기본 오늘, 수정 가능).
- **실패(fail)**: **재도전** 버튼 노출 → 또 한 행 **INSERT**(append). **이전 실패 행은 그대로 보존**.
- **성공(success) = 잠금**: success attempt가 생기면 더 이상 attempt 불가. 전체 초기화 전까지는 그 **success attempt의 `done_date` 수정만** 가능(성공 취소 불가).
- **전체 초기화**(얼럿 컨펌): 해당 인스턴스의 `challenge_attempts`를 **전부 삭제** → 전 day 미도전. **인스턴스/난이도/훈련요일은 유지.**

> **`done_date` 기본 오늘 + 수정 가능** 의도: 며칠치를 한 번에(몰아서) 기록하는 경우 대비.
> **재도전 이력 보존**: 실패→성공이 며칠에 걸쳐도 각 시도가 행으로 남아 스트릭 출석·도전 횟수에 모두 반영된다.

## 6. 계산 (스트릭 · 이번 달 도전 횟수)

인스턴스별로 계산한다. 입력: `training_weekdays`, 그리고 그 인스턴스의 `challenge_attempts` 전체(성공/실패/재도전 모두).

### 6.1 스트릭 🔥
- **출석한 날** = `challenge_attempts.done_date` 가 존재하는 캘린더 날짜(성공/실패/재도전 무관, "그날 1번이라도 도전"). 같은 날 여러 도전은 1일 출석으로 묶임.
- 오늘부터 거꾸로 **훈련요일(`training_weekdays`)에 해당하는 날짜만** 훑으며, 그날 출석이 있으면 +1, 없으면 중단. **비훈련요일은 건너뜀**(증가도 중단도 안 함).
- **오늘이 훈련요일인데 아직 미출석**이면 스트릭은 끊긴 게 아니라 **유지(살아있음)** — 카운트는 어제까지 기준.
- 결과: 스트릭 일수 + **살아있음/끊김** 플래그(살아있으면 컬러, 끊기면 회색 — 듀오링고풍).

```
예) 훈련요일=월~금
…목(출석) 금(출석) [토·일 건너뜀] 월(출석) 화(출석) → 스트릭 5, 살아있음
…월(출석) 화(미출석, 지나감) 수(오늘)            → 화에서 끊김 → 회색
```

### 6.2 이번 달 도전 횟수
- `done_date` 가 이번 달인 **`challenge_attempts` 행 수**. **성공·실패·재도전을 각각 1회로 카운트**(같은 day를 3번 실패+1번 성공 = 4회). 출석한 "날 수"가 아니라 "도전한 횟수".

> 둘 다 **쿼리/유틸 계산**이며 별도 집계 컬럼을 두지 않는다.

## 7. 챌린지 탭 UI (`/challenge`)

```
┌ 챌린지 ─────────────────────────────┐
│ [ + 챌린지 추가 ]                      │   ← 없으면 빈 상태 안내만
│                                      │
│ ┌ 대시보드 카드(인스턴스 1개) ────────┐ │
│ │ 풀업 챌린지     🔥 5  이번달 12회  ⟳ │ │   ⟳ = 전체 초기화(컨펌)
│ │ 빨강밴드 2개                        │ │   ← 난이도 요약
│ ├────────────────────────────────┤ │
│ │  D1   D2   D3   D4   D5   D6  D7  │ │   ← 7개씩 줄바꿈(시각적 표, 캘린더 아님)
│ │  ✓5   ✓6   ✓6   ✗7   ↻7   ·8  ·8 │ │
│ │  D8   D9  …                       │ │
│ └────────────────────────────────┘ │
└──────────────────────────────────────┘
   ✓ 성공  ✗ 실패  ↻ 재도전대기(fail)  · 미도전   숫자 = 그 day 목표횟수
```

- 상단 `+ 챌린지 추가` → 아래로 **active 인스턴스별 대시보드 카드** 나열. active 없으면 빈 상태 안내.
- **카드 헤더**: 챌린지명 · 난이도 요약 · 🔥스트릭 · 이번 달 N회 · ⟳전체 초기화(얼럿 컨펌).
- **day 그리드**: `D1…DN` **시퀀스**를 7개씩 줄바꿈한 시각적 표. 각 셀 = 상태 아이콘 + 목표 횟수.
- **셀 탭 → 하단 시트**로 상태 컨트롤:
  - 미도전 → `[도전]` → **성공/실패** (성공/실패 시 날짜 = 기본 오늘, 수정 가능)
  - 실패 → `[재도전]` → 성공/실패 다시
  - 성공 → **날짜 수정만**

### 7.1 챌린지 추가 팝업 (3단계)
1. **챌린지 선택**: 풀업 / 푸쉬업 카드.
2. **난이도 구성**
   - 풀업: 밴드(색상+갯수) / 맨몸 / 중량(무게) 택1 → `difficulty` jsonb. **프로그램은 항상 공통**.
   - 푸쉬업: 니/풀 + 최대 가능 갯수 → **구간 자동 결정** → 해당 `program_id`.
3. **훈련 요일 선택**: 월~일 중 다중 선택, **기본 월~금**(`{1,2,3,4,5}`).
4. `[시작]` → `user_challenges` 1행 생성(day 행 미리 생성 안 함; 전 day는 attempt 없음 = 미도전) → 대시보드 카드 오픈.

## 8. 홈 위젯 연동

- **위치**: 홈(`src/app/page.tsx`)의 **운동 통계 카드(이번 달 운동) 바로 아래**.
- **active 챌린지가 있을 때만** "도전 중 챌린지" 섹션 등장(없으면 미표시).
- 인스턴스마다 **정사각형 카드** 1개. 내용은 **딱 3개**:

```
┌───────────┐   ┌────────────┐
│ 풀업 챌린지 │   │ 푸쉬업 챌린지 │
│           │   │            │
│   🔥 5    │   │   🔥 2     │
│  12회 도전 │   │   8회 도전  │
└───────────┘   └────────────┘
```
  - **챌린지명 / 🔥연속 기록 / 이번 달 도전 횟수**. 그 외 요소(주간 스트립 등) 없음.
  - 🔥 스트릭: 살아있으면 컬러, 끊기면 회색.
  - 여럿이면 **2개씩 그리드**(자연 줄바꿈). 카드 탭 → `/challenge`.

## 9. 난이도 구성 상세

### 9.1 풀업 (`equipment`)
- 옵션: **밴드**(색상 + 갯수) / **맨몸** / **중량**(무게). 택1.
- 표시·기록용일 뿐 **day 표에 영향 없음**(공통 프로그램 1개).
- 밴드 **색상 목록**, 중량 단위(kg/lb)는 표/사용자 확인 후 확정.

### 9.2 푸쉬업 (`range`)
- variant: **니푸쉬업 / 푸쉬업**.
- **최대 가능 갯수** 입력 → 구간 매핑(예: `10~15`, `16~25`, …) → `difficulty_key` → `program_id`.
- variant × 구간 = 프로그램 수. **정확한 구간 경계·표는 이미지 수령 후 확정**.

## 10. 미정 / 표 이미지 의존

| 항목 | 채우는 곳 | 비고 |
|---|---|---|
| 풀업 day별 목표 횟수 | `challenge_program_days` (program=공통) | 이미지 |
| 푸쉬업 구간별 day 표 | `challenge_programs` + `_days` (구간마다) | 이미지 |
| 밴드 색상 목록 | 추가 팝업 옵션 + 시드 | 이미지/사용자 |
| 푸쉬업 구간 경계 | `difficulty_key` 매핑 | 이미지 |

→ 표/시드는 **별도 seed SQL**(`supabase/seed-challenges.sql`)로 분리해, 숫자만 나중에 채워도 스키마/코드 변경 불필요.

## 11. 기술 노트 (배치)

기존 컨벤션(`src/lib/api/*.ts` 모듈, `src/components/<도메인>/*` 컴포넌트, `globals.css` 시맨틱 토큰)을 따른다.

- **API**: `src/lib/api/challenges.ts`
  - `getChallengeTemplates()`, `getProgram(templateKey, difficultyKey)`
  - `getActiveChallenges(userId)` — 인스턴스 + program days + attempts 로딩 → day별 상태/스트릭/횟수 파생
  - `startChallenge({userId, templateKey, difficulty, trainingWeekdays})` — `user_challenges` 1행만 생성(day 행 미리 생성 안 함)
  - `addAttempt({userChallengeId, dayNo, result, doneDate})` — `challenge_attempts` INSERT(도전·재도전 공통). 단, 해당 day에 success attempt가 이미 있으면 거부(잠금)
  - `updateAttemptDate({attemptId, doneDate})` — 성공 셀 날짜 수정
  - `resetChallenge(userChallengeId)` — 그 인스턴스의 `challenge_attempts` 전부 삭제
  - 테이블 미생성(마이그레이션 PENDING) 시 `PGRST205` → 빈 목록 반환(`pr.ts` 패턴 동일)
- **상태/스트릭/횟수 유틸**: `src/lib/challenge/derive.ts` — 순수 함수, 단위 테스트 대상
  - `deriveDayStatus(attemptsByDay)` → day_no별 `untried|fail|success` + 표시용 done_date
  - `computeStreak(trainingWeekdays, attemptDates, today)` · `monthlyAttemptCount(attempts, month)`
- **컴포넌트**
  - `src/app/challenge/page.tsx` — 탭(추가 버튼 + 카드 목록 + 빈 상태)
  - `src/components/challenge/ChallengeDashboardCard.tsx` — 인스턴스 1개(헤더 + day 그리드 + ⟳)
  - `src/components/challenge/DayCell.tsx` — 그리드 셀
  - `src/components/challenge/DayStatusSheet.tsx` — 하단 시트(상태/날짜)
  - `src/components/challenge/AddChallengePopup.tsx` — 3단계 추가 플로우
  - `src/components/home/ChallengeWidgets.tsx` — 홈 정사각형 카드 섹션
- **DB**: 마이그레이션 `supabase/migration-challenges.sql`(§4 테이블) + 시드 `supabase/seed-challenges.sql`(§10). 라이브 적용은 사용자 확인 후.
- **테마**: 스트릭 "살아있음" = `--accent-pop`(골드) 계열, "끊김" = 회색(`text-secondary`). 성공/실패 = 기존 `--success`(파랑)/`--danger`(빨강).

## 12. 상태 머신 불변식 / 엣지

- day 상태·스트릭·횟수는 모두 `challenge_attempts`에서 **파생**. 시작 시 day 행을 미리 만들지 않음.
- **도전·재도전은 append-only** — 어떤 시도도 삭제·덮어쓰지 않음(이력 영구 보존). 유일한 삭제 경로는 **전체 초기화**(인스턴스의 attempts 전부 삭제).
- **성공 attempt가 생기면 그 day는 잠금** — 추가 attempt INSERT 거부. UI는 성공 셀에 **날짜 수정만** 노출. 성공 취소 불가(전체 초기화로만).
- **`target_reps` 는 program에서 live 조회**(스냅샷 미보관). 관리자가 진행 중 표를 바꾸면 표시값이 따라 바뀜 — 시드 안정 가정 하에 허용. (스냅샷이 필요해지면 `user_challenges`에 program 버전 고정 또는 attempt에 target 스냅샷 추가)
- 동시 여러 active 인스턴스 허용. 같은 챌린지(template)를 난이도 달리해 동시에 둘 수도 있음.
- **시작 day는 항상 `day_no=1`** 부터(중간 시작 없음).

## 13. 결정 완료 (2026-06-28 사용자 확정)

1. **재도전 이력 보존** → ✅ append-only `challenge_attempts` 채택. 실패→성공이 며칠에 걸쳐도 각 시도가 스트릭 출석·도전 횟수에 모두 반영(§4.2, §5, §6).
2. **이번 달 도전 횟수** → ✅ "도전한 횟수"(성공·실패·재도전 각 1회). 출석 "날 수"가 아님(§6.2).
3. **시작 day** → ✅ 항상 `day_no=1`부터(§12).
