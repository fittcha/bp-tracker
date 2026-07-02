# 프로필 사진 업로드 설계

작성일: 2026-07-02
대상 앱: Road to Rx'd (Next.js 16 + Supabase, public 스키마, anon key, RLS allow-all)

## 1. 목적 / 범위

유저 계정에 프로필 사진(아바타)을 넣는다.

- **설정·업로드**: MY 탭. 파일 선택 → 정사각 **수동 크롭 UI**(react-easy-crop) → 클라이언트에서 256×256 JPEG로 내보내 Supabase Storage 업로드 → `users.avatar_url` 저장.
- **표시**: (a) MY 탭 프로필 영역(큰 아바타 + 변경/삭제), (b) 앱 헤더(작은 본인 아바타), (c) 다른 유저가 나오는 목록 — 공유 아이디 검색 결과, 받기(PendingShares) 모달, 공유 모달의 '대기 중' 목록.
- 사진 없으면 **이니셜 폴백**(username 첫 글자, 네이비 배경 + 크림 글자).

범위 밖(YAGNI): 다중 사진/갤러리, 서버측 이미지 변환, EXIF 회전 보정(react-easy-crop이 화면상 회전은 다루지 않으므로 필요 시 후속), 챌린지 카드/BottomNav 표시.

## 2. 데이터 모델 & 저장

### 2.1 스키마
`users` 테이블에 컬럼 추가:
```sql
alter table users add column if not exists avatar_url text;
```
`null` = 사진 없음(이니셜 폴백). 기존 `select('*')` 쿼리들(`getUserByUsername`, `searchUsersByUsername`)은 자동으로 이 컬럼을 포함한다.

### 2.2 Storage
Supabase Storage **공용 버킷 `avatars`** 사용(기존 `food-images` 패턴 재사용).
```sql
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;
```
정책(anon 업로드/수정/삭제/읽기 허용 — 앱의 RLS allow-all 관례):
```sql
create policy "avatars anon read"   on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars anon insert" on storage.objects for insert with check (bucket_id = 'avatars');
create policy "avatars anon update" on storage.objects for update using (bucket_id = 'avatars');
create policy "avatars anon delete" on storage.objects for delete using (bucket_id = 'avatars');
```
파일 경로: `${userId}/avatar-${Date.now()}.jpg`. **timestamp를 경로에 포함**해 업로드마다 URL이 바뀌게 한다(브라우저 캐시 자동 무효화 — stale 이미지 방지). 이전 파일은 방치(경로가 달라 덮어쓰지 않음; 정리는 YAGNI). 저장 포맷은 JPEG(quality 0.85), 256×256.

## 3. 캐싱 설계

이 앱의 SWR + localStorage 영속 캐시(`r2r-swr:*`)에 통합한다.

1. **이미지 파일**: timestamp 경로 → 사진 변경 시 URL 변경 → 브라우저가 URL 단위 HTTP 캐싱, 새 사진은 새 URL이라 자동 캐시버스트. 고정경로 upsert는 stale를 유발하므로 쓰지 않는다.
2. **본인 avatar_url(앱 상태)**: `AuthUser`(localStorage-auth)에 넣지 않고 **`k.profile(uid)` SWR 키**로 관리. `getUserProfile(uid)` → `{ username, avatarUrl }`. localStorage provider 덕에 재실행 시 즉시 표시 + 백그라운드 갱신. Header·MY가 이 키를 구독한다.
3. **변경 전파**: 사진 변경/삭제 후 바운드 `mutate(k.profile(uid))` 한 번 → Header·MY 동시 갱신.
4. **다른 유저 avatar**: 각자의 기존 쿼리에 얹힘 — 받기 모달은 `k.pendingShares`(캐시+갱신), 공유 검색은 캐시 없이 매번 fresh. select에 `avatar_url` 포함만 하면 된다. (다른 유저가 내 새 사진을 보는 것은 그들 쿼리 다음 갱신 때 자연 반영.)

`k`에 추가:
```ts
profile: (uid: string) => ['profile', uid] as const,
```

## 4. 컴포넌트 & 파일 구조

### 4.1 신규
- `src/components/Avatar.tsx` — 공용 표시 컴포넌트. `<Avatar src={url ?? null} name={username} size={px} />`.
  - src 있으면 원형 `<img>` (`object-cover`, `rounded-full`), 없으면 이니셜 원형(네이비 `bg-accent`, 크림 `text-accent-soft` 글자). 이니셜은 순수 함수 `getInitial(name)`로 계산.
  - size는 px 숫자. 글자 크기는 size에 비례(`Math.round(size * 0.42)`).
- `src/lib/image/crop.ts` — `getCroppedBlob(imageSrc: string, croppedAreaPixels: Area, outputSize?: number): Promise<Blob>`. react-easy-crop의 `croppedAreaPixels`(x,y,width,height)로 원본을 canvas에 그려 `outputSize`(기본 256) 정사각 JPEG Blob 생성. `Area` 타입은 `{ x:number; y:number; width:number; height:number }`(로컬 정의, react-easy-crop과 호환).
- `src/components/profile/AvatarCropModal.tsx` — 크롭 모달.
  - props: `isOpen`, `imageSrc: string`(선택 이미지 data URL), `onCancel()`, `onCropped(blob: Blob)`, `busy?: boolean`.
  - 내부: react-easy-crop `<Cropper aspect={1} cropShape="round" showGrid={false}>` + 줌 슬라이더(`range` 1~3). `onCropComplete`로 croppedAreaPixels 보관. "적용" → `getCroppedBlob` → `onCropped(blob)`. busy면 "적용" 로딩 표시.
  - 앱 모달 관례: `fixed inset-0 z-[100] flex items-center justify-center p-4` + backdrop `bg-black/40` + 패널 `bg-surface rounded-2xl max-h-[85vh]`. 크롭 영역은 정사각(예: `aspect-square w-full max-w-xs`) 상대 배치.
