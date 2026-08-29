// Full data-attribute contract: README.md, "Data-attribute contract".

export const ALL_FILTER = "all"
export const HIDDEN_CLASS = "hidden"
export const HIDDEN_STYLE = "none"
export const ACTIVE_BUTTON_CLASS = "btn-active"
export const ARIA_SORT_NONE = "none"
export const NEUTRAL_ICON = " ↕"

export const SELECTORS = {
  filterButton: "[data-filter-btn]",
  sortButton: "[data-sort-btn]",
  sortIcon: "[data-sort-icon]",
  prevPageButton: "[data-prev-page]",
  nextPageButton: "[data-next-page]",
  count: "[data-count-dimension]"
}

export const PAGE_STEPS = [[SELECTORS.prevPageButton, -1], [SELECTORS.nextPageButton, 1]]

export const TARGETS = {
  search: "search",
  row: "row",
  matchCount: "matchCount",
  totalCount: "totalCount",
  matchPct: "matchPct",
  emptyRow: "emptyRow",
  prevPage: "prevPage",
  nextPage: "nextPage",
  pageInfo: "pageInfo",
  groupHeader: "groupHeader",
  filterDisplay: "filterDisplay",
  filterSelect: "filterSelect"
}

export const DIRECTIONS = {
  asc:  { opposite: "desc", multiplier: 1,  aria: "ascending",  icon: " ↑" },
  desc: { opposite: "asc",  multiplier: -1, aria: "descending", icon: " ↓" }
}

export const pascalCase = (value) => value
  .split("-")
  .map(part => part.charAt(0).toUpperCase() + part.slice(1))
  .join("")

// Dataset key carrying a row's value for a filter dimension:
// data-filter-payment-status → dataset.filterPaymentStatus
export const dimensionDatasetKey = (dimension) => `filter${pascalCase(dimension)}`

export const dimensionValue = (row, dimension) => row.dataset[dimensionDatasetKey(dimension)]

const parseSlashDate = (value, dayFirst) => {
  const [first, second, year] = value.split("/")
  const day = dayFirst ? first : second
  const month = dayFirst ? second : first
  return new Date(+year, month - 1, +day).getTime()
}

// data-sort-type → parser: turns a cell string into a comparable number; strings stay locale-aware.
export const SORT_TYPES = {
  string:      { locale: true },
  numeric:     { parse: value => (value === "" ? null : parseFloat(value)) },
  date:        { parse: value => new Date(value).getTime() },
  "date-dmy":  { parse: value => parseSlashDate(value, true) },
  "date-mdy":  { parse: value => parseSlashDate(value, false) }
}

// Defaults are dropped from the URL when equal; parse normalizes values read back.
// Filter dimensions serialize separately as tf_filter_{dimension} params.
export const URL_FIELDS = [
  { key: "sort",   default: "name" },
  { key: "dir",    default: "asc", parse: value => (DIRECTIONS[value] ? value : undefined) },
  { key: "page",   default: 1,     parse: value => parseInt(value) || 1 },
  { key: "search", default: "" }
]
