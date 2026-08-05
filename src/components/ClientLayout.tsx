'use client'

import { useEffect, useState } from 'react'
import { usePathname } from 'next/navigation'
import { SWRConfig } from 'swr'
import Header from '@/components/Header'
import BottomNav from '@/components/BottomNav'
import AuthGuard from '@/components/auth/AuthGuard'
import { getLoggedInUser } from '@/lib/auth'
import { localStorageProvider } from '@/lib/swr/provider'
import PendingSharesGate from '@/components/PendingSharesModal'

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const isLogin = pathname === '/login'
  const [overlayVisible, setOverlayVisible] = useState(false)
  const uid = getLoggedInUser()?.id ?? 'anon'

  useEffect(() => {
    const handler = (e: Event) => setOverlayVisible((e as CustomEvent).detail)
    window.addEventListener('calc-open', handler)
    return () => window.removeEventListener('calc-open', handler)
  }, [])

  const content = (
    <>
      {!isLogin && <Header />}
      <main className={isLogin ? '' : 'max-w-lg mx-auto px-4 pt-3 pb-20'}>{children}</main>
      {!isLogin && <BottomNav />}
      {!isLogin && uid !== 'anon' && <PendingSharesGate uid={uid} />}
      {overlayVisible && (
        <div
          className="fixed inset-0 bg-black/40 z-[55]"
          onClick={() => {
            setOverlayVisible(false)
            window.dispatchEvent(new CustomEvent('calc-close'))
          }}
        />
      )}
    </>
  )

  return (
    <AuthGuard>
      <SWRConfig
        key={uid}
        value={{
          provider: () => localStorageProvider(uid),
          revalidateOnFocus: true,
          // 앱 복귀마다 재검증 → 그때마다 화면이 스왑돼 어지러웠다. 1분으로 묶는다.
          focusThrottleInterval: 60_000,
          revalidateOnReconnect: true,
          dedupingInterval: 2000,
          // 전역 true. 단 날짜별 데이터(운동 탭)는 훅에서 false로 덮어 이전 날짜 카드가
          // 남지 않게 한다 — src/app/workout/page.tsx의 perDate.
          keepPreviousData: true,
        }}
      >
        {content}
      </SWRConfig>
    </AuthGuard>
  )
}
