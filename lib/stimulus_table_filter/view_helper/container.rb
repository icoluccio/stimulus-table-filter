# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_container_tag(sort: 'name', dir: 'asc', page: nil, page_size: nil, url_key: nil,
                                   debounce_ms: nil, tag: :div, **opts, &)
      data = container_data(sort:, dir:, page:, page_size:, url_key:,
                            debounce_ms:).merge(opts.delete(:data) || {})
      content_tag(tag, data: data, **opts, &)
    end

    private

    def base_container_data(sort:, dir:, page: nil)
      base = { controller: 'table-filter', table_filter_sort_value: sort, table_filter_dir_value: dir }
      base[:table_filter_page_value] = page.to_s if page
      base
    end

    def container_data(sort:, dir:, page: nil, page_size: nil, url_key: nil, debounce_ms: nil)
      base = base_container_data(sort:, dir:, page:)
      base = base.merge(table_filter_page_size_value: page_size.to_s)     if page_size
      base = base.merge(table_filter_url_key_value: url_key.to_s)         if url_key
      base = base.merge(table_filter_debounce_ms_value: debounce_ms.to_s) if debounce_ms
      base
    end
  end
end
