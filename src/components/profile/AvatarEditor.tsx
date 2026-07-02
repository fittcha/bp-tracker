'use client'

import { useRef, useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import Avatar from '@/components/Avatar'
import AvatarCropModal from '@/components/profile/AvatarCropModal'
import { getUserProfile, uploadAvatar, updateAvatarUrl } from '@/lib/api/users'
import { k } from '@/lib/swr/keys'

interface AvatarEditorProps {
  uid: string
  username: string
}

// MY 탭 프로필: 현재 아바타 + 사진 변경/삭제. 업로드는 크롭 모달 경유.
export default function AvatarEditor({ uid, username }: AvatarEditorProps) {
  const { mutate } = useSWRConfig()
  const { data: profile } = useSWR(uid ? k.profile(uid) : null, () => getUserProfile(uid))
  const avatarUrl = profile?.avatarUrl ?? null
  const fileRef = useRef<HTMLInputElement>(null)
  const [imageSrc, setImageSrc] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const [err, setErr] = useState('')

  function pick(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    e.target.value = '' // 같은 파일 재선택 허용
    if (!file || !file.type.startsWith('image/')) return
    const reader = new FileReader()
    reader.onload = () => setImageSrc(typeof reader.result === 'string' ? reader.result : null)
    reader.readAsDataURL(file)
  }

  async function handleCropped(blob: Blob) {
    setBusy(true)
    setErr('')
    try {
      const url = await uploadAvatar(blob, uid)
      await updateAvatarUrl(uid, url)
      mutate(k.profile(uid))
      setImageSrc(null)
    } catch {
      setErr('사진을 저장하지 못했어요. 다시 시도해 주세요.')
    } finally {
      setBusy(false)
    }
  }

  async function handleRemove() {
    if (!confirm('프로필 사진을 삭제할까요?')) return
    setBusy(true)
    setErr('')
    try {
      await updateAvatarUrl(uid, null)
      mutate(k.profile(uid))
    } catch {
      setErr('삭제하지 못했어요. 다시 시도해 주세요.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="bg-surface border border-border rounded-xl p-4 flex items-center gap-4">
      <Avatar src={avatarUrl} name={username} size={64} />
      <div className="min-w-0 flex-1">
        <p className="text-sm font-bold text-foreground truncate">{username}</p>
        <div className="flex items-center gap-3 mt-1.5">
          <button
            onClick={() => fileRef.current?.click()}
            disabled={busy}
            className="text-xs font-semibold text-accent disabled:opacity-50"
          >
            사진 변경
          </button>
          {avatarUrl && (
            <button
              onClick={handleRemove}
              disabled={busy}
              className="text-xs font-medium text-text-secondary disabled:opacity-50"
            >
              삭제
            </button>
          )}
        </div>
        {err && <p className="text-xs text-danger mt-1">{err}</p>}
      </div>
      <input ref={fileRef} type="file" accept="image/*" onChange={pick} className="hidden" />
      {imageSrc && (
        <AvatarCropModal
          isOpen
          imageSrc={imageSrc}
          busy={busy}
          onCancel={() => { if (!busy) setImageSrc(null) }}
          onCropped={handleCropped}
        />
      )}
    </div>
  )
}
