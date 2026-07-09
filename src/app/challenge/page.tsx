'use client'

import { useMemo, useState } from 'react'
import { Plus } from 'lucide-react'
import useSWR, { useSWRConfig } from 'swr'
import { getLoggedInUser } from '@/lib/auth'
import { getChallengesData, type ActiveChallenge, type ChallengeTemplate } from '@/lib/api/challenges'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'
import ChallengeDashboardCard from '@/components/challenge/ChallengeDashboardCard'
import AddChallengePopup from '@/components/challenge/AddChallengePopup'

export default function ChallengePage() {
  const uid = getLoggedInUser()?.id ?? ''
  const { data } = useSWR(uid ? k.challenges(uid) : null, () => getChallengesData(uid))
  const { mutate } = useSWRConfig()
  const [addOpen, setAddOpen] = useState(false)

  const reload = () => { void mutate(matchPrefix('challenges', uid)) }

  const actives: ActiveChallenge[] = data?.actives ?? []
  const templateMap: Record<string, ChallengeTemplate> = useMemo(
    () => Object.fromEntries((data?.templates ?? []).map((t) => [t.key, t])),
    [data],
  )

  const loading = data === undefined

  return (
    <div className="flex flex-col gap-4">
      {loading ? (
        <p className="text-sm text-text-secondary text-center py-12">불러오는 중…</p>
      ) : actives.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-center">
          <p className="text-base font-semibold text-foreground mb-1">진행 중인 챌린지가 없어요</p>
          <p className="text-sm text-text-secondary">아래 버튼으로 풀업·푸쉬업 챌린지를 시작해보세요.</p>
        </div>
      ) : (
        <>
          <p className="text-[11px] text-text-secondary/80 px-1 mb-2">
            💡 완주 후 <span className="font-semibold text-text-secondary">7일 안에</span> 다음 난이도를 시작하면 🔥연속기록이 이어져요. (카드 ⋯ → 완료)
          </p>
          {actives.map((a) => (
            <ChallengeDashboardCard key={a.challenge.id} active={a} template={templateMap[a.challenge.template_key]} onChanged={reload} />
          ))}
        </>
      )}

      {!loading && (
        <button
          onClick={() => setAddOpen(true)}
          className="self-center inline-flex items-center gap-1.5 px-4 py-2 rounded-full border border-accent/40 text-accent text-sm font-medium hover:bg-accent/5 transition-colors">
          <Plus size={16} /> 챌린지 추가
        </button>
      )}

      <AddChallengePopup isOpen={addOpen} onClose={() => setAddOpen(false)} onStarted={reload} />
    </div>
  )
}
