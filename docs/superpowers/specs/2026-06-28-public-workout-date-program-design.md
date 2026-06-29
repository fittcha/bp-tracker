# 공용 운동 — 날짜 기반 프로그램 설계

- **작성일**: 2026-06-28
- **상태**: 설계 확정(사용자 승인) → 구현 계획(writing-plans) 예정
- **앱**: ROAD TO FITTER / Road to Rx'd · Next.js 16 + Supabase
- **선행**: 개인운동 "세트 그룹" 빌더(`set_group`/`set_info`, `2026-06-28-personal-workout-set-group-builder-design.md`) — 이 설계는 그 그룹 모델을 공용에 확장.

## 1. 배경 & 문제

현재 공용 운동(`owner_user_id IS NULL`)은 `workouts.default_weekday`(1=월~5=금) 하나에 묶여 **매주 동일하게 반복**된다(`getDefaultWorkoutsForWeekday`). 그러나 사용자는 **날짜 기준으로 테마별 프로그램을 일정 기간 배정**하려 한다. 첫 프로그램은 **8주 스트렝스**(2026-07-06 시작, 주5일×8주=40세션). 같은 "월요일·스쿼트"라도 주차마다 세트·%1RM·구성이 전부 다르다(W1 @75% 4×5 → W3 @80% 5세트+백오프 → W4 디로드 → W8 Find Heavy Single). 현재 모델엔 "날짜"가 없어 표현 불가.

또 한 세션은 섹션 A(메인)/B(보조 슈퍼셋)/C(안정화)/D(피니셔)로 나뉜다. 이걸 **세트 그룹(`set_group`/`set_info`)** 으로 렌더하되, 그룹 사이 연결을 개인운동의 `– into –`(서킷)와 구분해야 한다.

## 2. 목표

- 공용 운동을 **특정 날짜(`program_date`)** 에 배정. 그날 뷰는 그 날짜의 세션을 표시.
- 한 세션 = 여러 **세트 그룹**(섹션 A/B/C/D). 각 그룹 = `set_info` 헤더 + 동작들.
- **그룹 사이 연결자(`set_lead`)** 를 그룹별 텍스트로 표현(또둔 모델). `'into'`=서킷 구분선, 자유텍스트(예 `'Rest 3:00'`)=이탤릭 연결, `null`=블록 분리.
- 프로그램 식별/표시용 **`program_label`**(예 `'Strength 8주 · 1주차'`) eyebrow.
- 콘텐츠는 **SQL 시드로만** 관리(인앱 편집기 없음).

## 3. 비목표 (YAGNI)

- %1RM → 실제 중량 자동계산(메모 텍스트로만 표시).
- 인앱 공용 세션 편집기(시드 SQL로 관리).
- 진행률 % 바/게이지(라벨만; 향후 토대).
- 과거 미기록 날짜 일괄 백필(자동담기는 오늘/미래만).
- 기존 `default_weekday` 요일반복 공용 유지(신규는 날짜 기반; 기존 플레이스홀더는 시드에서 제거).
- 개인운동 빌더에 연결자 선택 UI(빌더는 항상 `'into'`).

## 4. 또둔(DDODUN) 검증 결과 (설계 근거)

또둔은 운동을 단일 `description` 텍스트로 저장하고, 같은 섹션도 여러 행으로 쪼갠 뒤 `computeGroups()`로 그룹 분리한다. **그룹의 연결/구분 신호 = 각 그룹 첫 줄의 리드 텍스트**: `EMOM 8`·`3 Sets`(setInfo 헤더), `Rest 3:00`·`— into —`·`* and then,`(연결자 note), 없으면 블록. 즉 연결 방식은 **운동 전역 플래그가 아니라 "그룹별 텍스트"** 다. 본 설계는 이 모델을 정규화 스키마(`set_group`/`set_info`/`set_lead`)로 옮긴다. (또둔: `src/components/workout/WorkoutSection.tsx` `parseDescription`/`computeGroups`.)

## 5. 데이터 모델

기존 컬럼 유지. 컬럼만 추가(공용·개인·시즌1 호환).

