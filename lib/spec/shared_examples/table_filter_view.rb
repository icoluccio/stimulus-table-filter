# frozen_string_literal: true

RSpec.shared_examples 'a table filter view' do
  it('has a table-filter controller') { expect(html).to have_data('controller', 'table-filter') }
  it('has a search input target') { expect(html).to have_data_target('search') }
  it('has at least one filterable row') { expect(html).to have_data_target('row') }
  it('has filter status buttons') { expect(html).to have_data('filter-btn') }
  it('has sort buttons') { expect(html).to have_data('sort-btn') }
end

RSpec.shared_examples 'a table filter with sortable th headers' do
  it('uses th elements as sort triggers') { expect(html).to have_data('sort-btn').on('th') }
end

RSpec.shared_examples 'a table filter with sort column' do |col|
  it("has a sort trigger for column '#{col}'") { expect(html).to have_data('sort-btn', col) }
end

RSpec.shared_examples 'a table filter with empty row' do
  it('has an empty-state row target') { expect(html).to have_data_target('emptyRow') }
end

RSpec.shared_examples 'a table filter with pagination controls' do
  it('has a prev page button') { expect(html).to have_data('prev-page') }
  it('has a next page button') { expect(html).to have_data('next-page') }
  it('has a page info target') { expect(html).to have_data_target('pageInfo') }
end

RSpec.shared_examples 'a table filter with group headers' do
  it('has a groupHeader target') { expect(html).to have_data_target('groupHeader') }
end

RSpec.shared_examples 'a table filter with group' do |group|
  it("has rows in group '#{group}'") { expect(html).to have_data('group', group) }
end

RSpec.shared_examples 'a table filter with filter select' do
  it('has a filterSelect target') { expect(html).to have_data_target('filterSelect') }
end

RSpec.shared_examples 'a table filter with filter display' do
  it('has a filterDisplay target') { expect(html).to have_data_target('filterDisplay') }
end

RSpec.shared_examples 'a table filter with initial sort' do |col, dir: 'asc'|
  it("has sort-value '#{col}'") { expect(html).to have_data('table-filter-sort-value', col) }
  it("has dir-value '#{dir}'") { expect(html).to have_data('table-filter-dir-value', dir) }
end

RSpec.shared_examples 'a table filter with page size' do |n|
  it("has page-size-value '#{n}'") { expect(html).to have_data('table-filter-page-size-value', n) }
end

RSpec.shared_examples 'a table filter with url key' do |key|
  it("has url-key-value '#{key}'") { expect(html).to have_data('table-filter-url-key-value', key) }
end

RSpec.shared_examples 'a table filter with debounce' do |ms|
  it("has debounce-ms-value '#{ms}'") { expect(html).to have_data('table-filter-debounce-ms-value', ms) }
end

RSpec.shared_examples 'a table filter with count' do |dimension, value|
  it("has a count for #{dimension} '#{value}'") {
    expect(html).to have_data('count-dimension', dimension).and have_data('count-value', value)
  }
end

RSpec.shared_examples 'a table filter with filter btn' do |value|
  it("has a filter button for '#{value}'") { expect(html).to have_data('filter-btn', value) }
end

RSpec.shared_examples 'a table filter with sort type' do |col, type|
  it("sort trigger '#{col}' has type '#{type}'") {
    expect(html).to have_data('sort-btn', col).and have_data('sort-type', type)
  }
end

RSpec.shared_examples 'a table filter row with sort column' do |col|
  it("rows have data-sort-#{col} attribute") { expect(html).to have_data("sort-#{col}") }
end

RSpec.shared_examples 'a table filter with accessible sort headers' do
  let(:sortable_ths) { Nokogiri::HTML.fragment(html).css('th[data-sort-btn]') }

  it('has th elements as sort triggers') { expect(sortable_ths).not_to be_empty }
  it('sort th triggers have scope="col"') { expect(sortable_ths.map { |th| th['scope'] }).to all(eq('col')) }
end
