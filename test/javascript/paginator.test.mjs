import { test } from 'node:test'
import assert from 'node:assert/strict'
import { Paginator } from '../../app/assets/javascripts/stimulus_table_filter/paginator.js'

const PAGE_SIZE = 25
const TOTAL = 87
const LAST_PAGE = 4   // ceil(87 / 25)
const paginator = (size = PAGE_SIZE) => new Paginator(size)

test('is disabled when the page size is 0 or missing', () => {
  assert.equal(paginator(0).enabled, false)
  assert.equal(new Paginator(undefined).enabled, false)
})

test('page count rounds up and never returns zero', () => {
  assert.equal(paginator().pageCount(TOTAL), LAST_PAGE)
  assert.equal(paginator().pageCount(PAGE_SIZE), 1)
  assert.equal(paginator().pageCount(0), 1)
})

test('clamp caps the page at the last one with rows', () => {
  assert.equal(paginator().clamp(99, TOTAL), LAST_PAGE)
  assert.equal(paginator().clamp(2, TOTAL), 2)
})

test('window returns the slice bounds for a page', () => {
  assert.deepEqual(paginator().window(3), { start: 50, end: 75 })
  assert.deepEqual(paginator().window(1), { start: 0, end: PAGE_SIZE })
})

test('info formats the visible range for the matched rows', () => {
  assert.equal(paginator().info(2, TOTAL), '26–50 of 87')
  assert.equal(paginator().info(LAST_PAGE, TOTAL), '76–87 of 87')
  assert.equal(paginator().info(1, 0), '')
})