```sql
-- 운동(세션) 정의
alter table workouts
  add column if not exists program_date  date,   -- 공용 프로그램 세션 날짜(null=비프로그램)
  add column if not exists program_label text;    -- 프로그램 태그 eyebrow(예 'Strength 8주 · 1주차')

-- 동작: 그룹 연결자
alter table workout_exercises
  add column if not exists set_lead text;         -- 그룹 위 연결자: 'into' | 자유텍스트 | null

-- 그날 로그: 연결자 복사본
alter table workout_logs
  add column if not exists set_lead text;
```

- 이미 존재(선행 기능): `workout_exercises`/`workout_logs`의 `set_group int`, `set_info text`.
- 공용 프로그램 세션 = `workouts`(`owner_user_id` NULL, `program_date` 지정, `program_label`, `title`, `category`) + `workout_exercises`(섹션→`set_group`, `set_info`=그룹 헤더, `set_lead`=그룹 연결자).
- `set_lead` 의미: `'into'` → `– into –` 구분선 / 그 외 텍스트 → 이탤릭 연결자 줄 / `null` → 블록 분리(헤더 밴드만). **첫 그룹은 항상 연결자 없음**(set_lead 무시).
- 공용 스트렝스: 섹션은 블록이라 `set_lead = null`. 개인운동: 빌더가 2번째 그룹부터 `'into'`. 공용 서킷(향후): `'into'` 시드.
- 개인운동에선 `sets`/`section` 미사용(그룹핑=`set_group`); 공용 세션은 `section` 추적용 보존 가능(렌더는 `set_group` 사용).

## 6. 데이터 흐름 / API (`src/lib/api`)

1. **타입**:
   - `Workout`(`workouts.ts`): `+ program_date?: string | null`, `+ program_label?: string | null`.
   - `WorkoutExercise`(`workouts.ts`): `+ set_lead?: string | null`.
   - `WorkoutLog`(`workout-logs.ts`): `+ set_lead?: string | null`.
   - `WorkoutLogJoined.workout`(`workout-logs.ts`): `+ program_label: string | null`.
2. **조회**:
   - 신규 `getWorkoutsForDate(date: string): Promise<Workout[]>` — `owner_user_id IS NULL AND program_date = date AND archived = false`, `sort_order` 순.
   - `getWorkoutExercises`는 `select('*')` → `set_lead` 포함(변경 불필요).
   - `getWorkoutLogsWithWorkout` select 문자열에 `set_lead` 추가; workouts 조인에 `program_label` 추가; 매핑에서 `workout.program_label` 채움.
3. **담기**: `addWorkoutToDate` 행에 `set_lead: ex.set_lead ?? null` 추가(`set_group`/`set_info`는 이미 복사).
4. **그날 뷰**(`src/app/workout/page.tsx`): 요일반복 조회를 **날짜 기반**으로 교체.
   - `getDefaultWorkoutsForWeekday(weekday)` → `getWorkoutsForDate(ds)`.
   - 자동담기: 미기록 공용 세션은 **오늘/미래만** 자동 생성(현행 규칙 유지; 프로그램 시작 7/6이라 전부 미래). 과거 미기록 날짜는 자동표시 안 함.
   - 공용/개인 그룹핑·정렬은 현행 유지(공용 먼저, 개인 "추가 운동").

## 7. 렌더 (`src/components/workout/WorkoutCard.tsx`)

- **그룹 렌더 판정**: 로그에 `set_group`이 하나라도 있으면 그룹 렌더(개인 + 공용 프로그램 공통). 없으면 기존 섹션 렌더(레거시 요일반복 공용·시즌1 템플릿). → 현재 `isPersonal` 기준을 **`set_group` 존재 기준**으로 일반화.
- **그룹 헤더** = `set_info` 밴드(`bg-border/50` semibold; 선행 기능과 동일).
- **그룹 사이 연결자**(2번째 그룹부터, 그 그룹의 `set_lead`):
  - `set_lead === 'into'` → `– into –` 구분선(현재 스타일: `border-t` + 가는 선 + italic 'into').
  - `set_lead` 가 그 외 비어있지 않은 텍스트 → `border-t` + 이탤릭 연결자 줄(그 텍스트 표시, 예 "Rest 3:00").
  - `set_lead` null/빈값 → 블록 분리(헤더 밴드 + `border-t`만, 연결자 텍스트 없음).
