'use client'

import { useRouter } from 'next/navigation'
import PinInput from '@/components/auth/PinInput'

export default function LoginPage() {
  const router = useRouter()

  return (
    <PinInput onSuccess={() => router.push('/')} />
  )
}
