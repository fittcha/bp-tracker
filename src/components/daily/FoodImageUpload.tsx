'use client'

import { useState, useRef } from 'react'
import { uploadFoodImage } from '@/lib/api/daily-logs'

interface OcrResult {
  totalCalories: number | null
  carbs: number | null
  protein: number | null
  fat: number | null
}

interface FoodImageUploadProps {
  imageUrl: string | null
  onUploaded: (url: string) => void
  onOcrResult: (result: OcrResult) => void
  userId: string
}

// FatSecret table parsing: detect header row, then map values by fixed column order
function parseFatSecretTable(lines: string[]): OcrResult | null {
  for (let i = 0; i < lines.length - 1; i++) {
    const line = lines[i]

    // Detect FatSecret header: need at least 3 nutrition keywords on one line
    const isEnglish = [/Calorie/i, /Carb/i, /Prot/i, /Fat/i, /Sugar/i]
      .filter(p => p.test(line)).length >= 3
    const isKorean = [/칼로리/, /탄수/, /단백/, /지방/, /권장/]
      .filter(p => p.test(line)).length >= 3

    if (!isEnglish && !isKorean) continue

    // Extract numbers from the value line (next line)
    const nextLine = lines[i + 1]
    const numbers = [...nextLine.matchAll(/(\d+\.?\d*)/g)].map(m => parseFloat(m[1]))
    if (numbers.length < 4) continue

    // Map by fixed FatSecret column order
    // English: Sugar(skip), Fat, Carbs, Prot, Calories → 5 numbers
    // Korean:  지방, 탄수, 단백질, 권장(skip), 칼로리 → 5 numbers
    if (isEnglish && numbers.length >= 5) {
      return {
        fat: numbers[1],           // Fat (2nd column)
        carbs: numbers[2],         // Carbs (3rd column)
        protein: numbers[3],       // Prot (4th column)
        totalCalories: Math.round(numbers[4]), // Calories (5th column)
      }
    }
    if (isKorean && numbers.length >= 5) {
      return {
        fat: numbers[0],           // 지방 (1st column)
        carbs: numbers[1],         // 탄수 (2nd column)
        protein: numbers[2],       // 단백질 (3rd column)
        totalCalories: Math.round(numbers[4]), // 칼로리 (5th column)
      }
    }
    // Fallback for 4 numbers (no Sugar/권장 column)
    if (numbers.length === 4) {
      return {
        fat: numbers[0],
        carbs: numbers[1],
        protein: numbers[2],
        totalCalories: Math.round(numbers[3]),
      }
    }
  }
  return null
}

function parseNutrition(text: string): OcrResult {
  // Clean up OCR text
  const lines = text.replace(/\n+/g, '\n').split('\n').map(l => l.trim()).filter(Boolean)

  // Try FatSecret table parsing first (header + value rows)
  const tableResult = parseFatSecretTable(lines)
  if (tableResult && (tableResult.totalCalories || tableResult.carbs || tableResult.protein || tableResult.fat)) {
    return tableResult
  }

  // Fallback: keyword-based parsing for other formats
  const result: OcrResult = { totalCalories: null, carbs: null, protein: null, fat: null }
  const fullText = lines.join(' ')

  // Normalize common OCR misreads
  const normalized = fullText
    .replace(/[oO]/g, (m, offset) => {
      const before = fullText[offset - 1]
      const after = fullText[offset + 1]
      if (before && /\d/.test(before)) return '0'
      if (after && /\d/.test(after)) return '0'
      return m
    })
    .replace(/，/g, ',')
    .replace(/．/g, '.')

  // Look for calorie patterns - find ALL matches, pick the largest (total)
  const calPatterns = [
    /칼로리\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
    /(\d[\d,\.]+)\s*칼로리/gi,
    /(\d[\d,\.]+)\s*kcal/gi,
    /kcal\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
    /열량\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
    /(\d[\d,\.]+)\s*열량/gi,
    /에너지\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
  ]
  const allCalories: number[] = []
  for (const pat of calPatterns) {
    for (const m of normalized.matchAll(pat)) {
      const val = parseFloat(m[1].replace(/,/g, ''))
      if (val >= 200 && val < 15000) allCalories.push(Math.round(val))
    }
  }
  // "칼로리" 헤더가 있는 줄을 찾고, 바로 다음 줄에서 같은 위치의 숫자를 찾기
  for (let i = 0; i < lines.length; i++) {
    if (/칼로리|kcal|열량/i.test(lines[i]) && i + 1 < lines.length) {
      const nextLineNums = lines[i + 1].match(/\b(\d{3,5})\b/g)
      if (nextLineNums) {
        for (const n of nextLineNums) {
          const val = parseInt(n)
          if (val >= 200 && val < 15000) allCalories.push(val)
        }
      }
    }
    if (/칼로리|kcal|열량/i.test(lines[i])) {
      const nums = lines[i].match(/\b(\d{3,5})\b/g)
      if (nums) {
        for (const n of nums) {
          const val = parseInt(n)
          if (val >= 200 && val < 15000) allCalories.push(val)
        }
      }
    }
  }
  if (allCalories.length > 0) {
    result.totalCalories = Math.max(...allCalories)
  }

  // Look for macros with more flexible patterns
  const fatPatterns = [/지방\s*[:\s：=]?\s*(\d[\d,\.]+)/, /\bFat\s*[:\s：=]?\s*(\d[\d,\.]+)/i]
  const carbPatterns = [/탄수\s*화?\s*물?\s*[:\s：=]?\s*(\d[\d,\.]+)/, /\bCarb\w*\s*[:\s：=]?\s*(\d[\d,\.]+)/i]
  const proteinPatterns = [/단백\s*질?\s*[:\s：=]?\s*(\d[\d,\.]+)/, /\bProt\w*\s*[:\s：=]?\s*(\d[\d,\.]+)/i]

  for (const pat of fatPatterns) {
    const m = normalized.match(pat)
    if (m) { result.fat = parseFloat(m[1].replace(/,/g, '')); break }
  }
  for (const pat of carbPatterns) {
    const m = normalized.match(pat)
    if (m) { result.carbs = parseFloat(m[1].replace(/,/g, '')); break }
  }
  for (const pat of proteinPatterns) {
    const m = normalized.match(pat)
    if (m) { result.protein = parseFloat(m[1].replace(/,/g, '')); break }
  }

  // Fallback: 칼로리 키워드로 못 찾으면 매크로에서 역산
  if (!result.totalCalories && (result.carbs || result.protein || result.fat)) {
    const c = result.carbs ?? 0
    const p = result.protein ?? 0
    const f = result.fat ?? 0
    const calc = Math.round(c * 4 + p * 4 + f * 9)
    if (calc > 0) result.totalCalories = calc
  }

  return result
}