- **program_label eyebrow**: 카드 헤더에서 `workout.program_label` 있으면 제목 위 작은 라벨로 표시(공용 프로그램 세션). 없으면 미표시.
- **완료 체크·무게(lb/kg)·메모 자동저장**: 현행 유지.
- **휴지통(그날에서 빼기)**: 현행대로 **개인 전용**(`owner_user_id != null`). 공용 프로그램 세션엔 미표시(자동담기로 재생성되므로).

## 8. 빌더 (`src/components/workout/AddWorkoutPopup.tsx`)

- `buildExercises()`: 유효 그룹을 순서대로 만들 때, **첫 그룹은 `set_lead = null`, 이후 그룹은 `set_lead = 'into'`** 부여(개인운동은 항상 into 서킷). UI 변경 없음.
- `handleEditWorkout`: 기존 동작을 `set_group`으로 그룹 복원(현행). `set_lead`는 저장 시 재부여하므로 빌더 state에 보관 불필요.

## 9. 시드 (`supabase/`)

- `migration-workout-program.sql`(신규): §5 ALTER 3건(workouts 2 + workout_exercises 1 + workout_logs 1).
- `seed-strength-8week.sql`(신규): `season2-strength-8week-data.md` 40세션 전사.
  - 세션마다 `workouts` 1행: `owner_user_id` NULL, `program_date`(평일 7/6~8/28), `program_label`(`'Strength 8주 · N주차'`), `title`(예 "스쿼트"), `category`(예 "하체(스쿼트)"), `sort_order`.
  - 섹션→`set_group`(1,2,…), `set_info`=그룹 헤더(예 `"A · 메인 · 4 Sets"`, `"B · 슈퍼셋 · 3 Sets"`). **세트수가 다른 블록(예 백오프)은 별도 그룹**으로 분리.
  - `set_lead`=`null`(섹션 블록). 동작=`exercise_name`/`reps`(횟수·시간)/`notes`(메모: %1RM·RIR·Rest). `sets`=null, `section`은 추적용 기록 가능.
  - 기존 플레이스홀더 요일반복 공용은 시드에서 제거(또는 archived).
  - anon 키로 적용(RLS 허용). 사용자가 Supabase에서 실행.
- 셀 정확도: 데이터 문서 → 시드 1:1 매핑 검증(주차/요일/날짜/섹션/동작/세트/횟수/메모).

## 10. 기존 데이터 / 호환

- 레거시 요일반복 공용(플레이스홀더): 날짜 기반 조회로 전환 시 안 뜸 → 시드에서 제거.
- 과거 평평한 개인운동 로그(`set_group` null): 그룹 렌더 판정에서 `set_group` 없음 → 1그룹 취급(선행 기능과 동일).
- 시즌1 템플릿 로그(workout 없음): 섹션 렌더 그대로.
- `set_lead` null 기존 그룹: 연결자 없이 블록 분리(개인 과거 로그는 into 없이 떨어지나, 신규 생성분부터 into 적용).

## 11. 테스트 / 검증

- 컴포넌트 테스트 인프라 없음 → 게이트 = `npx tsc --noEmit` + `npm run lint` clean (시즌1 기존 lint 2건은 알려진 기술부채).
- 순수 매핑(빌더 state→exercises의 `set_lead` 부여)은 vitest 단위 테스트 가능(선택).
- 라이브 DB 마이그레이션+시드 적용, 모바일 시각 QA(7/6 스쿼트 세션 A/B/C/D 블록 표시, 7/7 덤벨상체, program_label eyebrow, 개인운동 into 유지)는 사용자 수동.

## 12. 영향 파일

- `supabase/migration-workout-program.sql` (신규: ALTER 4컬럼)
- `supabase/seed-strength-8week.sql` (신규: 40세션)
- `src/lib/api/workouts.ts` (`Workout`/`WorkoutExercise` 타입 + `getWorkoutsForDate`)
- `src/lib/api/workout-logs.ts` (`WorkoutLog`/`WorkoutLogJoined` 타입 + select(`set_lead`,`program_label`) + `addWorkoutToDate` 복사)
- `src/app/workout/page.tsx` (날짜 기반 조회 + 자동담기)
- `src/components/workout/WorkoutCard.tsx` (set_group 그룹판정 + 그룹별 set_lead 연결자 + program_label eyebrow)
- `src/components/workout/AddWorkoutPopup.tsx` (`buildExercises` set_lead 부여)
