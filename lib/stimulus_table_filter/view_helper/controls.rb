# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_search_tag(**opts) = tag.input(type: 'search', data: target_data('search', opts), **opts)

    # Raises StimulusTableFilter::Error if +filters+ is given without +dimension+.
    def table_filter_bar_tag(placeholder: nil, filters: {}, dimension: nil, search: {}, group: {}, button: {}, **opts)
      content_tag(:div, **opts) do
        safe_join([table_filter_search_tag(placeholder: placeholder, **search),
                   table_filter_button_group(filters, dimension, group, button)])
      end
    end

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

    def table_filter_button_group(filters, dimension, group, button)
      return if filters.empty?

      content_tag(:div, table_filter_buttons(filters, dimension, button), **group)
    end

    def table_filter_buttons(filters, dimension, button)
      raise Error, 'table_filter_bar_tag requires dimension: when filters are given' unless dimension

      safe_join(filters.map { |value, label| table_filter_filter_btn_tag(value, label, dimension:, **button) })
    end

    def option_tag(pair) = content_tag(:option, pair.first, value: pair.last)
    def render_options(pairs) = safe_join(pairs.map(&method(:option_tag)))

    def normalize_options(options)
      pairs = options.is_a?(Hash) ? options.to_a : options
      pairs.map { |pair| pair.is_a?(Array) ? pair : [pair, pair] }
    end
  end
end
