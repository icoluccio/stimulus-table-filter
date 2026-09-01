import { Controller } from "@hotwired/stimulus"
import {
  ALL_FILTER,
  DIRECTIONS,
  HIDDEN_CLASS,
  PAGE_STEPS,
  SELECTORS,
  TARGETS
} from "stimulus_table_filter/table_filter"
import { PageNavigator } from "stimulus_table_filter/page_navigator"
import { RowMatcher } from "stimulus_table_filter/row_matcher"
import { RowSorter } from "stimulus_table_filter/row_sorter"
import { RowStats } from "stimulus_table_filter/row_stats"
import { TableView } from "stimulus_table_filter/table_filter_view"
import { UrlState } from "stimulus_table_filter/url_state"

export default class extends Controller {
  static targets = Object.values(TARGETS)
  static values  = {
    filterDimensions: { type: Object, default: {} },
    sort:             { type: String, default: "name" },
    dir:              { type: String, default: "asc" },
    page:             { type: Number, default: 1 },
    search:           { type: String, default: "" },
    pageSize:         { type: Number, default: 0 },
    urlKey:           { type: String, default: "tf" },
    debounceMs:       { type: Number, default: 0 }
  }

  #debounceTimer = null
  #interacted    = false   // URL state is only written after the first user interaction
  #view          = new TableView(this)

  // Bound handlers stored so disconnect() can remove the same references
  #onClick  = (e) => this.#handleClick(e)
  #onInput  = (e) => this.#handleInput(e)
  #onChange = (e) => this.#handleChange(e)

  connect() {
    this.#readUrlState()
    if (this.hasSearchTarget && this.searchValue) this.searchTarget.value = this.searchValue
    this.element.addEventListener("click",  this.#onClick)
    this.element.addEventListener("input",  this.#onInput)
    this.element.addEventListener("change", this.#onChange)
    this.refresh()
  }

  disconnect() {
    this.element.removeEventListener("click",  this.#onClick)
    this.element.removeEventListener("input",  this.#onInput)
    this.element.removeEventListener("change", this.#onChange)
    clearTimeout(this.#debounceTimer)
  }

  // ── Public API (also callable from external elements as data-action handlers) ────

  setFilter(event) { this.#applyFilter(event.currentTarget.dataset.filterBtn, event.currentTarget.dataset.filterDimension) }
  sortBy(event)    { this.#applySort(event.currentTarget.dataset.sortBtn) }
  search()         { this.pageValue = 1; this.refresh() }

  refresh() {
    this.#filterRows()
    this.#reorder()
    this.#renderStats()   // counts the full filtered set; must run before #applyPage
    this.#applyPage()
    this.#view.renderGroupHeaders(this.rowTargets)   // only header groups with rows on this page stay visible
    this.#view.renderFilterButtons(this.filterDimensionsValue)
    this.#view.renderSortTriggers(this.sortValue, this.dirValue)
    this.#view.renderFilterDisplay(this.filterDimensionsValue)
    this.#view.renderFilterSelect(this.filterDimensionsValue)
    this.#view.renderCounts(this.#matchedRows())
    this.#view.renderPagination(this.pageValue, this.#matchedRows().length, this.#navigator())
    if (this.#interacted) this.#writeUrlState()
  }

  #handleClick(event) {
    if (this.#clickFilter(event)) return
    if (this.#clickSort(event)) return
    this.#clickPage(event)
  }

  #clickFilter(event) {
    const btn = event.target.closest(SELECTORS.filterButton)
    if (!btn) return false
    this.#applyFilter(btn.dataset.filterBtn, btn.dataset.filterDimension)
    return true
  }

  #clickSort(event) {
    const btn = event.target.closest(SELECTORS.sortButton)
    if (!btn) return false
    this.#applySort(btn.dataset.sortBtn)
    return true
  }

  #clickPage(event) {
    for (const [selector, step] of PAGE_STEPS) {
      if (!event.target.closest(selector)) continue
      this.#goToPage(step)
      return true
    }
    return false
  }

  // Every user-driven change resets pagination, marks the session as
  // interactive and re-renders the table.
  #rerun(update) {
    update()
    this.pageValue = 1
    this.#interacted = true
    this.refresh()
  }

  #applyFilter(value, dimension) {
    if (!dimension) return
    this.#rerun(() => this.#toggleDimensionFilter(dimension, value))
  }

  #applySort(col) {
    this.#rerun(() => {
      this.dirValue = this.sortValue === col ? DIRECTIONS[this.dirValue].opposite : "asc"
      this.sortValue = col
    })
  }

  #handleInput(event) {
    if (!this.#hasTargetToken(event.target, "search")) return
    this.searchValue = event.target.value
    this.#interacted = true
    this.pageValue = 1
    this.debounceMsValue ? this.#deferRefresh() : this.refresh()
  }

  #deferRefresh() {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => this.refresh(), this.debounceMsValue)
  }

  // Select always replaces (single-choice); it cannot represent multi-value state.
  #handleChange(event) {
    const select = event.target
    if (!this.#hasTargetToken(select, "filterSelect")) return
    this.#rerun(() => this.#setDimensionFilter(select.dataset.filterDimension, select.value))
  }

  // An element may carry several space-separated target names; match tokens, not the whole string.
  #hasTargetToken(el, token) {
    return (el.dataset?.tableFilterTarget || "").split(" ").includes(token)
  }

  // Toggles a value within a dimension's list; "all" resets, and an emptied
  // list removes the dimension.
  #toggleDimensionFilter(dimension, value) {
    const current = this.filterDimensionsValue[dimension] ?? ALL_FILTER
    this.#setDimensionFilter(dimension, RowMatcher.toggledFilter(current, value))
  }

