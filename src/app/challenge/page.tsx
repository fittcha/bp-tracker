'use client'

import { useCallback, useEffect, useState } from 'react'
import { Plus } from 'lucide-react'
import { getLoggedInUser } from '@/lib/auth'
import {
  getActiveChallenges, getChallengeTemplates,
  type ActiveChallenge, type ChallengeTemplate,
} from '@/lib/api/challenges'
import ChallengeDashboardCard from '@/components/challenge/ChallengeDashboardCard'
import AddChallengePopup from '@/components/challenge/AddChallengePopup'

export default function ChallengePage() {
  const [actives, setActives] = useState<ActiveChallenge[]>([])
  const [templates, setTemplates] = useState<Record<string, ChallengeTemplate>>({})
  const [loading, setLoading] = useState(true)
  const [addOpen, setAddOpen] = useState(false)

  const reload = useCallback(async () => {
    const user = getLoggedInUser()
    if (!user) { setLoading(false); return }
    const [list, temps] = await Promise.all([getActiveChallenges(user.id), getChallengeTemplates()])
    setActives(list)
    setTemplates(Object.fromEntries(temps.map((t) => [t.key, t])))
    setLoading(false)
  }, [])

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { reload() }, [reload])

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
        actives.map((a) => (
          <ChallengeDashboardCard key={a.challenge.id} active={a} template={templates[a.challenge.template_key]} onChanged={reload} />
        ))
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
