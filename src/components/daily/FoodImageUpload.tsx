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

function parseNutrition(text: string): OcrResult {
  const result: OcrResult = { totalCalories: null, carbs: null, protein: null, fat: null }

  // Clean up OCR text - normalize whitespace and common OCR errors
  const lines = text.replace(/\n+/g, '\n').split('\n').map(l => l.trim()).filter(Boolean)
  const fullText = lines.join(' ')

  // Normalize common OCR misreads
  const normalized = fullText
    .replace(/[oO]/g, (m, offset) => {
      // Only replace 'o'/'O' that appear within number-like contexts
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
    /cal\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
    /(\d[\d,\.]+)\s*cal\b/gi,
    /열량\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
    /(\d[\d,\.]+)\s*열량/gi,
    /에너지\s*[:\s：=]?\s*(\d[\d,\.]+)/gi,
  ]
  const allCalories: number[] = []
  for (const pat of calPatterns) {
    for (const m of normalized.matchAll(pat)) {
      const val = parseFloat(m[1].replace(/,/g, ''))
      if (val >= 100 && val < 15000) allCalories.push(Math.round(val))
    }
  }
  // Also find standalone 3-5 digit numbers near calorie context
  for (const line of lines) {
    const nums = line.match(/\b(\d{3,5})\b/g)
    if (nums && /칼로리|kcal|cal|열량|에너지/i.test(line)) {
      for (const n of nums) {
        const val = parseInt(n)
        if (val >= 100 && val < 15000) allCalories.push(val)
      }
    }
  }
  if (allCalories.length > 0) {
    result.totalCalories = Math.max(...allCalories)
  }

  // Look for macros with more flexible patterns
  const fatPatterns = [/지방\s*[:\s：=]?\s*(\d[\d,\.]+)/]
  const carbPatterns = [/탄수\s*화?\s*물?\s*[:\s：=]?\s*(\d[\d,\.]+)/, /탄수\s*[:\s：=]?\s*(\d[\d,\.]+)/]
  const proteinPatterns = [/단백\s*질?\s*[:\s：=]?\s*(\d[\d,\.]+)/]

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

  // Fallback: try to find numbers in a structured row
  if (!result.fat && !result.carbs && !result.protein) {
    const numPattern = /(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)\s+\d+%?/g
    const matches = [...normalized.matchAll(numPattern)]
    if (matches.length > 0) {
      const firstMatch = matches[0]
      result.fat = parseFloat(firstMatch[1])
      result.carbs = parseFloat(firstMatch[2])
      result.protein = parseFloat(firstMatch[3])
    }
  }

  // If we have macros but no calories, calculate from macros
  if (!result.totalCalories && (result.carbs || result.protein || result.fat)) {
    const c = result.carbs ?? 0
    const p = result.protein ?? 0
    const f = result.fat ?? 0
    const calc = Math.round(c * 4 + p * 4 + f * 9)
    if (calc > 0) result.totalCalories = calc
  }

  return result
}

export default function FoodImageUpload({ imageUrl, onUploaded, onOcrResult, userId }: FoodImageUploadProps) {
  const [uploading, setUploading] = useState(false)
  const [ocrLoading, setOcrLoading] = useState(false)
  const fileRef = useRef<HTMLInputElement>(null)

  async function handleFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setUploading(true)

    // Upload image
    try {
      const url = await uploadFoodImage(file, userId)
      onUploaded(url)
    } catch (err) {
      console.error('Upload failed:', err)
    }
    setUploading(false)

    // Run OCR
    setOcrLoading(true)
    try {
      const { createWorker } = await import('tesseract.js')
      const worker = await createWorker('kor+eng')
      const imageUrl = URL.createObjectURL(file)
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
            🗑️
          </button>
        )}
      </div>
      {ocrLoading && (
        <p className="text-xs text-accent mt-1 text-center">이미지에서 칼로리/매크로를 추출하고 있습니다...</p>
      )}
    </div>
  )
}
