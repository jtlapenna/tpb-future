class CreateStoreProductVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :store_product_variants do |t|
      t.string :title
      t.string :sku
      t.decimal :price
      t.bigint :variant_id
      t.text :fields
      t.references :store_product

      t.timestamps
    end
  end
end
