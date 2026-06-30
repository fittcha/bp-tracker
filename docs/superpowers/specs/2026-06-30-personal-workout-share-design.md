# 개인운동 공유 기능 설계

- **작성일**: 2026-06-30
- **상태**: 설계 확정(사용자 승인) → 구현 계획(writing-plans) 예정
- **앱**: ROAD TO FITTER / Road to Rx'd · Next.js 16 + Supabase (client fetch, anon key, RLS allow-all)

## 1. 배경 & 목표

개인운동(라이브러리에 본인이 만든 운동)을 다른 유저에게 보내서 그대로 쓸 수 있게 한다. 보내는 사람이 아이디 검색으로 여러 유저를 골라 공유하고, 받는 사람은 수락/거부로 추가 여부를 결정한다. 보낸 사람은 상대가 응답하기 전까지 공유를 취소할 수 있다.

**비목표(YAGNI)**: 공유 이력/통계, 그룹·전체 공유, 재공유 알림, 공유 댓글, 실시간 푸시. 공유 단위는 **개인운동 1개**(공용·시즌1 운동은 공유 불가).

## 2. 데이터 모델 — `workout_shares` (대기 전용)

```sql
create table workout_shares (
  id               uuid primary key default gen_random_uuid(),
  from_user_id     uuid not null references users(id),
  to_user_id       uuid not null references users(id),
  source_workout_id uuid,              -- 보낸 사람 참조용(취소·대기 목록 그룹핑). 원본 삭제돼도 payload로 수락 가능하므로 nullable, FK 미설정
  payload          jsonb not null,     -- 공유 시점 스냅샷
  created_at       timestamptz not null default now()
);
create index idx_workout_shares_to on workout_shares (to_user_id);
create index idx_workout_shares_from_src on workout_shares (from_user_id, source_workout_id);
```

- **행 존재 = 대기(pending) 상태.** 수락/거부/취소 시 행을 **삭제**한다(상태 컬럼·이력 없음).
- **payload (스냅샷)**: 공유 누르는 순간 원본 운동을 통째로 직렬화.
  ```jsonc
  {
    "title": "가슴 루틴",
    "category": "가슴" | null,
    "exercises": [
      { "section": null, "exercise_name": "Incline DB Press", "reps": "10", "notes": "...",
        "sort_order": 0, "set_group": 1, "set_info": "3 Sets", "set_lead": null },
      ...
    ]
  }
  ```
  스냅샷이므로 공유 후 원본을 수정/삭제해도 받은 건엔 영향 없음.
- **source_workout_id**: 보낸 사람이 "이 운동을 누구에게 대기 중인지" 묶어 보고 취소하는 용도. 수락 로직은 payload만 사용(원본 참조 안 함).
- RLS allow-all (앱 기존 방식, anon 키로 CRUD).

## 3. 보내는 흐름

**진입점**: 운동추가 팝업(`AddWorkoutPopup`) 라이브러리의 각 **개인운동** `⋯` 메뉴에 **'공유'** 항목 추가(수정/숨김 옆). `owner_user_id`가 본인인 개인운동에만 노출. 공용·시즌1 카드엔 없음.

**공유 모달 (`ShareWorkoutModal`)** — 두 구역:
1. **새로 공유**: 아이디 검색창. **빈 문자열이면 결과 0**(전체 조회 금지). 입력 시 `searchUsersByUsername`로 `ilike '%query%'` 결과 노출 — 본인 제외, 비활성(active=false) 제외, 이미 이 운동 대기 중인 유저는 "대기 중"으로 비활성 표시(중복 공유 방지). 결과 행 **왼쪽 체크박스**. 선택한 유저는 아래 **칩 목록**으로 누적(× 로 제거).
2. **공유 대기 중**: 이 운동(`source_workout_id`)으로 보낸 pending 목록. `[username] 대기 중 [취소]`. 취소 = 그 행 삭제.

**공유하기 버튼**: 선택 0명이면 비활성. 클릭 시 선택 유저 수만큼 `shareWorkout`이 `workout_shares` 행 삽입(payload 스냅샷 동일). 이미 같은 (to_user, source_workout_id) pending 행이 있으면 건너뜀.

## 4. 받는 흐름

**앱 로드 시 전역 확인**: `ClientLayout` 레벨(로그인 유저 확정 후)에서 `getPendingShares(uid)` 조회. 대기건이 1개 이상이면 **목록 모달**(`PendingSharesModal`)을 한 번에 표시.

