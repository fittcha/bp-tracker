# 제서 예선 반영 — 8주 프로그램 2주 시프트 · 설계

- 날짜: 2026-08-05
- 대상: 공용 날짜기반 프로그램 `Strength 8주` (2026-07-06 시작, 평일 40세션)
- 선행 설계: `docs/superpowers/specs/2026-06-28-public-workout-date-program-design.md`

## 1. 배경

ZEST SURVIVOR(이하 제서) 예선이 **7/27(월)~8/5(수)** 로 진행돼 이 기간 아무도 추가운동(8주 스트렝스)을 하지 못했다. 예선 완주를 축하하는 의미로 그 기간을 `ZEST SURVIVOR 예선` 카드 한 장으로 대체하고, 8/6~8/7은 스페셜 세션으로 채우고, 남은 프로그램(4~8주차)을 **8/10(월)부터 2주 뒤로** 미룬다. 주차 표기도 콘텐츠와 함께 밀려 8/10이 4주차가 된다.

## 2. 확인된 현황 (라이브 DB 조회, 2026-08-05)

| 사실 | 값 | 근거 |
|---|---|---|
| 7/27 이후 프로그램 카드 | **143행** (4~8주차) | `workouts` where `program_label like 'Strength 8주%'` |
| 7/27~8/7 프로그램 연결 로그 | 148건, **완료 0건** | 자동담기로 깔린 껍데기 |
| 8/8 이후(8/10~8/28) 프로그램 연결 로그 | 88건, **완료 0건** | 미리 넘겨본 사용자의 자동담기 |
| 정리 대상 합계 | **236건 전부 미완료** | → 삭제해도 잃는 기록 없음 |

즉 "다들 추가운동을 안 했을 것"이라는 전제는 데이터로 확인됐다.

발견된 두 가지 제약:

1. **과거 날짜 자동담기 차단** — `workout/page.tsx`의 자동담기는 날짜기반 프로그램을 오늘/미래만 담는다(`isPast` 가드). 과거에 카드를 새로 깔아도 화면에 안 뜨고, 그날 앱을 안 열었으면 뒤늦게 기록할 방법도 없다. 선행 설계에서 "과거 미기록 날짜 일괄 백필"은 **비목표(YAGNI)** 로 적혀 있어 안전장치가 아니라 범위 축소였다.
2. **헤더 주차가 날짜 산술** — `getCurrentProgram`이 `floor((today - startDate)/7)+1`로 주차를 계산한다. 2주 시프트로 날짜와 라벨 사이에 갭이 생기면 8/10에 라벨은 "4주차"인데 헤더는 "6주차"로 뜬다.

## 3. 결정 사항

### 3.1 일정

| 날짜 | 내용 |
|---|---|
| 7/6~7/24 | 1~3주차 (변경 없음) |
| **7/27~7/31, 8/3~8/5 (평일 8일)** | **ZEST SURVIVOR 예선** 1장 |
| **8/6(목), 8/7(금)** | **스페셜 세션** (내용 후속 확정) |
| 8/10~8/14 | 4주차 |
| 8/17~8/21 | 5주차 |
| 8/24~8/28 | 6주차 |
| 8/31~9/4 | 7주차 |
| 9/7~9/11 | 8주차 → 프로그램 종료 |

주말(8/1~8/2)은 예선 카드를 두지 않는다(프로그램은 평일 리듬 유지).

### 3.2 제서 예선 세션

날짜별로 공용 `workouts` 1행 + `workout_exercises` 1행.

- `title`: `ZEST SURVIVOR 예선`, `category`: `측정`, `owner_user_id`: null, `default_weekday`: null, `sort_order`: 0
- `program_label`: **null** — `getCurrentProgram`이 `program_label not null` 행만 프로그램 범위로 보므로, null이면 헤더 배너의 시작·종료·주차 계산을 흔들지 않는다.
- 동작: `exercise_name` `제서 이벤트 측정`, `sets`/`reps`/`notes` **null**, `set_group` 1, `section` null.
  `sets`/`reps`가 null이면 `ExerciseCard`의 메타 줄이 렌더되지 않고, 제목·동작명이 이미 설명적이라 `notes`도 비운다 → 카드가 체크 한 줄로 나온다.

