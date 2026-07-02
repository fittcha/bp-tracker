# 프로필 사진 업로드 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 유저 계정에 프로필 사진(아바타)을 추가한다 — MY 탭에서 크롭 업로드, 헤더·공유 목록에 표시, 없으면 이니셜 폴백.

**Architecture:** `users.avatar_url` 컬럼 + Supabase Storage `avatars` 공용 버킷. MY 탭에서 파일 선택 → react-easy-crop 정사각 크롭 → canvas로 256×256 JPEG Blob → 타임스탬프 경로로 업로드(자동 캐시버스트) → `avatar_url` 저장. 본인 아바타는 `k.profile(uid)` SWR로 구독해 헤더·MY가 `mutate` 한 번으로 갱신. 다른 유저 아바타는 기존 유저 조회 쿼리에 `avatar_url`만 얹어 표시.

**Tech Stack:** Next.js 16 (App Router, 'use client'), React 19, TypeScript, Tailwind v4, Supabase (public 스키마, anon key, RLS allow-all, Storage), SWR 2.x(localStorage provider), vitest, react-easy-crop.

## Global Constraints

- **테마 토큰**(globals.css): `--accent #1E3A5F`(네이비), `--accent-pop #C0974A`(골드), `--accent-soft #F3ECDC`(크림), `--surface`, `--background`, `--foreground`, `--text-secondary`, `--border`, `--danger`. Tailwind 클래스 `bg-accent`, `text-accent-soft`, `text-danger` 등으로 사용.
- **모달 관례**: `fixed inset-0 z-[100] flex items-center justify-center p-4` + backdrop `bg-black/40` + 패널 `bg-surface rounded-2xl max-h-[85vh] overflow-y-auto`. BottomNav는 `z-50`, PendingSharesModal은 `z-[120]` — 크롭 모달은 그 위 `z-[130]`.
- **SWR mutate**: 반드시 `useSWRConfig()`의 바운드 `mutate` 사용(전역 `import { mutate }` 금지). 키는 `src/lib/swr/keys.ts`의 `k` 팩토리.
- **캐싱**: 이미지 경로에 `Date.now()` 타임스탬프 포함(URL 변경=캐시버스트). 본인 avatar_url은 `AuthUser`(localStorage-auth)에 넣지 않고 `k.profile(uid)` SWR로만 관리.
- **이미지 출력 포맷**: 정사각 256×256, JPEG, quality 0.85.
- **의존성**: `react-easy-crop` 신규 추가.
- **UI 문구**: 한국어. 에러 문구는 "…하지 못했어요. 다시 시도해 주세요." 톤.
- **테스트**: 순수 로직만 vitest(`npm test` = `vitest run`). supabase 래퍼·canvas·React 컴포넌트는 유닛테스트 없음(기존 코드 관례: `uploadFoodImage`도 무테스트) → `npx tsc --noEmit`로 타입 검증 + 수동 확인.
- **파일 상단**: 클라이언트 컴포넌트/훅 사용 파일은 `'use client'` 첫 줄.

---

### Task 1: 스키마·Storage 마이그레이션 + users API + SWR 키

DB 컬럼/버킷과 아바타용 API 함수, SWR 키를 만든다. 이후 모든 태스크의 토대.

**Files:**
- Create: `supabase/migration-user-avatar.sql`
- Modify: `src/lib/api/users.ts` (User 인터페이스 + 3개 함수 추가)
- Modify: `src/lib/swr/keys.ts` (profile 키 추가)

**Interfaces:**
- Consumes: 기존 `supabase` (`src/lib/supabase.ts`의 `export const supabase`), 기존 `uploadFoodImage` 패턴(`src/lib/api/daily-logs.ts`).
- Produces:
  - `User.avatar_url?: string | null`
  - `uploadAvatar(file: Blob, userId: string): Promise<string>` — publicUrl 반환
  - `updateAvatarUrl(userId: string, url: string | null): Promise<void>`
  - `getUserProfile(userId: string): Promise<{ username: string; avatarUrl: string | null }>`
  - `k.profile(uid: string) => ['profile', uid]`

