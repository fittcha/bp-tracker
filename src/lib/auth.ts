'use client'

const AUTH_KEY = 'bp-tracker-auth'

export function isAuthenticated(): boolean {
  if (typeof window === 'undefined') return false
  return localStorage.getItem(AUTH_KEY) === 'true'
}

export function authenticate(pin: string): boolean {
  const correctPin = process.env.NEXT_PUBLIC_PIN || '1234'
  if (pin === correctPin) {
    localStorage.setItem(AUTH_KEY, 'true')
    return true
  }
  return false
}

export function logout() {
  localStorage.removeItem(AUTH_KEY)
}
