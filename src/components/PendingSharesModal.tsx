'use client'

import { useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import { getPendingShares, acceptShare, rejectShare } from '@/lib/api/workout-shares'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'

// SWRConfig 내부에서 렌더되어야 함(provider 사용). 대기건 1+ 이면 모달 노출.
export default function PendingSharesGate({ uid }: { uid: string }) {
  const { mutate } = useSWRConfig()
  const { data: shares } = useSWR(uid ? k.pendingShares(uid) : null, () => getPendingShares(uid))
  const [busyId, setBusyId] = useState<string | null>(null)
  const [closed, setClosed] = useState(false)

  if (!shares || shares.length === 0 || closed) return null

  async function handleAccept(id: string) {
    setBusyId(id)
    try {
      await acceptShare(id)
      mutate(k.pendingShares(uid))
      mutate(matchPrefix('personal-workouts', uid))
    } finally { setBusyId(null) }
  }
  async function handleReject(id: string) {
    setBusyId(id)
    try { await rejectShare(id); mutate(k.pendingShares(uid)) }
    finally { setBusyId(null) }
  }

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4 bg-foreground/50">
      <div className="w-full max-w-sm bg-surface rounded-2xl max-h-[80vh] flex flex-col overflow-hidden">
        <div className="px-4 pt-4 pb-3 border-b border-border flex items-center justify-between flex-shrink-0">
          <h2 className="text-base font-bold text-foreground">공유 받은 운동 <span className="text-accent-pop">{shares.length}</span></h2>
          <button onClick={() => setClosed(true)} className="w-8 h-8 flex items-center justify-center text-text-secondary rounded-lg">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
          </button>
        </div>
        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2">
          {shares.map((s) => (
            <div key={s.id} className="border border-border rounded-xl px-3 py-2.5">
              <p className="text-sm text-foreground"><span className="font-bold">{s.fromUsername}</span>님이 공유</p>
              <p className="text-sm font-semibold text-foreground mt-0.5">{s.title}</p>
              <div className="flex items-center gap-2 mt-2.5">
                <button onClick={() => handleReject(s.id)} disabled={busyId === s.id}
                  className="flex-1 py-2 rounded-lg text-sm font-medium border border-border text-text-secondary disabled:opacity-50">거부</button>
                <button onClick={() => handleAccept(s.id)} disabled={busyId === s.id}
                  className="flex-1 py-2 rounded-lg text-sm font-semibold bg-accent text-white disabled:opacity-50">수락</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
