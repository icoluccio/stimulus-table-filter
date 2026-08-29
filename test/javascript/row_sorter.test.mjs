import { test } from 'node:test'
import assert from 'node:assert/strict'
import { RowSorter } from '../../app/assets/javascripts/stimulus_table_filter/row_sorter.js'

// Sorts a single column through RowSorter and returns the values in sorted order.
const sortColumn = (column, values, type = 'string', dir = 'asc') => {
  const key = `sort${column.charAt(0).toUpperCase()}${column.slice(1)}`
  const rows = values.map(value => ({ dataset: { [key]: value } }))
  return new RowSorter(column, type, dir).sort(rows).map(r => r.dataset[key])
}

test('string sort compares lexicographically in the given direction', () => {
  assert.deepEqual(sortColumn('title', ['b', 'a', 'c']), ['a', 'b', 'c'])
  assert.deepEqual(sortColumn('title', ['b', 'a', 'c'], 'string', 'desc'), ['c', 'b', 'a'])
})

test('numeric sort orders numerically, not lexicographically', () => {
  assert.deepEqual(sortColumn('amount', ['10', '2'], 'numeric'), ['2', '10'])
})

test('numeric sort puts missing values last in both directions', () => {
  assert.deepEqual(sortColumn('amount', ['', '10', '2'], 'numeric'), ['2', '10', ''])
  assert.deepEqual(sortColumn('amount', ['', '10', '2'], 'numeric', 'desc'), ['10', '2', ''])
})

test('numeric sort falls back to the plain column attribute', () => {
  const rows = [{ dataset: { amount: '5' } }, { dataset: { amount: '1' } }]
  const sorted = new RowSorter('amount', 'numeric', 'asc').sort(rows)
  assert.deepEqual(sorted.map(r => r.dataset.amount), ['1', '5'])
})

test('date-dmy sorts by actual date and puts missing values last', () => {
  const values = ['03/01/2024', '15/01/2024', '20/12/2023', '']
  assert.deepEqual(sortColumn('created', values, 'date-dmy'), ['20/12/2023', '03/01/2024', '15/01/2024', ''])
})

test('date-mdy parses month-first dates', () => {
  assert.deepEqual(sortColumn('created', ['01/15/2024', '01/03/2024'], 'date-mdy'), ['01/03/2024', '01/15/2024'])
})

test('ISO dates sort without an explicit type suffix', () => {
  assert.deepEqual(sortColumn('created', ['2024-02-01', '2024-01-15'], 'date'), ['2024-01-15', '2024-02-01'])
})
