import { test } from 'node:test'
import assert from 'node:assert/strict'
import { RowStats } from '../../app/assets/javascripts/stimulus_table_filter/row_stats.js'
import { UrlState } from '../../app/assets/javascripts/stimulus_table_filter/url_state.js'

const row = (status) => ({ dataset: { filterStatus: status } })

test('computes matched and total counts over the filtered set', () => {
  const rows = [row('active'), row('draft'), row('archived')]
  const matchedRows = [rows[0], rows[1]]
  assert.deepEqual(RowStats.compute(rows, matchedRows), { matched: 2, total: 3 })
})

test('percentage rounds to the nearest whole number and survives empty tables', () => {
  assert.equal(RowStats.percentage(1, 3), 33)
  assert.equal(RowStats.percentage(0, 0), 0)
})

const withLocation = (search, pathname = '/items') => {
  globalThis.location = { search, pathname }
  const urls = []
  globalThis.history = { replaceState: (_state, _title, url) => urls.push(url) }
  return urls
}

test('read returns present params and drops the rest', () => {
  withLocation('?tf_sort=grade&tf_dir=desc')
  assert.deepEqual(UrlState.read('tf'), { sort: 'grade', dir: 'desc' })
})

test('read collects per-dimension filter params', () => {
  withLocation('?tf_filter_state=active&tf_filter_payment=paid')
  assert.deepEqual(UrlState.read('tf'), { filterDimensions: { state: 'active', payment: 'paid' } })
})

test('read parses the page as an integer', () => {
  withLocation('?tf_page=3')
  assert.deepEqual(UrlState.read('tf'), { page: 3 })
})

test('write keeps params that differ from their defaults', () => {
  const urls = withLocation('')
  UrlState.write('tf', { filterDimensions: { state: 'active' }, sort: 'grade', dir: 'desc', search: 'bob', page: 2 })
  assert.equal(urls[0], '/items?tf_sort=grade&tf_dir=desc&tf_page=2&tf_search=bob&tf_filter_state=active')
})

test('write drops params equal to their defaults and preserves foreign params', () => {
  const urls = withLocation('?keep=1&tf_filter_state=active')
  UrlState.write('tf', { filterDimensions: {}, sort: 'name', dir: 'asc', search: '', page: 1 })
  assert.equal(urls[0], '/items?keep=1')
})

test('write serializes dimension filters as separate params', () => {
  const urls = withLocation('')
  UrlState.write('tf', {
    filterDimensions: { state: 'active', payment: 'paid' },
    sort: 'name', dir: 'asc', search: '', page: 1
  })
  assert.equal(urls[0], '/items?tf_filter_state=active&tf_filter_payment=paid')
})

test('write drops dimension params that are empty or all', () => {
  const urls = withLocation('?tf_filter_state=active&tf_filter_payment=paid')
  UrlState.write('tf', {
    filterDimensions: { state: 'all', payment: '' },
    sort: 'name', dir: 'asc', search: '', page: 1
  })
  assert.equal(urls[0], '/items?')
})
