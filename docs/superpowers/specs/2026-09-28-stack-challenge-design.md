# 쌓기 챌린지 · 설계

- 날짜: 2026-09-28
- 선행: `docs/superpowers/specs/2026-06-28-challenge-tab-design.md`, `2026-07-09-challenge-set-progress-streak-design.md`

## 1. 목적

기존 푸쉬업·풀업 챌린지는 난이도별로 주차·일차 횟수가 **정해진** 프로그램이다. 여기에 **종목을 직접 정해 개수만 쌓는** 챌린지를 더한다. 목적은 하나 — 누적 개수를 센다.

- 종목은 자유 입력, 그게 곧 제목이다.
- 시작일이 **1일차**. 요일 개념 없이 매일 하루씩 올라간다.
- 숫자는 직접 수정할 수 없고 **±1 / ±5 / ±10 버튼**으로만 움직인다.
- 누적 숫자가 카드 한가운데 가장 크게 놓인다.
- 목표 개수는 **있음/없음을 먼저 고르고**, 있음이면 개수를 입력한다. 목표가 있어도 주인공은 현재 누적 숫자다.

기능은 모든 회원에게 보인다(계정 잠금 없음). 기록은 기존 챌린지와 같이 `user_id`로 묶여 본인만 본다.

## 2. 데이터 — 새 테이블 2개

기존 `challenge_*` 테이블은 건드리지 않는다. 처방(`challenge_program_days`)·훈련 요일·성공/실패(`challenge_attempts`)가 전부 무의미해서, 재사용하면 `derive.ts`의 스트릭·일차 판정까지 흔들린다.

```sql
stack_challenges(
  id, user_id → users, title text, goal_count int null,
  started_at date default current_date,
  status text default 'active' check in ('active','archived'), created_at
)
stack_entries(
  id, stack_challenge_id → stack_challenges on delete cascade,
  delta int not null, done_date date default current_date, created_at
)
```

**누적 = `sum(delta)`이고 버튼 한 번이 행 하나다.** 총합 컬럼 하나로 두면 `total = total + 1`을 PostgREST가 표현하지 못해 read-modify-write가 되고, 연타하면 카운트가 유실된다. INSERT는 경합이 없다. 일자별 합계("오늘 몇 개")도 같은 테이블에서 공짜로 나온다.

합산은 클라이언트가 한다 — 이 Supabase 인스턴스는 집계 함수를 막아놨다(`PGRST123: Use of aggregate functions is not allowed`). 행은 탭 횟수만큼 쌓이지만 `delta`만 받아오면 한 행이 수 바이트다. 훗날 행이 문제가 될 만큼 커지면 일자별 1행으로 합치는 RPC로 바꾸면 된다.

## 3. 파생 — 순수 함수

`src/lib/challenge/stack.ts`:

```ts
export interface StackEntry { delta: number; done_date: string }
export interface StackState { dayNo: number; total: number; todayTotal: number }
export function deriveStack(entries: StackEntry[], startedAt: string, today: string): StackState
```

- `dayNo` = 시작일로부터 경과일 + 1 (시작일이 1일차). 오늘이 시작일보다 앞서면 1로 클램프.
- `total` = 모든 `delta` 합. **0 아래로 내려가지 않는다** — 음수 횟수는 말이 안 되므로 `Math.max(0, sum)`.
- `todayTotal` = `done_date === today`인 항목의 합.

감소 버튼은 화면에서 `total === 0`이면 비활성한다. 저장된 합이 음수가 되는 입력 자체를 API가 막는다(현재 합보다 큰 감소는 현재 합만큼만 기록).

## 4. UI

**생성** — `AddChallengePopup` 1단계 목록에 `쌓기 챌린지`를 추가하고, 고르면 기존 난이도/요일 흐름 대신 전용 한 화면으로 간다.

```
종목명   [ 푸쉬업            ]
목표 설정   ( ) 없음   (•) 있음 → [ 10000 ]
                                   [ 시작 ]
```

종목명이 비면 시작할 수 없다. '있음'인데 개수가 비었거나 0 이하면 시작할 수 없다.

**카드** — `StackChallengeCard`

```
┌──────────────────────────────┐
│ 쌓기 · 푸쉬업              ⋯ │
│ 12일차                        │
│                               │
│           1,240               │
│      / 10,000 ▓▓▓░░░░ 12%     │  ← 목표 있을 때만
│                               │
│  -10  -5  -1  │  +1  +5  +10  │
│  오늘 120개                    │
└──────────────────────────────┘
```

누적 숫자가 카드에서 가장 크다. 목표가 있으면 그 아래 작게 `/ 목표`와 진행바가 붙되 숫자 크기를 넘지 않는다. `⋯` → 그만두기(`status='archived'`, 기록 보존).

버튼을 누르면 낙관적으로 숫자를 먼저 올리고 INSERT를 보낸다. 실패하면 되돌리고 `alert`로 사유를 띄운다 — 이 프로젝트의 챌린지 쓰기 규칙이다(마이그레이션 미적용 같은 실패가 조용히 삼켜지면 원인을 못 찾는다).

## 5. 파일

| 파일 | 역할 | 상태 |
|---|---|---|
| `supabase/migration-stack-challenge.sql` | 테이블 2개 + 인덱스 + RLS | 신규 |
| `src/lib/challenge/stack.ts` | `deriveStack` 순수 함수 | 신규 |
| `src/lib/challenge/stack.test.ts` | 단위 테스트 | 신규 |
| `src/lib/api/stack.ts` | 목록·생성·증감·보관 | 신규 |
| `src/components/challenge/StackChallengeCard.tsx` | 카드 | 신규 |
| `src/components/challenge/AddChallengePopup.tsx` | '쌓기 챌린지' 분기 | 수정 |
| `src/app/challenge/page.tsx` | 기존 카드와 함께 렌더 · 빈 상태 문구 | 수정 |
| `src/lib/swr/keys.ts` | `stackChallenges(uid)` | 수정 |

## 6. 검증

- `deriveStack` 단위 테스트: 시작일=1일차 / 경과일 / 합계 / 0 클램프 / 오늘 합계 / 빈 입력 / 미래 시작일.
- `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
- 수동: 생성(목표 없음/있음) → +1·+10 누적 → -10으로 0까지 → 0에서 감소 비활성 → 날짜 넘어가면 '오늘' 초기화·일차 증가 → 그만두기.

## 7. 비목표

- 숫자 직접 입력·수정(버튼으로만).
- 일자별 기록 화면·그래프(데이터는 남지만 이번엔 안 보여준다).
- 다른 회원의 누적 보기·랭킹.
- 목표 달성 시 자동 완료·알림(달성해도 계속 쌓인다).
- 기존 챌린지의 스트릭·요일 로직과의 연동.
