import { describe, it, expect } from 'vitest'
import { deriveProgram, type ProgramRow } from './program-week'

// 제서 예선으로 7/27~8/7이 비고 4주차가 8/10부터 재개되는 실제 일정(주차별 대표 날짜만 추림)
const SCHEDULE: ProgramRow[] = [
  { program_date: '2026-07-06', program_label: 'Strength 8주 · 1주차' },
  { program_date: '2026-07-13', program_label: 'Strength 8주 · 2주차' },
  { program_date: '2026-07-20', program_label: 'Strength 8주 · 3주차' },
  { program_date: '2026-07-24', program_label: 'Strength 8주 · 3주차' },
  { program_date: '2026-08-10', program_label: 'Strength 8주 · 4주차' },
  { program_date: '2026-08-17', program_label: 'Strength 8주 · 5주차' },
  { program_date: '2026-09-11', program_label: 'Strength 8주 · 8주차' },
]

describe('deriveProgram', () => {
  it('갭 기간에는 마지막 진행 세션의 라벨 주차를 유지(날짜 산술이면 5주차로 틀림)', () => {
    expect(deriveProgram(SCHEDULE, '2026-08-05')).toEqual({
      name: 'Strength 8주',
      startDate: '2026-07-06',
      totalWeeks: 8,
      currentWeek: 3,
      status: 'active',
    })
  })

  it('재개일부터 라벨대로 4주차', () => {
    expect(deriveProgram(SCHEDULE, '2026-08-10')?.currentWeek).toBe(4)
  })

  it('시작 전이면 upcoming · 주차 null', () => {
    expect(deriveProgram(SCHEDULE, '2026-07-01')).toMatchObject({ status: 'upcoming', currentWeek: null })
  })

  it('마지막 세션 이후면 done · 주차는 총 주차', () => {
    expect(deriveProgram(SCHEDULE, '2026-09-12')).toMatchObject({ status: 'done', currentWeek: 8 })
  })

  it('라벨이 다른 특별 세션은 종료일 계산에서 제외', () => {
    const rows: ProgramRow[] = [...SCHEDULE, { program_date: '2026-09-30', program_label: 'ZEST 이벤트 · 특별' }]
    expect(deriveProgram(rows, '2026-09-12')).toMatchObject({ status: 'done', name: 'Strength 8주' })
  })

  it('라벨에서 주차를 못 읽으면 currentWeek null', () => {
    const rows: ProgramRow[] = [{ program_date: '2026-07-06', program_label: 'Strength 8주 · 디로드' }]
    expect(deriveProgram(rows, '2026-07-06')).toMatchObject({ currentWeek: null, status: 'active' })
  })

  it('정렬되지 않은 입력도 날짜순으로 판정', () => {
    expect(deriveProgram([...SCHEDULE].reverse(), '2026-08-05')?.currentWeek).toBe(3)
  })

  it('행이 없으면 null', () => {
    expect(deriveProgram([], '2026-08-05')).toBeNull()
  })
})
