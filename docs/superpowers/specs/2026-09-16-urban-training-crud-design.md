# urban 훈련 목록 편집·삭제·생성 · 설계

- 날짜: 2026-09-16
- 선행: `docs/superpowers/specs/2026-09-16-urban-training-tab-design.md`

## 1. 목적

urban 훈련 목록을 앱 안에서 관리한다. 지금은 SQL로만 넣고 고칠 수 있어서, 스토리 캡처가 올라올 때마다 SQL을 새로 써야 한다. 목록에서 **생성 · 수정 · 삭제**를 할 수 있게 한다.

## 2. 권한 — 오조작 방지용 게이트

urban 목록은 **공용**이라 한 사람이 고치면 전원에게 반영된다. 이 앱에는 권한 개념이 없다(users 테이블에 role 없음, PIN은 전원 공용). 따라서 이 게이트는 **보안이 아니라 오조작 방지**다 — 누구든 코치 계정으로 로그인하면 통과한다. 목적은 일반 회원 화면에 편집 UI가 아예 보이지 않게 하는 것.

`src/lib/api/urban.ts`:

```ts
export const URBAN_EDITORS = ['chacha']
export function canEditUrban(username?: string | null): boolean
```

`UrbanTrainingPopup`이 `getLoggedInUser()?.username`으로 판정해 `+ 새 urban 훈련` 버튼과 카드의 `⋯` 메뉴를 노출/숨김한다. 코치가 늘면 배열에 추가한다.

## 3. 세트 그룹 빌더 추출

편집 폼(제목 + 세트 그룹 + 동작 행 추가/삭제)은 현재 `AddWorkoutPopup`(488줄) 안에 있다. 그대로 복제하면 ~120줄이 두 벌이 되고 한쪽만 고치는 사고가 난다.

→ `src/components/workout/SetGroupBuilder.tsx`로 **순수 이동**한다. props는 `{ groups, setGroups }`이고, 그룹/행 조작 함수 6개(`updateGroupInfo`·`addGroup`·`removeGroup`·`updateRow`·`addRow`·`removeRow`)가 함께 옮겨간다. `buildExercisesFromGroups`(이미 테스트 있음)와 `SetGroup`/`ExerciseRow` 타입은 그대로 둔다.

`AddWorkoutPopup`은 빌더를 쓰도록 바꾸고 동작은 유지한다(회귀 검증: tsc·빌드 + 내 운동 생성/수정 수동 확인).

## 4. API — 얇은 래퍼 3개

기존 함수는 건드리지 않고 `urban.ts`에 감싼다.

| 함수 | 구현 |
|---|---|
| `createUrbanTraining(title, exercises)` | `workouts` insert — `owner_user_id` null, `category` `'urban'`, `default_weekday`/`program_date` null, `sort_order` = 현재 최대 + 1 |
| `updateUrbanTraining(id, title, exercises)` | `updatePersonalWorkout(id, title, URBAN_CATEGORY, exercises)` — owner를 안 따지므로 그대로 쓸 수 있다. 동작 전체 교체 방식 |
| `archiveUrbanTraining(id)` | `archiveWorkout(id)` — `archived = true` |

**삭제는 아카이브다.** 행을 지우면 이미 담아 기록한 로그의 `workout_exercise_id`가 `on delete set null`로 끊겨 시즌1 레거시 카드처럼 렌더된다. 아카이브는 `getUrbanTrainings`가 `archived=false`로 거르므로 목록에서만 사라지고 과거 기록은 그대로다. 복구는 `update workouts set archived = false where id = ...`.

## 5. UI

목록 화면에 두 가지가 추가된다(권한 있을 때만).

- 각 카드 오른쪽 `⋯` → **수정 / 삭제**
- 목록 맨 아래 `+ 새 urban 훈련`

수정·생성은 같은 폼(제목 + `SetGroupBuilder` + 저장/취소)을 쓰고, 팝업 안에서 목록 ↔ 상세 ↔ 폼 3단으로 전환한다. 수정 진입 시 기존 동작을 `set_group` 기준으로 묶어 그룹을 복원한다(`AddWorkoutPopup.handleEditWorkout`과 같은 방식).

삭제는 확인창 — "…를 목록에서 지울까요? 이미 담아서 기록한 건 남습니다."

저장·삭제 후 `urban-trainings` 캐시를 무효화해 목록을 갱신한다.

## 6. 검증

- `canEditUrban` 단위 테스트(코치 계정 / 일반 계정 / null·undefined / 빈 문자열).
- `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
- 수동: 코치 계정에서 생성 → 목록 노출 → 수정(그룹 복원 확인) → 삭제(목록에서 사라지고 담아둔 기록은 유지) / 일반 계정에서 `⋯`·생성 버튼이 안 보이는지 / `+ 내 운동` 생성·수정이 여전히 동작하는지(빌더 추출 회귀).

## 7. 비목표

- 실제 인증·권한 체계(앱 전체에 없음).
- 드래그로 목록 순서 바꾸기(`sort_order`는 생성 시 맨 뒤).
- 아카이브된 항목을 앱에서 복구하는 UI(SQL로).
- 목록 최신순 정렬(별건).
