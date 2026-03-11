'use client'

// 백스쿼트 - 정면, 바벨 어깨 위, 딥스쿼트, 두꺼운 라인 픽토그램
export function BackSquatIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="32" cy="10" r="5" strokeWidth="3" />
      {/* Barbell */}
      <line x1="8" y1="20" x2="56" y2="20" strokeWidth="3" />
      {/* Plates left */}
      <rect x="4" y="15" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="9" y="16" width="3" height="8" rx="0.5" strokeWidth="2" />
      {/* Plates right */}
      <rect x="56" y="15" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="52" y="16" width="3" height="8" rx="0.5" strokeWidth="2" />
      {/* Arms holding bar */}
      <path d="M22 20 C22 24, 26 28, 28 26" strokeWidth="3" fill="none" />
      <path d="M42 20 C42 24, 38 28, 36 26" strokeWidth="3" fill="none" />
      {/* Torso */}
      <path d="M28 26 L26 40" strokeWidth="3.5" />
      <path d="M36 26 L38 40" strokeWidth="3.5" />
      {/* Hips */}
      <path d="M26 40 Q32 44, 38 40" strokeWidth="3" />
      {/* Left leg - deep squat */}
      <path d="M26 40 C22 42, 16 44, 14 50" strokeWidth="3.5" />
      <path d="M14 50 C14 54, 16 56, 18 58" strokeWidth="3.5" />
      <line x1="18" y1="58" x2="12" y2="58" strokeWidth="3" />
      {/* Right leg - deep squat */}
      <path d="M38 40 C42 42, 48 44, 50 50" strokeWidth="3.5" />
      <path d="M50 50 C50 54, 48 56, 46 58" strokeWidth="3.5" />
      <line x1="46" y1="58" x2="52" y2="58" strokeWidth="3" />
    </svg>
  )
}

// 프론트스쿼트 - 정면, 프론트랙 팔꿈치 높이, 딥스쿼트
export function FrontSquatIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="32" cy="10" r="5" strokeWidth="3" />
      {/* Barbell at front rack - slightly lower */}
      <line x1="10" y1="24" x2="54" y2="24" strokeWidth="3" />
      {/* Plates */}
      <rect x="4" y="19" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="9" y="20" width="3" height="8" rx="0.5" strokeWidth="2" />
      <rect x="56" y="19" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="52" y="20" width="3" height="8" rx="0.5" strokeWidth="2" />
      {/* Arms - elbows up, front rack */}
      <path d="M26 24 L22 20 L24 16" strokeWidth="3" fill="none" />
      <path d="M38 24 L42 20 L40 16" strokeWidth="3" fill="none" />
      {/* Torso */}
      <path d="M28 24 L26 40" strokeWidth="3.5" />
      <path d="M36 24 L38 40" strokeWidth="3.5" />
      {/* Hips */}
      <path d="M26 40 Q32 44, 38 40" strokeWidth="3" />
      {/* Left leg */}
      <path d="M26 40 C22 42, 16 44, 14 50" strokeWidth="3.5" />
      <path d="M14 50 C14 54, 16 56, 18 58" strokeWidth="3.5" />
      <line x1="18" y1="58" x2="12" y2="58" strokeWidth="3" />
      {/* Right leg */}
      <path d="M38 40 C42 42, 48 44, 50 50" strokeWidth="3.5" />
      <path d="M50 50 C50 54, 48 56, 46 58" strokeWidth="3.5" />
      <line x1="46" y1="58" x2="52" y2="58" strokeWidth="3" />
    </svg>
  )
}

// 데드리프트 - 옆모습, 힙힌지, 바벨 당기기
export function DeadliftIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="18" cy="12" r="5" strokeWidth="3" />
      {/* Torso - bent forward ~45deg */}
      <path d="M20 17 L34 32" strokeWidth="4" />
      {/* Neck to back line */}
      <path d="M18 17 L20 17" strokeWidth="3" />
      {/* Arms straight down to bar */}
      <path d="M24 22 L26 42" strokeWidth="3" />
      <path d="M28 26 L30 42" strokeWidth="3" />
      {/* Barbell */}
      <line x1="14" y1="42" x2="50" y2="42" strokeWidth="3" />
      {/* Plates */}
      <rect x="8" y="36" width="4" height="12" rx="1" strokeWidth="2.5" />
      <rect x="13" y="37" width="3" height="10" rx="0.5" strokeWidth="2" />
      <rect x="52" y="36" width="4" height="12" rx="1" strokeWidth="2.5" />
      <rect x="49" y="37" width="3" height="10" rx="0.5" strokeWidth="2" />
      {/* Hips */}
      <path d="M34 32 L36 34" strokeWidth="3" />
      {/* Back leg */}
      <path d="M36 34 L38 46" strokeWidth="3.5" />
      <path d="M38 46 L40 56" strokeWidth="3.5" />
      <line x1="40" y1="56" x2="44" y2="56" strokeWidth="3" />
      {/* Front leg */}
      <path d="M34 32 L32 44" strokeWidth="3.5" />
      <path d="M32 44 L32 56" strokeWidth="3.5" />
      <line x1="32" y1="56" x2="36" y2="56" strokeWidth="3" />
    </svg>
  )
}

