# Worklog — 2026.08.05

제서(ZEST SURVIVOR) 예선 반영: 8주 스트렝스 프로그램 2주 시프트 · 8/6~8/7 스페셜 세션 · 캐시 낡음 오염 수정. 전부 main push + 라이브 SQL 적용 완료(PENDING 없음).

설계 `docs/superpowers/specs/2026-08-05-zest-qualifier-2week-shift-design.md` / 계획 `docs/superpowers/plans/2026-08-05-zest-qualifier-2week-shift.md`.

## 1. 예선 기간 대체 + 4~8주차 2주 시프트 (라이브 적용 완료)

예선이 7/27(월)~8/5(수)로 진행돼 그 기간 추가운동을 아무도 하지 못했다. 라이브 조회로 확인: 7/27 이후 프로그램 연결 로그 **236건 전부 미완료**(자동담기로 깔린 껍데기) → 정리해도 잃는 기록 없음.

- **7/27~8/5 평일 8일** = `ZEST SURVIVOR 예선` 카드 1장(동작 `제서 이벤트 측정`). `program_label` **null** → 헤더 프로그램 배너에서 제외(`getCurrentProgram`이 라벨 있는 행만 범위로 봄), `category = 측정`.
- **4~8주차 = `program_date + 14`** (8/10 재개, 종료 8/28 → **9/11**). 라벨이 콘텐츠에 붙어 함께 이동하므로 `program_label` 재작성 불필요 — 8/10이 자동으로 4주차가 된다.
- 실행 순서가 중요: **껍데기 로그 정리 → 시프트**. 반대로 하면 8/24 로그가 9/7로 옮겨간 8주차 카드를 가리킨 채 8/24에 렌더돼 새 6주차와 겹친다.
- `supabase/migration-strength-shift-2w.sql`(1회성, 멱등 아님 — 사전 점검 쿼리 내장). 결과: 삭제 236행 / 업데이트 143행 / 삽입 8장. 사후 `stale_logs = 0`, 총 카드 179 = 3주차 28 + 시프트 143 + 예선 8.
- 시드·데이터 문서 동기화: 날짜 리터럴 143개 + **세션 주석 25줄**(처음에 놓쳐서 카드 날짜와 어긋났다) + wipe 범위 종료일 9/11. 40세션 전부 주석↔카드 날짜 일치 검사, 문서↔시드 날짜 교차검증 통과.
- 커밋: `88dc486`·`5e8d70d`(스펙) · `52f7a37`(계획) · `89c5ab5`(마이그레이션) · `cb89509`(시드) · `82ee6ab`(데이터 문서).

## 2. 코드 2건 (main `600b25a`, `23feba9`)

- **헤더 주차를 날짜 산술 → 라벨 기준으로**: `getCurrentProgram`이 `floor((today-start)/7)+1`로 세던 것을, `program_date <= today`인 마지막 세션 라벨의 `N주차`를 읽게 바꿨다. 시프트로 날짜와 주차 사이에 갭이 생기면 날짜 산술은 8/10에 "6주차"라고 틀린다. 순수 함수 `src/lib/workout/program-week.ts` `deriveProgram()`으로 분리 + vitest 8개. 같은 이름(`' · '` 앞부분)으로 시작하는 행만 범위 계산에 써서 라벨 다른 특별 세션이 시작/종료일을 흔들지 않게 했다. 주차를 못 읽으면 `currentWeek = null` → `Header.tsx`가 "진행 중"으로 표시.
- **과거 날짜 자동담기 허용**: 날짜기반 프로그램을 오늘/미래만 담던 `isPast` 가드 제거. 과거에 카드를 깔아도 안 보이고, 그날 앱을 안 열었으면 뒤늦게 기록할 방법도 없던 제약이었다(선행 설계에선 안전장치가 아니라 YAGNI 비목표였음). 캘린더는 평일이면 이미 무조건 회색 점(`worked.has(ds) || 평일`)이라 표시 영향 없음.

## 3. 8/6~8/7 스페셜 세션 (main `bce7444`, `1f1e08d`, 라이브 적용 완료)

예선 직후 이틀. **벤치마크 + 어깨·전거근·코어 보조**, 카드 3장씩. 회복을 유산소가 아니라 기존 프로그램 어휘(`Serratus Punch (band)`, `Banded Face Pull`, `Pallof Press`, `Plank Shoulder Taps`)로 구성.

