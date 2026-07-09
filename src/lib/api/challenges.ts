import { supabase } from '@/lib/supabase'

export interface ChallengeTemplate {
  key: string
  name: string
  exercise: string
  difficulty_mode: 'equipment' | 'range'
  sort_order: number
}

export interface ChallengeProgram {
  id: string
  template_key: string
  difficulty_key: string | null
  label: string | null
  sort_order: number
}

export interface ChallengeProgramDay {
  id: string
  program_id: string
  day_no: number        // 프로그램 내 1-based 전체 순번
  week_no: number        // 1-based 주차
  day_in_week: number    // 주차 내 1-based 일
  sets_text: string      // 세트/라운드 구성, '·' 구분 (예: "5·4·3·2·1", "17·19·15·15·20+")
  rest_seconds: number | null  // 세트간 휴식(초). 없으면 null
}

export interface UserChallenge {
  id: string
  user_id: string
  template_key: string
  program_id: string
  difficulty: Record<string, unknown>
  training_weekdays: number[]
  started_at: string
  status: 'active' | 'archived'
  created_at?: string
  completed_at?: string | null
  carried_streak?: number
  final_streak?: number
}

export interface ChallengeAttempt {
  id: string
  user_challenge_id: string
  day_no: number
  result: 'success' | 'fail'
  done_date: string
  created_at?: string
}

export interface ActiveChallenge {
  challenge: UserChallenge
  days: ChallengeProgramDay[]
  attempts: ChallengeAttempt[]
  progress: Record<number, number[]> // day_no → 완료 세트 인덱스
}

const MISSING = 'PGRST205' // 테이블 미생성(마이그레이션 PENDING)

export async function getChallengeTemplates(): Promise<ChallengeTemplate[]> {
  const { data, error } = await supabase.from('challenge_templates').select('*').order('sort_order')
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  return (data ?? []) as ChallengeTemplate[]
}

export async function getProgramsForTemplate(templateKey: string): Promise<ChallengeProgram[]> {
  const { data, error } = await supabase
    .from('challenge_programs')
    .select('*')
    .eq('template_key', templateKey)
    .order('sort_order', { ascending: true })
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  return (data ?? []) as ChallengeProgram[]
}

async function getProgramDays(programId: string): Promise<ChallengeProgramDay[]> {
  const { data, error } = await supabase
    .from('challenge_program_days')
    .select('*')
    .eq('program_id', programId)
    .order('day_no')
  if (error) throw error
  return (data ?? []) as ChallengeProgramDay[]
}

async function getAttempts(userChallengeId: string): Promise<ChallengeAttempt[]> {
  const { data, error } = await supabase
    .from('challenge_attempts')
    .select('*')
    .eq('user_challenge_id', userChallengeId)
    .order('created_at', { ascending: true })
  if (error) throw error
  return (data ?? []) as ChallengeAttempt[]
}

async function getDayProgress(userChallengeId: string): Promise<Record<number, number[]>> {
  const { data, error } = await supabase
    .from('challenge_day_progress')
    .select('day_no, done_sets')
    .eq('user_challenge_id', userChallengeId)
  if (error) {
    if (error.code === MISSING) return {} // 테이블 미생성 폴백
    throw error
  }
  const map: Record<number, number[]> = {}
  for (const r of (data ?? []) as { day_no: number; done_sets: number[] }[]) {
    map[r.day_no] = Array.isArray(r.done_sets) ? r.done_sets : []
  }
  return map
}

export async function getActiveChallenges(userId: string): Promise<ActiveChallenge[]> {
  const { data, error } = await supabase
    .from('user_challenges')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'active')
    .order('created_at', { ascending: true })
  if (error) {
    if (error.code === MISSING) return []
    throw error
  }
  const challenges = (data ?? []) as UserChallenge[]
  return Promise.all(
    challenges.map(async (challenge) => {
      const [days, attempts, progress] = await Promise.all([
        getProgramDays(challenge.program_id),
        getAttempts(challenge.id),
        getDayProgress(challenge.id),
      ])
      return { challenge, days, attempts, progress }
    }),
  )
}

