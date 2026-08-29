# frozen_string_literal: true

RSpec.shared_examples 'a sort trigger' do |method_name|
  subject(:result) { helper.public_send(method_name, 'title', 'Item') }

  it('sets the sort-btn data attribute') { expect(result).to have_data('sort-btn', 'title') }
  it('includes the label') { expect(result).to include('Item') }
  it('includes the sort icon span') { expect(result).to have_data('sort-icon') }
  it('omits sort-type when not given') { expect(result).not_to have_data('sort-type') }

  it('emits data-sort-type when type is given') {
    expect(helper.public_send(method_name, 'amount', 'Amount', type: 'numeric')).to have_data('sort-type', 'numeric')
  }

  it('preserves gem data when caller passes extra data') {
    expect(helper.public_send(method_name, 'title', 'Item', data: { custom: 'x' })).to have_data('sort-btn', 'title')
  }

  it('includes caller data when merging') {
    expect(helper.public_send(method_name, 'title', 'Item', data: { custom: 'x' })).to have_data('custom', 'x')
  }
end
