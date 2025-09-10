class AddIndexBySkuOnVariant < ActiveRecord::Migration[5.1]
  def change
    add_index :product_variants, :sku, unique: true
  end
end
