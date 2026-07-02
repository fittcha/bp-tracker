'use client'

import { useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import { getPendingShares, acceptShare, rejectShare } from '@/lib/api/workout-shares'
import Avatar from '@/components/Avatar'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'

// SWRConfig 내부에서 렌더되어야 함(provider 사용). 대기건 1+ 이면 모달 노출.
export default function PendingSharesGate({ uid }: { uid: string }) {
  const { mutate } = useSWRConfig()
  const { data: shares } = useSWR(uid ? k.pendingShares(uid) : null, () => getPendingShares(uid))
  // busyId !== null이면 모든 행 버튼 비활성(전체 in-flight 락)
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

  const isProcessing = busyId !== null

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4 bg-foreground/50">
      <div className="w-full max-w-sm bg-surface rounded-2xl max-h-[80vh] flex flex-col overflow-hidden shadow-lg">
        {/* 헤더 */}
        <div className="px-4 pt-4 pb-3 border-b border-border flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-2">
            <h2 className="text-base font-bold text-foreground">공유 받은 운동</h2>
            <span className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-accent-pop text-white text-[11px] font-bold leading-none">
              {shares.length}
            </span>
          </div>
          <button
            onClick={() => setClosed(true)}
            aria-label="닫기"
            className="w-10 h-10 flex items-center justify-center text-text-secondary rounded-xl transition-colors hover:bg-accent-light hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" aria-hidden="true">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        {/* 목록 */}
        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-2.5">
          {shares.map((s) => (
            <div key={s.id} className="border border-border rounded-xl px-3 py-3">
              <div className="flex items-center gap-2.5">
                <Avatar src={s.avatarUrl ?? null} name={s.fromUsername} size={36} />
                <div className="min-w-0">
                  {/* 보낸 사람 */}
                  <p className="text-[11px] text-text-secondary mb-0.5">
                    <span className="font-bold text-foreground">{s.fromUsername}</span>님이 공유했어요
                  </p>
                  {/* 운동명 */}
                  <p className="text-sm font-bold text-foreground truncate">{s.title}</p>
                </div>
              </div>
              {/* 액션 버튼 */}
              <div className="flex items-center gap-2 mt-3">
                <button
                  onClick={() => handleReject(s.id)}
                  disabled={isProcessing}
                  className="flex-1 min-h-[40px] rounded-lg text-sm font-medium border border-border text-text-secondary transition-colors hover:border-danger hover:text-danger disabled:opacity-40 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-border"
                >
                  거부
                </button>
                <button
                  onClick={() => handleAccept(s.id)}
                  disabled={isProcessing}
                  className="flex-1 min-h-[40px] rounded-lg text-sm font-bold bg-accent text-white transition-colors hover:bg-accent/90 disabled:opacity-40 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-1"
                >
                  {busyId === s.id ? '처리 중…' : '수락'}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
