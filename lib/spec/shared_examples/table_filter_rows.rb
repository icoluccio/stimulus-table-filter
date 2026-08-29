# frozen_string_literal: true

RSpec.shared_examples 'table filter row named' do |name|
  it("has a filterable row for '#{name}'") { expect(html).to have_data('name', name) }
end

RSpec.shared_examples 'table filter rows with status' do |status|
  it("has at least one row with status '#{status}'") { expect(html).to have_data('filter-status', status) }
end

RSpec.shared_examples 'table filter rows include names' do |*names|
  names.each { |name| it_behaves_like 'table filter row named', name }
end
