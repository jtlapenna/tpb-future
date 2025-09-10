class AddStoreIdToStoreProduct < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_products, :store, foreign_key: true
  end
end
