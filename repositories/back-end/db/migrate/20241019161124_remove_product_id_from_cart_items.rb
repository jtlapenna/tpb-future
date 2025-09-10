class RemoveProductIdFromCartItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :cart_items, :product_id, :integer
  end
end
