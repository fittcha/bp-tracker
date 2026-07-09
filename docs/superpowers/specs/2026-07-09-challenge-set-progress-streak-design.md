# 챌린지 세트별 진행 + 완료/스트릭 보호 설계

작성일: 2026-07-09
대상: Road to Rx'd 챌린지 탭 (Next.js 16 + Supabase, public 스키마, anon key, RLS allow-all, SWR+localStorage 캐시)

두 개의 독립적이지만 응집된 챌린지 UX 개선. Part A(세트별 진행)와 Part B(완료+스트릭 보호)는 데이터·컴포넌트를 공유하나 서로 의존하지 않는다.

## 배경 (현재 모델)

- `challenge_program_days`: `day_no, week_no, day_in_week, sets_text('·' 구분, 마지막 '+'=AMRAP), rest_seconds`
- `user_challenges`: `id, user_id, template_key, program_id, difficulty, training_weekdays[], started_at, status('active'|'archived'), created_at`
- `challenge_attempts`(append-only): `id, user_challenge_id, day_no, result('success'|'fail'), done_date, created_at` → 카드 상태 + 스트릭의 소스. **성공은 terminal(잠금)**.
- `derive.ts`: `deriveDayStates`(day별 success>fail>untried, success 잠금), `computeStreak(trainingWeekdays, attemptDates, today)`(훈련요일 역순 연속출석; 오늘 미출석은 유예), `monthlyAttemptCount`.
- `ChallengeDashboardCard`: 주차 그리드에 day별 세트칩(표시전용) + 상태 점 + 스트릭(🔥). `DayStatusSheet`: day 클릭 시 세트칩(표시전용) + 성공/실패 버튼 + 날짜 + (성공 시 날짜수정·기록삭제).
- 삭제(`deleteChallenge`)는 물리삭제(attempts cascade). 다음 난이도로 가려면 삭제 → 새 챌린지는 attempts 0 → **스트릭 0으로 초기화(문제)**.

---

## Part A — 세트별 진행 클릭

### A1. 목표
DayStatusSheet의 각 세트 칩을 클릭해 개별 세트를 "진행완료"로 토글. 모든 세트 완료 시 자동 성공. 부분 진행은 서버에 보존(닫기·실패해도 유지). **기존 성공/실패 버튼은 유지**(성공 경로가 둘: 세트 전부 클릭 or 성공 버튼).

### A2. 데이터
신규 테이블 `challenge_day_progress`:
```sql
create table if not exists challenge_day_progress (
  id uuid primary key default gen_random_uuid(),
  user_challenge_id uuid not null references user_challenges(id) on delete cascade,
  day_no int not null,
  done_sets jsonb not null default '[]',   -- 완료된 세트 인덱스(0-based) 배열, 예 [0,2,4]
  updated_at timestamptz not null default now(),
  unique (user_challenge_id, day_no)
);
alter table challenge_day_progress enable row level security;
create policy "cdp all" on challenge_day_progress for all using (true) with check (true);
```
- `done_sets`는 0-based 세트 인덱스 배열. 총 세트 수 = 해당 day `sets_text.split('·').length`.
- 챌린지 삭제 시 FK cascade로 함께 정리.

### A3. 순수 로직 (derive/challenge)
- `toggleSet(doneSets: number[], index: number): number[]` — index 있으면 제거, 없으면 추가(정렬 유지). 순수·테스트.
- `isDayComplete(doneSets: number[], totalSets: number): boolean` — 서로 다른 유효 인덱스가 total개 모두 있으면 true. 순수·테스트.

### A4. API (`src/lib/api/challenges.ts`)
- `ActiveChallenge`에 `progress: Record<number, number[]>`(day_no → done_sets) 추가. `getActiveChallenges`가 `challenge_day_progress`를 함께 로드해 채움(2-step, day_no별 map).
- `setDayProgress(userChallengeId, dayNo, doneSets: number[]): Promise<void>` — upsert(`onConflict: user_challenge_id,day_no`). done_sets 저장.
- `clearDayProgress(userChallengeId, dayNo): Promise<void>` — 해당 행 삭제(성공 기록 삭제 시 호출).
- 자동 성공은 **호출측(sheet)**에서 판단: 토글 결과가 `isDayComplete`면 `addAttempt(success)` + `setDayProgress`. (addAttempt는 이미 성공 잠금 가드 보유.)

