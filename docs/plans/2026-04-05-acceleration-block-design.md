# Acceleration Block 일일 인증 기능 설계 (5~8주차)

## 배경
5~8주차 Acceleration Block (4/6~5/3) 감량 가속 구간에서 매일 인증 형식에 2가지 항목 추가:
- 식단 인증 (X/Y): 준비된 식사 횟수 / 계획한 식사 타이밍
- 저강도 유산소 (X/2): 주간 누적 체크 횟수 / 2 (주 2회 의무, 45분 이상)

## 구현 완료 (2026-04-05)

## 1. 식단 횟수 (Daily 페이지)

### UI
- "식단 횟수" 섹션 + 오른쪽 `+추가` 버튼
- +추가 → 이름 입력 필드 (아침, 간식, 점심 등 유저가 직접 지정)
- 회색 테두리 (미체크) → 클릭 → 파란색 테두리+글씨 (완료) → 다시 클릭 → 해제
- 롱프레스/우클릭으로 슬롯 삭제
- week_number >= 5 일 때만 노출

### DB
- `meal_slot_configs` 테이블: 설정 이력 관리
  - `id` uuid PK
  - `user_id` uuid FK
  - `effective_date` date — 이 날짜부터 적용
  - `slot_count` int — 식단 슬롯 수
  - `slot_names` jsonb — 슬롯 이름 배열 (["아침", "간식", "점심"])
  - `created_at` timestamptz
  - unique(user_id, effective_date)
- `daily_logs`에 컬럼 추가:
  - `meal_completed` int — 체크한 수
  - `meal_total` int — 그 날의 슬롯 수 스냅샷
  - `meal_checked` jsonb — 체크된 슬롯 이름 배열

### 로직
- 날짜 진입 시: `effective_date <= 해당일` 중 가장 최근 config → slot_names 조회 → 이름별 카드 렌더링
- `+추가` → 이름 입력 → 현재 날짜에 새 config (slot_names 확장)
- 설정은 해당 날짜 이후 디폴트 적용, 이전 날짜 영향 없음
- 체크/해제 시 meal_completed + meal_total + meal_checked 자동 저장

### 카톡 공유
- `식단 : 3/4` 형식 (운동 여부 다음, 당/가공식품 전)

## 2. 저강도 유산소 (Workout 페이지)

### UI
- 진행률(0/7완료) + 검색 바로 위 섹션
- 회색 배경 카드, 체크 토글 + 메모 아이콘
- week_number >= 5, 평일(월~금)만 노출

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
- 메모: 800ms 디바운스 자동 저장
- 주간 누적: 해당 주 월~일 범위에서 completed=true count

### 카톡 공유
- `저강도 유산소 : X/2` (당/가공식품 다음, 맨 마지막)

## 3. 추가 UI 개선
- 영양제/추가 섹션: 아코디언 토글 (기본 접힘, 뱃지 표시)
- 카톡 공유 텍스트 순서: 날짜 → 수면 → 운동 → 식단 → 당/가공 → 유산소

## 4. 표시 조건
- 두 기능 모두 week_number >= 5 일 때만 노출
- 5주차 시작일: 2026-04-06 (월)
