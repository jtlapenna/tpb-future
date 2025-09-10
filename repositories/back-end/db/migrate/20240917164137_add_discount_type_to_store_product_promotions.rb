class AddDiscountTypeToStoreProductPromotions < ActiveRecord::Migration[6.0]
  def change
    add_column :store_product_promotions, :discount_type, :string
  end
end
