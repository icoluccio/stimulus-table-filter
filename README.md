stimulus_table_filter
=====================

[![CI](https://github.com/icoluccio/stimulus-table-filter/actions/workflows/ci.yml/badge.svg)](https://github.com/icoluccio/stimulus-table-filter/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/stimulus_table_filter.svg)](https://badge.fury.io/rb/stimulus_table_filter)

# Table of contents
  - [Description](#description)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Quick start](#quick-start)
    - [Container](#container)
    - [Rows](#rows)
    - [Search](#search)
    - [Filter buttons](#filter-buttons)
    - [Select and active-filter display](#select-and-active-filter-display)
    - [Group headers](#group-headers)
    - [Column headers](#column-headers)
    - [Sort triggers](#sort-triggers)
    - [Empty row](#empty-row)
    - [Footer stats](#footer-stats)
    - [Pagination](#pagination)
    - [Data-attribute contract](#data-attribute-contract)
    - [RSpec shared examples](#rspec-shared-examples)
  - [Contributing](#contributing)
  - [Releases](#releases)
  - [About](#about)
  - [License](#license)

-----------------------

## Description

stimulus-table-filter is a Stimulus controller for Rails that adds instant search, filter
dimensions, multi-column sort, pagination, and live footer stats to any table or list, with zero
JavaScript dependencies. Everything is driven by data attributes. It ships a Rails Engine
that registers the view helpers and wires the controller's importmap pin and assets.

## Installation

Add the following line to your application's Gemfile:

```ruby
gem 'stimulus_table_filter'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install stimulus_table_filter
```

Requires Ruby 3.2+ and Rails 7.0+ with importmap (the Rails 7+ default).

### CSS (optional)

Add the gem's stylesheet to your application layout to get
`cursor: pointer; user-select: none` on sort triggers:

```erb
<%= stylesheet_link_tag "stimulus_table_filter/table_filter", "data-turbo-track": "reload" %>
```

Omit if your own CSS already handles sort-trigger styling.

### Register the controller

The importmap pin is automatic. Registering the controller with your Stimulus application is a
one-liner in your controllers entrypoint:

```js
// app/javascript/controllers/index.js
import TableFilterController from "stimulus_table_filter/table_filter_controller"
application.register("table-filter", TableFilterController)
```

### RSpec

```ruby
# spec/rails_helper.rb
require "stimulus_table_filter/rspec"
StimulusTableFilter::RSpec.install!
```

This includes the `html` helper in all example groups, loads the shared
examples (see [RSpec shared examples](#rspec-shared-examples)) and defines the
`have_data` / `have_data_target` matchers.

### RSpec matchers

The matchers parse the HTML with Nokogiri and assert on real attributes. On failure they list
the found attributes, instead of a raw string diff:

```ruby
expect(html).to have_data('sort-btn', 'amount')   # any element with data-sort-btn="amount"
expect(html).to have_data('filter-btn')          # attribute present, any value
expect(html).to have_data('sort-btn').on('th')   # scoped to <th> elements
expect(html).to have_data_target('matchCount')   # data-table-filter-target="matchCount"
```

## Usage

### Quick start

A complete filterable table in one view partial:

```erb
<%= table_filter_container_tag do %>
  <%# Search + filter bar %>
  <div>
    <%= table_filter_search_tag(placeholder: "Search users…") %>
    <%= table_filter_filter_btn_tag("all",      "All",      dimension: "status") %>
    <%= table_filter_filter_btn_tag("active",   "Active",   dimension: "status") %>
    <%= table_filter_filter_btn_tag("archived", "Archived", dimension: "status") %>
  </div>

  <table>
    <thead>
      <tr>
        <%= table_filter_sort_th_tag("name",   "Name") %>
        <th>Status</th>
        <%= table_filter_sort_th_tag("amount", "Amount", type: "numeric") %>
      </tr>
    </thead>
    <tbody>
      <% @users.each do |user| %>
        <%= table_filter_row_tag(
              name:    user.username,
              filters: { status: user.active? ? "active" : "archived" },
              sort:    { amount: user.balance }
            ) do %>
          <td><%= user.username %></td>
          <td><%= user.status %></td>
          <td><%= user.balance %></td>
        <% end %>
      <% end %>

      <%= table_filter_empty_row_tag do %>
        <td colspan="3">No results</td>
      <% end %>
    </tbody>
    <tfoot>
      <tr>
        <td colspan="3">
          <%= table_filter_match_count_tag %> of <%= table_filter_total_count_tag %>
        </td>
      </tr>
    </tfoot>
  </table>
<% end %>
```

Register the controller once (see [Register the controller](#register-the-controller)).
Click a `<th>` to sort; click again to reverse; type to search.

### Container

Wraps the entire widget. Emits `data-controller="table-filter"` and the initial-value attributes
the controller reads on connect.

```erb
<%= table_filter_container_tag(sort: "name", dir: "asc") do %>
  ...
<% end %>
```

| Option | Default | Description |
|--------|---------|-------------|
| `sort:` | `"name"` | Initial sort column |
| `dir:` | `"asc"` | Initial direction: `"asc"` or `"desc"` |
| `page:` | `nil` | Initial page number |
| `page_size:` | `nil` | Rows per page (omit or `0` to disable pagination) |
| `url_key:` | `nil` | URL param prefix (default `tf`); set per table to namespace multiple tables |
| `debounce_ms:` | `nil` | Search debounce in ms (default `0` = immediate) |
| `tag:` | `:div` | Wrapping HTML element |

Every helper accepts `**opts` and passes them through to the underlying tag.
Your `data:` attributes override the gem's own, so you can attach custom data without conflict.

### Rows

Each row carries a searchable name, any number of filter dimension values, and sort values
(keyed by column name):

```erb
<%= table_filter_row_tag(
      name:    user.username,
      filters: { status: user.status },
      sort:    { amount: user.balance }
    ) do %>
  <td>...</td>
<% end %>
```

Pass `tag: :div` for card-based layouts. `table_filter_row_attrs` returns the data hash without
wrapping it in a tag, for use with existing helpers.

**Sort values**: keyed by column name. `sort: { amount: 8.5 }` emits `data-sort-amount="8.5"`.
The JS reads `data-sort-{col}` when sorting on that column.

**Filter dimensions**: `filters:` maps dimension names to values, emitted as
`data-filter-{name}`. Any dimension name works; `status` is the conventional choice:

```erb
<%= table_filter_row_tag(name: "INV-7",
                         filters: { status: "open", payment: "paid", priority: "high" }) %>
```

All dimensions are optional. Filter buttons and selects declare the dimension they act on with
the required `dimension:` argument; a row matches when **every** dimension with active filters
contains its value, and rows without a value for a dimension never match that dimension's
filters. Omit `filters:` and the filter helpers entirely for a search-and-sort-only table.

### Search

```erb
<%= table_filter_search_tag(placeholder: "Search…", class: "input input-sm") %>
```

Filters rows by matching `data-name`, or `data-searchable` when present. Case-insensitive
substring match.

### Filter buttons

```erb
<%= table_filter_filter_btn_tag("all",      "All",      dimension: "status", class: "btn btn-xs") %>
<%= table_filter_filter_btn_tag("active",   "Active",   dimension: "status", class: "btn btn-xs") %>
<%= table_filter_filter_btn_tag("archived", "Archived", dimension: "status", class: "btn btn-xs") %>
```

`dimension:` names the row dimension the button acts on. Multiple buttons of one dimension can
be active at once (click toggles); clicking `all` clears that dimension. A button receives
`btn-active` and `aria-pressed` while its value is among the dimension's active filters. The
`all` button is active only when none are.

### Select and active-filter display

Single-choice alternative to buttons (a select cannot represent multi-value):

```erb
<%= table_filter_select_tag({ "All" => "all", "Active" => "active" }, dimension: "status") %>
<%= table_filter_select_tag([["All", "all"], ["Archived", "archived"]], dimension: "status") %>
<%= table_filter_select_tag(%w[All Active], dimension: "status") %>
```

Accepts a hash, an array of `[label, value]` pairs, or an array of strings (used as both label
and value). Selecting an option replaces that dimension's filter with the chosen value. Pair it
with the active-filter display, which the controller fills with the dimension's active values
and hides when the dimension has none:

```erb
<%= table_filter_active_filter_tag(dimension: "status") %> <!-- e.g. "active, archived" -->
```

### Group headers

```erb
<%= table_filter_group_header_tag("category-a") do %>
  <td colspan="5">Category A</td>
<% end %>
```

Each header carries the group key. The controller hides the header whenever no visible row
shares its `data-group`. Pass `tag: :div` for non-table layouts.

### Column headers

Convenience wrapper that renders a sortable `<th>` and falls back to a plain `<th scope="col">`
when `sortable: false`:

```erb
<%= table_filter_column_tag(col: "amount", label: "Amount", type: "numeric") %>
<%= table_filter_column_tag(col: "actions", label: "Actions", sortable: false) %>
```

### Sort triggers

Make a `<th>` the sort trigger, the recommended approach for tables:

```erb
<%= table_filter_sort_th_tag("name",   "Name") %>
<%= table_filter_sort_th_tag("amount", "Amount", type: "numeric") %>
```

Or use a standalone `<button>`:

```erb
<%= table_filter_sort_btn_tag("name", "Name") %>
```

`type: "numeric"` sorts numerically with nulls pushed to the end (both directions). Omit for lexicographic sort.
Each trigger renders a `<span data-sort-icon>` that the controller fills with `↑`, `↓`, or `↕`.
`<th>` triggers also receive `aria-sort="ascending"`, `"descending"`, or `"none"`.

### Empty row

The controller shows this row when no rows pass the active filter. It starts hidden.

```erb
<%= table_filter_empty_row_tag do %>
  <td colspan="5" class="text-center py-6">No results</td>
<% end %>
```

### Footer stats

The default footer shows how many rows match the current filter and search, out of all rows:

```erb
<%= table_filter_footer_tag(colspan: 5) %>
<!-- renders: <span>12</span> of <span>87</span> -->
```

Or build your own footer. The block receives the match-count and total-count spans:

```erb
<%= table_filter_footer_tag do |match_count, total_count| %>
  <%= match_count %> of <%= total_count %>
<% end %>
```

Available stat spans:

- `table_filter_match_count_tag`: rows passing the active filter and search, across all pages
- `table_filter_total_count_tag`: every row in the table
- `table_filter_match_pct_tag`: match count as a percentage of total
- `table_filter_count_tag`: a live counter for any dimension and value, the hook for
  domain stats; your app decides what each status means:

```erb
<%= table_filter_count_tag(dimension: "status", value: "active") %> active of
<%= table_filter_total_count_tag %>
```

### Pagination

Set `page_size:` on the container, then add the controls:

```erb
<%= table_filter_prev_btn_tag %>
<%= table_filter_page_info_tag %>
<%= table_filter_next_btn_tag %>
```

Buttons disable themselves at the bounds; `pageInfo` fills with "1–25 of 87".

### Data-attribute contract

The Stimulus controller reads and writes the following attributes. The view helpers emit all
of them; this table is a reference for debugging and for callers that bypass the helpers.

| Attribute | Set by | Purpose |
|-----------|--------|---------|
| `data-controller="table-filter"` | Container | Mounts the controller |
| `data-table-filter-sort-value` | Container | Initial sort column |
| `data-table-filter-dir-value` | Container | Initial sort direction |
| `data-table-filter-page-size-value` | Container | Rows per page (0 = no pagination) |
| `data-table-filter-page-value` | Container | Initial page number |
| `data-table-filter-search-value` | Container | Initial search text |
| `data-table-filter-url-key-value` | Container | URL param prefix (default `tf`) |
| `data-table-filter-debounce-ms-value` | Container | Search debounce in ms (0 = immediate) |
| `data-table-filter-target="row"` | Row helpers | Marks filterable rows |
| `data-name="{name}"` | Row helpers | Searchable name (downcased); fallback sort value for `name` |
| `data-searchable="{text}"` | Row helpers | Explicit search text (overrides `data-name`) |
| `data-filter-status="{value}"` | Row helpers | Value for the `status` dimension |
| `data-filter-{name}="{value}"` | Row helpers | Value for the filter dimension `{name}` |
| `data-filter-dimension="{name}"` | Filter triggers, select, display | Which dimension the trigger acts on (required) |
| `data-sort-{col}="{value}"` | Row helpers | Sort value for column |
| `data-group="{key}"` | Row helpers | Group key; header hides when all siblings are hidden |
| `data-table-filter-target="search"` | Search helper | The search input |
| `data-table-filter-target="matchCount"` | Stat helper | Span for rows matching the filter and search |
| `data-table-filter-target="totalCount"` | Stat helper | Span for the total row count |
| `data-table-filter-target="matchPct"` | Stat helper | Span for the match percentage |
| `data-count-dimension` | Count helper | Dimension the span counts |
| `data-count-value` | Count helper | Value the span counts |
| `data-table-filter-target="emptyRow"` | Empty row helper | Shown when no rows match |
| `data-table-filter-target="groupHeader"` | Group header helper | Hidden when no visible row shares its `data-group` |
| `data-table-filter-target="filterSelect"` | Select helper | Single-choice filter alternative to buttons |
| `data-table-filter-target="filterDisplay"` | Active filter helper | Filled with active filter value(s) |
| `data-table-filter-target="prevPage"` / `"nextPage"` | Pagination helpers | Page buttons (auto-disabled at bounds) |
| `data-table-filter-target="pageInfo"` | Pagination helper | Filled with "1–25 of 87" |
| `data-filter-btn="{value}"` | Filter btn helper | Marks a filter button |
| `data-sort-btn="{col}"` | Sort helpers | Marks a sort trigger |
| `data-sort-type="..."` | Sort helpers | `numeric`, `string`, `date`, `date-dmy`, `date-mdy` (default `string`) |
| `data-sort-icon` | Sort helpers | Span inside a trigger, filled with ↑ / ↓ / ↕ |
| `data-prev-page` / `data-next-page` | Pagination helpers | Click delegation on the button element |

Behavior notes:

- **Filters**: buttons act on the dimension named by their `data-filter-dimension`. Multiple
  buttons of one dimension can be active at once (click toggles); `data-filter-btn="all"` clears
  that dimension. A select always replaces its dimension's filter.
- **Sorting**: the controller sets `aria-sort` on `<th>` triggers and toggles the `btn-active`
  class on `<button>` triggers (DaisyUI).
- **Footer stats**: the match count covers every row that passes the active filters and search,
  across all pages. Count tags populate with the number of matching rows whose dimension value
  equals the tag's value.
- **URL state**: every filter dimension, sort, direction, page and search sync to
  `URLSearchParams` on every change (dimensions as `tf_filter_{dimension}` params) and the
  controller restores them on connect. Namespace multiple tables with `data-table-filter-url-key-value`.
- **Event handling**: the controller delegates all events itself; individual elements
  need no `data-action`. `setFilter`, `sortBy` and `search` are also callable programmatically.

### RSpec shared examples

After calling `StimulusTableFilter::RSpec.install!`, the `html` helper, the shared examples below
and the `have_data` / `have_data_target` matchers are available in all example groups:

```ruby
include_examples 'a table filter view'
# controller, search target, filterable row, filter/sort buttons

include_examples 'a table filter with sortable th headers'
# th elements used as sort triggers

include_examples 'a table filter with sort column', 'amount'
# specific column name has a data-sort-btn trigger

include_examples 'a table filter with sort type', 'amount', 'numeric'
# the sort trigger for that column declares the sort type

include_examples 'a table filter with accessible sort headers'
# every th sort trigger has scope="col"

include_examples 'a table filter with filter btn', 'active'
# a button marked with data-filter-btn="active"

include_examples 'a table filter with filter select'
# filterSelect target present

include_examples 'a table filter with filter display'
# filterDisplay target present

include_examples 'a table filter with initial sort', 'name'
# the container declares the initial sort column (dir: keyword also available)

include_examples 'a table filter with page size', 25
# the container declares the page size

include_examples 'a table filter with url key', 'items'
# the container declares the URL param prefix

include_examples 'a table filter with debounce', 200
# the container declares the search debounce

include_examples 'a table filter row with sort column', 'amount'
# rows carry data-sort-amount values

include_examples 'a table filter with count', 'status', 'active'
# a count span for that dimension and value is present

include_examples 'a table filter footer'
# matchCount and totalCount targets present

include_examples 'a table filter with empty row'
# emptyRow target present

include_examples 'a table filter with pagination controls'
# prev/next page buttons and pageInfo target present

include_examples 'a table filter with group headers'
# groupHeader target present

include_examples 'a table filter with group', 'category-a'
# rows carry that data-group

include_examples 'table filter rows with status', 'active'
# at least one row with data-filter-status="active"

include_examples 'table filter row named', 'alice'
# filterable row present for that name

include_examples 'table filter rows include names', 'alice', 'bob'
# filterable rows present for each name
```

The `html` helper returns `response.body` in request specs and `page.html` in system specs.
Override it with `let(:html) { ... }` when needed.

## Contributing

1. Fork it
2. Run `bundle install` to install dependencies
3. Run `bundle exec overcommit --install` once, to enable the pre-push hook (runs RuboCop and the full spec suite on every `git push`)
4. Create your feature branch (`git checkout -b my-new-feature`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Run RuboCop lint (`bundle exec rubocop lib spec --format simple`)
7. Run rspec tests (`bundle exec rspec`)
8. Push your branch (`git push origin my-new-feature`). The pre-push hook re-verifies both
9. Create a new Pull Request to `main` branch

## Releases
📢 [See what's changed in a recent version](https://github.com/icoluccio/stimulus-table-filter/releases)

## About

The current maintainer of this gem is:
* [Ignacio Coluccio](https://github.com/icoluccio)

## License

**stimulus_table_filter** is available under the MIT [license](https://raw.githubusercontent.com/icoluccio/stimulus-table-filter/main/LICENSE.md).

    Copyright (c) 2026 Ignacio Coluccio

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
