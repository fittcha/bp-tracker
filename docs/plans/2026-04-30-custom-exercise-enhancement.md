# Custom Exercise Enhancement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enhance custom exercise feature with sets/reps, section, memo, and edit functionality.

**Architecture:** Add `custom_sets`/`custom_reps` columns to `workout_logs`. Enhance `CustomExerciseForm` to accept section/sets/reps and support edit mode. Update workout page to display custom exercises with section headers and memo toggles like coach exercises.

**Tech Stack:** Next.js (App Router), TypeScript, Tailwind CSS v4, Supabase

---

### Task 1: DB Migration — Add custom_sets, custom_reps columns

**Files:**
- Create: `docs/sql/add-custom-exercise-fields.sql`

**Step 1: Write migration SQL**

```sql
ALTER TABLE workout_logs
  ADD COLUMN custom_sets text,
  ADD COLUMN custom_reps text;
```

**Step 2: Run migration in Supabase SQL Editor**

Execute the SQL above in Supabase Dashboard > SQL Editor.

**Step 3: Commit**

```bash
git add docs/sql/add-custom-exercise-fields.sql
git commit -m "feat: add custom_sets, custom_reps columns to workout_logs"
```

---

### Task 2: Update WorkoutLog type and API functions

**Files:**
- Modify: `app/src/lib/api/workout-logs.ts`

**Step 1: Update WorkoutLog interface**

Add to the `WorkoutLog` interface (after `memo`):

```typescript
custom_sets: string | null
custom_reps: string | null
```

**Step 2: Update addCustomExercise to accept new fields**

Replace the `addCustomExercise` function:

```typescript
export async function addCustomExercise(
  date: string,
  exerciseName: string,
  userId: string,
  section?: string,
  customSets?: string,
  customReps?: string,
) {
  const { data, error } = await supabase
    .from('workout_logs')
    .insert({
      date,
      user_id: userId,
      template_id: null,
      is_custom: true,
      exercise_name: exerciseName,
      section: section || null,
      completed: false,
      weight_lb: null,
      weight_unit: 'lb',
      memo: null,
      custom_sets: customSets || null,
      custom_reps: customReps || null,
    })
    .select()
    .single()
  if (error) throw error
  return data
}
```

**Step 3: Add updateCustomExercise function**

Add after `addCustomExercise`:

```typescript
export async function updateCustomExercise(
  id: string,
  fields: {
    exercise_name: string
    section: string | null
    custom_sets: string | null
    custom_reps: string | null
  },
) {
  const { error } = await supabase
    .from('workout_logs')
    .update(fields)
    .eq('id', id)
  if (error) throw error
}
```

**Step 4: Commit**

```bash
git add app/src/lib/api/workout-logs.ts
git commit -m "feat: update workout-logs API for custom exercise fields"
```

---

### Task 3: Enhance CustomExerciseForm with section/sets/reps and edit mode

**Files:**
- Modify: `app/src/components/workout/CustomExerciseForm.tsx`

**Step 1: Rewrite CustomExerciseForm**

Replace entire file content:

