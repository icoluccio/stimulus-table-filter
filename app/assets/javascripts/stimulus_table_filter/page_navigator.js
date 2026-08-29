import { Paginator } from "stimulus_table_filter/paginator"

export class PageNavigator {
  constructor(pageSize) {
    this.paginator = new Paginator(pageSize)
  }

  get enabled() {
    return this.paginator.enabled
  }

  step(page, step, matchedTotal) {
    const target = page + step
    const inRange = target >= 1 && target <= this.paginator.pageCount(matchedTotal)
    return inRange ? target : page
  }

  clamp(page, matchedTotal) { return this.paginator.clamp(page, matchedTotal) }

  window(page) { return this.paginator.window(page) }

  pageCount(matchedTotal) { return this.paginator.pageCount(matchedTotal) }

  info(page, matchedTotal) { return this.paginator.info(page, matchedTotal) }
}
