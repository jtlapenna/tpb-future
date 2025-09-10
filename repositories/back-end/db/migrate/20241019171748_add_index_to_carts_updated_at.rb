class AddIndexToCartsUpdatedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :carts, :updated_at
  end
end
