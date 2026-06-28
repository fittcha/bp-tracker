# 개인 운동 "세트 그룹" 빌더 설계

- **작성일**: 2026-06-28
- **상태**: 설계 확정(사용자 승인) → 구현 계획(writing-plans) 예정
- **브랜치**: `personal-workout-set-groups`
- **앱**: ROAD TO FITTER / Road to Rx'd · Next.js 16 + Supabase

## 1. 배경 & 문제

개인 운동 생성 폼(`AddWorkoutPopup`)은 **플랫한 4열 표**(동작명/세트/횟수/메모)로 동작을 입력한다. 그러나 결과 렌더(`WorkoutCard`)는 시즌1 **코치 템플릿용 "섹션 그룹"** 모델 — 첫 동작의 `sets`+`notes`를 **그룹 헤더(setInfo)로 끌어올린다**. 그래서 사용자가 동작별로 입력하면(예: 피라미드 인터벌 400/600/…), 첫 동작의 세트(1)·메모(7'30")가 `1 Sets · 7'30"` 헤더로 올라가고 나머지 동작은 자기 횟수/메모가 안 보인다. **입력 포맷(동작별)과 등록 포맷(섹션 그룹+끌어올림)이 불일치.**

사용자가 원하는 모델: 운동은 **"세트 그룹"의 연속**이고, 각 그룹이 자체 세트 정보 + 동작들을 갖는다.

## 2. 목표 모델

- 운동 = **순서 있는 세트 그룹 목록** (그룹 사이는 `– into –`로 이어짐).
- 각 **세트 그룹** = `set_info`(그룹 헤더 텍스트, 예: `3 Sets`, `AMRAP 10`, 빈 값 허용) + **동작 목록**.
- 각 **동작** = `동작명` + `횟수/시간` + `메모`. (동작별 세트 없음 — 세트/라운드 개념은 그룹 단위)
- 빌더: 기본 1그룹 생성. **+ 동작 추가**(그룹에 동작 행 추가) / **+ 세트 추가**(새 세트 그룹 생성).

## 3. 비목표 (YAGNI)

- 공용(코치) 운동·시즌1 템플릿의 빌더/렌더 변경 (이번엔 **개인 운동 생성/수정만** 교체, 기존 섹션 렌더 유지).
- 동작별 다중 세트(동작마다 set1/set2 다른 무게) — 세트는 그룹 단위로 결정됨.
- 그날 로그의 과거 데이터 일괄 백필(불필요 — 렌더가 null을 1그룹으로 처리).
- 동작 라이브러리(추천 동작) 자동완성 등 부가 기능.

## 4. 데이터 모델

개인 운동만 대상. 기존 컬럼 유지(공용·시즌1 호환), 컬럼 추가만.

```sql
-- 운동 정의
alter table workout_exercises
  add column if not exists set_group int,     -- 그룹 순서(1-based). 개인운동만 사용
  add column if not exists set_info  text;    -- 그룹 헤더(예: '3 Sets'). null 가능

-- 그날 로그(담긴 운동)
alter table workout_logs
  add column if not exists set_group int,
  add column if not exists set_info  text;
```

- 동작 필드 매핑: `exercise_name`(동작명) · `reps`(횟수/시간) · `notes`(메모). 기존 `sets` 컬럼은 개인운동에서 **미사용**(공용·시즌1 호환 위해 보존).
- `section`도 개인운동에선 미사용(그룹핑은 `set_group`로).

## 5. 데이터 흐름

1. **생성**(`createPersonalWorkout`): 그룹 순서대로 각 동작에 `set_group`(1,2,…)·`set_info` + `exercise_name`/`reps`/`notes`·`sort_order` 저장.
2. **수정**(`updatePersonalWorkout`): 기존 동작 전량 교체(현행 방식) — 그룹/동작 재저장.
3. **담기**(`addWorkoutToDate`): `workout_exercises` → `workout_logs` 복사 시 `set_group`·`set_info`도 복사.
4. **조회**(`getWorkoutExercises`, `getWorkoutLogsWithWorkout`): `set_group`·`set_info` select에 포함.
5. **렌더**(`WorkoutCard`): §7.

## 6. 빌더 UI (`AddWorkoutPopup` 생성/수정)

```
운동 이름 [______]   [카테고리 ▾]

┌ 세트 그룹 1 ─────────────────────────────┐
│ 세트 info [예: 3 Sets / AMRAP 10 ______]    │
│  · [동작명]  [횟수/시간]  [메모]        ✕    │
│  · [동작명]  [횟수/시간]  [메모]        ✕    │
│  [+ 동작 추가]                              │
└────────────────────────────────────────┘
              – into –
┌ 세트 그룹 2 ──────────────────────  ✕그룹  ┐
│ 세트 info [______]                          │
│  · [동작명]  [횟수/시간]  [메모]        ✕    │
│  [+ 동작 추가]                              │
└────────────────────────────────────────┘

[+ 세트 추가]
                            [취소]  [만들고 담기 / 수정 저장]
```

- 상태: `groups: { id: string; setInfo: string; rows: { id: string; exercise_name: string; reps: string; notes: string }[] }[]`. 기본값 = 그룹 1개 + 동작 1줄.
- 핸들러: `addGroup` / `removeGroup(gi)` / `addRow(gi)` / `removeRow(gi, ri)` / `updateGroupInfo(gi, v)` / `updateRow(gi, ri, field, v)`.
- 입력칸 = **테두리 박스 + 모바일 너비**(좁지 않게), 모달 = **중앙 + 양쪽 여백**(이미 적용된 패턴 유지).
- 동작 행의 `동작명`만 있으면 유효(횟수/메모 선택). 그룹은 유효 동작이 1개 이상일 때만 저장.
- 저장 매핑: 그룹 순서 = `set_group`(1-based), 그룹 `setInfo` = `set_info`, 동작 = `exercise_name`/`reps`/`notes`, `sort_order` = 전체 순번.

## 7. 렌더 (`WorkoutCard`)

- **개인 운동 분기**: 카드의 로그가 개인 운동(`workout.owner_user_id != null`)이면 **그룹 모델**로 렌더.
  - `set_group`(없으면 1)로 그룹핑, 그룹 순서대로.
  - 그룹 헤더 = `set_info`(있을 때만 표시).
  - 동작 = `횟수(reps) 접두 + 동작명 + 메모(notes)`.
  - 그룹 사이 **`– into –`** 구분선.
  - **세트info 끌어올리기 안 함**(버그 제거).
- **그 외**(공용 코치·시즌1 템플릿, `owner_user_id == null` 또는 workout 없음): **기존 섹션/끌어올리기 로직 그대로**.
- 완료 체크(동작별 + 카드 전체)·무게(lb/kg) 입력·메모 자동저장은 현행 유지.

## 8. 기존 데이터 / 호환

- 과거에 담긴 **평평한 개인운동 로그**: `set_group`=null → 렌더가 "1그룹·헤더 없음"으로 그림 → 동작들이 `횟수+동작명+메모`로 깔끔히 보임(기존 `1 Sets · 7'30"` 끌어올림 버그도 사라짐). **별도 백필 불필요.**
- 기존 개인운동 정의(`workout_exercises`): 수정폼 로드 시 `set_group` null → 1그룹으로 취급.
- 공용 코치 운동·시즌1 템플릿: 변경 없음.

## 9. 영향 파일

- `supabase/migration-workout-set-groups.sql` (신규: ALTER 2개 테이블)
- `src/lib/api/workouts.ts` (`WorkoutExercise` 타입 + create/update에 그룹 저장 + getWorkoutExercises select)
- `src/lib/api/workout-logs.ts` (`WorkoutLog` 타입 + addWorkoutToDate 복사 + getWorkoutLogsWithWorkout select)
- `src/components/workout/AddWorkoutPopup.tsx` (그룹형 빌더)
- `src/components/workout/WorkoutCard.tsx` (개인운동 그룹 렌더 분기)

## 10. 테스트 / 검증

- 프로젝트에 컴포넌트 테스트 인프라 없음 → 게이트 = `npx tsc --noEmit` + `npm run lint` clean.
- 라이브 DB 마이그레이션 적용 + 모바일 시각 QA(생성→담기→그날 렌더, 기존 평평 운동 렌더)는 사용자 수동.
- 그룹 매핑 순수 로직(빌더 state → workout_exercises rows)은 추출해 vitest로 단위 테스트 가능(선택).
