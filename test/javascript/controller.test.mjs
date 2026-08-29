import { test } from 'node:test'
import assert from 'node:assert/strict'
import controller from '../../app/assets/javascripts/stimulus_table_filter/table_filter_controller.js'
import { TableView } from '../../app/assets/javascripts/stimulus_table_filter/table_filter_view.js'

test('the controller and view modules load with their full import graphs', () => {
  assert.equal(typeof controller, 'function')
  assert.equal(controller.targets.length, 12)
  assert.equal(typeof TableView, 'function')
})