  // A missing/empty value removes the dimension from the filter state.
  #setDimensionFilter(dimension, value) {
    if (!dimension) return
    const { [dimension]: _omitted, ...rest } = this.filterDimensionsValue
    const inactive = value === undefined || value === ALL_FILTER
    this.filterDimensionsValue = inactive ? rest : { ...rest, [dimension]: value }
  }

  #navigator() {
    return new PageNavigator(this.pageSizeValue)
  }

  #matchedRows() {
    return this.rowTargets.filter(r => !r.classList.contains(HIDDEN_CLASS))
  }

  #filterRows() {
    const matcher = new RowMatcher(this.searchValue, this.filterDimensionsValue)
    this.#view.renderRowVisibility(this.rowTargets, matcher)
  }

  #renderStats() {
    const stats = RowStats.compute(this.rowTargets, this.#matchedRows())
    this.#view.renderStats(stats)
    this.#view.renderEmptyRow(stats.matched)
  }

  #applyPage() {
    const navigator = this.#navigator()
    this.#view.clearPageWindow(this.rowTargets)
    if (!navigator.enabled) return

    const matched = this.#matchedRows()
    this.pageValue = navigator.clamp(this.pageValue, matched.length)   // stale ?tf_page= from the URL
    this.#view.showPageWindow(matched, navigator.window(this.pageValue))
  }

  #goToPage(step) {
    const navigator = this.#navigator()
    const target = navigator.step(this.pageValue, step, this.#matchedRows().length)
    if (target === this.pageValue) return
    this.pageValue = target
    this.#interacted = true
    this.#applyPage()
    this.#view.renderPagination(this.pageValue, this.#matchedRows().length, navigator)
  }

  #reorder() {
    this.#view.reorderRows(this.#sorter().sort(this.rowTargets))
  }

  #sorter() {
    // Match by value instead of an interpolated attribute selector, since the sort
    // column can come from the URL and selector injection must stay impossible.
    const trigger = [...this.element.querySelectorAll(SELECTORS.sortButton)]
      .find(btn => btn.dataset.sortBtn === this.sortValue)
    return new RowSorter(this.sortValue, trigger?.dataset.sortType, this.dirValue)
  }

  #readUrlState() {
    this.#applyUrlState(UrlState.read(this.urlKeyValue))
  }

  // URL_FIELDS keys are Stimulus values, so state applies by name.
  #applyUrlState(state) {
    for (const [key, value] of Object.entries(state)) this[`${key}Value`] = value
  }

  #writeUrlState() {
    UrlState.write(this.urlKeyValue, {
      filterDimensions: this.filterDimensionsValue,
      sort:             this.sortValue,
      dir:              this.dirValue,
      search:           this.searchValue.trim(),
      page:             this.pageValue
    })
  }
}
