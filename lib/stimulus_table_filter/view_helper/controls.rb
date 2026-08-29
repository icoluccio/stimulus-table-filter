# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_search_tag(**opts) = tag.input(type: 'search', data: target_data('search', opts), **opts)

    def table_filter_filter_btn_tag(value, label, dimension: nil, **opts)
      data = with_data({ filter_btn: value }, opts)
      data[:filter_dimension] = dimension if dimension
      content_tag(:button, label, data: data, **opts)
    end

    def table_filter_empty_row_tag(**opts, &)
      data  = target_data('emptyRow', opts)
      klass = ['hidden', *Array(opts.delete(:class))].join(' ')
      content_tag(:tr, data: data, class: klass, **opts, &)
    end

    def table_filter_active_filter_tag(dimension: nil, **opts, &)
      data = target_data('filterDisplay', opts)
      data[:filter_dimension] = dimension if dimension
      content_tag(:span, data: data, hidden: true, **opts, &)
    end

    def table_filter_select_tag(options, dimension: nil, **opts)
      data = with_data({ table_filter_target: 'filterSelect' }, opts)
      data[:filter_dimension] = dimension if dimension
      pairs = normalize_options(options)
      content_tag(:select, data: data, **opts) { render_options(pairs) }
    end

    private

    def option_tag(pair) = content_tag(:option, pair.first, value: pair.last)
    def render_options(pairs) = safe_join(pairs.map(&method(:option_tag)))

    def normalize_options(options)
      pairs = options.is_a?(Hash) ? options.to_a : options
      pairs.map { |pair| pair.is_a?(Array) ? pair : [pair, pair] }
    end
  end
end
