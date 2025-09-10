class AddStoreProductIdToCartItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :cart_items, :store_product, null: false, foreign_key: true
  end
end