```tsx
'use client'

import { useState, useEffect } from 'react'

interface CustomExerciseFormProps {
  onAdd: (name: string, section?: string, sets?: string, reps?: string) => void
  editingLog?: {
    id: string
    exercise_name: string
    section: string | null
    custom_sets: string | null
    custom_reps: string | null
  } | null
  onUpdate?: (id: string, name: string, section: string | null, sets: string | null, reps: string | null) => void
  onCancelEdit?: () => void
}

export default function CustomExerciseForm({ onAdd, editingLog, onUpdate, onCancelEdit }: CustomExerciseFormProps) {
  const [name, setName] = useState('')
  const [section, setSection] = useState('')
  const [sets, setSets] = useState('')
  const [reps, setReps] = useState('')
  const [open, setOpen] = useState(false)

  const isEditing = !!editingLog

  useEffect(() => {
    if (editingLog) {
      setName(editingLog.exercise_name)
      setSection(editingLog.section || '')
      setSets(editingLog.custom_sets || '')
      setReps(editingLog.custom_reps || '')
      setOpen(true)
    }
  }, [editingLog])

  function resetForm() {
    setName('')
    setSection('')
    setSets('')
    setReps('')
    setOpen(false)
  }

  function handleSubmit() {
    if (!name.trim()) return
    if (isEditing && onUpdate) {
      onUpdate(
        editingLog!.id,
        name.trim(),
        section.trim() || null,
        sets.trim() || null,
        reps.trim() || null,
      )
    } else {
      onAdd(name.trim(), section.trim() || undefined, sets.trim() || undefined, reps.trim() || undefined)
    }
    resetForm()
  }

  function handleCancel() {
    resetForm()
    if (isEditing && onCancelEdit) onCancelEdit()
  }

  if (!open && !isEditing) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="w-full border-2 border-dashed border-accent/30 rounded-xl py-3 text-sm font-medium text-accent hover:border-accent/50 transition-colors"
      >
        + 운동 추가
      </button>
    )
  }

  return (
    <div className="bg-accent-light border border-accent/20 rounded-xl p-4 space-y-3">
      <input
        autoFocus
        placeholder="운동명"
        value={name}
        onChange={(e) => setName(e.target.value)}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      />
      <input
        placeholder="섹션 (예: 복근, 스트레칭)"
        value={section}
        onChange={(e) => setSection(e.target.value)}
        className="w-full border border-border rounded-lg px-3 py-2 text-sm bg-surface"
      />
      <div className="flex gap-2">
        <input
          placeholder="세트 (예: 4)"
          value={sets}
          onChange={(e) => setSets(e.target.value)}
          className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-surface"
        />
        <input
          placeholder="렙 (예: 12)"
          value={reps}
          onChange={(e) => setReps(e.target.value)}
          className="flex-1 border border-border rounded-lg px-3 py-2 text-sm bg-surface"
        />
      </div>
      <div className="flex gap-2">
        <button
          onClick={handleSubmit}
          className="flex-1 bg-accent text-white rounded-lg py-2 text-sm font-medium"
        >
          {isEditing ? '수정' : '추가'}
        </button>
        <button
          onClick={handleCancel}
          className="px-4 py-2 text-sm text-text-secondary"
        >
          취소
        </button>
      </div>
    </div>
  )
}
```

**Step 2: Commit**

```bash
git add app/src/components/workout/CustomExerciseForm.tsx
git commit -m "feat: enhance CustomExerciseForm with section/sets/reps and edit mode"
```

---

### Task 4: Update workout page — custom exercise display + edit + memo

**Files:**
- Modify: `app/src/app/workout/page.tsx`

**Step 1: Add imports and state**

Add to imports (line 5):
```typescript
import { getWorkoutLogs, upsertWorkoutLog, batchInsertWorkoutLogs, addCustomExercise, updateCustomExercise, deleteWorkoutLog, WorkoutLog } from '@/lib/api/workout-logs'
```

Add state inside `WorkoutPage` (after `longPressRef`):
```typescript
const [editingLog, setEditingLog] = useState<WorkoutLog | null>(null)
```

**Step 2: Update handleAddCustom**

Replace `handleAddCustom`:
```typescript
async function handleAddCustom(name: string, section?: string, sets?: string, reps?: string) {
  await addCustomExercise(date, name, userId, section, sets, reps)
  loadData()
}
```

**Step 3: Add handleUpdateCustom**

Add after `handleAddCustom`:
```typescript
async function handleUpdateCustom(id: string, name: string, section: string | null, sets: string | null, reps: string | null) {
  await updateCustomExercise(id, { exercise_name: name, section, custom_sets: sets, custom_reps: reps })
  setEditingLog(null)
  loadData()
}
```

**Step 4: Group custom logs by section**

Replace the simple `customLogs` variable (line 301) and add grouping logic after it:
```typescript
const customLogs = logs.filter(l => l.is_custom)

// Group custom logs by section
const customSections: { section: string; items: WorkoutLog[] }[] = []
const customSectionMap = new Map<string, WorkoutLog[]>()
for (const log of customLogs) {
  const sec = log.section || '개인 운동'
  if (!customSectionMap.has(sec)) {
    const items: WorkoutLog[] = []
    customSectionMap.set(sec, items)
    customSections.push({ section: sec, items })
  }
  customSectionMap.get(sec)!.push(log)
}
```

