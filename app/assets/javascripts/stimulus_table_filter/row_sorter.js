import { DIRECTIONS, SORT_TYPES } from "stimulus_table_filter/table_filter"

export class RowSorter {
  constructor(column, type, dir) {
    this.column = column
    this.spec = SORT_TYPES[type] ?? SORT_TYPES.string
    this.dir = (DIRECTIONS[dir] ?? DIRECTIONS.desc).multiplier
    this.key = `sort${column.charAt(0).toUpperCase()}${column.slice(1)}`
  }

  sort(rows) {
    return [...rows].sort((a, b) => this.compare(a, b))
  }

  value(row) {
    return row.dataset[this.key] ?? row.dataset[this.column] ?? ""
  }

  compare(a, b) {
    const av = this.value(a)
    const bv = this.value(b)
    if (this.spec.locale) return av.localeCompare(bv) * this.dir
    return this.nullsLast(this.spec.parse(av), this.spec.parse(bv))
  }

  // Present values compare numerically; missing values (null) sort last in both directions.
  nullsLast(av, bv) {
    if (av === null && bv === null) return 0
    if (av === null) return 1
    if (bv === null) return -1
    return (av - bv) * this.dir
  }
}
