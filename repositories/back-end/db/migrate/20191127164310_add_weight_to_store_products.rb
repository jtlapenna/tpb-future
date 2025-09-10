class AddWeightToStoreProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :store_products, :weight, :decimal, precision: 8, scale: 3
  end
end
