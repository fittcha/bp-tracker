# 2026-06-30~07-01 작업 정리 — 개인운동 공유 · '내 운동' 리브랜딩 · 중복버그 · PR 모달

> 전부 `main` 머지·`origin` 푸시·Vercel 자동 배포 완료. 배포: https://road-to-rxd.vercel.app
> 핵심 커밋: 공유 SDD `2b62929`, 데이터/버그 후속 `429e307`·`cb09b18`·`0a5038f`, PR 모달 `7c16b27`·`cb11c2a`·`c661934`·`cbace05`·`72e1eaf`

## 1. 개인운동 공유 기능 (SDD 5태스크)
- brainstorming→writing-plans→SDD→최종 opus 리뷰(READY TO MERGE)→finishing 머지.
- **모델**: `workout_shares` 대기전용 테이블(payload 스냅샷 + source_workout_id, 수락/거부/취소=행 삭제).
- **보내기**: 라이브러리 `⋯ → 공유` → 아이디 `ilike` 검색(빈쿼리 0건)·체크박스·골드 칩·"공유 대기 중" 취소.
- **받기**: 앱 로드 시 전역 목록 모달(ClientLayout 내 SWRConfig)로 수락(딥카피)/거부.
- API `workout-shares.ts`, `searchUsersByUsername`, 순수헬퍼 `share-payload.ts`(+vitest), 키 `k.pendingShares`.
- 스펙 `2026-06-30-personal-workout-share-design.md`, 계획 동일 날짜 plans.
- ⚠️ **`supabase/migration-workout-shares.sql` 라이브 1회 적용 필요**(미적용=공유 송수신 불가, 앱은 정상).

## 2. '운동 추가' → '내 운동' 리네이밍 + 디자인 검수
- 팝업이 사실상 라이브러리(탐색/생성/수정/공유/숨김+담기)라 명칭 정리. 버튼·제목 '내 운동', 헤더 "탭하면 오늘 운동에 담겨요".
- frontend-design 검수: 카드 균일높이(min-h-72)+카테고리 navy칩+"담는중" 골드, focus-visible 전반, ⋯메뉴 숨김 구분선, 빈상태 CTA, 팝업 높이 68vh, 운동카드 셀 상하 여백 축소.

## 3. 중복 로그 버그 — 근본 수정 (중요)
- **증상**: 운동이 두 개씩 중복, WOD가 맨 아래 하나 더, 날짜 밀림(off-by-one).
- **원인 3종**:
  1. 자동담기가 stale 캐시(이전 세션 빈/부분 day-logs)로 present 계산 → 이미 있는 걸 재담기.
  2. `keepPreviousData`로 날짜 전환 중 defaults가 이전 날짜 값 유지 → 전날 프로그램이 다음 날짜에.
  3. `getWorkoutLogsWithWorkout` 정렬 없음 → 카드 내 동작 순서 뒤섞임(페어 Rest 위치 어긋남).
  4. WOD 요일 불일치(다른 요일 WOD 섞임) — dedup이 틀린 걸 남겨 재발.
- **수정**: `addWorkoutToDate` 멱등화(DB 존재 확인 후 담기) + `defaults.ds===ds` 게이트 + 조회를 `workout_exercises.sort_order`로 정렬 + WOD를 날짜 요일과 매칭되는 것만 남기고 정리(REST). 기존 중복 전부 dedup.

## 4. 8주 스트렝스 데이터 다듬기 (시드 + 라이브 동일)
- 'N개 남기기' 전부 삭제(RPE 변환 안 함 — 표준 RPE=10−남기는개수라 직관과 반대).
- OHP '그 주 강도' → %(7/16 @77.5%, 8/13 @87.5%; 그 주 메인과 동일).
- 보조(B)·안정화(C)·코어(D) 2개 페어는 앞 동작 'Rest as needed' 삭제(뒤만 유지 = 슈퍼셋 rest는 페어 끝에).
- 데이터 문서 `docs/data/season2-strength-8week-data.md` 동기화.

## 5. PR 탭 모달 개선
- nRM/PACE/WOD 추가·이력 모달 **하단시트→중앙 팝업**(z-50=BottomNav와 겹쳐 잘리던 것 해결, z-[100]·중앙·max-h-85vh).
- 입력칸 `min-w-0`(flex/grid 내 number/date 오버플로우 잘림), iOS `type=date` `appearance-none`(네이티브 내재폭 오버플로우).
- **PACE**: 러닝에 HALF(21.0975km)/FULL(42.195km) 추가, 러닝 총시간 hh:mm:ss(로잉 mm:ss). 거리→km 맵 `PACE_DISTANCE_KM` 공유.
- **네임드 WOD**: 기록 시 스코어타입(For Time/AMRAP/Reps) 선택 가능.

## 잔여
- `migration-workout-shares.sql` 라이브 적용(공유 활성화).