```
┌─ ZEST SURVIVOR 예선 ──────┐
│ ☐  제서 이벤트 측정            │
└─────────────────────────┘
```

기록은 각자 로그의 메모/무게 칸에 자유롭게 남긴다(예선 종목을 앱에서 강제하지 않는다).

### 3.3 데이터 변경 (라이브 SQL, Supabase SQL 에디터 수동 실행)

파일: `supabase/migration-strength-shift-2w.sql`. 순서가 중요하다.

```sql
-- 1) 껍데기 로그 정리: 시프트로 전부 stale이 되는 7/27 이후 프로그램 로그 (미완료만)
delete from workout_logs wl
using workout_exercises we, workouts w
where wl.workout_exercise_id = we.id
  and we.workout_id = w.id
  and w.owner_user_id is null
  and w.program_label like 'Strength 8주%'
  and wl.date >= '2026-07-27'
  and wl.completed = false;                  -- 기대 236행

-- 2) 4~8주차 2주 시프트 (라벨은 콘텐츠에 붙어 함께 이동 → 재작성 불필요)
update workouts
set program_date = program_date + 14
where owner_user_id is null
  and program_label like 'Strength 8주%'
  and program_date >= '2026-07-27';          -- 기대 143행

-- 3) 제서 예선 카드 8일치 삽입 (평일 8일, 날짜당 카드 1장 · 동작 1행)
--    program_label = null → 헤더 프로그램 배너에 영향 없음
with d(program_date) as (values
  ('2026-07-27'::date), ('2026-07-28'), ('2026-07-29'), ('2026-07-30'),
  ('2026-07-31'), ('2026-08-03'), ('2026-08-04'), ('2026-08-05')
), w as (
  insert into workouts (title, owner_user_id, default_weekday, category, program_date, program_label, sort_order)
  select 'ZEST SURVIVOR 예선', null, null, '측정', d.program_date, null, 0 from d
  returning id
)
insert into workout_exercises (workout_id, section, exercise_name, sets, reps, notes, sort_order, set_group, set_info, set_lead)
select w.id, null, '제서 이벤트 측정', null, null, null, 0, 1, null, null from w;
```

`completed = false` 조건은 안전장치다. 실행 결과 행수가 236/143과 다르면 멈추고 원인을 확인한다.

**세 단계 모두 1회성이고 멱등하지 않다 — 재실행 금지.** 2)를 두 번 돌리면 4주가 밀리고, 1)은 시프트 후 정상적으로 쌓인 미완료 로그를 지우고, 3)은 카드를 중복 생성한다. 실행 전 `select count(*) from workouts where owner_user_id is null and program_label = 'Strength 8주 · 8주차' and program_date > '2026-09-01'`로 이미 적용됐는지 확인한다(0이면 미적용).

미완료 로그를 남긴 채 시프트하면 예: 8/24 로그가 9/7로 옮겨간 8주차 카드를 가리키면서 8/24에 그대로 렌더돼, 새로 담기는 6주차와 겹쳐 보인다. 그래서 1)이 2)보다 먼저다.

### 3.4 코드 변경

**(a) 과거 날짜 자동담기 허용** — `src/app/workout/page.tsx`

```diff
- const isPast = ds < toDateString(new Date())
- const weekdayIds = new Set(defaults.weekday.map((w) => w.id))
  const all = [...defaults.weekday, ...defaults.date]
- const missing = all.filter((w) => !present.has(w.id) && (!isPast || weekdayIds.has(w.id)))
+ const missing = all.filter((w) => !present.has(w.id))
```

효과: 과거 날짜를 열면 그날 프로그램 카드가 담긴다. 제서 예선 카드 8일치에 별도 백필 SQL이 필요 없고, 8/6~8/7 스페셜 세션을 뒤늦게 삽입해도 사용자가 그 날짜를 열면 담긴다. 또 그날 앱을 못 열어 놓친 과거 세션을 뒤늦게 기록할 수 있다.

