class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :store_product
end

# == Schema Information
#
# Table name: cart_items
#
#  id               :bigint           not null, primary key
#  quantity         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cart_id          :bigint           not null
#  store_product_id :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id           (cart_id)
#  index_cart_items_on_store_product_id  (store_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (store_product_id => store_products.id)
#
