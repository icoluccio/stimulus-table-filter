import { URL_FIELDS } from "stimulus_table_filter/table_filter"

export class UrlState {
  static read(prefix) {
    const state = {}
    const params = this.withParams(prefix, (params, field, param) => {
      if (!params.has(param)) return
      const value = field.parse ? field.parse(params.get(param)) : params.get(param)
      if (value !== undefined) state[field.key] = value
    })
    const dimensions = this.readDimensions(params, prefix)
    if (dimensions.size) state.filterDimensions = Object.fromEntries(dimensions)
    return state
  }

  static write(prefix, state) {
    const params = this.withParams(prefix, (params, field, param) => {
      const value = state[field.key]
      if (value === undefined || value === field.default) params.delete(param)
      else params.set(param, String(value))
    })
    const dimensions = state.filterDimensions ?? {}
    const marker = `${prefix}_filter_`
    for (const key of [...params.keys()]) {
      if (key.startsWith(marker) && !Object.hasOwn(dimensions, key.slice(marker.length))) params.delete(key)
    }
    for (const [dimension, value] of Object.entries(dimensions)) {
      const param = `${prefix}_filter_${dimension}`
      if (!value || value === "all") params.delete(param)
      else params.set(param, value)
    }
    history.replaceState(null, "", `${location.pathname}?${params}`)
  }

  static withParams(prefix, apply) {
    const params = new URLSearchParams(location.search)
    for (const field of URL_FIELDS) apply(params, field, `${prefix}_${field.key}`)
    return params
  }

  static readDimensions(params, prefix) {
    const dimensions = new Map()
    const marker = `${prefix}_filter_`
    for (const [key, value] of params) {
      if (!key.startsWith(marker)) continue
      const dimension = key.slice(marker.length)
      if (dimension) dimensions.set(dimension, value)
    }
    return dimensions
  }
}
