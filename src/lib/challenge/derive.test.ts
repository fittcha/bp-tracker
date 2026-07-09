import { describe, it, expect } from 'vitest'
import { deriveDayStates, computeStreak, monthlyAttemptCount, toggleSet, isDayComplete, computeStreakWithCarry } from './derive'

describe('deriveDayStates', () => {
  it('attempt 없으면 빈 맵', () => {
    expect(deriveDayStates([]).size).toBe(0)
  })
  it('success는 잠금 — fail 순서와 무관하게 success 유지', () => {
    const m = deriveDayStates([
      { id: 'a', day_no: 1, result: 'fail', done_date: '2026-06-01' },
      { id: 'b', day_no: 1, result: 'success', done_date: '2026-06-03' },
      { id: 'c', day_no: 1, result: 'fail', done_date: '2026-06-05' },
    ])
    expect(m.get(1)).toEqual({ day_no: 1, status: 'success', doneDate: '2026-06-03', successAttemptId: 'b' })
  })
  it('fail만 있으면 최신 fail 날짜 보존', () => {
    const m = deriveDayStates([
      { id: 'a', day_no: 2, result: 'fail', done_date: '2026-06-01' },
      { id: 'b', day_no: 2, result: 'fail', done_date: '2026-06-04' },
    ])
    expect(m.get(2)).toEqual({ day_no: 2, status: 'fail', doneDate: '2026-06-04', successAttemptId: null })
  })
  it('success가 먼저 와도 잠금 유지 (이후 fail 무시)', () => {
    const m = deriveDayStates([
      { id: 'b', day_no: 1, result: 'success', done_date: '2026-06-03' },
      { id: 'c', day_no: 1, result: 'fail', done_date: '2026-06-05' },
    ])
    expect(m.get(1)).toEqual({ day_no: 1, status: 'success', doneDate: '2026-06-03', successAttemptId: 'b' })
  })
})

describe('computeStreak (1=월..7=일)', () => {
  const MONFRI = [1, 2, 3, 4, 5]
  it('attempt 없으면 0/끊김', () => {
    expect(computeStreak(MONFRI, [], '2026-06-24')).toEqual({ count: 0, alive: false })
  })
  it('주말을 건너뛰고 연속 유지 (오늘=수, 미출석=살아있음)', () => {
    // 2026-06-18 목, 19 금, 22 월, 23 화 출석 / 24 수(오늘) 미출석
    const dates = ['2026-06-18', '2026-06-19', '2026-06-22', '2026-06-23']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 4, alive: true })
  })
  it('오늘도 출석하면 카운트 포함', () => {
    const dates = ['2026-06-22', '2026-06-23', '2026-06-24']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 3, alive: true })
  })
  it('지나간 훈련일 미출석이면 끊김(회색)', () => {
    // 22 월 출석, 23 화 미출석(지나감), 24 수 오늘
    expect(computeStreak(MONFRI, ['2026-06-22'], '2026-06-24')).toEqual({ count: 0, alive: false })
  })
  it('같은 날 여러 attempt는 1일로 묶임', () => {
    const dates = ['2026-06-23', '2026-06-23', '2026-06-24']
    expect(computeStreak(MONFRI, dates, '2026-06-24')).toEqual({ count: 2, alive: true })
  })
  it('훈련요일이 없으면 0/끊김', () => {
    expect(computeStreak([], ['2026-06-24'], '2026-06-24')).toEqual({ count: 0, alive: false })
  })
  it('오늘이 비훈련요일(토)이어도 평일 연속이 유지됨', () => {
    const dates = ['2026-06-22', '2026-06-23', '2026-06-24', '2026-06-25', '2026-06-26'] // 월~금
    expect(computeStreak(MONFRI, dates, '2026-06-27')).toEqual({ count: 5, alive: true }) // 27=토(비훈련)
  })
})

describe('monthlyAttemptCount', () => {
  it('해당 월 attempt 수(중복 날짜도 각각 카운트)', () => {
    const dates = ['2026-06-01', '2026-06-01', '2026-06-30', '2026-05-31', '2026-07-01']
    expect(monthlyAttemptCount(dates, '2026-06')).toBe(3)
  })
})

describe('toggleSet', () => {
  it('없으면 추가(정렬)', () => { expect(toggleSet([2, 0], 1)).toEqual([0, 1, 2]) })
  it('있으면 제거', () => { expect(toggleSet([0, 1, 2], 1)).toEqual([0, 2]) })
})

describe('isDayComplete', () => {
  it('모든 인덱스 채우면 true', () => { expect(isDayComplete([0, 1, 2], 3)).toBe(true) })
  it('일부면 false', () => { expect(isDayComplete([0, 2], 3)).toBe(false) })
  it('범위밖/중복 무시', () => { expect(isDayComplete([0, 0, 5], 3)).toBe(false) })
  it('total 0이면 false', () => { expect(isDayComplete([], 0)).toBe(false) })
})

describe('computeStreakWithCarry', () => {
  // 훈련요일 월(1)·수(3)·금(5)
  const wd = [1, 3, 5]
  it('시작일까지 무결 → carried 합산', () => {
    // 2026-07-06(월)~08(수)~10(금) 다 출석, 오늘 금, 시작 07-06, carried 12
    const r = computeStreakWithCarry(wd, ['2026-07-06', '2026-07-08', '2026-07-10'], '2026-07-10', '2026-07-06', 12)
    expect(r.count).toBe(15) // 3 + 12
  })
  it('중간 끊기면 carried 미포함', () => {
    // 07-08(수) 빠짐, 07-10만 출석, 오늘 금
    const r = computeStreakWithCarry(wd, ['2026-07-10'], '2026-07-10', '2026-07-06', 12)
    expect(r.count).toBe(1) // 금 1개, 수 미출석에서 끊김
  })
  it('기록 0 + 갓 시작 → carried 표시', () => {
    // 오늘=시작일 월, 아직 출석 전, carried 12
    const r = computeStreakWithCarry(wd, [], '2026-07-06', '2026-07-06', 12)
    expect(r.count).toBe(12)
    expect(r.alive).toBe(true)
  })
  it('carried 0이면 기존 스트릭과 동일(합산 없음)', () => {
    const r = computeStreakWithCarry(wd, ['2026-07-06', '2026-07-08'], '2026-07-08', '2026-07-06', 0)
    expect(r.count).toBe(2)
  })
})
