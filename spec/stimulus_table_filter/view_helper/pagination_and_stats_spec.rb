# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StimulusTableFilter::ViewHelper do
  include_context 'view helper'

  describe '#table_filter_prev_btn_tag' do
    subject(:result) { helper.table_filter_prev_btn_tag }

    it('renders a button') { expect(result).to start_with('<button') }
    it('has data-prev-page') { expect(result).to have_data('prev-page') }
    it('has prevPage target') { expect(result).to have_data_target('prevPage') }
    it('uses ← as default label') { expect(result).to include('←') }
    it('accepts a custom label') { expect(helper.table_filter_prev_btn_tag('Previous')).to include('Previous') }
  end

  describe '#table_filter_next_btn_tag' do
    subject(:result) { helper.table_filter_next_btn_tag }

    it('renders a button') { expect(result).to start_with('<button') }
    it('has data-next-page') { expect(result).to have_data('next-page') }
    it('has nextPage target') { expect(result).to have_data_target('nextPage') }
    it('uses → as default label') { expect(result).to include('→') }
    it('accepts a custom label') { expect(helper.table_filter_next_btn_tag('Next')).to include('Next') }
  end

  describe '#table_filter_page_info_tag' do
    it('renders a span') { expect(helper.table_filter_page_info_tag).to start_with('<span') }

    it('has pageInfo target') {
      expect(helper.table_filter_page_info_tag).to have_data_target('pageInfo')
    }
  end

  describe '#table_filter_match_count_tag' do
    it('has matchCount target') {
      expect(helper.table_filter_match_count_tag).to have_data_target('matchCount')
    }
  end

  describe '#table_filter_total_count_tag' do
    it('has totalCount target') {
      expect(helper.table_filter_total_count_tag).to have_data_target('totalCount')
    }
  end

  describe '#table_filter_match_pct_tag' do
    it('has matchPct target') {
      expect(helper.table_filter_match_pct_tag).to have_data_target('matchPct')
    }
  end

  describe '#table_filter_count_tag' do
    let(:result_with_extra_data) do
      helper.table_filter_count_tag(dimension: 'status', value: 'active', data: { custom: 'x' })
    end

    it('marks the dimension and value') {
      expect(helper.table_filter_count_tag(dimension: 'status', value: 'active'))
        .to have_data('count-dimension', 'status').and have_data('count-value', 'active')
    }

    it('renders a span') {
      expect(helper.table_filter_count_tag(dimension: 'status', value: 'active')).to start_with('<span')
    }

    it_behaves_like 'merges caller data', 'data-count-dimension="status"'
  end

  describe '#table_filter_footer_tag' do
    subject(:result) { helper.table_filter_footer_tag { '' } }

    let(:default_footer) { helper.table_filter_footer_tag }

    it('wraps in tfoot') { expect(result).to start_with('<tfoot>') }
    it('contains a tr') { expect(result).to include('<tr>') }
    it('contains a td') { expect(result).to include('<td>') }

    it 'applies colspan to the td' do
      expect(helper.table_filter_footer_tag(colspan: 5) { '' }).to include('colspan="5"')
    end

    it 'applies html options to the td' do
      expect(helper.table_filter_footer_tag(class: 'text-sm') { '' }).to include('class="text-sm"')
    end

    it 'accepts a custom tag' do
      expect(helper.table_filter_footer_tag(tag: :div) { '' }).to start_with('<div>')
    end

    it('renders the match count span by default') { expect(default_footer).to have_data_target('matchCount') }
    it('renders the total count span by default') { expect(default_footer).to have_data_target('totalCount') }
    it('joins the two counts with "of"') { expect(default_footer).to include(' of ') }
    it('omits the percentage span by default') { expect(default_footer).not_to have_data_target('matchPct') }

    it('renders block content instead of default') {
      expect(helper.table_filter_footer_tag { 'custom' }).to include('custom')
    }

    it('omits the default spans when a block is given') {
      expect(helper.table_filter_footer_tag { 'custom' }).not_to have_data_target('matchCount')
    }

    it 'yields match_count and total_count spans to the block' do
      spans = []
      helper.table_filter_footer_tag { |match, total| spans.push(match, total).join }
      expect(spans.map { |s| s[/data-table-filter-target="(\w+)"/, 1] }).to eq(%w[matchCount totalCount])
    end
  end
end
