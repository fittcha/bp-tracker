// username → 아바타 이니셜(첫 글자 대문자, 유니코드 첫 코드포인트). 빈값은 '?'.
export function getInitial(name: string): string {
  const trimmed = (name ?? '').trim()
  if (!trimmed) return '?'
  return [...trimmed][0].toUpperCase()
}
