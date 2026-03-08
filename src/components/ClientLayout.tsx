'use client'

import Header from '@/components/Header'
import BottomNav from '@/components/BottomNav'

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Header />
      <main className="max-w-lg mx-auto px-4 pt-4 pb-20">
        {children}
      </main>
      <BottomNav />
    </>
  )
}
