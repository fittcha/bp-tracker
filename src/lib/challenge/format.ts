// 난이도 jsonb → 사람이 읽는 요약 (대시보드 카드 + 홈 위젯 공용).
// 항상 {label} 보유. 풀업 밴디드=bands[], 웨이티드=weight_kg 부가 표시.
export function formatDifficulty(difficulty: Record<string, unknown>): string {
  const label = String(difficulty.label ?? difficulty.difficulty_key ?? '')
  const dk = difficulty.difficulty_key
  if (dk === 'banded' && Array.isArray(difficulty.bands) && difficulty.bands.length > 0) {
    const bands = difficulty.bands as Array<{ color?: unknown; count?: unknown }>
    const parts = bands.map((b) => `${String(b.color)} ${String(b.count)}`).join(' · ')
    return `${label} / ${parts}`
  }
  if (dk === 'weighted' && difficulty.weight_kg != null && difficulty.weight_kg !== 0) {
    return `${label} / +${String(difficulty.weight_kg)}kg`
  }
  return label
}
