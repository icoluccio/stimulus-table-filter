import { ALL_FILTER } from "stimulus_table_filter/table_filter"

export class FilterList {
  constructor(current) {
    this.values = current === ALL_FILTER ? new Set() : new Set(current.split(","))
  }

  toggle(value) {
    this.values.has(value) ? this.values.delete(value) : this.values.add(value)
  }

  has(value) { return this.values.has(value) }

  get isEmpty() { return this.values.size === 0 }

  toString() { return this.isEmpty ? ALL_FILTER : [...this.values].join(",") }
}
