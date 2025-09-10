class DropTableStoreProductVariants < ActiveRecord::Migration[6.0]
  def change
    drop_table :store_product_variants
  end
end