부작용은 **캘린더 표시 없음** — `WorkoutCalendar`가 평일이면 이미 무조건 회색 점을 찍고(`worked.has(ds) || 평일`), 금색 점은 `completed` 기준이라 담기만으로는 변하지 않는다. 남는 비용은 "안 한 과거 날을 열면 미완료 카드가 생성돼 남는다" 뿐이다(지난 2주에 쌓인 게 236행 수준이니 규모는 무해).

**(b) 헤더 주차를 라벨 기준으로** — 순수 함수로 분리해 단위 테스트한다.

- 신규 `src/lib/workout/program-week.ts`: `deriveProgram(rows, today)` — `{program_date, program_label}[]`와 오늘 날짜를 받아 `CurrentProgram`을 반환하는 순수 함수. 기존 `src/lib/workout/build-exercises.ts` + 테스트와 같은 패턴.
- `getCurrentProgram`은 조회만 하고 이 함수에 위임.

규칙:

1. `rows[0].program_label`의 `' · '` 앞부분을 프로그램 이름으로 잡고, **같은 이름으로 시작하는 행만** 범위 계산에 쓴다(다른 라벨을 가진 특별 세션이 시작/종료일을 흔들지 않게).
2. `startDate`/`endDate` = 그 행들의 최소/최대 `program_date`. `totalWeeks` = 이름에서 `(\d+)주` 파싱.
3. `today < startDate` → `upcoming`, `currentWeek` null. `today > endDate` → `done`, `currentWeek` = `totalWeeks`.
4. 진행 중이면 **`program_date <= today`인 마지막 행의 라벨에서 `(\d+)주차`** 를 읽어 `currentWeek`로 쓴다. 날짜 산술을 쓰지 않으므로 갭이 있어도 라벨과 항상 일치한다.
5. 라벨에서 주차를 못 읽으면 `currentWeek` null.

결과: 갭 기간(7/27~8/7)에는 마지막 진행 세션인 7/24 기준 "3주차"가 유지되고, 8/10부터 "4주차"로 넘어간다.

**(c) 주차 null 대응** — `Header.tsx`가 `${program.currentWeek}주차`를 그대로 쓰면 null일 때 "null주차"가 뜬다. `currentWeek != null`일 때만 주차를 붙이고, null이면 `진행 중`으로 표시한다.

### 3.5 시드·문서 동기화

라이브와 시드가 갈라지지 않게 같은 커밋에서 맞춘다.

- `supabase/seed-strength-8week.sql`: `2026-07-27` 이상인 `program_date` 리터럴을 +14일로 치환하고, 제서 예선 카드 8일치 세션을 3주차와 4주차 사이에 추가. 기계적 치환이므로 스크립트로 처리하고 전후 날짜 분포를 비교 검증한다.
- `docs/data/season2-strength-8week-data.md`: 4~8주차 헤더의 날짜 범위 표기 갱신(`## 4주차 — … (8/10 ~ 8/14)` 등), 각 세션 제목의 날짜 갱신, 제서 예선 기간 설명 한 줄 추가.
- `supabase/migration-strength-shift-2w.sql`: 라이브 1회성 적용용. 시드를 처음부터 다시 돌리는 경우엔 필요 없다는 주석을 단다.

## 4. 검증

1. `npm test` — `program-week` 단위 테스트(정상 진행/갭 기간/시작 전/종료 후/라벨 파싱 실패).
2. `npm run lint`, `npx tsc --noEmit`.
3. SQL 실행 후 라이브 조회로 확인:
   - `program_date >= '2026-07-27'` & Strength 라벨 로그 = **0건**
   - 날짜별 카드 수: 8/10~8/14가 4주차, 9/7~9/11이 8주차, 종료일 9/11
   - 7/27~8/5 평일 8일에 `ZEST SURVIVOR 예선` 카드 1장씩, 8/6~8/7은 0장
