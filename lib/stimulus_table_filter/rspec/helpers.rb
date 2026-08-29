# frozen_string_literal: true

require_relative '../error'

module StimulusTableFilter
  module RSpec
    # Provides `html` for shared examples: `response.body` in request specs, `page.html` in system specs.
    # Override with `let(:html) { ... }` in your example group if needed.
    module Helpers
      def html
        return response.body if respond_to?(:response) && response.respond_to?(:body)
        return page.html     if respond_to?(:page) && page.respond_to?(:html)

        raise StimulusTableFilter::Error, 'Define `let(:html) { ... }` or use inside a request or system spec'
      end
    end
  end
end
