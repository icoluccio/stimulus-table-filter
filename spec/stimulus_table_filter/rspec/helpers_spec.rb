# frozen_string_literal: true

require 'spec_helper'
require 'stimulus_table_filter/rspec'

RSpec.describe StimulusTableFilter::RSpec::Helpers do
  def helper_with(**singleton_methods)
    Object.new.extend(described_class).tap do |h|
      singleton_methods.each { |name, val| h.define_singleton_method(name) { val } }
    end
  end

  describe '#html' do
    it 'returns response.body when response is available' do
      h = helper_with(response: Struct.new(:body).new('<html>r</html>'))
      expect(h.html).to eq('<html>r</html>')
    end

    it 'returns page.html when page is available' do
      h = helper_with(page: Struct.new(:html).new('<html>p</html>'))
      expect(h.html).to eq('<html>p</html>')
    end

    it 'raises StimulusTableFilter::Error when neither response nor page is available' do
      expect { Object.new.extend(described_class).html }
        .to raise_error(StimulusTableFilter::Error, /Define `let\(:html\)/)
    end

    it 'raises when page does not respond to html' do
      expect { helper_with(page: Object.new).html }.to raise_error(StimulusTableFilter::Error, /Define `let\(:html\)/)
    end
  end
end
