# frozen_string_literal: true

require_relative 'rspec/helpers'
require_relative 'rspec/matchers'
require_relative '../spec/shared_examples/table_filter_view'
require_relative '../spec/shared_examples/table_filter_footer'
require_relative '../spec/shared_examples/table_filter_rows'

module StimulusTableFilter
  # Opt-in wiring for the shared examples.
  # Call StimulusTableFilter::RSpec.install! from your spec support file.
  module RSpec
    def self.install!
      ::RSpec.configure do |config|
        config.include Helpers
      end
    end
  end
end
