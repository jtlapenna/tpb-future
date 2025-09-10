class AddDiscountPriceToStoreProductsPromotionsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :store_product_promotions, :discount_price, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
