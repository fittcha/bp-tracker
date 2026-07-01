# 2026 ZEST BP Tracker — PRD

> **2026.06 시즌 전환:** 시즌1(15주 바디프로필, 촬영 06.20 종료) → 시즌2 **ROAD TO FITTER / Road to Rx'd**로 피벗.
> 앱명·URL 변경(https://road-to-rxd.vercel.app), 하단 5탭(홈·운동·챌린지·PR·MY), 네이비+골드 테마.
> **§1~7은 시즌1 기준 기록**이고, **§8이 시즌2 확장 현황**입니다.

## 1. 개요

| 항목 | 내용 |
|------|------|
| **제품명** | 2026 ZEST BP Tracker |
| **목적** | 15주 바디프로필 준비 트래커 (촬영일: 2026.06.20) |
| **스택** | Next.js 16 (App Router) + TypeScript + Tailwind CSS v4 + Supabase |
| **배포** | https://road-to-rxd.vercel.app (Vercel, 시즌2) · (구 bp-tracker-six-kohl 404) |
| **저장소** | https://github.com/fittcha/bp-tracker |
| **프로그램 기간** | 2026.03.09 ~ 2026.06.20 (15주) |

### 1.1 5-Phase 프로그램

| Phase | 주차 | 기간 |
|-------|------|------|
| Reset Block | 1~2주 | 03.09 ~ 03.22 |
| Adaptation Cut | 3~4주 | 03.23 ~ 04.05 |
| Acceleration | 5~8주 | 04.06 ~ 05.03 |
| Cutting Peak | 9~14주 | 05.04 ~ 06.14 |
| Make Up | 15주 | 06.15 ~ 06.20 |

---

## 2. 사용자 & 인증

- **인증 방식**: username + 4자리 PIN (Supabase 자체 인증 X)
- **첫 로그인**: PIN 미설정 시 → PIN 설정 플로우 (입력 → 확인)
- **자동 로그인**: 체크 시 localStorage, 미체크 시 sessionStorage
- **마지막 사용자명 기억**: 다음 로그인 시 자동 입력
- **멀티유저**: `user_id` 컬럼으로 데이터 격리, 운동 템플릿/주차는 공유


---

## 3. 페이지 구성

### 3.1 홈 대시보드 (`/`)
- **D-day 카드**: 촬영일까지 카운트다운
- **주간 진행 바**: 5-Phase 타임라인, 현재 주차 표시
- **오늘 현황 카드**: 운동/기록 상태 (진행전/진행중/완료)
- **주간 요약**: 체중 변화, 평균 칼로리, 평균 수면, 운동 횟수

### 3.2 운동 탭 (`/workout`)
- **날짜 네비게이션**: ←/→ 버튼, date picker, 7일 주간 캘린더(월~일)
- **주차/Phase 표시**: weeks 테이블 기반
- **코치 운동 목록**: section별 그룹 렌더링
  - WOD (박스 와드) → A, B, C... 순서
  - 그룹 헤더: sets, Superset/EMOM/AMRAP/setInfo 라벨
  - 그룹 내 sets 변경 시 회색 디바이더 표시
- **운동 항목별 UI**:
  - 완료 체크박스 (개별 + 그룹 토글)
  - 무게 입력 (lb/kg 토글, ±5 버튼)
  - 메모 (textarea 자동 높이)
  - 운동명 롱프레스(1초) → GIF 모달
- **커스텀 운동 추가**: 사용자 운동 직접 등록
- **운동 이력 검색**: 돋보기 → 전체화면 모달, ILIKE 검색, 전체/완료 필터
- **저강도 유산소** (5주차~): 체크박스 + 메모, 토~일 포함 전체 요일 표시
- **자동 저장**: 500ms 디바운스

### 3.3 기록 탭 (`/daily`)
- **체중**: kg 입력
- **수면**: 취침/기상 시간 → 수면 시간 자동 계산
- **운동 완료**: O/X 토글
- **당/가공식품**: X(없음) 또는 텍스트 입력
- **식단 이미지 OCR**: FatSecret 캡처 → Tesseract.js(kor+eng) → 영양소 자동 추출
  - 영문: Sugar(skip), Fat, Carbs, Prot, Calories
  - 한글: 지방, 탄수, 단백질, 권장(skip), 칼로리
- **영양소**: 칼로리, 탄수, 단백질, 지방 (수동 편집 가능)
- **영양제**: 6항목 체크리스트 (비타민B/D/C, 오메가3, 마그네슘, 유산균)
- **수분**: 250ml × 8컵 (최대 2L), toFixed(2) 표시
- **메모**: 자유 텍스트
- **식단 횟수** (5주차~): 이름 기반 슬롯, effective_date별 디폴트, 체크 토글
- **카톡 공유 텍스트**: 항상 표시, 날짜→수면→운동→식단→당/가공→유산소 순서
- **자동 저장**: 800ms 디바운스
- **탭 전환 시 유산소 카운트 자동 갱신** (visibilitychange)

### 3.4 요약 탭 (`/summary`)
- **주차 선택**: 드롭다운 (1~15주)
- **체중 그래프**:
  - Y축 동적 높이 (1kg당 20px, 최소 180px)
  - 1kg 간격 그리드+라벨
  - 파란색 포인트: 오늘 날짜 기준 (없으면 마지막 데이터)
- **매크로 차트**: 도넛 차트, 칼로리 기여 비율 (C×4 : P×4 : F×9)
- **주간 통계**: 칼로리, 수면, 운동, 당 섭취
- **전체 보기**: 주간 ↔ 전체 기간 토글

### 3.5 관리자 운동 페이지 (`/admin/workout`)
- 주차/요일 선택 → 운동 추가/수정/삭제
- 타 주차 템플릿 복사

---

## 4. 데이터베이스 스키마

### 4.1 테이블

| 테이블 | 용도 | 주요 컬럼 |
|--------|------|-----------|
| `users` | 사용자 | id, username(unique), pin_hash, created_by |
| `weeks` | 15주 메타 | id, week_number(1-15), phase, start_date, end_date |
| `workout_templates` | 코치 운동 | week_id(FK), day_number, section, exercise_name, sets(text), reps, rest_seconds, notes, sort_order |
| `workout_logs` | 운동 기록 | user_id(FK), date, template_id, is_custom, exercise_name, section, completed, weight_lb, weight_unit, memo |
| `daily_logs` | 일일 기록 | user_id, date, weight_kg, sleep_time, wake_time, sleep_hours, workout_done, sugar_processed, total_calories, carbs_g, protein_g, fat_g, food_image_url, supplements, water_liters, memo, meal_completed, meal_total, meal_checked(jsonb) |
| `meal_slot_configs` | 식단 슬롯 | user_id, effective_date, slot_count, slot_names(jsonb) |
| `cardio_logs` | 저강도 유산소 | user_id, date, completed, memo |

### 4.2 유니크 제약조건
- `users.username`
- `weeks.week_number`
- `meal_slot_configs(user_id, effective_date)`
- `cardio_logs(user_id, date)`

---

## 5. 핵심 동작 규칙

### 5.1 운동 데이터
- 매 Day 시작에 WOD 박스 와드 (sort_order=0)
- sort_order: Day 내 연속 (섹션별 리셋 X)
- 같은 section 내 2개+ 운동 → 그룹 렌더링
- 그룹 헤더에 첫 운동의 sets 표시 → 그룹 내 sets 동일 유지
- Superset: 첫 운동 notes에 "Superset" 기입
- setInfo 문자열은 그룹 라벨로 표시 (운동 아래 중복 X)
- "And Then" 패턴: 같은 섹션에 동일 운동명 + 다른 sets → 자동 디바이더

### 5.2 날짜 처리
- 전체 YYYY-MM-DD 문자열 기준
- `toDateString()` (로컬 시간 기반) 사용 필수 — `toISOString()` 사용 금지 (UTC 오프셋 버그)
- 주간 범위: 월요일~일요일 (dayOfWeek===0 → mondayOffset=-6)

### 5.3 자동 저장
- 운동 무게/메모: 500ms 디바운스
- 일일 기록: 800ms 디바운스
- 유산소 메모: 800ms 디바운스

### 5.4 OCR (FatSecret)
- 고정 컬럼 순서 매핑 (위치 기반 X)
- 영문: Sugar(skip) → Fat → Carbs → Prot → Calories
- 한글: 지방 → 탄수 → 단백질 → 권장(skip) → 칼로리

### 5.5 차트
- 매크로 비율: 칼로리 기여도 (C×4 : P×4 : F×9), 그램 비율 X
- 수분: 250ml × 8컵, toFixed(2) 표시
- 체중 Y축: 상한 = 소수점 .5이상 올림+1kg, 미만 올림

---

## 6. 컴포넌트 구조

```
src/
├── app/
│   ├── layout.tsx          # RootLayout
│   ├── page.tsx            # 홈 대시보드
│   ├── login/page.tsx      # 로그인
│   ├── workout/page.tsx    # 운동 탭
│   ├── daily/page.tsx      # 기록 탭
│   ├── summary/page.tsx    # 요약 탭
│   └── admin/workout/page.tsx  # 관리자
├── components/
│   ├── auth/               # AuthGuard, PinInput
│   ├── dashboard/          # DdayCard, WeekProgressBar, TodayStatus, WeeklySummaryCard
│   ├── workout/            # ExerciseSearchModal, ExerciseGifModal, Calculator, CustomExerciseForm
│   ├── daily/              # FoodImageUpload, MacroDonutChart, KakaoShareText
│   ├── summary/            # WeightChart, MacroChart, WeeklyStats, OneRMSection
│   └── layout/             # Header, BottomNav, ClientLayout, AnnouncementPopup
└── lib/
    ├── auth.ts             # 로그인/로그아웃
    ├── supabase.ts         # Supabase 클라이언트
    ├── utils.ts            # 날짜, Phase, D-day 등 유틸
    └── api/                # DB 접근 모듈
        ├── users.ts
        ├── workout-templates.ts
        ├── workout-logs.ts
        ├── daily-logs.ts
        ├── cardio-logs.ts
        ├── meal-slots.ts
        ├── user-1rm.ts
        └── exercise-db.ts
```

---

## 7. 완료된 마일스톤

| 시기 | 내용 |
|------|------|
| 2026.03.08 | v1.0 핵심 기능 + 멀티유저 |
| 2026.03.09 | 버그 수정 (UTC, 운동 상태, OCR, 중복) |
| 2026.03.11 | v1.2 무게 단위(lb/kg), 체중 그래프 UI 개선 |
| 2026.03.22 | 3주차 운동 데이터 입력 |
| 2026.04.01 | 운동 이력 검색, 줄바꿈 지원, 메모 자동높이 |
| 2026.04.05 | Acceleration Block (식단횟수, 저강도유산소, 카톡공유) |
| 2026.04.05 | 5주차 운동 데이터, 체중 그래프 개선 |
| 2026.04.12 | 6주차 운동 데이터, 유산소 주말 표시, 그룹 디바이더 |
| 2026.04.12 | UTC 버그 전면 수정 (유산소 카운트, 체중 그래프, 대시보드) |
| 2026.04.14 | 카톡 텍스트 항상 표시, PRD 문서 작성 |
| 2026.06.26 | **시즌2 피벗 + R2R 리브랜딩** (5탭, 네이비+골드, PR/MY 탭 이식) |
| 2026.06.28 | 챌린지 탭(푸쉬업·풀업), 개인운동 세트그룹 빌더 |
| 2026.06.29 | 공용운동 **날짜 기반 8주 스트렝스 프로그램** |
| 2026.06.30 | **SWR 클라이언트 캐시**(전 화면) + 개인운동 **공유 기능** + '내 운동' 라이브러리 |
| 2026.07.01 | 중복로그 버그 근본수정, 8주 데이터 다듬기, PR 모달 팝업화·HALF/FULL |

---

## 8. 시즌2 확장 — ROAD TO FITTER / Road to Rx'd

> 시즌1(바프) → 시즌2 피벗. 5탭 구조, 네이비(`#1E3A5F`)+골드(`#C0974A`) 테마.
> 스택 동일(Next.js 16 + Supabase). 스펙/계획: `docs/superpowers/specs`·`plans`.

### 8.1 탭 구성 (하단 5탭)
| 탭 | 역할 |
|----|------|
| 홈 | 진행 프로그램(헤더 미니 진행바) · 캘린더(운동/완료 도트) · 통계 · 챌린지 위젯 |
| 운동 | 날짜별 공용(날짜기반 프로그램+요일 WOD) + **내 운동**(개인 라이브러리) 담기 |
| 챌린지 | 제공 챌린지(푸쉬업 6주·풀업 4주), 주차 매트릭스, append-only attempts |
| PR | 1RM · nRM · PACE(러닝/로잉) · WOD(네임드/오픈) 기록 |
| MY | 체중 그래프(기간 아코디언) · daily-log · 로그아웃 |

### 8.2 운동 — 공용(날짜기반) + 내 운동(라이브러리)
- **공용 프로그램**: `workouts.program_date`(날짜 배정) + `program_label`(eyebrow). 섹션 A/B/C/D = 각각 별도 카드. 요일 WOD(박스 와드)는 `default_weekday`로 매일 상단.
- **내 운동**(구 '운동 추가'): 개인운동 라이브러리 — 카테고리 탐색, 세트그룹 빌더 생성/수정, 숨김, **공유**. 카드 탭 = 오늘에 담기(멱등).
- **세트 그룹**: 운동 = `set_group`으로 묶인 그룹 목록, 그룹 헤더 `set_info`, 연결자 `set_lead`(into/텍스트/null).
- **자동담기**: 그날 열면 defaults(공용) 자동 담김 — `defaults.ds` 게이트(off-by-one 방지) + addWorkoutToDate 멱등(중복 방지) + sort_order 정렬.

### 8.3 개인운동 공유 (2026.06.30)
- 라이브러리 `⋯ → 공유` → 아이디 `ilike` 검색·체크박스·골드 칩·"공유 대기 중" 취소.
- 받는 쪽: 앱 로드 시 전역 목록 모달로 **수락**(내 라이브러리 딥카피)/**거부**.
- `workout_shares` 대기전용 테이블(payload 스냅샷 + source_workout_id; 수락/거부/취소=행 삭제). ⚠️ 마이그레이션 `supabase/migration-workout-shares.sql` 라이브 적용 필요.

### 8.4 PR 탭
- **1RM**: 한글 운동명 매칭, 계산기 연동. **nRM**: 2~10RM. **PACE**: 러닝(5K·10K·HALF·FULL, hh:mm:ss) / 로잉(2K·5K, mm:ss), min/km·/500m 자동. **WOD**: 네임드(프리셋+커스텀)·오픈, 스코어타입 For Time/AMRAP/Reps 선택.
- 추가/이력 모달은 중앙 팝업(BottomNav 위, `z-[100]`).

### 8.5 성능 — SWR 클라이언트 캐시 (2026.06.30)
- 전 읽기 화면 `useSWR` + localStorage provider(stale-while-revalidate) + 유저별 격리. 쓰기 후 바운드 `useSWRConfig().mutate(matchPrefix)`로 무효화. 키 팩토리 `src/lib/swr/keys.ts`.

### 8.6 시즌2 신규 테이블
| 테이블 | 용도 | 주요 컬럼 |
|--------|------|-----------|
| `workouts` | 공용/개인 운동 정의 | owner_user_id, default_weekday, program_date, program_label, set_group/set_info/set_lead(exercises) |
| `workout_exercises` | 운동 동작 | workout_id, section, exercise_name, reps, notes, sort_order, set_group, set_info, set_lead |
| `challenge_*` | 챌린지 | templates/programs/program_days/user_challenges/attempts |
| `user_1rm` · `user_nrm_records` · `user_pace_records` · `wod_records` | PR 기록 | — |
| `workout_shares` | 개인운동 공유 대기 | from/to_user_id, source_workout_id, payload(jsonb) |
| `daily_logs`(체중/수면 등 시즌1 유지) | — | — |
