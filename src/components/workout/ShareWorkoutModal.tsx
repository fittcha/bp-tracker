'use client'

import { useState, useEffect, useCallback } from 'react'
import { searchUsersByUsername, type User } from '@/lib/api/users'
import { shareWorkout, getSentPendingShares, cancelShare, type SentShare } from '@/lib/api/workout-shares'
import type { Workout } from '@/lib/api/workouts'

interface Props { userId: string; workout: Workout; onClose: () => void }

export default function ShareWorkoutModal({ userId, workout, onClose }: Props) {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<User[]>([])
  const [searching, setSearching] = useState(false)
  const [selected, setSelected] = useState<User[]>([])
  const [pending, setPending] = useState<SentShare[]>([])
  const [sharing, setSharing] = useState(false)
  const [err, setErr] = useState<string | null>(null)
  const [done, setDone] = useState(false)

  const loadPending = useCallback(async () => {
    try { setPending(await getSentPendingShares(userId, workout.id)) } catch { /* 무시 */ }
  }, [userId, workout.id])

  useEffect(() => { loadPending() }, [loadPending])

  // 검색 디바운스
  useEffect(() => {
    if (query.trim() === '') { setResults([]); return }
    setSearching(true)
    const t = setTimeout(async () => {
      try { setResults(await searchUsersByUsername(query, userId)) }
      catch { setResults([]) }
      finally { setSearching(false) }
    }, 250)
    return () => clearTimeout(t)
  }, [query, userId])

  const pendingUsernames = new Set(pending.map((p) => p.toUsername))
  const selectedIds = new Set(selected.map((u) => u.id))

  function toggle(u: User) {
    setSelected((prev) => prev.some((s) => s.id === u.id) ? prev.filter((s) => s.id !== u.id) : [...prev, u])
  }

  async function handleShare() {
    if (selected.length === 0) return
    setSharing(true); setErr(null)
    try {
      await shareWorkout(userId, workout.id, selected.map((u) => u.id))
      setSelected([]); setQuery(''); setResults([]); setDone(true)
      await loadPending()
      setTimeout(() => setDone(false), 1800)
    } catch (e) {
      setErr(e instanceof Error ? e.message : '공유에 실패했습니다.')
    } finally { setSharing(false) }
  }

  async function handleCancel(shareId: string) {
    try { await cancelShare(shareId); await loadPending() }
    catch (e) { setErr(e instanceof Error ? e.message : '취소에 실패했습니다.') }
  }

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 bg-foreground/40"
      onClick={(e) => { if (e.target === e.currentTarget) onClose() }}>
      <div className="w-full max-w-md bg-surface rounded-2xl max-h-[85vh] flex flex-col overflow-hidden">
        {/* 헤더 */}
        <div className="px-4 pt-4 pb-3 border-b border-border flex items-center justify-between flex-shrink-0">
          <div className="min-w-0">
            <p className="text-[11px] text-text-secondary">운동 공유</p>
            <h2 className="text-base font-bold text-foreground truncate">{workout.title}</h2>
          </div>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center text-text-secondary rounded-lg shrink-0">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-3">
          {/* 검색 */}
          <input
            autoFocus value={query} onChange={(e) => setQuery(e.target.value)} placeholder="아이디 검색"
            className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface text-foreground placeholder:text-text-secondary outline-none focus:border-accent"
          />

          {/* 선택 칩(골드 톤) */}
          {selected.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {selected.map((u) => (
                <span key={u.id} className="inline-flex items-center gap-1 pl-2.5 pr-1.5 py-1 rounded-full bg-accent-pop/15 text-accent-pop text-xs font-medium">
                  {u.username}
                  <button onClick={() => toggle(u)} className="w-4 h-4 flex items-center justify-center" aria-label="제거">
                    <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
                  </button>
                </span>
              ))}
            </div>
          )}

          {/* 검색 결과 */}
          {query.trim() === '' ? (
            <p className="text-xs text-text-secondary/70 py-2">아이디를 입력하세요.</p>
          ) : searching ? (
            <p className="text-xs text-text-secondary/70 py-2">검색 중…</p>
          ) : results.length === 0 ? (
            <p className="text-xs text-text-secondary/70 py-2">검색 결과 없음</p>
          ) : (
            <div className="space-y-0.5">
              {results.map((u) => {
                const isPending = pendingUsernames.has(u.username)
                const isSel = selectedIds.has(u.id)
                return (
                  <button key={u.id} disabled={isPending} onClick={() => toggle(u)}
                    className={`w-full flex items-center gap-2.5 px-2 py-2 rounded-lg text-left transition-colors ${isPending ? 'opacity-40' : 'hover:bg-accent-light'}`}>
                    <span className={`w-4 h-4 rounded border flex items-center justify-center shrink-0 ${isSel ? 'bg-accent border-accent text-white' : 'border-border'}`}>
                      {isSel && <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><polyline points="20 6 9 17 4 12" /></svg>}
                    </span>
                    <span className="text-sm text-foreground flex-1">{u.username}</span>
                    {isPending && <span className="text-[10px] text-text-secondary">대기 중</span>}
                  </button>
                )
              })}
            </div>
          )}

          {/* 공유 대기 중(취소) */}
          {pending.length > 0 && (
            <div className="pt-2 border-t border-border">
              <p className="text-[11px] font-semibold text-text-secondary mb-1.5">공유 대기 중</p>
              <div className="space-y-0.5">
                {pending.map((p) => (
                  <div key={p.id} className="flex items-center justify-between px-2 py-1.5">
                    <span className="text-sm text-foreground">{p.toUsername}</span>
                    <button onClick={() => handleCancel(p.id)} className="text-[11px] font-medium text-danger px-2 py-1 rounded">취소</button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {err && <p className="text-xs text-danger">{err}</p>}
          {done && <p className="text-xs text-accent-pop">공유했어요.</p>}
        </div>

        {/* 푸터 액션 */}
        <div className="px-4 py-3 border-t border-border flex-shrink-0">
          <button onClick={handleShare} disabled={selected.length === 0 || sharing}
            className="w-full py-2.5 rounded-lg text-sm font-semibold bg-accent text-white disabled:opacity-50">
            {sharing ? '공유 중…' : selected.length > 0 ? `${selected.length}명에게 공유하기` : '공유하기'}
          </button>
        </div>
      </div>
    </div>
  )
}
