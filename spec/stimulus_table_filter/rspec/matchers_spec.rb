# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'data attribute matchers' do
  let(:markup) { '<div data-foo="bar" data-empty="" data-table-filter-target="row other"></div>' }

  describe 'have_data' do
    it('matches a value') { expect(markup).to have_data('foo', 'bar') }
    it('matches values given as non-strings') { expect(markup).to have_data('foo', :bar) }
    it('matches attribute presence') { expect(markup).to have_data('empty') }
    it('matches within a specific tag') { expect(markup).to have_data('foo', 'bar').on('div') }
    it('does not match absent values') { expect(markup).not_to have_data('foo', 'nope') }
    it('does not match absent attributes') { expect(markup).not_to have_data('missing') }

    it('lists the found values in the failure message') {
      matcher = have_data('foo', 'nope')
      matcher.matches?(markup)
      expect(matcher.failure_message).to include('found: ["bar"]')
    }

    it('reports a missing attribute in the failure message') {
      matcher = have_data('missing')
      matcher.matches?(markup)
      expect(matcher.failure_message).to include('no element has one')
    }
  end

  describe 'have_data_target' do
    it('matches one of several space-separated targets') { expect(markup).to have_data_target('other') }
    it('does not match absent targets') { expect(markup).not_to have_data_target('search') }

    it('lists the targets present in the failure message') {
      matcher = have_data_target('search')
      matcher.matches?(markup)
      expect(matcher.failure_message).to include('targets present: ["row other"]')
    }
  end
end
