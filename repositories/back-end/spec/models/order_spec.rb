require 'rails_helper'

describe Order do
  let(:product) { create :store_product, sku: 'some sku' }

  let(:data) do
    {
      customer_id: '10000017',
      items: [{ product_id: product.id, quantity: 1 }]
    }
  end

  let(:order) { described_class.new(data.merge(store_id: product.store_id)) }

  it 'is valid' do
    expect(order).to be_valid
  end

  %i[customer_id store_id].each do |field|
    it "is not valid when #{field} is nil" do
      order.send "#{field}=", nil

      expect(order).not_to be_valid
    end

    it "is not valid when #{field} is ''" do
      order.send "#{field}=", ''

      expect(order).not_to be_valid
    end
  end

  it 'is not valid without items' do
    order.items = []

    expect(order).not_to be_valid
  end

  it 'is not valid when one item is not valid' do
    order.items.first.product_id = -1

    expect(order).not_to be_valid
  end

  it 'ignore unknown attributes' do
    order = described_class.new(other_field: 'aaa', customer_id: 'bbb')

    expect(order).to have_attributes customer_id: 'bbb'
    expect(order.attributes).not_to have_key 'other_field'
  end
end
