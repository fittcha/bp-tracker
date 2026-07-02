// react-easy-crop의 croppedAreaPixels(원본 픽셀 좌표)로 정사각 JPEG Blob 생성.
export interface Area {
  x: number
  y: number
  width: number
  height: number
}

export function getCroppedBlob(imageSrc: string, area: Area, outputSize = 256): Promise<Blob> {
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
