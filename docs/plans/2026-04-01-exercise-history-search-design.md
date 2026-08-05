# 운동 이력 검색 기능 디자인 (완료)

## 개요
운동 이름으로 과거 이력을 검색하여 몇 주차 무슨 요일에 어떤 무게로 수행했는지 확인하는 기능.

## 진입점
- 운동 페이지 상단: `5/7 완료` 텍스트를 왼쪽으로 이동
- 오른쪽에 돋보기 아이콘 배치 (r=6, strokeWidth=2)
- 아이콘 클릭 → 검색 모달 오픈

## 모달 UI
- 반투명 오버레이 (bg-black/50) + 상하좌우 p-3 여백 + rounded-2xl
- 상단: 검색 input (자동 포커스, 돋보기 아이콘 내장) + 닫기(X) 버튼
- 필터: `전체` / `완료` 토글 (디폴트: `완료`)
- ESC 키로 닫기, body scroll lock

## 검색 결과
- 정렬: 날짜 최신순 → 같은 날짜 내 섹션 A→B→C 순 → 생성순
- 카드 형태 (테두리로 감싸기)
- 완료: 일반 카드 (bg-surface, border-border)
- 미완료: 텍스트 + 테두리 모두 연한 회색 (/50 opacity)

### 카드 레이아웃
```
┌─────────────────────────────────┐
│ Week 3 · 3/25(화)               │
│ A. Bench Press  ·  135 lb  ✓   │
│    4x8                          │
│    메모 내용 (있으면)              │
└─────────────────────────────────┘
```

- 1행: 주차 + 날짜(요일) — accent 색상
- 2행: 섹션 + 운동명 + 무게(단위, nowrap) + 완료 체크
- 3행: sets/reps (작은 회색 서브텍스트, 템플릿 조인, rest 제외)
- 4행: 메모 (있으면, italic)

## 데이터 조회
- workout_logs에서 exercise_name ILIKE `%검색어%` + user_id 필터
- weeks 테이블로 주차 매칭 (클라이언트 사이드)
- template_id로 workout_templates 일괄 조회 → sets, reps
- 완료 필터: completed = true (디폴트) 또는 전체

## 기술 사항
- Supabase ILIKE 쿼리 (한글/영문 부분 매칭)
- 검색 디바운스 400ms
- 현재 로그인 유저의 데이터만 조회

## 구현 파일
- `src/lib/api/workout-logs.ts` — searchWorkoutLogs 함수
- `src/components/workout/ExerciseSearchModal.tsx` — 모달 컴포넌트
- `src/app/workout/page.tsx` — 돋보기 아이콘 + 모달 연동
