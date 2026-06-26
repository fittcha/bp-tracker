'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Calendar, Dumbbell, Flame, Trophy, User } from 'lucide-react'

const tabs = [
  { href: '/', label: '홈', Icon: Calendar },
  { href: '/workout', label: '운동', Icon: Dumbbell },
  { href: '/challenge', label: '챌린지', Icon: Flame },
  { href: '/pr', label: 'PR', Icon: Trophy },
  { href: '/my', label: 'MY', Icon: User },
]

export default function BottomNav() {
  const pathname = usePathname()
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-surface border-t border-border">
      <div className="flex items-center justify-around max-w-lg mx-auto h-16">
        {tabs.map((tab) => {
          const isActive = pathname === tab.href
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center gap-1 px-3 py-2 text-xs transition-colors ${
                isActive ? 'text-accent-pop' : 'text-text-secondary'
              }`}
            >
              <tab.Icon size={22} strokeWidth={isActive ? 2.5 : 2} />
              <span className="font-medium">{tab.label}</span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
