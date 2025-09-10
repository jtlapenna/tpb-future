class AddPromotionColumnsToStoreProductPromotions < ActiveRecord::Migration[6.0]
  def change
    add_column :store_product_promotions, :promotion_id, :string
    add_column :store_product_promotions, :promotion_name, :string
  end
end
