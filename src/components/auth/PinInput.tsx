'use client'

import { useState, useEffect, useCallback } from 'react'

interface PinInputProps {
  title: string
  onComplete: (pin: string) => void
  error: boolean
  onErrorReset: () => void
}

export default function PinInput({ title, onComplete, error, onErrorReset }: PinInputProps) {
  const [pin, setPin] = useState('')

  // When error becomes true, show red dots + shake, then reset after 500ms
  useEffect(() => {
    if (!error) return
    const timer = setTimeout(() => {
      setPin('')
      onErrorReset()
    }, 500)
    return () => clearTimeout(timer)
  }, [error, onErrorReset])

  const handleDigit = useCallback((digit: string) => {
    if (error) return
    setPin(prev => {
      if (prev.length >= 4) return prev
      const newPin = prev + digit
      if (newPin.length === 4) {
        // Defer onComplete to next tick so state updates first
        setTimeout(() => onComplete(newPin), 0)
      }
      return newPin
    })
  }, [error, onComplete])

  const handleDelete = useCallback(() => {
    if (error) return
    setPin(prev => prev.slice(0, -1))
  }, [error])

  return (
    <div className="flex flex-col items-center">
      <p className="text-sm text-text-secondary mb-8">{title}</p>

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
            key={key || 'empty'}
            type="button"
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
