'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import PinInput from '@/components/auth/PinInput'
import { setLoggedInUser, getLastUsername, setLastUsername } from '@/lib/auth'
import { getUserByUsername, setUserPin, verifyPin, type User } from '@/lib/api/users'

type Step = 'username' | 'pin-setup' | 'pin-setup-confirm' | 'pin-verify'

export default function LoginPage() {
  const router = useRouter()
  const [step, setStep] = useState<Step>('username')
  const [username, setUsername] = useState('')
  const [autoLogin, setAutoLogin] = useState(false)
  const [usernameError, setUsernameError] = useState('')
  const [loading, setLoading] = useState(false)
  const [pinError, setPinError] = useState(false)
  const [user, setUser] = useState<User | null>(null)
  const [setupPin, setSetupPin] = useState('')

  useEffect(() => {
    setUsername(getLastUsername())
  }, [])

  async function handleNext() {
    if (!username.trim()) return
    setUsernameError('')
    setLoading(true)
    try {
      const found = await getUserByUsername(username.trim())
      if (!found) {
        setUsernameError('등록되지 않은 사용자입니다')
        return
      }
      setUser(found)
      if (found.pin_hash === null) {
        setStep('pin-setup')
      } else {
        setStep('pin-verify')
      }
    } catch {
      setUsernameError('오류가 발생했습니다')
    } finally {
      setLoading(false)
    }
  }

  function completeLogin(u: User) {
    setLastUsername(u.username)
    setLoggedInUser({ id: u.id, username: u.username }, autoLogin)
    router.push('/')
  }

  // PIN setup: first entry
  const handleSetupPin = useCallback((pin: string) => {
    setSetupPin(pin)
    setStep('pin-setup-confirm')
  }, [])

  // PIN setup: confirm entry
  const handleConfirmPin = useCallback(async (pin: string) => {
    if (pin !== setupPin) {
      setPinError(true)
      return
    }
    if (!user) return
    try {
      await setUserPin(user.id, pin)
      completeLogin({ ...user, pin_hash: pin })
    } catch {
      setPinError(true)
    }
  }, [setupPin, user, autoLogin])

  // PIN verify
  const handleVerifyPin = useCallback(async (pin: string) => {
    if (!user) return
    try {
      const ok = await verifyPin(user.id, pin)
      if (ok) {
        completeLogin(user)
      } else {
        setPinError(true)
      }
    } catch {
      setPinError(true)
    }
  }, [user, autoLogin])

  const handlePinErrorReset = useCallback(() => {
    setPinError(false)
  }, [])

  // Username screen
  if (step === 'username') {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-background px-4">
        <h1 className="text-2xl font-bold text-foreground mb-8">BP Tracker</h1>

        <div className="w-full max-w-[320px] space-y-4">
          <input
            type="text"
            value={username}
            onChange={e => { setUsername(e.target.value); setUsernameError('') }}
            onKeyDown={e => { if (e.key === 'Enter') handleNext() }}
            placeholder="사용자 이름"
            className="w-full px-4 py-3 rounded-lg border border-border bg-surface text-foreground placeholder:text-text-secondary focus:outline-none focus:border-accent"
          />

          {usernameError && (
            <p className="text-sm text-danger">{usernameError}</p>
          )}

          <label className="flex items-center gap-2 text-sm text-text-secondary cursor-pointer">
            <input
              type="checkbox"
              checked={autoLogin}
              onChange={e => setAutoLogin(e.target.checked)}
              className="w-4 h-4 accent-accent"
            />
            자동 로그인
          </label>

          <button
            onClick={handleNext}
            disabled={loading || !username.trim()}
            className="w-full py-3 rounded-lg bg-accent text-white font-medium disabled:opacity-50 transition-opacity"
          >
            {loading ? '확인 중...' : '다음'}
          </button>
        </div>
      </div>
    )
  }

  // PIN screens
  let pinTitle = ''
  let pinHandler: (pin: string) => void

  if (step === 'pin-setup') {
    pinTitle = 'PIN을 설정해주세요'
    pinHandler = handleSetupPin
  } else if (step === 'pin-setup-confirm') {
    pinTitle = 'PIN을 한번 더 입력해주세요'
    pinHandler = handleConfirmPin
  } else {
    pinTitle = 'PIN을 입력하세요'
    pinHandler = handleVerifyPin
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-background px-4">
      <h1 className="text-2xl font-bold text-foreground mb-2">BP Tracker</h1>
      <PinInput
        key={step}
        title={pinTitle}
        onComplete={pinHandler}
        error={pinError}
        onErrorReset={handlePinErrorReset}
      />
    </div>
  )
}
