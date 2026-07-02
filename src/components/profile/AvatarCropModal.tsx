'use client'

import { useCallback, useState } from 'react'
import Cropper, { type Area } from 'react-easy-crop'
import { getCroppedBlob } from '@/lib/image/crop'

interface AvatarCropModalProps {
  isOpen: boolean
  imageSrc: string
  busy?: boolean
  onCancel: () => void
  onCropped: (blob: Blob) => void
}

// 배경 스와치(테마 토큰 값). 투명 PNG·축소 여백을 채울 색.
const BG_SWATCHES: { label: string; value: string }[] = [
  { label: '흰색', value: '#FFFFFF' },
  { label: '크림', value: '#F3ECDC' },
  { label: '라이트', value: '#E8EDF3' },
  { label: '네이비', value: '#1E3A5F' },
]

// 정사각(원형 마스크) 크롭 + 확대 + 배경색. "적용" 시 256px JPEG Blob 전달.
export default function AvatarCropModal({ isOpen, imageSrc, busy = false, onCancel, onCropped }: AvatarCropModalProps) {
  const [crop, setCrop] = useState({ x: 0, y: 0 })
  const [zoom, setZoom] = useState(1)
  const [areaPixels, setAreaPixels] = useState<Area | null>(null)
  const [bgColor, setBgColor] = useState('#FFFFFF')
  const [err, setErr] = useState('')

  const onComplete = useCallback((_area: Area, pixels: Area) => setAreaPixels(pixels), [])

  if (!isOpen) return null

  async function apply() {
    if (!areaPixels) return
    setErr('')
    try {
      const blob = await getCroppedBlob(imageSrc, areaPixels, 256, bgColor)
      onCropped(blob)
    } catch {
      setErr('이미지를 처리하지 못했어요. 다시 시도해 주세요.')
    }
  }

  return (
    <div className="fixed inset-0 z-[130] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40" onClick={busy ? undefined : onCancel} />
      <div className="relative w-full max-w-xs bg-surface rounded-2xl p-4 max-h-[85vh] overflow-y-auto">
        <h3 className="text-base font-bold text-foreground mb-3">사진 편집</h3>
        <div className="relative w-full aspect-square rounded-xl overflow-hidden" style={{ background: bgColor }}>
          <Cropper
            image={imageSrc}
            crop={crop}
            zoom={zoom}
            aspect={1}
            cropShape="round"
            showGrid={false}
            onCropChange={setCrop}
            onZoomChange={setZoom}
            onCropComplete={onComplete}
          />
        </div>
        <div className="mt-3">
          <label className="block text-[11px] font-semibold text-text-secondary mb-1">확대</label>
          <input
            type="range"
            min={1}
            max={3}
            step={0.01}
            value={zoom}
            onChange={(e) => setZoom(Number(e.target.value))}
            className="w-full accent-accent"
          />
        </div>
        <div className="mt-3">
          <label className="block text-[11px] font-semibold text-text-secondary mb-1.5">배경색</label>
          <div className="flex items-center gap-2">
            {BG_SWATCHES.map((s) => {
              const selected = bgColor.toUpperCase() === s.value.toUpperCase()
              return (
                <button
                  key={s.value}
                  type="button"
                  onClick={() => setBgColor(s.value)}
                  aria-label={s.label}
                  aria-pressed={selected}
                  className={`w-7 h-7 rounded-full border transition-shadow ${selected ? 'ring-2 ring-accent ring-offset-1' : 'border-border'}`}
                  style={{ background: s.value }}
                />
              )
            })}
            {/* 커스텀 색 */}
            <label className="relative w-7 h-7 rounded-full overflow-hidden border border-border cursor-pointer" aria-label="직접 선택" title="직접 선택">
              <span
                aria-hidden
                className="absolute inset-0"
                style={{ background: 'conic-gradient(from 0deg, #f00, #ff0, #0f0, #0ff, #00f, #f0f, #f00)' }}
              />
              <input
                type="color"
                value={bgColor}
                onChange={(e) => setBgColor(e.target.value)}
                className="absolute inset-0 opacity-0 cursor-pointer"
              />
            </label>
          </div>
        </div>
        {err && <p className="text-xs text-danger mt-2">{err}</p>}
        <div className="grid grid-cols-2 gap-2.5 mt-4">
          <button
            onClick={onCancel}
            disabled={busy}
            className="py-2.5 rounded-xl border border-border text-sm font-medium text-text-secondary disabled:opacity-50"
          >
            취소
          </button>
          <button
            onClick={apply}
            disabled={busy || !areaPixels}
            className="py-2.5 rounded-xl bg-accent text-white text-sm font-semibold disabled:opacity-50"
          >
            {busy ? '저장 중…' : '적용'}
          </button>
        </div>
      </div>
    </div>
  )
}
