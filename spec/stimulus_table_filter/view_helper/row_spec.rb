# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StimulusTableFilter::ViewHelper do
  include_context 'view helper'

  describe '#table_filter_row_attrs' do
    subject(:result) do
      helper.table_filter_row_attrs(name: 'Alpha', filters: { status: 'active' }, sort: { amount: 8.5 })
    end

    it('sets target to row') { expect(result[:data][:table_filter_target]).to eq('row') }
    it('downcases the name') { expect(result[:data][:name]).to eq('alpha') }
    it('emits the status as the default filter dimension') { expect(result[:data][:filter_status]).to eq('active') }
    it('prefixes sort values with sort_') { expect(result[:data][:sort_amount]).to eq('8.5') }
    it('omits searchable when not given') { expect(result[:data]).not_to have_key(:searchable) }
    it('omits group when not given') { expect(result[:data]).not_to have_key(:group) }

    it('omits the status dimension when status is not given') {
      expect(helper.table_filter_row_attrs(name: 'Alpha')[:data]).not_to have_key(:filter_status)
    }

    it('emits data-filter-* attributes for extra dimensions') {
      expect(helper.table_filter_row_attrs(name: 'beta', filters: { payment: 'paid', priority: 'high' })[:data])
        .to include(filter_payment: 'paid', filter_priority: 'high')
    }

    it('omits dimension attributes when filters is empty') {
      expect(helper.table_filter_row_attrs(name: 'beta')[:data]).not_to have_key(:filter_payment)
    }

    it('supports multiple sort columns') {
      expect(helper.table_filter_row_attrs(name: 'beta',
                                           sort: { amount: 9.0, created: '2024-01-01' })[:data]).to include(
                                             sort_amount: '9.0', sort_created: '2024-01-01'
                                           )
    }

    it('defaults sort_amount to empty string when nil') {
      expect(helper.table_filter_row_attrs(name: 'beta',
                                           sort: { amount: nil })[:data][:sort_amount]).to eq('')
    }

    it('includes searchable downcased when given') {
      expect(helper.table_filter_row_attrs(name: 'alpha',
                                           searchable: 'Alpha Tag')[:data][:searchable]).to eq('alpha tag')
    }

    it('includes group stringified when given') {
      expect(helper.table_filter_row_attrs(name: 'alpha',
                                           group: :category_a)[:data][:group]).to eq('category_a')
    }
  end

  describe '#table_filter_row_tag' do
    subject(:result) do
      helper.table_filter_row_tag(name: 'Alpha', filters: { status: 'active' },
                                  sort: { amount: 8.5 }) do
        ''
      end
    end

    let(:result_with_extra_data) do
      helper.table_filter_row_tag(name: 'alpha', filters: { status: 'active' }, data: { custom: 'x' }) do
        ''
      end
    end

    it('sets the table-filter-target') { expect(result).to have_data_target('row') }
    it('downcases the name in data attr') { expect(result).to have_data('name', 'alpha') }
    it('sets the status data attribute') { expect(result).to have_data('filter-status', 'active') }
    it('sets the sort-amount data attribute') { expect(result).to have_data('sort-amount', '8.5') }
    it('wraps content in a tr by default') { expect(result).to match(%r{<tr[^>]*></tr>}) }

    it('accepts a custom tag') {
      expect(helper.table_filter_row_tag(tag: :div, name: 'alpha', filters: { status: 'active' }) do
        ''
      end).to start_with('<div ')
    }

    it('sets data-searchable when given') {
      expect(helper.table_filter_row_tag(name: 'alpha',
                                         searchable: 'Alpha Tag') do
        ''
      end).to have_data('searchable', 'alpha tag')
    }

    it('sets data-group when given') {
      expect(helper.table_filter_row_tag(name: 'alpha',
                                         group: 'category-a') do
        ''
      end).to have_data('group', 'category-a')
    }

    it_behaves_like 'merges caller data', 'data-table-filter-target="row"'
  end

  describe '#table_filter_group_header_tag' do
    subject(:result) { helper.table_filter_group_header_tag('category-a') { 'Category A' } }

    it('sets groupHeader target') { expect(result).to have_data_target('groupHeader') }
    it('sets data-group') { expect(result).to have_data('group', 'category-a') }
    it('renders a tr by default') { expect(result).to start_with('<tr ') }
    it('renders content') { expect(result).to include('Category A') }

    it('accepts a custom tag') {
      expect(helper.table_filter_group_header_tag('x', tag: :div) do
        ''
      end).to start_with('<div ')
    }

    it('merges caller data') {
      expect(helper.table_filter_group_header_tag('x', data: { foo: 'bar' }) do
        ''
      end).to have_data('foo', 'bar')
    }
  end
end
