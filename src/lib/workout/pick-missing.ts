// 자동담기 선별 — 그 날짜에 아직 안 담긴 공용 운동만 고른다. 순수 함수.
//
// 날짜기반 프로그램 카드는 카드 자신의 program_date가 그 날짜와 일치할 때만 담는다.
// localStorage SWR 백업 캐시(lib/swr/provider.ts)가 시프트 이전 목록을 내려줄 수 있어서다 —
// 2026-08-05 제서 예선 2주 시프트 직후 실제로 7/28에 8/11 카드 11행이 담겼다.
// page.tsx의 `defaults.ds !== ds` 가드는 날짜 전환 레이스만 막고 '캐시 낡음'은 못 잡는다.
// 카드 행이 program_date를 이미 들고 오므로, 캐시 무효화에 기대지 않고 여기서 걸러낸다.

export interface DefaultWorkout {
  id: string
  program_date?: string | null   // null·undefined = 요일 공용(WOD), 날짜 검사 없음
}

export function pickMissingWorkouts<T extends DefaultWorkout>(
  all: T[],
  presentIds: ReadonlySet<string>,
  ds: string,
): T[] {
  return all.filter((w) => {
    if (presentIds.has(w.id)) return false
    if (w.program_date != null && w.program_date !== ds) return false
    return true
  })
}
