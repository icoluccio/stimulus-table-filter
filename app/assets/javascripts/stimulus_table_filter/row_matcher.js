import { ALL_FILTER, dimensionValue } from "stimulus_table_filter/table_filter"
import { FilterList } from "stimulus_table_filter/filter_list"

// dimensions: { name → comma-separated active values }. A row must match
// every dimension that has active values (AND), any value within it (OR).
export class RowMatcher {
  constructor(query, dimensions) {
    this.query = (query || "").toLowerCase().trim()
    this.sets = Object.entries(dimensions ?? {})
      .map(([dimension, value]) => ({ dimension, list: new FilterList(value) }))
  }

  matches(row) {
    const text = (row.dataset.searchable || row.dataset.name || "").toLowerCase()
    return this.matchesQuery(text) && this.sets.every(set => this.matchesDimension(set, row))
  }

  matchesQuery(text) {
    return !this.query || text.includes(this.query)
  }

  // A dimension with no active values matches every row; rows without a
  // value for an active dimension never match it.
  matchesDimension({ dimension, list }, row) {
    return list.isEmpty || list.has(dimensionValue(row, dimension))
  }

  // Multi-value: toggles the value in/out of a comma-separated list; "all" resets.
  static toggledFilter(current, value) {
    if (value === ALL_FILTER) return ALL_FILTER
    if (current === ALL_FILTER) return value
    const list = new FilterList(current)
    list.toggle(value)
    return list.toString()
  }
}
