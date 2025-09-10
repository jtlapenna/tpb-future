class AddSkuToProductVariants < ActiveRecord::Migration[5.1]
  def change
    add_column :product_variants, :sku, :string
  end
end
