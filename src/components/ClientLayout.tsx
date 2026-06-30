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
          revalidateOnReconnect: true,
          dedupingInterval: 2000,
          keepPreviousData: true,
        }}
      >
        {content}
      </SWRConfig>
    </AuthGuard>
  )
}
