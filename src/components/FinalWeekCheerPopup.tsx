'use client'

import { useState, useEffect } from 'react'
import { getLoggedInUser } from '@/lib/auth'

// 1회 노출 기록 키 (브라우저당)
const STORAGE_KEY = 'bp-cheer-final-week'

// 표시 구간: 06-15 05:00 KST(=06-14 20:00 UTC) ~ 06-21 00:00 KST(=06-20 15:00 UTC)
const WINDOW_START = Date.UTC(2026, 5, 14, 20, 0, 0)
const WINDOW_END = Date.UTC(2026, 5, 20, 15, 0, 0)
// chacha 테스트 모드 종료: 내일 09:00 KST(=06-15 00:00 UTC) — 그 전까지 chacha는 열 때마다 매번 표시
const CHACHA_TEST_END = Date.UTC(2026, 5, 15, 0, 0, 0)

export default function FinalWeekCheerPopup() {
  const [show, setShow] = useState(false)
  // 테스트 모드: 닫아도 localStorage에 기록하지 않아 다음 접속에 다시 표시
  const [testMode, setTestMode] = useState(false)

  useEffect(() => {
    const now = Date.now()
    const user = getLoggedInUser()

    // chacha 한정 테스트: 종료 시각 전까지 열 때마다 표시
    if (user?.username === 'chacha' && now < CHACHA_TEST_END) {
      setTestMode(true)
      setShow(true)
      return
    }

    // 일반: 마지막 주 구간 내 첫 접속 1회
    const inWindow = now >= WINDOW_START && now < WINDOW_END
    const dismissed = localStorage.getItem(STORAGE_KEY) === 'done'
    if (inWindow && !dismissed) setShow(true)
  }, [])

  function handleDismiss() {
    if (!testMode) localStorage.setItem(STORAGE_KEY, 'done')
    setShow(false)
  }

  if (!show) return null

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center bg-black/40">
      <div className="relative bg-surface rounded-2xl shadow-xl mx-6 max-w-sm w-full p-6 pt-9 text-left">
        <button
          onClick={handleDismiss}
          aria-label="닫기"
          className="absolute top-3 right-3 w-7 h-7 flex items-center justify-center rounded-full text-text-secondary active:bg-border/50"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
        <div className="space-y-4 text-sm text-text-secondary leading-relaxed border-l-[3px] border-text-secondary/30 pl-4">
          <p>드디어 마지막 주입니다 🥳</p>
          <div>
            <p>15주 동안 열심히 달려오느라 정말 고생 많았어요!</p>
            <p>남은 한 주도 컨디션 잘 챙기고,</p>
            <p>끝까지 나를 믿고 잘 마무리합시다 💪</p>
          </div>
          <p>6월 20일, 가장 멋진 모습으로 만나요! 🔥</p>
        </div>
      </div>
    </div>
  )
}
