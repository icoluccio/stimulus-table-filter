# frozen_string_literal: true

RSpec.shared_examples 'merges caller data' do |gem_attr|
  let(:gem_data) { gem_attr.match(/\Adata-(.+?)="(.+)"\z/).captures }

  it('preserves gem data when caller passes extra data') {
    expect(result_with_extra_data).to have_data(gem_data[0], gem_data[1])
  }

  it('includes caller data when merging') { expect(result_with_extra_data).to have_data('custom', 'x') }
end