- [ ] **Step 1: 마이그레이션 SQL 작성**

Create `supabase/migration-user-avatar.sql`:

```sql
-- 프로필 사진(아바타): users.avatar_url + avatars 공용 버킷 + anon 정책
-- 라이브 1회 적용(재실행 안전).

alter table users add column if not exists avatar_url text;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars anon read"   on storage.objects;
drop policy if exists "avatars anon insert" on storage.objects;
drop policy if exists "avatars anon update" on storage.objects;
drop policy if exists "avatars anon delete" on storage.objects;
create policy "avatars anon read"   on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars anon insert" on storage.objects for insert with check (bucket_id = 'avatars');
create policy "avatars anon update" on storage.objects for update using (bucket_id = 'avatars');
create policy "avatars anon delete" on storage.objects for delete using (bucket_id = 'avatars');
```

- [ ] **Step 2: `User` 인터페이스에 avatar_url 추가**

`src/lib/api/users.ts` 의 `User` 인터페이스(4-11행) 수정 — `active?` 아래에 한 줄 추가:

```ts
export interface User {
  id: string
  username: string
  pin_hash: string | null
  created_by: string | null
  created_at: string
  active?: boolean
  avatar_url?: string | null
}
```

- [ ] **Step 3: 아바타 API 함수 3개 추가**

`src/lib/api/users.ts` 파일 맨 끝(`createUser` 함수 뒤)에 추가:

```ts
// 아바타 이미지 업로드(avatars 버킷). 경로에 timestamp 포함 → URL 변경으로 캐시버스트.
export async function uploadAvatar(file: Blob, userId: string): Promise<string> {
  const fileName = `${userId}/avatar-${Date.now()}.jpg`
  const { error } = await supabase.storage
    .from('avatars')
    .upload(fileName, file, { contentType: 'image/jpeg', upsert: false })
  if (error) throw error
  const { data } = supabase.storage.from('avatars').getPublicUrl(fileName)
  return data.publicUrl
}

export async function updateAvatarUrl(userId: string, url: string | null): Promise<void> {
  const { error } = await supabase.from('users').update({ avatar_url: url }).eq('id', userId)
  if (error) throw error
}

// 본인 프로필(username + 아바타). k.profile SWR 페처.
export async function getUserProfile(userId: string): Promise<{ username: string; avatarUrl: string | null }> {
  const { data, error } = await supabase
    .from('users').select('username, avatar_url').eq('id', userId).single()
  if (error) throw error
  return { username: data.username as string, avatarUrl: (data.avatar_url as string | null) ?? null }
}
```

- [ ] **Step 4: SWR `profile` 키 추가**

`src/lib/swr/keys.ts` 의 `k` 객체에서 `pendingShares` 줄 아래에 추가:

```ts
  pendingShares: (uid: string) => ['pending-shares', uid] as const,
  profile: (uid: string) => ['profile', uid] as const,
}
```

- [ ] **Step 5: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 에러 없음(exit 0).

유닛테스트 없음 — supabase Storage/DB 래퍼는 기존 `uploadFoodImage`와 동일하게 무테스트, 타입 검증으로 갈음.

- [ ] **Step 6: Commit**

```bash
git add supabase/migration-user-avatar.sql src/lib/api/users.ts src/lib/swr/keys.ts
git commit -m "feat(profile): avatar 스키마/Storage 마이그레이션 + users API + SWR 키"
```

---

### Task 2: `getInitial` 순수 함수 + `Avatar` 공용 컴포넌트

이니셜 폴백 로직(TDD)과 표시 컴포넌트.

**Files:**
- Create: `src/lib/avatar.ts`
- Create: `src/lib/avatar.test.ts`
- Create: `src/components/Avatar.tsx`

**Interfaces:**
- Produces:
  - `getInitial(name: string): string`
  - `Avatar` (default export) props: `{ src?: string | null; name: string; size?: number; className?: string }`