- `src/components/profile/AvatarEditor.tsx` — MY 탭에 들어갈 프로필 영역.
  - 현재 아바타(`Avatar` size 80) + username + "사진 변경" 버튼(+ 사진 있으면 "삭제").
  - 숨김 `<input type="file" accept="image/*">`. 파일 선택 → `FileReader`로 data URL → `AvatarCropModal` 오픈.
  - onCropped(blob) → `uploadAvatar(blob, uid)` → `updateAvatarUrl(uid, url)` → `mutate(k.profile(uid))` → 모달 닫기. 로딩/에러 상태 표시(에러 문구: "사진을 저장하지 못했어요. 다시 시도해 주세요.").
  - 삭제 → 확인 후 `updateAvatarUrl(uid, null)` → `mutate(k.profile(uid))`.
  - 이미지 아닌 파일은 파일 선택 단계에서 `accept`로 1차 차단, 방어적으로 `file.type.startsWith('image/')` 체크.

### 4.2 수정
- `src/lib/api/users.ts`
  - `User` 인터페이스에 `avatar_url?: string | null` 추가.
  - `uploadAvatar(file: Blob, userId: string): Promise<string>` — `avatars` 버킷 업로드 후 publicUrl 반환(경로 `${userId}/avatar-${Date.now()}.jpg`, `contentType: 'image/jpeg'`).
  - `updateAvatarUrl(userId: string, url: string | null): Promise<void>` — `users.avatar_url` 업데이트.
  - `getUserProfile(userId: string): Promise<{ username: string; avatarUrl: string | null }>` — id로 `username, avatar_url` 조회.
- `src/lib/api/workout-shares.ts`
  - `PendingShare`에 `avatarUrl: string | null`, `SentShare`에 `avatarUrl: string | null` 추가.
  - `getPendingShares`/`getSentPendingShares`의 유저 조회 `select('id, username')` → `select('id, username, avatar_url')`, 매핑에 avatarUrl 포함(`Map<id, {username, avatarUrl}>`).
- `src/lib/swr/keys.ts` — `profile` 키 추가.
- `src/components/Header.tsx` — username 옆에 작은 아바타. `const { data: profile } = useSWR(uid ? k.profile(uid) : null, () => getUserProfile(uid))`. `<Avatar src={profile?.avatarUrl ?? null} name={username} size={24} />`. uid 없으면 렌더 안 함.
- `src/app/my/page.tsx` — 상단(로그아웃 근처 프로필 영역)에 `<AvatarEditor uid={uid} username={user.username} />` 삽입.
- 공유 검색 결과 UI / PendingShares 모달 / 공유 '대기 중' 목록: 각 행에 `<Avatar size={32}>` 추가(해당 컴포넌트에서 `avatarUrl` 소비). 대상 파일은 구현 계획에서 정확히 지목한다(ShareWorkoutModal, PendingSharesModal).

## 5. 데이터 흐름 (업로드)

```
MY: 파일 선택
  → FileReader.readAsDataURL → imageSrc(data URL)
  → AvatarCropModal 열림 (react-easy-crop, aspect=1, cropShape=round, zoom)
  → "적용": getCroppedBlob(imageSrc, croppedAreaPixels, 256) → Blob(jpeg)
  → uploadAvatar(blob, uid) → Storage(avatars/${uid}/avatar-${ts}.jpg) → publicUrl
  → updateAvatarUrl(uid, publicUrl) → users.avatar_url
  → mutate(k.profile(uid)) → Header·MY 즉시 갱신
  → 모달 닫기
```

삭제:
```
"삭제" → confirm → updateAvatarUrl(uid, null) → mutate(k.profile(uid))
```

## 6. 의존성

- **react-easy-crop** 신규 추가(`npm i react-easy-crop`). 터치 핀치줌·드래그가 검증된 경량 라이브러리. Pretendard 등 이미 외부 리소스를 쓰는 앱이라 번들 의존 추가는 관례에 어긋나지 않음.

## 7. 에러 / 엣지 케이스

- 이미지 아닌 파일: `accept="image/*"` + `file.type` 체크로 무시.
- 업로드 실패: try/catch로 에러 상태 표시, 모달 유지(재시도 가능).
- 매우 큰 원본: 크롭+256px 리사이즈로 자동 축소되므로 업로드 용량 문제 없음.
- uid 없음(비로그인): Header 아바타 미렌더, MY는 기존대로.
- avatar_url이 깨진 URL: `<img onError>`로 이니셜 폴백 전환.

## 8. 테스트

- vitest 순수 함수만: `getInitial(name)` (빈 문자열/공백/유니코드 첫 글자 대문자화). canvas·Storage·react-easy-crop 상호작용은 단위테스트 대상 아님 → `tsc` 통과 + 수동 확인.
- 수동 확인: 업로드→크롭→표시(MY·헤더), 삭제→이니셜 복귀, 다른 유저 검색 결과 아바타, 사진 교체 시 URL 변경(캐시버스트).

## 9. 마이그레이션 / 배포

`supabase/migration-user-avatar.sql`(신규): §2.1 컬럼 + §2.2 버킷/정책. 라이브 1회 적용. Storage 버킷 생성은 대시보드로도 가능하나 SQL로 함께 문서화한다.