### A5. UI (`DayStatusSheet`)
props에 `doneSets: number[]`, `totalSets`(파생), `onToggleSet(index)`, `onClearProgress` 추가.
- **세트 칩 = 토글 버튼**:
  - `status !== 'success'`: 클릭 가능. `doneSets` 포함 인덱스 = 채운 스타일(네이비 채움/체크), 미포함 = 빈 테두리.
  - `status === 'success'`: **잠금**(disabled) + 전부 채운 스타일(성공 = 완료 의미). 어느 경로로 성공했든 동일.
- 클릭 흐름: `onToggleSet(i)` → 부모가 `toggleSet` 계산 → `setDayProgress` → 결과가 `isDayComplete`면 이어서 `addAttempt(success, 날짜)`(→ day 성공·잠금). 아니면 진행만 저장.
- **성공 버튼 유지**: 누르면 기존대로 `addAttempt(success)`(세트 클릭 없이 즉시 성공·잠금). **실패 버튼 유지**: `addAttempt(fail)` — `done_sets`는 **보존**(clear 안 함).
- **성공 상태 되돌리기(잠금 해제 장치, 2가지)** — 성공 시 칩이 잠기므로 반드시 해제 수단 제공:
  - **"잠금 해제"(수정) 버튼**: `deleteAttempt(successId)` 만 호출(`done_sets` **보존**) → 성공 취소, 칩 다시 편집 가능(전부 채워진 부분 상태). 세트 조정 후 다시 전부 채우면 재성공. 가벼운 되돌리기.
  - **"기록 삭제"(휴지통, 기존)**: `deleteAttempt(successId)` **+ `clearDayProgress`** → day 완전 리셋(untried, 세트 초기화). 완전 삭제.
  - 두 버튼은 성공 상태 액션 줄에 함께 노출(잠금해제=보더/세컨더리, 기록삭제=danger 휴지통).
- 부분 진행(성공/실패 attempt 없음): sheet엔 채운 칩 유지, **카드(ChallengeDashboardCard)엔 미표시**(untried 점 그대로).

### A6. 카드
`ChallengeDashboardCard`/`DayColumn` 변경 없음 — 성공/실패/미도전 점만. 부분 진행은 밖에 표시하지 않는다(요구사항).

---

## Part B — 전체 완료 + 스트릭 보호

### B1. 목표
"챌린지 전체 완료" 버튼(아무때나 수동). 완료 = **아카이브**(삭제 아님, attempts 보존)로 활성 목록에서 제거. **같은 종목** 챌린지를 완료 후 **7일 내** 새로 시작하면 연속기록(스트릭)이 이어진다. UX 안내문구 제공.

### B2. 데이터
`user_challenges` 컬럼 추가:
```sql
alter table user_challenges add column if not exists completed_at timestamptz;
alter table user_challenges add column if not exists carried_streak int not null default 0;
alter table user_challenges add column if not exists final_streak int not null default 0;
```
- 완료 = `status='archived'` + `completed_at=now()` + `final_streak=<완료 시점 표시 스트릭>`.
- `carried_streak` = 시작 시 스냅샷된 이어받은 스트릭(같은 종목 최근 완료의 `final_streak`, 7일 내면).
- `getActiveChallenges`는 `status='active'`만 → 완료건 자동 제외.