function compressImage(file: File, maxSize = 1200, quality = 0.8): Promise<File> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      let { width, height } = img
      if (width <= maxSize && height <= maxSize) {
        URL.revokeObjectURL(img.src)
        resolve(file)
        return
      }
      const ratio = Math.min(maxSize / width, maxSize / height)
      width = Math.round(width * ratio)
      height = Math.round(height * ratio)
      const canvas = document.createElement('canvas')
      canvas.width = width
      canvas.height = height
      canvas.getContext('2d')!.drawImage(img, 0, 0, width, height)
      URL.revokeObjectURL(img.src)
      canvas.toBlob(
        (blob) => resolve(new File([blob!], file.name.replace(/\.\w+$/, '.jpg'), { type: 'image/jpeg' })),
        'image/jpeg',
        quality
      )
    }
    img.src = URL.createObjectURL(file)
  })
}

export default function FoodImageUpload({ imageUrl, onUploaded, onOcrResult, userId }: FoodImageUploadProps) {
  const [uploading, setUploading] = useState(false)
  const [ocrLoading, setOcrLoading] = useState(false)
  const fileRef = useRef<HTMLInputElement>(null)

  async function handleFile(e: React.ChangeEvent<HTMLInputElement>) {
    const rawFile = e.target.files?.[0]
    if (!rawFile) return

    setUploading(true)
    const compressed = await compressImage(rawFile)

    // Upload compressed image
    try {
      const url = await uploadFoodImage(compressed, userId)
      onUploaded(url)
    } catch (err) {
      console.error('Upload failed:', err)
    }
    setUploading(false)

    // Run OCR on original for better accuracy
    setOcrLoading(true)
    try {
      const { createWorker } = await import('tesseract.js')
      const worker = await createWorker('kor+eng')
      const imageUrl = URL.createObjectURL(rawFile)
      const { data: { text } } = await worker.recognize(imageUrl)
      URL.revokeObjectURL(imageUrl)
      await worker.terminate()

      console.log('OCR text:', text)
      const result = parseNutrition(text)
      console.log('OCR result:', result)

      if (result.totalCalories || result.carbs || result.protein || result.fat) {
        onOcrResult(result)
      }
    } catch (err) {
      console.error('OCR failed:', err)
    }
    setOcrLoading(false)
  }

  return (
    <div>
      <p className="text-sm font-medium mb-2">식단 앱 캡쳐</p>
      {imageUrl && (
        <img
          src={imageUrl}
          alt="식단 캡쳐"
          className="w-full max-h-60 object-contain rounded-lg mb-2 border border-border"
        />
      )}
      <input
        ref={fileRef}
        type="file"
        accept="image/*"
        onChange={handleFile}
        className="hidden"
      />
      <div className="flex gap-2">
        <button
          onClick={() => fileRef.current?.click()}
          disabled={uploading || ocrLoading}
          className="flex-1 border-2 border-dashed border-border rounded-xl py-3 text-sm text-text-secondary hover:border-accent/30 transition-colors disabled:opacity-50"
        >
          {uploading ? '업로드 중...' : ocrLoading ? 'OCR 분석 중...' : imageUrl ? '이미지 변경' : '이미지 업로드'}
        </button>
        {imageUrl && (
          <button
            onClick={() => onUploaded('')}
            className="w-12 h-12 flex items-center justify-center border-2 border-danger/30 rounded-xl text-danger hover:bg-danger/10 transition-colors"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="3 6 5 6 21 6" />
              <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6" />
              <path d="M10 11v6" />
              <path d="M14 11v6" />
              <path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" />
            </svg>
          </button>
        )}
      </div>
      {ocrLoading && (
        <p className="text-xs text-accent mt-1 text-center">이미지에서 칼로리/매크로를 추출하고 있습니다...</p>
      )}
    </div>
  )
}