**목록 모달**: `공유 받은 운동 (N)` 헤더 + 행마다 `[보낸사람]님이 '[운동명]' 공유 · 거부 / 수락`.
- **수락** → payload로 `createPersonalWorkout(uid, title, category, exercises)` 호출 + 그 share 행 삭제.
- **거부** → 그 share 행만 삭제.
- 모든 행 처리(또는 닫기)하면 모달 종료. 닫아도 미처리 건은 다음 진입 시 다시 뜸.

## 5. API (`src/lib/api/`)

`users.ts`:
- `searchUsersByUsername(query: string, excludeId: string): Promise<User[]>` — `query.trim()===''`이면 `[]` 즉시 반환. 아니면 `ilike '%query%'` + `active=true` + `id != excludeId`, limit 20, username 순.

`workout-shares.ts` (신규):
- `shareWorkout(fromId: string, sourceWorkoutId: string, toIds: string[]): Promise<void>` — 원본 workout+exercises 조회 → payload 빌드 → 각 toId에 대해 기존 pending 없을 때만 insert.
- `getPendingShares(toId: string): Promise<PendingShare[]>` — to_user 대기건 + from username 조인. `PendingShare = { id, fromUsername, title }`.
- `getSentPendingShares(fromId: string, sourceWorkoutId: string): Promise<SentShare[]>` — 모달 대기 목록용. `SentShare = { id, toUsername }`.
- `acceptShare(shareId: string): Promise<void>` — share 행 읽어(to_user_id + payload) `createPersonalWorkout(to_user_id, ...)` 호출 + 행 삭제. (caller는 mutate용 uid를 이미 보유)
- `rejectShare(shareId: string): Promise<void>` / `cancelShare(shareId: string): Promise<void>` — 행 삭제(동작 동일, 의미 구분 위해 둘 다 노출).

payload 빌더는 순수 함수로 분리: `buildSharePayload(workout, exercises) → SharePayload` (`src/lib/workout/share-payload.ts`).

## 6. SWR / 무효화 (기존 캐시 패턴 사용)

- 키 추가: `k.pendingShares(uid)`. `ClientLayout`/`PendingSharesModal`에서 `useSWR(uid ? k.pendingShares(uid) : null, () => getPendingShares(uid))`.
- 수락/거부 후: `mutate(k.pendingShares(uid))`. 수락은 추가로 `mutate(matchPrefix('personal-workouts', uid))`(라이브러리에 새 운동 반영).
- 공유 모달의 대기 목록은 모달 로컬 상태로 충분(공유/취소 후 재조회). 전역 캐시 불필요.

## 7. 에러 / 엣지

- 빈 검색어 → 결과 0 + "아이디를 입력하세요" 안내. 결과 없음 → "검색 결과 없음".
- 선택 0명 → 공유하기 비활성.
- 수락 시 payload 누락/파싱 실패 → 그 건만 조용히 스킵(행 삭제), 나머지 진행.
- 상대가 이미 수락/거부해 행이 사라진 뒤 취소 시도 → no-op(삭제 0건, 에러 아님).
- 공용/시즌1 운동엔 공유 진입점 없음(개인운동 한정).

## 8. 테스트 (vitest)

순수 함수/가드만(컴포넌트 단위테스트 없음, 앱 관례):
1. `buildSharePayload`: 원본 workout+exercises → payload 직렬화(set_group/set_info/set_lead 보존, id/workout_id 제외).
2. `searchUsersByUsername` 빈쿼리 가드: `''`/공백 → `[]`(쿼리 미발생).
3. 중복 대기 스킵 판정(순수 함수로 추출 시): 기존 pending toId 집합 vs 신규 toIds → 실제 insert 대상.

게이트: `tsc --noEmit` + `eslint` + `vitest run`.

## 9. 영향 파일

- 신규: `supabase/migration-workout-shares.sql`(테이블+인덱스), `src/lib/api/workout-shares.ts`, `src/lib/workout/share-payload.ts`, `src/components/workout/ShareWorkoutModal.tsx`, `src/components/PendingSharesModal.tsx`.
- 수정: `src/lib/api/users.ts`(`searchUsersByUsername`), `src/lib/swr/keys.ts`(`pendingShares`), `src/components/ClientLayout.tsx`(앱 로드 시 대기 확인+모달), `src/components/workout/AddWorkoutPopup.tsx`(라이브러리 ⋯ 메뉴 '공유' + 모달 연결).

## 10. 롤아웃

마이그레이션(`migration-workout-shares.sql`)을 라이브에 1회 적용 후 코드 머지·배포. 기존 데이터 마이그레이션 불필요(신규 테이블).
