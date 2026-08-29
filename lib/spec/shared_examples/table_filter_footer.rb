# frozen_string_literal: true

RSpec.shared_examples 'a table filter footer' do
  it('has a match count target') { expect(html).to have_data_target('matchCount') }
  it('has a total count target') { expect(html).to have_data_target('totalCount') }
end
