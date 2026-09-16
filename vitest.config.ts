import { defineConfig } from 'vitest/config'
import { fileURLToPath } from 'node:url'

// tsconfig의 paths("@/*" → "./src/*")를 vitest에도 맞춘다.
// 이게 없으면 '@/...'를 런타임 임포트하는 모듈(예: src/lib/api/*)은 테스트에서 로드되지 않는다.
// 환경(node/jsdom)은 기존대로 파일 상단 `// @vitest-environment jsdom` 주석으로 지정.
export default defineConfig({
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
})