- [ ] **Step 1: 실패하는 테스트 작성**

Create `src/lib/avatar.test.ts`:

```ts
import { describe, it, expect } from 'vitest'
import { getInitial } from './avatar'

describe('getInitial', () => {
  it('영문 첫 글자를 대문자로', () => {
    expect(getInitial('alice')).toBe('A')
    expect(getInitial('Bob')).toBe('B')
  })
  it('앞뒤 공백을 무시', () => {
    expect(getInitial('  spaced')).toBe('S')
  })
  it('빈 문자열/공백은 물음표', () => {
    expect(getInitial('')).toBe('?')
    expect(getInitial('   ')).toBe('?')
  })
  it('한글 첫 글자', () => {
    expect(getInitial('지수')).toBe('지')
  })
  it('유니코드(이모지) 첫 코드포인트', () => {
    expect(getInitial('🔥nova')).toBe('🔥')
  })
})
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `npx vitest run src/lib/avatar.test.ts`
Expected: FAIL — `getInitial` 을 './avatar'에서 찾을 수 없음(모듈 없음).

- [ ] **Step 3: `getInitial` 구현**

Create `src/lib/avatar.ts`:

```ts
// username → 아바타 이니셜(첫 글자 대문자, 유니코드 첫 코드포인트). 빈값은 '?'.
export function getInitial(name: string): string {
  const trimmed = (name ?? '').trim()
  if (!trimmed) return '?'
  return [...trimmed][0].toUpperCase()
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `npx vitest run src/lib/avatar.test.ts`
Expected: PASS (5 passed).

- [ ] **Step 5: `Avatar` 컴포넌트 구현**

Create `src/components/Avatar.tsx`:

```tsx
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
```

- [ ] **Step 6: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 에러 없음.

- [ ] **Step 7: Commit**

```bash
git add src/lib/avatar.ts src/lib/avatar.test.ts src/components/Avatar.tsx
git commit -m "feat(profile): getInitial 유틸 + Avatar 공용 컴포넌트"
```

---

### Task 3: react-easy-crop 설치 + 크롭 유틸 + 크롭 모달

정사각 크롭 UI와 canvas 내보내기.

**Files:**
- Modify: `package.json` (react-easy-crop 의존성 — `npm i`로)
- Create: `src/lib/image/crop.ts`
- Create: `src/components/profile/AvatarCropModal.tsx`

**Interfaces:**
- Consumes: react-easy-crop `Cropper`, 기존 테마/모달 관례.
- Produces:
  - `Area` 타입: `{ x: number; y: number; width: number; height: number }` (crop.ts export)
  - `getCroppedBlob(imageSrc: string, area: Area, outputSize?: number): Promise<Blob>` (기본 outputSize=256)
  - `AvatarCropModal` (default export) props: `{ isOpen: boolean; imageSrc: string; busy?: boolean; onCancel: () => void; onCropped: (blob: Blob) => void }`

- [ ] **Step 1: react-easy-crop 설치**

Run: `npm i react-easy-crop`
Expected: `package.json` dependencies에 `react-easy-crop` 추가, 설치 성공.

- [ ] **Step 2: 크롭 유틸 구현**

Create `src/lib/image/crop.ts`:

```ts
// react-easy-crop의 croppedAreaPixels(원본 픽셀 좌표)로 정사각 JPEG Blob 생성.
export interface Area {
  x: number
  y: number
  width: number
  height: number
}

export function getCroppedBlob(imageSrc: string, area: Area, outputSize = 256): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = outputSize
      canvas.height = outputSize
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        reject(new Error('canvas context를 만들 수 없어요'))
        return
      }
      ctx.drawImage(img, area.x, area.y, area.width, area.height, 0, 0, outputSize, outputSize)
      canvas.toBlob(
        (blob) => (blob ? resolve(blob) : reject(new Error('이미지 변환에 실패했어요'))),
        'image/jpeg',
        0.85,
      )
    }
    img.onerror = () => reject(new Error('이미지를 불러오지 못했어요'))
    img.src = imageSrc
  })
}
```

- [ ] **Step 3: 크롭 모달 구현**

Create `src/components/profile/AvatarCropModal.tsx`:

```tsx
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

// 정사각(원형 마스크) 크롭 + 확대 슬라이더. "적용" 시 256px JPEG Blob 전달.
export default function AvatarCropModal({ isOpen, imageSrc, busy = false, onCancel, onCropped }: AvatarCropModalProps) {
  const [crop, setCrop] = useState({ x: 0, y: 0 })
  const [zoom, setZoom] = useState(1)
  const [areaPixels, setAreaPixels] = useState<Area | null>(null)
  const [err, setErr] = useState('')

  const onComplete = useCallback((_area: Area, pixels: Area) => setAreaPixels(pixels), [])

  if (!isOpen) return null

  async function apply() {
    if (!areaPixels) return
    setErr('')
    try {
      const blob = await getCroppedBlob(imageSrc, areaPixels, 256)
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
        <div className="relative w-full aspect-square rounded-xl overflow-hidden bg-foreground/5">
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
```

주: `Area` 를 react-easy-crop에서 import한다(crop.ts의 `Area`와 구조가 동일해 `getCroppedBlob`에 그대로 전달 가능). crop.ts는 react-easy-crop 비의존(독립 테스트/재사용 가능).

- [ ] **Step 4: 타입 검증 + 빌드**

Run: `npx tsc --noEmit`
Expected: 에러 없음.

canvas·react-easy-crop 상호작용은 유닛테스트 없음 → 타입 검증으로 갈음, 실동작은 Task 4 이후 수동 확인.

- [ ] **Step 5: Commit**

```bash
git add package.json package-lock.json src/lib/image/crop.ts src/components/profile/AvatarCropModal.tsx
git commit -m "feat(profile): react-easy-crop 크롭 유틸 + 크롭 모달"
```

---

### Task 4: `AvatarEditor` + MY 탭 연결

MY 탭에서 업로드/크롭/삭제하는 프로필 영역.

**Files:**
- Create: `src/components/profile/AvatarEditor.tsx`
- Modify: `src/app/my/page.tsx` (import + return 최상단 삽입)

**Interfaces:**
- Consumes: `Avatar`(Task 2), `AvatarCropModal`(Task 3), `uploadAvatar`/`updateAvatarUrl`/`getUserProfile`(Task 1), `k.profile`(Task 1).
- Produces: `AvatarEditor` (default export) props: `{ uid: string; username: string }`

- [ ] **Step 1: `AvatarEditor` 구현**

Create `src/components/profile/AvatarEditor.tsx`:

```tsx
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
```

- [ ] **Step 2: MY 탭에 import 추가**

`src/app/my/page.tsx` 상단 import 블록에 추가(다른 컴포넌트 import 근처):

```ts
import AvatarEditor from '@/components/profile/AvatarEditor'
```

- [ ] **Step 3: MY 탭 return 최상단에 삽입**

`src/app/my/page.tsx` 133-135행. `return ( <div className="space-y-4 pb-4">` 바로 다음, `{/* Date picker */}` 앞에 삽입:

```tsx
  return (
    <div className="space-y-4 pb-4">
      {uid && user && <AvatarEditor uid={uid} username={user.username} />}

      {/* Date picker */}
```

(`user`/`uid`는 이미 파일 상단에 `const user = getLoggedInUser()`, `const uid = user?.id ?? ''`로 존재.)

- [ ] **Step 4: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 에러 없음.

- [ ] **Step 5: 빌드 확인(전체 통합)**

Run: `npm run build`
Expected: 빌드 성공(타입/린트 에러 없음).

- [ ] **Step 6: 수동 확인(리뷰어 안내)**

`npm run dev` 후 MY 탭: 프로필 영역 표시 → "사진 변경" → 파일 선택 → 크롭 모달(확대·드래그) → "적용" → 아바타 반영 → 헤더는 Task 5 후 확인 → "삭제" → 이니셜 복귀.

- [ ] **Step 7: Commit**

```bash
git add src/components/profile/AvatarEditor.tsx src/app/my/page.tsx
git commit -m "feat(profile): AvatarEditor + MY 탭 연결"
```

---

### Task 5: 헤더 아바타

앱 헤더 우측(username 옆)에 본인 아바타. `k.profile` SWR 구독으로 변경 즉시 반영.

**Files:**
- Modify: `src/components/Header.tsx`

**Interfaces:**
- Consumes: `Avatar`(Task 2), `getUserProfile`/`k.profile`(Task 1).

- [ ] **Step 1: import + SWR 추가**

`src/components/Header.tsx` 상단 import에 추가:

```ts
import Avatar from '@/components/Avatar'
import { getUserProfile } from '@/lib/api/users'
```

`export default function Header() {` 본문에서 `const username = ...` 아래에 uid + profile SWR 추가:

```tsx
  const user = getLoggedInUser()
  const uid = user?.id ?? ''
  const username = user?.username ?? toDateString(new Date())
  const { data: profile } = useSWR(uid ? k.profile(uid) : null, () => getUserProfile(uid))
```

(파일에 이미 `import useSWR from 'swr'`, `import { k } from '@/lib/swr/keys'` 존재.)

- [ ] **Step 2: username 우측 표시부 교체**

`src/components/Header.tsx` 36-37행. 현재:

```tsx
          <h1 className="text-sm font-bold text-foreground">Road to Rx&apos;d</h1>
          <span className="text-xs text-text-secondary">{username}</span>
```

를 아래로 교체(username 앞에 작은 아바타):

```tsx
          <h1 className="text-sm font-bold text-foreground">Road to Rx&apos;d</h1>
          <div className="flex items-center gap-2">
            {uid && <Avatar src={profile?.avatarUrl ?? null} name={username} size={22} />}
            <span className="text-xs text-text-secondary">{username}</span>
          </div>
```

- [ ] **Step 3: 타입 검증**

Run: `npx tsc --noEmit`
Expected: 에러 없음.

- [ ] **Step 4: 수동 확인**

`npm run dev` → 헤더 우측에 아바타 표시. MY에서 사진 변경/삭제 시 헤더가 즉시 갱신(같은 `k.profile(uid)` 구독).

- [ ] **Step 5: Commit**

```bash
git add src/components/Header.tsx
git commit -m "feat(profile): 헤더에 본인 아바타 표시"
```

---

### Task 6: 다른 유저 아바타 — 공유 API + 공유/받기 모달

공유 검색 결과·공유 대기 목록·받은 공유 카드에 상대 유저 아바타.

**Files:**
- Modify: `src/lib/api/workout-shares.ts` (PendingShare/SentShare + 조회 2곳)
- Modify: `src/components/workout/ShareWorkoutModal.tsx` (검색 결과 행 + 대기 행)
- Modify: `src/components/PendingSharesModal.tsx` (받은 카드)

**Interfaces:**
- Consumes: `Avatar`(Task 2), `User.avatar_url`(Task 1, `searchUsersByUsername`가 `select('*')`로 이미 포함).
- Produces:
  - `PendingShare { id; fromUsername; title; avatarUrl: string | null }`
  - `SentShare { id; toUsername; avatarUrl: string | null }`

- [ ] **Step 1: 공유 인터페이스에 avatarUrl 추가**

`src/lib/api/workout-shares.ts` 5-6행 교체:

```ts
export interface PendingShare { id: string; fromUsername: string; title: string; avatarUrl: string | null }
export interface SentShare { id: string; toUsername: string; avatarUrl: string | null }
```

- [ ] **Step 2: `getPendingShares` 유저 조회에 avatar_url 포함**

`src/lib/api/workout-shares.ts` 의 `getPendingShares` 안(41-44행) 교체:

```ts
  const { data: us, error: ue } = await supabase.from('users').select('id, username, avatar_url').in('id', fromIds)
  if (ue) throw ue
  const byId = new Map(
    (us ?? []).map((u) => [u.id as string, { username: u.username as string, avatarUrl: (u.avatar_url as string | null) ?? null }]),
  )
  return rows.map((r) => {
    const info = byId.get(r.from_user_id)
    return { id: r.id, fromUsername: info?.username ?? '알 수 없음', title: r.payload?.title ?? '운동', avatarUrl: info?.avatarUrl ?? null }
  })
```

- [ ] **Step 3: `getSentPendingShares` 유저 조회에 avatar_url 포함**

`src/lib/api/workout-shares.ts` 의 `getSentPendingShares` 안(56-59행) 교체:

```ts
  const { data: us, error: ue } = await supabase.from('users').select('id, username, avatar_url').in('id', toIds)
  if (ue) throw ue
  const byId = new Map(
    (us ?? []).map((u) => [u.id as string, { username: u.username as string, avatarUrl: (u.avatar_url as string | null) ?? null }]),
  )
  return rows.map((r) => {
    const info = byId.get(r.to_user_id)
    return { id: r.id, toUsername: info?.username ?? '알 수 없음', avatarUrl: info?.avatarUrl ?? null }
  })
```

- [ ] **Step 4: 기존 공유 테스트 회귀 확인**

Run: `npm test`
Expected: 기존 테스트 전부 PASS(`share-payload.test.ts` 등, 인터페이스 필드 추가는 페이로드 로직 무관).

- [ ] **Step 5: ShareWorkoutModal — Avatar import + 검색 결과 행**

`src/components/workout/ShareWorkoutModal.tsx` 상단 import에 추가:

```ts
import Avatar from '@/components/Avatar'
```

검색 결과 행 152행. 현재:

```tsx
                    <span className="text-sm text-foreground flex-1 font-medium">{u.username}</span>
```

를 교체(체크박스와 username 사이에 아바타):

```tsx
                    <Avatar src={u.avatar_url ?? null} name={u.username} size={28} />
                    <span className="text-sm text-foreground flex-1 font-medium">{u.username}</span>
```

- [ ] **Step 6: ShareWorkoutModal — 공유 대기 행**

`src/components/workout/ShareWorkoutModal.tsx` 168-169행. 현재:

```tsx
                  <div key={p.id} className="flex items-center justify-between px-2.5 py-1.5 rounded-xl">
                    <span className="text-sm text-foreground font-medium">{p.toUsername}</span>
```

를 교체(아바타 + username 묶음):

```tsx
                  <div key={p.id} className="flex items-center justify-between px-2.5 py-1.5 rounded-xl">
                    <span className="flex items-center gap-2 min-w-0">
                      <Avatar src={p.avatarUrl ?? null} name={p.toUsername} size={24} />
                      <span className="text-sm text-foreground font-medium truncate">{p.toUsername}</span>
                    </span>
```

- [ ] **Step 7: PendingSharesModal — Avatar import + 받은 카드**

`src/components/PendingSharesModal.tsx` 상단 import에 추가:

```ts
import Avatar from '@/components/Avatar'
```

61-67행. 현재:

```tsx
            <div key={s.id} className="border border-border rounded-xl px-3 py-3">
              {/* 보낸 사람 */}
              <p className="text-[11px] text-text-secondary mb-0.5">
                <span className="font-bold text-foreground">{s.fromUsername}</span>님이 공유했어요
              </p>
              {/* 운동명 */}
              <p className="text-sm font-bold text-foreground">{s.title}</p>
```

를 교체(아바타 + 텍스트 가로 배치):

```tsx
            <div key={s.id} className="border border-border rounded-xl px-3 py-3">
              <div className="flex items-center gap-2.5">
                <Avatar src={s.avatarUrl ?? null} name={s.fromUsername} size={36} />
                <div className="min-w-0">
                  {/* 보낸 사람 */}
                  <p className="text-[11px] text-text-secondary mb-0.5">
                    <span className="font-bold text-foreground">{s.fromUsername}</span>님이 공유했어요
                  </p>
                  {/* 운동명 */}
                  <p className="text-sm font-bold text-foreground truncate">{s.title}</p>
                </div>
              </div>
```

주: 이 카드의 닫는 `</div>`(액션 버튼 블록 뒤, 원본 85행의 `</div>`)는 그대로 두면 새로 연 flex `<div>`와 카드 `<div>` 짝이 맞는다 — 카드 열림 `<div key>` + flex `<div>` 2개 열고, flex 닫기 1개를 위에서 넣었으니, 액션 버튼 뒤 카드 닫기 `</div>` 앞에 flex를 닫는 `</div>`를 추가해야 한다. Step 8에서 처리.

- [ ] **Step 8: PendingSharesModal — flex 컨테이너 닫기 태그 정합**

Step 7에서 `{/* 액션 버튼 */}` 위의 텍스트 묶음 flex를 열었으므로, 액션 버튼 블록은 그 flex 밖(카드 직속)에 있어야 한다. Step 7 교체 결과에서 텍스트 묶음 flex를 운동명 `<p>` 뒤에 바로 닫도록 이미 구성했다(위 코드의 마지막 두 줄 `</div></div>`가 `min-w-0` div와 flex div를 닫음). 액션 버튼 블록(69-84행)은 변경 없이 카드 `<div>` 직속으로 유지된다. 확인만 하고 별도 수정 불필요.

Run: `npx tsc --noEmit`
Expected: 에러 없음(JSX 태그 짝 정합).

- [ ] **Step 9: 빌드 확인**

Run: `npm run build`
Expected: 빌드 성공.

- [ ] **Step 10: 수동 확인**

두 유저 계정으로: A가 사진 설정 → B의 공유 검색에서 A 아바타 표시, A→B 공유 시 B의 받은 카드에 A 아바타, A의 공유 모달 '대기 중'에 B 아바타(있으면).

- [ ] **Step 11: Commit**

```bash
git add src/lib/api/workout-shares.ts src/components/workout/ShareWorkoutModal.tsx src/components/PendingSharesModal.tsx
git commit -m "feat(profile): 공유 검색/받기/대기 목록에 유저 아바타"
```

---

## 배포 후 액션(구현 외)

- `supabase/migration-user-avatar.sql` 를 라이브 Supabase에 1회 적용(SQL 에디터). 미적용 시 avatar 컬럼/버킷 없어 업로드 실패.
- (별건 리마인더) 기존 `supabase/migration-workout-shares.sql` 도 아직 라이브 미적용이면 함께 적용 필요.

## Self-Review

**1. Spec coverage:**
- 스키마 avatar_url + avatars 버킷/정책 → Task 1 ✅
- 캐싱(timestamp URL, k.profile SWR, mutate 전파) → Task 1(키/업로드 경로) + Task 4/5(구독·mutate) ✅
- Avatar 컴포넌트(이니셜 폴백) → Task 2 ✅
- crop.ts + AvatarCropModal(react-easy-crop) → Task 3 ✅
- AvatarEditor + MY 연결 → Task 4 ✅
- 헤더 아바타 → Task 5 ✅
- 다른 유저 아바타(공유 검색/받기/대기) + workout-shares select → Task 6 ✅
- 에러/엣지(비이미지 차단, 업로드 실패 문구, onError 폴백, uid 없음) → Task 2(onError)/Task 4(pick·catch)/Task 5(uid 가드) ✅
- 테스트(getInitial 유닛 + tsc/수동) → Task 2 + 각 태스크 tsc ✅

**2. Placeholder scan:** "TBD/TODO/적절히" 없음. 모든 코드 단계에 완전한 코드 포함.

**3. Type consistency:** `uploadAvatar(file: Blob, userId)`, `updateAvatarUrl(userId, url|null)`, `getUserProfile→{username, avatarUrl}`, `k.profile(uid)`, `Avatar{src,name,size}`, `getCroppedBlob(imageSrc, area, outputSize)`, `Area{x,y,width,height}`, `PendingShare.avatarUrl`/`SentShare.avatarUrl` — 태스크 간 명칭·시그니처 일치 확인.
