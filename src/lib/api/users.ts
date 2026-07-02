import { supabase } from '@/lib/supabase'
import { isBlankQuery } from '@/lib/workout/share-payload'

export interface User {
  id: string
  username: string
  pin_hash: string | null
  created_by: string | null
  created_at: string
  active?: boolean
  avatar_url?: string | null
}

export async function getUserByUsername(username: string): Promise<User | null> {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('username', username)
    .eq('active', true) // 비활성(소프트 삭제) 유저는 로그인 불가
    .single()
  if (error && error.code !== 'PGRST116') throw error
  return data
}

// 아이디 like 검색(공유 대상 선택용). 빈 문자열은 조회 안 함. 본인·비활성 제외.
export async function searchUsersByUsername(query: string, excludeId: string): Promise<User[]> {
  if (isBlankQuery(query)) return []
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .ilike('username', `%${query.trim()}%`)
    .eq('active', true)
    .neq('id', excludeId)
    .order('username', { ascending: true })
    .limit(20)
  if (error) throw error
  return (data ?? []) as User[]
}

export async function setUserPin(userId: string, pin: string) {
  const { error } = await supabase
    .from('users')
    .update({ pin_hash: pin })
    .eq('id', userId)
  if (error) throw error
}

export async function verifyPin(userId: string, pin: string): Promise<boolean> {
  const { data, error } = await supabase
    .from('users')
    .select('pin_hash')
    .eq('id', userId)
    .single()
  if (error) throw error
  return data.pin_hash === pin
}

export async function createUser(username: string, createdBy: string | null): Promise<User> {
  const { data, error } = await supabase
    .from('users')
    .insert({ username, created_by: createdBy })
    .select()
    .single()
  if (error) throw error
  return data
}

// 아바타 이미지 업로드(avatars 버킷). 경로에 timestamp 포함 → URL 변경으로 캐시버스트.
export async function uploadAvatar(file: Blob, userId: string): Promise<string> {
  const fileName = `${userId}/avatar-${Date.now()}.jpg`
  const { error } = await supabase.storage
    .from('avatars')
    .upload(fileName, file, { contentType: 'image/jpeg', upsert: false })
  if (error) throw error
  const { data } = supabase.storage.from('avatars').getPublicUrl(fileName)
  return data.publicUrl
}

export async function updateAvatarUrl(userId: string, url: string | null): Promise<void> {
  const { error } = await supabase.from('users').update({ avatar_url: url }).eq('id', userId)
  if (error) throw error
}

// 본인 프로필(username + 아바타). k.profile SWR 페처.
export async function getUserProfile(userId: string): Promise<{ username: string; avatarUrl: string | null }> {
  const { data, error } = await supabase
    .from('users').select('username, avatar_url').eq('id', userId).single()
  if (error) throw error
  return { username: data.username as string, avatarUrl: (data.avatar_url as string | null) ?? null }
}
