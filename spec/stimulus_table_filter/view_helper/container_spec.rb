# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StimulusTableFilter::ViewHelper, '#table_filter_container_tag' do
  subject(:result) { helper.table_filter_container_tag { '' } }

  include_context 'view helper'

  let(:result_with_extra_data) { helper.table_filter_container_tag(data: { custom: 'x' }) { '' } }

  it('sets the table-filter controller') { expect(result).to have_data('controller', 'table-filter') }
  it('sets default sort value') { expect(result).to have_data('table-filter-sort-value', 'name') }
  it('sets default dir value') { expect(result).to have_data('table-filter-dir-value', 'asc') }
  it('renders a div by default') { expect(result).to start_with('<div ') }

  it('omits page size value when page_size is not given') {
    expect(result).not_to have_data('table-filter-page-size-value')
  }

  it('omits page value when page is not given') {
    expect(result).not_to have_data('table-filter-page-value')
  }

  it 'accepts a custom initial sort column' do
    expect(helper.table_filter_container_tag(sort: 'title') { '' }).to have_data('table-filter-sort-value', 'title')
  end

  it 'accepts a custom tag' do
    expect(helper.table_filter_container_tag(tag: :section) { '' }).to start_with('<section ')
  end

  it 'sets page size value when page_size is given' do
    expect(helper.table_filter_container_tag(page_size: 25) { '' }).to have_data('table-filter-page-size-value', '25')
  end

  it 'sets page value when page is given' do
    expect(helper.table_filter_container_tag(page: 2) { '' }).to have_data('table-filter-page-value', '2')
  end

  it('omits url-key value when url_key is not given') {
    expect(result).not_to have_data('table-filter-url-key-value')
  }

  it('omits debounce-ms value when debounce_ms is not given') {
    expect(result).not_to have_data('table-filter-debounce-ms-value')
  }

  it('omits search value when search is not given') {
    expect(result).not_to have_data('table-filter-search-value')
  }

  it('sets search value when search is given') {
    expect(helper.table_filter_container_tag(search: 'rails') do
      ''
    end).to have_data('table-filter-search-value', 'rails')
  }

  it('sets url-key value when url_key is given') {
    expect(helper.table_filter_container_tag(url_key: 'items') do
      ''
    end).to have_data('table-filter-url-key-value', 'items')
  }

  it('sets debounce-ms value when debounce_ms is given') {
    expect(helper.table_filter_container_tag(debounce_ms: 200) do
      ''
    end).to have_data('table-filter-debounce-ms-value', '200')
  }

  it_behaves_like 'merges caller data', 'data-controller="table-filter"'
end
