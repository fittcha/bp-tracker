import { supabase } from '@/lib/supabase'
import { buildSharePayload, filterNewRecipients, type SharePayload } from '@/lib/workout/share-payload'
import { createPersonalWorkout, getWorkoutExercises, type Workout } from '@/lib/api/workouts'

export interface PendingShare { id: string; fromUsername: string; title: string }
export interface SentShare { id: string; toUsername: string }

// 보낸 사람 본인 → 선택 유저들에게 공유. payload 스냅샷, 이미 대기 중인 수신자는 건너뜀.
export async function shareWorkout(fromId: string, sourceWorkoutId: string, toIds: string[]): Promise<void> {
  if (toIds.length === 0) return
  const { data: w, error: we } = await supabase
    .from('workouts').select('title, category').eq('id', sourceWorkoutId).single()
  if (we) throw we
  const exercises = await getWorkoutExercises(sourceWorkoutId)
  const payload: SharePayload = buildSharePayload(w as Pick<Workout, 'title' | 'category'>, exercises)

  const { data: existing, error: ee } = await supabase
    .from('workout_shares').select('to_user_id')
    .eq('from_user_id', fromId).eq('source_workout_id', sourceWorkoutId).in('to_user_id', toIds)
  if (ee) throw ee
  const already = (existing ?? []).map((r) => r.to_user_id as string)
  const targets = filterNewRecipients(toIds, already)
  if (targets.length === 0) return

  const rows = targets.map((toId) => ({
    from_user_id: fromId, to_user_id: toId, source_workout_id: sourceWorkoutId, payload,
  }))
  const { error: ie } = await supabase.from('workout_shares').insert(rows)
  if (ie) throw ie
}

// 받는 사람 대기건 + 보낸사람 username. 2-step(임베드 힌트 회피).
export async function getPendingShares(toId: string): Promise<PendingShare[]> {
  const { data, error } = await supabase
    .from('workout_shares').select('id, from_user_id, payload')
    .eq('to_user_id', toId).order('created_at', { ascending: true })
  if (error) throw error
  const rows = (data ?? []) as { id: string; from_user_id: string; payload: SharePayload }[]
  if (rows.length === 0) return []
  const fromIds = [...new Set(rows.map((r) => r.from_user_id))]
  const { data: us, error: ue } = await supabase.from('users').select('id, username').in('id', fromIds)
  if (ue) throw ue
  const nameById = new Map((us ?? []).map((u) => [u.id as string, u.username as string]))
  return rows.map((r) => ({ id: r.id, fromUsername: nameById.get(r.from_user_id) ?? '알 수 없음', title: r.payload?.title ?? '운동' }))
}

// 공유 모달의 '대기 중' 목록(이 운동을 누구에게 보냈나) + 받는사람 username.
export async function getSentPendingShares(fromId: string, sourceWorkoutId: string): Promise<SentShare[]> {
  const { data, error } = await supabase
    .from('workout_shares').select('id, to_user_id')
    .eq('from_user_id', fromId).eq('source_workout_id', sourceWorkoutId).order('created_at', { ascending: true })
  if (error) throw error
  const rows = (data ?? []) as { id: string; to_user_id: string }[]
  if (rows.length === 0) return []
  const toIds = [...new Set(rows.map((r) => r.to_user_id))]
  const { data: us, error: ue } = await supabase.from('users').select('id, username').in('id', toIds)
  if (ue) throw ue
  const nameById = new Map((us ?? []).map((u) => [u.id as string, u.username as string]))
  return rows.map((r) => ({ id: r.id, toUsername: nameById.get(r.to_user_id) ?? '알 수 없음' }))
}

// 수락: payload로 내 라이브러리에 개인운동 생성 후 행 삭제.
export async function acceptShare(shareId: string): Promise<void> {
  const { data, error } = await supabase
    .from('workout_shares').select('to_user_id, payload').eq('id', shareId).single()
  if (error) throw error
  const row = data as { to_user_id: string; payload: SharePayload }
  if (row?.payload?.title) {
    await createPersonalWorkout(row.to_user_id, row.payload.title, row.payload.category ?? null, row.payload.exercises ?? [])
  }
  const { error: de } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (de) throw de
}

// 거부/취소: 행 삭제(동작 동일, 의미 구분).
export async function rejectShare(shareId: string): Promise<void> {
  const { error } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (error) throw error
}
export async function cancelShare(shareId: string): Promise<void> {
  const { error } = await supabase.from('workout_shares').delete().eq('id', shareId)
  if (error) throw error
}
