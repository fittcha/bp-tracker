# 클라이언트 데이터 캐시 (SWR) 설계

- **작성일**: 2026-06-30
- **상태**: 설계 확정(사용자 승인) → 구현 계획(writing-plans) 예정
- **앱**: ROAD TO FITTER / Road to Rx'd · Next.js 16 + Supabase (client fetch)

## 1. 배경 & 문제

모든 화면이 마운트 시 `useEffect`로 Supabase를 **콜드 조회**한다(캐시 없음). 앱 재실행·탭 전환마다 전부 재요청 → 매번 로딩 스피너, 체감 느림. 특히 운동 탭은 `로그 조회 → 누락 공용 자동담기(insert) → 재조회`로 왕복이 많다. 한국↔Supabase 왕복 지연이 직렬로 쌓인다.

## 2. 목표 / 비목표

**목표**
- 재실행·탭 전환 시 **마지막 데이터 즉시 표시**(localStorage 영속) + 백그라운드 갱신(stale-while-revalidate).
- **쓰기 후 정확한 무효화**: 로그/완료/attempt/PR 변경이 관련 화면에 반영.
- 운동 자동담기 왕복 축소.
- 전 읽기 화면 적용: 홈(캘린더·통계), 헤더(프로그램), 운동(그날 로그), 챌린지, PR(1RM/nRM/Pace), MY(체중·daily-log).

**비목표(YAGNI)**: 오프라인 쓰기 큐, 실시간 구독, RSC/서버 캐시, 무한스크롤/페이지네이션.

## 3. 접근: SWR + localStorage provider

`swr`(경량, stale-while-revalidate 내장) 도입. 전역 `<SWRConfig>`를 `ClientLayout`에 배치.

**전역 옵션**
- `provider`: localStorage 백업 Map 캐시(§5).
- `revalidateOnFocus: true`, `revalidateOnReconnect: true`, `dedupingInterval: 2000`, `keepPreviousData: true`.
- `revalidateIfStale: true`(기본) — 캐시 있어도 마운트 시 백그라운드 갱신.

## 4. 캐시 키 (유저별 네임스페이스, 배열 키)

모든 키 첫 요소 = 리소스명, 이후 파라미터. 유저별 분리를 위해 `uid` 포함.

| 키 | fetcher | 사용처 |
|---|---|---|
| `['home-stats', uid, ym]` | week/month completed counts | 홈 통계 |
| `['cal-dates', uid, gridStart]` | completed+worked dates(42일) | 홈 캘린더 |
| `['program', today]` | `getCurrentProgram(today)` | 헤더 |
| `['day-defaults', uid, ds]` | 요일공용+날짜프로그램 workouts | 운동 |
| `['day-logs', uid, ds]` | `getWorkoutLogsWithWorkout(ds, uid)` | 운동 |
| `['challenges', uid]` | `getActiveChallenges(uid)` | 챌린지·홈위젯 |
| `['personal-workouts', uid]` | `getPersonalWorkouts(uid)` | 운동추가 팝업 |
| `['pr-1rm', uid]` / `['pr-nrm', uid]` / `['pr-pace', uid]` | getAll1RM/NRM/Pace | PR |
| `['daily-log', uid, date]` | `getDailyLog(date, uid)` | MY |
| `['weight-range', uid, start, end]` | 체중 그래프 범위 쿼리 | MY |

## 5. localStorage provider (영속)

```
function makeProvider(uid):
  key = `r2r-swr:${uid}`
  map = new Map(JSON.parse(localStorage[key] ?? '[]'))   // 하이드레이트 → 첫 렌더 즉시
  persist = () => localStorage[key] = JSON.stringify([...map])
  // 모바일 신뢰성: pagehide + visibilitychange(hidden)에 저장 (beforeunload는 모바일 비신뢰)
  addEventListener('pagehide', persist); addEventListener('visibilitychange', () => document.hidden && persist())
  return map
```
- 유저별 네임스페이스(`uid`) — 다른 유저 로그인 시 섞임 방지. **로그아웃 시 해당 키 제거**.
- 용량: 이 앱 데이터 규모 작아 단순 JSON 직렬화로 충분(상한 우려 시 키 prune은 향후).
- provider는 `uid` 확정 후 생성되어야 하므로, SWRConfig를 로그인 사용자 기준으로 구성(비로그인/login 경로는 캐시 불필요).

## 6. 읽기 마이그레이션 (화면별)

각 화면의 `useEffect+useState` 조회를 `useSWR(key, fetcher)`로 교체. 로딩 상태는 `data === undefined && !cached`일 때만 스켈레톤; 캐시 있으면 즉시 데이터. `keepPreviousData`로 날짜/월 이동 시 깜빡임 제거.

- 홈(`page.tsx`): home-stats. `WorkoutCalendar`: cal-dates. `ChallengeWidgets`: challenges.
- 헤더(`Header.tsx`): program.
- 운동(`workout/page.tsx`): day-defaults + day-logs (§8). `AddWorkoutPopup`: personal-workouts.
- 챌린지(`challenge/page.tsx`): challenges.
- PR(`pr/page.tsx`): pr-1rm/nrm/pace. MY(`my/page.tsx`): daily-log + weight-range.

