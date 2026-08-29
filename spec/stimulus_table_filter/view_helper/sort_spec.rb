# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StimulusTableFilter::ViewHelper do
  include_context 'view helper'

  describe '#table_filter_sort_btn_tag' do
    it('renders a button') { expect(helper.table_filter_sort_btn_tag('title', 'Item')).to start_with('<button ') }

    it_behaves_like 'a sort trigger', :table_filter_sort_btn_tag
  end

  describe '#table_filter_sort_th_tag' do
    it('renders a th') { expect(helper.table_filter_sort_th_tag('title', 'Item')).to start_with('<th ') }

    it('adds scope="col" for accessibility') {
      expect(helper.table_filter_sort_th_tag('title', 'Item')).to include('scope="col"')
    }

    it_behaves_like 'a sort trigger', :table_filter_sort_th_tag
  end

  describe '#table_filter_column_tag' do
    let(:unsortable) { helper.table_filter_column_tag(col: 'actions', label: 'Actions', sortable: false) }

    it('renders a sortable th by default') {
      expect(helper.table_filter_column_tag(col: 'title', label: 'Item')).to have_data('sort-btn', 'title')
    }

    it('includes the label') { expect(helper.table_filter_column_tag(col: 'title', label: 'Item')).to include('Item') }

    it('includes the sort icon') {
      expect(helper.table_filter_column_tag(col: 'title', label: 'Item')).to have_data('sort-icon')
    }

    it('passes sort type through') {
      expect(helper.table_filter_column_tag(col: 'amount', label: 'Amount',
                                            type: 'numeric')).to have_data('sort-type', 'numeric')
    }

    it('renders a th when sortable: false') { expect(unsortable).to start_with('<th') }
    it('omits sort-btn when sortable: false') { expect(unsortable).not_to have_data('sort-btn') }
    it('keeps scope="col" for accessibility when sortable: false') { expect(unsortable).to include('scope="col"') }
  end
end