4. 앱에서: 7/28 열기 → 제서 예선 카드 담김 · 체크 동작. 8/10 열기 → 4주차 콘텐츠. 헤더가 "Strength 8주 · 3주차"(오늘 기준).

## 5. 8/6~8/7 스페셜 세션 (2026-08-05 확정)

예선 직후 이틀. 성격은 **벤치마크 + 어깨·전거근·코어 보조**로 정했다. 회복을 유산소(로잉)로 채우지 않고 코어·견갑 계열로 잡은 이유는, 이 프로그램이 이미 쓰는 어휘(`Serratus Punch (band)`, `Banded Face Pull`, `Pallof Press`, `Plank Shoulder Taps`)로 예선 피로 부위를 직접 다루기 때문이다. 동작명은 전부 기존 시드 표기를 그대로 재사용한다.

벤치마크 배치는 **8/6 Baseline · 8/7 Annie**. Baseline에는 Air Squat 40개가 있어 하지 부하가 있고 Annie는 줄넘기·코어라 하지를 거의 쓰지 않으므로, **8/10(월) 스쿼트 디로드** 직전인 금요일을 비워두는 쪽이 맞다.

카드 메타는 예선 카드와 동일 — `owner_user_id` null, `program_label` **null**(헤더 배너 미포함), `category` `측정`, `sets` 컬럼은 null이고 세트 수는 `set_info`가 운반한다.

### 8/6 (목)

| 카드 (sort_order) | set_info | 동작 | reps | notes |
|---|---|---|---|---|
| `A · Baseline` (0) | `For Time · 1 Round` | Row (Erg) | 500m | |
| | | Air Squat | 40 | |
| | | Sit ups | 30 | |
| | | Push up | 20 | |
| | | Pull up | 10 | |
| `B · 어깨·전거근` (1) | `Superset · 3 Sets` | Serratus Punch (band) | 15 | |
| | | Banded Face Pull | 20 | Rest 1:00 b/w sets |
| `C · 코어` (2) | `3 Sets` | Dead Bug | 10/10 | |
| | | Pallof Press | 12/12 | Rest as needed |

### 8/7 (금)

| 카드 (sort_order) | set_info | 동작 | reps | notes |
|---|---|---|---|---|
| `A · Annie` (0) | `For Time` | Double Under | 50-40-30-20-10 | |
| | | Sit ups | 50-40-30-20-10 | |
| `B · 어깨·전거근` (1) | `Superset · 3 Sets` | Serratus Punch (band) | 15 | |
| | | Rear Delt Fly | 15 | |
| | | Lateral Raises | 15 | Rest 1:00 b/w sets |
| `C · 안정화` (2) | `3 Sets` | Plank Shoulder Taps | 0:45 | Rest as needed |

8/7에는 굴곡 코어를 더 넣지 않는다 — Annie가 이미 Sit ups 150개다. 대신 견갑 안정화만 붙인다.

Baseline은 전 세계 박스에서 첫 측정용으로 널리 쓰이는 관례적 벤치마크, Annie는 공식 Girls 벤치마크다. 둘 다 기록이 남아 나중에 재측정 기준으로 쓸 수 있다.

플레이스홀더 카드를 미리 넣지 않은 판단은 유효했다 — 동작 행을 나중에 교체하면 사용자 로그의 `workout_exercise_id`가 `on delete set null`로 끊겨 시즌1 레거시 카드처럼 렌더된다. 가드 제거(3.4a) 덕분에 지금 삽입해도 해당 날짜를 여는 사용자에게 정상적으로 담긴다.

## 6. 비목표

- 제서 예선 종목·기록을 구조화해 저장(메모로 충분).
- 프로그램 세션 인앱 편집기(계속 SQL 시드로 관리).
- 챌린지(풀업 등) 일정 조정 — 이번 시프트는 추가운동만 대상.
- 과거 미기록 날짜 일괄 백필 SQL(가드 제거로 불필요해짐).