### B3. 순수 로직 (`derive.ts`)
`computeStreakWithCarry(trainingWeekdays, attemptDates, today, startDate, carried)` 추가(기존 `computeStreak` 확장/래핑):
- 오늘부터 훈련일 역순 walk(기존과 동일, 오늘 미출석 유예).
- walk 중 **지나간 훈련일 미출석 → 끊김 → 그 지점 count 반환(carried 안 더함)**.
- walk가 **`startDate` 이전으로 끊김 없이 넘어가면 → count + carried 반환**(시작부터 오늘까지 무결 = 이어받기 유효).
- 반환 `{ count, alive }`. 카드는 이걸로 표시.
- `carried`는 시작 시점에 이미 "7일 내" 조건을 통과해야 >0이므로, 이후 계산은 무결성만 본다. 체인(A→B→C)은 `final_streak` 스냅샷이 전이돼 자연 연결.
- **완료~시작 사이의 갭 면제**: walk는 `startDate`에서 멈추고 carried를 더하므로, **시작일 이전(갭 구간)의 훈련일 미출석은 검사하지 않는다**(=7일 보호). 즉 갭에 기록이 없어도 **시작일부터 이전 스트릭이 이어진다**. 시작 직후(기록 0)면 표시 스트릭 = carried. 단 시작 후 B에서 훈련일을 빠뜨리면 walk가 시작일에 못 닿아 carried 미포함(정상 리셋).

### B4. API
- `startChallenge`: insert 전 `carried_streak` 산출 — 같은 `template_key`의 `status='archived' AND completed_at is not null AND completed_at >= (오늘 − 7일)` 중 `completed_at` 최신의 `final_streak`(없으면 0). insert에 `carried_streak` 포함.
- `completeChallenge(userChallengeId, finalStreak: number): Promise<void>` — `status='archived', completed_at=now(), final_streak=finalStreak` update. (스트릭은 클라이언트에서 `computeStreakWithCarry`로 계산해 전달.)
- `getCarriedStreak`은 startChallenge 내부 헬퍼로 처리(별도 export 불필요).

### B5. UI
- **완료 버튼**: `ChallengeDashboardCard` ⋯ 메뉴에 "완료"(초기화·삭제와 함께). 클릭 → 확인 다이얼로그(안내문구) → `completeChallenge(id, 현재스트릭)` → `onChanged`(카드 사라짐).
- **스트릭 표시**: 카드 🔥 count = `computeStreakWithCarry(training, attemptDates, today, started_at, carried_streak)`. 새 챌린지(이어받음, attempts 0)면 시작부터 carried 숫자 표시.
- **이어받음 배지**: `carried_streak > 0`인 챌린지 카드 헤더에 "이전 기록 N일 이어받음" 작은 배지(골드).
- **안내문구(3곳)**:
  1. 완료 확인 다이얼로그: "완료하면 기록이 보존되고, **7일 안에 같은 종목 다음 난이도를 시작하면 연속기록이 이어져요.**"
  2. 이어받은 카드 배지(위).
  3. 챌린지 대시보드 상단 또는 완료 버튼 근처 짧은 안내 1줄(예: "완주 후 7일 내 다음 난이도를 시작하면 🔥연속기록 유지").

### B6. 삭제 vs 완료 구분
- **삭제**(기존): 물리삭제, 기록 소멸, 스트릭 이어받기 불가. 유지.
- **완료**(신규): 아카이브, 기록 보존, 7일 내 이어받기. 다음 난이도 이동의 정식 경로.

---

## 테스트
- `derive.ts` 순수함수 vitest:
  - `computeStreakWithCarry`: (a) 무결하게 시작일 넘어가면 carried 더함, (b) 중간 훈련일 끊기면 carried 안 더함, (c) attempts 0 + 갓 시작 → carried 표시, (d) carried=0이면 기존 computeStreak과 동일.
  - `isDayComplete`, `toggleSet`.
- `challenge_day_progress` API·DayStatusSheet 토글·완료 버튼은 supabase/React라 유닛테스트 없음(코드베이스 관례) → `tsc --noEmit` + `npm run build` + 수동.
- 기존 challenge 테스트(derive.test.ts 등) 회귀 유지.

## 마이그레이션 / 배포
`supabase/migration-challenge-progress.sql`(신규): §A2 테이블 + §B2 3컬럼. 라이브 SQL 에디터 1회 적용. 미적용 시: 세트 진행 저장 실패(칩 토글 무동작) + 완료/이어받기 미동작 — 앱 나머지는 정상(getActiveChallenges의 progress 로드는 테이블 없으면 빈 map로 폴백).

## 범위 밖 (YAGNI)
- 완료한 챌린지 히스토리 열람 화면(숨김으로 충분).
- 세트별 진행의 카드 표시(요구상 미표시).
- 교차 종목 스트릭 이어받기(같은 종목만).
