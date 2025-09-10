class AddStoreToStorePrice < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_prices, :store, foreign_key: true
  end
end
