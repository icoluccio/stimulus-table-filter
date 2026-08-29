# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    private

    def with_data(base, opts) = base.merge(opts.delete(:data) || {})
    def target_data(target, opts) = with_data({ table_filter_target: target }, opts)
  end
end

require_relative 'view_helper/container'
require_relative 'view_helper/rows'
require_relative 'view_helper/controls'
require_relative 'view_helper/sort'
require_relative 'view_helper/stats'
