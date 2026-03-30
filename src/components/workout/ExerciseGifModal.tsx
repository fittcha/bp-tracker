'use client'

import { useEffect, useState } from 'react'
import { getExerciseGif, type ExerciseGif } from '@/lib/api/exercise-db'

interface Props {
  exerciseName: string
  onClose: () => void
}

export default function ExerciseGifModal({ exerciseName, onClose }: Props) {
  const [gif, setGif] = useState<ExerciseGif | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)

  useEffect(() => {
    getExerciseGif(exerciseName).then(result => {
      if (result) setGif(result)
      else setError(true)
      setLoading(false)
    })
  }, [exerciseName])

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50"
      onClick={onClose}
    >
      <div
        className="bg-surface border border-border rounded-2xl mx-4 max-w-sm w-full overflow-hidden"
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-border">
          <p className="text-sm font-medium truncate">{exerciseName}</p>
          <button onClick={onClose} className="text-text-secondary">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        {/* Body */}
        <div className="p-4">
          {loading && (
            <div className="flex items-center justify-center h-48">
              <div className="w-8 h-8 border-2 border-accent border-t-transparent rounded-full animate-spin" />
            </div>
          )}
          {error && !loading && (
            <div className="flex flex-col items-center justify-center h-48 gap-3">
              <p className="text-text-secondary text-sm">GIF를 찾을 수 없습니다</p>
              <a
                href={`https://www.google.com/search?q=${encodeURIComponent(exerciseName)}&tbm=isch`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-accent underline"
              >
                Google에서 검색
              </a>
            </div>
          )}
          {gif && !loading && (
            <div className="space-y-3">
              <div className="flex justify-center bg-white rounded-xl">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={gif.gifUrl}
                  alt={gif.name}
                  className="max-h-64 object-contain"
                />
              </div>
              <div className="text-center space-y-1">
                <p className="text-xs text-text-secondary capitalize">{gif.name}</p>
                {gif.targetMuscles.length > 0 && (
                  <p className="text-xs text-accent">{gif.targetMuscles.join(', ')}</p>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
