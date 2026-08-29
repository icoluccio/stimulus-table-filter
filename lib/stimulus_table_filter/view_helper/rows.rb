# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_row_attrs(name:, filters: {}, sort: {}, searchable: nil, group: nil)
      data = { table_filter_target: 'row', name: name.to_s.downcase, **filter_data(filters), **sort_data(sort) }
      extras = { searchable: searchable&.to_s&.downcase, group: group&.to_s }.compact
      { data: data.merge(extras) }
    end

    def table_filter_row_tag(name:, filters: {}, sort: {}, searchable: nil, group: nil,
                             tag: :tr, **html_options, &)
      data = with_data(
        table_filter_row_attrs(name: name, filters: filters, sort: sort,
                               searchable: searchable, group: group)[:data], html_options
      )
      content_tag(tag, data: data, **html_options, &)
    end

    def table_filter_group_header_tag(group, tag: :tr, **opts, &)
      data = with_data({ table_filter_target: 'groupHeader', group: group.to_s }, opts)
      content_tag(tag, data: data, **opts, &)
    end

    private

    def filter_key(key) = :"filter_#{key}"
    def filter_data(filters) = filters.transform_keys(&method(:filter_key)).transform_values(&:to_s)
    def sort_key(key) = :"sort_#{key}"
    def sort_data(sort) = sort.transform_keys(&method(:sort_key)).transform_values(&:to_s)
  end
end
