export class Paginator {
  constructor(size) {
    this.size = Number(size) || 0
  }

  get enabled() {
    return this.size > 0
  }

  pageCount(matchedTotal) {
    return Math.ceil(matchedTotal / this.size) || 1
  }

  clamp(page, matchedTotal) {
    return Math.min(page, this.pageCount(matchedTotal))
  }

  window(page) {
    const start = (page - 1) * this.size
    return { start, end: start + this.size }
  }

  info(page, matchedTotal) {
    if (matchedTotal === 0) return ""
    const start = (page - 1) * this.size + 1
    const end = Math.min(page * this.size, matchedTotal)
    return `${start}–${end} of ${matchedTotal}`
  }
}
