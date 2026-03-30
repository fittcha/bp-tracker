const EXERCISEDB_BASE = 'https://exercisedb.dev/api/v1'

export interface ExerciseGif {
  exerciseId: string
  name: string
  gifUrl: string
  targetMuscles: string[]
}

// In-memory cache: search term -> result
const gifCache = new Map<string, ExerciseGif | null>()

export async function searchExerciseGif(query: string): Promise<ExerciseGif | null> {
  const key = query.toLowerCase().trim()
  if (gifCache.has(key)) return gifCache.get(key)!

  try {
    const res = await fetch(`${EXERCISEDB_BASE}/exercises/search?q=${encodeURIComponent(key)}&limit=1`)
    if (!res.ok) { gifCache.set(key, null); return null }
    const json = await res.json()
    const ex = json.data?.[0]
    if (!ex) { gifCache.set(key, null); return null }
    const result: ExerciseGif = {
      exerciseId: ex.exerciseId,
      name: ex.name,
      gifUrl: ex.gifUrl,
      targetMuscles: ex.targetMuscles || [],
    }
    gifCache.set(key, result)
    return result
  } catch {
    gifCache.set(key, null)
    return null
  }
}

export const EXERCISE_NAME_MAP: Record<string, string> = {
  '박스 와드': '', // WOD - no GIF
  '백스쿼트': 'barbell back squat',
  '프론트스쿼트': 'barbell front squat',
  '데드리프트': 'barbell deadlift',
  '벤치프레스': 'barbell bench press',
  '숄더프레스': 'dumbbell shoulder press',
  '클린': 'power clean',
  '스내치': 'barbell snatch',
}

export function getSearchTerm(exerciseName: string): string {
  if (exerciseName in EXERCISE_NAME_MAP) return EXERCISE_NAME_MAP[exerciseName]
  return exerciseName
    .replace(/^(\d+\s)/, '')
    .replace(/\s*\(.*?\)\s*/g, ' ')
    .replace(/\s*[-–]\s*(Full|Bottom|Half|Top).*$/i, '')
    .replace(/\s*(w\/|@)\s*/g, ' ')
    .trim()
}
