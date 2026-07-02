'use client'

import { useState } from 'react'
import { getInitial } from '@/lib/avatar'

interface AvatarProps {
  src?: string | null
  name: string
  size?: number
  className?: string
}

// src 있으면 원형 이미지(object-cover), 없거나 로드 실패면 이니셜 원형(네이비+크림).
export default function Avatar({ src, name, size = 40, className = '' }: AvatarProps) {
  const [failedSrc, setFailedSrc] = useState<string | null>(null)
  const showImg = !!src && failedSrc !== src
  const fontSize = Math.round(size * 0.42)
  return (
    <span
      className={`inline-flex items-center justify-center rounded-full overflow-hidden bg-accent text-accent-soft font-semibold shrink-0 select-none ${className}`}
      style={{ width: size, height: size, fontSize }}
    >
      {showImg ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={src as string}
          alt=""
          className="w-full h-full object-cover"
          onError={() => setFailedSrc(src ?? null)}
        />
      ) : (
        getInitial(name)
      )}
    </span>
  )
}
