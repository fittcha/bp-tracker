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
      <div className="bg-surface rounded-2xl shadow-xl mx-6 max-w-sm w-full p-6 text-center">
        <p className="text-base font-bold mb-4">마지막 한 주입니다 💪</p>
        <p className="text-sm text-text-secondary leading-relaxed">
          15주 동안 달려오느라 정말 고생 많았어요.
        </p>
        <p className="text-sm text-text-secondary leading-relaxed mb-4">
          컨디션 잘 챙기고, 끝까지 나를 믿고 잘 마무리하길 🙏
        </p>
        <p className="text-sm font-semibold mb-5">
          6월 20일, 가장 멋진 모습으로 봐요! 🔥
        </p>
        <button
          onClick={handleDismiss}
          className="w-full py-2 rounded-xl bg-accent text-white text-sm font-medium active:bg-accent/80"
        >
          확인
        </button>
      </div>
    </div>
  )
}
