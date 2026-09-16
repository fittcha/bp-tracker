# urban 훈련 탭 · 설계

- 날짜: 2026-09-16
- 선행: `docs/superpowers/specs/2026-06-28-personal-workout-set-group-builder-design.md`(내 운동 팝업), `2026-06-28-public-workout-date-program-design.md`(공용 카드)

## 1. 목적

운동 탭 `+ 내 운동` 아래에 `+ urban 훈련`을 둔다. 내 운동 팝업과 비슷하지만 세 가지가 다르다.

1. **부위별 카테고리 탭이 없다** — 한 목록으로 쭉 나열.
2. **탭하면 바로 담기지 않고 상세가 열린다** — 상세에서 `오늘 운동에 추가`를 눌러야 담긴다.
3. **완료 흔적이 목록에 보인다** — 완료 횟수 · 훈련일자 · 최근 기록.

## 2. 데이터 — 공용 라이브러리

훈련 하나 = `workouts` 1행 + `workout_exercises` N행(기존 구조 그대로, `set_group`/`set_info`로 세트 묶음 표현).

| 컬럼 | 값 | 이유 |
|---|---|---|
| `owner_user_id` | **null** | 공용 — 코치가 한 번 넣으면 전원이 같은 목록을 본다 |
| `default_weekday` | **null** | 요일 자동담기에서 제외 |
| `program_date` | **null** | 날짜 프로그램 자동담기에서 제외 |
| `program_label` | null | 헤더 프로그램 배너에서 제외(`getCurrentProgram`은 라벨 있는 행만 본다) |
| `category` | **`urban`** | 목록 마커 |
| `sort_order` | 목록 정렬 | |

이 네 조건(owner·weekday·date 모두 null) 조합은 현재 DB에 **0행**이라 기존 어떤 조회와도 겹치지 않는다. 자동담기(`pickMissingWorkouts`)는 `defaults.weekday`/`defaults.date`만 대상으로 하므로 urban은 **영원히 자동으로 담기지 않는다** — 사용자가 명시적으로 추가할 때만 들어온다.

데이터는 사용자가 SQL로 넣는다(이 프로젝트의 공용 콘텐츠 운영 방식과 동일). `supabase/seed-urban-training.sql`에 삽입 패턴과 예시 2개를 둔다.

## 3. 담긴 카드는 '개인' 취급

`buildGroups`(`src/app/workout/page.tsx`)가 `owner_user_id === null`로 공용을 판정한다. urban은 owner가 null이라 그대로 두면

- WOD·프로그램과 같은 **공용 묶음**에 렌더되고(추가 운동 섹션 위),
- `WorkoutCard`의 `이 날짜에서 빼기` 버튼이 `isPersonal` 게이트(`WorkoutCard.tsx:279`)에 걸려 **사라진다** — 잘못 담아도 뺄 수 없다.

그래서 판정을 바꾼다: `isShared = owner_user_id === null && category !== 'urban'`. 이를 위해 `getWorkoutLogsWithWorkout`의 조인 select에 `category`를 추가하고 `WorkoutLogJoined.workout`에 필드를 늘린다.

결과: urban 카드는 **"추가 운동" 섹션**에 개인 운동과 함께 뜨고, 빼기 버튼이 살아난다.

## 4. 완료 통계

**단위는 훈련이다. 동작별로 세지 않는다.**

순수 함수 `deriveUrbanStats(rows)` — `src/lib/workout/urban-stats.ts`:

```ts
export interface UrbanLogRow { workoutId: string; date: string; completed: boolean; memo: string | null }
export interface UrbanStat { count: number; dates: string[]; lastDate: string | null; lastMemo: string | null }
export function deriveUrbanStats(rows: UrbanLogRow[]): Record<string, UrbanStat>
```

규칙:

1. 로그를 **(훈련 id, 날짜)** 로 묶는다.
2. 그 묶음의 로그가 **전부 `completed`** 면 그 날짜를 완료일로 친다. 하나라도 미완료면 치지 않는다.
3. `count` = 완료일 수, `dates` = 완료일 **최신순**, `lastDate` = `dates[0]`.
4. `lastMemo` = 가장 최근 완료일 로그들의 `memo` 중 비어있지 않은 것을 순서대로 `' · '` 로 이어붙인 값. 하나도 없으면 `null`.
5. 완료일이 없는 훈련은 결과에 `count: 0, dates: [], lastDate: null, lastMemo: null` 로 들어간다(목록에서 "기록 없음" 표시).

## 5. UI

`+ 내 운동` 버튼 바로 아래에 `+ urban 훈련` 버튼. 누르면 `UrbanTrainingPopup` — 한 팝업 안에서 목록 ↔ 상세를 전환한다(별도 라우트 없음).

**목록**: 카테고리 탭 없이 `sort_order` 순 나열. 각 행은 제목 + 통계 한 줄.
- 완료 이력 있음: `완료 4회 · 최근 10/14`
- 없음: `기록 없음`

**상세**: 뒤로 버튼 + 제목, 동작 목록(그룹 헤더 `set_info`, `동작 × 횟수 — 메모`), 그 아래 완료 이력(`완료 4회` / 훈련일 전체 / `최근 "5라운드 12:30"`), 맨 아래 `오늘 운동에 추가` 버튼.

추가에 성공하면 팝업을 닫고 그날 로그를 갱신한다(`addWorkoutToDate` 재사용 — 중복 방어는 기존 가드가 그대로 적용된다).

목록이 비어 있으면 "등록된 urban 훈련이 없습니다."

## 6. 파일

| 파일 | 역할 | 상태 |
|---|---|---|
| `src/lib/workout/urban-stats.ts` | 로그 → 훈련별 통계. 순수 함수 | 신규 |
| `src/lib/workout/urban-stats.test.ts` | 위 단위 테스트 | 신규 |
| `src/lib/api/urban.ts` | `getUrbanTrainings()` · `getUrbanLogs(userId)` | 신규 |
| `src/components/workout/UrbanTrainingPopup.tsx` | 목록/상세 2단 팝업 | 신규 |
| `src/lib/swr/keys.ts` | `urbanTrainings` · `urbanStats` · `urbanExercises` 키 | 수정 |
| `src/lib/api/workout-logs.ts` | 조인 select에 `category` 추가 | 수정 |
| `src/app/workout/page.tsx` | 버튼 + 팝업 연결, `buildGroups`의 `isShared` 판정 | 수정 |
| `supabase/seed-urban-training.sql` | 삽입 패턴 + 예시 2개 | 신규 |

## 7. 검증

- `deriveUrbanStats` 단위 테스트: 전부 완료만 카운트 / 부분 완료 제외 / 훈련별 분리 / 동작 여러 개여도 1회 / 날짜 최신순 / 메모 이어붙이기·없으면 null / 빈 입력.
- `npm run lint`, `npx tsc --noEmit`, `npm run build`.
- 앱 확인: 버튼 노출 → 목록(빈 상태) → 시드 넣고 목록/상세 → 추가 → "추가 운동" 섹션에 뜨는지 → 빼기 버튼 동작 → 전부 체크 후 팝업 재진입 시 `완료 1회`로 잡히는지.

## 8. 비목표

- 앱 안에서 urban 훈련을 만들거나 수정하는 폼(내 운동과 달리 SQL로만 관리).
- 개인별 urban 훈련(전원 공용 목록 하나).
- 완료율·그래프 등 통계 확장(횟수 · 날짜 · 최근 메모까지만).
- 부분 완료를 별도 집계('시도 횟수' 같은 지표 없음).
