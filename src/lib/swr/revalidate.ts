// 키 prefix(+선행 파라미터) 매처. useSWRConfig().mutate(matchPrefix(...))로 무효화.
export function matchPrefix(prefix: string, ...params: unknown[]) {
  return (key: unknown): boolean => {
    if (!Array.isArray(key) || key[0] !== prefix) return false
    return params.every((p, i) => key[i + 1] === p)
  }
}
