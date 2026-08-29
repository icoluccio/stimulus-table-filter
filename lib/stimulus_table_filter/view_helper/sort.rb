# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_sort_btn_tag(col, label, type: nil, **)
      table_filter_build_sort_trigger(:button, col, label, type: type, **)
    end

    def table_filter_sort_th_tag(col, label, type: nil, **)
      table_filter_build_sort_trigger(:th, col, label, type: type, **)
    end

    def table_filter_column_tag(col:, label:, type: nil, sortable: true, **)
      return content_tag(:th, label, scope: 'col', **) unless sortable

      table_filter_sort_th_tag(col, label, type: type, **)
    end

    private

    def sort_trigger_icon = content_tag(:span, '', data: { sort_icon: '' })
    def sort_btn_base(col, type) = type ? { sort_btn: col, sort_type: type } : { sort_btn: col }
    def sort_trigger_data(col, type, opts) = sort_btn_base(col, type).merge(opts.delete(:data) || {})

    def table_filter_build_sort_trigger(tag, col, label, type: nil, **opts)
      data = sort_trigger_data(col, type, opts)
      opts = { scope: 'col' }.merge(opts) if tag == :th
      content_tag(tag, ERB::Util.html_escape(label) + sort_trigger_icon, data: data, **opts)
    end
  end
end