// 벤치프레스 - 옆모습, 누워서 팔꿈치 각도 밀기
export function BenchIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Bench */}
      <rect x="10" y="38" width="36" height="4" rx="2" strokeWidth="2.5" />
      {/* Bench legs */}
      <line x1="14" y1="42" x2="14" y2="54" strokeWidth="3" />
      <line x1="42" y1="42" x2="42" y2="54" strokeWidth="3" />
      {/* Head */}
      <circle cx="14" cy="30" r="4" strokeWidth="3" />
      {/* Body lying */}
      <path d="M18 31 L40 31" strokeWidth="4" />
      {/* Upper arm */}
      <path d="M24 31 L24 22" strokeWidth="3" />
      <path d="M32 31 L32 22" strokeWidth="3" />
      {/* Forearm - angled, pushing up */}
      <path d="M24 22 L28 14" strokeWidth="3" />
      <path d="M32 22 L36 14" strokeWidth="3" />
      {/* Barbell */}
      <line x1="22" y1="14" x2="44" y2="14" strokeWidth="3" />
      {/* Plates */}
      <rect x="16" y="10" width="4" height="8" rx="1" strokeWidth="2.5" />
      <rect x="21" y="11" width="3" height="6" rx="0.5" strokeWidth="2" />
      <rect x="46" y="10" width="4" height="8" rx="1" strokeWidth="2.5" />
      <rect x="43" y="11" width="3" height="6" rx="0.5" strokeWidth="2" />
      {/* Legs bent off bench */}
      <path d="M40 33 L46 42" strokeWidth="3" />
      <path d="M46 42 L48 54" strokeWidth="3" />
      <line x1="48" y1="54" x2="52" y2="54" strokeWidth="3" />
    </svg>
  )
}

// 숄더프레스 - 정면, 서서 오버헤드 프레스
export function OverheadIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="32" cy="18" r="5" strokeWidth="3" />
      {/* Barbell overhead */}
      <line x1="8" y1="6" x2="56" y2="6" strokeWidth="3" />
      {/* Plates */}
      <rect x="4" y="2" width="4" height="8" rx="1" strokeWidth="2.5" />
      <rect x="9" y="3" width="3" height="6" rx="0.5" strokeWidth="2" />
      <rect x="56" y="2" width="4" height="8" rx="1" strokeWidth="2.5" />
      <rect x="52" y="3" width="3" height="6" rx="0.5" strokeWidth="2" />
      {/* Arms pressing up - slight V */}
      <path d="M26 24 L22 16 L20 6" strokeWidth="3" fill="none" />
      <path d="M38 24 L42 16 L44 6" strokeWidth="3" fill="none" />
      {/* Torso */}
      <path d="M28 24 L28 42" strokeWidth="3.5" />
      <path d="M36 24 L36 42" strokeWidth="3.5" />
      {/* Hips */}
      <path d="M28 42 Q32 44, 36 42" strokeWidth="3" />
      {/* Left leg */}
      <path d="M28 42 L26 54" strokeWidth="3.5" />
      <line x1="26" y1="54" x2="22" y2="58" strokeWidth="3" />
      <line x1="22" y1="58" x2="18" y2="58" strokeWidth="3" />
      {/* Right leg */}
      <path d="M36 42 L38 54" strokeWidth="3.5" />
      <line x1="38" y1="54" x2="42" y2="58" strokeWidth="3" />
      <line x1="42" y1="58" x2="46" y2="58" strokeWidth="3" />
    </svg>
  )
}

