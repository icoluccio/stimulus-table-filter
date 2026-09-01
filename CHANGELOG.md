# Changelog

All notable changes to this project will be documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.1] - 2026-08-31

- `table_filter_container_tag` accepts a `search:` option and emits
  `data-table-filter-search-value`, matching the documented data-attribute contract
- README: document that `table_filter_footer_tag` wraps its content in a footer element, a
  `<tr>` and a `<td>`; correct the URL-state and programmatic-API behavior notes

## [0.1.0] - 2026-08-25

Initial release.

- Stimulus controller (`table-filter`): instant search, filter dimensions, multi-column
  sort, pagination, group headers, URL state and live footer stats
- Rails Engine with view helpers for the whole widget; opt-in CSS
- RSpec support: shared examples plus `have_data` / `have_data_target` matchers
- CI: RuboCop, RSpec and JavaScript tests across Ruby 3.2–3.4 and Rails 7.0–8.1

[0.1.1]: https://github.com/icoluccio/stimulus-table-filter/releases/tag/v0.1.1
[0.1.0]: https://github.com/icoluccio/stimulus-table-filter/releases/tag/v0.1.0
