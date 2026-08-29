import { test } from 'node:test'
import assert from 'node:assert/strict'
import { RowMatcher } from '../../app/assets/javascripts/stimulus_table_filter/row_matcher.js'

test('search matches data-name case-insensitively as a substring', () => {
  const matcher = new RowMatcher('LPH', {})
  assert.equal(matcher.matches({ dataset: { name: 'alpha' } }), true)
  assert.equal(matcher.matches({ dataset: { name: 'beta' } }), false)
})

test('search prefers data-searchable over data-name', () => {
  const matcher = new RowMatcher('tag', {})
  assert.equal(matcher.matches({ dataset: { name: 'alpha', searchable: 'Alpha Tag' } }), true)
  assert.equal(matcher.matches({ dataset: { name: 'alpha', searchable: 'Other' } }), false)
})

test('empty searchable falls back to data-name', () => {
  const matcher = new RowMatcher('alpha', {})
  assert.equal(matcher.matches({ dataset: { name: 'alpha', searchable: '' } }), true)
})

test('filter matches any value in the dimension list', () => {
  const matcher = new RowMatcher('', { status: 'active,draft' })
  assert.equal(matcher.matches({ dataset: { filterStatus: 'active' } }), true)
  assert.equal(matcher.matches({ dataset: { filterStatus: 'draft' } }), true)
  assert.equal(matcher.matches({ dataset: { filterStatus: 'archived' } }), false)
})

test('an "all" dimension value matches every row', () => {
  const matcher = new RowMatcher('', { status: 'all' })
  assert.equal(matcher.matches({ dataset: { filterStatus: 'anything' } }), true)
})

test('blank query and empty dimensions match every row', () => {
  const matcher = new RowMatcher('   ', {})
  assert.equal(matcher.matches({ dataset: { name: 'alpha', filterStatus: 'active' } }), true)
})

test('dimensions AND: the row must match every dimension with active values', () => {
  const matcher = new RowMatcher('', { status: 'active', payment: 'paid' })
  assert.equal(matcher.matches({ dataset: { filterStatus: 'active', filterPayment: 'paid' } }), true)
  assert.equal(matcher.matches({ dataset: { filterStatus: 'active', filterPayment: 'unpaid' } }), false)
  assert.equal(matcher.matches({ dataset: { filterStatus: 'archived', filterPayment: 'paid' } }), false)
})

test('rows without a value for an active dimension never match it', () => {
  const matcher = new RowMatcher('', { payment: 'paid' })
  assert.equal(matcher.matches({ dataset: {} }), false)
})

test('an "all" dimension value matches every row regardless of the row value', () => {
  const matcher = new RowMatcher('', { payment: 'all' })
  assert.equal(matcher.matches({ dataset: { filterPayment: 'whatever' } }), true)
})

test('toggledFilter replaces "all" with the clicked value', () => {
  assert.equal(RowMatcher.toggledFilter('all', 'active'), 'active')
})

test('toggledFilter toggles values in and out of the active list', () => {
  assert.equal(RowMatcher.toggledFilter('active', 'draft'), 'active,draft')
  assert.equal(RowMatcher.toggledFilter('active,draft', 'draft'), 'active')
})

test('toggledFilter returns "all" when the last value is removed', () => {
  assert.equal(RowMatcher.toggledFilter('active', 'active'), 'all')
})

test('toggledFilter resets to "all"', () => {
  assert.equal(RowMatcher.toggledFilter('active,draft', 'all'), 'all')
})
