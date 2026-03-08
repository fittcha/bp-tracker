'use client'

import { useEffect, useState } from 'react'
import { usePathname, useRouter } from 'next/navigation'
import { isAuthenticated } from '@/lib/auth'

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const [checked, setChecked] = useState(false)
  const [authed, setAuthed] = useState(false)
  const pathname = usePathname()
  const router = useRouter()

  useEffect(() => {
    const auth = isAuthenticated()
    setAuthed(auth)
    setChecked(true)

    if (!auth && pathname !== '/login') {
      router.replace('/login')
    }
  }, [pathname, router])

  if (!checked) return null

  if (pathname === '/login') {
    return <>{children}</>
  }

  if (!authed) return null

  return <>{children}</>
}
