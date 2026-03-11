'use client'

import { useState, useEffect } from 'react'

const CURRENT_VERSION = 'v1.1'
const STORAGE_KEY = 'bp-announcement-dismissed'

const announcements = [
  '🏋️ 나의 1RM 기록 — 요약 탭에서 운동별 1RM을 관리하세요',
  '🔢 무게 계산기 — 운동 탭 하단 계산기 버튼으로 입력한 무게 또는 1RM 대비 % 무게를 빠르게 계산',
  '⚖️ lb / kg 단위 선택 — 운동 기록 시 lb 클릭으로 kg 전환 가능',
]

export default function AnnouncementPopup() {
  const [show, setShow] = useState(false)

  useEffect(() => {
    const dismissed = localStorage.getItem(STORAGE_KEY)
    if (dismissed !== CURRENT_VERSION) setShow(true)
  }, [])

  function handleDismiss() {
    localStorage.setItem(STORAGE_KEY, CURRENT_VERSION)
    setShow(false)
  }

  if (!show) return null

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/40">
      <div className="bg-surface rounded-2xl shadow-xl mx-6 max-w-sm w-full p-5">
        <p className="text-sm font-bold mb-3">새로운 기능 안내 ✨</p>
        <ul className="space-y-2 mb-4">
          {announcements.map((text, i) => (
            <li key={i} className="text-sm text-text-secondary leading-relaxed">{text}</li>
          ))}
        </ul>
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
