class CreateStoreProductPromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :store_product_promotions do |t|
      t.text :promotion
      t.references :store_product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