- **8/6(목) Baseline** — `Row (Erg) 500m → Air Squat 40 → Sit ups 30 → Push up 20 → Pull up 10` (For Time · 1 Round) + `B · 어깨·전거근` + `C · 코어`.
- **8/7(금) Annie** — `Double Under / Sit ups 50-40-30-20-10` (For Time) + `B · 어깨·전거근` + `C · 안정화`. Annie가 Sit ups 150개라 굴곡 코어를 더 넣지 않고 견갑 안정화만.
- 배치 근거: Baseline엔 Air Squat 40개가 있어 하지 부하가 있고 Annie는 줄넘기·코어라 하지를 거의 안 쓴다 → **8/10(월) 스쿼트 디로드** 직전인 금요일을 비웠다.
- 플레이스홀더 카드는 넣지 않았다 — 나중에 동작 행을 교체하면 유저 로그 `workout_exercise_id`가 `on delete set null`로 끊겨 시즌1 레거시 카드처럼 렌더된다. §2의 가드 제거 덕분에 내용 확정 후 삽입해도 정상 담긴다.
- `supabase/migration-strength-special-0806.sql`. 라이브 검증: 카드 6장·동작 15행, 라벨 전부 null.

## 4. 사고 — 낡은 localStorage 캐시가 옛 카드를 되살렸다 (main `a9f6010`)

배포 직후 예선 기간(7/28·7/31)에 **8주 프로그램 카드가 다시 나타났다**. 마이그레이션 직후엔 `stale_logs = 0`이었는데 재발.

**원인**: `localStorage` SWR 백업 캐시(`src/lib/swr/provider.ts`, 키 `r2r-swr:<uid>`)에 **시프트 이전** `dayDefaults(uid, '2026-07-28')`(= 지금 8/11인 카드 목록)이 남아 있었고, 과거 자동담기 가드를 푼 상태에서 그 날짜를 열자 자동담기가 그 캐시를 그대로 믿고 담았다. 예전에 열어본 날짜만 캐시에 있으므로 **7/28·7/31만** 오염(11행, 전부 미완료, 생성 시각이 예선 카드 담기와 같은 버스트). `page.tsx`의 `defaults.ds !== ds` 가드는 **날짜 전환 레이스만** 막고 '캐시 낡음'은 못 잡는다.

**수정**:
- 자동담기 선별을 순수 함수 `src/lib/workout/pick-missing.ts` `pickMissingWorkouts(all, presentIds, ds)`로 분리. 카드 행이 이미 들고 오는 `program_date`가 `ds`와 다르면 담지 않는다(요일 WOD는 `program_date` null이라 통과). 캐시 무효화에 기대지 않는 구조적 방어. vitest 6개 — 이 사고를 재현한 회귀 테스트 포함.
- `supabase/migration-fix-program-log-date-mismatch.sql`: 불변식 **`wl.date = w.program_date`** 기준 점검 + 미완료만 삭제. 기준일·라벨 같은 상수가 없어 **다음 시프트에도 재사용 가능**. 라이브 11행 삭제 완료, 재조회 0.

**교훈**: 프로그램 일정을 옮긴 뒤에는 이 점검 쿼리를 반드시 돌린다. 클라이언트 캐시 때문에 정리 직후 0이어도 며칠 안에 되살아날 수 있다.

**재발 1회 더 (8/3, 11행)**: 픽스 푸시(≈08:12 UTC) 이후인 `08:20:12`에 8/3에서 또 발생. 카드 날짜가 8/17(옛 5주차 월)이었다. 원인은 픽스 실패가 아니라 **클라이언트가 아직 옛 번들로 돌고 있었기 때문** — `pickMissingWorkouts`는 브라우저가 새 JS를 받은 뒤에야 동작한다. 11행 삭제, 어긋남 0. 즉 배포 후에도 각 사용자가 앱을 새로 로드하기 전까지는 같은 오염이 생길 수 있으니, 며칠 뒤 점검 쿼리를 한 번 더 돌리는 게 안전하다.

## 5. 최종 상태

| 기간 | 내용 |
|---|---|
| 7/6~7/24 | 1~3주차 (변경 없음) |
| 7/27~8/5 (평일 8일) | `ZEST SURVIVOR 예선` 1장 |
| 8/6 · 8/7 | Baseline · Annie + 어깨·전거근·코어 |
| 8/10~9/11 | 4~8주차 (8/10 = 4주차, 종료 9/11) |

vitest 57개 green(신규 14: `deriveProgram` 8 · `pickMissingWorkouts` 6). lint는 작업 전 기준선과 동일(기존 `AuthGuard.tsx` set-state-in-effect 등 9건, 신규 0).

**남은 불일치(이번 범위 밖)**: `docs/data/season2-strength-8week-data.md`의 4~8주차 표는 2026-07-16 고립/보조 보강이 빠진 옛 구조다(시드·라이브엔 반영됨). 날짜 표기만 이번에 맞췄다.