export async function startChallenge(p: {
  userId: string
  templateKey: string
  programId: string
  difficulty: Record<string, unknown>
  trainingWeekdays: number[]
}): Promise<UserChallenge> {
  // 같은 종목, 7일 내 완료건의 final_streak 이어받기
  const cutoff = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
  const { data: prev } = await supabase
    .from('user_challenges')
    .select('final_streak, completed_at')
    .eq('user_id', p.userId)
    .eq('template_key', p.templateKey)
    .eq('status', 'archived')
    .not('completed_at', 'is', null)
    .gte('completed_at', cutoff)
    .order('completed_at', { ascending: false })
    .limit(1)
    .maybeSingle()
  const carried = (prev?.final_streak as number | undefined) ?? 0

  const { data, error } = await supabase
    .from('user_challenges')
    .insert({
      user_id: p.userId,
      template_key: p.templateKey,
      program_id: p.programId,
      difficulty: p.difficulty,
      training_weekdays: p.trainingWeekdays,
      carried_streak: carried,
    })
    .select()
    .single()
  if (error) throw error
  return data as UserChallenge
}

export async function addAttempt(p: {
  userChallengeId: string
  dayNo: number
  result: 'success' | 'fail'
  doneDate: string
}): Promise<ChallengeAttempt> {
  // 성공 attempt가 이미 있으면 잠금 — 추가 거부
  const { data: locked, error: le } = await supabase
    .from('challenge_attempts')
    .select('id')
    .eq('user_challenge_id', p.userChallengeId)
    .eq('day_no', p.dayNo)
    .eq('result', 'success')
    .maybeSingle()
  if (le) throw le
  if (locked) throw new Error('이미 성공한 day입니다')

  const { data, error } = await supabase
    .from('challenge_attempts')
    .insert({
      user_challenge_id: p.userChallengeId,
      day_no: p.dayNo,
      result: p.result,
      done_date: p.doneDate,
    })
    .select()
    .single()
  if (error) throw error
  return data as ChallengeAttempt
}

export async function setDayProgress(userChallengeId: string, dayNo: number, doneSets: number[]): Promise<void> {
  const { error } = await supabase
    .from('challenge_day_progress')
    .upsert(
      { user_challenge_id: userChallengeId, day_no: dayNo, done_sets: doneSets, updated_at: new Date().toISOString() },
      { onConflict: 'user_challenge_id,day_no' },
    )
  if (error) {
    if (error.code === MISSING) return
    throw error
  }
}

export async function clearDayProgress(userChallengeId: string, dayNo: number): Promise<void> {
  const { error } = await supabase
    .from('challenge_day_progress')
    .delete()
    .eq('user_challenge_id', userChallengeId)
    .eq('day_no', dayNo)
  if (error) {
    if (error.code === MISSING) return
    throw error
  }
}

export async function updateAttemptDate(attemptId: string, doneDate: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .update({ done_date: doneDate })
    .eq('id', attemptId)
    .select()
    .single()
  if (error) throw error
}

// 단일 attempt 물리삭제 (성공 잘못 누름 되돌리기 등). 삭제 후 그 day는 남은 attempt로 재파생.
export async function deleteAttempt(attemptId: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .delete()
    .eq('id', attemptId)
  if (error) throw error
}

export async function resetChallenge(userChallengeId: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .delete()
    .eq('user_challenge_id', userChallengeId)
  if (error) throw error
}

// 수정: 훈련 요일 + 난이도 메타(밴드/중량). 트랙/변형(program)은 변경하지 않음.
export async function updateChallenge(userChallengeId: string, p: {
  trainingWeekdays: number[]
  difficulty: Record<string, unknown>
}): Promise<void> {
  const { error } = await supabase
    .from('user_challenges')
    .update({ training_weekdays: p.trainingWeekdays, difficulty: p.difficulty })
    .eq('id', userChallengeId)
    .select()
    .single()
  if (error) throw error
}

// 완료: 아카이브 + 완료시각 + 스트릭 스냅샷(삭제 아님, attempts 보존).
export async function completeChallenge(userChallengeId: string, finalStreak: number): Promise<void> {
  const { error } = await supabase
    .from('user_challenges')
    .update({ status: 'archived', completed_at: new Date().toISOString(), final_streak: finalStreak })
    .eq('id', userChallengeId)
  if (error) throw error
}

// 삭제: 인스턴스 + attempts(FK cascade) 전부 제거
export async function deleteChallenge(userChallengeId: string): Promise<void> {
  const { error } = await supabase
    .from('user_challenges')
    .delete()
    .eq('id', userChallengeId)
  if (error) throw error
}

// 챌린지 탭 + 홈 위젯 공용 fetcher. k.challenges(uid) 캐시의 canonical shape.
export async function getChallengesData(userId: string): Promise<{ actives: ActiveChallenge[]; templates: ChallengeTemplate[] }> {
  const [actives, templates] = await Promise.all([getActiveChallenges(userId), getChallengeTemplates()])
  return { actives, templates }
}
