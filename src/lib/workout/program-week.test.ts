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

  // 2026-09-14부터 Urban Wave 6주가 시작되며 프로그램이 둘이 됐다.
  // 예전엔 '가장 이른 프로그램'을 골라 끝난 8주짜리가 배너를 계속 차지했다.
  describe('프로그램이 여럿일 때', () => {
    const UW: ProgramRow[] = [
      { program_date: '2026-09-14', program_label: 'Urban Wave 6주 · 1주차' },
      { program_date: '2026-09-21', program_label: 'Urban Wave 6주 · 2주차' },
      { program_date: '2026-10-23', program_label: 'Urban Wave 6주 · 6주차' },
    ]
    const BOTH = [...SCHEDULE, ...UW]

    it('오늘이 속한 프로그램을 고른다', () => {
      expect(deriveProgram(BOTH, '2026-09-21')).toMatchObject({
        name: 'Urban Wave 6주', totalWeeks: 6, currentWeek: 2, status: 'active',
      })
    })

    it('끝난 프로그램이 배너를 차지하지 않는다', () => {
      expect(deriveProgram(BOTH, '2026-08-05')).toMatchObject({ name: 'Strength 8주', currentWeek: 3 })
    })

    it('프로그램 사이 공백이면 다음에 시작할 쪽을 보여준다', () => {
      expect(deriveProgram(BOTH, '2026-09-12')).toMatchObject({
        name: 'Urban Wave 6주', status: 'upcoming', startDate: '2026-09-14', currentWeek: null,
      })
    })

    it('전부 끝났으면 가장 최근에 끝난 쪽', () => {
      expect(deriveProgram(BOTH, '2026-11-01')).toMatchObject({
        name: 'Urban Wave 6주', status: 'done', currentWeek: 6,
      })
    })

    it('주차 수가 없는 일회성 라벨은 후보에서 제외한다', () => {
      const rows = [...SCHEDULE, { program_date: '2026-09-30', program_label: 'ZEST 이벤트 · 특별' }]
      expect(deriveProgram(rows, '2026-09-12')).toMatchObject({ name: 'Strength 8주', status: 'done' })
    })
  })
})
