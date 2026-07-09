# Worklog — 2026.07.02~09

프로필 사진 · 8주 스트렝스 프로그램 v2 · 챌린지 세트진행/스트릭 보호. 전부 main 머지 + origin push(배포 완료). ⚠️ 일부 라이브 마이그레이션 PENDING(맨 아래).

## 1. 유저 프로필 사진(아바타) — SDD 6태스크 + 헤더 후속 (main `eaf63af`)
- `users.avatar_url` + Storage 공용 버킷 `avatars`(`migration-user-avatar.sql`).
- MY 탭: 파일 선택 → react-easy-crop 수동 정사각 크롭 → 256px JPEG(경로 timestamp=캐시버스트) 업로드. `uploadAvatar`/`updateAvatarUrl`/`getUserProfile`.
- 공용 `Avatar` 컴포넌트(`getInitial` 이니셜 폴백, vitest). 표시: MY(64)·헤더(26)·공유 검색(28)/받기(36)/대기(24).
- 본인 아바타 `k.profile(uid)` SWR(AuthUser엔 안 넣음, 변경 시 바운드 mutate로 헤더·MY 동기화). 다른 유저는 공유 쿼리 select에 `avatar_url` 추가.
- **후속**: 헤더 우측 아이디 텍스트 제거 → 아바타만.
- **크롭 배경색**(`313d1b0`): JPEG 무알파 → 투명 PNG가 검정 배경 되는 문제. canvas를 bgColor로 먼저 채우고 그림. 크롭 모달에 배경색 스와치(흰/크림/라이트/네이비) + 커스텀 컬러픽커, 미리보기 동기화.

## 2. 공용 8주 스트렝스 프로그램 다양화 v2 (main `964ac0b` 외)
세 메인리프트 판박이 선형 → 리프트별 방식 다양화 + 볼륨 차등(회복여력 벤치>스쿼트>데드). seed 파일 수정 + 라이브 REST 반영 + 옛 로그 스냅샷 삭제(재스냅샷).
- **스쿼트(월)**: W1 6×5@75%+백오프 · W2 정지 6×5@72.5% · W3 컨트라스트 4×(7+3) · W5 웨이브 76/82/88% · W6 클러스터 1·1·1@87.5%.
- **데드(수)**: W1 5×4 · W2 스피드 3@70%×8 · W3 5×5@80% · W5 서브맥스 웨이브(탑85%) · W6 클러스터. (전신피로 배려로 novelty 최소.) 보조 = **DB RDL 계열 격주**(후면사슬) + 로우/페이스풀 순환.
- **벤치(금)**: W1 5×8@70%+백오프 · W2 정지 6×5+백오프 · W3 컨트라스트 4×(8+3) · W5 웨이브+백오프2세트 · W6 컨트라스트 5×(8+3). (볼륨 여력 커서 최다.)
- 공통: 디로드(W4)·피크(W7 2@90%)·테스트(W8 Heavy Single) 저볼륨 유지, 헤비% 82.5→85→87.5→90 단조증가. 보조 B 전요일 4세트·C 3세트. 화(밀기) 피니셔 어깨/삼두로 통일(윗몸/로우 제거). 백오프 @65%→**@50%**(=본세트의 ~65%, 진짜 백오프).
- 커밋: `8b420cd`(7/7 피니셔) · `ed7edf9`(피니셔4·코어4→3) · `56f9c24`(수 RDL) · `6177bc6`(백오프50%) · `1f54bfa`(벤치 5×8) · `5c90086`(벤치 W2·W5) · `60b5287`(스쿼트 6세트).
- **교훈(중요)**: 공용 프로그램 `workout_exercises` 수정해도 **이미 열어본 날짜의 `workout_logs` 스냅샷은 안 바뀜** → 해당 날짜·섹션 로그 삭제해야 앱이 새로 스냅샷. `feedback_bp_workout_data` #15.

## 3. 챌린지 세트별 진행 + 완료/스트릭 보호 — SDD 6태스크 + 최종픽스 (main `29f40a1`)
- **세트 진행**: DayStatusSheet 세트칩=토글(`challenge_day_progress.done_sets` jsonb). 모든 세트→자동 성공+칩 잠금. "잠금 해제"(성공만 취소·진행 보존)/"기록 삭제"(둘 다 초기화). 부분 진행 서버 보존·카드 미표시. 기존 성공/실패 버튼 유지.
- **완료/스트릭**: "완료"=아카이브(`status=archived`+`completed_at`+`final_streak`, attempts 보존). 같은 종목 7일 내 재시작 시 `carried_streak` 이어받기. `computeStreakWithCarry`(시작일까지 무결하면 carried 합산·끊기면 제외·완료~시작 갭 면제). 안내문구 3곳. 홈 위젯도 동일 함수(최종리뷰 I1 픽스) + progress writer MISSING 가드(M1).
- 43 vitest green. 스펙/계획: `docs/superpowers/specs`·`plans` 2026-07-09.

## ⚠️ 라이브 마이그레이션 PENDING (배포됐으나 DB 미적용)
Supabase SQL 에디터서 1회 실행 필요(미적용 시 앱은 폴백 정상):
- `supabase/migration-workout-shares.sql`(공유) · `supabase/migration-user-avatar.sql`(아바타) · `supabase/migration-challenge-progress.sql`(챌린지 세트진행/완료)
