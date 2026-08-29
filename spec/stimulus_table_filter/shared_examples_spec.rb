# frozen_string_literal: true

require 'spec_helper'
require 'stimulus_table_filter/rspec'

StimulusTableFilter::RSpec.install!

# Exercises all shared examples against a minimal HTML fixture so coverage
# holds and contract-string regressions fail fast.
FIXTURE_HTML = File.read(File.expand_path('../fixtures/table_filter.html', __dir__))

RSpec.describe 'shared examples against fixture HTML' do
  let(:html) { FIXTURE_HTML }

  it_behaves_like 'a table filter view'
  it_behaves_like 'a table filter with sortable th headers'
  it_behaves_like 'a table filter footer'
  it_behaves_like 'table filter rows with status', 'active'
  it_behaves_like 'table filter rows with status', 'archived'
  it_behaves_like 'table filter rows with status', 'draft'
  it_behaves_like 'table filter rows include names', 'alpha', 'beta', 'gamma'
  it_behaves_like 'a table filter with sort column', 'title'
  it_behaves_like 'a table filter with sort column', 'amount'
  it_behaves_like 'a table filter with empty row'
  it_behaves_like 'a table filter with pagination controls'
  it_behaves_like 'a table filter with group headers'
  it_behaves_like 'a table filter with group', 'category-a'
  it_behaves_like 'a table filter with filter select'
  it_behaves_like 'a table filter with filter display'
  it_behaves_like 'a table filter with initial sort', 'title'
  it_behaves_like 'a table filter with initial sort', 'title', dir: 'asc'
  it_behaves_like 'a table filter with page size', 2
  it_behaves_like 'a table filter with count', 'status', 'active'
  it_behaves_like 'a table filter with url key', 'tf'
  it_behaves_like 'a table filter with debounce', 300
  it_behaves_like 'a table filter with filter btn', 'all'
  it_behaves_like 'a table filter with filter btn', 'active'
  it_behaves_like 'a table filter with sort type', 'amount', 'numeric'
  it_behaves_like 'a table filter row with sort column', 'amount'
  it_behaves_like 'a table filter row with sort column', 'title'
  it_behaves_like 'a table filter with accessible sort headers'
end
