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
      const [days, attempts] = await Promise.all([
        getProgramDays(challenge.program_id),
        getAttempts(challenge.id),
      ])
      return { challenge, days, attempts }
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
  const { data, error } = await supabase
    .from('user_challenges')
    .insert({
      user_id: p.userId,
      template_key: p.templateKey,
      program_id: p.programId,
      difficulty: p.difficulty,
      training_weekdays: p.trainingWeekdays,
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

export async function updateAttemptDate(attemptId: string, doneDate: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .update({ done_date: doneDate })
    .eq('id', attemptId)
    .select()
    .single()
  if (error) throw error
}

export async function resetChallenge(userChallengeId: string): Promise<void> {
  const { error } = await supabase
    .from('challenge_attempts')
    .delete()
    .eq('user_challenge_id', userChallengeId)
  if (error) throw error
}
