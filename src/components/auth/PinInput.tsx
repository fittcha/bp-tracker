'use client'

import { useState } from 'react'
import { authenticate } from '@/lib/auth'

interface PinInputProps {
  onSuccess: () => void
}

export default function PinInput({ onSuccess }: PinInputProps) {
  const [pin, setPin] = useState('')
  const [error, setError] = useState(false)

  function handleDigit(digit: string) {
    if (pin.length >= 4) return
    const newPin = pin + digit

    setPin(newPin)
    setError(false)

    if (newPin.length === 4) {
      if (authenticate(newPin)) {
        onSuccess()
      } else {
        setError(true)
        setTimeout(() => {
          setPin('')
          setError(false)
        }, 500)
      }
    }
  }

  function handleDelete() {
    setPin(prev => prev.slice(0, -1))
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-background px-4">
      <h1 className="text-2xl font-bold text-foreground mb-2">BP Tracker</h1>
      <p className="text-sm text-text-secondary mb-8">PIN을 입력하세요</p>

      {/* PIN dots */}
      <div className={`flex gap-4 mb-8 ${error ? 'animate-shake' : ''}`}>
        {[0, 1, 2, 3].map(i => (
          <div
            key={i}
            className={`w-4 h-4 rounded-full transition-colors ${
              i < pin.length
                ? error ? 'bg-danger' : 'bg-accent'
                : 'bg-border'
            }`}
          />
        ))}
      </div>

      {/* Keypad */}
      <div className="grid grid-cols-3 gap-4 max-w-[240px]">
        {['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'].map((key) => (
          <button
            key={key}
            onClick={() => {
              if (key === 'del') handleDelete()
              else if (key) handleDigit(key)
            }}
            disabled={!key}
            className={`w-16 h-16 rounded-full flex items-center justify-center text-xl font-medium transition-colors ${
              key === 'del'
                ? 'text-text-secondary'
                : key
                ? 'bg-surface text-foreground active:bg-border'
                : ''
            }`}
          >
            {key === 'del' ? (
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 4H8l-7 8 7 8h13a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z" />
                <line x1="18" y1="9" x2="12" y2="15" />
                <line x1="12" y1="9" x2="18" y2="15" />
              </svg>
            ) : key}
          </button>
        ))}
      </div>
    </div>
  )
}
