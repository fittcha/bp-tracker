const EXERCISEDB_BASE = 'https://exercisedb.dev/api/v1'
const GIF = 'https://static.exercisedb.dev/media'

export interface ExerciseGif {
  exerciseId: string
  name: string
  gifUrl: string
  targetMuscles: string[]
}

// Pre-verified exercise ID → GIF mappings
// Only includes exercises with confirmed correct IDs
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

  // === Curl ===
  'Barbell Curl': { exerciseId: '25GPyDY', name: 'barbell curl', gifUrl: `${GIF}/25GPyDY.gif`, targetMuscles: ['biceps'] },
  'DB Hammer Curls': { exerciseId: 'slDvUAU', name: 'dumbbell hammer curl', gifUrl: `${GIF}/slDvUAU.gif`, targetMuscles: ['biceps'] },
  'Alter DB Hammer Curls': { exerciseId: 'slDvUAU', name: 'dumbbell hammer curl', gifUrl: `${GIF}/slDvUAU.gif`, targetMuscles: ['biceps'] },
  'Alternating DB Curls': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },
  'DB Curls': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },
  'Alter Seated DB Curl': { exerciseId: 'BU15nH4', name: 'dumbbell alternate biceps curl', gifUrl: `${GIF}/BU15nH4.gif`, targetMuscles: ['biceps'] },

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

  // === Press ===
  'Seated DB Press': { exerciseId: 'znQUdHY', name: 'dumbbell seated shoulder press', gifUrl: `${GIF}/znQUdHY.gif`, targetMuscles: ['deltoids'] },
  '숄더프레스': { exerciseId: 'A6wtbuL', name: 'dumbbell standing overhead press', gifUrl: `${GIF}/A6wtbuL.gif`, targetMuscles: ['deltoids'] },

  // === Tricep ===
  'Behind the Neck Overhead DB Tricep Extension': { exerciseId: 'kont8Ut', name: 'dumbbell seated triceps extension', gifUrl: `${GIF}/kont8Ut.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Extension': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Push Down': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'Banded Tricep Pushdown': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },
  'DB Skull Crusher': { exerciseId: 'kont8Ut', name: 'dumbbell seated triceps extension', gifUrl: `${GIF}/kont8Ut.gif`, targetMuscles: ['triceps'] },
  'Bench Tricep Dips': { exerciseId: 'gAwDzB3', name: 'cable triceps pushdown (v-bar)', gifUrl: `${GIF}/gAwDzB3.gif`, targetMuscles: ['triceps'] },

  // === Cardio / No GIF ===
  'Row': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] }, // 로잉 머신
  '박스 와드': { exerciseId: '', name: '', gifUrl: '', targetMuscles: [] },
}

// In-memory cache for API search fallback
const gifCache = new Map<string, ExerciseGif | null>()

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

  // 3. Fallback: API search with cache
  const key = normalized.toLowerCase()
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
