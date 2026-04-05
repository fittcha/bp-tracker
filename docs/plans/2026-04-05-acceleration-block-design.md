# Acceleration Block 일일 인증 기능 설계 (5~8주차)

## 배경
5~8주차 Acceleration Block (4/6~5/3) 감량 가속 구간에서 매일 인증 형식에 2가지 항목 추가:
- 식단 인증 (X/Y): 준비된 식사 횟수 / 계획한 식사 타이밍
- 저강도 유산소 (X/2): 주간 누적 체크 횟수 / 2 (주 2회 의무, 45분 이상)

## 1. 식단 횟수 (Daily 페이지)

### UI
- "식단 횟수" 섹션 + 오른쪽 `+추가` 버튼
- 카드/버튼 한 줄 4~5개 크기
- 회색 테두리 (미체크) → 클릭 → 파란 테두리 + 체크 (완료) → 다시 클릭 → 해제
- week_number >= 5 일 때만 노출

### DB
- `meal_slot_configs` 테이블: 설정 이력 관리
  - `id` uuid PK
  - `user_id` uuid FK
  - `effective_date` date — 이 날짜부터 적용
  - `slot_count` int — 식단 슬롯 수
  - `created_at` timestamptz
  - unique(user_id, effective_date)
- `daily_logs`에 컬럼 추가:
  - `meal_completed` int — 체크한 수
  - `meal_total` int — 그 날의 슬롯 수 스냅샷

### 로직
- 날짜 진입 시: `effective_date <= 해당일` 중 가장 최근 config → slot_count 조회 → 카드 N개 렌더링
- `+추가` → 현재 날짜에 새 config INSERT (slot_count + 1), 카드 즉시 추가
- 이전 날짜는 영향 없음 (각 날짜마다 자기 시점의 config 참조)
- 체크/해제 시 meal_completed + meal_total 자동 저장

### 카톡 공유
- `식단 : 3/4` 형식

## 2. 저강도 유산소 (Workout 페이지)

### UI
- 박스와드 위 작은 섹션: 체크 토글 + 메모 입력
- 주간 카운트 UI 표시 없음 (깔끔하게)
- week_number >= 5 일 때만 노출

### DB
- `cardio_logs` 테이블
  - `id` uuid PK
  - `user_id` uuid FK
  - `date` date
  - `completed` boolean default false
  - `memo` text
  - `created_at` timestamptz
  - unique(user_id, date)

### 로직
- 운동 페이지 로드 시: 해당일 cardio_log 조회
- 체크 토글 → upsert cardio_log
- 주간 누적: 해당 주 월~일 범위에서 completed=true count

### 카톡 공유
- `저강도 유산소 : X/2` (해당 주 월~일 누적 자동 계산)

## 3. 표시 조건
- 두 기능 모두 week_number >= 5 일 때만 노출
- 5주차 시작일: 2026-04-06 (월)
