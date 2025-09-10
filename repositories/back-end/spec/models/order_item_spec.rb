require 'rails_helper'

describe OrderItem do
  let(:product) { create :store_product, sku: 'Some-sku' }

  let(:order) { Order.new(store_id: product.store_id) }
  let(:data) do
    {
      order: order,
      product_id: product.id,
      quantity: 1
    }
  end

  let(:item) { described_class.new(data) }

  it 'is valid' do
    expect(item).to be_valid
  end

  %i[product_id quantity].each do |field|
    it "is not valid when #{field} is nil" do
      item.send "#{field}=", nil

      expect(item).not_to be_valid
    end

    it "is not valid when #{field} is ''" do
      item.send "#{field}=", ''

      expect(item).not_to be_valid
    end
  end

  [:quantity].each do |field|
    it "is not valid when #{field} is not a number" do
      item.send "#{field}=", 'a'

      expect(item).not_to be_valid
    end
  end

  it "is not valid when catalog product doesn't exists" do
    item.product_id = -1

    expect(item).not_to be_valid
  end

  it 'is not valid when catalog product is not from order catalog' do
    item.product_id = create(:store_product).id

    expect(item).not_to be_valid
  end

  it 'ignore unknown attributes' do
    item = described_class.new(other_field: 'aaa')

    expect(item.attributes).not_to have_key 'other_field'
  end
end
