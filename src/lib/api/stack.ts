import { supabase } from '@/lib/supabase'
import type { StackEntry } from '@/lib/challenge/stack'

// 쌓기 챌린지 API. 누적은 stack_entries의 delta 합이고, 버튼 한 번이 행 하나다.
// 설계: docs/superpowers/specs/2026-09-28-stack-challenge-design.md

export interface StackChallenge {
  id: string
  user_id: string
  title: string
  goal_count: number | null
  started_at: string
  status: 'active' | 'archived'
  created_at?: string
}

export interface StackChallengeWithEntries {
  challenge: StackChallenge
  entries: StackEntry[]
}

// 진행 중인 쌓기 챌린지 + 각 항목의 증감 기록. 합산은 deriveStack이 한다
// (이 인스턴스는 PostgREST 집계가 막혀 있어 delta만 받아와 클라이언트에서 더한다).
export async function getStackChallenges(userId: string): Promise<StackChallengeWithEntries[]> {
  const { data: cs, error } = await supabase
    .from('stack_challenges')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'active')
    .order('created_at', { ascending: true })
  if (error) throw error
  const challenges = (cs ?? []) as StackChallenge[]
  if (challenges.length === 0) return []

  const { data: es, error: ee } = await supabase
    .from('stack_entries')
    .select('stack_challenge_id, delta, done_date')
    .in('stack_challenge_id', challenges.map((c) => c.id))
  if (ee) throw ee
  const rows = (es ?? []) as { stack_challenge_id: string; delta: number; done_date: string }[]

  const byChallenge = new Map<string, StackEntry[]>()
  for (const r of rows) {
    const arr = byChallenge.get(r.stack_challenge_id)
    const entry = { delta: r.delta, done_date: r.done_date }
    if (arr) arr.push(entry)
    else byChallenge.set(r.stack_challenge_id, [entry])
  }
  return challenges.map((c) => ({ challenge: c, entries: byChallenge.get(c.id) ?? [] }))
}

export async function startStackChallenge(params: {
  userId: string
  title: string
  goalCount: number | null
  startedAt: string
}): Promise<StackChallenge> {
  const { data, error } = await supabase
    .from('stack_challenges')
    .insert({
      user_id: params.userId,
      title: params.title,
      goal_count: params.goalCount,
      started_at: params.startedAt,
    })
    .select()
    .single()
  if (error) throw error
  return data as StackChallenge
}

// 증감 1건 기록. 감소가 현재 합보다 크면 현재 합만큼만 빼 0 아래로 내려가지 않게 한다.
export async function addStackEntry(
  challengeId: string,
  delta: number,
  currentTotal: number,
  doneDate: string,
): Promise<void> {
  const applied = delta < 0 ? -Math.min(currentTotal, -delta) : delta
  if (applied === 0) return
  const { error } = await supabase
    .from('stack_entries')
    .insert({ stack_challenge_id: challengeId, delta: applied, done_date: doneDate })
  if (error) throw error
}

export async function archiveStackChallenge(challengeId: string): Promise<void> {
  const { error } = await supabase
    .from('stack_challenges')
    .update({ status: 'archived' })
    .eq('id', challengeId)
  if (error) throw error
}

// 종목명·목표 수정. 누적(stack_entries)과 시작일은 건드리지 않는다 —
// 숫자는 ± 버튼으로만 움직인다는 규칙, 시작일은 일차 기준이라 고정.
export async function updateStackChallenge(
  challengeId: string,
  p: { title: string; goalCount: number | null },
): Promise<void> {
  const { error } = await supabase
    .from('stack_challenges')
    .update({ title: p.title, goal_count: p.goalCount })
    .eq('id', challengeId)
  if (error) throw error
}