**Step 5: Replace custom exercises rendering block**

Replace the `{/* Custom exercises */}` block (lines 727-809) with:

```tsx
{/* Custom exercises grouped by section */}
{customSections.map(({ section: sec, items: customItems }) => {
  const allCompleted = customItems.every(l => l.completed)
  const someCompleted = customItems.some(l => l.completed)

  function handleCustomGroupToggle() {
    const newState = !allCompleted
    for (const item of customItems) {
      if (item.completed !== newState) {
        handleToggleComplete(item.id!, newState)
      }
    }
  }

  return (
    <div key={`custom-${sec}`} className="bg-surface border border-accent/20 rounded-xl overflow-hidden">
      <div className="px-4 py-2.5 bg-accent-light border-b border-accent/20 flex items-center gap-2">
        <button
          onClick={handleCustomGroupToggle}
          className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
            allCompleted ? 'bg-success border-success text-white'
              : someCompleted ? 'border-success/50 bg-success/10'
              : 'border-accent/30'
          }`}
        >
          {allCompleted && (
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          )}
          {someCompleted && !allCompleted && (
            <div className="w-2 h-0.5 bg-success rounded" />
          )}
        </button>
        <span className="text-xs font-bold text-accent">{sec}</span>
      </div>
      <div className="divide-y divide-border">
        {customItems.map(log => {
          const isWeightOpen = !!weightOpen[log.id!]
          const isMemoOpen = !!memoOpen[log.id!]
          return (
            <div key={log.id}>
              <div className="flex items-center gap-3 px-4 py-3">
                <button
                  onClick={() => handleToggleComplete(log.id!, !log.completed)}
                  className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                    log.completed ? 'bg-text-secondary/40 border-transparent text-white' : 'border-accent/30'
                  }`}
                >
                  {log.completed && (
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  )}
                </button>
                <div className="flex-1 min-w-0">
                  <p
                    className={`text-sm font-medium text-accent select-none whitespace-pre-line ${log.completed ? 'line-through opacity-50' : ''}`}
                    onTouchStart={() => handleLongPressStart(log.exercise_name)}
                    onTouchEnd={() => handleLongPressEnd(log.exercise_name)}
                    onTouchCancel={() => handleLongPressEnd(log.exercise_name)}
                    onMouseDown={() => handleLongPressStart(log.exercise_name)}
                    onMouseUp={() => handleLongPressEnd(log.exercise_name)}
                    onMouseLeave={() => handleLongPressEnd(log.exercise_name)}
                    onContextMenu={(e) => e.preventDefault()}
                  >
                    {log.exercise_name}
                  </p>
                  {(log.custom_sets || log.custom_reps) && (
                    <p className="text-xs text-text-secondary">
                      {log.custom_sets && `${log.custom_sets}세트`} {log.custom_reps && `× ${log.custom_reps}`}
                    </p>
                  )}
                </div>
                <div className="flex items-center gap-1 flex-shrink-0">
                  <button
                    onClick={() => toggleWeightInput(log.id!)}
                    className={`w-5 h-5 rounded border flex items-center justify-center transition-colors ${
                      isWeightOpen ? 'bg-accent border-accent text-white' : 'border-text-secondary/30 bg-surface'
                    }`}
                  >
                    {isWeightOpen ? (
                      <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                    ) : (
                      <span className="text-[8px] font-bold text-text-secondary">{log.weight_unit ?? 'lb'}</span>
                    )}
                  </button>
                  {isWeightOpen && (
                    <>
                      <button
                        onClick={() => handleWeightChange(log.id!, Math.max(0, (log.weight_lb ?? 0) - 5))}
                        className="w-5 h-5 rounded bg-background border border-border flex items-center justify-center text-[10px] font-bold text-text-secondary active:bg-border"
                      >−</button>
                      <input
                        type="number"
                        inputMode="decimal"
                        placeholder="0"
                        value={log.weight_lb ?? ''}
                        onChange={(e) => handleWeightChange(log.id!, e.target.value ? parseFloat(e.target.value) : null)}
                        className="w-12 border border-border rounded-lg px-1 py-0.5 text-xs text-center bg-background"
                      />
                      <button
                        onClick={() => handleUnitToggle(log.id!)}
                        className="text-[9px] text-text-secondary active:text-accent"
                      >{log.weight_unit ?? 'lb'}</button>
                      <button
                        onClick={() => handleWeightChange(log.id!, (log.weight_lb ?? 0) + 5)}
                        className="w-5 h-5 rounded bg-background border border-border flex items-center justify-center text-[10px] font-bold text-text-secondary active:bg-border"
                      >+</button>
                    </>
                  )}
                </div>
                <button
                  onClick={() => setMemoOpen(prev => ({ ...prev, [log.id!]: !prev[log.id!] }))}
                  className={`w-6 h-6 flex items-center justify-center rounded transition-colors ${
                    isMemoOpen ? 'text-accent' : log.memo ? 'text-accent/60' : 'text-text-secondary/40'
                  }`}
                  title="메모"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                    <line x1="16" y1="13" x2="8" y2="13" />
                    <line x1="16" y1="17" x2="8" y2="17" />
                  </svg>
                </button>
                <button
                  onClick={() => setEditingLog(log)}
                  className="text-accent/60 hover:text-accent transition-colors"
                  title="수정"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                  </svg>
                </button>
                <button onClick={() => handleDeleteLog(log.id!)} className="text-danger text-xs">
                  삭제
                </button>
              </div>
              {isMemoOpen && (
                <div className="px-4 py-2.5 border-t border-border bg-background/50">
                  <textarea
                    placeholder="메모 입력..."
                    value={log.memo || ''}
                    onChange={(e) => {
                      handleMemoChange(log.id!, e.target.value)
                      e.target.style.height = 'auto'
                      e.target.style.height = e.target.scrollHeight + 'px'
                    }}
                    ref={(el) => {
                      if (el) {
                        el.style.height = 'auto'
                        el.style.height = el.scrollHeight + 'px'
                      }
                    }}
                    className="w-full text-xs bg-transparent resize-none outline-none text-foreground placeholder:text-text-secondary/50"
                    rows={1}
                  />
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
})}
```

**Step 6: Update CustomExerciseForm usage**

Replace the `<CustomExerciseForm onAdd={handleAddCustom} />` line (811) with:
```tsx
<CustomExerciseForm
  onAdd={handleAddCustom}
  editingLog={editingLog}
  onUpdate={handleUpdateCustom}
  onCancelEdit={() => setEditingLog(null)}
/>
```

**Step 7: Update totalSections/completedSections**

Replace lines 317-318:
```typescript
const totalSections = sections.length + customSections.length
const completedSections = sections.filter(s => s.items.every(i => i.completed)).length + customSections.filter(s => s.items.every(l => l.completed)).length
```

**Step 8: Commit**

```bash
git add app/src/app/workout/page.tsx
git commit -m "feat: custom exercise display with section/sets/reps, memo, edit"
```

---

### Task 5: Verify and test

**Step 1: Run dev server**

```bash
cd /Users/chacha/lab/2026bp/app && npm run dev
```

**Step 2: Manual testing checklist**

- [ ] 개인 운동 추가: 운동명 + 섹션 + 세트 + 렙 모두 입력 후 추가
- [ ] 개인 운동 추가: 운동명만 입력 (섹션/세트/렙 미입력) → "개인 운동" 기본 섹션
- [ ] 같은 섹션 운동 여러 개 → 하나의 섹션 카드로 그룹화
- [ ] 세트/렙 정보 표시 확인 ("4세트 × 12")
- [ ] 메모 토글 작동 확인
- [ ] 수정 버튼 → 폼에 기존 값 채워짐 → 수정 완료
- [ ] 삭제 작동 확인
- [ ] 섹션별 그룹 체크박스 작동 확인
- [ ] 진행률(완료/전체) 카운트 정확한지 확인

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: custom exercise enhancement - section, sets/reps, memo, edit"
```
