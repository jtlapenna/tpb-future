class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :phone_number, presence: true

  def get_items(id)
    cart = Cart.Where(id: id ).includes(:cart_items).first
    cart.cart_items.map do |cart_item|
      {
        productId: cart_item.store_product_id,
      }
    end
  end

end

# == Schema Information
#
# Table name: carts
#
#  id            :bigint           not null, primary key
#  checkout_date :datetime
#  is_active     :boolean
#  phone_number  :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_carts_on_updated_at  (updated_at)
#
