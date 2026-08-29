import {
  ACTIVE_BUTTON_CLASS,
  ALL_FILTER,
  ARIA_SORT_NONE,
  DIRECTIONS,
  HIDDEN_CLASS,
  HIDDEN_STYLE,
  NEUTRAL_ICON,
  SELECTORS,
  TARGETS,
  dimensionValue,
  pascalCase
} from "stimulus_table_filter/table_filter"
import { FilterList } from "stimulus_table_filter/filter_list"
import { RowStats } from "stimulus_table_filter/row_stats"

export class TableView {
  constructor(controller) {
    this.controller = controller
  }

  renderRowVisibility(rows, matcher) {
    rows.forEach(row => row.classList.toggle(HIDDEN_CLASS, !matcher.matches(row)))
  }

  reorderRows(rows) {
    Map.groupBy(rows, row => row.parentElement)
       .forEach((groupRows, parent) => parent.append(...groupRows))
  }

  renderGroupHeaders(rows) {
    this.controller.groupHeaderTargets.forEach(header => {
      const hasVisibleRows = rows.some(r => r.dataset.group === header.dataset.group && this.isVisible(r))
      header.classList.toggle(HIDDEN_CLASS, !hasVisibleRows)
    })
  }

  clearPageWindow(rows) {
    rows.forEach(row => row.style.removeProperty("display"))
  }

  showPageWindow(rows, { start, end }) {
    rows.forEach((row, index) => {
      if (index < start || index >= end) row.style.display = HIDDEN_STYLE
    })
  }

  renderStats({ matched, total }) {
    const c = this.controller
    window.__targetDebug = Object.fromEntries(
      ['matchCount', 'totalCount', 'matchPct'].map((name) => {
        const key = pascalCase(name)
        const dom = c.element.querySelector(`[data-table-filter-target~="${name}"]`)
        return [name, {
          has: c[`has${key}Target`],
          get: c[`${key}Target`] ? 'el' : String(c[`${key}Target`]),
          dom: dom ? 'el' : 'missing'
        }]
      })
    )
    this.#target(TARGETS.matchCount).textContent = matched
    this.#target(TARGETS.totalCount).textContent = total
    this.#target(TARGETS.matchPct).textContent = `${RowStats.percentage(matched, total)}%`
  }

  renderCounts(matchedRows) {
    this.controller.element.querySelectorAll(SELECTORS.count).forEach(el => {
      el.textContent = matchedRows
        .filter(row => dimensionValue(row, el.dataset.countDimension) === el.dataset.countValue).length
    })
  }

  renderEmptyRow(matched) {
    this.#target(TARGETS.emptyRow).classList.toggle(HIDDEN_CLASS, matched > 0)
  }

  renderFilterButtons(dimensions) {
    this.controller.element.querySelectorAll(SELECTORS.filterButton).forEach(btn => {
      const list = this.listFor(dimensions, this.dimensionOf(btn))
      const isActive = btn.dataset.filterBtn === ALL_FILTER ? list.isEmpty : list.has(btn.dataset.filterBtn)
      this.setActiveState(btn, isActive)
    })
  }

  renderSortTriggers(sortValue, dirValue) {
    const direction = DIRECTIONS[dirValue]
    this.controller.element.querySelectorAll(SELECTORS.sortButton).forEach(btn => {
      const active = btn.dataset.sortBtn === sortValue
      this.renderSortTriggerState(btn, active, direction)
      this.#sortIcon(btn).textContent = active ? direction.icon : NEUTRAL_ICON
    })
  }

  renderSortTriggerState(btn, active, direction) {
    if (btn.tagName === "TH") {
      btn.setAttribute("aria-sort", active ? direction.aria : ARIA_SORT_NONE)
      return
    }
    this.setActiveState(btn, active)
  }

  renderFilterDisplay(dimensions) {
    const display = this.#target(TARGETS.filterDisplay)
    const list = this.listFor(dimensions, this.dimensionOf(display))
    display.hidden = list.isEmpty
    display.textContent = list.toString().replace(/,/g, ", ")
  }

  renderFilterSelect(dimensions) {
    const select = this.#target(TARGETS.filterSelect)
    select.value = this.listFor(dimensions, this.dimensionOf(select)).toString()
  }

  renderPagination(page, matchedTotal, navigator) {
    if (!navigator.enabled) return
    this.#target(TARGETS.prevPage).disabled = page <= 1
    this.#target(TARGETS.nextPage).disabled = page >= navigator.pageCount(matchedTotal)
    this.#target(TARGETS.pageInfo).textContent = navigator.info(page, matchedTotal)
  }

  isVisible(row) {
    return !row.classList.contains(HIDDEN_CLASS) && row.style.display !== HIDDEN_STYLE
  }

  setActiveState(btn, isActive) {
    btn.classList.toggle(ACTIVE_BUTTON_CLASS, isActive)
    btn.setAttribute("aria-pressed", isActive ? "true" : "false")
  }

  // A trigger's data-filter-dimension names the dimension it acts on.
  dimensionOf(el) {
    return el.dataset.filterDimension
  }

  listFor(dimensions, dimension) {
    return new FilterList(dimensions[dimension] ?? ALL_FILTER)
  }

  // Writes to a missing target land on a detached sink element and are discarded.
  // has is PascalCase (hasMatchCountTarget); the value getter is camelCase (matchCountTarget).
  #target(name) {
    const controller = this.controller
    return controller[`has${pascalCase(name)}Target`] ? controller[`${name}Target`] : document.createElement("template")
  }

  #sortIcon(btn) {
    return btn.querySelector(SELECTORS.sortIcon) ?? document.createElement("template")
  }
}
