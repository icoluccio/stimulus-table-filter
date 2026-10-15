# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StimulusTableFilter::ViewHelper do
  include_context 'view helper'

  describe '#table_filter_search_tag' do
    let(:result_with_extra_data) { helper.table_filter_search_tag(data: { custom: 'x' }) }

    it('renders a search input') { expect(helper.table_filter_search_tag).to include('type="search"') }

    it('sets the search target') {
      expect(helper.table_filter_search_tag).to have_data_target('search')
    }

    it_behaves_like 'merges caller data', 'data-table-filter-target="search"'
  end

  describe '#table_filter_bar_tag' do
    let(:filters) { { 'all' => 'All', 'active' => 'Active' } }
    let(:bar) do
      helper.table_filter_bar_tag(placeholder: 'Search…', filters: filters, dimension: 'status', class: 'toolbar',
                                  search: { class: 'input' }, group: { class: 'join' }, button: { class: 'btn' })
    end

    it('wraps the controls in a container with the given options') {
      expect(bar).to include('<div class="toolbar">')
    }

    it('renders the search input with its placeholder and options') {
      expect(bar).to include('placeholder="Search…"').and include('class="input"')
    }

    it('renders one filter button per value inside the group') {
      expect(bar).to include('<div class="join">').and include('data-filter-btn="all"')
        .and include('data-filter-btn="active"')
    }

    it('scopes the buttons to the dimension') {
      expect(bar.scan('data-filter-dimension="status"').size).to eq(2)
    }

    it('omits the button group when there are no filters') {
      expect(helper.table_filter_bar_tag(placeholder: 'Search…')).not_to include('data-filter-btn')
    }

    it('raises when filters are given without a dimension') {
      expect { helper.table_filter_bar_tag(filters: filters) }
        .to raise_error(StimulusTableFilter::Error, /requires dimension:/)
    }

    it('merges caller data on the search input and buttons') {
      html = helper.table_filter_bar_tag(filters: filters, dimension: 'status',
                                         search: { data: { a: 'x' } }, button: { data: { b: 'y' } })
      expect(html).to include('data-a="x"').and include('data-b="y"').and include('data-table-filter-target="search"')
    }
  end

  describe '#table_filter_filter_btn_tag' do
    let(:result_with_extra_data) do
      helper.table_filter_filter_btn_tag('active', 'Active', dimension: 'status', data: { custom: 'x' })
    end

    it('sets the filter-btn data attribute') {
      expect(helper.table_filter_filter_btn_tag('active', 'Active',
                                                dimension: 'status')).to have_data('filter-btn', 'active')
    }

    it('includes the label') {
      expect(helper.table_filter_filter_btn_tag('active', 'Active', dimension: 'status')).to include('Active')
    }

    it('marks the dimension on the button') {
      expect(helper.table_filter_filter_btn_tag('paid', 'Paid', dimension: 'payment'))
        .to have_data('filter-dimension', 'payment')
    }

    it('emits the dimension attribute even for the default dimension') {
      expect(helper.table_filter_filter_btn_tag('active', 'Active', dimension: 'status'))
        .to have_data('filter-dimension', 'status')
    }

    it_behaves_like 'merges caller data', 'data-filter-btn="active"'
  end

  describe '#table_filter_active_filter_tag' do
    subject(:result) { helper.table_filter_active_filter_tag(dimension: 'status') { 'Active' } }

    let(:result_with_extra_data) do
      helper.table_filter_active_filter_tag(dimension: 'status', data: { custom: 'x' }) do
        ''
      end
    end

    it('sets filterDisplay target') { expect(result).to have_data_target('filterDisplay') }
    it('is hidden by default') { expect(result).to include('hidden') }
    it('renders content') { expect(result).to include('Active') }

    it('marks the dimension on the display') {
      expect(helper.table_filter_active_filter_tag(dimension: 'payment') { '' })
        .to have_data('filter-dimension', 'payment')
    }

    it_behaves_like 'merges caller data', 'data-table-filter-target="filterDisplay"'
  end

  describe '#table_filter_select_tag' do
    subject(:result) { helper.table_filter_select_tag(options, dimension: 'status') }

    let(:options) { [%w[All all], %w[Active active], %w[Archived archived]] }
    let(:result_with_extra_data) { helper.table_filter_select_tag(options, dimension: 'status', data: { custom: 'x' }) }

    it('sets filterSelect target') { expect(result).to have_data_target('filterSelect') }
    it('renders a select element') { expect(result).to start_with('<select ') }
    it('renders option elements') { expect(result).to include('<option') }
    it('sets option values') { expect(result).to include('value="active"') }
    it('renders option labels') { expect(result).to include('Active') }
    it('renders all options') { expect(result.scan('<option').size).to eq(3) }

    it('renders one option per hash entry') {
      expect(helper.table_filter_select_tag({ 'All' => 'all', 'Active' => 'active' },
                                            dimension: 'status').scan('<option').size).to eq(2)
    }

    it('uses hash values as option values') {
      expect(helper.table_filter_select_tag({ 'All' => 'all', 'Active' => 'active' },
                                            dimension: 'status')).to include('value="active"')
    }

    it('uses the string as option value') {
      expect(helper.table_filter_select_tag(%w[All Active], dimension: 'status')).to include('value="All"')
    }

    it('uses the string as option label') {
      expect(helper.table_filter_select_tag(%w[All Active], dimension: 'status')).to include('>All</option>')
    }

    it_behaves_like 'merges caller data', 'data-table-filter-target="filterSelect"'
  end

  describe '#table_filter_empty_row_tag' do
    subject(:result) { helper.table_filter_empty_row_tag { '' } }

    let(:with_class) { helper.table_filter_empty_row_tag(class: 'text-center') { '' } }

    it('sets the emptyRow target') { expect(result).to have_data_target('emptyRow') }
    it('is hidden by default') { expect(result).to include('hidden') }

    it('keeps hidden when caller adds extra classes') { expect(with_class).to include('hidden') }
    it('includes caller class alongside hidden') { expect(with_class).to include('text-center') }

    it('handles array class values') {
      expect(helper.table_filter_empty_row_tag(class: %w[text-center py-2]) do
        ''
      end).to include('hidden text-center py-2')
    }
  end
end