## 7. 쓰기 무효화 (정확성 — 핵심)

변이 후 영향 키를 전역 `mutate`(키 매처 함수)로 재검증. **무효화 지점은 변이를 호출하는 핸들러**(컴포넌트)에서 수행(또는 작은 헬퍼 `revalidate(prefix)`로 중앙화).

매핑:
- 운동 로그 변이 `upsertWorkoutLog`/`addWorkoutToDate`/`deleteWorkoutLogs` → `day-logs`(해당 ds), `cal-dates`(uid), `home-stats`(uid).
- 챌린지 변이 `addAttempt`/`updateAttemptDate`/`deleteAttempt`/`resetChallenge`/`startChallenge`/`deleteChallenge`/`updateChallenge` → `challenges`(uid).
- PR 변이 `upsert1RM`/`upsertNRM`/`deleteNRM`/`upsertPaceRecord`/`deletePaceRecord` → 해당 `pr-*`(uid).
- MY `upsertDailyLog` → `daily-log`(date) + `weight-range`(uid).
- 개인운동 `createPersonalWorkout`/`updatePersonalWorkout`/`archiveWorkout` → `personal-workouts`(uid) + (담긴 날 영향 시 day-logs).

키 매처 헬퍼:
```
revalidate(prefix, ...params) → mutate(key => Array.isArray(key) && key[0]===prefix && params.every((p,i)=>key[i+1]===p))
```
- **완료 토글/무게**(`WorkoutCard`): 현행 낙관적 로컬 반영 유지 + 디바운스 저장 후 `cal-dates`/`home-stats` 무효화(day-logs는 낙관적이라 즉시 mutate 불필요, 단 정합 위해 저장 완료 후 가볍게 revalidate).

## 8. 운동 탭 자동담기 (까다로운 부분)

현재 `loadData`의 `읽기→자동담기(쓰기)→재읽기`를 분리:
- **읽기**: `day-defaults`(useSWR) + `day-logs`(useSWR) → 캐시 즉시 표시.
- **자동담기**: 별도 `useEffect`가 `day-logs`·`day-defaults` 로드 후 실행. 누락 규칙(현행): WOD(요일공용)는 과거 포함 항상, 프로그램 등은 오늘/미래만. 누락분 `addWorkoutToDate` 순차 실행 후 `mutate(['day-logs',uid,ds])`.
- **중복 담기 방지**: `처리한 ds` ref Set 가드 + 진행중 플래그(같은 ds 재진입 차단). SWR 재검증으로 day-logs가 갱신돼도 effect는 ds당 1회만 자동담기.
- 그룹핑/정렬(공용→프로그램, 개인, 레거시)은 `day-logs`+`day-defaults`에서 파생(현행 로직 유지, useMemo).

## 9. 영향 파일

- `package.json` (+ `swr`)
- `src/components/ClientLayout.tsx` (`<SWRConfig>` + provider)
- `src/lib/swr/` (신규: `provider.ts` localStorage provider, `revalidate.ts` 키 매처 헬퍼, `keys.ts` 키 팩토리)
- 읽기 전환: `app/page.tsx`, `components/home/{WorkoutCalendar,ChallengeWidgets}.tsx`, `components/Header.tsx`, `app/workout/page.tsx`, `components/workout/AddWorkoutPopup.tsx`, `app/challenge/page.tsx`, `app/pr/page.tsx`, `app/my/page.tsx`
- 무효화: 위 + `components/workout/WorkoutCard.tsx`, `components/challenge/ChallengeDashboardCard.tsx`, `components/challenge/AddChallengePopup.tsx` 등 변이 호출처
- 로그아웃: `src/lib/auth.ts`(logout 시 `r2r-swr:${uid}` 제거)

## 10. 에러 처리

- SWR `onError`: 캐시/이전 데이터 유지(빈 화면 금지). 기존 `.catch` 폴백은 fetcher 내부 또는 SWR 기본 동작으로 대체.
- fetcher는 throw 시 SWR가 error 상태 — UI는 cached data 우선 표시.

## 11. 테스트 / 검증

- vitest: ① localStorage provider 직렬화/하이드레이트(라운드트립) ② `revalidate` 키 매처(prefix/param 매칭) ③ 운동 자동담기 누락 계산(순수 함수로 추출 시).
- 게이트: `tsc --noEmit` + `npm run lint` + `vitest run`.
- 수동: 모바일에서 재실행/탭전환 즉시표시, 쓰기 후 반영(완료체크→홈 통계, attempt→챌린지), 유저 전환 캐시 격리.

## 12. 롤아웃

전 화면 한 번에(사용자 요청). 단계는 구현 계획에서 태스크로 분할(인프라 → 화면별 읽기 → 무효화 → 운동 자동담기 → PR/MY → 검증).
