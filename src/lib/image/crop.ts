// react-easy-crop의 croppedAreaPixels(원본 픽셀 좌표)로 정사각 JPEG Blob 생성.
// JPEG은 투명도가 없으므로 그리기 전에 bgColor로 캔버스를 채운다 —
// 이미지 바깥(축소 시 여백)과 투명 PNG의 투명 영역이 모두 이 색으로 채워진다.
export interface Area {
  x: number
  y: number
  width: number
  height: number
}

export function getCroppedBlob(imageSrc: string, area: Area, outputSize = 256, bgColor = '#FFFFFF'): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = outputSize
      canvas.height = outputSize
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        reject(new Error('canvas context를 만들 수 없어요'))
        return
      }
      ctx.fillStyle = bgColor
      ctx.fillRect(0, 0, outputSize, outputSize)
      ctx.drawImage(img, area.x, area.y, area.width, area.height, 0, 0, outputSize, outputSize)
      canvas.toBlob(
        (blob) => (blob ? resolve(blob) : reject(new Error('이미지 변환에 실패했어요'))),
        'image/jpeg',
        0.85,
      )
    }
    img.onerror = () => reject(new Error('이미지를 불러오지 못했어요'))
    img.src = imageSrc
  })
}