// 클린 - 정면, 바벨 어깨 캐치, 파워 포지션
export function CleanIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="32" cy="8" r="5" strokeWidth="3" />
      {/* Barbell at shoulder/front rack */}
      <line x1="8" y1="20" x2="56" y2="20" strokeWidth="3" />
      {/* Plates */}
      <rect x="4" y="15" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="9" y="16" width="3" height="8" rx="0.5" strokeWidth="2" />
      <rect x="56" y="15" width="4" height="10" rx="1" strokeWidth="2.5" />
      <rect x="52" y="16" width="3" height="8" rx="0.5" strokeWidth="2" />
      {/* Arms - elbows forward catching bar */}
      <path d="M26 20 L22 16 L24 13" strokeWidth="3" fill="none" />
      <path d="M38 20 L42 16 L40 13" strokeWidth="3" fill="none" />
      {/* Torso */}
      <path d="M28 22 L27 36" strokeWidth="3.5" />
      <path d="M36 22 L37 36" strokeWidth="3.5" />
      {/* Hips */}
      <path d="M27 36 Q32 39, 37 36" strokeWidth="3" />
      {/* Left leg - quarter squat catch */}
      <path d="M27 36 C24 40, 20 44, 20 50" strokeWidth="3.5" />
      <path d="M20 50 L20 56" strokeWidth="3.5" />
      <line x1="20" y1="56" x2="15" y2="56" strokeWidth="3" />
      {/* Right leg */}
      <path d="M37 36 C40 40, 44 44, 44 50" strokeWidth="3.5" />
      <path d="M44 50 L44 56" strokeWidth="3.5" />
      <line x1="44" y1="56" x2="49" y2="56" strokeWidth="3" />
      {/* Motion lines - upward energy */}
      <line x1="10" y1="48" x2="10" y2="40" strokeWidth="1.5" strokeDasharray="2 3" />
      <line x1="54" y1="48" x2="54" y2="40" strokeWidth="1.5" strokeDasharray="2 3" />
    </svg>
  )
}

// 스내치 - 정면, 와이드그립 오버헤드, 딥스쿼트 캐치
export function SnatchIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Head */}
      <circle cx="32" cy="14" r="5" strokeWidth="3" />
      {/* Wide barbell overhead */}
      <line x1="4" y1="6" x2="60" y2="6" strokeWidth="3" />
      {/* Plates - wider apart */}
      <rect x="0" y="2" width="4" height="8" rx="1" strokeWidth="2.5" />
      <rect x="60" y="2" width="4" height="8" rx="1" strokeWidth="2.5" />
      {/* Arms wide V overhead */}
      <path d="M26 20 L18 12 L14 6" strokeWidth="3" fill="none" />
      <path d="M38 20 L46 12 L50 6" strokeWidth="3" fill="none" />
      {/* Torso */}
      <path d="M28 22 L26 36" strokeWidth="3.5" />
      <path d="M36 22 L38 36" strokeWidth="3.5" />
      {/* Hips */}
      <path d="M26 36 Q32 40, 38 36" strokeWidth="3" />
      {/* Left leg - deep squat */}
      <path d="M26 36 C22 38, 16 42, 14 48" strokeWidth="3.5" />
      <path d="M14 48 C14 52, 16 54, 18 56" strokeWidth="3.5" />
      <line x1="18" y1="56" x2="12" y2="56" strokeWidth="3" />
      {/* Right leg */}
      <path d="M38 36 C42 38, 48 42, 50 48" strokeWidth="3.5" />
      <path d="M50 48 C50 52, 48 54, 46 56" strokeWidth="3.5" />
      <line x1="46" y1="56" x2="52" y2="56" strokeWidth="3" />
    </svg>
  )
}

// 기본 아이콘 (커스텀 운동용) - 덤벨
export function DefaultExerciseIcon({ size = 24 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
      {/* Bar */}
      <line x1="20" y1="32" x2="44" y2="32" strokeWidth="4" />
      {/* Left dumbbell */}
      <rect x="8" y="24" width="12" height="16" rx="3" strokeWidth="3" />
      {/* Right dumbbell */}
      <rect x="44" y="24" width="12" height="16" rx="3" strokeWidth="3" />
    </svg>
  )
}

const ICON_MAP: Record<string, React.ComponentType<{ size?: number }>> = {
  '백스쿼트': BackSquatIcon,
  '프론트스쿼트': FrontSquatIcon,
  '데드리프트': DeadliftIcon,
  '벤치프레스': BenchIcon,
  '숄더프레스': OverheadIcon,
  '클린': CleanIcon,
  '스내치': SnatchIcon,
}

export function getExerciseIcon(exerciseName: string): React.ComponentType<{ size?: number }> {
  return ICON_MAP[exerciseName] ?? DefaultExerciseIcon
}
