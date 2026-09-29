'use client'

import { useMemo, useState } from 'react'
import { Plus } from 'lucide-react'
import useSWR, { useSWRConfig } from 'swr'
import { getLoggedInUser } from '@/lib/auth'
import { getChallengesData, type ActiveChallenge, type ChallengeTemplate } from '@/lib/api/challenges'
import { k } from '@/lib/swr/keys'
import { matchPrefix } from '@/lib/swr/revalidate'
import ChallengeDashboardCard from '@/components/challenge/ChallengeDashboardCard'
import StackChallengeCard from '@/components/challenge/StackChallengeCard'
import { getStackChallenges } from '@/lib/api/stack'
import AddChallengePopup from '@/components/challenge/AddChallengePopup'

export default function ChallengePage() {
  const uid = getLoggedInUser()?.id ?? ''
  const { data } = useSWR(uid ? k.challenges(uid) : null, () => getChallengesData(uid))
  const { data: stacks } = useSWR(uid ? k.stackChallenges(uid) : null, () => getStackChallenges(uid))
  const { mutate } = useSWRConfig()
  const [addOpen, setAddOpen] = useState(false)

  const reload = () => {
    void mutate(matchPrefix('challenges', uid))
    void mutate(matchPrefix('stack-challenges', uid))
  }

  const actives: ActiveChallenge[] = data?.actives ?? []
  const templateMap: Record<string, ChallengeTemplate> = useMemo(
    () => Object.fromEntries((data?.templates ?? []).map((t) => [t.key, t])),
    [data],
  )

  const stackItems = stacks ?? []
  const loading = data === undefined || stacks === undefined
  const isEmpty = actives.length === 0 && stackItems.length === 0

  // 탭은 종류를 나눠 보여준다. 숨겨진 쪽에 뭐가 있는지 알 수 있게 개수를 함께 띄운다.
  // 직접 고르기 전(null)까지는 내용이 있는 쪽을 잡는다 — 쌓기만 있는 사람이 빈 탭에
  // 떨어지지 않게. 로드 전엔 둘 다 비어 있으므로 데이터가 온 뒤 자연히 맞춰진다.
  const [tabPref, setTabPref] = useState<'program' | 'stack' | null>(null)
  const tab = tabPref ?? (actives.length > 0 ? 'program' : 'stack')
  const setTab = setTabPref
  const tabs = [
    { key: 'program' as const, label: '챌린지', count: actives.length },
    { key: 'stack' as const, label: '쌓기', count: stackItems.length },
  ]

  return (
    <div className="flex flex-col gap-4">
      {loading ? (
        <p className="text-sm text-text-secondary text-center py-12">불러오는 중…</p>
      ) : isEmpty ? (
        <div className="flex flex-col items-center justify-center py-20 text-center">
          <p className="text-base font-semibold text-foreground mb-1">진행 중인 챌린지가 없어요</p>
          <p className="text-sm text-text-secondary">아래 버튼으로 풀업·푸쉬업 챌린지나 쌓기를 시작해보세요.</p>
        </div>
      ) : (
        <>
          {/* 종류 탭 */}
          <div className="flex gap-1 p-1 rounded-xl bg-background border border-border">
            {tabs.map((t) => (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
                  tab === t.key ? 'bg-surface text-foreground shadow-sm' : 'text-text-secondary'
                }`}
              >
                {t.label}
                {t.count > 0 && (
                  <span className={`ml-1.5 text-xs tabular-nums ${tab === t.key ? 'text-accent' : 'text-text-secondary/60'}`}>
                    {t.count}
                  </span>
                )}
              </button>
            ))}
          </div>

          {tab === 'program' ? (
            actives.length === 0 ? (
              <p className="text-sm text-text-secondary text-center py-12">
                진행 중인 풀업·푸쉬업 챌린지가 없어요.
              </p>
            ) : (
              <>
                <p className="text-[11px] text-text-secondary/80 px-1 mb-2">
                  💡 완주 후 <span className="font-semibold text-text-secondary">7일 안에</span> 다음 난이도를 시작하면 🔥연속기록이 이어져요. (카드 ⋯ → 완료)
                </p>
                {actives.map((a) => (
                  <ChallengeDashboardCard key={a.challenge.id} active={a} template={templateMap[a.challenge.template_key]} onChanged={reload} />
                ))}
              </>
            )
          ) : stackItems.length === 0 ? (
            <p className="text-sm text-text-secondary text-center py-12">쌓는 중인 종목이 없어요.</p>
          ) : (
            stackItems.map((it) => (
              <StackChallengeCard key={it.challenge.id} item={it} onChanged={reload} />
            ))
          )}
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
