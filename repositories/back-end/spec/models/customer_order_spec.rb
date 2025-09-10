require 'rails_helper'

describe CustomerOrder do
  let(:customer_order) { build_stubbed :customer_order }

  it 'is valid' do
    expect(customer_order).to be_valid
  end

  it 'is not valid without customer_id' do
    customer_order.customer_id = nil
    expect(customer_order).not_to be_valid
  end

  it 'is not valid without order_id' do
    customer_order.order_id = nil
    expect(customer_order).not_to be_valid
  end

  it 'is not valid without kiosk_id' do
    customer_order.store_id = nil
    expect(customer_order).not_to be_valid
  end
end
