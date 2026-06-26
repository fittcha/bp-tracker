'use client'

import { useEffect, useState } from 'react'
import { usePathname } from 'next/navigation'
import Header from '@/components/Header'
import BottomNav from '@/components/BottomNav'
import AuthGuard from '@/components/auth/AuthGuard'

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const isLogin = pathname === '/login'
  const [overlayVisible, setOverlayVisible] = useState(false)

  useEffect(() => {
    const handler = (e: Event) => setOverlayVisible((e as CustomEvent).detail)
    window.addEventListener('calc-open', handler)
    return () => window.removeEventListener('calc-open', handler)
  }, [])

  return (
    <AuthGuard>
      {!isLogin && <Header />}
      <main className={isLogin ? '' : 'max-w-lg mx-auto px-4 pt-3 pb-20'}>
        {children}
      </main>
      {!isLogin && <BottomNav />}
      {overlayVisible && (
        <div
          className="fixed inset-0 bg-black/40 z-[55]"
          onClick={() => {
            setOverlayVisible(false)
            window.dispatchEvent(new CustomEvent('calc-close'))
          }}
        />
      )}
    </AuthGuard>
  )
}
