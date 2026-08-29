# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'stimulus_table_filter'
require 'stimulus_table_filter/rspec'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
