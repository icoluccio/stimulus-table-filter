# frozen_string_literal: true

module StimulusTableFilter
  module ViewHelper
    def table_filter_prev_btn_tag(label = '←', **opts)
      content_tag(:button, label, data: with_data({ prev_page: '', table_filter_target: 'prevPage' }, opts), **opts)
    end

    def table_filter_next_btn_tag(label = '→', **opts)
      content_tag(:button, label, data: with_data({ next_page: '', table_filter_target: 'nextPage' }, opts), **opts)
    end

    def table_filter_page_info_tag(**opts) = content_tag(:span, '', data: target_data('pageInfo', opts), **opts)

    def table_filter_match_count_tag(**)  = table_filter_stat_span('matchCount', **)
    def table_filter_total_count_tag(**)  = table_filter_stat_span('totalCount', **)
    def table_filter_match_pct_tag(**)    = table_filter_stat_span('matchPct', **)

    def table_filter_count_tag(dimension:, value:, **opts)
      data = with_data({ count_dimension: dimension, count_value: value }, opts)
      content_tag(:span, '', data: data, **opts)
    end

    def table_filter_footer_tag(colspan: nil, tag: :tfoot, **opts, &)
      content_tag(tag) do
        content_tag(:tr) do
          td_opts = colspan ? { colspan: colspan } : {}
          content_tag(:td, **td_opts, **opts) { footer_content(&) }
        end
      end
    end

    private

    def footer_content(&)
      return default_footer_content unless block_given?

      capture(table_filter_match_count_tag, table_filter_total_count_tag, &)
    end

    def table_filter_stat_span(target, **opts) = content_tag(:span, '', data: target_data(target, opts), **opts)

    def default_footer_content
      safe_join([table_filter_match_count_tag, ' of ', table_filter_total_count_tag])
    end
  end
end
