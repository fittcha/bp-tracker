const EXERCISEDB_BASE = 'https://exercisedb.dev/api/v1'
const GIF = 'https://static.exercisedb.dev/media'

export interface ExerciseGif {
  exerciseId: string
  name: string
  gifUrl: string
  targetMuscles: string[]
}

// Pre-verified exercise ID → GIF mappings
const KNOWN_EXERCISES: Record<string, ExerciseGif> = {
  // === Bench Press ===
  'DB Bench Press': { exerciseId: 'SpYC0Kp', name: 'dumbbell bench press', gifUrl: `${GIF}/SpYC0Kp.gif`, targetMuscles: ['pectorals'] },
  'Bench Press': { exerciseId: 'EIeI8Vf', name: 'barbell bench press', gifUrl: `${GIF}/EIeI8Vf.gif`, targetMuscles: ['pectorals'] },
  'Close Grip Bench Press': { exerciseId: 'J6Dx1Mu', name: 'barbell close-grip bench press', gifUrl: `${GIF}/J6Dx1Mu.gif`, targetMuscles: ['triceps'] },
  '벤치프레스': { exerciseId: 'EIeI8Vf', name: 'barbell bench press', gifUrl: `${GIF}/EIeI8Vf.gif`, targetMuscles: ['pectorals'] },

  // === Squat ===
  'Back Squat': { exerciseId: 'qXTaZnJ', name: 'barbell full squat', gifUrl: `${GIF}/qXTaZnJ.gif`, targetMuscles: ['glutes'] },
  'Front Squat': { exerciseId: 'qXTaZnJ', name: 'barbell full squat', gifUrl: `${GIF}/qXTaZnJ.gif`, targetMuscles: ['glutes', 'quadriceps'] },
  'Goblet Squats': { exerciseId: 'HsvHqgf', name: 'dumbbell squat', gifUrl: `${GIF}/HsvHqgf.gif`, targetMuscles: ['glutes'] },
  'DB Goblet Squats': { exerciseId: 'HsvHqgf', name: 'dumbbell squat', gifUrl: `${GIF}/HsvHqgf.gif`, targetMuscles: ['glutes'] },
  '백스쿼트': { exerciseId: 'qXTaZnJ', name: 'barbell full squat', gifUrl: `${GIF}/qXTaZnJ.gif`, targetMuscles: ['glutes'] },
  '프론트스쿼트': { exerciseId: 'qXTaZnJ', name: 'barbell full squat', gifUrl: `${GIF}/qXTaZnJ.gif`, targetMuscles: ['glutes', 'quadriceps'] },

  // === Deadlift ===
  'DB Romanian Deadlift': { exerciseId: 'rR0LJzx', name: 'dumbbell romanian deadlift', gifUrl: `${GIF}/rR0LJzx.gif`, targetMuscles: ['glutes'] },
  '데드리프트': { exerciseId: 'wQ2c4XD', name: 'barbell romanian deadlift', gifUrl: `${GIF}/wQ2c4XD.gif`, targetMuscles: ['glutes'] },
  'Sumo Deadlift High Pulls': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },

  // === Curl ===
  'Barbell Curl': { exerciseId: '25GPyDY', name: 'barbell curl', gifUrl: `${GIF}/25GPyDY.gif`, targetMuscles: ['biceps'] },
  'DB Hammer Curls': { exerciseId: 'slDvUAU', name: 'dumbbell hammer curl', gifUrl: `${GIF}/slDvUAU.gif`, targetMuscles: ['biceps'] },
  'Alter DB Hammer Curls': { exerciseId: 'slDvUAU', name: 'dumbbell hammer curl', gifUrl: `${GIF}/slDvUAU.gif`, targetMuscles: ['biceps'] },
  'Alternating DB Curls': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },
  'DB Curls': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },
  'Alter Seated DB Curl': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },
  'Empty Barbell Curls - Full reps': { exerciseId: '25GPyDY', name: 'barbell curl', gifUrl: `${GIF}/25GPyDY.gif`, targetMuscles: ['biceps'] },
  'Empty Barbell Curls - Bottom to Half reps': { exerciseId: '25GPyDY', name: 'barbell curl', gifUrl: `${GIF}/25GPyDY.gif`, targetMuscles: ['biceps'] },
  'Empty Barbell Curls - Half to Top reps': { exerciseId: '25GPyDY', name: 'barbell curl', gifUrl: `${GIF}/25GPyDY.gif`, targetMuscles: ['biceps'] },

  // === Shoulder / Lateral ===
  'DB Lateral Raises': { exerciseId: 'DsgkuIt', name: 'dumbbell lateral raise', gifUrl: `${GIF}/DsgkuIt.gif`, targetMuscles: ['deltoids'] },
  'DB Lateral Raise': { exerciseId: 'DsgkuIt', name: 'dumbbell lateral raise', gifUrl: `${GIF}/DsgkuIt.gif`, targetMuscles: ['deltoids'] },
  'Lateral Raises': { exerciseId: 'DsgkuIt', name: 'dumbbell lateral raise', gifUrl: `${GIF}/DsgkuIt.gif`, targetMuscles: ['deltoids'] },
  'SA Lateral Raises': { exerciseId: 'DsgkuIt', name: 'dumbbell lateral raise', gifUrl: `${GIF}/DsgkuIt.gif`, targetMuscles: ['deltoids'] },
  'Rear Delt Fly': { exerciseId: '8DiFDVA', name: 'dumbbell rear fly', gifUrl: `${GIF}/8DiFDVA.gif`, targetMuscles: ['deltoids'] },
  'Seated DB Arnold Press': { exerciseId: 'Xy4jlWA', name: 'dumbbell arnold press', gifUrl: `${GIF}/Xy4jlWA.gif`, targetMuscles: ['deltoids'] },

  // === Chest ===
  'DB Chest Fly': { exerciseId: 'yz9nUhF', name: 'dumbbell fly', gifUrl: `${GIF}/yz9nUhF.gif`, targetMuscles: ['pectorals'] },

  // === Row ===
  'DB Bent Row': { exerciseId: 'BJ0Hz5L', name: 'dumbbell bent over row', gifUrl: `${GIF}/BJ0Hz5L.gif`, targetMuscles: ['lats'] },
  'Bent Over Barbell Row': { exerciseId: 'eZyBC3j', name: 'barbell bent over row', gifUrl: `${GIF}/eZyBC3j.gif`, targetMuscles: ['lats'] },
  'Chest Supported DB Row': { exerciseId: 'BJ0Hz5L', name: 'dumbbell bent over row', gifUrl: `${GIF}/BJ0Hz5L.gif`, targetMuscles: ['lats'] },

  // === Lunge ===
  'Barbell Back Rack Lunges': { exerciseId: 't8iSghb', name: 'barbell lunge', gifUrl: `${GIF}/t8iSghb.gif`, targetMuscles: ['glutes', 'quadriceps'] },
  'Barbell Reverse Lunges': { exerciseId: 'VaP75jl', name: 'barbell rear lunge', gifUrl: `${GIF}/VaP75jl.gif`, targetMuscles: ['glutes', 'quadriceps'] },

  // === Split Squat ===
  'Bulgarian Split Squat': { exerciseId: '9E25EOx', name: 'split squats', gifUrl: `${GIF}/9E25EOx.gif`, targetMuscles: ['glutes', 'quadriceps'] },
  'Bulgarian Split Squats': { exerciseId: '9E25EOx', name: 'split squats', gifUrl: `${GIF}/9E25EOx.gif`, targetMuscles: ['glutes', 'quadriceps'] },

  // === Abs / Core ===
  'V ups': { exerciseId: 'mbkgB44', name: 'jackknife sit-up', gifUrl: `${GIF}/mbkgB44.gif`, targetMuscles: ['abs'] },
  'Russian Twist': { exerciseId: 'XVDdcoj', name: 'russian twist', gifUrl: `${GIF}/XVDdcoj.gif`, targetMuscles: ['abs'] },
  'DB Side Bend': { exerciseId: 'IpONWYv', name: 'dumbbell side bend', gifUrl: `${GIF}/IpONWYv.gif`, targetMuscles: ['abs'] },
  'DB Side Bent': { exerciseId: 'IpONWYv', name: 'dumbbell side bend', gifUrl: `${GIF}/IpONWYv.gif`, targetMuscles: ['abs'] },
  'Hanging Knee Raises (No Kipping)': { exerciseId: '03lzqwk', name: 'hanging knee raise', gifUrl: `${GIF}/03lzqwk.gif`, targetMuscles: ['abs'] },
  'Weighted Hanging Knee Raises (No Kipping)': { exerciseId: '03lzqwk', name: 'hanging knee raise', gifUrl: `${GIF}/03lzqwk.gif`, targetMuscles: ['abs'] },
  'Flutter Kick w/ Hollow Rock Hold': { exerciseId: 'UVo2Qs2', name: 'flutter kicks', gifUrl: `${GIF}/UVo2Qs2.gif`, targetMuscles: ['abs'] },

  // === Press ===
  'Seated DB Press': { exerciseId: 'znQUdHY', name: 'dumbbell seated shoulder press', gifUrl: `${GIF}/znQUdHY.gif`, targetMuscles: ['deltoids'] },
  '숄더프레스': { exerciseId: 'A6wtbuL', name: 'dumbbell standing overhead press', gifUrl: `${GIF}/A6wtbuL.gif`, targetMuscles: ['deltoids'] },
  '8 Standing DB Press': { exerciseId: 'A6wtbuL', name: 'dumbbell standing overhead press', gifUrl: `${GIF}/A6wtbuL.gif`, targetMuscles: ['deltoids'] },

  // === Pull Up ===
  'Strict Pull Ups': { exerciseId: '0V2YQjW', name: 'pull up (neutral grip)', gifUrl: `${GIF}/0V2YQjW.gif`, targetMuscles: ['lats'] },
  'Banded Strict Pull ups': { exerciseId: '0V2YQjW', name: 'pull up (neutral grip)', gifUrl: `${GIF}/0V2YQjW.gif`, targetMuscles: ['lats'] },

  // === Tricep ===
  'Behind the Neck Overhead DB Tricep Extension': { exerciseId: 'kont8Ut', name: 'dumbbell seated triceps extension', gifUrl: `${GIF}/kont8Ut.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Extension': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Push Down': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Pushdown': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'DB Skull Crusher': { exerciseId: 'kont8Ut', name: 'dumbbell seated triceps extension', gifUrl: `${GIF}/kont8Ut.gif`, targetMuscles: ['triceps'] },
  'Bench Tricep Dips': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },

  // === Other ===
  'Good Morning w/ Barbell': { exerciseId: 'XlZ4lAC', name: 'barbell good morning', gifUrl: `${GIF}/XlZ4lAC.gif`, targetMuscles: ['hamstrings'] },
  'DB Burpees': { exerciseId: '0JtKWum', name: 'dumbbell burpee', gifUrl: `${GIF}/0JtKWum.gif`, targetMuscles: ['full body'] },
  'Target Burpees': { exerciseId: 'dK9394r', name: 'burpee', gifUrl: `${GIF}/dK9394r.gif`, targetMuscles: ['full body'] },

  // === Lunge (DB) ===
  'Alternating DB(2) Lunges (Holding DB in Each Hand)': { exerciseId: 'RRWFUcw', name: 'dumbbell lunge', gifUrl: `${GIF}/RRWFUcw.gif`, targetMuscles: ['glutes', 'quadriceps'] },

  'Plank Pull Through': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  'Side V ups': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  'Air Squats': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  'Wall Sit': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },

  // === No GIF (ExerciseDB에 없음 → Google fallback) ===
  'Hip Thrust': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  'Row': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  'Band Pull Apart': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  '박스 와드': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  '15~45 Minute Easy Run': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  '200m Run @ Fast': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
  '400m Recovery Run': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
}

const CACHE_KEY = 'exercisedb-gif-cache'
const CACHE_VERSION = 1

interface CacheEntry {
  v: number
  data: Record<string, ExerciseGif | null>
}

function loadCache(): Map<string, ExerciseGif | null> {
  try {
    const raw = localStorage.getItem(CACHE_KEY)
    if (!raw) return new Map()
    const parsed: CacheEntry = JSON.parse(raw)
    if (parsed.v !== CACHE_VERSION) return new Map()
    return new Map(Object.entries(parsed.data))
  } catch {
    return new Map()
  }
}

function saveCache(cache: Map<string, ExerciseGif | null>) {
  try {
    const obj: CacheEntry = {
      v: CACHE_VERSION,
      data: Object.fromEntries(cache),
    }
    localStorage.setItem(CACHE_KEY, JSON.stringify(obj))
  } catch {
    // localStorage full or unavailable
  }
}

// Lazy-initialized localStorage cache
let gifCache: Map<string, ExerciseGif | null> | null = null

function getCache(): Map<string, ExerciseGif | null> {
  if (!gifCache) gifCache = loadCache()
  return gifCache
}

export async function getExerciseGif(exerciseName: string): Promise<ExerciseGif | null> {
  // 1. Exact match in known exercises
  if (exerciseName in KNOWN_EXERCISES) {
    const known = KNOWN_EXERCISES[exerciseName]
    if (!known.exerciseId) return null
    return known
  }

  // 2. Normalize and check again
  const normalized = exerciseName
    .replace(/^(\d+\s)/, '')
    .replace(/\s*\(.*?\)\s*/g, ' ')
    .replace(/\s*[-–]\s*(Full|Bottom|Half|Top).*$/i, '')
    .replace(/\s*(w\/|@)\s*/g, ' ')
    .trim()

  if (normalized in KNOWN_EXERCISES) {
    const known = KNOWN_EXERCISES[normalized]
    if (!known.exerciseId) return null
    return known
  }

  // 3. Fallback: API search with localStorage cache
  const cache = getCache()
  const key = normalized.toLowerCase()
  if (cache.has(key)) return cache.get(key)!

  try {
    const res = await fetch(`${EXERCISEDB_BASE}/exercises/search?q=${encodeURIComponent(key)}&limit=1`)
    if (!res.ok) { cache.set(key, null); saveCache(cache); return null }
    const json = await res.json()
    const ex = json.data?.[0]
    if (!ex) { cache.set(key, null); saveCache(cache); return null }
    const result: ExerciseGif = {
      exerciseId: ex.exerciseId,
      name: ex.name,
      gifUrl: ex.gifUrl,
      targetMuscles: ex.targetMuscles || [],
    }
    cache.set(key, result)
    saveCache(cache)
    return result
  } catch {
    cache.set(key, null)
    saveCache(cache)
    return null
  }
}
