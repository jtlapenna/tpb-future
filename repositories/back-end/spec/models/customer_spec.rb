require 'rails_helper'

describe Customer do
  let(:customer) { build_stubbed :customer }

  it 'is valid' do
    expect(customer).to be_valid
  end

  it 'is not valid without customer_id' do
    customer.customer_id = nil
    expect(customer).not_to be_valid
  end
end
